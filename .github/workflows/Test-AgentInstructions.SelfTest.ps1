# .SYNOPSIS
# Runs the extracted metadata and bounded-input self-tests.
#
# .DESCRIPTION
# Validates final-state metadata arithmetic, authenticated endpoint handling,
# bounded input readers and linked-path rejection with functions loaded by
# Test-AgentInstructions.ps1.
#
# .PARAMETER RuntimeContext
# The shared runtime state supplied by the validator through the child-script boundary.
#
# .PARAMETER RepositoryRootPath
# The absolute path of the repository that supplies Git and document fixtures.
#
# .PARAMETER Revision
# The exact Git commit used as an authenticated endpoint fixture.
#
# .PARAMETER MaximumBytes
# The maximum permitted byte count for bounded Git path reads.
#
# .PARAMETER MaximumMetadataUtcDate
# The latest trusted UTC calendar date permitted in metadata fixtures.
#
# .EXAMPLE
# & ./Test-AgentInstructions.SelfTest.ps1 @hashtableArguments
#
# # Runs the extracted self-tests with validated named arguments.
#
# .INPUTS
# None. This script does not accept pipeline input.
#
# .OUTPUTS
# None. The script throws when a self-test fails.
#
# .NOTES
# Version: 1.12.20261007.0

[CmdletBinding(PositionalBinding = $false)]
[OutputType([void])]
param(
    [Parameter(Mandatory)][hashtable] $RuntimeContext,
    [Parameter(Mandatory)][string] $RepositoryRootPath,
    [Parameter(Mandatory)][string] $Revision,
    [Parameter(Mandatory)]
    [ValidateRange(1, 2147483646)]
    [int] $MaximumBytes,
    [Parameter(Mandatory)]
    [ValidatePattern('^\d{4}-\d{2}-\d{2}$')]
    [string] $MaximumMetadataUtcDate
)

$hashtableRuntimeContext = $RuntimeContext

function Assert-ParserJsonConversionSelfTest {
    # .SYNOPSIS
    # Checks native Markdown conversion against the original strict decoder.
    #
    # .DESCRIPTION
    # Compares exact types, ordered properties, type names and array elements.
    # Refusal cases require no partial output from either conversion path.
    #
    # .EXAMPLE
    # Assert-ParserJsonConversionSelfTest
    #
    # # Throws if the structural opt-in changes the JSON contract.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. A failed contract throws.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - Not a public interface.
    # Positional parameters are disabled for internal callers.
    # Version: 1.0.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param()

    $scriptBlockCompare = {
        param($Expected, $Actual)
        if ($null -eq $Expected) {
            if ($null -ne $Actual) { throw 'JSON conversion changed a null value.' }
            return
        }
        if ($null -eq $Actual -or $Expected.GetType() -ne $Actual.GetType()) {
            throw 'JSON conversion changed a value type.'
        }
        if ($Expected -is [array]) {
            if ($Expected.Count -ne $Actual.Count) { throw 'JSON conversion changed array cardinality.' }
            for ($intIndex = 0; $intIndex -lt $Expected.Count; $intIndex++) {
                & $scriptBlockCompare -Expected $Expected[$intIndex] -Actual $Actual[$intIndex]
            }
        } elseif ($Expected -is [pscustomobject]) {
            $arrExpectedProperties = @($Expected.PSObject.Properties)
            $arrActualProperties = @($Actual.PSObject.Properties)
            if ($arrExpectedProperties.Count -ne $arrActualProperties.Count -or
                ($Expected.PSObject.TypeNames -join "`0") -cne ($Actual.PSObject.TypeNames -join "`0")) {
                throw 'JSON conversion changed object properties or type names.'
            }
            for ($intIndex = 0; $intIndex -lt $arrExpectedProperties.Count; $intIndex++) {
                if ($arrExpectedProperties[$intIndex].Name -cne $arrActualProperties[$intIndex].Name) {
                    throw 'JSON conversion changed property order or spelling.'
                }
                & $scriptBlockCompare -Expected $arrExpectedProperties[$intIndex].Value `
                    -Actual $arrActualProperties[$intIndex].Value
            }
        } elseif ($Expected -is [double]) {
            if ([BitConverter]::DoubleToInt64Bits($Expected) -ne [BitConverter]::DoubleToInt64Bits($Actual)) {
                throw 'JSON conversion changed a floating-point value.'
            }
        } elseif ($Expected -cne $Actual) {
            throw 'JSON conversion changed a scalar value.'
        }
    }
    $arrValidJson = @(
        '{}',
        '{"z":[],"a":[null],"nested":[[1],[],[null]],"object":{"b":true,"a":false}}',
        '{"a":null,"b":1,"c":1.0,"d":-0.0,"e":-9223372036854775808,"f":9223372036854775807,"g":9223372036854775808,"h":1e-300}',
        '{"value":"2026-10-29T23:59:59.123456789+05:45","newline":"a\nb","unicode":"\u00e9\ud83d\ude03"}',
        '{"PSTypeName":"StyleGuide.JsonFixture","value":1}',
        '{"nested":[{"pstypename":"StyleGuide.NestedFixture","value":null}]}',
        '{"PSTypeName":null}', '{"PSTypeName":17}', '{"PSTypeName":[1,2]}',
        '{"Count":1,"Length":2,"value":3}',
        ('{"a":' + ('[' * 63) + '1' + (']' * 63) + '}')
    )
    foreach ($strContent in $arrValidJson) {
        $objExpected = ConvertFrom-ParserJsonContext -Content $strContent -MaximumBytes 16384
        $objActual = ConvertFrom-ParserJsonContext -Content $strContent -MaximumBytes 16384 `
            -UseNativeStructuralConversion
        & $scriptBlockCompare -Expected $objExpected -Actual $objActual
    }
    $strBoundaryContent = '{"text":"' + [char]0x00e9 + '"}'
    $intExactBytes = [Text.Encoding]::UTF8.GetByteCount($strBoundaryContent)
    foreach ($boolNative in @($false, $true)) {
        $objBoundary = ConvertFrom-ParserJsonContext -Content $strBoundaryContent `
            -MaximumBytes $intExactBytes -UseNativeStructuralConversion:$boolNative
        if ($objBoundary.text -cne [string][char]0x00e9) {
            throw 'JSON conversion changed exact-boundary Unicode text.'
        }
        $objBoundaryFailure = $null
        try {
            $null = ConvertFrom-ParserJsonContext -Content $strBoundaryContent `
                -MaximumBytes ($intExactBytes - 1) -UseNativeStructuralConversion:$boolNative
        } catch { $objBoundaryFailure = $_ }
        if ($null -eq $objBoundaryFailure -or
            $objBoundaryFailure.Exception.Message -cne 'The parser returned oversized JSON context.') {
            throw 'JSON conversion lost its exact UTF-8 byte bound.'
        }
    }
    # Some reserved names are rejected by PowerShell itself. Preserve that result,
    # as well as successful special-name casts, without inventing an admission rule.
    foreach ($strName in @('PSObject', 'PSBase', 'PSAdapted', 'PSExtended', 'PSTypeNames')) {
        $strContent = '{"first":1,"nested":{"' + $strName + '":"value"},"last":2}'
        $objExpected = $null
        $objExpectedFailure = $null
        $objActual = $null
        $objActualFailure = $null
        try { $objExpected = ConvertFrom-ParserJsonContext -Content $strContent -MaximumBytes 4096 } catch {
            $objExpectedFailure = $_
        }
        try {
            $objActual = ConvertFrom-ParserJsonContext -Content $strContent -MaximumBytes 4096 `
                -UseNativeStructuralConversion
        } catch { $objActualFailure = $_ }
        if (($null -eq $objExpectedFailure) -ne ($null -eq $objActualFailure)) {
            throw 'JSON conversion changed reserved-name acceptance.'
        }
        if ($null -ne $objExpectedFailure) {
            if ($objExpectedFailure.Exception.Message -cne $objActualFailure.Exception.Message) {
                throw 'JSON conversion changed reserved-name failure.'
            }
        } else { & $scriptBlockCompare -Expected $objExpected -Actual $objActual }
    }
    foreach ($strContent in @(
            '', '[]', 'null', 'true', '1', '"text"',
            '{"":1}', '{"a":1,"a":2}', '{"a":1,"A":2}', '{"a":1,"\u0061":2}',
            '{"items":[{"a":1,"A":2}]}', '{"items":[{"":1}]}',
            '{"first":1,"nested":{"PSTypeName":"Fixture","a":1,"A":2}}',
            '{"first":1,"last":1e400}', '{"first":1,"last":-1e400}',
            '{"a":NaN}', '{"a":Infinity}', '{"a":1,}', '{"a":/*comment*/1}',
            ('{"a":' + ('[' * 64) + '1' + (']' * 64) + '}'),
            ('{"a":"' + ('x' * 4096) + '"}')
        )) {
        $strExpectedFailure = $null
        foreach ($boolNative in @($false, $true)) {
            $listOutput = [Collections.Generic.List[object]]::new()
            $objFailure = $null
            try {
                ConvertFrom-ParserJsonContext -Content $strContent -MaximumBytes 4096 `
                    -UseNativeStructuralConversion:$boolNative | ForEach-Object { $listOutput.Add($_) }
            } catch { $objFailure = $_ }
            if ($null -eq $objFailure -or $listOutput.Count -ne 0) {
                throw 'JSON conversion accepted invalid input or emitted partial output.'
            }
            if (-not $boolNative) {
                $strExpectedFailure = $objFailure.Exception.Message
            } elseif ($objFailure.Exception.Message -cne $strExpectedFailure) {
                throw 'JSON conversion changed a strict decoder failure.'
            }
        }
    }
}


function Assert-MarkdownStringArrayContextSelfTest {
    # .SYNOPSIS
    # Checks admission and typed output for all six Markdown string arrays.
    #
    # .DESCRIPTION
    # Delegates to the real parser before changing one raw field per case.
    # Requires explicit valid and invalid outcomes, no partial output on refusal,
    # and exact string-array types and values. Nonstring elements, including
    # null, are refused in prose blocks, table cells and top-level list items.
    #
    # .EXAMPLE
    # Assert-MarkdownStringArrayContextSelfTest
    #
    # # Throws if a string-array shortcut changes context admission or output.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. A changed result or an unexpected parser fixture throws.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261007.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param()

    $scriptBlockActualParser = ${function:Invoke-MarkdownParserProcess}
    $hashtableFixture = @{ Family = ''; Field = ''; Json = ''; Remove = $false; Mutate = $false; Processes = 0 }
    function Invoke-MarkdownParserProcess {
        # .SYNOPSIS
        # Changes one string-array field after a fresh real parser call.
        #
        # .DESCRIPTION
        # Preserves the process result and native exit handling while replacing
        # only the selected field in fresh JSON. This wrapper is function-local.
        #
        # .PARAMETER StartInfo
        # The validated process start information passed to the real parser.
        #
        # .PARAMETER Content
        # The original Markdown fixture passed unchanged to the real parser.
        #
        # .EXAMPLE
        # Invoke-MarkdownParserProcess -StartInfo $objStartInfo -Content $strMarkdown
        #
        # # Returns the fresh process result with one declared field mutation.
        #
        # .INPUTS
        # None. No pipeline input.
        #
        # .OUTPUTS
        # [pscustomobject] The actual process result with mutated JSON output.
        #
        # .NOTES
        # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
        # Parameters, return shape, and positional contract can change without notice.
        # Positional parameters are disabled; internal callers use named arguments.
        # Version: 1.0.20261007.0
        [CmdletBinding(PositionalBinding = $false)]
        [OutputType([pscustomobject])]
        param(
            [Parameter(Mandatory)][Diagnostics.ProcessStartInfo] $StartInfo,
            [Parameter(Mandatory)][AllowEmptyString()][string] $Content
        )

        $objProcessResult = & $scriptBlockActualParser -StartInfo $StartInfo -Content $Content
        $hashtableFixture.Processes++
        if (-not $hashtableFixture.Mutate) { return $objProcessResult }
        $hashtableRawContext = $objProcessResult.Output | ConvertFrom-Json -AsHashtable
        if ($hashtableRawContext[$hashtableFixture.Family] -isnot [array] -or
            $hashtableRawContext[$hashtableFixture.Family].Count -eq 0) {
            throw 'The real parser fixture lacks the selected record family.'
        }
        if ($hashtableFixture.Family -ceq 'tableRows') {
            if ($hashtableRawContext.tableRows[0].cells -isnot [array] -or
                $hashtableRawContext.tableRows[0].cells.Count -eq 0) {
                throw 'The real parser fixture lacks a table cell.'
            }
            $hashtableRecord = $hashtableRawContext.tableRows[0].cells[0]
        } else {
            $hashtableRecord = $hashtableRawContext[$hashtableFixture.Family][0]
        }
        if (-not $hashtableRecord.Contains($hashtableFixture.Field)) {
            throw 'The real parser fixture lacks the selected string-array field.'
        }
        if ($hashtableFixture.Remove) {
            [void]($hashtableRecord.Remove($hashtableFixture.Field))
        } else {
            $objFixtureValue = ConvertFrom-ParserJsonContext `
                -Content ('{"value":' + $hashtableFixture.Json + '}') -MaximumBytes 4096
            $hashtableRecord[$hashtableFixture.Field] = $objFixtureValue.value
        }
        $objProcessResult.Output = $hashtableRawContext | ConvertTo-Json -Depth 20 -Compress
        return $objProcessResult
    }
    $strMarkdown = @(
        '# Title', '', 'Text `code` [link](https://example.invalid).', '',
        '- Item `code` [link](https://example.invalid)', '',
        '| Field | Value |', '| --- | --- |', '| Cell | `code` [link](https://example.invalid) |'
    ) -join "`n"
    $intLineCount = @([regex]::Split($strMarkdown, '\r\n|\r|\n')).Count
    $arrCases = @(
        @{ Name = 'empty'; Json = '[]'; Outcome = 'accept' },
        @{ Name = 'singleton'; Json = '["one"]'; Outcome = 'accept' },
        @{ Name = 'many strings'; Json = '["","one","\u00e9\ud83d\ude03","2026-10-06T23:00:00Z"]'; Outcome = 'accept' },
        @{ Name = 'missing'; Json = ''; Outcome = 'reject' },
        @{ Name = 'null field'; Json = 'null'; Outcome = 'reject' },
        @{ Name = 'scalar string'; Json = '"text"'; Outcome = 'reject' },
        @{ Name = 'scalar number'; Json = '1'; Outcome = 'reject' },
        @{ Name = 'scalar Boolean'; Json = 'true'; Outcome = 'reject' },
        @{ Name = 'object field'; Json = '{}'; Outcome = 'reject' },
        @{ Name = 'nested array'; Json = '[["text"]]'; Outcome = 'reject' },
        @{ Name = 'object element'; Json = '[{}]'; Outcome = 'reject' },
        @{ Name = 'bad first'; Json = '[1,"text"]'; Outcome = 'reject' },
        @{ Name = 'bad last'; Json = '["text",false]'; Outcome = 'reject' },
        @{ Name = 'null element'; Json = '[null]'; Outcome = 'reject' },
        @{ Name = 'null first string'; Json = '[null,"text"]'; Outcome = 'reject' },
        @{ Name = 'null last string'; Json = '["text",null]'; Outcome = 'reject' },
        @{ Name = 'null first number'; Json = '[null,1]'; Outcome = 'reject' },
        @{ Name = 'null last number'; Json = '[1,null]'; Outcome = 'reject' }
    )
    try {
        $strPlainMarkdown = $strMarkdown.Replace('`code`', 'code').Replace(
            '[link](https://example.invalid)', 'link')
        $objPlainContext = Get-MarkdownParseContext -Content $strPlainMarkdown -LineCount $intLineCount
        if ($null -eq $objPlainContext -or $hashtableFixture.Processes -ne 1 -or
            $objPlainContext.ProseBlocks -isnot [pscustomobject[]] -or $objPlainContext.ProseBlocks.Count -eq 0 -or
            $objPlainContext.TopLevelListItems -isnot [pscustomobject[]] -or $objPlainContext.TopLevelListItems.Count -eq 0 -or
            $objPlainContext.TableRows -isnot [pscustomobject[]] -or $objPlainContext.TableRows.Count -eq 0) {
            throw 'The plain Markdown fixture lost its fresh parser call or record families.'
        }
        foreach ($objRow in $objPlainContext.TableRows) {
            if ($objRow.Cells -isnot [pscustomobject[]] -or $objRow.Cells.Count -eq 0) {
                throw 'The plain Markdown fixture lost its typed table cells.'
            }
        }
        $arrPlainRecords = @($objPlainContext.ProseBlocks) + @($objPlainContext.TopLevelListItems) +
            @($objPlainContext.TableRows | ForEach-Object { $_.Cells })
        foreach ($objRecord in $arrPlainRecords) {
            if ($objRecord.Code -isnot [string[]] -or $objRecord.Code.Count -ne 0 -or
                $objRecord.Links -isnot [string[]] -or $objRecord.Links.Count -ne 0) {
                throw 'Plain prose, table or list Markdown lost a naturally empty string array.'
            }
        }
        $hashtableFixture.Mutate = $true
        foreach ($strFamily in @('proseBlocks', 'tableRows', 'topLevelListItems')) {
            $hashtableFixture.Family = $strFamily
            foreach ($strField in @('code', 'links')) {
                $hashtableFixture.Field = $strField
                foreach ($hashtableCase in $arrCases) {
                    $hashtableFixture.Json = $hashtableCase.Json
                    $hashtableFixture.Remove = $hashtableCase.Name -ceq 'missing'
                    $intPreviousProcesses = $hashtableFixture.Processes
                    $listOutput = [Collections.Generic.List[pscustomobject]]::new()
                    $objFailure = $null
                    try {
                        Get-MarkdownParseContext -Content $strMarkdown -LineCount $intLineCount |
                            ForEach-Object { $listOutput.Add($_) }
                    } catch {
                        # Expected refusals are compared below; unrelated failures cannot pass.
                        $objFailure = $_
                    }
                    if (($null -ne $objFailure -and $listOutput.Count -ne 0) -or
                        ($hashtableCase.Outcome -ceq 'accept' -and $null -ne $objFailure) -or
                        ($hashtableCase.Outcome -ceq 'reject' -and $null -eq $objFailure)) {
                        throw ('String-array outcome changed: {0}/{1}/{2}.' -f
                            $strFamily, $strField, $hashtableCase.Name)
                    }
                    if ($null -eq $objFailure) {
                        if ($listOutput.Count -ne 1) { throw 'String-array context lost its single output.' }
                        $objContext = $listOutput[0]
                        foreach ($strArrayName in @('CodeBlockRanges', 'ProseBlocks', 'TableRows',
                                'TopLevelBlocks', 'TopLevelListItems', 'Headings', 'LevelTwoHeadings')) {
                            if ($objContext.$strArrayName -isnot [pscustomobject[]]) {
                                throw 'String-array context changed an exact record-array type.'
                            }
                        }
                        if ($objContext.ProseBlocks.Count -eq 0 -or $objContext.TopLevelListItems.Count -eq 0 -or
                            $objContext.TableRows.Count -eq 0) {
                            throw 'String-array context lost the fixture record families.'
                        }
                        foreach ($objRecord in @($objContext.ProseBlocks) + @($objContext.TopLevelListItems)) {
                            if ($objRecord.Code -isnot [string[]] -or $objRecord.Links -isnot [string[]]) {
                                throw 'String-array context changed a prose or list string-array type.'
                            }
                        }
                        foreach ($objRow in $objContext.TableRows) {
                            if ($objRow.Cells -isnot [pscustomobject[]] -or $objRow.Cells.Count -eq 0) {
                                throw 'String-array context changed cell-array type or lost cells.'
                            }
                            foreach ($objCell in $objRow.Cells) {
                                if ($objCell.Code -isnot [string[]] -or $objCell.Links -isnot [string[]]) {
                                    throw 'String-array context changed a cell string-array type.'
                                }
                            }
                        }
                    }
                    if ($null -ne $objFailure) {
                        $strExpectedFailure = if ($hashtableFixture.Remove) {
                            "The property '${strField}' cannot be found on this object. Verify that the property exists."
                        } else {
                            switch ($strFamily) {
                                'proseBlocks' { 'The locked Markdown parser returned a malformed prose block.' }
                                'tableRows' { 'The locked Markdown parser returned a malformed table cell.' }
                                'topLevelListItems' { 'The locked Markdown parser returned a malformed top-level list item.' }
                            }
                        }
                        if ($objFailure.Exception.Message -cne $strExpectedFailure) {
                            throw ('String-array refusal changed: {0}/{1}/{2}.' -f
                                $strFamily, $strField, $hashtableCase.Name)
                        }
                    } else {
                        $objTarget = switch ($strFamily) {
                            'proseBlocks' { $objContext.ProseBlocks[0] }
                            'tableRows' { $objContext.TableRows[0].Cells[0] }
                            'topLevelListItems' { $objContext.TopLevelListItems[0] }
                        }
                        $strOutputField = if ($strField -ceq 'code') { 'Code' } else { 'Links' }
                        $objExpectedValue = ConvertFrom-ParserJsonContext `
                            -Content ('{"value":' + $hashtableCase.Json + '}') -MaximumBytes 4096
                        $arrExpectedStrings = $objExpectedValue.value
                        $arrActualStrings = $objTarget.$strOutputField
                        if ($arrActualStrings -isnot [string[]] -or
                            $arrActualStrings.Count -ne $arrExpectedStrings.Count) {
                            throw 'String-array context changed target type or cardinality.'
                        }
                        for ($intIndex = 0; $intIndex -lt $arrExpectedStrings.Count; $intIndex++) {
                            if ($arrActualStrings[$intIndex] -cne $arrExpectedStrings[$intIndex]) {
                                throw 'String-array context changed an exact target value.'
                            }
                        }
                    }
                    if ($hashtableFixture.Processes -ne $intPreviousProcesses + 1) {
                        throw 'String-array context skipped its fresh parser call.'
                    }
                }
            }
        }
    } finally {
        Set-Item -LiteralPath Function:Invoke-MarkdownParserProcess -Value $scriptBlockActualParser
    }
}


function Assert-MarkdownParseReuseSelfTest {
    # .SYNOPSIS
    # Tests isolated structural reuse without skipping the real parser.
    #
    # .DESCRIPTION
    # Counts actual parser and decoder calls, changes fresh output and definitions,
    # mutates returned graphs, and exercises bounded retention and owner cleanup.
    # Scoped wrappers delegate to the installed functions and cannot outlive this test.
    #
    # .EXAMPLE
    # Assert-MarkdownParseReuseSelfTest
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. Throws on an incorrect result.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - Not a public interface.
    # Version: 1.0.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param()

    $scriptBlockActualParser = ${function:Invoke-MarkdownParserProcess}
    $scriptBlockActualDecoder = ${function:ConvertFrom-ParserJsonContext}
    $scriptBlockActualNode = ${function:Get-NodeApplicationContext}
    $scriptBlockActualCopy = ${function:Copy-MarkdownParseReuseContext}
    $scriptBlockActualContext = ${function:Get-MarkdownParseContext}
    $hashtableProbe = @{ Processes = 0; Decodes = 0; NativeDecodes = 0; RuntimeDecodes = 0; NodeChecks = 0; Mode = ''; OverrideCalls = 0 }
    function Invoke-MarkdownParserProcess {
        param($StartInfo, $Content)
        $hashtableProbe.Processes++
        if ($hashtableProbe.Mode -ceq 'native-failure') { throw 'Fresh parser failure control.' }
        $objResult = & $scriptBlockActualParser -StartInfo $StartInfo -Content $Content
        if ($hashtableProbe.Mode -ceq 'bad-json') { $objResult.Output = '{"a":1,"a":2}' }
        if ($hashtableProbe.Mode -ceq 'bad-range') {
            $hashtableRaw = $objResult.Output | ConvertFrom-Json -AsHashtable
            $hashtableRaw.codeBlockRanges = ,@(-1, 1)
            $objResult.Output = $hashtableRaw | ConvertTo-Json -Depth 20 -Compress
        }
        return $objResult
    }
    function ConvertFrom-ParserJsonContext {
        param($Content, $MaximumBytes, [switch] $UseNativeStructuralConversion)
        if ($MaximumBytes -eq 16777216) {
            $hashtableProbe.Decodes++
            if ($UseNativeStructuralConversion) { $hashtableProbe.NativeDecodes++ }
        } else {
            $hashtableProbe.RuntimeDecodes++
        }
        return & $scriptBlockActualDecoder -Content $Content -MaximumBytes $MaximumBytes `
            -UseNativeStructuralConversion:$UseNativeStructuralConversion
    }
    function Get-NodeApplicationContext {
        $hashtableProbe.NodeChecks++
        if ($hashtableProbe.Mode -ceq 'missing-node') { return $null }
        return & $scriptBlockActualNode
    }
    $scriptBlockCountedDecoder = ${function:ConvertFrom-ParserJsonContext}
    $strMarkdown = @(
        '# Title', '', '## Metadata', '', '- **Status:** Active',
        '- **Owner:** Test', '- **Last Updated:** 2026-10-01', '- **Scope:** Test', '',
        'Text `code` [link](https://example.invalid).', '',
        '| Field | Value |', '| --- | --- |', '| Cell | `code` [link](https://example.invalid) |', '',
        '```text', 'code', '```'
    ) -join "`n"
    $intLineCount = @([regex]::Split($strMarkdown, '\r\n|\r|\n')).Count
    $objBudget = [pscustomobject]@{ Retained = 0 }
    $listSlots = [Collections.Generic.List[object]]::new()
    $objSlot = Get-MarkdownParseReuseSlot -Budget $objBudget
    $listSlots.Add($objSlot)
    try {
        $objFirst = Get-MarkdownParseContext -Content $strMarkdown -LineCount $intLineCount -ReuseSlot $objSlot
        $strExpected = $objFirst | ConvertTo-Json -Depth 12 -Compress
        $objSecond = Get-MarkdownParseContext -Content $strMarkdown -LineCount $intLineCount -ReuseSlot $objSlot
        if ($hashtableProbe.Processes -ne 2 -or $hashtableProbe.NodeChecks -ne 2 -or
            $hashtableProbe.Decodes -ne 1 -or $hashtableProbe.NativeDecodes -ne 1 -or
            ($objSecond | ConvertTo-Json -Depth 12 -Compress) -cne $strExpected) {
            throw 'Structural reuse must retain two real parser calls and one interpretation.'
        }
        foreach ($objResult in @($objFirst, $objSecond)) {
            foreach ($strArrayName in @('CodeBlockRanges', 'ProseBlocks', 'TableRows',
                    'TopLevelBlocks', 'TopLevelListItems', 'Headings', 'LevelTwoHeadings')) {
                if ($objResult.$strArrayName -isnot [pscustomobject[]]) {
                    throw 'Structural reuse changed an exact array type.'
                }
                foreach ($objRecord in $objResult.$strArrayName) {
                    $objRecord.Start = -900
                    if ($null -ne $objRecord.PSObject.Properties['Text']) { $objRecord.Text = 'mutated' }
                    foreach ($strStrings in @('Code', 'Links')) {
                        if ($null -ne $objRecord.PSObject.Properties[$strStrings]) {
                            if ($objRecord.$strStrings -isnot [string[]]) { throw 'String-array type changed.' }
                            if ($objRecord.$strStrings.Count -gt 0) { $objRecord.$strStrings[0] = 'mutated' }
                        }
                    }
                    if ($null -ne $objRecord.PSObject.Properties['Cells']) {
                        if ($objRecord.Cells -isnot [pscustomobject[]]) { throw 'Cell-array type changed.' }
                        foreach ($objCell in $objRecord.Cells) {
                            $objCell.Start = -901
                            $objCell.End = -902
                            $objCell.Text = 'mutated'
                            if ($objCell.Code.Count -gt 0) { $objCell.Code[0] = 'mutated' }
                            if ($objCell.Links.Count -gt 0) { $objCell.Links[0] = 'mutated' }
                        }
                    }
                }
            }
        }
        $objAfterMutation = Get-MarkdownParseContext -Content $strMarkdown -LineCount $intLineCount -ReuseSlot $objSlot
        if (($objAfterMutation | ConvertTo-Json -Depth 12 -Compress) -cne $strExpected -or
            $hashtableProbe.Decodes -ne 1 -or $hashtableProbe.Processes -ne 3) {
            throw 'Returned-object mutation reached the owned interpretation.'
        }
        $null = Get-MarkdownParseContext -Content $strMarkdown -LineCount ($intLineCount + 1) -ReuseSlot $objSlot
        $null = Get-MarkdownParseContext -Content ($strMarkdown + ' ') -LineCount $intLineCount -ReuseSlot $objSlot
        $null = Get-MarkdownParseContext -Content ($strMarkdown + ' ') -LineCount $intLineCount
        if ($hashtableProbe.Processes -ne 6 -or $hashtableProbe.Decodes -ne 4) {
            throw 'Changed parser input, LineCount or fresh direct call reused stale interpretation.'
        }
        foreach ($strMode in @('native-failure', 'bad-json', 'bad-range', 'missing-node')) {
            $hashtableProbe.Mode = ''
            $null = Get-MarkdownParseContext -Content $strMarkdown -LineCount $intLineCount -ReuseSlot $objSlot
            $hashtableProbe.Mode = $strMode
            $objFailure = $null
            try { $null = Get-MarkdownParseContext -Content $strMarkdown -LineCount $intLineCount -ReuseSlot $objSlot } catch {
                $objFailure = $_
            }
            $strFailure = switch ($strMode) {
                'native-failure' { 'Fresh parser failure control' }
                'bad-json' { 'invalid context data' }
                'bad-range' { 'invalid or overlapping range' }
                'missing-node' { 'trusted Node.js runtime is required' }
            }
            if ($null -eq $objFailure -or $objFailure.Exception.Message -notmatch $strFailure -or
                $null -ne $objSlot.Snapshot -or $objBudget.Retained -ne 0) {
                throw "Fresh failure or snapshot release failed: $strMode."
            }
        }
        $hashtableProbe.Mode = ''
        $null = Get-MarkdownParseContext -Content $strMarkdown -LineCount $intLineCount -ReuseSlot $objSlot
        Set-Item -LiteralPath Function:ConvertFrom-ParserJsonContext -Value {
            param($Content, $MaximumBytes)
            $hashtableProbe.OverrideCalls++
            if ($Content.Length -le $MaximumBytes) { throw 'Decoder replacement control.' }
            throw 'Unexpected decoder replacement input.'
        }
        $objFailure = $null
        try { $null = Get-MarkdownParseContext -Content $strMarkdown -LineCount $intLineCount -ReuseSlot $objSlot } catch {
            $objFailure = $_
        } finally {
            Set-Item -LiteralPath Function:ConvertFrom-ParserJsonContext -Value $scriptBlockCountedDecoder
        }
        if ($null -eq $objFailure -or $objFailure.Exception.Message -notmatch 'invalid context data' -or
            $hashtableProbe.OverrideCalls -ne 1 -or $null -ne $objSlot.Snapshot) {
            throw 'A decoder replacement was hidden by reuse.'
        }
        foreach ($strDefinition in @('Copy-MarkdownParseReuseContext', 'Get-MarkdownParseContext')) {
            $null = Get-MarkdownParseContext -Content $strMarkdown -LineCount $intLineCount -ReuseSlot $objSlot
            $intPriorDecodes = $hashtableProbe.Decodes
            $intPriorProcesses = $hashtableProbe.Processes
            try {
                if ($strDefinition -ceq 'Copy-MarkdownParseReuseContext') {
                    Set-Item -LiteralPath Function:Copy-MarkdownParseReuseContext -Value {
                        param($Context, $ParserText, $ParserOutput)
                        return & $scriptBlockActualCopy -Context $Context -ParserText $ParserText -ParserOutput $ParserOutput
                    }
                } else {
                    Set-Item -LiteralPath Function:Get-MarkdownParseContext -Value {
                        param($Content, $LineCount, $ReuseSlot)
                        return & $scriptBlockActualContext -Content $Content -LineCount $LineCount -ReuseSlot $ReuseSlot
                    }
                }
                $objReplaced = Get-MarkdownParseContext -Content $strMarkdown -LineCount $intLineCount -ReuseSlot $objSlot
                if ($hashtableProbe.Decodes -ne ($intPriorDecodes + 1) -or
                    $hashtableProbe.Processes -ne ($intPriorProcesses + 1) -or
                    ($objReplaced | ConvertTo-Json -Depth 12 -Compress) -cne $strExpected) {
                    throw "A structural helper replacement reused its former interpretation: $strDefinition."
                }
            } finally {
                Set-Item -LiteralPath Function:Copy-MarkdownParseReuseContext -Value $scriptBlockActualCopy
                Set-Item -LiteralPath Function:Get-MarkdownParseContext -Value $scriptBlockActualContext
            }
        }
        foreach ($objExisting in $listSlots) { Clear-MarkdownParseReuseSlot -Slot $objExisting }
        for ($intSlot = 0; $intSlot -lt 9; $intSlot++) {
            $objNext = Get-MarkdownParseReuseSlot -Budget $objBudget
            $listSlots.Add($objNext)
            $null = Get-MarkdownParseContext -Content '' -LineCount 1 -ReuseSlot $objNext
        }
        if ($objBudget.Retained -ne 8 -or $null -ne $objNext.Snapshot) {
            throw 'Snapshot retention exceeded eight or rejected its fresh fallback.'
        }
        Clear-MarkdownParseReuseSlot -Slot $listSlots[1]
        $null = Get-MarkdownParseContext -Content '' -LineCount 1 -ReuseSlot $objNext
        if ($objBudget.Retained -ne 8 -or $null -eq $objNext.Snapshot) {
            throw 'Released capacity was not available to the next eligible owner.'
        }
        $objEmpty = Get-MarkdownParseContext -Content '' -LineCount 1
        if ($null -eq (Copy-MarkdownParseReuseContext -Context $objEmpty -ParserText (' ' * 524288) -ParserOutput '') -or
            $null -ne (Copy-MarkdownParseReuseContext -Context $objEmpty -ParserText (' ' * 524289) -ParserOutput '')) {
            throw 'UTF-16 retention boundary changed.'
        }
        $objEmpty.CodeBlockRanges = [pscustomobject[]]@(
            for ($intRange = 0; $intRange -lt 2048; $intRange++) {
                [pscustomobject]@{ Start = $intRange * 2; End = $intRange * 2 + 1 }
            })
        if ($null -eq (Copy-MarkdownParseReuseContext -Context $objEmpty -ParserText '' -ParserOutput '')) {
            throw 'Exact structural-record retention limit was rejected.'
        }
        $objEmpty.CodeBlockRanges += [pscustomobject]@{ Start = 4096; End = 4097 }
        if ($null -ne (Copy-MarkdownParseReuseContext -Context $objEmpty -ParserText '' -ParserOutput '')) {
            throw 'Structural-record retention limit was ignored.'
        }
        $objEmpty.CodeBlockRanges = [pscustomobject[]]@()
        $objEmpty.ProseBlocks = [pscustomobject[]]@([pscustomobject]@{
                Start = 0; End = 1; Text = ''; Code = [string[]]@('' * 0); Links = [string[]]@()
            })
        $objEmpty.ProseBlocks[0].Code = [string[]]@(for ($intElement = 0; $intElement -lt 8191; $intElement++) { '' })
        if ($null -eq (Copy-MarkdownParseReuseContext -Context $objEmpty -ParserText '' -ParserOutput '')) {
            throw 'Exact array-element retention limit was rejected.'
        }
        $objEmpty.ProseBlocks[0].Code += ''
        if ($null -ne (Copy-MarkdownParseReuseContext -Context $objEmpty -ParserText '' -ParserOutput '')) {
            throw 'Array-element retention limit was ignored.'
        }
    } finally {
        foreach ($objExisting in $listSlots) { Clear-MarkdownParseReuseSlot -Slot $objExisting }
    }
    if ($objBudget.Retained -ne 0) { throw 'Document-owned reuse leaked after cleanup.' }

    $scriptBlockActualSlot = ${function:Get-MarkdownParseReuseSlot}
    $scriptBlockActualClear = ${function:Clear-MarkdownParseReuseSlot}
    $hashtableOwnerProbe = @{ Allocations = 0; FailSecond = $false; FailCleanup = $false }
    $listOwnedSlots = [Collections.Generic.List[object]]::new()
    function Get-MarkdownParseReuseSlot {
        param($Budget)
        $hashtableOwnerProbe.Allocations++
        if ($hashtableOwnerProbe.FailSecond -and $hashtableOwnerProbe.Allocations -eq 2) {
            throw 'Second-slot allocation control.'
        }
        $objOwnedSlot = & $scriptBlockActualSlot -Budget $Budget
        $listOwnedSlots.Add($objOwnedSlot)
        return $objOwnedSlot
    }
    function Clear-MarkdownParseReuseSlot {
        param($Slot)
        & $scriptBlockActualClear -Slot $Slot
        if ($hashtableOwnerProbe.FailCleanup) { throw 'Cleanup failure control.' }
    }
    $strVersioned = "# Fixture`n`n**Version:** 1.0.20261001.0`n`n## Metadata`n`n" +
        "- **Status:** Active`n- **Owner:** Test`n- **Last Updated:** 2026-10-01`n" +
        "- **Scope:** Test`n`n## Procedure`n`nFollow the procedure.`n"
    $objNormalizedSlot = & $scriptBlockActualSlot
    try {
        $hashtableProbe.Processes = 0
        $hashtableProbe.Decodes = 0
        foreach ($strNewline in @("`n", "`r`n", "`r")) {
            $objMetadata = Get-DocumentMetadataContext `
                -Content ($strVersioned.Replace("`n", $strNewline)) -ReuseSlot $objNormalizedSlot
            if ($null -ne $objMetadata.Failure) { throw 'A normalized newline metadata fixture failed.' }
        }
        if ($hashtableProbe.Processes -ne 3 -or $hashtableProbe.Decodes -ne 1) {
            throw 'Metadata consumers did not bind reuse to actual normalized text and line count.'
        }
    } finally {
        & $scriptBlockActualClear -Slot $objNormalizedSlot
    }
    $hashtableProbe.Processes = 0
    $hashtableProbe.Decodes = 0
    $arrFailure = @(Get-PublishedEndpointMetadataFailure -Name 'fixture.md' `
            -CurrentContent $strVersioned -ParentContent $strVersioned `
            -IsNewDocumentTransition $false -RequireExpectedUtcDateForRenderedChange $false)
    if ($arrFailure.Count -ne 0 -or $hashtableOwnerProbe.Allocations -ne 0 -or
        $hashtableProbe.Processes -ne 2 -or $hashtableProbe.Decodes -ne 2) {
        throw 'A direct required-Version call allocated retention or stopped parsing fresh.'
    }
    $hashtableProbe.Processes = 0
    $hashtableProbe.Decodes = 0
    $arrFailure = @(Get-PublishedEndpointLastUpdatedFailure -Name 'fixture.md' `
            -CurrentContent $strVersioned -BaseContent $strVersioned -TrustedEventUtcDate '')
    if ($arrFailure.Count -ne 0 -or $hashtableOwnerProbe.Allocations -ne 2 -or
        $hashtableProbe.Processes -ne 4 -or $hashtableProbe.Decodes -ne 2 -or
        @($listOwnedSlots | Where-Object { $null -ne $_.Snapshot -or $_.Budget.Retained -ne 0 }).Count -ne 0) {
        throw 'The optional-Version owner did not reuse and release its two interpretations.'
    }
    $objBorrowedCurrent = Get-MarkdownParseReuseSlot
    $objBorrowedParent = Get-MarkdownParseReuseSlot -Budget $objBorrowedCurrent.Budget
    try {
        $hashtableOwnerProbe.Allocations = 0
        $hashtableProbe.Processes = 0
        $hashtableProbe.Decodes = 0
        $arrFailure = @(Get-PublishedEndpointLastUpdatedFailure -Name 'fixture.md' `
                -CurrentContent $strVersioned -BaseContent $strVersioned -TrustedEventUtcDate '' `
                -CurrentParseReuse $objBorrowedCurrent -ParentParseReuse $objBorrowedParent)
        if ($arrFailure.Count -ne 0 -or $hashtableOwnerProbe.Allocations -ne 0 -or
            $hashtableProbe.Processes -ne 4 -or $hashtableProbe.Decodes -ne 2 -or
            $objBorrowedCurrent.Budget.Retained -ne 2) {
            throw 'Nested borrowed slots changed owner count or lost their interpretations.'
        }
        Clear-MarkdownParseReuseSlot -Slot $objBorrowedCurrent
        Clear-MarkdownParseReuseSlot -Slot $objBorrowedParent
        $hashtableProbe.Processes = 0
        $hashtableProbe.Decodes = 0
        $arrFailure = @(Get-PublishedEndpointLastUpdatedFailure -Name 'fixture.md' `
                -CurrentContent $strVersioned -BaseContent $strVersioned -TrustedEventUtcDate '' `
                -CurrentParseReuse $objBorrowedCurrent)
        if ($arrFailure.Count -ne 0 -or $hashtableOwnerProbe.Allocations -ne 0 -or
            $hashtableProbe.Processes -ne 4 -or $hashtableProbe.Decodes -ne 3 -or
            $objBorrowedCurrent.Budget.Retained -ne 1) {
            throw 'A partial borrowed pair allocated an owner or reused its absent slot.'
        }
    } finally {
        Clear-MarkdownParseReuseSlot -Slot $objBorrowedCurrent
        Clear-MarkdownParseReuseSlot -Slot $objBorrowedParent
    }
    $hashtableOwnerProbe.Allocations = 0
    $hashtableOwnerProbe.FailSecond = $true
    $hashtableOwnerProbe.FailCleanup = $true
    $objFailure = $null
    try {
        $null = Get-PublishedEndpointLastUpdatedFailure -Name 'fixture.md' `
            -CurrentContent $strVersioned -BaseContent $strVersioned -TrustedEventUtcDate ''
    } catch {
        $objFailure = $_
    } finally {
        $hashtableOwnerProbe.FailSecond = $false
        $hashtableOwnerProbe.FailCleanup = $false
    }
    if ($null -eq $objFailure -or $objFailure.Exception.Message -notmatch 'Second-slot allocation control' -or
        @($listOwnedSlots | Where-Object { $null -ne $_.Snapshot -or $_.Budget.Retained -ne 0 }).Count -ne 0) {
        throw 'Partial allocation cleanup replaced the primary failure or retained data.'
    }
}


function Assert-DocumentMetadataClassificationSelfTest {
    # .SYNOPSIS
    # Exercises classification coverage and trusted-baseline exemption safety.
    #
    # .DESCRIPTION
    # Checks malformed data, undiscovered governed documents, and attempted
    # candidate-only exemptions through the actual classification consumers.
    #
    # .PARAMETER MaximumMetadataUtcDate
    # The trusted finalization UTC date used by the loaded validator.
    #
    # .EXAMPLE
    # Assert-DocumentMetadataClassificationSelfTest -MaximumMetadataUtcDate '2026-10-02'
    #
    # # Throws if classification permits an unsafe exemption or misses a path.
    #
    # .INPUTS
    # None. This function does not accept pipeline input.
    #
    # .OUTPUTS
    # None. The function throws when a security fixture is accepted.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $MaximumMetadataUtcDate)

    $strNewVersionedDocument = "# New versioned fixture`n`n**Version:** 1.0.$($MaximumMetadataUtcDate.Replace('-', '')).0`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Fixture Maintainers`n- **Last Updated:** $MaximumMetadataUtcDate`n- **Scope:** Null-base finalization.`n`n## Procedure`n`nFollow the current procedure.`n"
    if (@(Get-PublishedEndpointMetadataFailure -Name 'new-versioned.md' `
                -CurrentContent $strNewVersionedDocument -ParentContent $null `
                -ExpectedUtcDate $MaximumMetadataUtcDate -IsNewDocumentTransition $true `
                -RequireExpectedUtcDateForRenderedChange $true).Count -ne 0) {
        throw 'Current-date null-base versioned finalization was rejected.'
    }
    $strEarlierVersionedDate = [DateTime]::ParseExact($MaximumMetadataUtcDate, 'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture).AddDays(-1).ToString('yyyy-MM-dd')
    $strEarlierVersionedDocument = $strNewVersionedDocument.Replace(
        $MaximumMetadataUtcDate, $strEarlierVersionedDate).Replace(
        $MaximumMetadataUtcDate.Replace('-', ''), $strEarlierVersionedDate.Replace('-', ''))
    if (-not (@(Get-PublishedEndpointMetadataFailure -Name 'new-versioned.md' `
                -CurrentContent $strEarlierVersionedDocument -ParentContent $null `
                -ExpectedUtcDate $MaximumMetadataUtcDate -IsNewDocumentTransition $true `
                -RequireExpectedUtcDateForRenderedChange $true) -match 'Last Updated must')) {
        throw 'Stale null-base versioned finalization bypassed the explicit date requirement.'
    }
    $arrTrackedFixturePaths = @(
        'README.md', 'generated.md', '.cursor/rules/operations.mdc',
        'docs/RUNBOOK.md', 'docs/decisions/0001-safety.md')
    $strValidClassification = '{"schemaVersion":2,"authorizedExemptionPaths":[],' +
        '"tier2Paths":["README.md"],"generatedPaths":["generated.md"]}'
    $objValidContext = Get-DocumentMetadataClassificationContext `
        -Content $strValidClassification -TrackedPath $arrTrackedFixturePaths
    if ($null -ne $objValidContext.Failure) {
        throw 'The valid exact classification fixture was rejected.'
    }
    $arrDiscoveredFixturePaths = @(Get-DiscoveredGovernedMarkdownDocumentPath `
            -CandidatePath $arrTrackedFixturePaths `
            -KnownGovernedPath @('docs/decisions/0001-safety.md') `
            -ExemptPath $objValidContext.ExemptPaths)
    if ($arrDiscoveredFixturePaths.Count -ne 2 -or
        $arrDiscoveredFixturePaths -cnotcontains '.cursor/rules/operations.mdc' -or
        $arrDiscoveredFixturePaths -cnotcontains 'docs/RUNBOOK.md') {
        throw 'New or hidden governed Markdown escaped classification discovery.'
    }
    $arrSuffixPaths = @('docs/RUNBOOK.MD', 'docs/mixed.Md', 'docs/example.MdC',
        '.cursor/rules/operations.MDC', 'docs/exact.md', 'docs/exact.MD')
    $arrSuffixDiscovered = @(Get-DiscoveredGovernedMarkdownDocumentPath `
            -CandidatePath ($arrSuffixPaths + @('notes.txt')) -KnownGovernedPath @() -ExemptPath @())
    if ($arrSuffixDiscovered.Count -ne $arrSuffixPaths.Count) { throw 'Markdown suffix discovery lost exact paths.' }
    foreach ($strSuffixPath in $arrSuffixPaths) {
        if ($arrSuffixDiscovered -cnotcontains $strSuffixPath) { throw "Markdown suffix path changed: $strSuffixPath" }
        foreach ($strCategory in @('tier2Paths', 'generatedPaths', 'authorizedExemptionPaths')) {
            $hashtableManifest = @{ schemaVersion = 2; tier2Paths = @(); generatedPaths = @(); authorizedExemptionPaths = @() }
            $hashtableManifest[$strCategory] = @($strSuffixPath)
            $objSuffixContext = Get-DocumentMetadataClassificationContext `
                -Content ($hashtableManifest | ConvertTo-Json -Compress) -TrackedPath $arrSuffixPaths
            if ($objSuffixContext.Failure) { throw "Valid Markdown suffix classification failed: $strSuffixPath" }
        }
    }
    foreach ($strCaseAlias in @('AGENTS.MD', '.cursor/rules/operations.MDC')) {
        if (-not (Test-GovernedInstructionPathCaseMismatch -RepositoryRelativePath $strCaseAlias `
                    -GovernedRootPaths @('AGENTS.md'))) {
            throw "Existing governed-family casing rule was lost: $strCaseAlias"
        }
    }
    $objUpperCandidate = Get-DocumentMetadataClassificationContext `
        -Content '{"schemaVersion":2,"authorizedExemptionPaths":[],"tier2Paths":["docs/RUNBOOK.MD"],"generatedPaths":[]}' `
        -TrackedPath $arrSuffixPaths
    foreach ($strAuthorizedPath in @('docs/RUNBOOK.MD', 'docs/runbook.md')) {
        $arrSuffixFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
                -HasTrustedBaselineManifest $true -TrustedBaselineExemptPath @() `
                -TrustedBaselineAuthorizedExemptionPath @($strAuthorizedPath) `
                -CandidateExemptPath $objUpperCandidate.ExemptPaths `
                -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath @())
        if (($strAuthorizedPath -ceq 'docs/RUNBOOK.MD') -ne ($arrSuffixFailures.Count -eq 0)) {
            throw 'Markdown suffix recognition changed exact authorization identity.'
        }
    }
    if (@(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $true -TrustedBaselineExemptPath $objUpperCandidate.ExemptPaths `
            -TrustedBaselineAuthorizedExemptionPath @() -CandidateExemptPath $objUpperCandidate.ExemptPaths `
            -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath $objUpperCandidate.ExemptPaths).Count -eq 0) {
        throw 'An uppercase Tier2 path gained unauthenticated generated status.'
    }
    foreach ($strDiscoveredFixturePath in $arrDiscoveredFixturePaths) {
        $objMissingMetadataContext = Get-DocumentMetadataContext `
            -Content "# Operational procedure`n`nRun the reviewed procedure.`n" `
            -RequiresVersion $false
        if ($null -eq $objMissingMetadataContext.Failure) {
            throw "Discovered governed content accepted a missing header: $strDiscoveredFixturePath"
        }
    }

    $arrInvalidClassificationFixtures = @(
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":1'),
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":"2"'),
        $strValidClassification.Replace('"schemaVersion":2,', ''),
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":2,"schemaVersion":2'),
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":2,"unknown":true'),
        $strValidClassification.Replace('"tier2Paths":["README.md"]', '"tier2Paths":null'),
        $strValidClassification.Replace('"README.md"', '42'),
        $strValidClassification.Replace('"README.md"', '"README.md","README.md"'),
        $strValidClassification.Replace('"README.md"', '"generated.md","README.md"'),
        $strValidClassification.Replace('"README.md"', '"untracked.md"'),
        $strValidClassification.Replace('"generated.md"', '"README.md"'),
        $strValidClassification.Replace('"README.md"', '"../README.md"'),
        $strValidClassification.Replace('"README.md"', '"/README.md"'),
        $strValidClassification.Replace('"README.md"', '"docs\\README.md"'),
        $strValidClassification.Replace('"README.md"', '"README\u000a.md"'),
        $strValidClassification.Replace('"README.md"', '"README.txt"'),
        $strValidClassification.Replace('"authorizedExemptionPaths":[]', '"authorizedExemptionPaths":null'),
        $strValidClassification.Replace('"authorizedExemptionPaths":[]', '"authorizedExemptionPaths":["README.md"]'),
        $strValidClassification.Replace('"authorizedExemptionPaths":[]', '"authorizedExemptionPaths":["../future.md"]'),
        $strValidClassification.Replace('"authorizedExemptionPaths":[]', '"authorizedExemptionPaths":["future.md","future.md"]'),
        $strValidClassification.Replace('"authorizedExemptionPaths":[]', '"authorizedExemptionPaths":["z.md","a.md"]'),
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":[[[[[[[[[[2]]]]]]]]]]'),
        $strValidClassification.Replace('"schemaVersion":2', '"schemaVersion":2/*comment*/'),
        $strValidClassification.TrimEnd('}') + ',}'
    )
    foreach ($strInvalidClassification in $arrInvalidClassificationFixtures) {
        $objInvalidContext = Get-DocumentMetadataClassificationContext `
            -Content $strInvalidClassification -TrackedPath $arrTrackedFixturePaths
        if ($null -eq $objInvalidContext.Failure) {
            throw "An unsafe classification fixture was accepted: $strInvalidClassification"
        }
    }

    $arrCandidateActivePaths = @('README.md', 'docs/RUNBOOK.md')
    $arrCandidateOnlyFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $true `
            -TrustedBaselineExemptPath @('README.md') `
            -TrustedBaselineAuthorizedExemptionPath @() `
            -CandidateExemptPath $arrCandidateActivePaths `
            -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath @())
    if ($arrCandidateOnlyFailures.Count -ne 1 -or
        $arrCandidateOnlyFailures[0] -notmatch 'docs/RUNBOOK\.md') {
        throw 'Candidate-only metadata exemption bypassed the trusted baseline.'
    }
    $strCandidateAuthorization = $strValidClassification.Replace(
        '"authorizedExemptionPaths":[]',
        '"authorizedExemptionPaths":["docs/RUNBOOK.md"]')
    $objCandidateAuthorizationContext = Get-DocumentMetadataClassificationContext `
        -Content $strCandidateAuthorization -TrackedPath $arrTrackedFixturePaths
    if ($null -ne $objCandidateAuthorizationContext.Failure -or
        $objCandidateAuthorizationContext.ExemptPaths -ccontains 'docs/RUNBOOK.md') {
        throw 'A candidate future authorization became an active exemption.'
    }
    $arrAuthorizedFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $true `
            -TrustedBaselineExemptPath @('README.md') `
            -TrustedBaselineAuthorizedExemptionPath @('docs/RUNBOOK.md') `
            -CandidateExemptPath $arrCandidateActivePaths `
            -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath @())
    if ($arrAuthorizedFailures.Count -ne 0) {
        throw 'The exact trusted baseline authorization was rejected.'
    }
    $arrWrongAuthorizationFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $true `
            -TrustedBaselineExemptPath @('README.md') `
            -TrustedBaselineAuthorizedExemptionPath @('docs/another.md') `
            -CandidateExemptPath $arrCandidateActivePaths `
            -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath @())
    if ($arrWrongAuthorizationFailures.Count -ne 1) {
        throw 'An authorization for another path permitted the candidate exemption.'
    }
    $arrBootstrapFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
            -HasTrustedBaselineManifest $false `
            -TrustedBaselineExemptPath @() `
            -TrustedBaselineAuthorizedExemptionPath @() `
            -CandidateExemptPath $objValidContext.ExemptPaths `
            -TrustedBaselineGeneratedPath @() -CandidateGeneratedPath $objValidContext.GeneratedPaths)
    if ($arrBootstrapFailures.Count -ne 1) {
        throw 'A missing trusted manifest bypassed the closed initialization proof.'
    }
    $strJoinerPath = 'a' + [char]0x200d + 'b.md'
    $strComposedPath = [string][char]0x00e9 + '.md'
    $strDecomposedPath = 'e' + [char]0x0301 + '.md'
    $arrCategoryTrackedPaths = @('a.md', 'b.md', 'ab.md', $strJoinerPath, $strComposedPath, $strDecomposedPath)
    $arrCategoryCases = @(
        @{ Name = 'unchanged'; BT = @('a.md'); BG = @('b.md'); BA = @(); CT = @('a.md'); CG = @('b.md'); CA = @(); Failure = '' },
        @{ Name = 'Tier2 to generated'; BT = @('a.md'); BG = @(); BA = @(); CT = @(); CG = @('a.md'); CA = @(); Failure = 'unauthenticated generated status: a.md' },
        @{ Name = 'generated to Tier2'; BT = @(); BG = @('a.md'); BA = @(); CT = @('a.md'); CG = @(); CA = @(); Failure = '' },
        @{ Name = 'category swap'; BT = @('a.md'); BG = @('b.md'); BA = @(); CT = @('b.md'); CG = @('a.md'); CA = @(); Failure = 'unauthenticated generated status: a.md' },
        @{ Name = 'remove Tier2'; BT = @('a.md'); BG = @('b.md'); BA = @(); CT = @(); CG = @('b.md'); CA = @(); Failure = '' },
        @{ Name = 'remove generated'; BT = @('a.md'); BG = @('b.md'); BA = @(); CT = @('a.md'); CG = @(); CA = @(); Failure = '' },
        @{ Name = 'remove all'; BT = @('a.md'); BG = @('b.md'); BA = @(); CT = @(); CG = @(); CA = @(); Failure = '' },
        @{ Name = 'new Tier2'; BT = @(); BG = @(); BA = @(); CT = @('a.md'); CG = @(); CA = @(); Failure = 'unauthenticated metadata exemption: a.md' },
        @{ Name = 'new generated'; BT = @(); BG = @(); BA = @(); CT = @(); CG = @('a.md'); CA = @(); Failure = 'unauthenticated generated status: a.md' },
        @{ Name = 'authorized Tier2'; BT = @(); BG = @(); BA = @('a.md'); CT = @('a.md'); CG = @(); CA = @(); Failure = '' },
        @{ Name = 'authorized generated'; BT = @(); BG = @(); BA = @('a.md'); CT = @(); CG = @('a.md'); CA = @(); Failure = '' },
        @{ Name = 'wrong authorization'; BT = @('a.md'); BG = @(); BA = @('b.md'); CT = @(); CG = @('a.md'); CA = @(); Failure = 'unauthenticated generated status: a.md' },
        @{ Name = 'candidate authorization inert'; BT = @('a.md'); BG = @(); BA = @(); CT = @('a.md'); CG = @(); CA = @('b.md'); Failure = '' },
        @{ Name = 'remove and authorize'; BT = @('a.md'); BG = @(); BA = @(); CT = @(); CG = @(); CA = @('a.md'); Failure = '' },
        @{ Name = 'ordinal generated joiner'; BT = @($strJoinerPath); BG = @('ab.md'); BA = @(); CT = @(); CG = @('ab.md', $strJoinerPath); CA = @(); Failure = "unauthenticated generated status: $strJoinerPath" },
        @{ Name = 'ordinal union joiner'; BT = @('ab.md'); BG = @(); BA = @(); CT = @('ab.md', $strJoinerPath); CG = @(); CA = @(); Failure = "unauthenticated metadata exemption: $strJoinerPath" },
        @{ Name = 'ordinal normalization distinction'; BT = @($strComposedPath); BG = @($strDecomposedPath); BA = @(); CT = @(); CG = @($strDecomposedPath, $strComposedPath); CA = @(); Failure = "unauthenticated generated status: $strComposedPath" },
        @{ Name = 'ordinal exact authorization'; BT = @(); BG = @('ab.md'); BA = @($strJoinerPath); CT = @(); CG = @('ab.md', $strJoinerPath); CA = @(); Failure = '' }
    )
    foreach ($objCase in $arrCategoryCases) {
        $strBaseline = @{ schemaVersion = 2; tier2Paths = $objCase.BT; generatedPaths = $objCase.BG; authorizedExemptionPaths = $objCase.BA } | ConvertTo-Json -Compress
        $strCandidate = @{ schemaVersion = 2; tier2Paths = $objCase.CT; generatedPaths = $objCase.CG; authorizedExemptionPaths = $objCase.CA } | ConvertTo-Json -Compress
        $objBaseline = Get-DocumentMetadataClassificationContext -Content $strBaseline -TrackedPath $arrCategoryTrackedPaths
        $objCandidate = Get-DocumentMetadataClassificationContext -Content $strCandidate -TrackedPath $arrCategoryTrackedPaths
        if ($objBaseline.Failure -or $objCandidate.Failure) { throw "Invalid category fixture: $($objCase.Name)" }
        $arrFailures = @(Get-DocumentMetadataClassificationExpansionFailure `
                -HasTrustedBaselineManifest $true `
                -TrustedBaselineExemptPath $objBaseline.ExemptPaths `
                -TrustedBaselineAuthorizedExemptionPath $objBaseline.AuthorizedExemptionPaths `
                -CandidateExemptPath $objCandidate.ExemptPaths `
                -TrustedBaselineGeneratedPath $objBaseline.GeneratedPaths `
                -CandidateGeneratedPath $objCandidate.GeneratedPaths)
        if (($objCase.Failure -ceq '' -and $arrFailures.Count -ne 0) -or
            ($objCase.Failure -cne '' -and -not ($arrFailures -match [regex]::Escape($objCase.Failure)))) {
            throw "Category transition failed: $($objCase.Name): $($arrFailures -join '; ')"
        }
    }
    $arrInitialTier2 = @('ACKNOWLEDGMENTS.md', 'CONTRIBUTING.md', 'README.md',
        'samples/test-nested-markdown-linting.md', 'samples/test-recursive-nested-markdown.md')
    $arrInitialGenerated = @('STYLE_GUIDE_CHAT.md', 'STYLE_GUIDE_FULL.md',
        'copilot-instructions.md', 'powershell.instructions.md')
    $hashtableInitialMapping = @{
        schemaVersion = 2
        authorizedExemptionPaths = @()
        tier2Paths = $arrInitialTier2
        generatedPaths = $arrInitialGenerated
    }
    $strInitialMapping = $hashtableInitialMapping | ConvertTo-Json -Depth 5
    $objInitialMapping = Get-DocumentMetadataClassificationContext -Content $strInitialMapping `
        -TrackedPath @($arrInitialTier2 + $arrInitialGenerated + @('docs/extra.md'))
    $strInitialBase = 'a71f16a8d76beeca1ba8fdc3b1c95e1958e0973c'
    $strInitialValidatorSha = '5a61845f756be1d1bc4ddb772ffbc6c71ab525f0394d11d8c672f998a05fb4a5'
    if (@(Get-InitialDocumentMetadataClassificationFailure -BaselineRevision $strInitialBase `
                -TrustedBaselineValidatorSha256 $strInitialValidatorSha -CandidateContext $objInitialMapping).Count -ne 0) {
        throw 'The parsed closed initial mapping with harmless formatting was rejected.'
    }
    foreach ($objInitialNegative in @(
            @{ Base = '48f4d8a36c8faceee12afac78aaecea0d176125d'; Sha = $strInitialValidatorSha; Context = $objInitialMapping },
            @{ Base = ('0' * 40); Sha = $strInitialValidatorSha; Context = $objInitialMapping },
            @{ Base = $strInitialBase; Sha = ('0' * 64); Context = $objInitialMapping })) {
        if (@(Get-InitialDocumentMetadataClassificationFailure -BaselineRevision $objInitialNegative.Base `
                    -TrustedBaselineValidatorSha256 $objInitialNegative.Sha -CandidateContext $objInitialNegative.Context).Count -eq 0) {
            throw 'An unsupported initialization identity was accepted.'
        }
    }
    foreach ($strChangedMapping in @(
            $strInitialMapping.Replace('"ACKNOWLEDGMENTS.md",', ''),
            $strInitialMapping.Replace('"README.md",', '"README.md", "docs/extra.md",'),
            $strInitialMapping.Replace('"authorizedExemptionPaths": []', '"authorizedExemptionPaths": ["docs/extra.md"]'),
            $strInitialMapping.Replace('"STYLE_GUIDE_CHAT.md",', '').Replace('"README.md",', '"README.md", "STYLE_GUIDE_CHAT.md",'))) {
        $objChangedMapping = Get-DocumentMetadataClassificationContext -Content $strChangedMapping `
            -TrackedPath @($arrInitialTier2 + $arrInitialGenerated + @('docs/extra.md'))
        if (@(Get-InitialDocumentMetadataClassificationFailure -BaselineRevision $strInitialBase `
                    -TrustedBaselineValidatorSha256 $strInitialValidatorSha -CandidateContext $objChangedMapping).Count -eq 0) {
            throw 'An omitted, expanded, authorized or reclassified initial mapping was accepted.'
        }
    }
    foreach ($strUnsafeDiscoveryPath in @('../escape.md', '/root.md', 'docs\bad.md')) {
        $boolDiscoveryRejected = $false
        try {
            $null = @(Get-DiscoveredGovernedMarkdownDocumentPath `
                    -CandidatePath @($strUnsafeDiscoveryPath) `
                    -KnownGovernedPath @() -ExemptPath @())
        } catch {
            $boolDiscoveryRejected = $true
        }
        if (-not $boolDiscoveryRejected) {
            throw "Unsafe tracked document discovery was accepted: $strUnsafeDiscoveryPath"
        }
    }
    $boolGovernedExemptionRejected = $false
    try {
        $null = @(Get-DiscoveredGovernedMarkdownDocumentPath `
                -CandidatePath @('docs/RUNBOOK.md') `
                -KnownGovernedPath @('docs/RUNBOOK.md') `
                -ExemptPath @('docs/RUNBOOK.md'))
    } catch {
        $boolGovernedExemptionRejected = $true
    }
    if (-not $boolGovernedExemptionRejected) {
        throw 'A known governed document was allowed to exempt itself.'
    }

    foreach ($objIgnoreFixture in @(
            [pscustomobject]@{ Path = 'CLAUDE.local.md'; Rules = "CLAUDE.local.md`n"; Expected = $true },
            [pscustomobject]@{ Path = 'nested/CLAUDE.local.md'; Rules = "CLAUDE.local.md`n"; Expected = $true },
            [pscustomobject]@{ Path = 'nested/CLAUDE.local.md'; Rules = "/CLAUDE.local.md`n"; Expected = $false },
            [pscustomobject]@{ Path = 'CLAUDE.local.md'; Rules = "CLAUDE.local.md`n!CLAUDE.local.md`n"; Expected = $false },
            [pscustomobject]@{ Path = 'nested/CLAUDE.local.md'; Rules = "CLAUDE.local.md`n!nested/CLAUDE.local.md`n"; Expected = $false },
            [pscustomobject]@{ Path = 'CLAUDE.md'; Rules = "CLAUDE.local.md`n"; Expected = $false },
            [pscustomobject]@{ Path = 'nested/CLAUDE.md'; Rules = "CLAUDE.local.md`n"; Expected = $false },
            [pscustomobject]@{ Path = 'CLAUDE.md'; Rules = "CLAUDE*.md`n"; Expected = $true }
        )) {
        $boolIgnoreResult = Test-GitIgnorePathEffective `
            -GitIgnoreContent $objIgnoreFixture.Rules `
            -RepositoryRelativePath $objIgnoreFixture.Path
        if ($boolIgnoreResult -ne $objIgnoreFixture.Expected) {
            throw "Personal-memory ignore scope fixture failed: $($objIgnoreFixture.Path)"
        }
    }

    $arrTimestampFixtures = @(
        '2026-10-29T23:59:59Z',
        '2026-10-29T23:59:59.123456789+05:45',
        '2026-10-29T23:59:59.000000001-07:30')
    $strTimestampMarkdown = 'Values: ' +
        (($arrTimestampFixtures | ForEach-Object { '`' + $_ + '`' }) -join ', ') + ".`n"
    $objTimestampContext = Get-MarkdownParseContext -Content $strTimestampMarkdown -LineCount 2
    $arrActualTimestampValues = @($objTimestampContext.ProseBlocks[0].Code)
    if ($arrActualTimestampValues.Count -ne $arrTimestampFixtures.Count) {
        throw 'The real Markdown parser lost timestamp code spans.'
    }
    for ($intTimestampIndex = 0; $intTimestampIndex -lt $arrTimestampFixtures.Count; $intTimestampIndex++) {
        if ($arrActualTimestampValues[$intTimestampIndex] -isnot [string] -or
            $arrActualTimestampValues[$intTimestampIndex] -cne $arrTimestampFixtures[$intTimestampIndex]) {
            throw 'The real Markdown parser changed timestamp type, offset or precision.'
        }
    }
    $objTypedJson = ConvertFrom-ParserJsonContext `
        -Content '{"empty":[],"one":[null],"nested":[[1]],"null":null,"true":true,"false":false,"integer":1,"decimal":1.25,"text":"2026-10-29T23:59:59.123456789+05:45"}' `
        -MaximumBytes 4096
    if ($objTypedJson.empty -isnot [array] -or $objTypedJson.empty.Count -ne 0 -or
        $objTypedJson.one -isnot [array] -or $objTypedJson.one.Count -ne 1 -or
        $null -ne $objTypedJson.one[0] -or $objTypedJson.nested[0] -isnot [array] -or
        $null -ne $objTypedJson.null -or $objTypedJson.true -isnot [bool] -or
        -not $objTypedJson.true -or $objTypedJson.false -isnot [bool] -or $objTypedJson.false -or
        $objTypedJson.integer -isnot [int64] -or $objTypedJson.integer -ne 1 -or
        $objTypedJson.decimal -isnot [double] -or $objTypedJson.decimal -ne 1.25 -or
        $objTypedJson.text -isnot [string] -or $objTypedJson.text -cne $arrTimestampFixtures[1]) {
        throw 'Parser JSON decoding changed typed context shape.'
    }
    foreach ($strInvalidParserJson in @(
            '[]', '{"a":1,"a":2}', '{"a":1,"A":2}', '{"a":1,}',
            '{"a":/* comment */1}', '{"a":1e400}',
            ('{"a":' + ('[' * 65) + '1' + (']' * 65) + '}'),
            ('{"a":"' + ('x' * 4096) + '"}'))) {
        $boolParserJsonRejected = $false
        try {
            $null = ConvertFrom-ParserJsonContext -Content $strInvalidParserJson -MaximumBytes 4096
        } catch {
            $boolParserJsonRejected = $true
        }
        if (-not $boolParserJsonRejected) {
            throw 'Parser JSON decoding accepted malformed, ambiguous or unbounded input.'
        }
    }

    foreach ($objRecursiveIgnoreFixture in @(
            [pscustomobject]@{ Name = 'canonical all-depth pattern'; Rules = "CLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'native recursive alias'; Rules = "**/CLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'enumerated root and literal depth'; Rules = "/CLAUDE.local.md`n/nested/CLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'deep later negation'; Rules = "CLAUDE.local.md`n!tools/project/CLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'exclusion restores proof'; Rules = "!tools/project/CLAUDE.local.md`nCLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'broad later negation'; Rules = "CLAUDE.local.md`n!*.md`n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'harmless later negation needs reordering'; Rules = "CLAUDE.local.md`n!README.local.md`n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'escaped negation is literal'; Rules = "CLAUDE.local.md`n\!example.md`n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'comments do not negate'; Rules = "CLAUDE.local.md`n# !*.md`n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'leading space remains literal'; Rules = " CLAUDE.local.md`n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'native trailing spaces'; Rules = "CLAUDE.local.md  `n"; Paths = @('.gitignore'); Expected = $true },
            [pscustomobject]@{ Name = 'escaped trailing space is literal'; Rules = "CLAUDE.local.md\ `n"; Paths = @('.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'nested override invalidates proof'; Rules = "CLAUDE.local.md`n"; Paths = @('.gitignore', 'tools/.gitignore'); Expected = $false },
            [pscustomobject]@{ Name = 'case alias invalidates proof'; Rules = "CLAUDE.local.md`n"; Paths = @('.gitignore', 'tools/.GITIGNORE'); Expected = $false },
            [pscustomobject]@{ Name = 'root ignore is required'; Rules = "CLAUDE.local.md`n"; Paths = @(); Expected = $false }
        )) {
        if ((Test-RecursivePersonalMemoryIgnoreContract `
                -GitIgnoreContent $objRecursiveIgnoreFixture.Rules `
                -TrackedPath $objRecursiveIgnoreFixture.Paths) -ne $objRecursiveIgnoreFixture.Expected) {
            throw "Recursive root-ignore proof failed: $($objRecursiveIgnoreFixture.Name)"
        }
    }
    foreach ($strRecursiveRule in @("CLAUDE.local.md`n", "**/CLAUDE.local.md`n")) {
        foreach ($strPrivatePath in @('CLAUDE.local.md', 'nested/CLAUDE.local.md', 'tools/project/CLAUDE.local.md')) {
            if (-not (Test-GitIgnorePathEffective -GitIgnoreContent $strRecursiveRule `
                    -RepositoryRelativePath $strPrivatePath)) {
                throw "Native Git rejected recursive personal-memory coverage: $strPrivatePath"
            }
        }
        foreach ($strPublicPath in @('CLAUDE.md', 'nested/CLAUDE.md', 'tools/project/CLAUDE.md')) {
            if (Test-GitIgnorePathEffective -GitIgnoreContent $strRecursiveRule `
                    -RepositoryRelativePath $strPublicPath) {
                throw "Native Git hid public instructions: $strPublicPath"
            }
        }
    }

    $strLegacyMetadataContent = "# Procedure`n`nInvalid prior metadata.`n"
    $strInitialGovernedContent = "# Procedure`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Maintainers`n- **Last Updated:** $MaximumMetadataUtcDate`n- **Scope:** Operational procedure.`n"
    foreach ($objPromotionFixture in @(
            [pscustomobject]@{ Name = 'trusted exempt promotion'; Path = 'README.md'; Exempt = @('README.md'); Current = $strInitialGovernedContent; Allowed = $true; Fails = $false },
            [pscustomobject]@{ Name = 'stale promoted document'; Path = 'README.md'; Exempt = @('README.md'); Current = $strInitialGovernedContent.Replace($MaximumMetadataUtcDate, '2020-01-01'); Allowed = $true; Fails = $true },
            [pscustomobject]@{ Name = 'invalid promoted header'; Path = 'README.md'; Exempt = @('README.md'); Current = $strLegacyMetadataContent; Allowed = $true; Fails = $true },
            [pscustomobject]@{ Name = 'nonexempt invalid parent'; Path = 'docs/RUNBOOK.md'; Exempt = @('README.md'); Current = $strInitialGovernedContent; Allowed = $false; Fails = $true },
            [pscustomobject]@{ Name = 'candidate-only exemption cannot supply proof'; Path = 'docs/RUNBOOK.md'; Exempt = @(); Current = $strInitialGovernedContent; Allowed = $false; Fails = $true },
            [pscustomobject]@{ Name = 'known governed path wins'; Path = 'AGENTS.md'; Exempt = @('AGENTS.md'); Current = $strInitialGovernedContent; Allowed = $false; Fails = $true },
            [pscustomobject]@{ Name = 'ADR remains previously governed'; Path = 'docs/decisions/0001-safety.md'; Exempt = @('docs/decisions/0001-safety.md'); Current = $strInitialGovernedContent; Allowed = $false; Fails = $true }
        )) {
        $boolPromotedCoverage = Test-InitialMetadataCoveragePath `
            -HasTrustedBaselineManifest $true `
            -TrustedBaselineExemptPath $objPromotionFixture.Exempt `
            -RepositoryRelativePath $objPromotionFixture.Path
        $objPromotionBaseContent = $strLegacyMetadataContent
        if ($boolPromotedCoverage) { $objPromotionBaseContent = $null }
        $arrPromotionFailures = @(Get-PublishedEndpointLastUpdatedFailure `
                -Name $objPromotionFixture.Path -CurrentContent $objPromotionFixture.Current `
                -BaseContent $objPromotionBaseContent -TrustedEventUtcDate '' `
                -RequireCurrentMaximumDateForRenderedChange $boolPromotedCoverage)
        if ($boolPromotedCoverage -ne $objPromotionFixture.Allowed -or
            ($arrPromotionFailures.Count -gt 0) -ne $objPromotionFixture.Fails) {
            throw "Trusted exemption promotion fixture failed: $($objPromotionFixture.Name)"
        }
    }

    # Candidate classification/catalog choices are not inputs to proved prior coverage.
    foreach ($strPriorGovernedFixturePath in @('AGENTS.md', 'docs/decisions/0001-safety.md', '.github/workflows/scripts-README.md')) {
        if (Test-InitialMetadataCoveragePath -HasTrustedBaselineManifest $false `
                -RepositoryRelativePath $strPriorGovernedFixturePath) {
            throw 'Candidate reclassification escaped proved prior governed coverage.'
        }
    }
    if (Test-InitialMetadataCoveragePath -HasTrustedBaselineManifest $false `
            -RepositoryRelativePath 'docs/RUNBOOK.md') {
        throw 'A missing baseline manifest waived invalid parent metadata.'
    }

}

function Assert-PublishedMetadataGitFixture {
    # .SYNOPSIS
    # Tests final-state metadata on a real three-commit scratch branch.
    #
    # .DESCRIPTION
    # Reads baseline, invalid intermediate and valid final bytes from Git.
    # Proves the published endpoint comparison does not walk topic transitions.
    #
    # .PARAMETER MaximumMetadataUtcDate
    # The trusted UTC date used for the final fixture metadata.
    #
    # .EXAMPLE
    # Assert-PublishedMetadataGitFixture -MaximumMetadataUtcDate '2026-10-02'
    #
    # # Throws when invalid intermediate metadata poisons a valid final state.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. The function throws if a fixture fails.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $MaximumMetadataUtcDate)

    $strTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = [IO.Path]::GetFullPath([IO.Path]::Combine(
            $strTempRoot, 'agent-metadata-endpoints-' + [Guid]::NewGuid().ToString('N')))
    if (-not $strFixtureRoot.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -or
        $strFixtureRoot -ceq $strTempRoot) {
        throw 'The published metadata fixture root is unsafe.'
    }
    $strEmptyHooks = [IO.Path]::Combine($strFixtureRoot, 'empty-hooks')
    [void][IO.Directory]::CreateDirectory($strEmptyHooks)
    $strFixtureFile = [IO.Path]::Combine($strFixtureRoot, 'fixture.md')
    $strPromotionFile = [IO.Path]::Combine($strFixtureRoot, 'README.md')
    $strManifestDirectory = [IO.Path]::Combine($strFixtureRoot, '.github')
    [void][IO.Directory]::CreateDirectory($strManifestDirectory)
    $strManifestFile = [IO.Path]::Combine($strManifestDirectory, 'document-metadata-classification.json')
    $strExemptManifest = '{"schemaVersion":2,"authorizedExemptionPaths":[],"tier2Paths":["README.md"],"generatedPaths":[]}'
    $strGovernedManifest = '{"schemaVersion":2,"authorizedExemptionPaths":[],"tier2Paths":[],"generatedPaths":[]}'
    $strExemptReadme = "# Onboarding`n`nConsumer setup.`n"
    $strPromotedReadme = "# Procedure`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Fixture Maintainers`n- **Last Updated:** $MaximumMetadataUtcDate`n- **Scope:** Governed procedure.`n"

    $strPriorDate = [DateTime]::ParseExact($MaximumMetadataUtcDate, 'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture).AddDays(-1).ToString(
        'yyyy-MM-dd', [Globalization.CultureInfo]::InvariantCulture)
    $strBaselineContent = "# Fixture`n`n**Version:** 1.0.$($strPriorDate.Replace('-', '')).0`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Fixture Maintainers`n- **Last Updated:** $strPriorDate`n- **Scope:** Published endpoint regression.`n`n## Content`n`nPublished baseline.`n"
    $strIntermediateContent = $strBaselineContent.Replace('Published baseline.', 'Intermediate change without metadata advancement.')
    $strFinalContent = $strBaselineContent.Replace($strPriorDate, $MaximumMetadataUtcDate).
        Replace($strPriorDate.Replace('-', ''), $MaximumMetadataUtcDate.Replace('-', '')).
        Replace('Published baseline.', 'Corrected final state.')
    $listRevisions = [Collections.Generic.List[string]]::new()
    try {
        & git -c "init.templateDir=$strEmptyHooks" -C $strFixtureRoot init --quiet --initial-branch=topic
        if ($LASTEXITCODE -ne 0) { throw 'Could not initialize the metadata branch fixture.' }
        foreach ($strContent in @($strBaselineContent, $strIntermediateContent, $strFinalContent)) {
            [IO.File]::WriteAllText($strFixtureFile, $strContent, [Text.UTF8Encoding]::new($false))
            [IO.File]::WriteAllText($strPromotionFile,
                $(if ($listRevisions.Count -eq 0) { $strExemptReadme } else { $strPromotedReadme }),
                [Text.UTF8Encoding]::new($false))
            [IO.File]::WriteAllText($strManifestFile,
                $(if ($listRevisions.Count -eq 0) { $strExemptManifest } else { $strGovernedManifest }),
                [Text.UTF8Encoding]::new($false))
            & git -c core.autocrlf=false -C $strFixtureRoot add -- fixture.md README.md .github/document-metadata-classification.json
            if ($LASTEXITCODE -ne 0) { throw 'Could not index the metadata branch fixture.' }
            & git -C $strFixtureRoot -c user.name=MetadataFixture `
                -c user.email=metadata-fixture@example.invalid -c commit.gpgsign=false `
                -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=fixture
            if ($LASTEXITCODE -ne 0) { throw 'Could not commit the metadata branch fixture.' }
            $strRevision = [string](& git -C $strFixtureRoot rev-parse --verify 'HEAD^{commit}')
            if ($LASTEXITCODE -ne 0 -or $strRevision.Trim() -cnotmatch '^[0-9a-f]{40}$') {
                throw 'Could not read the metadata fixture commit identity.'
            }
            $listRevisions.Add($strRevision.Trim())
        }
        if (@($listRevisions | Select-Object -Unique).Count -ne 3) {
            throw 'The metadata branch fixture did not create three distinct commits.'
        }
        $arrCommittedContent = @(foreach ($strRevision in $listRevisions) {
                Read-GitRevisionText -RepositoryRootPath $strFixtureRoot `
                    -Revision $strRevision -RepositoryRelativePath 'fixture.md' `
                    -MaximumBytes 4096 -RequireRegularFile
            })
        $arrIntermediateFailures = @(Get-PublishedEndpointMetadataFailure `
                -Name 'fixture.md' -CurrentContent $arrCommittedContent[1] `
                -ParentContent $arrCommittedContent[0] -ExpectedUtcDate $MaximumMetadataUtcDate `
                -IsNewDocumentTransition $false)
        $arrFinalFailures = @(Get-PublishedEndpointMetadataFailure `
                -Name 'fixture.md' -CurrentContent $arrCommittedContent[2] `
                -ParentContent $arrCommittedContent[0] -ExpectedUtcDate $MaximumMetadataUtcDate `
                -IsNewDocumentTransition $false)
        $arrChangedPaths = @(Read-GitPublishedEndpointChangedPath `
                -RepositoryRootPath $strFixtureRoot -BaselineRevision $listRevisions[0] `
                -FinalRevision $listRevisions[2] -MaximumBytes 4096)
        if ($arrIntermediateFailures.Count -eq 0 -or $arrFinalFailures.Count -ne 0 -or
            $arrChangedPaths.Count -ne 3 -or
            $arrChangedPaths -cnotcontains '.github/document-metadata-classification.json' -or
            $arrChangedPaths -cnotcontains 'README.md' -or $arrChangedPaths -cnotcontains 'fixture.md') {
            throw ("A real multi-commit endpoint regressed. Intermediate: $($arrIntermediateFailures -join '; '); " +
                "final: $($arrFinalFailures -join '; '); paths: $($arrChangedPaths -join '; ').")
        }
        $arrFixtureBaselinePaths = @(Read-GitTrackedPath -RepositoryRootPath $strFixtureRoot `
                -Revision $listRevisions[0] -MaximumBytes 4096)
        $arrFixtureFinalPaths = @(Read-GitTrackedPath -RepositoryRootPath $strFixtureRoot `
                -Revision $listRevisions[2] -MaximumBytes 4096)
        $objFixtureBaselineClassification = Get-DocumentMetadataClassificationContext `
            -Content (Read-GitRevisionText -RepositoryRootPath $strFixtureRoot `
                -Revision $listRevisions[0] -RepositoryRelativePath '.github/document-metadata-classification.json' `
                -MaximumBytes 4096 -RequireRegularFile) -TrackedPath $arrFixtureBaselinePaths
        $objFixtureFinalClassification = Get-DocumentMetadataClassificationContext `
            -Content (Read-GitRevisionText -RepositoryRootPath $strFixtureRoot `
                -Revision $listRevisions[2] -RepositoryRelativePath '.github/document-metadata-classification.json' `
                -MaximumBytes 4096 -RequireRegularFile) -TrackedPath $arrFixtureFinalPaths
        if ($null -ne $objFixtureBaselineClassification.Failure -or
            $null -ne $objFixtureFinalClassification.Failure) {
            throw 'The real promotion classification fixture is invalid.'
        }
        $boolFixturePromotion = Test-InitialMetadataCoveragePath `
            -HasTrustedBaselineManifest $true `
            -TrustedBaselineExemptPath $objFixtureBaselineClassification.ExemptPaths `
            -RepositoryRelativePath 'README.md'
        $strCommittedPromotedReadme = Read-GitRevisionText -RepositoryRootPath $strFixtureRoot `
            -Revision $listRevisions[2] -RepositoryRelativePath 'README.md' `
            -MaximumBytes 4096 -RequireRegularFile
        $arrDiscoveredPromotionPaths = @(Get-DiscoveredGovernedMarkdownDocumentPath `
                -CandidatePath $arrFixtureFinalPaths -KnownGovernedPath @('fixture.md') `
                -ExemptPath $objFixtureFinalClassification.ExemptPaths)
        if (-not $boolFixturePromotion -or
            $arrDiscoveredPromotionPaths -cnotcontains 'README.md' -or
            @(Get-PublishedEndpointLastUpdatedFailure -Name 'README.md' `
                -CurrentContent $strCommittedPromotedReadme -BaseContent $null `
                -TrustedEventUtcDate '' -RequireCurrentMaximumDateForRenderedChange $true).Count -ne 0) {
            throw 'Trusted Git-object exemption removal did not become valid governed coverage.'
        }

    } finally {
        if ([IO.Directory]::Exists($strFixtureRoot) -and
            $strFixtureRoot.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -and
            $strFixtureRoot -cne $strTempRoot) {
            Remove-Item -LiteralPath $strFixtureRoot -Recurse -Force
        }
    }
}

function Assert-ClassificationAdmissionGitFixture {
    # .SYNOPSIS
    # Tests exact accepted-base classification admission without parser dependencies.
    #
    # .DESCRIPTION
    # Runs the installed fixture validator at B against inert H data and rejects
    # mixed policy/data bypasses. Candidate executable bytes must never execute.
    # Also checks the real workflow call and mutations of its branch placement.
    #
    # .PARAMETER RepositoryRootPath
    # The repository supplying the proposed validator and workflow fixture bytes.
    #
    # .EXAMPLE
    # Assert-ClassificationAdmissionGitFixture -RepositoryRootPath $strRoot
    #
    # # Throws if trusted admission or unconditional workflow placement fails.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. The function throws when a fixture fails.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261003.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $RepositoryRootPath)

    $strTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = [IO.Path]::Combine($strTempRoot,
        'agent-classification-admission-' + [Guid]::NewGuid().ToString('N'))
    $strWorkflowDirectory = [IO.Path]::Combine($strFixtureRoot, '.github', 'workflows')
    [void][IO.Directory]::CreateDirectory($strWorkflowDirectory)
    $strEmptyHooks = [IO.Path]::Combine($strFixtureRoot, 'empty-hooks')
    [void][IO.Directory]::CreateDirectory($strEmptyHooks)
    $strValidatorPath = [IO.Path]::Combine($strWorkflowDirectory, 'Test-AgentInstructions.ps1')
    $strManifestPath = [IO.Path]::Combine($strFixtureRoot, '.github', 'document-metadata-classification.json')
    $strValidatorContent = [IO.File]::ReadAllText([IO.Path]::Combine(
            $RepositoryRootPath, '.github', 'workflows', 'Test-AgentInstructions.ps1'))
    $strHostPath = (Get-Process -Id $PID).Path
    $strPlainManifest = '{"schemaVersion":2,"authorizedExemptionPaths":[],"tier2Paths":["README.md"],"generatedPaths":[]}'
    $strAuthorizedManifest = $strPlainManifest.Replace('"authorizedExemptionPaths":[]',
        '"authorizedExemptionPaths":["docs/RUNBOOK.md"]')
    $strActivatedManifest = $strPlainManifest.Replace('["README.md"]', '["README.md","docs/RUNBOOK.md"]')
    $scriptblockCommit = {
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Admission fixture indexing failed.' }
        & git -C $strFixtureRoot -c user.name=AdmissionFixture `
            -c user.email=admission-fixture@example.invalid -c commit.gpgsign=false `
            -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=fixture
        if ($LASTEXITCODE -ne 0) { throw 'Admission fixture commit failed.' }
        ([string](& git -C $strFixtureRoot rev-parse --verify 'HEAD^{commit}')).Trim()
    }
    $scriptblockCheck = {
        param([string] $Baseline, [string] $Candidate, [bool] $Accept, [string] $Expected)
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $Baseline
        if ($LASTEXITCODE -ne 0) { throw 'Admission baseline checkout failed.' }
        $strOutput = (& $strHostPath -NoProfile -File $strValidatorPath `
                -MetadataClassificationOnly -InputRevision $Candidate `
                -PublishedBaselineRevision $Baseline 2>&1 | Out-String)
        $intExitCode = $LASTEXITCODE
        if (($intExitCode -eq 0) -ne $Accept -or $strOutput -notmatch $Expected) {
            throw "Classification CLI fixture failed ($Accept, exit $intExitCode): $strOutput"
        }
    }
    try {
        & git -C $strFixtureRoot -c "init.templateDir=$strEmptyHooks" init --quiet --initial-branch=fixture
        if ($LASTEXITCODE -ne 0) { throw 'Admission fixture initialization failed.' }
        [IO.File]::WriteAllText($strValidatorPath, $strValidatorContent, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strManifestPath, $strPlainManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'README.md'), '# Onboarding', [Text.UTF8Encoding]::new($false))
        [void][IO.Directory]::CreateDirectory([IO.Path]::Combine($strFixtureRoot, 'docs'))
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'docs', 'RUNBOOK.md'), '# Procedure', [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        # This accepted fixture installs the proposed checker; it is not native first-install authority.
        & $scriptblockCheck $strBaseline $strBaseline $true 'Metadata classification data validated'
        $strGeneratedManifest = '{"schemaVersion":2,"authorizedExemptionPaths":[],"tier2Paths":[],"generatedPaths":["README.md"]}'
        [IO.File]::WriteAllText($strManifestPath, $strGeneratedManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'README.md'),
            "# Reader`n`n- **Status:** Broken`n- **Last Updated:** 2099-99-99`n", [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strValidatorPath, "throw 'CANDIDATE_EXECUTED'", [Text.UTF8Encoding]::new($false))
        $strReclassifiedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strReclassifiedCandidate $false '(?s)unauthenticated generated status:.*README[.]md'
        # The existing published path-authorization route still permits activation.
        $strReadmeAuthorization = '{"schemaVersion":2,"authorizedExemptionPaths":["README.md"],"tier2Paths":[],"generatedPaths":[]}'
        [IO.File]::WriteAllText($strManifestPath, $strReadmeAuthorization, [Text.UTF8Encoding]::new($false))
        $strReadmeAuthorizedBaseline = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strReadmeAuthorizedBaseline $true 'Metadata classification data validated'
        & git -C $strFixtureRoot checkout --quiet --detach $strReadmeAuthorizedBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Generated authorization baseline checkout failed.' }
        [IO.File]::WriteAllText($strManifestPath, $strGeneratedManifest, [Text.UTF8Encoding]::new($false))
        $strGeneratedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strReadmeAuthorizedBaseline $strGeneratedCandidate $true 'Metadata classification data validated'
        & $scriptblockCheck $strGeneratedCandidate $strGeneratedCandidate $true 'Metadata classification data validated'
        # Existing generated provenance cannot authorize a nonregular Git entry.
        # Keep these candidate objects out of the regular baseline checkout.
        foreach ($strMode in @('100755', '120000', '160000')) {
            & git -C $strFixtureRoot checkout --quiet --detach $strGeneratedCandidate
            if ($LASTEXITCODE -ne 0) { throw 'Generated type baseline checkout failed.' }
            $strObject = if ($strMode -ceq '160000') { $strGeneratedCandidate } else {
                ([string](& git -C $strFixtureRoot rev-parse 'HEAD:README.md')).Trim()
            }
            & git -C $strFixtureRoot update-index --cacheinfo "$strMode,$strObject,README.md"
            if ($LASTEXITCODE -ne 0) { throw 'Generated type fixture indexing failed.' }
            $strModeTree = & git -C $strFixtureRoot write-tree
            if ($LASTEXITCODE -ne 0 -or $strModeTree -cnotmatch '^[0-9a-f]{40}$') {
                throw 'Generated type fixture tree failed.'
            }
            $strModeCandidate = & git -C $strFixtureRoot -c user.name=AdmissionFixture `
                -c user.email=admission-fixture@example.invalid -c commit.gpgsign=false `
                commit-tree $strModeTree -p $strGeneratedCandidate -m mode
            if ($LASTEXITCODE -ne 0 -or $strModeCandidate -cnotmatch '^[0-9a-f]{40}$') {
                throw 'Generated type fixture commit failed.'
            }
            $strCandidateTree = & git -C $strFixtureRoot rev-parse "$strModeCandidate^{tree}"
            if ($LASTEXITCODE -ne 0 -or $strCandidateTree -cne $strModeTree) {
                throw 'Generated type fixture tree identity changed.'
            }
            $strCandidateParent = & git -C $strFixtureRoot rev-parse "$strModeCandidate^"
            if ($LASTEXITCODE -ne 0 -or $strCandidateParent -cne $strGeneratedCandidate) {
                throw 'Generated type fixture parent changed.'
            }
            $strObjectType = if ($strMode -ceq '160000') { 'commit' } else { 'blob' }
            $strCandidateEntry = & git -C $strFixtureRoot ls-tree $strModeCandidate -- README.md
            if ($LASTEXITCODE -ne 0 -or
                $strCandidateEntry -cne "$strMode $strObjectType $strObject`tREADME.md") {
                throw 'Generated type fixture entry changed.'
            }
            & git -C $strFixtureRoot read-tree $strGeneratedCandidate
            if ($LASTEXITCODE -ne 0) { throw 'Generated type fixture index restoration failed.' }
            $strRestoredHead = & git -C $strFixtureRoot rev-parse HEAD
            if ($LASTEXITCODE -ne 0 -or $strRestoredHead -cne $strGeneratedCandidate) {
                throw 'Generated type fixture changed the baseline checkout.'
            }
            $arrRestoredStatus = @(& git -C $strFixtureRoot status --porcelain --untracked-files=no)
            if ($LASTEXITCODE -ne 0 -or $arrRestoredStatus.Count -ne 0) {
                throw 'Generated type fixture did not restore a clean baseline index and worktree.'
            }
            & $scriptblockCheck $strGeneratedCandidate $strModeCandidate $false 'not one regular 100644 blob'
            & $scriptblockCheck $strReadmeAuthorizedBaseline $strModeCandidate $false 'not one regular 100644 blob'
        }
        & git -C $strFixtureRoot checkout --quiet --detach $strGeneratedCandidate
        if ($LASTEXITCODE -ne 0) { throw 'Generated type fixture restoration failed.' }

        [IO.File]::WriteAllText($strManifestPath, $strPlainManifest, [Text.UTF8Encoding]::new($false))
        $strTier2Candidate = & $scriptblockCommit
        & $scriptblockCheck $strGeneratedCandidate $strTier2Candidate $true 'Metadata classification data validated'
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Category fixture baseline restoration failed.' }
        [IO.File]::WriteAllText($strManifestPath, $strActivatedManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strValidatorPath,
            "throw 'CANDIDATE_EXECUTED'", [Text.UTF8Encoding]::new($false))
        $strMixedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strMixedCandidate $false 'docs/RUNBOOK.md'
        [IO.File]::WriteAllText($strManifestPath,
            $strActivatedManifest.Replace('"authorizedExemptionPaths":[]',
                '"authorizedExemptionPaths":["docs/RUNBOOK.md"]'), [Text.UTF8Encoding]::new($false))
        $strCombinedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strCombinedCandidate $false 'docs/RUNBOOK.md'
        [IO.File]::WriteAllText($strManifestPath, $strAuthorizedManifest, [Text.UTF8Encoding]::new($false))
        $strAuthorizationCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strAuthorizationCandidate $true 'Metadata classification data validated'
        & git -C $strFixtureRoot checkout --quiet --detach $strAuthorizationCandidate
        if ($LASTEXITCODE -ne 0) { throw 'Authorization baseline checkout failed.' }
        $strAuthorizedBaseline = $strAuthorizationCandidate
        [IO.File]::WriteAllText($strManifestPath, $strActivatedManifest, [Text.UTF8Encoding]::new($false))
        $strActivatedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strAuthorizedBaseline $strActivatedCandidate $true 'Metadata classification data validated'
        [IO.File]::WriteAllText($strManifestPath, '{"schemaVersion":1}', [Text.UTF8Encoding]::new($false))
        $strMalformedCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strMalformedCandidate $false 'classification manifest'
        [IO.File]::WriteAllText($strManifestPath, (' ' * 32769), [Text.UTF8Encoding]::new($false))
        $strOversizeCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strOversizeCandidate $false 'byte|bytes'
        Remove-Item -LiteralPath $strManifestPath -Force
        $strMissingManifestCandidate = & $scriptblockCommit
        & $scriptblockCheck $strBaseline $strMissingManifestCandidate $false 'document-metadata-classification.json'
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        foreach ($arrInvalidArguments in @(
                @('-MetadataClassificationOnly'),
                @('-MetadataClassificationOnly', '-SelfTest', '-InputRevision', $strBaseline, '-PublishedBaselineRevision', $strBaseline),
                @('-MetadataClassificationOnly', '-InputRevision', 'abc', '-PublishedBaselineRevision', $strBaseline))) {
            $null = & $strHostPath -NoProfile -File $strValidatorPath @arrInvalidArguments 2>&1
            if ($LASTEXITCODE -eq 0) { throw 'An invalid classification mode combination was accepted.' }
        }
        & git -C $strFixtureRoot checkout --quiet --detach $strAuthorizedBaseline
        $null = & $strHostPath -NoProfile -File $strValidatorPath -MetadataClassificationOnly `
            -InputRevision $strActivatedCandidate -PublishedBaselineRevision $strBaseline 2>&1
        if ($LASTEXITCODE -eq 0) { throw 'Classification mode accepted checkout different from B.' }
    } finally {
        $strResolvedFixtureRoot = [IO.Path]::GetFullPath($strFixtureRoot)
        if ($strResolvedFixtureRoot.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -and
            $strResolvedFixtureRoot -cne $strTempRoot -and [IO.Directory]::Exists($strResolvedFixtureRoot)) {
            Remove-Item -LiteralPath $strResolvedFixtureRoot -Recurse -Force
        }
    }

    $strWorkflow = [IO.File]::ReadAllText([IO.Path]::Combine(
            $RepositoryRootPath, '.github', 'workflows', 'agent-instructions.yml'))
    $objRunMatch = [regex]::Match($strWorkflow,
        '(?ms)^      - name: Classify exact PR input and validate ordinary content\r?\n.*?^        run: \|\r?\n(?<run>(?:          [^\r\n]*\r?\n)+)')
    if (-not $objRunMatch.Success) { throw 'The accepted-policy validation run block is unavailable.' }
    $strRun = [regex]::Replace($objRunMatch.Groups['run'].Value, '(?m)^          ', '')
    $scriptblockCallProof = {
        param([string] $Run)
        $arrTokens = $null
        $arrErrors = $null
        $objAst = [Management.Automation.Language.Parser]::ParseInput($Run, [ref]$arrTokens, [ref]$arrErrors)
        if ($arrErrors.Count -ne 0) { return $false }
        $arrCalls = @($objAst.FindAll({ param($Node)
                    $Node -is [Management.Automation.Language.CommandAst] -and
                    $Node.CommandElements.Extent.Text -contains '-MetadataClassificationOnly' }, $true))
        if ($arrCalls.Count -ne 1) { return $false }
        $objCall = $arrCalls[0]
        if ($objCall.Extent.Text -notmatch '-InputRevision \$env:EXPECTED_HEAD -PublishedBaselineRevision \$env:EXPECTED_BASE') { return $false }
        $objParent = $objCall.Parent
        while ($null -ne $objParent) {
            if ($objParent -is [Management.Automation.Language.IfStatementAst]) { return $false }
            $objParent = $objParent.Parent
        }
        $intClassify = $Run.IndexOf('$strResult = & node .github/workflows/Classify-InstructionMaintenance.mjs', [StringComparison]::Ordinal)
        if ($intClassify -lt $objCall.Extent.EndOffset) { return $false }
        $strFollowing = $Run.Substring($objCall.Extent.EndOffset)
        return $strFollowing -match '^\r?\nif \(\$LASTEXITCODE -ne 0\) \{ throw ''Accepted metadata classification rejected PR data\.''' -and
            $Run -match '\$ErrorActionPreference = ''Stop'''
    }
    if (-not (& $scriptblockCallProof $strRun)) { throw 'The real workflow lacks unconditional fatal accepted-base data admission.' }
    $strCall = '& ./.github/workflows/Test-AgentInstructions.ps1 -MetadataClassificationOnly -InputRevision $env:EXPECTED_HEAD -PublishedBaselineRevision $env:EXPECTED_BASE'
    foreach ($strMutation in @(
            $strRun.Replace($strCall, '# removed admission'),
            $strRun.Replace($strCall, "if (`$objResult.classification -ceq 'ordinary') { $strCall }"),
            $strRun.Replace("throw 'Accepted metadata classification rejected PR data.'", "Write-Output 'ignored classification failure'"))) {
        if (& $scriptblockCallProof $strMutation) { throw 'An unsafe workflow admission mutation passed.' }
    }
}

function Invoke-AgentInstructionFixtureClock {
    # .SYNOPSIS
    # Runs a private fixture action with checked debugger clock controls.
    #
    # .DESCRIPTION
    # Pins the exact validator's two UTC date consumers without changing its
    # bytes or production interface. Breakpoints exist only for this action.
    #
    # .PARAMETER CheckerPath
    # The absolute path of the actual validator supplying both clock anchors.
    #
    # .PARAMETER UtcNow
    # The private fixture timestamp shared by related synthetic documents.
    #
    # .PARAMETER Action
    # The actual validator invocation or in-process local-context call.
    #
    # .PARAMETER LocalOnly
    # Controls only an already-loaded local-context function.
    #
    # .PARAMETER RequireLocal
    # Requires the local-context breakpoint to fire during the action.
    #
    # .EXAMPLE
    # Invoke-AgentInstructionFixtureClock -CheckerPath $strChecker -UtcNow $objNow -Action { & $strChecker }
    #
    # # Runs the exact checker with the private fixture date.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # System.Object. The unchanged output of the fixture action.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([object])]
    param(
        [Parameter(Mandatory)][string] $CheckerPath,
        [Parameter(Mandatory)][DateTimeOffset] $UtcNow,
        [Parameter(Mandatory)][scriptblock] $Action,
        [Parameter()][switch] $LocalOnly,
        [Parameter()][switch] $RequireLocal
    )

    $strSource = [IO.File]::ReadAllText($CheckerPath)
    $strBreakpointPath = [Management.Automation.WildcardPattern]::Escape($CheckerPath)
    $strInitialization = @'
$script:objValidationUtcNow = [DateTimeOffset]::UtcNow
$script:strMaximumMetadataUtcDate = $script:objValidationUtcNow.ToString('yyyy-MM-dd')
$script:objMaximumCommitUtcTimestamp = $script:objValidationUtcNow.AddMinutes(5)
'@
    $strLocal = @'
    $strExpectedUtcDate = if ($intDiffExitCode -eq 1) {
        [DateTimeOffset]::UtcNow.ToString('yyyy-MM-dd')
    } else {
        ''
    }
'@
    $arrLines = foreach ($strAnchor in @($strInitialization, $strLocal)) {
        $strPattern = [regex]::Escape($strAnchor.Replace("`r`n", "`n")).Replace('\n', '\r?\n')
        $arrMatches = @([regex]::Matches($strSource, '(?m)^' + $strPattern + '\r?$'))
        if ($arrMatches.Count -ne 1) {
            throw 'Fixture clock requires one exact initialization and local-date anchor.'
        }
        # Break on the first executable statement after the complete assignment.
        1 + [regex]::Matches($strSource.Substring(0, $arrMatches[0].Index + $arrMatches[0].Length), "`n").Count + 1
    }
    $strTimestamp = $UtcNow.ToUniversalTime().ToString('o')
    $strDate = $UtcNow.ToUniversalTime().ToString('yyyy-MM-dd')
    $strStateName = 'hashtableFixtureClock' + [Guid]::NewGuid().ToString('N')
    $hashtableClockState = @{ InitializationReadbacks = 0; LocalReadbacks = 0 }
    $scriptblockInitialize = [scriptblock]::Create(@'
$script:objValidationUtcNow = [DateTimeOffset]::Parse('TIMESTAMP')
$script:strMaximumMetadataUtcDate = 'DATE'
$script:objMaximumCommitUtcTimestamp = [DateTimeOffset]::Parse('TIMESTAMP').AddMinutes(5)
if ($script:strMaximumMetadataUtcDate -cne 'DATE' -or
    $script:objValidationUtcNow -ne [DateTimeOffset]::Parse('TIMESTAMP') -or
    $script:objMaximumCommitUtcTimestamp -ne [DateTimeOffset]::Parse('TIMESTAMP').AddMinutes(5)) {
    throw 'Fixture initialization clock readback failed.'
}
$global:STATE.InitializationReadbacks++
'@.Replace('TIMESTAMP', $strTimestamp).Replace('DATE', $strDate).Replace('STATE', $strStateName))
    $scriptblockLocal = [scriptblock]::Create(@'
$strFixtureExpectedDate = if ((Get-Variable -Name intDiffExitCode -Scope 1 -ValueOnly) -eq 1) { 'DATE' } else { '' }
Set-Variable -Name strExpectedUtcDate -Scope 1 -Value $strFixtureExpectedDate
if ((Get-Variable -Name strExpectedUtcDate -Scope 1 -ValueOnly) -cne $strFixtureExpectedDate) {
    throw 'Fixture local clock readback failed.'
}
$global:STATE.LocalReadbacks++
'@.Replace('DATE', $strDate).Replace('STATE', $strStateName))
    $objInitializationBreakpoint = $null
    $objLocalBreakpoint = $null
    $objPrimaryFailure = $null
    $listClockFailures = [Collections.Generic.List[string]]::new()
    # Debugger action exceptions do not reliably escape the debugger. A unique
    # runspace-local receipt records completed readbacks, checked outside it.
    Set-Variable -Name $strStateName -Scope Global -Value $hashtableClockState
    try {
        if (-not $LocalOnly) {
            $objInitializationBreakpoint = Set-PSBreakpoint -Script $strBreakpointPath -Line $arrLines[0] -Action $scriptblockInitialize
        }
        $objLocalBreakpoint = Set-PSBreakpoint -Script $strBreakpointPath -Line $arrLines[1] -Action $scriptblockLocal
        & $Action
    } catch {
        $objPrimaryFailure = $_
    } finally {
        foreach ($objBreakpoint in @($objInitializationBreakpoint, $objLocalBreakpoint)) {
            if ($null -ne $objBreakpoint) {
                try { Remove-PSBreakpoint -Breakpoint $objBreakpoint -ErrorAction Stop } catch { $listClockFailures.Add($_.Exception.Message) }
            }
        }
        try { Remove-Variable -Name $strStateName -Scope Global -ErrorAction Stop } catch { $listClockFailures.Add($_.Exception.Message) }
        if (-not $LocalOnly -and ($null -eq $objInitializationBreakpoint -or
                ($objInitializationBreakpoint.HitCount -eq 0 -and $null -eq $objPrimaryFailure) -or
                $hashtableClockState.InitializationReadbacks -ne $objInitializationBreakpoint.HitCount)) {
            $listClockFailures.Add('Initialization clock did not fire with a successful readback.')
        }
        if (($RequireLocal -and ($null -eq $objLocalBreakpoint -or $objLocalBreakpoint.HitCount -eq 0)) -or
            ($null -ne $objLocalBreakpoint -and $hashtableClockState.LocalReadbacks -ne $objLocalBreakpoint.HitCount)) {
            $listClockFailures.Add('Local clock did not fire with a successful readback.')
        }
    }
    if ($listClockFailures.Count -gt 0) {
        $strFailure = 'Fixture clock control failed: ' + ($listClockFailures -join ' ')
        if ($null -ne $objPrimaryFailure) { $strFailure = $objPrimaryFailure.Exception.Message + "`n" + $strFailure }
        throw $strFailure
    }
    if ($null -ne $objPrimaryFailure) { throw $objPrimaryFailure }
}

function Get-AgentFinalizationDateMutant {
    # .SYNOPSIS
    # Changes the two actual document finalization arguments for private tests.
    #
    # .DESCRIPTION
    # Parses the checker and requires one script-level named argument for each
    # endpoint. Verifies the original member expressions, replaces only their
    # distinct source extents, and rejects unchanged or malformed output.
    # Function-local callers are not the main document dispatch under test.
    #
    # .PARAMETER Content
    # Exact checker source to mutate without changing any file.
    #
    # .PARAMETER Replacement
    # The deliberate private fault expression to insert at both argument spans.
    #
    # .EXAMPLE
    # Get-AgentFinalizationDateMutant -Content $strChecker -Replacement '$false'
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # System.String. The checked private mutant source.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - Not a public interface.
    # Version: 1.0.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([string])]
    param(
        [Parameter(Mandatory)][AllowEmptyString()][string] $Content,
        [Parameter(Mandatory)][ValidateNotNullOrEmpty()][string] $Replacement
    )

    $arrTokens = $null
    $arrErrors = $null
    $objAst = [Management.Automation.Language.Parser]::ParseInput($Content, [ref]$arrTokens, [ref]$arrErrors)
    if ($arrErrors.Count -ne 0) { throw 'Finalization mutant source must parse without errors.' }
    $listArguments = [Collections.Generic.List[object]]::new()
    foreach ($objTarget in @(
            @{ Command = 'Get-PublishedEndpointMetadataFailure'; Parameter = 'RequireExpectedUtcDateForRenderedChange' },
            @{ Command = 'Get-PublishedEndpointLastUpdatedFailure'; Parameter = 'RequireCurrentMaximumDateForRenderedChange' })) {
        $listTargetArguments = [Collections.Generic.List[object]]::new()
        foreach ($objCommand in $objAst.FindAll({
                    param($objNode)
                    $objNode -is [Management.Automation.Language.CommandAst]
                }, $true)) {
            if ($objCommand.GetCommandName() -cne $objTarget.Command) { continue }
            $objAncestor = $objCommand.Parent
            while ($null -ne $objAncestor -and
                $objAncestor -isnot [Management.Automation.Language.FunctionDefinitionAst]) {
                $objAncestor = $objAncestor.Parent
            }
            if ($null -ne $objAncestor) { continue }
            for ($intIndex = 1; $intIndex -lt $objCommand.CommandElements.Count; $intIndex++) {
                $objParameter = $objCommand.CommandElements[$intIndex]
                if ($objParameter -isnot [Management.Automation.Language.CommandParameterAst] -or
                    $objParameter.ParameterName -cne $objTarget.Parameter) { continue }
                $objArgument = $objParameter.Argument
                if ($null -eq $objArgument) {
                    if ($intIndex + 1 -ge $objCommand.CommandElements.Count -or
                        $objCommand.CommandElements[$intIndex + 1] -is [Management.Automation.Language.CommandParameterAst]) {
                        throw "Finalization mutant argument is absent: $($objTarget.Parameter)."
                    }
                    $objArgument = $objCommand.CommandElements[$intIndex + 1]
                }
                $objExpression = $objArgument
                while ($objExpression -is [Management.Automation.Language.ParenExpressionAst] -and
                    $objExpression.Pipeline -is [Management.Automation.Language.PipelineAst] -and
                    $objExpression.Pipeline.PipelineElements.Count -eq 1 -and
                    $objExpression.Pipeline.PipelineElements[0] -is [Management.Automation.Language.CommandExpressionAst]) {
                    $objExpression = $objExpression.Pipeline.PipelineElements[0].Expression
                }
                if ($objExpression -isnot [Management.Automation.Language.MemberExpressionAst] -or
                    $objExpression -is [Management.Automation.Language.InvokeMemberExpressionAst] -or
                    $objExpression.Static -or
                    $objExpression.Expression -isnot [Management.Automation.Language.VariableExpressionAst] -or
                    $objExpression.Expression.VariablePath.UserPath -cne 'objDocumentContext' -or
                    $objExpression.Member -isnot [Management.Automation.Language.StringConstantExpressionAst] -or
                    $objExpression.Member.Value -cne 'RequireFinalizationDate') {
                    throw "Finalization mutant argument has an unexpected expression: $($objTarget.Parameter)."
                }
                $listTargetArguments.Add($objArgument)
            }
        }
        if ($listTargetArguments.Count -ne 1) {
            throw "Finalization mutant requires exactly one script-level argument: $($objTarget.Command)/$($objTarget.Parameter)."
        }
        $listArguments.Add($listTargetArguments[0])
    }
    $arrArguments = @($listArguments | Sort-Object { $_.Extent.StartOffset })
    if ($arrArguments.Count -ne 2 -or
        $arrArguments[0].Extent.EndOffset -gt $arrArguments[1].Extent.StartOffset -or
        $arrArguments[0].Extent.StartOffset -eq $arrArguments[1].Extent.StartOffset) {
        throw 'Finalization mutant requires two distinct non-overlapping argument spans.'
    }
    $strMutant = $Content
    foreach ($objArgument in @($arrArguments | Sort-Object { $_.Extent.StartOffset } -Descending)) {
        $strMutant = $strMutant.Remove($objArgument.Extent.StartOffset,
            $objArgument.Extent.EndOffset - $objArgument.Extent.StartOffset).
            Insert($objArgument.Extent.StartOffset, $Replacement)
    }
    if ($strMutant -ceq $Content) { throw 'Finalization mutant construction must change the checker.' }
    $arrTokens = $null
    $arrErrors = $null
    $null = [Management.Automation.Language.Parser]::ParseInput($strMutant, [ref]$arrTokens, [ref]$arrErrors)
    if ($arrErrors.Count -ne 0) { throw 'Finalization mutant output must parse without errors.' }
    return $strMutant
}

function Assert-AgentFinalizationDateMutationSelfTest {
    # .SYNOPSIS
    # Checks exact mutation construction and rejects ineffective target changes.
    #
    # .DESCRIPTION
    # Uses small parsed source fixtures with the actual command and parameter
    # identities. Checks formatting, extra arguments, comments and private
    # function decoys without executing a checker or changing a file.
    #
    # .EXAMPLE
    # Assert-AgentFinalizationDateMutationSelfTest
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. Throws when construction or refusal changes.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - Not a public interface.
    # Version: 1.0.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param()

    $strMember = '$objDocumentContext.RequireFinalizationDate'
    $strVersioned = 'Get-PublishedEndpointMetadataFailure -RequireExpectedUtcDateForRenderedChange ' + $strMember
    $strOptional = 'Get-PublishedEndpointLastUpdatedFailure -RequireCurrentMaximumDateForRenderedChange ' + $strMember
    $strSource = $strVersioned + "`n" + $strOptional
    $strMutant = Get-AgentFinalizationDateMutant -Content $strSource -Replacement '$false'
    if ($strMutant -cne $strSource.Replace($strMember, '$false')) {
        throw 'The date mutation did not change exactly its two source arguments.'
    }
    $strExtra = '-CurrentParseReuse $objSlot -ParentParseReuse $objPrior'
    $strComment = '# ' + $strMember
    $strDecoy = 'function Test-PrivateDecoy { ' + $strVersioned + ' }'
    $strFormatted = $strComment + "`n" + $strDecoy + "`n" +
        $strVersioned.Replace(' ' + $strMember, ':(' + $strMember + ')') + " `n" +
        $strOptional.Replace(' -Require', " $strExtra -Require") + ' ' + $strExtra
    $strExpected = $strFormatted.Replace(':(' + $strMember + ')', ':$false').
        Replace('-RequireCurrentMaximumDateForRenderedChange ' + $strMember,
            '-RequireCurrentMaximumDateForRenderedChange $false')
    if ((Get-AgentFinalizationDateMutant -Content $strFormatted -Replacement '$false') -cne $strExpected) {
        throw 'Formatting or extra arguments changed mutation scope or a private decoy.'
    }
    foreach ($objCase in @(
            @{ Content = $strVersioned; Replacement = '$false'; Expected = 'exactly one'; Name = 'missing target' },
            @{ Content = $strSource + "`n" + $strVersioned; Replacement = '$false'; Expected = 'exactly one'; Name = 'duplicate command' },
            @{ Content = $strSource.Replace($strVersioned, $strVersioned + ' -RequireExpectedUtcDateForRenderedChange ' + $strMember); Replacement = '$false'; Expected = 'exactly one'; Name = 'duplicate parameter' },
            @{ Content = $strSource.Replace(' -RequireExpectedUtcDateForRenderedChange ' + $strMember, ' -RequireExpectedUtcDateForRenderedChange'); Replacement = '$false'; Expected = 'argument is absent'; Name = 'absent argument' },
            @{ Content = $strSource.Replace($strMember, '$objOther.RequireFinalizationDate'); Replacement = '$false'; Expected = 'unexpected expression'; Name = 'incorrect owner' },
            @{ Content = $strSource.Replace($strMember, $strMember + '()'); Replacement = '$false'; Expected = 'unexpected expression'; Name = 'method invocation' },
            @{ Content = $strSource.Replace(' ' + $strMember, ' $false'); Replacement = '$false'; Expected = 'unexpected expression'; Name = 'already changed' },
            @{ Content = $strSource; Replacement = $strMember; Expected = 'must change'; Name = 'no-op' },
            @{ Content = $strSource + '('; Replacement = '$false'; Expected = 'source must parse'; Name = 'invalid source' },
            @{ Content = $strSource; Replacement = '('; Expected = 'output must parse'; Name = 'invalid replacement' })) {
        $objFailure = $null
        try { $null = Get-AgentFinalizationDateMutant -Content $objCase.Content -Replacement $objCase.Replacement } catch {
            $objFailure = $_
        }
        if ($null -eq $objFailure -or $objFailure.Exception.Message -notmatch $objCase.Expected) {
            throw "Finalization mutation refusal failed: $($objCase.Name)."
        }
    }
}

function Assert-AuthorFinalizationGitFixture {
    # .SYNOPSIS
    # Tests the deliberate finalization caller and unchanged delayed verification.
    #
    # .DESCRIPTION
    # Installs proposed checker code in a scratch accepted B, reads candidate H
    # as Git data, and exercises new, promoted and versioned document consumers.
    # A debugger clock shim changes only the test clock, never repository bytes.
    #
    # .PARAMETER RepositoryRootPath
    # The repository supplying proposed code and locked Markdown dependencies.
    #
    # .EXAMPLE
    # Assert-AuthorFinalizationGitFixture -RepositoryRootPath $strRoot
    #
    # # Throws on incorrect finalization, delayed-check or mutation behavior.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. The function throws if a production caller fixture fails.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $RepositoryRootPath)

    $strValidatorContent = [IO.File]::ReadAllText([IO.Path]::Combine(
            $RepositoryRootPath, '.github', 'workflows', 'Test-AgentInstructions.ps1'))
    Assert-AgentFinalizationDateMutationSelfTest
    $strRequireDateMutant = Get-AgentFinalizationDateMutant -Content $strValidatorContent -Replacement '$false'
    $strInitialCoverageMutant = Get-AgentFinalizationDateMutant -Content $strValidatorContent -Replacement '($objDocumentContext.RequireFinalizationDate -or $objDocumentContext.IsInitialMetadataCoverage)'

    $strTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = [IO.Path]::Combine($strTempRoot,
        'agent-author-finalization-' + [Guid]::NewGuid().ToString('N'))
    $strEmptyHooks = [IO.Path]::Combine($strTempRoot,
        'agent-finalization-hooks-' + [Guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($strEmptyHooks)
    $strHostPath = (Get-Process -Id $PID).Path
    $objFixtureNodeCommand = Get-Command -Name 'node' -CommandType Application -ErrorAction SilentlyContinue |
        Select-Object -First 1
    if ($null -eq $objFixtureNodeCommand) { throw 'Finalization fixture requires the trusted Node application.' }
    $objFixtureUtcNow = [DateTimeOffset]::UtcNow
    $strCurrentDate = $objFixtureUtcNow.ToString('yyyy-MM-dd')
    $strPriorDate = $objFixtureUtcNow.AddDays(-1).ToString('yyyy-MM-dd')
    $strBaselineDate = $objFixtureUtcNow.AddDays(-2).ToString('yyyy-MM-dd')
    $strFutureDate = $objFixtureUtcNow.AddDays(1).ToString('yyyy-MM-dd')
    $strValidatorPath = [IO.Path]::Combine($strFixtureRoot, '.github', 'workflows', 'Test-AgentInstructions.ps1')
    $strRunbookPath = [IO.Path]::Combine($strFixtureRoot, 'docs', 'finalization-fixture.md')
    $strMetadataDocument = "# Finalization fixture`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Fixture Maintainers`n- **Last Updated:** DATE`n- **Scope:** Author finalization tests.`n`n## Procedure`n`nFollow the current procedure.`n"
    # Private installed-policy setup uses only current tracked regular files.
    # Bound index output, each file and aggregate bytes; keep dependencies separate.
    # Native lstat supplies the type and identity immediately around each read.
    # This is not atomic confinement: the private fixture assumes no competing
    # writer. The child timeout does not bound a later substituted .NET OpenRead.
    $strFixtureInquiryProgram = @(
        'const fs = require("node:fs");'
        'const st = fs.lstatSync(process.argv[1], { bigint: true });'
        'if (!st.isFile()) { process.stdout.write("nonregular"); }'
        'else { process.stdout.write(["regular", st.dev, st.ino, st.mode, st.size, st.mtimeNs, st.ctimeNs].join("|")); }'
    ) -join "`n"
    $scriptblockFileInquiry = {
        param([string] $Path)
        if (-not [IO.Path]::IsPathRooted($Path)) { throw 'Finalization file inquiry requires an absolute path.' }
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new($objFixtureNodeCommand.Source)
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        [void]$objStartInfo.Environment.Remove('NODE_OPTIONS')
        [void]$objStartInfo.Environment.Remove('NODE_PATH')
        foreach ($strArgument in @('-e', $strFixtureInquiryProgram, $Path)) { $objStartInfo.ArgumentList.Add($strArgument) }
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStartInfo
        $objResult = Read-BoundedProcessData -Process $objProcess -MaximumBytes 4096 `
            -TimeoutMilliseconds 5000 -DisplayName 'Finalization authoritative file inquiry'
        if ($objResult.ExitCode -ne 0) { throw 'Finalization authoritative file inquiry failed.' }
        $strRecord = ConvertFrom-StrictUtf8Data -Bytes $objResult.Bytes -DisplayName 'Finalization authoritative file inquiry'
        if ($strRecord -ceq 'nonregular') { throw 'Finalization fixture input is authoritatively nonregular.' }
        if ($strRecord -cnotmatch ('\Aregular(?:\|(?:0|[1-9][0-9]{0,39})){4}' +
                '(?:\|(?:0|-?[1-9][0-9]{0,39})){2}\z')) {
            throw 'Finalization authoritative file inquiry returned a malformed identity record.'
        }
        return $strRecord
    }
    $scriptblockSnapshot = {
        param([string] $Root)
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new('git')
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        foreach ($strArgument in @('-C', $Root, 'ls-files', '--stage', '-z')) {
            $objStartInfo.ArgumentList.Add($strArgument)
        }
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStartInfo
        $objResult = Read-BoundedProcessData -Process $objProcess -MaximumBytes 1048576 `
            -TimeoutMilliseconds 10000 -DisplayName 'Finalization fixture index'
        if ($objResult.ExitCode -ne 0) { throw 'Finalization fixture index acquisition failed.' }
        $arrTrackedPaths = @(Read-GitTrackedPath -RepositoryRootPath $Root -MaximumBytes 1048576)
        $strEntries = ConvertFrom-StrictUtf8Data -Bytes $objResult.Bytes -DisplayName 'Finalization fixture index'
        if (-not $strEntries.EndsWith([string][char]0, [StringComparison]::Ordinal)) {
            throw 'Finalization fixture index must have terminal NUL.'
        }
        $arrEntries = @($strEntries.TrimEnd([char]0).Split([char]0))
        if ($arrEntries.Count -gt 4096 -or $arrEntries.Count -ne $arrTrackedPaths.Count) {
            throw 'Finalization fixture index has an unsupported count or unresolved stages.'
        }
        $setPaths = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
        $dictComponents = [Collections.Generic.Dictionary[string, string]]::new([StringComparer]::OrdinalIgnoreCase)
        $listSnapshot = [Collections.Generic.List[object]]::new()
        $longTotalBytes = 0L
        foreach ($strEntry in $arrEntries) {
            $objEntry = [regex]::Match($strEntry, '^(?<mode>100644|100755) (?<blob>[0-9a-f]{40}) 0\t(?<path>.+)$')
            if (-not $objEntry.Success) { throw 'Finalization fixture requires stage-0 regular Git files.' }
            $strPath = $objEntry.Groups['path'].Value
            if ([IO.Path]::IsPathRooted($strPath) -or $strPath -match '[\\:\x00-\x1f\x7f]' -or
                $strPath -match '(?:^|/)(?:\.{1,2}|\.git|node_modules)(?:/|$)' -or
                $strPath.Contains('//', [StringComparison]::Ordinal) -or -not $setPaths.Add($strPath) -or
                $arrTrackedPaths -cnotcontains $strPath) {
                throw 'Finalization fixture contains an unsafe or colliding tracked path.'
            }
            $strFilePath = [IO.Path]::Combine($Root, $strPath)
            $listComponents = [Collections.Generic.List[object]]::new()
            $strComponentPath = $Root
            $strRelativeComponent = ''
            foreach ($strComponent in $strPath.Split('/')) {
                if ($strComponent -match '[. ]$') { throw 'Finalization fixture contains an aliased path component.' }
                $strRelativeComponent = ($strRelativeComponent + '/' + $strComponent).TrimStart('/')
                if ($dictComponents.ContainsKey($strRelativeComponent) -and
                    $dictComponents[$strRelativeComponent] -cne $strRelativeComponent) {
                    throw 'Finalization fixture contains a case-colliding path component.'
                }
                $dictComponents[$strRelativeComponent] = $strRelativeComponent
                $strComponentPath = [IO.Path]::Combine($strComponentPath, $strComponent)
                $objItem = Get-Item -LiteralPath $strComponentPath -Force
                if (($objItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -or $objItem.LinkType) {
                    throw 'Finalization fixture contains an unsafe linked path component.'
                }
                $listComponents.Add([pscustomobject]@{ Path = $strComponentPath; Type = $objItem.GetType(); Created = $objItem.CreationTimeUtc.Ticks })
            }
            if ($objItem -isnot [IO.FileInfo]) { throw 'Finalization fixture input is not a regular file.' }
            $objUnixModeProperty = $objItem.PSObject.Properties['UnixMode']
            $strUnixMode = if ($null -eq $objUnixModeProperty) { '' } else { [string]$objUnixModeProperty.Value }
            if (-not [string]::IsNullOrEmpty($strUnixMode) -and $strUnixMode[0] -cne '-') {
                throw 'Finalization fixture input has a non-regular Unix file type.'
            }
            $strAuthoritativeIdentity = & $scriptblockFileInquiry $strFilePath
            $objStream = [IO.File]::OpenRead($strFilePath)
            try {
                $arrBytes = [byte[]]@(Read-BoundedStreamData -Stream $objStream -MaximumBytes 16777216 `
                        -DisplayName 'Finalization fixture tracked input')
            } finally { $objStream.Dispose() }
            $strRecheckedAuthoritativeIdentity = & $scriptblockFileInquiry $strFilePath
            if ($strRecheckedAuthoritativeIdentity -cne $strAuthoritativeIdentity) {
                throw 'Finalization fixture authoritative file identity changed during its bounded read.'
            }
            foreach ($objComponent in $listComponents) {
                $objItem = Get-Item -LiteralPath $objComponent.Path -Force
                if (($objItem.Attributes -band [IO.FileAttributes]::ReparsePoint) -ne 0 -or $objItem.LinkType -or
                    $objItem.GetType() -ne $objComponent.Type -or $objItem.CreationTimeUtc.Ticks -ne $objComponent.Created) {
                    throw 'Finalization fixture path changed during its bounded read.'
                }
            }
            $objUnixModeProperty = $objItem.PSObject.Properties['UnixMode']
            $strRecheckedUnixMode = if ($null -eq $objUnixModeProperty) { '' } else { [string]$objUnixModeProperty.Value }
            if ($strRecheckedUnixMode -cne $strUnixMode) { throw 'Finalization fixture Unix type or mode changed during its bounded read.' }
            $longTotalBytes += $arrBytes.Length
            if ($longTotalBytes -gt 67108864) { throw 'Finalization fixture tracked snapshot exceeds its aggregate bound.' }
            $arrBlobHeader = [Text.Encoding]::ASCII.GetBytes("blob $($arrBytes.Length)$([char]0)")
            $objBlobDigest = $null
            $objRawDigest = $null
            try {
                $objBlobDigest = [Security.Cryptography.SHA1]::Create()
                $objRawDigest = [Security.Cryptography.SHA256]::Create()
                $strRawBlob = [BitConverter]::ToString($objBlobDigest.ComputeHash(
                        [byte[]]($arrBlobHeader + $arrBytes))).Replace('-', '').ToLowerInvariant()
                $strRawSha256 = [BitConverter]::ToString($objRawDigest.ComputeHash($arrBytes)).Replace('-', '')
            } finally {
                if ($null -ne $objBlobDigest) { $objBlobDigest.Dispose() }
                if ($null -ne $objRawDigest) { $objRawDigest.Dispose() }
            }
            $listSnapshot.Add([pscustomobject]@{ Path = $strPath; Mode = $objEntry.Groups['mode'].Value
                    IndexBlob = $objEntry.Groups['blob'].Value; Blob = $strRawBlob; Bytes = $arrBytes
                    Sha256 = $strRawSha256 })
        }
        return $listSnapshot.ToArray()
    }
    $scriptblockSnapshotIdentity = {
        param([object[]] $Snapshot)
        @($Snapshot | ForEach-Object { "$($_.Path)`t$($_.Mode)`t$($_.IndexBlob)`t$($_.Blob)`t$($_.Sha256)" }) -join "`n"
    }
    # Check intended index/tree modes after every staging/commit boundary.
    # Physical permissions are not consumed by this fixture's explicit callers.
    $scriptblockAssertModes = {
        param([string] $Revision = '')
        $arrArguments = if ([string]::IsNullOrEmpty($Revision)) {
            @('-C', $strFixtureRoot, 'ls-files', '--stage', '-z')
        } else { @('-C', $strFixtureRoot, 'ls-tree', '-r', '-z', $Revision) }
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new('git')
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        foreach ($strArgument in $arrArguments) { $objStartInfo.ArgumentList.Add($strArgument) }
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStartInfo
        $objResult = Read-BoundedProcessData -Process $objProcess -MaximumBytes 1048576 `
            -TimeoutMilliseconds 10000 -DisplayName 'Finalization intended modes'
        if ($objResult.ExitCode -ne 0) { throw 'Finalization intended-mode acquisition failed.' }
        $strEntries = ConvertFrom-StrictUtf8Data -Bytes $objResult.Bytes -DisplayName 'Finalization intended modes'
        if (-not $strEntries.EndsWith([string][char]0, [StringComparison]::Ordinal)) {
            throw 'Finalization intended modes must have terminal NUL.'
        }
        $setSeen = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        foreach ($strEntry in $strEntries.TrimEnd([char]0).Split([char]0)) {
            $objEntry = [regex]::Match($strEntry,
                '^(?<mode>100644|100755) (?:blob [0-9a-f]{40}|[0-9a-f]{40} 0)\t(?<path>.+)$')
            if (-not $objEntry.Success -or -not $setSeen.Add($objEntry.Groups['path'].Value)) {
                throw 'Finalization intended modes contain unsafe or unresolved entries.'
            }
            $strPath = $objEntry.Groups['path'].Value
            $strExpectedMode = if ($dictExpectedModes.ContainsKey($strPath)) {
                $dictExpectedModes[$strPath]
            } else { '100644' }
            if ($objEntry.Groups['mode'].Value -cne $strExpectedMode) {
                throw "Finalization intended Git mode changed: $strPath."
            }
        }
        foreach ($strPath in $dictExpectedModes.Keys) {
            if (-not $setSeen.Contains($strPath)) { throw "Finalization installed path disappeared: $strPath." }
        }
    }
    $scriptblockCommit = {
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Finalization fixture indexing failed.' }
        & $scriptblockAssertModes
        & git -C $strFixtureRoot -c user.name=FinalizationFixture `
            -c user.email=finalization-fixture@example.invalid -c commit.gpgsign=false `
            -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=fixture
        if ($LASTEXITCODE -ne 0) { throw 'Finalization fixture commit failed.' }
        $strCommittedHead = ([string](& git -C $strFixtureRoot rev-parse --verify 'HEAD^{commit}')).Trim()
        if ($LASTEXITCODE -ne 0 -or $strCommittedHead -cnotmatch '^[0-9a-f]{40}$') {
            throw 'Finalization committed HEAD resolution failed.'
        }
        & $scriptblockAssertModes $strCommittedHead
        return $strCommittedHead
    }
    $scriptblockInvokeCheck = {
        param([string[]] $Argument, [DateTimeOffset] $Clock, [string] $Checker, [bool] $RequireLocal)
        # The wrapper preserves actual checker bytes, arguments, native exit and
        # exception text. It is not a literal -File launch of the documented command.
        $arrParameterTokens = @('-ProposedPolicy', '-InputRevision', '-PublishedBaselineRevision',
            '-SelfTest', '-MetadataClassificationOnly', '-FinalizeMetadataNow')
        $strCommandArguments = (@($Argument | ForEach-Object {
                    if ($arrParameterTokens -ccontains $_) { $_ } else { "'" + $_.Replace("'", "''") + "'" }
                }) -join ' ')
        $strCommand = '$ErrorActionPreference = ''Stop''; function Invoke-AgentInstructionFixtureClock {' +
            ${function:Invoke-AgentInstructionFixtureClock}.ToString() + '}; $checker = ''' + $Checker.Replace("'", "''") +
            '''; try { Invoke-AgentInstructionFixtureClock -CheckerPath $checker -UtcNow ''' + $Clock.ToString('o') +
            ''' ' + $(if ($RequireLocal) { '-RequireLocal ' } else { '' }) +
            '-Action { & $checker ' + $strCommandArguments +
            ' } } catch { [Console]::Out.WriteLine($_.Exception.Message); exit 1 }'
        $strOutput = (& $strHostPath -NoLogo -NoProfile -NonInteractive -Command $strCommand 2>&1 | Out-String)
        $intExit = $LASTEXITCODE
        if ($strOutput -match 'Fixture clock control failed:|Fixture clock requires one exact') {
            throw "The private caller clock failed: $strOutput"
        }
        [pscustomobject]@{ Output = $strOutput; ExitCode = $intExit }
    }
    $scriptblockCheck = {
        param([string] $Candidate, [bool] $Now, [bool] $Later, [bool] $Accept, [string] $Expected)
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Finalization policy checkout failed.' }
        $arrArguments = @('-InputRevision', $Candidate, '-PublishedBaselineRevision', $strBaseline)
        if ($Now) { $arrArguments += '-FinalizeMetadataNow' }
        $objClock = if ($Later) { $objFixtureUtcNow.AddDays(1) } else { $objFixtureUtcNow }
        $objResult = & $scriptblockInvokeCheck $arrArguments $objClock $strValidatorPath $false
        if (($objResult.ExitCode -eq 0) -ne $Accept -or $objResult.Output -notmatch $Expected) {
            throw "Author finalization caller failed (Now=$Now Later=$Later Accept=$Accept exit=$($objResult.ExitCode)): $($objResult.Output)"
        }
    }
    $scriptblockInvokeProposedCheck = {
        param([string[]] $Argument)
        & $scriptblockInvokeCheck $Argument $objFixtureUtcNow $strValidatorPath $false
    }
    try {
        # A fixed synthetic clock makes omission and scope regressions visible
        # on every day. Only this private probe file contains synthetic code;
        # the real installed checker remains byte-for-byte source-qualified.
        $strClockProbePath = [IO.Path]::Combine($strEmptyHooks, 'clock-probe[fixture].ps1')
        $strClockDecoyPath = [IO.Path]::Combine($strEmptyHooks, 'clock-probef.ps1')
        $strClockProbeContent = @'
param([int] $Difference = 1)
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
    [pscustomobject]@{ Captured = $script:strMaximumMetadataUtcDate; Local = $strExpectedUtcDate }
}
Read-FixtureClock -intDiffExitCode $Difference
'@
        $arrInitialBreakpoints = @(Get-PSBreakpoint | Select-Object -ExpandProperty Id)
        $arrInitialClockState = @(Get-Variable -Name 'hashtableFixtureClock*' -Scope Global | Select-Object -ExpandProperty Name)
        [IO.File]::WriteAllText($strClockProbePath, $strClockProbeContent, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strClockDecoyPath, $strClockProbeContent, [Text.UTF8Encoding]::new($false))
        foreach ($intDifference in @(0, 1)) {
            $objClockProbe = Invoke-AgentInstructionFixtureClock -CheckerPath $strClockProbePath `
                -UtcNow ([DateTimeOffset]::Parse('2000-01-02T23:59:59Z')) -RequireLocal -Action {
                $arrClockBreakpoints = @(Get-PSBreakpoint | Where-Object { $_.Id -notin $arrInitialBreakpoints })
                if ($arrClockBreakpoints.Count -ne 2 -or
                    @($arrClockBreakpoints | Where-Object { $_.Script -cne $strClockProbePath }).Count -ne 0) {
                    throw 'The fixture clock registered breakpoints outside the exact probe path.'
                }
                & $strClockProbePath -Difference $intDifference
            }
            $strExpectedLocal = if ($intDifference -eq 1) { '2000-01-02' } else { '' }
            if ($objClockProbe.Captured -cne '2000-01-02' -or $objClockProbe.Local -cne $strExpectedLocal) {
                throw 'The fixture clock lost its initialization, local scope or unchanged-path branch.'
            }
        }
        foreach ($objClockCase in @(
                @{ Content = $strClockProbeContent.Replace('$script:objValidationUtcNow =', '$script:objOtherNow ='); Action = { & $strClockProbePath }; Expected = 'requires one exact' },
                @{ Content = $strClockProbeContent + "`n" + $strClockProbeContent; Action = { & $strClockProbePath }; Expected = 'requires one exact' },
                @{ Content = $strClockProbeContent; Action = { }; Expected = 'Initialization clock did not fire' },
                @{ Content = $strClockProbeContent; Action = { throw 'Expected primary fixture error.' }; Expected = '^Expected primary fixture error\.$' }
            )) {
            [IO.File]::WriteAllText($strClockProbePath, $objClockCase.Content, [Text.UTF8Encoding]::new($false))
            $objExpectedClockFailure = $null
            try {
                Invoke-AgentInstructionFixtureClock -CheckerPath $strClockProbePath `
                    -UtcNow ([DateTimeOffset]::Parse('2000-01-02T23:59:59Z')) -Action $objClockCase.Action
            } catch { $objExpectedClockFailure = $_ }
            if ($null -eq $objExpectedClockFailure -or $objExpectedClockFailure.Exception.Message -notmatch $objClockCase.Expected) {
                throw 'A missing/duplicate/inactive clock anchor or primary-error regression escaped its control.'
            }
        }
        [IO.File]::WriteAllText($strClockProbePath, $strClockProbeContent, [Text.UTF8Encoding]::new($false))
        $objUninstrumentedProbe = & $strClockProbePath
        if ($objUninstrumentedProbe.Captured -ceq '2000-01-02' -or
            $objUninstrumentedProbe.Local -ceq '2000-01-02' -or
            @(Compare-Object -ReferenceObject (@('sentinel') + $arrInitialBreakpoints) `
                -DifferenceObject (@('sentinel') + @(Get-PSBreakpoint | Select-Object -ExpandProperty Id))).Count -ne 0 -or
            @(Compare-Object -ReferenceObject (@('sentinel') + $arrInitialClockState) `
                -DifferenceObject (@('sentinel') + @(Get-Variable -Name 'hashtableFixtureClock*' -Scope Global | Select-Object -ExpandProperty Name))).Count -ne 0) {
            throw 'The fixture clock leaked into an ordinary invocation or failed scoped cleanup.'
        }

        # Exercise the actual bounded inquiry before the longer installed-policy
        # scenarios. Controlled programs replace only the native response producer.
        $strInquiryControlPath = [IO.Path]::Combine($strEmptyHooks, 'inquiry-control.dat')
        [IO.File]::WriteAllBytes($strInquiryControlPath, [byte[]]@(0, 255, 1, 0))
        [void](& $scriptblockFileInquiry $strInquiryControlPath)
        $strSavedInquiryProgram = $strFixtureInquiryProgram
        try {
            foreach ($objInquiryCase in @(
                    @{ Program = 'process.stdout.write("regular|1|2|3|4|5");'; Expected = 'malformed identity record' },
                    @{ Program = 'process.stdout.write("regular|1|2|3|4|5|6|7");'; Expected = 'malformed identity record' },
                    @{ Program = 'process.stdout.write("regular|-1|2|3|4|5|6");'; Expected = 'malformed identity record' },
                    @{ Program = 'process.stdout.write("regular|1|2|3|4|1e3|6");'; Expected = 'malformed identity record' },
                    @{ Program = 'process.stdout.write("nonregular");'; Expected = 'authoritatively nonregular' },
                    @{ Program = 'process.exit(42);'; Expected = 'authoritative file inquiry failed' },
                    @{ Program = 'process.stdout.write("x".repeat(4097));'; Expected = 'must not exceed|exceeded|output bound' },
                    @{ Program = 'setInterval(() => {}, 1000);'; Expected = 'timeout|timed out|deadline' }
                )) {
                $strFixtureInquiryProgram = $objInquiryCase.Program
                $boolRejected = $false
                try { [void](& $scriptblockFileInquiry $strInquiryControlPath) } catch {
                    if ($_.Exception.Message -notmatch $objInquiryCase.Expected) { throw }
                    $boolRejected = $true
                }
                if (-not $boolRejected) { throw 'A malformed or failed authoritative inquiry was accepted.' }
            }
        } finally { $strFixtureInquiryProgram = $strSavedInquiryProgram }
        $scriptblockSavedFileInquiry = $scriptblockFileInquiry
        $script:boolFixtureInquiryChanged = $false
        try {
            $scriptblockFileInquiry = {
                param([string] $Path)
                if (-not [IO.Path]::IsPathRooted($Path)) { throw 'Controlled identity inquiry requires an absolute path.' }
                if ($script:boolFixtureInquiryChanged) { return 'regular|1|2|3|4|5|7' }
                $script:boolFixtureInquiryChanged = $true
                return 'regular|1|2|3|4|5|6'
            }
            $boolRejected = $false
            try { $null = & $scriptblockSnapshot $RepositoryRootPath } catch {
                if ($_.Exception.Message -notmatch 'authoritative file identity changed') { throw }
                $boolRejected = $true
            }
            if (-not $boolRejected) { throw 'An authoritative before/after identity change was accepted.' }
        } finally {
            $scriptblockFileInquiry = $scriptblockSavedFileInquiry
            Remove-Variable -Name boolFixtureInquiryChanged -Scope Script -ErrorAction SilentlyContinue
        }
        [IO.File]::Delete($strInquiryControlPath)
        Write-Verbose 'Finalization authoritative inquiry shape/native-exit/bound/timeout/identity controls passed.'
        & git -c "init.templateDir=$strEmptyHooks" clone --quiet --shared --no-hardlinks --no-checkout -- $RepositoryRootPath $strFixtureRoot
        if ($LASTEXITCODE -ne 0) { throw 'Finalization fixture acquisition failed.' }
        & git -C $strFixtureRoot config --local core.fileMode false
        if ($LASTEXITCODE -ne 0) { throw 'Finalization private file-mode configuration failed.' }
        $strPrivateFileMode = ([string](& git -C $strFixtureRoot config --local --bool --get core.fileMode)).Trim()
        if ($LASTEXITCODE -ne 0 -or $strPrivateFileMode -cne 'false') {
            throw 'Finalization private file-mode configuration readback failed.'
        }
        $strSourceHead = ([string](& git -C $RepositoryRootPath rev-parse --verify 'HEAD^{commit}')).Trim()
        if ($LASTEXITCODE -ne 0 -or $strSourceHead -cnotmatch '^[0-9a-f]{40}$') {
            throw 'Finalization fixture source HEAD is invalid.'
        }
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strSourceHead
        if ($LASTEXITCODE -ne 0) { throw 'Finalization fixture source checkout failed.' }
        $arrSourceSnapshot = @(& $scriptblockSnapshot $RepositoryRootPath)
        $strSourceIdentity = & $scriptblockSnapshotIdentity $arrSourceSnapshot
        $dictExpectedModes = [Collections.Generic.Dictionary[string, string]]::new([StringComparer]::Ordinal)
        foreach ($objSourceInput in $arrSourceSnapshot) { $dictExpectedModes.Add($objSourceInput.Path, $objSourceInput.Mode) }
        $arrCloneSnapshot = @(& $scriptblockSnapshot $strFixtureRoot)
        foreach ($objCloneInput in $arrCloneSnapshot) {
            if ($arrSourceSnapshot.Path -cnotcontains $objCloneInput.Path) {
                [IO.File]::Delete([IO.Path]::Combine($strFixtureRoot, $objCloneInput.Path))
            }
        }
        foreach ($objSourceInput in $arrSourceSnapshot) {
            $strDestination = [IO.Path]::Combine($strFixtureRoot, $objSourceInput.Path)
            [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($strDestination))
            [IO.File]::WriteAllBytes($strDestination, $objSourceInput.Bytes)
        }
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Finalization installed snapshot indexing failed.' }
        foreach ($objSourceInput in $arrSourceSnapshot) {
            $strModeArgument = if ($objSourceInput.Mode -ceq '100755') { '--chmod=+x' } else { '--chmod=-x' }
            & git -C $strFixtureRoot update-index $strModeArgument -- $objSourceInput.Path
            if ($LASTEXITCODE -ne 0) { throw 'Finalization installed snapshot mode indexing failed.' }
        }
        $arrInstalledSnapshot = @(& $scriptblockSnapshot $strFixtureRoot)
        if ((& $scriptblockSnapshotIdentity $arrInstalledSnapshot) -cne $strSourceIdentity) {
            # Source index blobs can precede worktree edits; destination index must
            # instead equal the exact raw candidate blobs we just installed.
            $strExpectedInstalledIdentity = @($arrSourceSnapshot | ForEach-Object {
                    "$($_.Path)`t$($_.Mode)`t$($_.Blob)`t$($_.Blob)`t$($_.Sha256)" }) -join "`n"
            if ((& $scriptblockSnapshotIdentity $arrInstalledSnapshot) -cne $strExpectedInstalledIdentity) {
                throw 'Finalization installed snapshot path/blob/mode/raw comparison failed.'
            }
        }
        if ((& $scriptblockSnapshotIdentity @(& $scriptblockSnapshot $RepositoryRootPath)) -cne $strSourceIdentity) {
            throw 'Finalization fixture source changed during materialization.'
        }
        $strRecheckedHead = ([string](& git -C $RepositoryRootPath rev-parse --verify 'HEAD^{commit}')).Trim()
        if ($LASTEXITCODE -ne 0 -or $strRecheckedHead -cne $strSourceHead) { throw 'Finalization fixture source HEAD changed.' }
        Write-Verbose "Finalization installed snapshot verified: $($arrSourceSnapshot.Count) tracked paths; source HEAD=$strSourceHead"
        $strGuidePath = [IO.Path]::Combine($strFixtureRoot, 'STYLE_GUIDE.md')
        $strGuide = [IO.File]::ReadAllText($strGuidePath)
        $arrGuideVersions = @([regex]::Matches($strGuide, '(?m)^\*\*Version:\*\* (?<prefix>\d+\.\d+\.)(?<date>\d{8})\.\d+$'))
        $arrGuideDates = @([regex]::Matches($strGuide, '(?m)^- \*\*Last Updated:\*\* \d{4}-\d{2}-\d{2}$'))
        if ($arrGuideVersions.Count -ne 1 -or $arrGuideDates.Count -ne 1) {
            throw 'Finalization installed guide requires exactly one supported Version and Last Updated field.'
        }
        $strGuide = [regex]::Replace($strGuide,
            '(?m)^(?<prefix>\*\*Version:\*\* \d+\.\d+\.)\d{8}\.\d+$',
            '${prefix}' + $strBaselineDate.Replace('-', '') + '.0')
        $strGuide = [regex]::Replace($strGuide,
            '(?m)^- \*\*Last Updated:\*\* \d{4}-\d{2}-\d{2}$', '- **Last Updated:** ' + $strBaselineDate)
        [IO.File]::WriteAllText($strGuidePath, $strGuide, [Text.UTF8Encoding]::new($false))
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Finalization normalized setup indexing failed.' }
        & $scriptblockAssertModes
        $strInstalledTree = ([string](& git -C $strFixtureRoot write-tree)).Trim()
        if ($LASTEXITCODE -ne 0) { throw 'Finalization installed tree resolution failed.' }
        $strSourceTree = ([string](& git -C $strFixtureRoot rev-parse --verify 'HEAD^{tree}')).Trim()
        if ($LASTEXITCODE -ne 0) { throw 'Finalization source tree resolution failed.' }
        if ($strInstalledTree -ceq $strSourceTree) {
            $strBaseline = $strSourceHead
            Write-Verbose "Finalization hypothetical installed B reused exact source HEAD=$strBaseline; tree=$strInstalledTree"
        } else {
            $strBaseline = & $scriptblockCommit
            Write-Verbose "Finalization hypothetical installed B committed=$strBaseline; tree=$strInstalledTree"
        }
        & $scriptblockAssertModes $strBaseline
        Write-Verbose "Finalization intended Git modes verified after normalization/B and every candidate commit; private core.fileMode=$strPrivateFileMode"
        [void][IO.Directory]::CreateDirectory([IO.Path]::Combine($strFixtureRoot, 'node_modules'))
        foreach ($strPackage in @('markdown-it', 'argparse', 'entities', 'linkify-it', 'mdurl', 'punycode.js', 'uc.micro')) {
            Copy-Item -LiteralPath ([IO.Path]::Combine($RepositoryRootPath, 'node_modules', $strPackage)) `
                -Destination ([IO.Path]::Combine($strFixtureRoot, 'node_modules', $strPackage)) -Recurse
        }
        [IO.File]::WriteAllText($strRunbookPath, $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strCurrentCandidate = & $scriptblockCommit
        & $scriptblockCheck $strCurrentCandidate $true $false $true "Author finalization UTC date checked: $strCurrentDate; B=$strBaseline H=$strCurrentCandidate"
        & $scriptblockCheck $strCurrentCandidate $false $true $true 'Finalization date not verified by this invocation'
        # Execute the contributor guide's accepted-base worktree caller, using
        # installed fixture B and exact locally committed H. This is fixture
        # evidence; native pre-install B cannot execute this new mode.
        $strPolicyPath = [IO.Path]::Combine($strFixtureRoot, 'policy-worktree')
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" worktree add --quiet --detach $strPolicyPath $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Documented policy worktree creation failed.' }
        [void][IO.Directory]::CreateDirectory([IO.Path]::Combine($strPolicyPath, 'node_modules'))
        foreach ($strPackage in @('markdown-it', 'argparse', 'entities', 'linkify-it', 'mdurl', 'punycode.js', 'uc.micro')) {
            Copy-Item -LiteralPath ([IO.Path]::Combine($RepositoryRootPath, 'node_modules', $strPackage)) `
                -Destination ([IO.Path]::Combine($strPolicyPath, 'node_modules', $strPackage)) -Recurse
        }
        Push-Location $strPolicyPath
        try {
            $strPolicyChecker = [IO.Path]::Combine($strPolicyPath, '.github', 'workflows', 'Test-AgentInstructions.ps1')
            $objDocumentedResult = & $scriptblockInvokeCheck @('-InputRevision', $strCurrentCandidate,
                '-PublishedBaselineRevision', $strBaseline, '-FinalizeMetadataNow') $objFixtureUtcNow $strPolicyChecker $false
            if ($objDocumentedResult.ExitCode -ne 0 -or $objDocumentedResult.Output -notmatch "B=$strBaseline H=$strCurrentCandidate") {
                throw "Documented accepted-worktree finalization caller failed: $($objDocumentedResult.Output)"
            }
        } finally { Pop-Location }
        # Ignore the fixture-only nested policy checkout in subsequent commits.
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" worktree remove --force $strPolicyPath
        if ($LASTEXITCODE -ne 0) { throw 'Documented fixture worktree cleanup failed.' }
        [IO.File]::WriteAllText($strRunbookPath, $strMetadataDocument.Replace('DATE', $strPriorDate), [Text.UTF8Encoding]::new($false))
        $strEarlierCandidate = & $scriptblockCommit
        & $scriptblockCheck $strEarlierCandidate $true $false $false 'Last Updated must|must use'
        & $scriptblockCheck $strEarlierCandidate $false $true $true 'Finalization date not verified by this invocation'
        foreach ($strInvalidDate in @($strFutureDate, '2026-99-99')) {
            [IO.File]::WriteAllText($strRunbookPath, $strMetadataDocument.Replace('DATE', $strInvalidDate), [Text.UTF8Encoding]::new($false))
            $strInvalidCandidate = & $scriptblockCommit
            & $scriptblockCheck $strInvalidCandidate $true $false $false 'later than trusted UTC|valid|calendar'
        }
        # Optional coverage uses an explicit private installed-policy baseline.
        # This setup is independent of whether future source docs opt in.
        $strBeforeOptionalBaseline = $strBaseline
        $strOptionalReadmePath = [IO.Path]::Combine($strFixtureRoot, 'README.md')
        $strOptionalCatalogPath = [IO.Path]::Combine($strFixtureRoot, '.github', 'copilot-instructions.md')
        $strNoHeaderFixture = "# Reader fixture`n`nNo optional metadata header.`n"
        [IO.File]::WriteAllText($strOptionalReadmePath, $strNoHeaderFixture, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strOptionalCatalogPath, $strNoHeaderFixture, [Text.UTF8Encoding]::new($false))
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Optional metadata baseline indexing failed.' }
        & git -C $strFixtureRoot diff --cached --quiet
        $intOptionalBaselineDifference = $LASTEXITCODE
        if ($intOptionalBaselineDifference -eq 1) { $strBaseline = & $scriptblockCommit }
        elseif ($intOptionalBaselineDifference -ne 0) { throw 'Optional metadata baseline comparison failed.' }
        foreach ($strOptionalPath in @($strOptionalReadmePath, $strOptionalCatalogPath)) {
            [IO.File]::WriteAllText($strOptionalPath,
                $strMetadataDocument.Replace('DATE', $strPriorDate), [Text.UTF8Encoding]::new($false))
            $strOptionalStaleCandidate = & $scriptblockCommit
            & $scriptblockCheck $strOptionalStaleCandidate $true $false $false 'Last Updated must'
            & $scriptblockCheck $strOptionalStaleCandidate $false $true $true 'Finalization date not verified by this invocation'
            [IO.File]::WriteAllText($strOptionalPath,
                $strMetadataDocument.Replace('DATE', $strCurrentDate).Replace('Status:** Active', 'Status:** Broken'),
                [Text.UTF8Encoding]::new($false))
            $strOptionalMalformedCandidate = & $scriptblockCommit
            & $scriptblockCheck $strOptionalMalformedCandidate $false $false $false 'exact top-level Status'
        }
        $strOptionalVersionedDocument = $strMetadataDocument.Replace('DATE', $strCurrentDate).Replace(
            "# Finalization fixture`n", "# Finalization fixture`n`n**Version:** 1.0.$($strCurrentDate.Replace('-', '')).0`n")
        [IO.File]::WriteAllText($strOptionalReadmePath, $strOptionalVersionedDocument, [Text.UTF8Encoding]::new($false))
        $strOptionalVersionCandidate = & $scriptblockCommit
        & $scriptblockCheck $strOptionalVersionCandidate $true $false $true 'Author finalization UTC date checked'
        # A malformed prior opt-in is data to reject, not new coverage to erase.
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strPriorDate).Replace('Status:** Active', 'Status:** Broken'),
            [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strOptionalParentCandidate = & $scriptblockCommit
        & $scriptblockCheck $strOptionalParentCandidate $false $false $false 'parent of README.md .*Status'
        # Full optional-header removal is allowed; malformed remnants are not.
        [IO.File]::WriteAllText($strOptionalReadmePath, $strNoHeaderFixture, [Text.UTF8Encoding]::new($false))
        $strOptionalRemovalCandidate = & $scriptblockCommit
        & $scriptblockCheck $strOptionalRemovalCandidate $true $false $true 'Author finalization UTC date checked'
        $strBaseline = $strBeforeOptionalBaseline
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Optional metadata fixture baseline restoration failed.' }
        Write-Verbose 'Optional retained Tier2/catalog and invalid-prior caller controls passed.'
        # A generated-to-Tier2 move must gain the same real metadata checks.
        $strGeneratedReadmeManifestPath = [IO.Path]::Combine($strFixtureRoot, '.github', 'document-metadata-classification.json')
        $strOriginalReadmeManifest = [IO.File]::ReadAllText($strGeneratedReadmeManifestPath)
        $objGeneratedReadmeManifest = $strOriginalReadmeManifest | ConvertFrom-Json
        $objGeneratedReadmeManifest.tier2Paths = @($objGeneratedReadmeManifest.tier2Paths | Where-Object { $_ -cne 'README.md' })
        $objGeneratedReadmeManifest.generatedPaths = [string[]]@($objGeneratedReadmeManifest.generatedPaths) + @('README.md')
        [Array]::Sort($objGeneratedReadmeManifest.generatedPaths, [StringComparer]::Ordinal)
        [IO.File]::WriteAllText($strGeneratedReadmeManifestPath,
            ($objGeneratedReadmeManifest | ConvertTo-Json -Depth 5), [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strPriorDate), [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strGeneratedReadmeManifestPath, $strOriginalReadmeManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strGeneratedToTier2Candidate = & $scriptblockCommit
        & $scriptblockCheck $strGeneratedToTier2Candidate $true $false $true 'Author finalization UTC date checked'
        [IO.File]::WriteAllText($strGeneratedReadmeManifestPath, $strOriginalReadmeManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate).Replace('Status:** Active', 'Status:** Broken'), [Text.UTF8Encoding]::new($false))
        $strMalformedTier2Candidate = & $scriptblockCommit
        & $scriptblockCheck $strMalformedTier2Candidate $false $false $false 'exact top-level Status'
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strPriorDate).Replace('Status:** Active', 'Status:** Broken'), [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strGeneratedReadmeManifestPath, $strOriginalReadmeManifest, [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText($strOptionalReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strInvalidGeneratedParentCandidate = & $scriptblockCommit
        & $scriptblockCheck $strInvalidGeneratedParentCandidate $false $false $false 'parent of README.md .*Status'
        $strBaseline = $strBeforeOptionalBaseline
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Generated-to-Tier2 fixture baseline restoration failed.' }
        Write-Verbose 'Generated-to-Tier2 actual content and prior-header controls passed.'
        # Version-like labels and mixed suffixes must reach the actual B/H checks.
        $strBeforeCaseBaseline = $strBaseline
        $strCaseReadmePath = [IO.Path]::Combine($strFixtureRoot, 'README.md')
        $strCaseRunbookPath = [IO.Path]::Combine($strFixtureRoot, 'docs', 'RUNBOOK.MD')
        $strCaseMetadata = $strMetadataDocument.Replace('DATE', $strCurrentDate)
        $strInvalidCaseVersion = $strCaseMetadata.Replace('## Procedure',
            "**version:** 1.0.20200101.7`n`n## Procedure")
        [IO.File]::WriteAllText($strCaseReadmePath, $strInvalidCaseVersion, [Text.UTF8Encoding]::new($false))
        $strInvalidCaseCandidate = & $scriptblockCommit
        & $scriptblockCheck $strInvalidCaseCandidate $false $false $false 'exact document-level Version'
        [IO.File]::WriteAllText($strCaseReadmePath, $strInvalidCaseVersion, [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strCaseReadmePath, $strCaseMetadata, [Text.UTF8Encoding]::new($false))
        $strPriorCaseCandidate = & $scriptblockCommit
        & $scriptblockCheck $strPriorCaseCandidate $false $false $false '(?s)parent of README[.]md.*Version'
        $strBaseline = $strBeforeCaseBaseline
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Version-case fixture baseline restoration failed.' }
        [IO.File]::WriteAllText($strCaseRunbookPath, '# Missing metadata', [Text.UTF8Encoding]::new($false))
        $strUpperMissingCandidate = & $scriptblockCommit
        & $scriptblockCheck $strUpperMissingCandidate $false $false $false '(?s)RUNBOOK[.]MD.*metadata'
        [IO.File]::WriteAllText($strCaseRunbookPath, $strCaseMetadata, [Text.UTF8Encoding]::new($false))
        $strUpperValidCandidate = & $scriptblockCommit
        & $scriptblockCheck $strUpperValidCandidate $true $false $true 'Author finalization UTC date checked'
        & git -C $strFixtureRoot -c "core.hooksPath=$strEmptyHooks" checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Suffix fixture baseline restoration failed.' }
        Write-Verbose 'Version-like header and uppercase Markdown actual caller controls passed.'
        # A peer Metadata section remains operative when its placement is wrong.
        $strBeforeLateMetadataBaseline = $strBaseline
        $strLateMetadata = "`n`n## Metadata`n`n- **Status:** Broken`n- **Owner:** Fixture`n" +
            "- **Last Updated:** 2026-99-99`n- **Scope:** Optional metadata.`n"
        foreach ($strOptionalPath in @('README.md', '.github/copilot-instructions.md')) {
            $strOptionalFullPath = [IO.Path]::Combine($strFixtureRoot, $strOptionalPath)
            [IO.File]::WriteAllText($strOptionalFullPath,
                [IO.File]::ReadAllText($strOptionalFullPath) + $strLateMetadata,
                [Text.UTF8Encoding]::new($false))
            $strLateMetadataHead = & $scriptblockCommit
            & $scriptblockCheck $strLateMetadataHead $false $false $false 'must place one document-level metadata list'
        }
        $strReadmePath = [IO.Path]::Combine($strFixtureRoot, 'README.md')
        [IO.File]::WriteAllText($strReadmePath,
            "# Reader`n`n## Intro`n`nBody.`n" + $strLateMetadata,
            [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strValidAfterLateMetadataHead = & $scriptblockCommit
        & $scriptblockCheck $strValidAfterLateMetadataHead $false $false $false '(?s)parent of README[.]md.*metadata list'
        $strBaseline = $strBeforeLateMetadataBaseline
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Late metadata baseline restoration failed.' }
        [IO.File]::WriteAllText($strReadmePath,
            "# Reader`n`n## Examples`n`n### Metadata`n`n- **Status:** Broken`n",
            [Text.UTF8Encoding]::new($false))
        $strNestedMetadataExampleHead = & $scriptblockCommit
        & $scriptblockCheck $strNestedMetadataExampleHead $false $false $true 'content contract passed'
        Write-Verbose 'Later peer Metadata current/prior rejection and nested example caller controls passed.'

        # Proposed code at H validates B/H without claiming accepted-policy authority.
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Proposed transition baseline checkout failed.' }
        $strProposedReadmePath = [IO.Path]::Combine($strFixtureRoot, 'README.md')
        [IO.File]::AppendAllText($strProposedReadmePath, "`nProposed transition fixture.`n", [Text.UTF8Encoding]::new($false))
        $strProposedHead = & $scriptblockCommit
        $objProposedResult = & $scriptblockInvokeProposedCheck -Argument @('-ProposedPolicy',
            '-InputRevision', $strProposedHead, '-PublishedBaselineRevision', $strBaseline)
        $strProposedOutput = $objProposedResult.Output
        if ($objProposedResult.ExitCode -ne 0 -or $strProposedOutput -notmatch 'PROPOSED_POLICY_TRANSITION' -or
            $strProposedOutput -notmatch 'not accepted-policy, owner or merge authority' -or
            $strProposedOutput -notmatch 'Proposed-policy transition checks passed') {
            throw "Proposed transition positive failed: $strProposedOutput"
        }
        foreach ($arrArguments in @(
                @('-InputRevision', $strProposedHead, '-PublishedBaselineRevision', $strBaseline),
                @('-ProposedPolicy'),
                @('-ProposedPolicy', '-InputRevision', $strProposedHead, '-PublishedBaselineRevision', $strProposedHead),
                @('-ProposedPolicy', '-InputRevision', $strProposedHead, '-PublishedBaselineRevision', ('0' * 40)),
                @('-ProposedPolicy', '-InputRevision', $strProposedHead, '-PublishedBaselineRevision', ('f' * 40)),
                @('-ProposedPolicy', '-SelfTest', '-InputRevision', $strProposedHead, '-PublishedBaselineRevision', $strBaseline),
                @('-ProposedPolicy', '-MetadataClassificationOnly', '-InputRevision', $strProposedHead, '-PublishedBaselineRevision', $strBaseline),
                @('-ProposedPolicy', '-FinalizeMetadataNow', '-InputRevision', $strProposedHead, '-PublishedBaselineRevision', $strBaseline))) {
            $objRejectedResult = & $scriptblockInvokeProposedCheck -Argument $arrArguments
            $strRejectedOutput = $objRejectedResult.Output
            if ($objRejectedResult.ExitCode -eq 0 -or $strRejectedOutput -notmatch 'accepted baseline|requires distinct|unavailable') {
                throw "Proposed transition mode boundary failed: $strRejectedOutput"
            }
        }
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        $objWrongCheckoutResult = & $scriptblockInvokeProposedCheck -Argument @('-ProposedPolicy',
            '-InputRevision', $strProposedHead, '-PublishedBaselineRevision', $strBaseline)
        $strWrongCheckoutOutput = $objWrongCheckoutResult.Output
        if ($objWrongCheckoutResult.ExitCode -eq 0 -or $strWrongCheckoutOutput -notmatch 'exact candidate head') {
            throw "Proposed transition wrong checkout was accepted: $strWrongCheckoutOutput"
        }
        $strProposedManifestPath = [IO.Path]::Combine($strFixtureRoot, '.github', 'document-metadata-classification.json')
        $objProposedManifest = [IO.File]::ReadAllText($strProposedManifestPath) | ConvertFrom-Json
        $objProposedManifest.tier2Paths = @($objProposedManifest.tier2Paths) + @('docs/UNAUTHORIZED.md')
        [Array]::Sort($objProposedManifest.tier2Paths, [StringComparer]::Ordinal)
        [IO.File]::WriteAllText($strProposedManifestPath, ($objProposedManifest | ConvertTo-Json -Depth 4), [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'docs', 'UNAUTHORIZED.md'), '# Unapproved', [Text.UTF8Encoding]::new($false))
        $strUnauthorizedHead = & $scriptblockCommit
        $objUnauthorizedResult = & $scriptblockInvokeProposedCheck -Argument @('-ProposedPolicy',
            '-InputRevision', $strUnauthorizedHead, '-PublishedBaselineRevision', $strBaseline)
        $strUnauthorizedOutput = $objUnauthorizedResult.Output
        if ($objUnauthorizedResult.ExitCode -eq 0 -or $strUnauthorizedOutput -notmatch 'unauthenticated metadata') {
            throw "Proposed transition admitted an unapproved exemption: $strUnauthorizedOutput"
        }
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Proposed transition fixture restoration failed.' }
        Write-Verbose 'Proposed-policy H checkout, exact endpoints, ordinary success and unauthorized transition controls passed.'

        # Proposed transition diagnostics retain the actual published Version baseline.
        $strBackwardGuidePath = [IO.Path]::Combine($strFixtureRoot, 'STYLE_GUIDE.md')
        $strEarlierDate = [DateTime]::ParseExact($strBaselineDate, 'yyyy-MM-dd',
            [Globalization.CultureInfo]::InvariantCulture).AddDays(-1).ToString('yyyy-MM-dd')
        $strBackwardGuide = [IO.File]::ReadAllText($strBackwardGuidePath).
            Replace($strBaselineDate, $strEarlierDate).
            Replace($strBaselineDate.Replace('-', ''), $strEarlierDate.Replace('-', ''))
        [IO.File]::WriteAllText($strBackwardGuidePath, $strBackwardGuide, [Text.UTF8Encoding]::new($false))
        $strBackwardHead = & $scriptblockCommit
        $objBackwardResult = & $scriptblockInvokeProposedCheck -Argument @('-ProposedPolicy',
            '-InputRevision', $strBackwardHead, '-PublishedBaselineRevision', $strBaseline)
        $strBackwardOutput = $objBackwardResult.Output
        if ($objBackwardResult.ExitCode -eq 0 -or $strBackwardOutput -notmatch 'Version date must not move backward') {
            throw "Proposed transition lost the actual published Version baseline: $strBackwardOutput"
        }
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Proposed backward-date fixture restoration failed.' }
        Write-Verbose 'Proposed transition actual published Version backward-date rejection passed.'

        # Spaced emphasized optional remnants remain invalid current and prior headers.
        $strBeforeSpacedBaseline = $strBaseline
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Spaced metadata baseline checkout failed.' }
        $strReadmePath = [IO.Path]::Combine($strFixtureRoot, 'README.md')
        [IO.File]::WriteAllText($strReadmePath, "# Reader`n`n- **Owner :** Fixture`n", [Text.UTF8Encoding]::new($false))
        $strSpacedHead = & $scriptblockCommit
        & $scriptblockCheck $strSpacedHead $false $false $false 'one exact top-level Status'
        & git -C $strFixtureRoot checkout --quiet --detach $strSpacedHead
        if ($LASTEXITCODE -ne 0) { throw 'Spaced metadata prior checkout failed.' }
        $strBaseline = $strSpacedHead
        [IO.File]::WriteAllText($strReadmePath, $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strAfterSpacedHead = & $scriptblockCommit
        & $scriptblockCheck $strAfterSpacedHead $false $false $false '(?s)parent of README[.]md.*one exact top-level Status'
        $strBaseline = $strBeforeSpacedBaseline
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Spaced metadata fixture restoration failed.' }
        Write-Verbose 'Spaced emphasized optional current/prior caller rejections passed.'

        # Conflicting reserved fields and raw Unicode paths reach real B/H checks.
        $strBeforeFieldBaseline = $strBaseline
        $strReadmePath = [IO.Path]::Combine($strFixtureRoot, 'README.md')
        $strConflictingMetadata = $strMetadataDocument.Replace('DATE', $strCurrentDate).
            Replace('## Procedure', "- **last updated:** 2026-99-99`n`n## Procedure")
        [IO.File]::WriteAllText($strReadmePath, $strConflictingMetadata, [Text.UTF8Encoding]::new($false))
        $strConflictingHead = & $scriptblockCommit
        & $scriptblockCheck $strConflictingHead $false $false $false 'one exact top-level Last Updated list item'
        [IO.File]::WriteAllText($strReadmePath, $strConflictingMetadata, [Text.UTF8Encoding]::new($false))
        $strBaseline = & $scriptblockCommit
        [IO.File]::WriteAllText($strReadmePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strValidAfterConflictHead = & $scriptblockCommit
        & $scriptblockCheck $strValidAfterConflictHead $false $false $false '(?s)parent of README[.]md.*Last Updated list item'
        $strBaseline = $strBeforeFieldBaseline
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        if ($LASTEXITCODE -ne 0) { throw 'Conflicting-field baseline restoration failed.' }
        $strUnicodePath = [IO.Path]::Combine($strFixtureRoot, 'docs', ('caf' + [char]0x00e9 + '.md'))
        [IO.File]::WriteAllText($strUnicodePath,
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strValidUnicodeHead = & $scriptblockCommit
        & $scriptblockCheck $strValidUnicodeHead $true $false $true 'content contract passed'
        [IO.File]::WriteAllText($strUnicodePath, '# Procedure without metadata', [Text.UTF8Encoding]::new($false))
        $strInvalidUnicodeHead = & $scriptblockCommit
        & $scriptblockCheck $strInvalidUnicodeHead $false $false $false 'must place one document-level metadata list'
        Write-Verbose 'Reserved field current/prior and Unicode current-document caller controls passed.'

        # Promotion must remain valid on a later no-context rerun.
        $strManifestPath = [IO.Path]::Combine($strFixtureRoot, '.github', 'document-metadata-classification.json')
        $objManifest = [IO.File]::ReadAllText($strManifestPath) | ConvertFrom-Json
        $objManifest.tier2Paths = @($objManifest.tier2Paths | Where-Object { $_ -cne 'README.md' })
        [IO.File]::WriteAllText($strManifestPath, ($objManifest | ConvertTo-Json -Depth 5), [Text.UTF8Encoding]::new($false))
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'README.md'),
            $strMetadataDocument.Replace('DATE', $strCurrentDate), [Text.UTF8Encoding]::new($false))
        $strPromotionCandidate = & $scriptblockCommit
        & $scriptblockCheck $strPromotionCandidate $true $false $true 'Author finalization UTC date checked'
        & $scriptblockCheck $strPromotionCandidate $false $true $true 'Finalization date not verified by this invocation'
        # The existing versioned source consumer must receive the require-date flag.
        $strGuidePath = [IO.Path]::Combine($strFixtureRoot, 'STYLE_GUIDE.md')
        $strGuide = [IO.File]::ReadAllText($strGuidePath)
        $strOldVersion = [regex]::Match($strGuide, '(?m)^\*\*Version:\*\* (?<prefix>\d+\.\d+\.)(?<date>\d{8})\.(?<revision>\d+)$')
        if (-not $strOldVersion.Success) { throw 'Versioned fixture source has no exact version.' }
        $strNewGuide = [regex]::Replace($strGuide,
            '(?m)^(?<prefix>\*\*Version:\*\* \d+\.\d+\.)\d{8}\.\d+$',
            '${prefix}' + $strPriorDate.Replace('-', '') + '.0')
        $strNewGuide = [regex]::Replace($strNewGuide, '(?m)^(?<prefix>- \*\*Last Updated:\*\* )\d{4}-\d{2}-\d{2}$', '${prefix}' + $strPriorDate)
        $strNewGuide += "`n<!-- Author-finalization versioned fixture. -->`n"
        # Use rendered prose, not an ignored comment, to exercise the transition.
        $strNewGuide += "`nAuthor finalization fixture procedure applies.`n"
        [IO.File]::WriteAllText($strGuidePath, $strNewGuide, [Text.UTF8Encoding]::new($false))
        $strVersionedEarlierCandidate = & $scriptblockCommit
        & $scriptblockCheck $strVersionedEarlierCandidate $true $false $false 'Last Updated must'
        & $scriptblockCheck $strVersionedEarlierCandidate $false $true $true 'Finalization date not verified by this invocation'
        $strCurrentGuide = [regex]::Replace($strNewGuide,
            '(?m)^(?<prefix>\*\*Version:\*\* \d+\.\d+\.)\d{8}\.\d+$',
            '${prefix}' + $strCurrentDate.Replace('-', '') + '.0')
        $strCurrentGuide = [regex]::Replace($strCurrentGuide,
            '(?m)^- \*\*Last Updated:\*\* \d{4}-\d{2}-\d{2}$', '- **Last Updated:** ' + $strCurrentDate)
        [IO.File]::WriteAllText($strGuidePath, $strCurrentGuide, [Text.UTF8Encoding]::new($false))
        $strVersionedCurrentCandidate = & $scriptblockCommit
        & $scriptblockCheck $strVersionedCurrentCandidate $true $false $true 'Author finalization UTC date checked'
        & git -C $strFixtureRoot checkout --quiet --detach $strBaseline
        # The existing local staged-document path retains strict current UTC.
        foreach ($strLocalDate in @($strPriorDate, $strCurrentDate)) {
            [IO.File]::WriteAllText($strRunbookPath, $strMetadataDocument.Replace('DATE', $strLocalDate), [Text.UTF8Encoding]::new($false))
            & git -C $strFixtureRoot -c core.autocrlf=false add -- docs/finalization-fixture.md
            if ($LASTEXITCODE -ne 0) { throw 'Local finalization fixture staging failed.' }
            & $scriptblockAssertModes
            $objLocalResult = & $scriptblockInvokeCheck @() $objFixtureUtcNow $strValidatorPath $true
            if (($objLocalResult.ExitCode -eq 0) -ne ($strLocalDate -ceq $strCurrentDate) -or
                ($strLocalDate -ceq $strPriorDate -and $objLocalResult.Output -notmatch 'Last Updated must')) {
                throw "Local staged creation date regression: $($objLocalResult.Output)"
            }
        }
        & git -C $strFixtureRoot restore --staged -- docs/finalization-fixture.md
        if ($LASTEXITCODE -ne 0) { throw 'Local fixture index cleanup failed.' }
        Remove-Item -LiteralPath $strRunbookPath -Force
        foreach ($arrMode in @(@('-FinalizeMetadataNow'), @('-FinalizeMetadataNow', '-SelfTest'),
                @('-FinalizeMetadataNow', '-MetadataClassificationOnly', '-InputRevision', $strCurrentCandidate, '-PublishedBaselineRevision', $strBaseline))) {
            $objModeResult = & $scriptblockInvokeCheck $arrMode $objFixtureUtcNow $strValidatorPath $false
            if ($objModeResult.ExitCode -eq 0 -or $objModeResult.Output -notmatch 'FinalizeMetadataNow') {
                throw "An invalid finalization mode combination lost its refusal: $($objModeResult.Output)"
            }
        }
        # Mutations execute the same accepted-B caller against the meaningful negative.
        [IO.File]::WriteAllText($strValidatorPath, $strRequireDateMutant, [Text.UTF8Encoding]::new($false))
        & $scriptblockCheck $strVersionedEarlierCandidate $true $false $true 'Author finalization UTC date checked'
        [IO.File]::WriteAllText($strValidatorPath, $strValidatorContent, [Text.UTF8Encoding]::new($false))
        foreach ($strClockMutation in @(
                $strInitialCoverageMutant,
                $strValidatorContent.Replace('if ($FinalizeMetadataNow) {',
                    'if ($FinalizeMetadataNow -or $boolPublishedEndpointsRequested) {').Replace(
                    'RequireFinalizationDate = ($objParentContext.IsWorktreeTransition -or $FinalizeMetadataNow)',
                    'RequireFinalizationDate = ($objParentContext.IsWorktreeTransition -or $FinalizeMetadataNow -or $boolPublishedEndpointsRequested)'))) {
            [IO.File]::WriteAllText($strValidatorPath, $strClockMutation, [Text.UTF8Encoding]::new($false))
            $boolDelayedMutationRejected = $false
            try {
                & $scriptblockCheck $strPromotionCandidate $false $true $true 'Finalization date not verified by this invocation'
            } catch {
                if ($_.Exception.Message -notmatch 'Last Updated must') { throw }
                $boolDelayedMutationRejected = $true
            }
            if (-not $boolDelayedMutationRejected) { throw 'A delayed-clock regression mutation escaped its caller test.' }
            [IO.File]::WriteAllText($strValidatorPath, $strValidatorContent, [Text.UTF8Encoding]::new($false))
        }
        $strStatusMutant = $strValidatorContent.Replace('Finalization date not verified by this invocation',
            'No explicit date status')
        [IO.File]::WriteAllText($strValidatorPath, $strStatusMutant, [Text.UTF8Encoding]::new($false))
        $boolStatusMutationRejected = $false
        try {
            & $scriptblockCheck $strCurrentCandidate $false $true $true 'Finalization date not verified by this invocation'
        } catch {
            if ($_.Exception.Message -notmatch '(?s)exit=0.*No explicit date status') { throw }
            $boolStatusMutationRejected = $true
        }
        if (-not $boolStatusMutationRejected) { throw 'The missing limited-status mutation escaped its caller test.' }
        [IO.File]::WriteAllText($strValidatorPath, $strValidatorContent, [Text.UTF8Encoding]::new($false))

    } finally {
        foreach ($strCleanupPath in @($strFixtureRoot, $strEmptyHooks)) {
            $strResolvedCleanupPath = [IO.Path]::GetFullPath($strCleanupPath)
            if ($strResolvedCleanupPath.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -and
                $strResolvedCleanupPath -cne $strTempRoot -and [IO.Directory]::Exists($strResolvedCleanupPath)) {
                Remove-Item -LiteralPath $strResolvedCleanupPath -Recurse -Force
            }
        }
    }
}

function Assert-DocumentMetadataPlacementSelfTest {
    # .SYNOPSIS
    # Tests policy placement and optional-Version transitions.
    #
    # .DESCRIPTION
    # Uses actual bounded Markdown parsing and published transition helpers.
    # Checks available exact-checkout documents and their input-size bounds.
    # Historical native-baseline comparisons are separate acceptance evidence.
    #
    # .PARAMETER RepositoryRootPath
    # The trusted repository containing the available exact checkout objects.
    #
    # .PARAMETER MaximumMetadataUtcDate
    # The captured current validation date in yyyy-MM-dd format.
    #
    # .EXAMPLE
    # Assert-DocumentMetadataPlacementSelfTest -RepositoryRootPath $strRoot `
    #     -MaximumMetadataUtcDate '2026-10-02'
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. Throws when a contract fixture fails.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261002.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param(
        [Parameter(Mandatory)][string] $RepositoryRootPath,
        [Parameter(Mandatory)][string] $MaximumMetadataUtcDate
    )

    $strFields = "- **Status:** Active`n- **Owner:** Maintainers`n- **Last Updated:** $MaximumMetadataUtcDate`n- **Scope:** Procedure.`n"
    $strVersion = '**Version:** 1.0.' + $MaximumMetadataUtcDate.Replace('-', '') + '.0'
    $strDirect = "# Procedure`n`n$strFields"
    $strHeaded = "# Procedure`n`n## Metadata`n`n$strFields"
    $strVersionedDirect = "# Procedure`n`n$strVersion`n`n$strFields"
    $strVersionedHeaded = "# Procedure`n`n$strVersion`n`n## Metadata`n`n$strFields"
    $strFrontMatter = "---`ntitle: Procedure`n---`n"
    foreach ($objPlacementFixture in @(
            [pscustomobject]@{ Name = 'direct list'; Content = $strDirect; Version = $false },
            [pscustomobject]@{ Name = 'headed list'; Content = $strHeaded; Version = $false },
            [pscustomobject]@{ Name = 'required Version direct'; Content = $strVersionedDirect; Version = $true },
            [pscustomobject]@{ Name = 'required Version headed'; Content = $strVersionedHeaded; Version = $true },
            [pscustomobject]@{ Name = 'optional Version direct'; Content = $strVersionedDirect; Version = $false },
            [pscustomobject]@{ Name = 'optional Version headed'; Content = $strVersionedHeaded; Version = $false },
            [pscustomobject]@{ Name = 'no H1 body start'; Content = $strFields; Version = $false },
            [pscustomobject]@{ Name = 'frontmatter title fallback'; Content = $strFrontMatter + $strFields; Version = $false },
            [pscustomobject]@{ Name = 'leading directive fallback'; Content = $strFrontMatter + "<!-- markdownlint-disable MD013 -->`n`n" + $strFields; Version = $false },
            [pscustomobject]@{ Name = 'late H1 fallback'; Content = $strFields + ("`n" * 30) + '# Late title'; Version = $false },
            [pscustomobject]@{ Name = 'H1 body line 30 direct'; Content = $strFrontMatter + ("`n" * 29) + $strDirect; Version = $false },
            [pscustomobject]@{ Name = 'H1 body line 30 headed'; Content = ("`n" * 29) + $strHeaded; Version = $false },
            [pscustomobject]@{ Name = 'H1 body line 30 Version'; Content = ("`n" * 29) + $strVersionedHeaded; Version = $true },
            [pscustomobject]@{ Name = 'later body Version prose'; Content = $strHeaded + "`n## Procedure`n`n**Version:** 2.0.0`n"; Version = $false },
            [pscustomobject]@{ Name = 'late H1 body examples'; Content = $strFields + ("`n" * 30) + "# Late title`n`n$strFields`n`n**Version:** 2.0.0`n"; Version = $false },
            [pscustomobject]@{ Name = 'later body field examples'; Content = $strHeaded + "`n## Body examples`n`n$strFields"; Version = $false },
            [pscustomobject]@{ Name = 'fields beyond line 30'; Content = $strHeaded.Replace($strFields, ("`n" * 40) + $strFields); Version = $false }
        )) {
        $objContext = Get-DocumentMetadataContext -Content $objPlacementFixture.Content `
            -RequiresVersion $objPlacementFixture.Version
        if ($null -ne $objContext.Failure) {
            throw "Valid placement rejected ($($objPlacementFixture.Name)): $($objContext.Failure)"
        }
        if ($objPlacementFixture.Name -like 'optional Version*' -and
            ($objContext.VersionDate -cne $MaximumMetadataUtcDate.Replace('-', '') -or
                $objContext.VersionLineIndex -lt 0)) {
            throw 'Optional Version was accepted but ignored.'
        }
    }
    $strFence = '```'
    foreach ($objInvalidPlacement in @(
            [pscustomobject]@{ Name = 'intervening prose'; Content = $strDirect.Replace($strFields, "Prose.`n`n$strFields"); Failure = 'must place' },
            [pscustomobject]@{ Name = 'intervening prose after Version'; Content = $strVersionedHeaded.Replace('## Metadata', "Prose.`n`n## Metadata"); Failure = 'must place' },
            [pscustomobject]@{ Name = 'earlier H2'; Content = $strHeaded.Replace('## Metadata', "## Earlier`n`n## Metadata"); Failure = 'must place' },
            [pscustomobject]@{ Name = 'duplicate section'; Content = $strHeaded + "`n## Metadata`n`n$strFields"; Failure = 'must place' },
            [pscustomobject]@{ Name = 'duplicate direct blocks'; Content = $strDirect + "`nProse.`n`n$strFields"; Failure = 'one exact top-level Status' },
            [pscustomobject]@{ Name = 'mixed direct and section'; Content = $strDirect + "`n## Metadata`n`n$strFields"; Failure = 'must place' },
            [pscustomobject]@{ Name = 'duplicate field'; Content = $strDirect.Replace('- **Owner:** Maintainers', "- **Owner:** Maintainers`n- **Owner:** Other"); Failure = 'one exact top-level Owner' },
            [pscustomobject]@{ Name = 'nested fields'; Content = "# Procedure`n`n- Wrapper`n" + ($strFields -replace '(?m)^', '  '); Failure = 'one exact top-level Status' },
            [pscustomobject]@{ Name = 'quoted fields'; Content = "# Procedure`n`n" + ($strFields -replace '(?m)^', '> '); Failure = 'must place' },
            [pscustomobject]@{ Name = 'fenced fields'; Content = "# Procedure`n`n$strFence`n$strFields$strFence"; Failure = 'must place' },
            [pscustomobject]@{ Name = 'mixed fake field'; Content = $strDirect.Replace('- **Owner:** Maintainers', '> - **Owner:** Maintainers'); Failure = 'one exact top-level Owner' },
            [pscustomobject]@{ Name = 'invalid status'; Content = $strDirect.Replace('Status:** Active', 'Status:** Unknown'); Failure = 'one exact top-level Status' },
            [pscustomobject]@{ Name = 'unclosed front matter'; Content = "---`ntitle: Procedure`n" + $strDirect; Failure = 'close leading YAML' },
            [pscustomobject]@{ Name = 'Version misplaced within header'; Content = $strDirect + "`n$strVersion`n"; Failure = 'Version paragraph' },
            [pscustomobject]@{ Name = 'malformed optional Version'; Content = $strVersionedDirect.Replace($strVersion, '**Version:** invalid'); Failure = 'Version paragraph' },
            [pscustomobject]@{ Name = 'duplicate optional Version'; Content = $strVersionedDirect.Replace($strVersion, "$strVersion`n`n$strVersion"); Failure = 'Version paragraph' },
            [pscustomobject]@{ Name = 'Version outside early H1'; Content = $strVersion + "`n`n" + $strFields; Failure = 'Version paragraph' },
            [pscustomobject]@{ Name = 'nonleading directive prose'; Content = "Intro.`n`n<!-- markdownlint-disable MD013 -->`n`n$strFields"; Failure = 'must place' }
        )) {
        $objContext = Get-DocumentMetadataContext -Content $objInvalidPlacement.Content -RequiresVersion $false
        if ($null -eq $objContext.Failure -or $objContext.Failure -notmatch $objInvalidPlacement.Failure) {
            throw "Invalid placement not rejected at intended boundary ($($objInvalidPlacement.Name)): $($objContext.Failure)"
        }
    }
    $strPriorDate = [DateTime]::ParseExact($MaximumMetadataUtcDate, 'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture).AddDays(-1).ToString('yyyy-MM-dd')
    $strEarlierDate = [DateTime]::ParseExact($strPriorDate, 'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture).AddDays(-1).ToString('yyyy-MM-dd')
    $strPriorUnversioned = $strDirect.Replace($MaximumMetadataUtcDate, $strPriorDate)
    $strPriorVersioned = $strVersionedDirect.Replace($MaximumMetadataUtcDate, $strPriorDate).
        Replace($MaximumMetadataUtcDate.Replace('-', ''), $strPriorDate.Replace('-', ''))
    foreach ($objTransitionFixture in @(
            [pscustomobject]@{ Name = 'new optional tuple'; Current = $strVersionedDirect; Parent = $strPriorUnversioned; Failure = '' },
            [pscustomobject]@{ Name = 'same-day new optional tuple'; Current = $strVersionedDirect; Parent = $strDirect; Failure = '' },
            [pscustomobject]@{ Name = 'optional tuple nonzero introduction'; Current = $strVersionedDirect.Replace($strVersion, ($strVersion -replace '\.0$', '.1'));  Parent = $strPriorUnversioned; Failure = 'revision must be exactly 0' },
            [pscustomobject]@{ Name = 'optional date mismatch'; Current = $strVersionedDirect.Replace($strVersion, $strVersion.Replace($MaximumMetadataUtcDate.Replace('-', ''), $strPriorDate.Replace('-', ''))); Parent = $strPriorUnversioned; Failure = 'matching calendar date' },
            [pscustomobject]@{ Name = 'backward introduction'; Current = $strVersionedDirect.Replace($MaximumMetadataUtcDate, $strEarlierDate).Replace($MaximumMetadataUtcDate.Replace('-', ''), $strEarlierDate.Replace('-', '')); Parent = $strPriorUnversioned; Failure = 'must not move backward' },
            [pscustomobject]@{ Name = 'invalid governed parent introduction'; Current = $strVersionedDirect; Parent = '# Invalid parent'; Failure = 'The parent of' },
            [pscustomobject]@{ Name = 'invalid parent calendar introduction'; Current = $strVersionedDirect; Parent = $strPriorUnversioned.Replace($strPriorDate, '2026-99-99'); Failure = 'parent.*calendar date' },
            [pscustomobject]@{ Name = 'old optional tuple new date'; Current = $strVersionedDirect; Parent = $strPriorVersioned; Failure = '' },
            [pscustomobject]@{ Name = 'same tuple rendered change no increment'; Current = $strVersionedDirect + "`nChanged prose.`n"; Parent = $strVersionedDirect; Failure = 'revision must be exactly 1' },
            [pscustomobject]@{ Name = 'same tuple proper increment'; Current = $strVersionedDirect.Replace($strVersion, ($strVersion -replace '\.0$', '.1')) + "`nChanged prose.`n"; Parent = $strVersionedDirect; Failure = '' },
            [pscustomobject]@{ Name = 'optional removal'; Current = $strDirect; Parent = $strPriorVersioned; Failure = '' },
            [pscustomobject]@{ Name = 'optional removal backward date'; Current = $strDirect.Replace($MaximumMetadataUtcDate, $strEarlierDate); Parent = $strPriorVersioned; Failure = 'must not move backward' },
            [pscustomobject]@{ Name = 'invalid optional parent removal'; Current = $strDirect; Parent = $strPriorVersioned.Replace($strPriorDate.Replace('-', ''), '20269999'); Failure = 'parent.*matching calendar date' },
            [pscustomobject]@{ Name = 'invalid optional integer'; Current = $strVersionedDirect.Replace('1.0.', '999999999999999999999999.0.'); Parent = $null; Failure = '64-bit' },
            [pscustomobject]@{ Name = 'invalid optional calendar'; Current = $strVersionedDirect.Replace($MaximumMetadataUtcDate, '2026-02-30').Replace($MaximumMetadataUtcDate.Replace('-', ''), '20260230'); Parent = $null; Failure = 'calendar date' },
            [pscustomobject]@{ Name = 'stale optional new document'; Current = $strPriorVersioned; Parent = $null; Failure = 'Last Updated must be' }
        )) {
        $arrFailures = @(Get-PublishedEndpointLastUpdatedFailure -Name $objTransitionFixture.Name `
                -CurrentContent $objTransitionFixture.Current -BaseContent $objTransitionFixture.Parent `
                -TrustedEventUtcDate $MaximumMetadataUtcDate -RequireCurrentMaximumDateForRenderedChange $true)
        if (($objTransitionFixture.Failure -eq '' -and $arrFailures.Count -ne 0) -or
            ($objTransitionFixture.Failure -ne '' -and -not ($arrFailures -match $objTransitionFixture.Failure))) {
            throw "Optional Version transition failed ($($objTransitionFixture.Name)): $($arrFailures -join '; ')"
        }
    }
    if (-not (@(Get-PublishedEndpointMetadataFailure -Name 'required-removal' `
            -CurrentContent $strDirect -ParentContent $strVersionedDirect -ExpectedUtcDate $MaximumMetadataUtcDate `
            -IsNewDocumentTransition $false) -match 'Version paragraph')) {
        throw 'A required Version could be removed.'
    }
    $strCheckoutRevision = ([string](& git -C $RepositoryRootPath rev-parse --verify 'HEAD^{commit}')).Trim()
    if ($LASTEXITCODE -ne 0 -or $strCheckoutRevision -cnotmatch '^[0-9a-f]{40}$') {
        throw 'The available checkout revision could not be resolved exactly.'
    }
    foreach ($strCheckoutPath in @('.claude/commands/review-loop.md', 'docs/P1-SUPPLY-FREEZE-v1.md', 'docs/dependency-maintenance.md', '.github/instructions/docs.instructions.md')) {
        $strCheckoutContent = Read-GitRevisionText -RepositoryRootPath $RepositoryRootPath `
            -Revision $strCheckoutRevision -RepositoryRelativePath $strCheckoutPath `
            -MaximumBytes 196608 -RequireRegularFile
        $boolOversizedCheckoutRejected = $false
        try {
            $null = Read-GitRevisionText -RepositoryRootPath $RepositoryRootPath `
                -Revision $strCheckoutRevision -RepositoryRelativePath $strCheckoutPath `
                -MaximumBytes 8 -RequireRegularFile
        } catch {
            if ($_.Exception.Message -notmatch 'must not exceed 8 bytes') { throw }
            $boolOversizedCheckoutRejected = $true
        }
        if (-not $boolOversizedCheckoutRejected) { throw 'An oversized governed document passed its input bound.' }
        $arrFailures = @(Get-PublishedEndpointLastUpdatedFailure -Name $strCheckoutPath `
                -CurrentContent $strCheckoutContent -BaseContent $strCheckoutContent -TrustedEventUtcDate '')
        if ($arrFailures.Count -ne 0 -or
            (Test-InitialMetadataCoveragePath -HasTrustedBaselineManifest $false -RepositoryRelativePath $strCheckoutPath)) {
            throw "An available-checkout document failed ordinary comparison: $strCheckoutPath; $($arrFailures -join '; ')"
        }
    }
}

$arrDeclaredOutputTypes = @($MyInvocation.MyCommand.OutputType.Name)
if ($arrDeclaredOutputTypes.Count -ne 1 -or
    $arrDeclaredOutputTypes[0] -cne 'System.Void') {
    throw 'The extracted self-test must declare one void output contract.'
}
$script:strMaximumMetadataUtcDate = $MaximumMetadataUtcDate
function Assert-OptionalMetadataSelfTest {
    # .SYNOPSIS
    # Checks optional header intent and retained metadata transitions.
    #
    # .DESCRIPTION
    # Uses the production parser and metadata helpers. Intent selects strict
    # validation even when fields are malformed; examples remain non-operative.
    #
    # .PARAMETER MaximumMetadataUtcDate
    # The captured latest UTC date used by the validator.
    #
    # .EXAMPLE
    # Assert-OptionalMetadataSelfTest -MaximumMetadataUtcDate $strDate
    #
    # # Runs optional metadata positive and negative controls.
    #
    # .INPUTS
    # None. This function does not accept pipeline input.
    #
    # .OUTPUTS
    # None. Failed controls throw.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261003.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $MaximumMetadataUtcDate)

    $objDate = [DateTime]::ParseExact($MaximumMetadataUtcDate, 'yyyy-MM-dd',
        [Globalization.CultureInfo]::InvariantCulture)
    $strPriorDate = $objDate.AddDays(-1).ToString('yyyy-MM-dd')
    $strFutureDate = $objDate.AddDays(1).ToString('yyyy-MM-dd')
    $strFields = "- **Status:** Active`n- **Owner:** Fixture`n- **Last Updated:** $MaximumMetadataUtcDate`n- **Scope:** Optional metadata.`n"
    $strDirect = "# Reader`n`n$strFields`n## Content`n`nCurrent text.`n"
    $strVersion = '**Version:** 1.0.' + $MaximumMetadataUtcDate.Replace('-', '') + '.0'
    $strVersioned = $strDirect.Replace("# Reader`n", "# Reader`n`n$strVersion`n")
    $arrIntentCases = @(
        @{ Name = 'direct'; Content = $strDirect; Expected = $true },
        @{ Name = 'headed'; Content = $strDirect.Replace('- **Status:', "## Metadata`n`n- **Status:"); Expected = $true },
        @{ Name = 'optional version'; Content = $strVersioned; Expected = $true },
        @{ Name = 'missing fields'; Content = "# Reader`n`n## Metadata`n"; Expected = $true },
        @{ Name = 'malformed status'; Content = $strDirect.Replace('Status:** Active', 'Status:** Broken'); Expected = $true },
        @{ Name = 'malformed emphasis'; Content = "# Reader`n`n- **Owner** Fixture`n"; Expected = $true },
        @{ Name = 'wrong placement'; Content = $strDirect.Replace("# Reader`n", "# Reader`n`nIntervening prose.`n"); Expected = $true },
        @{ Name = 'direct before early title'; Content = $strFields + "`n# Reader`n`nBody.`n"; Expected = $true },
        @{ Name = 'headed before early title'; Content = "## Metadata`n`n$strFields`n# Reader`n`nBody.`n"; Expected = $true },
        @{ Name = 'malformed section before early title'; Content = "### Metadata`n`n# Reader`n`nBody.`n"; Expected = $true },
        @{ Name = 'quoted before early title'; Content = "> - **Status:** Active`n`n# Reader`n`nBody.`n"; Expected = $false },
        @{ Name = 'Metadata title without fields'; Content = "# Metadata`n`nReader overview.`n"; Expected = $false },
        @{ Name = 'Metadata title with fields'; Content = $strDirect.Replace('# Reader', '# Metadata'); Expected = $true },
        @{ Name = 'late Metadata title without fields'; Content = ("`n" * 31) + '# Metadata'; Expected = $false },
        @{ Name = 'late Metadata title with fallback fields'; Content = $strFields + ("`n" * 31) + '# Metadata'; Expected = $true },
        @{ Name = 'Version title without fields'; Content = "# Version`n`nReader overview.`n"; Expected = $false },
        @{ Name = 'Version title with fields'; Content = $strDirect.Replace('# Reader', '# Version'); Expected = $true },
        @{ Name = 'plain Version paragraph'; Content = "# Reader`n`nVersion: malformed`n"; Expected = $true },
        @{ Name = 'Version paragraph before title'; Content = "$strVersion`n`n# Reader`n"; Expected = $true },
        @{ Name = 'Metadata example after ordinary section'; Content = "# Reader`n`n## Examples`n`n### Metadata`n`n$strFields"; Expected = $false },
        @{ Name = 'later peer Metadata'; Content = "# Reader`n`n## Intro`n`nText.`n`n## Metadata`n`n$strFields"; Expected = $true },
        @{ Name = 'later peer missing fields'; Content = "# Reader`n`n## Intro`n`n## Metadata`n"; Expected = $true },
        @{ Name = 'later peer malformed fields'; Content = "# Reader`n`n## Intro`n`n## Metadata`n`n- **Status:** Broken`n- **Last Updated:** 2026-99-99`n"; Expected = $true },
        @{ Name = 'later peer stale fields'; Content = "# Reader`n`n## Intro`n`n## Metadata`n`n" + $strFields.Replace($MaximumMetadataUtcDate, $strPriorDate); Expected = $true },
        @{ Name = 'later peer after several sections'; Content = "# Reader`n`n## One`n`n### Detail`n`n## Two`n`n## Metadata`n`n$strFields"; Expected = $true },
        @{ Name = 'later peer before early title'; Content = "## Intro`n`n## Metadata`n`n$strFields`n# Reader`n"; Expected = $true },
        @{ Name = 'later peer fallback'; Content = "Overview.`n`n## Intro`n`n## Metadata`n`n$strFields"; Expected = $true },
        @{ Name = 'later peer setext'; Content = "# Reader`n`n## Intro`n`nMetadata`n--------`n`n$strFields"; Expected = $true },
        @{ Name = 'later noncanonical peer'; Content = "# Reader`n`n## Intro`n`n## metadata:`n`n$strFields"; Expected = $true },
        @{ Name = 'later quoted peer'; Content = "# Reader`n`n## Examples`n`n> ## Metadata`n> - **Status:** Broken`n"; Expected = $false },
        @{ Name = 'later fenced peer'; Content = "# Reader`n`n## Examples`n`n~~~~markdown`n## Metadata`n$strFields~~~~`n"; Expected = $false },
        @{ Name = 'later list-nested peer'; Content = "# Reader`n`n## Examples`n`n- Example:`n`n  ## Metadata`n`n  - **Status:** Broken`n"; Expected = $false },
        @{ Name = 'later HTML peer'; Content = "# Reader`n`n## Examples`n`n<div>`n## Metadata`n$strFields</div>`n"; Expected = $false },
        @{ Name = 'frontmatter peer'; Content = "---`n## Metadata`n---`n# Reader`n`nNo header.`n"; Expected = $false },
        @{ Name = 'later Metadata H1'; Content = "# Reader`n`n## Examples`n`n# Metadata`n"; Expected = $false },
        @{ Name = 'no H1 fallback'; Content = $strFields; Expected = $true },
        @{ Name = 'directive fallback'; Content = "<!-- markdownlint-disable MD013 -->`n`n$strFields"; Expected = $true },
        @{ Name = 'late H1 fallback'; Content = $strFields + ("`n" * 31) + '# Late title'; Expected = $true },
        @{ Name = 'no header'; Content = "# Reader`n`nGetting started.`n"; Expected = $false },
        @{ Name = 'generic labels'; Content = "# Reader`n`n- Owner: project team`n- Scope: user examples`n"; Expected = $false },
        @{ Name = 'fenced'; Content = "# Reader`n`n~~~~markdown`n$strFields~~~~`n"; Expected = $false },
        @{ Name = 'quoted'; Content = "# Reader`n`n" + (($strFields.TrimEnd() -split "`n" | ForEach-Object { '> ' + $_ }) -join "`n"); Expected = $false },
        @{ Name = 'front matter'; Content = "---`n$strFields---`n# Reader`n`nNo header.`n"; Expected = $false },
        @{ Name = 'unclosed marked front matter'; Content = "---`n$strFields"; Expected = $true },
        @{ Name = 'example section'; Content = "# Reader`n`n## Example`n`n$strFields"; Expected = $false },
        @{ Name = 'inline code'; Content = '# Reader' + "`n`n- ``**Status:** Active```n"; Expected = $false },
        @{ Name = 'HTML example'; Content = "# Reader`n`n<div>`n$strFields</div>`n"; Expected = $false }
    )
    foreach ($strLabel in @('Owner', 'Scope', 'OWNER', 'sCoPe')) {
        foreach ($strSpace in @(' ', '  ', "`t")) {
            $strMarker = "- **$strLabel${strSpace}:** Fixture"
            $arrIntentCases += @{ Name = "spaced emphasized $strLabel"; Content = "# Reader`n`n$strMarker`n"; Expected = $true }
            $arrIntentCases += @{ Name = "quoted spaced $strLabel"; Content = "# Reader`n`n> $strMarker`n"; Expected = $false }
            $arrIntentCases += @{ Name = "fenced spaced $strLabel"; Content = "# Reader`n`n~~~~markdown`n$strMarker`n~~~~`n"; Expected = $false }
            $arrIntentCases += @{ Name = "generic spaced $strLabel"; Content = "# Reader`n`n- $strLabel${strSpace}: prose`n"; Expected = $false }
        }
    }
    foreach ($objCase in $arrIntentCases) {
        if ((Test-DocumentMetadataHeaderIntent -Content $objCase.Content) -ne $objCase.Expected) {
            throw "Optional metadata intent failed: $($objCase.Name)"
        }
    }
    foreach ($objCase in @(
            @{ Name = 'initial'; Current = $strDirect; Base = $null; Strict = $true; Pattern = '' },
            @{ Name = 'initial version'; Current = $strVersioned; Base = $null; Strict = $true; Pattern = '' },
            @{ Name = 'initial nonzero revision'; Current = $strVersioned.Replace('.0' + "`n", '.2' + "`n"); Base = $null; Strict = $true; Pattern = 'revision must be exactly 0' },
            @{ Name = 'stale finalization'; Current = $strDirect.Replace($MaximumMetadataUtcDate, $strPriorDate); Base = $null; Strict = $true; Pattern = 'Last Updated must be' },
            @{ Name = 'delayed ordinary'; Current = $strDirect.Replace($MaximumMetadataUtcDate, $strPriorDate); Base = $null; Strict = $false; Pattern = '' },
            @{ Name = 'future'; Current = $strDirect.Replace($MaximumMetadataUtcDate, $strFutureDate); Base = $null; Strict = $false; Pattern = 'later than trusted UTC' },
            @{ Name = 'calendar'; Current = $strDirect.Replace($MaximumMetadataUtcDate, '2026-99-99'); Base = $null; Strict = $false; Pattern = 'real calendar date' },
            @{ Name = 'invalid parent'; Current = $strDirect; Base = $strDirect.Replace('Status:** Active', 'Status:** Broken'); Strict = $false; Pattern = 'parent of .*Status' },
            @{ Name = 'backward'; Current = $strDirect.Replace($MaximumMetadataUtcDate, $strPriorDate); Base = $strDirect; Strict = $false; Pattern = 'must not move backward' },
            @{ Name = 'version introduction'; Current = $strVersioned; Base = $strDirect; Strict = $false; Pattern = '' },
            @{ Name = 'version removal'; Current = $strDirect; Base = $strVersioned; Strict = $false; Pattern = '' },
            @{ Name = 'invalid prior version removal'; Current = $strDirect; Base = $strVersioned.Replace($strVersion, $strVersion.Replace($MaximumMetadataUtcDate.Replace('-', ''), '20269999')); Strict = $false; Pattern = 'matching calendar date' }
        )) {
        $arrFailures = @(Get-PublishedEndpointLastUpdatedFailure -Name 'optional.md' `
                -CurrentContent $objCase.Current -BaseContent $objCase.Base -TrustedEventUtcDate '' `
                -RequireCurrentMaximumDateForRenderedChange $objCase.Strict)
        if (($objCase.Pattern -ceq '' -and $arrFailures.Count -ne 0) -or
            ($objCase.Pattern -cne '' -and -not ($arrFailures -match $objCase.Pattern))) {
            throw "Optional metadata transition failed: $($objCase.Name): $($arrFailures -join '; ')"
        }
    }
    foreach ($strLabel in @('version:', 'VERSION:', 'vErSiOn:', 'Version :', "Version`t:")) {
        $strMalformedVersion = "**${strLabel}** 1.0.20200101.7"
        foreach ($strContent in @(
                $strDirect.Replace("# Reader`n", "# Reader`n`n$strMalformedVersion`n"),
                $strDirect.Replace('## Content', "$strMalformedVersion`n`n## Content"),
                $strVersioned.Replace('## Content', "$strMalformedVersion`n`n## Content"))) {
            foreach ($boolRequiresVersion in @($false, $true)) {
                $objMalformedContext = Get-DocumentMetadataContext -Content $strContent -RequiresVersion $boolRequiresVersion
                if ($objMalformedContext.Failure -notmatch 'one exact document-level Version paragraph') {
                    throw "A noncanonical Version-like header was ignored: $strLabel"
                }
            }
        }
    }
    $strNoncanonicalVersion = '**version:** 1.0.20200101.7'
    foreach ($strContent in @(
            $strDirect.Replace('## Content', "~~~~text`n$strNoncanonicalVersion`n~~~~`n`n## Content"),
            $strDirect.Replace('## Content', "> $strNoncanonicalVersion`n`n## Content"),
            ($strDirect + "`n$strNoncanonicalVersion`n"),
            "---`nversion: 1.0.20200101.7`n---`n$strDirect")) {
        if ((Get-DocumentMetadataContext -Content $strContent -RequiresVersion $false).Failure) {
            throw 'A Version-like example outside operative header paragraphs was promoted.'
        }
    }
    $strInvalidPriorVersion = $strDirect.Replace('## Content', "$strNoncanonicalVersion`n`n## Content")
    if (-not (@(Get-PublishedEndpointLastUpdatedFailure -Name 'optional.md' -CurrentContent $strDirect `
                -BaseContent $strInvalidPriorVersion -TrustedEventUtcDate '') -match 'parent of .*Version')) {
        throw 'A noncanonical prior Version-like header was erased.'
    }
    foreach ($strFieldName in @('Status', 'Owner', 'Last Updated', 'Scope')) {
        foreach ($strLabel in @($strFieldName.ToLowerInvariant(), $strFieldName.ToUpperInvariant(),
                ($strFieldName + ' '), $strFieldName.Replace(' ', '  '))) {
            foreach ($boolRequiresVersion in @($false, $true)) {
                $strBase = if ($boolRequiresVersion) { $strVersioned } else { $strDirect }
                $arrMalformed = @($strBase.Replace('## Content', "- **${strLabel}:** conflicting value`n`n## Content"))
                if ($strLabel -cne $strFieldName) {
                    $arrMalformed += $strBase.Replace("**${strFieldName}:**", "**${strLabel}:**")
                }
                foreach ($strMalformed in $arrMalformed) {
                    $strFailure = (Get-DocumentMetadataContext -Content $strMalformed -RequiresVersion $boolRequiresVersion).Failure
                    if ($strFailure -notmatch ('one exact top-level ' + [regex]::Escape($strFieldName) + ' list item')) {
                        throw "A reserved field variant escaped exact validation: $strLabel"
                    }
                }
            }
        }
    }
    foreach ($strExample in @(
            "~~~~text`n- **status:** Broken`n~~~~`n",
            "> - **status:** Broken`n",
            "- Example:`n  - **status:** Broken`n",
            '- `status: Broken`',
            '- **Related:** Useful reference.',
            '- StatusCode: ordinary extra field.')) {
        if ((Get-DocumentMetadataContext -Content $strDirect.Replace('## Content', "$strExample`n`n## Content") -RequiresVersion $false).Failure) {
            throw 'An excluded example or unrelated metadata label was promoted.'
        }
    }
    if ((Get-DocumentMetadataContext -Content ($strDirect + "`n- **status:** Broken`n") -RequiresVersion $false).Failure) {
        throw 'A later-section field example was promoted.'
    }
    $strInvalidPriorField = $strDirect.Replace('## Content', "- **last updated:** 2026-99-99`n`n## Content")
    if (-not (@(Get-PublishedEndpointLastUpdatedFailure -Name 'optional.md' -CurrentContent $strDirect `
                -BaseContent $strInvalidPriorField -TrustedEventUtcDate '') -match 'parent of .*Last Updated')) {
        throw 'A conflicting noncanonical prior field was erased.'
    }
}

function Assert-GitRevisionTextSelfTest {
    # .SYNOPSIS
    # Checks exact raw Git entry framing and bounded revision content reads.
    #
    # .DESCRIPTION
    # Uses disposable native Git objects and controlled child-process output.
    # Retains exact path, mode, object type, UTF-8 and transport failure checks.
    #
    # .EXAMPLE
    # Assert-GitRevisionTextSelfTest
    #
    # # Throws when a revision reader control fails.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. Failed controls throw.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; there are no parameters.
    # Version: 1.0.20261003.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param()

    $strTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = [IO.Path]::Combine($strTempRoot, 'agent-git-entry-' + [Guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory([IO.Path]::Combine($strFixtureRoot, 'docs'))
    $strEmptyHooks = [IO.Path]::Combine($strFixtureRoot, 'empty-hooks')
    [void][IO.Directory]::CreateDirectory($strEmptyHooks)
    $arrNames = @('docs/caf' + [char]0x00e9 + '.md') + @('docs/space name.md', 'docs/[literal].md', 'docs/UPPER.md')
    try {
        & git -C $strFixtureRoot -c "init.templateDir=$strEmptyHooks" init --quiet
        if ($LASTEXITCODE -ne 0) { throw 'Git entry fixture initialization failed.' }
        foreach ($strName in $arrNames) {
            [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, $strName), "content:$strName", [Text.UTF8Encoding]::new($false))
        }
        [IO.File]::WriteAllBytes([IO.Path]::Combine($strFixtureRoot, 'docs/invalid.md'), [byte[]]@(255))
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'docs/executable.md'), 'executable', [Text.UTF8Encoding]::new($false))
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Git entry fixture indexing failed.' }
        & git -C $strFixtureRoot update-index --chmod=+x -- docs/executable.md
        if ($LASTEXITCODE -ne 0) { throw 'Git entry fixture mode setup failed.' }
        & git -C $strFixtureRoot -c user.name=Fixture -c user.email=fixture@example.invalid `
            -c commit.gpgsign=false -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=fixture
        if ($LASTEXITCODE -ne 0) { throw 'Git entry fixture commit failed.' }
        $strRevision = ([string](& git -C $strFixtureRoot rev-parse HEAD)).Trim()
        $strBlob = ([string](& git -C $strFixtureRoot rev-parse "${strRevision}:docs/UPPER.md")).Trim()
        & git -C $strFixtureRoot update-index --add --cacheinfo "120000,$strBlob,docs/link.md"
        if ($LASTEXITCODE -ne 0) { throw 'Git entry symlink-mode setup failed.' }
        & git -C $strFixtureRoot update-index --add --cacheinfo "160000,$strRevision,docs/submodule"
        if ($LASTEXITCODE -ne 0) { throw 'Git entry gitlink-mode setup failed.' }
        & git -C $strFixtureRoot -c user.name=Fixture -c user.email=fixture@example.invalid `
            -c commit.gpgsign=false -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=modes
        if ($LASTEXITCODE -ne 0) { throw 'Git entry mode fixture commit failed.' }
        $strRevision = ([string](& git -C $strFixtureRoot rev-parse HEAD)).Trim()
        foreach ($strName in $arrNames) {
            $strRead = Read-GitRevisionText -RepositoryRootPath $strFixtureRoot -Revision $strRevision `
                -RepositoryRelativePath $strName -MaximumBytes 4096 -RequireRegularFile
            if ($strRead -cne "content:$strName") { throw "Git entry exact content failed: $strName" }
        }
        foreach ($objCase in @(
                @{ Path = 'docs/missing.md'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs/upper.md'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs/executable.md'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs/link.md'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs/submodule'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs'; Limit = 4096; Revision = $strRevision; Failure = 'not one regular 100644 blob' },
                @{ Path = 'docs/invalid.md'; Limit = 4096; Revision = $strRevision; Failure = 'UTF-8' },
                @{ Path = 'docs/UPPER.md'; Limit = 1; Revision = $strRevision; Failure = 'must not exceed 1 byte' },
                @{ Path = 'docs/UPPER.md'; Limit = 4096; Revision = ('0' * 40); Failure = 'Could not inspect' }
            )) {
            $boolRejected = $false
            try {
                $null = Read-GitRevisionText -RepositoryRootPath $strFixtureRoot -Revision $objCase.Revision `
                    -RepositoryRelativePath $objCase.Path -MaximumBytes $objCase.Limit -RequireRegularFile
            } catch {
                if ($_.Exception.Message -notmatch $objCase.Failure) { throw }
                $boolRejected = $true
            }
            if (-not $boolRejected) { throw "Git entry negative control was accepted: $($objCase.Path)" }
        }
        # Metadata-only generated inspection must not decode even an invalid UTF-8 body.
        $strBinaryObject = Get-GitRegularFileBlobId -RepositoryRootPath $strFixtureRoot `
            -Revision $strRevision -RepositoryRelativePath 'docs/invalid.md'
        if ($strBinaryObject -cnotmatch '^[0-9a-f]{40}$') { throw 'Generated binary metadata-only inspection failed.' }
        foreach ($strName in $arrNames) {
            $strIndexObject = Get-GitRegularFileBlobId -RepositoryRootPath $strFixtureRoot -RepositoryRelativePath $strName
            $strTreeObject = Get-GitRegularFileBlobId -RepositoryRootPath $strFixtureRoot -Revision $strRevision -RepositoryRelativePath $strName
            if ($strIndexObject -cne $strTreeObject) { throw 'Exact generated index/tree identity mismatch.' }
        }
        foreach ($strName in @('docs/executable.md', 'docs/link.md', 'docs/submodule', 'docs/missing.md', 'docs/upper.md')) {
            $boolRejected = $false
            try { $null = Get-GitRegularFileBlobId -RepositoryRootPath $strFixtureRoot -RepositoryRelativePath $strName } catch {
                if ($_.Exception.Message -notmatch 'not one regular 100644 blob') { throw }
                $boolRejected = $true
            }
            if (-not $boolRejected) { throw "Generated index mode/path admitted: $strName" }
        }
        $strStageObject = Get-GitRegularFileBlobId -RepositoryRootPath $strFixtureRoot `
            -Revision $strRevision -RepositoryRelativePath 'docs/UPPER.md'
        $objIndexStartInfo = [Diagnostics.ProcessStartInfo]::new('git')
        $objIndexStartInfo.UseShellExecute = $false
        $objIndexStartInfo.RedirectStandardInput = $true
        foreach ($strArgument in @('-C', $strFixtureRoot, 'update-index', '--index-info')) {
            $objIndexStartInfo.ArgumentList.Add($strArgument)
        }
        $objIndexProcess = [Diagnostics.Process]::Start($objIndexStartInfo)
        try {
            $objIndexProcess.StandardInput.Write("0 $('0' * 40)`tdocs/UPPER.md`n100644 $strStageObject 1`tdocs/UPPER.md`n")
            $objIndexProcess.StandardInput.Close()
            if (-not $objIndexProcess.WaitForExit(10000) -or $objIndexProcess.ExitCode -ne 0) {
                throw 'Generated unmerged-index fixture setup failed.'
            }
        } finally { $objIndexProcess.Dispose() }
        $strStagedEntry = [string](& git -C $strFixtureRoot ls-files --stage -- docs/UPPER.md)
        if ($LASTEXITCODE -ne 0 -or $strStagedEntry -cne "100644 $strStageObject 1`tdocs/UPPER.md") {
            throw 'Generated unmerged-index fixture did not create its exact stage1 entry.'
        }
        $boolStageRejected = $false
        try { $null = Get-GitRegularFileBlobId -RepositoryRootPath $strFixtureRoot -RepositoryRelativePath 'docs/UPPER.md' } catch {
            if ($_.Exception.Message -notmatch 'not one regular 100644 blob') { throw }
            $boolStageRejected = $true
        }
        if (-not $boolStageRejected) { throw 'Generated nonzero index stage was admitted.' }
        & git -C $strFixtureRoot reset --quiet $strRevision -- docs/UPPER.md
        if ($LASTEXITCODE -ne 0) { throw 'Generated index fixture restoration failed.' }
        $scriptBlockActualProcessReader = ${function:Read-BoundedProcessData}
        $strProbePath = 'docs/probe.md'
        $strRecord = '100644 blob ' + ('a' * 40) + "`t$strProbePath" + [char]0
        $arrRecordCases = @(
            @{ Name = 'exact 40'; Data = $strRecord; Failure = '' },
            @{ Name = 'exact 64'; Data = $strRecord.Replace(('a' * 40), ('a' * 64)); Failure = '' },
            @{ Name = 'empty'; Data = ''; Failure = 'not one regular 100644 blob' },
            @{ Name = 'no NUL'; Data = $strRecord.TrimEnd([char]0); Failure = 'not one regular 100644 blob' },
            @{ Name = 'extra record'; Data = $strRecord + [char]0; Failure = 'not one regular 100644 blob' },
            @{ Name = 'wrong case'; Data = $strRecord.Replace('probe.md', 'PROBE.md'); Failure = 'not one regular 100644 blob' },
            @{ Name = 'wrong mode'; Data = $strRecord.Replace('100644', '100755'); Failure = 'not one regular 100644 blob' },
            @{ Name = 'wrong type'; Data = $strRecord.Replace('blob', 'tree'); Failure = 'not one regular 100644 blob' },
            @{ Name = 'bad object'; Data = $strRecord.Replace(('a' * 40), ('g' * 40)); Failure = 'not one regular 100644 blob' },
            @{ Name = 'invalid UTF8'; Data = ''; Bytes = [byte[]]@(255); Failure = 'UTF-8' },
            @{ Name = 'native failure'; Data = $strRecord; Program = 'exit 42'; Failure = 'Could not inspect' },
            @{ Name = 'overflow'; Data = ('x' * 256); Failure = 'must not exceed|exceeded' },
            @{ Name = 'timeout'; Data = ''; Program = 'Start-Sleep -Seconds 30'; Failure = 'timed out|canceled' }
        )
        foreach ($objRecordCase in $arrRecordCases) {
            & {
                function Read-BoundedProcessData {
                    param($Process, $MaximumBytes, $TimeoutMilliseconds, $DisplayName)
                    $arrArguments = @($Process.StartInfo.ArgumentList)
                    $boolTree = $arrArguments -ccontains 'ls-tree'
                    if ($boolTree -and ($arrArguments[0] -cne '--literal-pathspecs' -or
                            $arrArguments -cnotcontains '-z' -or $arrArguments -cnotcontains '--full-tree' -or
                            $arrArguments[-1] -cne $strProbePath -or $MaximumBytes -ne 91 -or $TimeoutMilliseconds -ne 10000)) {
                        throw 'Git entry bounded invocation contract changed.'
                    }
                    if (-not $boolTree -and ($arrArguments[-1] -cnotmatch '^a{40}(?:a{24})?$')) {
                        throw 'Git content was not bound to the inspected object.'
                    }
                    $arrData = [byte[]]@(if (-not $boolTree) { [Text.Encoding]::UTF8.GetBytes('content') } elseif ($objRecordCase.ContainsKey('Bytes')) {
                        $objRecordCase.Bytes
                    } else { [Text.Encoding]::UTF8.GetBytes($objRecordCase.Data) })
                    $strProgram = if ($boolTree -and $objRecordCase.ContainsKey('Program')) { $objRecordCase.Program } else {
                        '$b=[Convert]::FromBase64String(''' + [Convert]::ToBase64String($arrData) + ''');[Console]::OpenStandardOutput().Write($b,0,$b.Length)'
                    }
                    $Process.StartInfo.FileName = (Get-Process -Id $PID).Path
                    $Process.StartInfo.ArgumentList.Clear()
                    foreach ($strArgument in @('-NoProfile', '-NonInteractive', '-Command', $strProgram)) {
                        $Process.StartInfo.ArgumentList.Add($strArgument)
                    }
                    & $scriptBlockActualProcessReader -Process $Process -MaximumBytes $MaximumBytes `
                        -TimeoutMilliseconds $TimeoutMilliseconds -DisplayName $DisplayName
                }
                $strFailure = ''
                try {
                    $strRead = Read-GitRevisionText -RepositoryRootPath $strFixtureRoot -Revision $strRevision `
                        -RepositoryRelativePath $strProbePath -MaximumBytes 4096 -RequireRegularFile
                    if ($strRead -cne 'content') { throw 'Controlled Git content changed.' }
                } catch { $strFailure = $_.Exception.Message }
                if (($objRecordCase.Failure -ceq '' -and $strFailure -cne '') -or
                    ($objRecordCase.Failure -cne '' -and $strFailure -notmatch $objRecordCase.Failure)) {
                    throw "Git entry transport control failed ($($objRecordCase.Name)): $strFailure"
                }
            }
        }
    } finally {
        $strResolvedFixtureRoot = [IO.Path]::GetFullPath($strFixtureRoot)
        if ($strResolvedFixtureRoot.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -and
            $strResolvedFixtureRoot -cne $strTempRoot -and [IO.Directory]::Exists($strResolvedFixtureRoot)) {
            Remove-Item -LiteralPath $strResolvedFixtureRoot -Recurse -Force
        }
    }
}

function Assert-PublishedBaselineCapacitySelfTest {
    # .SYNOPSIS
    # Separates current instruction capacity from complete historical metadata.
    #
    # .DESCRIPTION
    # Uses real regular Git blobs for both parent callers and exact bound,
    # path, mode, encoding and metadata-version negative controls.
    #
    # .PARAMETER MaximumMetadataUtcDate
    # The trusted current date used in the metadata transition fixture.
    #
    # .EXAMPLE
    # Assert-PublishedBaselineCapacitySelfTest -MaximumMetadataUtcDate '2026-10-04'
    #
    # # Throws if historical compatibility weakens current admission.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # None. Failed controls throw.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Positional parameters are disabled; callers use named arguments.
    # Version: 1.1.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $MaximumMetadataUtcDate)

    $strTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = [IO.Path]::Combine($strTempRoot, 'agent-parent-capacity-' + [Guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($strFixtureRoot)
    $strEmptyHooks = [IO.Path]::Combine($strFixtureRoot, 'empty-hooks')
    [void][IO.Directory]::CreateDirectory($strEmptyHooks)
    $strHeader = "# Historical instructions`n`n**Version:** 1.7.20261001.0`n`n## Metadata`n`n- **Status:** Active`n- **Owner:** Fixture`n- **Last Updated:** 2026-10-01`n- **Scope:** Parent comparison.`n`n## Procedure`n`n"
    $strParent = $strHeader + ('x' * (65536 - [Text.Encoding]::UTF8.GetByteCount($strHeader)))
    try {
        & git -C $strFixtureRoot -c "init.templateDir=$strEmptyHooks" init --quiet
        if ($LASTEXITCODE -ne 0) {
            throw 'Parent capacity fixture initialization failed.'
        }
        foreach ($strPath in @('AGENTS.md', 'OTHER.md')) {
            [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, $strPath), $strParent, [Text.UTF8Encoding]::new($false))
        }
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) {
            throw 'Parent capacity fixture indexing failed.'
        }
        $strParentBlob = [string](& git -C $strFixtureRoot hash-object -- AGENTS.md)
        if ($LASTEXITCODE -ne 0) {
            throw 'Parent capacity blob lookup failed.'
        }
        & git -C $strFixtureRoot update-index --add --cacheinfo "100644,$($strParentBlob.Trim()),agents.md"
        if ($LASTEXITCODE -ne 0) {
            throw 'Case-variant parent fixture indexing failed.'
        }
        & git -C $strFixtureRoot -c user.name=Fixture -c user.email=fixture@example.invalid `
            -c commit.gpgsign=false -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=parent
        if ($LASTEXITCODE -ne 0) {
            throw 'Parent capacity fixture commit failed.'
        }
        $strRevision = [string](& git -C $strFixtureRoot rev-parse HEAD)
        if ($LASTEXITCODE -ne 0) {
            throw 'Parent capacity revision lookup failed.'
        }
        $strRevision = $strRevision.Trim()
        $strCurrent = $strHeader.Replace('2026-10-01', $MaximumMetadataUtcDate).Replace('20261001', $MaximumMetadataUtcDate.Replace('-', '')) + "Current procedure.`n"
        [IO.File]::WriteAllText([IO.Path]::Combine($strFixtureRoot, 'AGENTS.md'), $strCurrent, [Text.UTF8Encoding]::new($false))
        $strExplicitParent = Read-PublishedBaselineDocumentText -RepositoryRootPath $strFixtureRoot `
            -Revision $strRevision -RepositoryRelativePath 'AGENTS.md' -CurrentMaximumBytes 32768
        $strCheckerPath = (Get-Command -Name Get-PublishedBaselineDocumentContext -CommandType Function).ScriptBlock.File
        $objLocalParent = Invoke-AgentInstructionFixtureClock -CheckerPath $strCheckerPath `
            -UtcNow ([DateTimeOffset]::Parse($MaximumMetadataUtcDate + 'T00:00:00Z')) -LocalOnly -RequireLocal -Action {
            Get-PublishedBaselineDocumentContext -RepositoryRootPath $strFixtureRoot `
                -RepositoryRelativePath 'AGENTS.md' -MaximumBytes 32768
        }
        if ($strExplicitParent -cne $strParent -or $objLocalParent.ParentContent -cne $strParent -or
            -not $objLocalParent.IsWorktreeTransition -or $objLocalParent.ExpectedUtcDate -cne $MaximumMetadataUtcDate) {
            throw 'Complete historical metadata did not survive both parent callers.'
        }
        if (@(Get-PublishedEndpointMetadataFailure -Name 'AGENTS.md' -CurrentContent $strCurrent `
                    -ParentContent $strExplicitParent -ExpectedUtcDate $MaximumMetadataUtcDate -IsNewDocumentTransition $false).Count -ne 0) {
            throw 'Valid shrinking metadata transition was rejected.'
        }
        foreach ($objCase in @(
                @{ Current = $strCurrent.Replace('1.7.', '0.7.'); Parent = $strExplicitParent },
                @{ Current = $strCurrent; Parent = $strExplicitParent.Replace('2026-10-01', 'invalid-date') }
            )) {
            if (@(Get-PublishedEndpointMetadataFailure -Name 'AGENTS.md' -CurrentContent $objCase.Current `
                        -ParentContent $objCase.Parent -ExpectedUtcDate $MaximumMetadataUtcDate -IsNewDocumentTransition $false).Count -eq 0) {
                throw 'Historical compatibility discarded a real parent metadata failure.'
            }
        }
        foreach ($objCase in @(
                @{ Path = 'OTHER.md'; Failure = 'must not exceed 32768' },
                @{ Path = 'agents.md'; Failure = 'must not exceed 32768' },
                @{ Path = 'missing.md'; Failure = 'not one regular 100644 blob' }
            )) {
            $boolRejected = $false
            try {
                $null = Read-PublishedBaselineDocumentText -RepositoryRootPath $strFixtureRoot `
                    -Revision $strRevision -RepositoryRelativePath $objCase.Path -CurrentMaximumBytes 32768
            } catch {
                if ($_.Exception.Message -notmatch $objCase.Failure) {
                    throw
                }
                $boolRejected = $true
            }
            if (-not $boolRejected) {
                throw "Historical capacity expanded another path: $($objCase.Path)"
            }
        }
        # The current revision reader still rejects the larger historical blob.
        $boolCurrentRejected = $false
        try {
            $null = Read-GitRevisionText -RepositoryRootPath $strFixtureRoot -Revision $strRevision `
                -RepositoryRelativePath 'AGENTS.md' -MaximumBytes $intAgentsMaximumInputBytes -RequireRegularFile
        } catch {
            if ($_.Exception.Message -notmatch 'must not exceed 32768') {
                throw
            }
            $boolCurrentRejected = $true
        }
        if (-not $boolCurrentRejected) {
            throw 'Historical capacity widened the current instruction reader.'
        }
        # Remove the case-only index alias before changing the Windows worktree file.
        & git -C $strFixtureRoot update-index --force-remove -- agents.md
        if ($LASTEXITCODE -ne 0) {
            throw 'Case-variant parent fixture cleanup failed.'
        }
        foreach ($strMode in @('current-overflow', 'parent-overflow', 'invalid-utf8', 'executable')) {
            [byte[]] $arrBytes = if ($strMode -ceq 'invalid-utf8') {
                [byte[]]@(255)
            } else {
                [Text.Encoding]::UTF8.GetBytes('x' * $(if ($strMode -ceq 'parent-overflow') { 65537 } else { 32769 }))
            }
            [IO.File]::WriteAllBytes([IO.Path]::Combine($strFixtureRoot, 'AGENTS.md'), $arrBytes)
            & git -C $strFixtureRoot -c core.autocrlf=false add -- AGENTS.md
            if ($LASTEXITCODE -ne 0) {
                throw 'Capacity negative fixture indexing failed.'
            }
            if ($strMode -ceq 'executable') {
                & git -C $strFixtureRoot update-index --chmod=+x -- AGENTS.md
                if ($LASTEXITCODE -ne 0) {
                    throw 'Capacity negative fixture mode setup failed.'
                }
            }
            & git -C $strFixtureRoot -c user.name=Fixture -c user.email=fixture@example.invalid `
                -c commit.gpgsign=false -c "core.hooksPath=$strEmptyHooks" commit --quiet --no-gpg-sign --message=$strMode
            if ($LASTEXITCODE -ne 0) {
                throw 'Capacity negative fixture commit failed.'
            }
            $strNegativeRevision = [string](& git -C $strFixtureRoot rev-parse HEAD)
            if ($LASTEXITCODE -ne 0) {
                throw 'Capacity negative revision lookup failed.'
            }
            $strNegativeRevision = $strNegativeRevision.Trim()
            $intBlobSize = [int](& git -C $strFixtureRoot cat-file -s "${strNegativeRevision}:AGENTS.md")
            if ($LASTEXITCODE -ne 0 -or $intBlobSize -ne $arrBytes.Length) {
                throw 'Capacity negative fixture did not publish the intended raw bytes.'
            }
            $boolRejected = $false
            try {
                if ($strMode -ceq 'current-overflow') {
                    $null = Read-RepositoryInputData -RepositoryRootPath $strFixtureRoot `
                        -Path ([IO.Path]::Combine($strFixtureRoot, 'AGENTS.md')) -RepositoryRelativePath 'AGENTS.md' `
                        -DisplayName 'current AGENTS.md' -MaximumBytes $intAgentsMaximumInputBytes -RequireIndexContentMatch
                } else {
                    $null = Read-PublishedBaselineDocumentText -RepositoryRootPath $strFixtureRoot `
                        -Revision $strNegativeRevision -RepositoryRelativePath 'AGENTS.md' -CurrentMaximumBytes 32768
                }
            } catch {
                $strExpected = switch ($strMode) {
                    'current-overflow' {
                        'must not exceed 32768'
                    }
                    'parent-overflow' {
                        'must not exceed 65536'
                    }
                    'invalid-utf8' {
                        'UTF-8'
                    }
                    'executable' {
                        'not one regular 100644 blob'
                    }
                }
                if ($_.Exception.Message -notmatch $strExpected) {
                    throw
                }
                $boolRejected = $true
            }
            if (-not $boolRejected) {
                throw "Historical capacity negative control was accepted: $strMode"
            }
        }
    } finally {
        $strResolvedFixtureRoot = [IO.Path]::GetFullPath($strFixtureRoot)
        if ($strResolvedFixtureRoot.StartsWith($strTempRoot, [StringComparison]::OrdinalIgnoreCase) -and
            $strResolvedFixtureRoot -cne $strTempRoot -and [IO.Directory]::Exists($strResolvedFixtureRoot)) {
            Remove-Item -LiteralPath $strResolvedFixtureRoot -Recurse -Force
        }
    }
}

function Assert-AgentSetupSelfTest {
    # .SYNOPSIS
    # Tests actual setup inputs, finite contracts and staged-reader closure.
    #
    # .DESCRIPTION
    # Runs positive and weakening controls through production helpers from the
    # separate SelfTest child. Private Git fixtures never mutate the source.
    #
    # .PARAMETER RepositoryRootPath
    # The repository whose actual setup texts supply the positive control.
    #
    # .EXAMPLE
    # Assert-AgentSetupSelfTest -RepositoryRootPath $RepositoryRootPath
    #
    # # Throws when a setup contract or staged closure regression is accepted.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [void] No output. Throws when a control fails.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.1.20261006.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param([Parameter(Mandatory)][string] $RepositoryRootPath)
    $setEmpty = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    $hashtableContent = Read-AgentSetupInputContent -RepositoryRootPath $RepositoryRootPath `
        -Revision '' -StagedInputPaths $setEmpty
    $arrPositive = @(Get-AgentSetupContractFailure -Content $hashtableContent)
    if ($arrPositive.Count) { throw "Actual setup positive control failed: $($arrPositive -join '; ')" }
    $scriptblockReject = {
        param([string] $Name, [string] $Path, [string] $Text, [string] $Expected)
        if ($Text -ceq $hashtableContent[$Path]) { throw "Setup mutation did not change input: $Name" }
        $hashtableMutation = $hashtableContent.Clone()
        $hashtableMutation[$Path] = $Text
        $arrFailures = @(Get-AgentSetupContractFailure -Content $hashtableMutation)
        if (-not ($arrFailures -match $Expected)) {
            throw "Setup mutation was not rejected by its contract: $Name ($($arrFailures -join '; '))"
        }
    }
    foreach ($arrMutation in @(
            ,@('package.json', 'node .github/workflows/NpmTools.mjs install', 'npm ci', 'Setup package command')
            ,@('package.json', 'npm --prefix .github/workflows run lint:md"', 'node bypass.mjs"', 'Setup package command')
            ,@('package.json', 'npm --prefix .github/workflows run lint:md:nested', 'node bypass.mjs', 'Setup package command')
            ,@('package.json', '.github/workflows/Test-AgentInstructions.ps1 -SelfTest', 'true', 'Setup package command')
            ,@('package.json', '"scripts": {', '"Scripts": {', 'exact scripts object')
            ,@('package.json', '"scripts": {', '"scripts": null, "scripts": {', 'strict unambiguous JSON')
            ,@('package.json', '"scripts": {', '"scripts": null, "Scripts": {', 'strict unambiguous JSON')
            ,@('package.json', '"devDependencies": {', '"devDependencies": {"markdownlint":"0.41.1",', 'must not declare direct markdownlint')
            ,@('package.json', '"devDependencies": {', '"devDependencies": {"markdownlint-cli2":"0.23.2",', 'must not declare direct markdownlint-cli2')
            ,@('.github/workflows/package.json', 'node lint-markdown.mjs', 'node lint-nested-markdown.js --outer', 'Setup package command')
            ,@('.github/workflows/package.json', '"lint:md:nested": "node lint-nested-markdown.js",', '', 'Setup package command.*\.github/workflows/package\.json scripts\.lint:md:nested')
            ,@('.github/workflows/package.json', 'node lint-nested-markdown.js', 'node -e 0', 'Setup package command.*\.github/workflows/package\.json scripts\.lint:md:nested')
            ,@('.github/workflows/package.json', 'node install-husky.mjs', 'node install-husky.mjs || true', 'Setup package command')
            ,@('.husky/pre-commit', " '*.mdc'", '', 'reviewed guard/lint phase')
            ,@('.husky/pre-commit', '--diff-filter=ACMR', '--diff-filter=ACM', 'reviewed guard/lint phase')
            ,@('.husky/pre-commit', 'if node .github/workflows/lint-staged-markdown.mjs; then', 'if true; then', 'reviewed guard/lint phase')
            ,@('.husky/pre-commit', 'if npm --prefix .github/workflows run lint:md:nested; then', 'if true; then', 'reviewed guard/lint phase')
            ,@('.pre-commit-config.yaml', '011a6d15e749bb3f2d771eed9c7aa0e7e3e10ee7', 'v1.7.12', 'full lowercase commit pin')
            ,@('.pre-commit-config.yaml', 'repo: local', 'repo: https://example.invalid/python-hooks', 'two local groups')
            ,@('.pre-commit-config.yaml', 'language: system', 'language: python', 'separate dependency environment')
            ,@('.pre-commit-config.yaml', '-Module yamllint', '-Module pip', 'reviewed system launcher/module')
            ,@('.pre-commit-config.yaml', 'files: ^.*\.ya?ml$', 'files: ^docs/.*\.ya?ml$', 'all repository YAML')
            ,@('.pre-commit-config.yaml', '\.github/document-metadata-classification\.json', 'unrelated\.json', 'select the classification manifest')
            ,@('.pre-commit-config.yaml', 'files: ^(\.github/workflows/lint-staged-markdown\.mjs|.*\.(md|mdc))$', 'files: ^.*\.(md|mdc)$', 'reviewed activation and selector')
            ,@('.pre-commit-config.yaml', ' -RequireStagedInputMatch', '', 'reviewed activation and selector')
            ,@('requirements-dev.txt', 'pre-commit==4.6.2', 'pre-commit>=4.6.2', 'Python requirements')
            ,@('requirements-dev.txt', '--require-hashes', '', 'Python requirements')
            ,@('requirements-dev.txt', '--only-binary=:all:', '', 'Python requirements')
            ,@('requirements-dev.txt', '    --hash=sha256:a8dc6b26ad22ff227d2634a65cb388215ce6cc96bbcc5cfde7641ae87e8dacc0', '', 'Python requirements')
            ,@('requirements-dev.txt', 'check-jsonschema==', 'other-package==', 'Python requirements')
            ,@('requirements-dev.txt', 'attrs==26.1.0', 'cfgv==26.1.0', 'Python requirements')
        )) {
        & $scriptblockReject ($arrMutation[1] + ' near miss') $arrMutation[0] `
            ($hashtableContent[$arrMutation[0]].Replace($arrMutation[1], $arrMutation[2])) $arrMutation[3]
    }
    $strPackage = $hashtableContent['package.json']
    & $scriptblockReject 'nonobject package' 'package.json' '[]' 'strict unambiguous JSON'
    & $scriptblockReject 'non-string command' 'package.json' `
        ($strPackage.Replace('"npm --prefix .github/workflows run lint:md"', 'true')) 'Setup package command'
    & $scriptblockReject 'extra unparsed lock data' 'requirements-dev.txt' `
        ($hashtableContent['requirements-dev.txt'] + "`n--extra-index-url https://example.invalid/simple`n") 'Python requirements'
    $strHook = $hashtableContent['.husky/pre-commit']
    $strOuter = 'if npm --prefix .github/workflows run lint:md; then'
    $strNested = 'if npm --prefix .github/workflows run lint:md:nested; then'
    & $scriptblockReject 'reordered phases' '.husky/pre-commit' `
        ($strHook.Replace($strOuter, 'SWAP_PHASE').Replace($strNested, $strOuter).Replace('SWAP_PHASE', $strNested)) `
        'reviewed guard/lint phase'
    & $scriptblockReject 'duplicate phase' '.husky/pre-commit' ($strHook + "`n$strOuter`n") 'reviewed guard/lint phase'
    & $scriptblockReject 'separate extra dependencies' '.pre-commit-config.yaml' `
        ($hashtableContent['.pre-commit-config.yaml'] + "`n        additional_dependencies: []`n") 'separate dependency environment'
    & $scriptblockReject 'extra hook group' '.pre-commit-config.yaml' `
        ($hashtableContent['.pre-commit-config.yaml'] + "`n  - repo: local`n    hooks: []`n") 'two local groups'
    $strReviewSetupPath = '.github/workflows/copilot-code-review.yml'
    if (-not $hashtableContent.ContainsKey($strReviewSetupPath)) {
        # Historical absence is valid, but both present-file security contracts
        # must still be tested in the private fixture on historical source trees.
        $hashtableContent[$strReviewSetupPath] = $hashtableContent['.github/workflows/copilot-setup-steps.yml']
    }
    foreach ($strSetupPath in @('.github/workflows/copilot-setup-steps.yml', $strReviewSetupPath)) {
        $strSetup = $hashtableContent[$strSetupPath]
        foreach ($strProjection in @(
                'GITHUB_TOKEN: value', 'GH_TOKEN: value', 'ACTIONS_RUNTIME_TOKEN: value'
                'ALIAS: ${{ github.token }}', "ALIAS: `${{ github['token'] }}"
                'ALIAS: ${{ secrets.TOKEN }}', 'ALIAS: ${{ toJSON(github) }}'
            )) {
            & $scriptblockReject 'credential projection' $strSetupPath `
                ($strSetup + "`n        env:`n          $strProjection`n") 'must not project credentials'
        }
        & $scriptblockReject 'action step' $strSetupPath `
            ($strSetup + "`n      - uses: actions/checkout@v4`n") 'must not execute an action'
        $hashtableHarmless = $hashtableContent.Clone()
        $hashtableHarmless[$strSetupPath] += "`n        env:`n          REVISION: `${{ github.sha }}`n"
        if (@(Get-AgentSetupContractFailure -Content $hashtableHarmless).Count) {
            throw 'Harmless setup revision expression was rejected.'
        }
    }
    $strIndex = $hashtableContent['.github/workflows/scripts-README.md']
    foreach ($arrNearMiss in @(
            ,@('--isolated install', 'install')
            ,@('--require-hashes ', '')
            ,@('--only-binary=:all: ', '')
            ,@('https://pypi.org/simple', 'https://example.invalid/simple')
            ,@('-r requirements-dev.txt', '-r other-requirements.txt')
            ,@('py -3.12 -m pip', 'py -3.11 -m pip')
            ,@('python3.12 -m pip', 'python3.11 -m pip')
            ,@('py -3.12 -m pre_commit run --all-files', 'pre-commit run --all-files')
            ,@('python3.12 -m pre_commit run --all-files', 'pre-commit run --all-files')
            ,@('-lt 7', '-lt 6')
        )) {
        & $scriptblockReject ('bootstrap ' + $arrNearMiss[0]) '.github/workflows/scripts-README.md' `
            ($strIndex.Replace($arrNearMiss[0], $arrNearMiss[1])) 'Script index must contain'
    }
    $strRunSpan = '`py -3.12 -m pre_commit run --all-files`'
    foreach ($strReplacement in @('', "<!-- $strRunSpan -->", "~~$strRunSpan~~", "$strRunSpan $strRunSpan")) {
        & $scriptblockReject 'missing hidden deleted or duplicate span' '.github/workflows/scripts-README.md' `
            ($strIndex.Replace($strRunSpan, $strReplacement)) 'Script index must contain'
    }
    $strTemporaryRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = Join-Path $strTemporaryRoot ('agent-setup-' + [Guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($strFixtureRoot)
    $objEncoding = [Text.UTF8Encoding]::new($false)
    try {
        & git -C $strFixtureRoot init --quiet
        if ($LASTEXITCODE -ne 0) { throw 'Setup fixture initialization failed.' }
        foreach ($strPath in $hashtableContent.Keys) {
            $strTarget = Join-Path $strFixtureRoot $strPath
            [void][IO.Directory]::CreateDirectory([IO.Path]::GetDirectoryName($strTarget))
            [IO.File]::WriteAllText($strTarget, $hashtableContent[$strPath], $objEncoding)
        }
        & git -C $strFixtureRoot -c core.autocrlf=false add --all
        if ($LASTEXITCODE -ne 0) { throw 'Setup fixture indexing failed.' }
        & git -C $strFixtureRoot -c user.name=Fixture -c user.email=fixture@example.invalid `
            -c core.hooksPath=/dev/null -c commit.gpgsign=false commit --quiet -m setup
        if ($LASTEXITCODE -ne 0) { throw 'Setup fixture baseline failed.' }
        $strBaseline = ([string](& git -C $strFixtureRoot rev-parse HEAD)).Trim()
        if ($LASTEXITCODE -ne 0) { throw 'Setup fixture revision failed.' }
        $hashtableRevision = Read-AgentSetupInputContent -RepositoryRootPath $strFixtureRoot `
            -Revision $strBaseline -StagedInputPaths $setEmpty
        foreach ($strPath in $hashtableContent.Keys) {
            if ($hashtableRevision[$strPath] -cne $hashtableContent[$strPath]) {
                throw "Setup immutable revision did not preserve input: $strPath"
            }
            $strTarget = Join-Path $strFixtureRoot $strPath
            [IO.File]::AppendAllText($strTarget, "`n", $objEncoding)
            & git -C $strFixtureRoot -c core.autocrlf=false add -- $strPath
            if ($LASTEXITCODE -ne 0) { throw 'Setup staged change failed.' }
            $setStaged = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
            foreach ($strStaged in @(Read-GitStagedInputPath -RepositoryRootPath $strFixtureRoot -MaximumBytes 1048576)) {
                [void]$setStaged.Add($strStaged)
            }
            if ($setStaged.Count -ne 1 -or -not $setStaged.Contains($strPath)) {
                throw "Setup helper-only staged set differs: $strPath"
            }
            $null = Read-AgentSetupInputContent -RepositoryRootPath $strFixtureRoot -Revision '' -StagedInputPaths $setStaged
            [IO.File]::AppendAllText($strTarget, "worktree-only`n", $objEncoding)
            $boolRejected = $false
            try {
                $null = Read-AgentSetupInputContent -RepositoryRootPath $strFixtureRoot -Revision '' -StagedInputPaths $setStaged
            } catch {
                if (-not $_.Exception.Message.Contains('must match its staged Git index blob.', [StringComparison]::Ordinal)) { throw }
                $boolRejected = $true
            }
            if (-not $boolRejected) { throw "Setup partial staging was accepted: $strPath" }
            $null = Read-AgentSetupInputContent -RepositoryRootPath $strFixtureRoot -Revision '' -StagedInputPaths $setEmpty
            [IO.File]::WriteAllText($strTarget, $hashtableContent[$strPath], $objEncoding)
            & git -C $strFixtureRoot -c core.autocrlf=false add -- $strPath
            if ($LASTEXITCODE -ne 0) { throw 'Setup fixture restoration failed.' }
        }
        foreach ($strMissing in @('requirements-dev.txt', '.github/workflows/Invoke-LockedPythonHook.ps1')) {
            $strTarget = Join-Path $strFixtureRoot $strMissing
            [IO.File]::Delete($strTarget)
            $boolRejected = $false
            try {
                $null = Read-AgentSetupInputContent -RepositoryRootPath $strFixtureRoot -Revision '' -StagedInputPaths $setEmpty
            } catch { $boolRejected = $true }
            if (-not $boolRejected) { throw "Required installed setup input was silently omitted: $strMissing" }
            [IO.File]::WriteAllText($strTarget, $hashtableContent[$strMissing], $objEncoding)
        }
        foreach ($strBoundPath in @('.github/workflows/copilot-setup-steps.yml', $strReviewSetupPath)) {
            $objBoundSpec = @(Get-AgentSetupInputSpec | Where-Object { $_.Path -ceq $strBoundPath })
            if ($objBoundSpec.Count -ne 1 -or $objBoundSpec[0].MaximumBytes -ne 65536) { throw 'Setup workflow read bound changed.' }
            foreach ($intExtra in @(0, 1)) {
                [IO.File]::WriteAllText((Join-Path $strFixtureRoot $strBoundPath), ('a' * (65536 + $intExtra)), $objEncoding)
                $boolRejected = $false
                try {
                    $hashtableBound = Read-AgentSetupInputContent -RepositoryRootPath $strFixtureRoot -Revision '' -StagedInputPaths $setEmpty
                    if ($hashtableBound[$strBoundPath].Length -ne 65536) { throw 'Setup bound did not preserve bytes.' }
                } catch {
                    if ($intExtra -eq 0 -or $_.Exception.Message -notmatch 'must not exceed') { throw }
                    $boolRejected = $true
                }
                if ($intExtra -eq 1 -and -not $boolRejected) { throw 'One-byte oversized setup input was accepted.' }
            }
            [IO.File]::WriteAllText((Join-Path $strFixtureRoot $strBoundPath),
                $hashtableContent[$strBoundPath], $objEncoding)
        }
        $strReviewTarget = Join-Path $strFixtureRoot $strReviewSetupPath
        $scriptblockRejectRead = {
            param([string] $Name, [string] $Revision, [Collections.Generic.HashSet[string]] $Staged,
                [string] $Expected)
            $boolRejected = $false
            try {
                $null = Read-AgentSetupInputContent -RepositoryRootPath $strFixtureRoot `
                    -Revision $Revision -StagedInputPaths $Staged
            } catch {
                if ($_.Exception.Message -notmatch $Expected) { throw }
                $boolRejected = $true
            }
            if (-not $boolRejected) { throw "Optional setup negative control was accepted: $Name" }
        }
        [IO.File]::Delete($strReviewTarget)
        & $scriptblockRejectRead 'indexed missing worktree' '' $setEmpty 'does not exist|Cannot find path'
        & git -C $strFixtureRoot rm --quiet --cached -- $strReviewSetupPath
        if ($LASTEXITCODE -ne 0) { throw 'Optional setup fixture index removal failed.' }
        $hashtableAbsent = Read-AgentSetupInputContent -RepositoryRootPath $strFixtureRoot `
            -Revision '' -StagedInputPaths $setEmpty
        if ($hashtableAbsent.ContainsKey($strReviewSetupPath)) { throw 'Absent review setup produced content.' }
        $boolStrictRejected = $false
        try {
            $null = Get-GitRegularFileBlobId -RepositoryRootPath $strFixtureRoot `
                -RepositoryRelativePath $strReviewSetupPath
        } catch {
            if ($_.Exception.Message -notmatch 'not one regular 100644 blob') { throw }
            $boolStrictRejected = $true
        }
        if (-not $boolStrictRejected) { throw 'Default Git entry admission silently allowed absence.' }
        $setMissingStaged = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
        [void]$setMissingStaged.Add($strReviewSetupPath)
        & $scriptblockRejectRead 'staged-set entry missing from index' '' $setMissingStaged 'absent from the Git index'
        & git -C $strFixtureRoot -c user.name=Fixture -c user.email=fixture@example.invalid `
            -c core.hooksPath=/dev/null -c commit.gpgsign=false commit --quiet -m historical-absence
        if ($LASTEXITCODE -ne 0) { throw 'Historical setup fixture commit failed.' }
        $strAbsentRevision = ([string](& git -C $strFixtureRoot rev-parse HEAD)).Trim()
        if ($LASTEXITCODE -ne 0) { throw 'Historical setup fixture revision failed.' }
        $hashtableAbsentRevision = Read-AgentSetupInputContent -RepositoryRootPath $strFixtureRoot `
            -Revision $strAbsentRevision -StagedInputPaths $setEmpty
        if ($hashtableAbsentRevision.ContainsKey($strReviewSetupPath)) { throw 'Historical absent review setup produced content.' }
        $hashtableOriginalRevision = Read-AgentSetupInputContent -RepositoryRootPath $strFixtureRoot `
            -Revision $strBaseline -StagedInputPaths $setEmpty
        if ($hashtableOriginalRevision[$strReviewSetupPath] -cne $hashtableContent[$strReviewSetupPath]) {
            throw 'Historical absence changed the immutable present-file input.'
        }
        [IO.File]::WriteAllText($strReviewTarget, $hashtableContent[$strReviewSetupPath], $objEncoding)
        & $scriptblockRejectRead 'untracked or residual deleted file' '' $setEmpty 'Repository input is unsafe'
        [IO.File]::Delete($strReviewTarget)
        [void][IO.Directory]::CreateDirectory($strReviewTarget)
        & $scriptblockRejectRead 'directory instead of absent optional file' '' $setEmpty 'Repository input is unsafe'
        [IO.Directory]::Delete($strReviewTarget)
        [IO.File]::WriteAllText($strReviewTarget, $hashtableContent[$strReviewSetupPath], $objEncoding)
        & git -C $strFixtureRoot -c core.autocrlf=false add -- $strReviewSetupPath
        if ($LASTEXITCODE -ne 0) { throw 'Optional setup fixture restoration failed.' }
        [IO.File]::WriteAllBytes($strReviewTarget, [byte[]]@(255))
        & $scriptblockRejectRead 'invalid UTF-8' '' $setEmpty 'UTF-8'
        [IO.File]::WriteAllText($strReviewTarget, $hashtableContent[$strReviewSetupPath], $objEncoding)
        $strReviewBlob = Get-GitRegularFileBlobId -RepositoryRootPath $strFixtureRoot `
            -RepositoryRelativePath $strReviewSetupPath
        & git -C $strFixtureRoot update-index --cacheinfo "120000,$strReviewBlob,$strReviewSetupPath"
        if ($LASTEXITCODE -ne 0) { throw 'Optional setup nonregular fixture index failed.' }
        & $scriptblockRejectRead 'nonregular index entry' '' $setEmpty 'not one regular 100644 blob'
        $strNonregularTree = ([string](& git -C $strFixtureRoot write-tree)).Trim()
        if ($LASTEXITCODE -ne 0) { throw 'Optional setup nonregular fixture tree failed.' }
        & $scriptblockRejectRead 'nonregular immutable entry' $strNonregularTree $setEmpty 'not one regular 100644 blob'
        & git -C $strFixtureRoot update-index --cacheinfo "100644,$strReviewBlob,$strReviewSetupPath"
        if ($LASTEXITCODE -ne 0) { throw 'Optional setup regular fixture index restoration failed.' }
    } finally {
        if ([IO.Path]::GetDirectoryName($strFixtureRoot).TrimEnd([IO.Path]::DirectorySeparatorChar) -cne
            $strTemporaryRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) -or
            -not [IO.Path]::GetFileName($strFixtureRoot).StartsWith('agent-setup-', [StringComparison]::Ordinal)) {
            throw 'Refusing setup fixture cleanup outside its private temporary root.'
        }
        Remove-Item -LiteralPath $strFixtureRoot -Recurse -Force
    }
}

function Assert-StagedInputSelfTest {
    # .SYNOPSIS
    # Tests staged matching against a real private Git index.
    #
    # .DESCRIPTION
    # Checks partial staging, helper-only changes, ordinal content, index modes,
    # native failure and byte bounds without changing the source repository.
    #
    # .EXAMPLE
    # Assert-StagedInputSelfTest
    #
    # # Throws if a retained staged-input boundary fails.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [void] No output. Throws on a failed fixture.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; there are no parameters.
    # Version: 1.0.20261003.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param()
    $strTemporaryRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strFixtureRoot = [IO.Path]::Combine($strTemporaryRoot, 'staged-input-' + [Guid]::NewGuid().ToString('N'))
    [void][IO.Directory]::CreateDirectory($strFixtureRoot)
    $strFixturePath = [IO.Path]::Combine($strFixtureRoot, 'input name.md')
    $objEncoding = [Text.UTF8Encoding]::new($false)
    $hashtableReader = @{
        Path = $strFixturePath; RepositoryRootPath = $strFixtureRoot
        RepositoryRelativePath = 'input name.md'; DisplayName = 'staged fixture'; MaximumBytes = 128
    }
    try {
        & git -C $strFixtureRoot init --quiet
        if ($LASTEXITCODE -ne 0) { throw 'Staged fixture initialization failed.' }
        [IO.File]::WriteAllText($strFixturePath, "accepted`n", $objEncoding)
        & git -C $strFixtureRoot -c core.autocrlf=false add -- 'input name.md'
        if ($LASTEXITCODE -ne 0) { throw 'Staged fixture indexing failed.' }
        $arrStagedPaths = @(Read-GitStagedInputPath -RepositoryRootPath $strFixtureRoot -MaximumBytes 4096)
        if ($arrStagedPaths.Count -ne 1 -or $arrStagedPaths[0] -cne 'input name.md') {
            throw 'The staged query did not retain the exact added path.'
        }
        $arrMatchedBytes = [byte[]]@(Read-RepositoryInputData @hashtableReader -RequireIndexContentMatch)
        if ([Text.Encoding]::UTF8.GetString($arrMatchedBytes) -cne "accepted`n") {
            throw 'Matching staged content was not returned intact.'
        }
        foreach ($strPartialContent in @("ACCEPTED`n", "worktree-only repair`n")) {
            [IO.File]::WriteAllText($strFixturePath, $strPartialContent, $objEncoding)
            $boolRejected = $false
            try { $null = Read-RepositoryInputData @hashtableReader -RequireIndexContentMatch } catch {
                if (-not $_.Exception.Message.Contains('must match its staged Git index blob.', [StringComparison]::Ordinal)) {
                    throw
                }
                $boolRejected = $true
            }
            if (-not $boolRejected) { throw 'Partial staging or ordinal content mismatch was accepted.' }
            $arrUnmatchedBytes = [byte[]]@(Read-RepositoryInputData @hashtableReader)
            if ([Text.Encoding]::UTF8.GetString($arrUnmatchedBytes) -cne $strPartialContent) {
                throw 'Ordinary local validation lost its worktree input semantics.'
            }
        }
        [IO.File]::WriteAllText($strFixturePath, "accepted`n", $objEncoding)
        & git -C $strFixtureRoot -c user.name=Fixture -c user.email=fixture@example.invalid `
            -c core.hooksPath=/dev/null -c commit.gpgsign=false commit --quiet -m baseline
        if ($LASTEXITCODE -ne 0) { throw 'Private staged fixture baseline failed.' }
        if (@(Read-GitStagedInputPath -RepositoryRootPath $strFixtureRoot -MaximumBytes 4096).Count -ne 0) {
            throw 'An unchanged index reported a staged input.'
        }
        [IO.File]::WriteAllText($strFixturePath, "unstaged`n", $objEncoding)
        if (@(Read-GitStagedInputPath -RepositoryRootPath $strFixtureRoot -MaximumBytes 4096).Count -ne 0) {
            throw 'A worktree-only change became a staged input.'
        }
        [IO.File]::WriteAllText($strFixturePath, "accepted`n", $objEncoding)
        $strHelperPath = [IO.Path]::Combine($strFixtureRoot, 'helper.ps1')
        [IO.File]::WriteAllText($strHelperPath, "Write-Output 'fixture'`n", $objEncoding)
        & git -C $strFixtureRoot -c core.autocrlf=false add -- helper.ps1
        if ($LASTEXITCODE -ne 0) { throw 'The helper-only fixture was not indexed.' }
        $arrHelperPaths = @(Read-GitStagedInputPath -RepositoryRootPath $strFixtureRoot -MaximumBytes 4096)
        if ($arrHelperPaths.Count -ne 1 -or $arrHelperPaths[0] -cne 'helper.ps1') {
            throw 'The staged query omitted a helper-only change.'
        }
        $boolBoundRejected = $false
        try { $null = Read-GitStagedInputPath -RepositoryRootPath $strFixtureRoot -MaximumBytes 1 } catch {
            if (-not $_.Exception.Message.Contains('must not exceed', [StringComparison]::Ordinal)) { throw }
            $boolBoundRejected = $true
        }
        if (-not $boolBoundRejected) { throw 'Oversized staged path output was accepted.' }
        $strIndexBlob = Get-GitRegularFileBlobId -RepositoryRootPath $strFixtureRoot -RepositoryRelativePath 'input name.md'
        foreach ($strMode in @('100755', '120000')) {
            & git -C $strFixtureRoot update-index --cacheinfo "$strMode,$strIndexBlob,input name.md"
            if ($LASTEXITCODE -ne 0) { throw 'The unsafe index-mode fixture was not installed.' }
            $boolModeRejected = $false
            try { $null = Read-RepositoryInputData @hashtableReader -RequireIndexContentMatch } catch {
                if (-not $_.Exception.Message.Contains('stage-0 regular file', [StringComparison]::Ordinal)) { throw }
                $boolModeRejected = $true
            }
            if (-not $boolModeRejected) { throw 'An unsafe staged index mode was accepted.' }
        }
        $boolNativeRejected = $false
        try { $null = Read-GitStagedInputPath -RepositoryRootPath $strFixturePath -MaximumBytes 4096 } catch {
            if (-not $_.Exception.Message.Contains('Could not inspect staged', [StringComparison]::Ordinal)) { throw }
            $boolNativeRejected = $true
        }
        if (-not $boolNativeRejected) { throw 'A failed native staged query was accepted.' }
    } finally {
        if ([IO.Path]::GetDirectoryName($strFixtureRoot).TrimEnd([IO.Path]::DirectorySeparatorChar) -cne
            $strTemporaryRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) -or
            -not [IO.Path]::GetFileName($strFixtureRoot).StartsWith('staged-input-', [StringComparison]::Ordinal)) {
            throw 'Refusing cleanup outside the private staged fixture.'
        }
        Remove-Item -LiteralPath $strFixtureRoot -Recurse -Force
    }
}

function Assert-ApplicationRuntimeSelfTest {
    # .SYNOPSIS
    # Tests application-only runtime selection and bounded live probes.
    #
    # .DESCRIPTION
    # Uses explicit resolver fixtures for unavailable, shadowed, malformed and
    # fallback identities. Live probes retain exact Python and Node execution.
    #
    # .EXAMPLE
    # Assert-ApplicationRuntimeSelfTest
    #
    # # Throws if a runtime-selection or probe contract fails.
    #
    # .INPUTS
    # None. No pipeline input.
    #
    # .OUTPUTS
    # [void] No output. Throws on a failed fixture.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; there are no parameters.
    # Version: 1.0.20261003.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([void])]
    param()
    $objSavedPythonContext = $hashtableRuntimeContext.PythonCommandContext
    $objSavedNodeContext = $hashtableRuntimeContext.NodeApplicationContext
    $strSavedPythonKey = $hashtableRuntimeContext.PythonResolutionKey
    $strApplicationPath = (Get-Command pwsh -CommandType Application | Select-Object -First 1).Path
    $strOtherPath = [IO.Path]::Combine([IO.Path]::GetDirectoryName($strApplicationPath), 'other-runtime')
    foreach ($objFixture in @(
            @{ Name = 'launcher'; Windows = $true; Type = 'Application'; Version = $true; Expected = $true }
            @{ Name = 'PATH'; Windows = $false; Type = 'Application'; Version = $true; Expected = $true }
            @{ Name = 'alias'; Windows = $false; Type = 'Alias'; Version = $true; Expected = $false }
            @{ Name = 'function'; Windows = $false; Type = 'Function'; Version = $true; Expected = $false }
            @{ Name = 'wrong version'; Windows = $false; Type = 'Application'; Version = $false; Expected = $false }
        )) {
        $strExpectedName = if ($objFixture.Windows) { 'py' } else { 'python3.12' }
        $scriptblockResolver = {
            param([string] $Name)
            if ($Name -ceq $strExpectedName) {
                [pscustomobject]@{ CommandType = $objFixture.Type; Path = $strApplicationPath }
            }
        }.GetNewClosure()
        $scriptblockProbe = {
            param([string] $Path, [string[]] $PrefixArgument)
            if ($Path -cne $strApplicationPath) { throw 'Unexpected Python fixture path.' }
            if ($objFixture.Windows -and ($PrefixArgument.Count -ne 1 -or $PrefixArgument[0] -cne '-3.12')) {
                throw 'The Windows launcher prefix was lost.'
            }
            return $objFixture.Version
        }.GetNewClosure()
        $objResolved = Get-Python312CommandContext -WindowsPlatform $objFixture.Windows `
            -CommandResolver $scriptblockResolver -VersionProbe $scriptblockProbe
        if (($null -ne $objResolved) -ne $objFixture.Expected) {
            throw "Python runtime fixture failed: $($objFixture.Name)."
        }
    }
    $scriptblockFallback = {
        param([string] $Name)
        if ($Name -ceq 'python3.12') { [pscustomobject]@{ CommandType = 'Application'; Path = $strOtherPath } }
        if ($Name -ceq 'python') { [pscustomobject]@{ CommandType = 'Application'; Path = $strApplicationPath } }
    }.GetNewClosure()
    $scriptblockCompatible = { param([string] $Path) $Path -ceq $strApplicationPath }.GetNewClosure()
    $objFallback = Get-Python312CommandContext -WindowsPlatform $false `
        -CommandResolver $scriptblockFallback -VersionProbe $scriptblockCompatible
    if ($null -eq $objFallback -or $objFallback.Path -cne $strApplicationPath) {
        throw 'Python resolution lost its supported fallback.'
    }
    $scriptblockNodeCandidates = {
        param([string] $Name)
        if ($Name -ceq 'node') {
            [pscustomobject]@{ CommandType = 'Application'; Path = $strOtherPath }
        }
    }.GetNewClosure()
    foreach ($objFixture in @(
            @{ Name = 'wrapper to direct'; Type = 'Application'; Version = '24.18.1'; Output = ''; Expected = $true }
            @{ Name = 'minimum version'; Type = 'Application'; Version = '22.0.0'; Output = ''; Expected = $true }
            @{ Name = 'old version'; Type = 'Application'; Version = '20.0.0'; Output = ''; Expected = $false }
            @{ Name = 'malformed version'; Type = 'Application'; Version = '24.0'; Output = ''; Expected = $false }
            @{ Name = 'reported alias'; Type = 'Alias'; Version = '24.18.1'; Output = ''; Expected = $false }
            @{ Name = 'reported function'; Type = 'Function'; Version = '24.18.1'; Output = ''; Expected = $false }
            @{ Name = 'invalid JSON'; Type = 'Application'; Version = '24.18.1'; Output = '{'; Expected = $false }
            @{ Name = 'duplicate identity'; Type = 'Application'; Version = '24.18.1'; Output = '{"execPath":"node","execPath":"node","nodeVersion":"24.18.1"}'; Expected = $false }
            @{ Name = 'wrong version type'; Type = 'Application'; Version = '24.18.1'; Output = '{"execPath":"node","nodeVersion":24}'; Expected = $false }
            @{ Name = 'oversized JSON'; Type = 'Application'; Version = '24.18.1'; Output = (' ' * 4097); Expected = $false }
            @{ Name = 'relative executable'; Type = 'Application'; Version = '24.18.1'; Output = '{"execPath":"node","nodeVersion":"24.18.1"}'; Expected = $false }
        )) {
        $scriptblockProbe = {
            param([string] $Path)
            if ($Path -cne $strOtherPath) { throw 'Unexpected Node fixture path.' }
            if ($objFixture.Output) { return $objFixture.Output }
            return @{ execPath = $strApplicationPath; nodeVersion = $objFixture.Version } | ConvertTo-Json -Compress
        }.GetNewClosure()
        $scriptblockDirect = {
            param([string] $Path)
            [pscustomobject]@{ CommandType = $objFixture.Type; Path = $Path }
        }.GetNewClosure()
        $objResolved = Get-NodeApplicationContext -CommandResolver $scriptblockNodeCandidates `
            -RuntimeProbe $scriptblockProbe -ApplicationResolver $scriptblockDirect
        if (($null -ne $objResolved) -ne $objFixture.Expected) {
            throw "Node runtime fixture failed: $($objFixture.Name)."
        }
        if ($null -ne $objResolved -and $objResolved.Path -cne $strApplicationPath) {
            throw 'Node resolution retained a wrapper instead of its direct executable.'
        }
    }
    if (-not [object]::ReferenceEquals($objSavedPythonContext, $hashtableRuntimeContext.PythonCommandContext) -or
        -not [object]::ReferenceEquals($objSavedNodeContext, $hashtableRuntimeContext.NodeApplicationContext) -or
        $strSavedPythonKey -cne $hashtableRuntimeContext.PythonResolutionKey) {
        throw 'Injected runtime fixtures changed the live application cache.'
    }
    $objPython = Get-Python312CommandContext
    if ($null -eq $objPython -or -not (Test-Python312Application -Path $objPython.Path -PrefixArgument $objPython.Arguments)) {
        throw 'The actual Python 3.12 application was rejected.'
    }
    if (Test-Python312Application -Path $strApplicationPath) { throw 'PowerShell was accepted as Python.' }
    $objNode = Get-NodeApplicationContext
    if ($null -eq $objNode -or $null -eq (Invoke-NodeRuntimeProbe -Path $objNode.Path)) {
        throw 'The actual Node application was rejected.'
    }
    if (-not [object]::ReferenceEquals($objPython, (Get-Python312CommandContext)) -or
        -not [object]::ReferenceEquals($objNode, (Get-NodeApplicationContext))) {
        throw 'Live application resolution did not retain its verified cache.'
    }
    $strTemporaryRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
    $strChildPath = [IO.Path]::Combine($strTemporaryRoot, 'runtime-scope-' + [Guid]::NewGuid().ToString('N') + '.ps1')
    $strChildProgram = @'
param([Parameter(Mandatory)][hashtable] $RuntimeContext)
Set-StrictMode -Version Latest
$hashtableRuntimeContext = $RuntimeContext
$objExpectedPython = $RuntimeContext.PythonCommandContext
$objExpectedNode = $RuntimeContext.NodeApplicationContext
if (-not [object]::ReferenceEquals($objExpectedPython, (Get-Python312CommandContext)) -or
    -not [object]::ReferenceEquals($objExpectedNode, (Get-NodeApplicationContext))) {
    throw 'The runtime child did not reuse the verified parent cache.'
}
$boolSavedPlatform = $RuntimeContext.WindowsPlatform
$arrSavedNames = $RuntimeContext.PythonPathNames
try {
    $RuntimeContext.WindowsPlatform = $false
    $RuntimeContext.PythonPathNames = @('missing-runtime-scope-python')
    if ($null -ne (Get-Python312CommandContext)) {
        throw 'The runtime child reused a cache for different Python names.'
    }
} finally {
    $RuntimeContext.WindowsPlatform = $boolSavedPlatform
    $RuntimeContext.PythonPathNames = $arrSavedNames
}
if (-not [object]::ReferenceEquals($objExpectedPython, (Get-Python312CommandContext))) {
    throw 'The runtime child failed to restore the parent resolution contract.'
}
'@
    try {
        [IO.File]::WriteAllText($strChildPath, $strChildProgram, [Text.UTF8Encoding]::new($false))
        & $strChildPath -RuntimeContext $hashtableRuntimeContext
        if (-not $?) { throw 'The runtime child script failed.' }
    } finally {
        if ([IO.Path]::GetDirectoryName($strChildPath).TrimEnd([IO.Path]::DirectorySeparatorChar) -cne
            $strTemporaryRoot.TrimEnd([IO.Path]::DirectorySeparatorChar) -or
            -not [IO.Path]::GetFileName($strChildPath).StartsWith('runtime-scope-', [StringComparison]::Ordinal)) {
            throw 'Refusing cleanup outside the private runtime child fixture.'
        }
        Remove-Item -LiteralPath $strChildPath -Force
    }
    $strSavedNodeOptions = $env:NODE_OPTIONS
    $strSavedNodePath = $env:NODE_PATH
    try {
        $env:NODE_OPTIONS = '--require=nonexistent-a21-probe-preload'
        $env:NODE_PATH = 'nonexistent-a21-probe-module-path'
        if ($null -eq (Invoke-NodeRuntimeProbe -Path $objNode.Path)) {
            throw 'The Node identity probe inherited preload environment variables.'
        }
    } finally {
        $env:NODE_OPTIONS = $strSavedNodeOptions
        $env:NODE_PATH = $strSavedNodePath
    }
    foreach ($objProcessFixture in @(
            @{ Name = 'stderr'; Program = '[Console]::Error.Write("noise")'; Bytes = 16; Milliseconds = 10000; Failure = 'returned unexpected error output.' }
            @{ Name = 'oversized stdout'; Program = '[Console]::Write("x" * 100)'; Bytes = 16; Milliseconds = 10000; Failure = 'must not exceed 16 bytes.' }
            @{ Name = 'timeout'; Program = 'Start-Sleep -Seconds 30'; Bytes = 16; Milliseconds = 100; Failure = 'timed out.' }
        )) {
        $objStartInfo = [Diagnostics.ProcessStartInfo]::new($strApplicationPath)
        $objStartInfo.UseShellExecute = $false
        $objStartInfo.CreateNoWindow = $true
        $objStartInfo.RedirectStandardOutput = $true
        $objStartInfo.RedirectStandardError = $true
        foreach ($strArgument in @('-NoProfile', '-NonInteractive', '-Command', $objProcessFixture.Program)) {
            $objStartInfo.ArgumentList.Add($strArgument)
        }
        $objProcess = [Diagnostics.Process]::new()
        $objProcess.StartInfo = $objStartInfo
        $boolRejected = $false
        try {
            $null = Read-BoundedProcessData -Process $objProcess -MaximumBytes $objProcessFixture.Bytes `
                -TimeoutMilliseconds $objProcessFixture.Milliseconds -DisplayName $objProcessFixture.Name `
                -RejectStandardError
        } catch {
            if (-not $_.Exception.Message.Contains($objProcessFixture.Failure, [StringComparison]::Ordinal)) {
                throw
            }
            $boolRejected = $true
        }
        if (-not $boolRejected) { throw "An invalid process probe was accepted: $($objProcessFixture.Name)." }
    }
}


Assert-ParserJsonConversionSelfTest
Assert-MarkdownStringArrayContextSelfTest
Assert-MarkdownParseReuseSelfTest
Assert-AgentSetupSelfTest -RepositoryRootPath $RepositoryRootPath

Assert-StagedInputSelfTest
Assert-ApplicationRuntimeSelfTest
Assert-GitRevisionTextSelfTest
Assert-PublishedBaselineCapacitySelfTest -MaximumMetadataUtcDate $MaximumMetadataUtcDate
Assert-DocumentMetadataClassificationSelfTest -MaximumMetadataUtcDate $MaximumMetadataUtcDate
Assert-OptionalMetadataSelfTest -MaximumMetadataUtcDate $MaximumMetadataUtcDate
Assert-DocumentMetadataPlacementSelfTest -RepositoryRootPath $RepositoryRootPath -MaximumMetadataUtcDate $MaximumMetadataUtcDate
Assert-PublishedMetadataGitFixture -MaximumMetadataUtcDate $MaximumMetadataUtcDate
Assert-ClassificationAdmissionGitFixture -RepositoryRootPath $RepositoryRootPath
Assert-AuthorFinalizationGitFixture -RepositoryRootPath $RepositoryRootPath

$intCapacityMaximumBytes = 573440
# Exercise the actual bounded reader at both sides of the finite role cap.
foreach ($intBoundaryBytes in @(
        $intCapacityMaximumBytes, ($intCapacityMaximumBytes + 1)
    )) {
    $objBoundaryStream = [IO.MemoryStream]::new([byte[]]::new($intBoundaryBytes))
    $boolBoundaryRejected = $false
    try {
        $arrBoundaryBytes = @(Read-BoundedStreamData -Stream $objBoundaryStream `
                -MaximumBytes $intCapacityMaximumBytes `
                -DisplayName 'Validator capacity boundary')
        if ($arrBoundaryBytes.Count -ne $intBoundaryBytes) {
            throw 'The validator boundary reader returned an incomplete result.'
        }
    } catch [IO.InvalidDataException] {
        if ($_.Exception.Message -cne
            "Validator capacity boundary must not exceed $intCapacityMaximumBytes bytes.") {
            throw
        }
        $boolBoundaryRejected = $true
    } finally {
        $objBoundaryStream.Dispose()
    }
    if ($boolBoundaryRejected -ne
        ($intBoundaryBytes -gt $intCapacityMaximumBytes)) {
        throw 'The validator capacity boundary did not fail closed exactly.'
    }
}
# These input-reader fixtures need no candidate code or parent-scope mutation.
Assert-RepositoryInputMetadataMutationRejected `
    -Name 'missing Git index entry mutation' `
    -GitIndexEntryCount 0 `
    -Failure 'missing Git index entry mutation must have exactly one Git index entry.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'Git symlink mode mutation' `
    -GitMode '120000' `
    -Failure 'Git symlink mode mutation must be a stage-0 regular file with Git mode 100644.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'nonzero Git stage mutation' `
    -GitStage '2' `
    -Failure 'nonzero Git stage mutation must be a stage-0 regular file with Git mode 100644.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'non-file worktree item mutation' `
    -IsFileInfo $false `
    -Failure 'non-file worktree item mutation must be a regular worktree file.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'reparse-point mutation' `
    -Attributes ([System.IO.FileAttributes]::Normal -bor [System.IO.FileAttributes]::ReparsePoint) `
    -Failure 'reparse-point mutation must not be a symbolic link or reparse point.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'link-type mutation' `
    -LinkType 'SymbolicLink' `
    -Failure 'link-type mutation must not have a link type.'

Assert-RepositoryInputMetadataMutationRejected `
    -Name 'Unix device mutation' `
    -UnixMode 'crw-rw-rw-' `
    -Failure 'Unix device mutation must have a regular Unix file type.'

$strPathSafetyTempRoot = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$strPathSafetyRoot = [IO.Path]::Combine(
    $strPathSafetyTempRoot,
    'agent-input-path-' + [Guid]::NewGuid().ToString('N')
)
if (-not $strPathSafetyRoot.StartsWith(
        $strPathSafetyTempRoot,
        [StringComparison]::OrdinalIgnoreCase
    )) {
    throw 'The repository-input path fixture root is unsafe.'
}
$strPathSafetyRepository = [IO.Path]::Combine($strPathSafetyRoot, 'repository')
$strPathSafetyLinkedDirectory =
    [IO.Path]::Combine($strPathSafetyRepository, 'linked')
$strPathSafetyOutsideDirectory = [IO.Path]::Combine($strPathSafetyRoot, 'outside')
$strPathSafetyInput = [IO.Path]::Combine(
    $strPathSafetyLinkedDirectory,
    'input.md'
)
[void][IO.Directory]::CreateDirectory($strPathSafetyLinkedDirectory)
[IO.File]::WriteAllText(
    $strPathSafetyInput,
    'safe',
    [Text.UTF8Encoding]::new($false)
)
try {
    & git -C $strPathSafetyRepository init --quiet
    & git -C $strPathSafetyRepository add -- linked/input.md
    if ($LASTEXITCODE -ne 0) {
        throw 'Could not create the repository-input path fixture index.'
    }
    $arrSafeRepositoryInput = [byte[]]@(Read-RepositoryInputData `
            -Path $strPathSafetyInput `
            -RepositoryRootPath $strPathSafetyRepository `
            -RepositoryRelativePath 'linked/input.md' `
            -DisplayName 'safe path fixture' `
            -MaximumBytes 64)
    if ([Text.Encoding]::UTF8.GetString($arrSafeRepositoryInput) -cne 'safe') {
        throw 'The safe repository-input path fixture returned unexpected bytes.'
    }

    [IO.File]::Delete($strPathSafetyInput)
    [IO.Directory]::Delete($strPathSafetyLinkedDirectory)
    [void][IO.Directory]::CreateDirectory($strPathSafetyOutsideDirectory)
    [IO.File]::WriteAllText(
        [IO.Path]::Combine($strPathSafetyOutsideDirectory, 'input.md'),
        'outside',
        [Text.UTF8Encoding]::new($false)
    )
    if ([IO.Path]::DirectorySeparatorChar -eq '\') {
        [void](New-Item -ItemType Junction `
                -Path $strPathSafetyLinkedDirectory `
                -Target $strPathSafetyOutsideDirectory)
    } else {
        [void](New-Item -ItemType SymbolicLink `
                -Path $strPathSafetyLinkedDirectory `
                -Target $strPathSafetyOutsideDirectory)
    }
    $boolLinkedComponentRejected = $false
    try {
        [void](Read-RepositoryInputData `
                -Path $strPathSafetyInput `
                -RepositoryRootPath $strPathSafetyRepository `
                -RepositoryRelativePath 'linked/input.md' `
                -DisplayName 'linked path fixture' `
                -MaximumBytes 64)
    } catch {
        $boolLinkedComponentRejected = $_.Exception.Message.Contains(
            'unsafe linked path component: linked.',
            [StringComparison]::Ordinal
        )
    }
    if (-not $boolLinkedComponentRejected) {
        throw 'An intermediate linked repository-input component was accepted.'
    }
} finally {
    if (Test-Path -LiteralPath $strPathSafetyLinkedDirectory) {
        $objLinkedFixtureItem =
            Get-Item -Force -LiteralPath $strPathSafetyLinkedDirectory
        if (($objLinkedFixtureItem.Attributes -band
                [IO.FileAttributes]::ReparsePoint) -ne 0) {
            Remove-Item -Force -LiteralPath $strPathSafetyLinkedDirectory
        }
    }
    if ([IO.Directory]::Exists($strPathSafetyRoot)) {
        Remove-Item -Recurse -Force -LiteralPath $strPathSafetyRoot
    }
}

function ConvertTo-CreatedPushCommitEvidenceObject {
    # .SYNOPSIS
    # Creates one Actions-shaped created-push commit evidence object.
    #
    # .DESCRIPTION
    # Returns the exact bounded property shape that the created-push evidence
    # parser accepts, with optional timestamp data for focused self-tests.
    #
    # .PARAMETER Id
    # The full Git object ID used for both commit and tree fixture fields.
    #
    # .PARAMETER Distinct
    # Whether the fixture commit is distinct from every retained remote ref.
    #
    # .PARAMETER Timestamp
    # The optional timestamp string included in the inert evidence object.
    #
    # .EXAMPLE
    # ConvertTo-CreatedPushCommitEvidenceObject -Id $strId -Distinct $true
    #
    # # Returns one bounded created-push evidence fixture.
    #
    # .INPUTS
    # None. This helper does not accept pipeline input.
    #
    # .OUTPUTS
    # [System.Management.Automation.PSCustomObject] One evidence fixture object.
    #
    # .NOTES
    # PRIVATE/INTERNAL HELPER - This function is not part of the public API.
    # Parameters, return shape, and positional contract can change without notice.
    # Positional parameters are disabled; internal callers use named arguments.
    # Version: 1.0.20261005.0
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)][string] $Id,
        [Parameter(Mandatory)][bool] $Distinct,
        [string] $Timestamp = ''
    )

    return [pscustomobject]@{
        id = $Id
        tree_id = $Id
        distinct = $Distinct
        message = ''
        timestamp = $Timestamp
        url = ''
        author = [pscustomobject]@{
            name = ''
            email = ''
            username = $null
        }
        committer = [pscustomobject]@{
            name = ''
            email = ''
            username = $null
        }
    }
}

$strBaseline = @(
    '# Endpoint fixture'
    '**Version:** 1.0.20260830.0'
    '## Metadata'
    '- **Status:** Active'
    '- **Owner:** Repository Maintainers'
    '- **Last Updated:** 2026-08-30'
    '- **Scope:** Extracted final-state regression.'
    '## Content'
    'Published baseline.'
) -join "`n"
$strFinal = @(
    '# Endpoint fixture'
    '**Version:** 1.0.20260831.0'
    '## Metadata'
    '- **Status:** Accepted'
    '- **Owner:** Repository Maintainers'
    '- **Last Updated:** 2026-08-31'
    '- **Scope:** Extracted final-state regression.'
    '## Content'
    'Corrected published final.'
) -join "`n"
if (@(Get-PublishedEndpointMetadataFailure -Name 'fixture.md' `
        -CurrentContent $strFinal -ParentContent $strBaseline `
        -ExpectedUtcDate '2026-08-31' `
        -IsNewDocumentTransition $false).Count -ne 0) {
    throw 'The extracted published-final regression was rejected.'
}

$strHigherTerminalRevision = $strFinal.Replace(
    '**Version:** 1.0.20260831.0',
    '**Version:** 1.0.20260831.3'
)
if (@(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strHigherTerminalRevision `
    -ParentContent $strBaseline -ExpectedUtcDate '2026-08-31' `
    -IsNewDocumentTransition $false) -cnotcontains
    ('fixture.md Version revision must be exactly 0 when a published-baseline ' +
        'major, minor, or date segment changes.')) {
    throw 'The extracted higher-order revision reset did not fail closed.'
}

$strMetadataOnlyHigherRevision = $strBaseline.Replace(
    '**Version:** 1.0.20260830.0',
    '**Version:** 1.0.20260902.5'
).Replace(
    '- **Last Updated:** 2026-08-30',
    '- **Last Updated:** 2026-09-02'
)
if (@(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strMetadataOnlyHigherRevision `
    -ParentContent $strBaseline -ExpectedUtcDate '2026-09-02' `
    -IsNewDocumentTransition $false) -cnotcontains
    ('fixture.md Version revision must be exactly 0 when a published-baseline ' +
        'major, minor, or date segment changes.')) {
    throw 'The extracted metadata-only higher-order reset did not fail closed.'
}
$strMetadataOnlyHigherReset = $strMetadataOnlyHigherRevision.Replace(
    '**Version:** 1.0.20260902.5',
    '**Version:** 1.0.20260902.0'
)
if (@(Get-PublishedEndpointMetadataFailure `
        -Name 'fixture.md' -CurrentContent $strMetadataOnlyHigherReset `
        -ParentContent $strBaseline -ExpectedUtcDate '2026-09-02' `
        -IsNewDocumentTransition $false).Count -ne 0) {
    throw 'The extracted metadata-only higher-order reset was rejected.'
}

$strMetadataOnlySameTupleIncrement = $strBaseline.Replace(
    '**Version:** 1.0.20260830.0',
    '**Version:** 1.0.20260830.1'
)
if (@(Get-PublishedEndpointMetadataFailure `
        -Name 'fixture.md' -CurrentContent $strMetadataOnlySameTupleIncrement `
        -ParentContent $strBaseline -ExpectedUtcDate '2026-08-30' `
        -IsNewDocumentTransition $false).Count -ne 0) {
    throw 'The extracted metadata-only same-tuple increment was rejected.'
}
$strMetadataOnlySameTupleSkip = $strMetadataOnlySameTupleIncrement.Replace(
    '**Version:** 1.0.20260830.1',
    '**Version:** 1.0.20260830.2'
)
if (@(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strMetadataOnlySameTupleSkip `
    -ParentContent $strBaseline -ExpectedUtcDate '2026-08-30' `
    -IsNewDocumentTransition $false) -cnotcontains
    ('fixture.md Version revision must be exactly 1 after a published change ' +
        'with an unchanged published-baseline major, minor, and date tuple.')) {
    throw 'The extracted metadata-only same-tuple skip did not fail closed.'
}

$strSameTupleFinal = $strBaseline.Replace(
    '**Version:** 1.0.20260830.0',
    '**Version:** 1.0.20260830.1'
).Replace('Published baseline.', 'Published final on the same tuple.')
if (@(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strSameTupleFinal `
    -ParentContent $strBaseline -ExpectedUtcDate '2026-08-30' `
    -IsNewDocumentTransition $false).Count -ne 0) {
    throw 'The extracted exact same-tuple revision increment was rejected.'
}
$strSkippedSameTupleRevision = $strSameTupleFinal.Replace(
    '**Version:** 1.0.20260830.1',
    '**Version:** 1.0.20260830.2'
)
if (@(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strSkippedSameTupleRevision `
    -ParentContent $strBaseline -ExpectedUtcDate '2026-08-30' `
    -IsNewDocumentTransition $false) -cnotcontains
    ('fixture.md Version revision must be exactly 1 after a published change ' +
        'with an unchanged published-baseline major, minor, and date tuple.')) {
    throw 'The extracted skipped same-tuple revision did not fail closed.'
}

if (@(Get-PublishedEndpointMetadataFailure -Name 'fixture.md' `
        -CurrentContent $strFinal -ParentContent $null -ExpectedUtcDate '' `
        -IsNewDocumentTransition $true `
        -RequireExpectedUtcDateForRenderedChange $false).Count -ne 0) {
    throw 'The extracted baseline-absent revision zero was rejected.'
}
$strNewDocumentNonzeroRevision = $strFinal.Replace(
    '**Version:** 1.0.20260831.0',
    '**Version:** 1.0.20260831.1'
)
if (@(Get-PublishedEndpointMetadataFailure -Name 'fixture.md' `
        -CurrentContent $strNewDocumentNonzeroRevision -ParentContent $null `
        -ExpectedUtcDate '' -IsNewDocumentTransition $true `
        -RequireExpectedUtcDateForRenderedChange $false) -cnotcontains
    'fixture.md Version revision must be exactly 0 when no published baseline exists.') {
    throw 'The extracted baseline-absent nonzero revision did not fail closed.'
}

$strSameTupleRollback = $strBaseline.Replace(
    '**Version:** 1.0.20260830.0',
    '**Version:** 1.0.20260830.4'
)
$arrRollbackFailures = @(Get-PublishedEndpointMetadataFailure `
    -Name 'fixture.md' -CurrentContent $strBaseline `
    -ParentContent $strSameTupleRollback -ExpectedUtcDate '2026-08-30' `
    -IsNewDocumentTransition $false)
if ($arrRollbackFailures -cnotcontains
    'fixture.md Version revision must not decrease from 4 to 0.') {
    throw 'The extracted same-tuple revision rollback did not fail closed.'
}

$strDateRollback = $strFinal.Replace(
    '**Version:** 1.0.20260831.0',
    '**Version:** 2.0.20260829.0'
).Replace('- **Last Updated:** 2026-08-31',
    '- **Last Updated:** 2026-08-29')
if (-not (@(Get-PublishedEndpointMetadataFailure `
        -Name 'fixture.md' -CurrentContent $strDateRollback `
        -ParentContent $strBaseline -ExpectedUtcDate '2026-08-29' `
        -IsNewDocumentTransition $false) -match
        'Version date must not move backward')) {
    throw 'The extracted independent date rollback did not fail closed.'
}

$strTupleRollback = $strFinal.Replace(
    '**Version:** 1.0.20260831.0',
    '**Version:** 0.9.20260831.0'
)
if (-not (@(Get-PublishedEndpointMetadataFailure `
        -Name 'fixture.md' -CurrentContent $strTupleRollback `
        -ParentContent $strBaseline -ExpectedUtcDate '2026-08-31' `
        -IsNewDocumentTransition $false) -match
        'Version major and minor tuple must not move backward')) {
    throw 'The extracted independent major/minor rollback did not fail closed.'
}

$strUnversionedBaseline = @(
    '# Unversioned endpoint fixture'
    '## Metadata'
    '- **Status:** Active'
    '- **Owner:** Repository Maintainers'
    '- **Last Updated:** 2026-08-30'
    '- **Scope:** Extracted unversioned final-state regression.'
    '## Content'
    'Published baseline.'
) -join "`n"
$strUnversionedFinal = $strUnversionedBaseline.Replace(
    '- **Last Updated:** 2026-08-30',
    '- **Last Updated:** 2026-08-31'
).Replace('Published baseline.', 'Published final.')
if (@(Get-PublishedEndpointLastUpdatedFailure -Name 'fixture.md' `
        -CurrentContent $strUnversionedFinal `
        -BaseContent $strUnversionedBaseline `
        -TrustedEventUtcDate '2026-08-31' `
        -RequireCurrentMaximumDateForRenderedChange $false).Count -ne 0) {
    throw 'The extracted unversioned published-final regression was rejected.'
}
$arrStaleFailures = @(Get-PublishedEndpointLastUpdatedFailure `
    -Name 'fixture.md' `
    -CurrentContent ($strUnversionedBaseline + "`nRendered final change.") `
    -BaseContent $strUnversionedBaseline `
    -TrustedEventUtcDate '2026-08-31')
if (-not ($arrStaleFailures -match 'Last Updated must be 2026-08-31')) {
    throw 'The extracted stale unversioned final did not fail closed.'
}

$strSameDayFinal = $strUnversionedBaseline.Replace('Published baseline.', 'Second edit on the same day.')
if (@(Get-PublishedEndpointLastUpdatedFailure -Name 'same-day.md' `
        -CurrentContent $strSameDayFinal -BaseContent $strUnversionedBaseline `
        -TrustedEventUtcDate '' -RequireCurrentMaximumDateForRenderedChange $false).Count -ne 0) {
    throw 'A valid same-day final document was rejected.'
}
if (-not (@(Get-PublishedEndpointLastUpdatedFailure -Name 'backward-date.md' `
        -CurrentContent $strSameDayFinal.Replace('2026-08-30', '2026-08-29') `
        -BaseContent $strUnversionedBaseline -TrustedEventUtcDate '') -match 'must not move backward')) {
    throw 'A backward final date was accepted.'
}
if (-not (@(Get-PublishedEndpointLastUpdatedFailure -Name 'stale-authoring.md' `
        -CurrentContent $strSameDayFinal -BaseContent $strUnversionedBaseline `
        -TrustedEventUtcDate '' -RequireCurrentMaximumDateForRenderedChange $true) -match 'Last Updated must be')) {
    throw 'The local authoring date check was lost.'
}

if (@(Read-GitPublishedEndpointChangedPath `
        -RepositoryRootPath $RepositoryRootPath `
        -BaselineRevision $Revision -FinalRevision $Revision `
        -MaximumBytes $MaximumBytes).Count -ne 0) {
    throw 'Identical endpoint trees reported changed paths.'
}
