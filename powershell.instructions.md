---
applyTo:  "**/*.ps1"
description: "PowerShell coding standards"
---

# PowerShell Writing Style

**Version:** 2.15.20260421.3

**Scope:** PowerShell coding standards for all `.ps1` files in this repository — style, formatting, naming, error handling, documentation, and compatibility patterns for both legacy (v1.0) and modern (v2.0+) codebases.

## Keywords

Per [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119): **MUST** / **SHALL** / **REQUIRED** = absolute requirement; **MUST NOT** / **SHALL NOT** = absolute prohibition; **SHOULD** / **RECOMMENDED** = strong recommendation (deviations require justification); **SHOULD NOT** / **NOT RECOMMENDED** = strong discouragement; **MAY** / **OPTIONAL** = truly optional.

<!-- rationale-anchor: keywords-extended-explanation -->

## Quick Reference Checklist

Scope tags: **[All]** = all PowerShell versions, **[Modern]** = PowerShell v2.0+ (requires features not available in v1.0), **[v1.0]** = backward compatible with Windows PowerShell v1.0. Each item links to its detailed section.

### Code Layout and Formatting (Quick Reference)

- **[All]** Code **MUST** use 4 spaces for indentation, never tabs → [Indentation Rules](#indentation-rules)
- **[All]** Opening braces **MUST** be placed on same line (OTBS) → [Brace Placement (OTBS)](#brace-placement-otbs)
- **[All]** `catch`, `finally`, `else` **MUST** be on same line as closing brace → [Exception: catch, finally, and else Keywords](#exception-catch-finally-and-else-keywords)
- **[All]** Code **MUST** use single space around operators, no extra alignment → [Operator Spacing and Alignment](#operator-spacing-and-alignment)
- **[All]** Operators **MUST NOT** be vertically aligned across multiple lines → [Operator Spacing and Alignment](#operator-spacing-and-alignment)
- **[All]** Multi-line method parameters **MUST** have extra indentation → [Multi-line Method Indentation](#multi-line-method-indentation)
- **[All]** Blank lines **SHOULD** be used sparingly: two around functions, one within → [Blank Line Usage](#blank-line-usage)
- **[All]** Blank lines **MUST NOT** contain any whitespace (spaces or tabs) → [Blank Line Usage](#blank-line-usage)
- **[All]** Lines **MUST NOT** end with trailing whitespace → [Trailing Whitespace](#trailing-whitespace)
- **[All]** Variables in strings **SHOULD** be delimited with `${}` or `-f` operator → [Variable Delimiting in Strings](#variable-delimiting-in-strings)
- **[All]** Source `.ps1` files **MUST** be UTF-8 without BOM by default; see [File Encoding](#file-encoding) for the Windows PowerShell/non-ASCII exception
- **[All]** When writing text files programmatically, encoding **MUST** be specified explicitly; prefer `.NET` for cross-version UTF-8 without BOM → [Programmatic File Writing Encoding](#programmatic-file-writing-encoding)
- **[All]** When producing byte-exact text artifacts, serializer output **MUST** be normalized to LF in memory before writing or comparing → [Line Endings for Byte-Exact Text Artifacts](#line-endings-for-byte-exact-text-artifacts)
- **[All]** Text-level file comparison **MUST** read files with `Get-Content -Raw` or `[System.IO.File]::ReadAllText()` under a fixed encoding/BOM convention; `Get-Content` without `-Raw` **MUST NOT** be used → [Line Endings for Byte-Exact Text Artifacts](#line-endings-for-byte-exact-text-artifacts)
- **[All]** True byte-for-byte comparison **MUST** read files with `[System.IO.File]::ReadAllBytes()`; this is required for hash/signature inputs and any other byte-exact identity check → [Line Endings for Byte-Exact Text Artifacts](#line-endings-for-byte-exact-text-artifacts)

### Capitalization and Naming Conventions (Quick Reference)

- **[All]** Public identifiers (functions, parameters, properties) **MUST** use PascalCase → [Capitalization and Naming Conventions](#capitalization-and-naming-conventions)
- **[All]** PowerShell keywords (function, param, if, else, return, trap) **MUST** be lowercase → [Capitalization and Naming Conventions](#capitalization-and-naming-conventions)
- **[All]** Local variables **MUST** use camelCase with type-hinting prefixes, fully descriptive (e.g., $strMessage, $intCount, no abbreviations) → [Local Variable Naming: Type-Prefixed camelCase](#local-variable-naming-type-prefixed-camelcase)
- **[All]** Functions **MUST** follow Verb-Noun pattern with approved verbs → [Script and Function Naming: Full Explicit Form](#script-and-function-naming-full-explicit-form)
- **[All]** Functions **MUST** use singular nouns in function names → [Script and Function Naming: Nouns](#script-and-function-naming-nouns)
- **[All]** Modules **MUST** use PascalCase nouns (containers, not actions) → [Module Naming: Noun-Based Containers](#module-naming-noun-based-containers)
- **[Modern]** Module manifest `Tags` key **MUST** be populated aggressively with relevant keywords for discoverability → [Module Naming: Noun-Based Containers](#module-naming-noun-based-containers)
- **[All]** Aliases **MUST NOT** be used in code → [Do Not Use Aliases](#do-not-use-aliases)
- **[Modern]** Modules **MUST NOT** export compatibility aliases (exception: genuine interactive shortcuts) → [Do Not Use Aliases](#do-not-use-aliases)
- **[All]** Parameters **MUST** use PascalCase, fully descriptive names → [Parameter Naming](#parameter-naming)
- **[v1.0]** Reference parameters **MUST** use "ReferenceTo" prefix → [Parameter Naming](#parameter-naming)
- **[All]** Code **SHOULD** avoid relative paths and tilde (~) shortcut → [Path and Scope Handling](#path-and-scope-handling)
- **[All]** Code **SHOULD** use explicit scoping ($global:, $script:) → [Path and Scope Handling](#path-and-scope-handling)
- **[All]** `-LiteralPath` **SHOULD** be used instead of `-Path` when operating on concrete (non-wildcard) paths derived from variables or `Join-Path` → [Prefer `-LiteralPath` Over `-Path` for Concrete Paths](#prefer--literalpath-over--path-for-concrete-paths)
- **[All]** For destructive cmdlets (`Remove-Item`, `Move-Item`), `-LiteralPath` **MUST** be used for variable-derived paths → [Prefer `-LiteralPath` Over `-Path` for Concrete Paths](#prefer--literalpath-over--path-for-concrete-paths)
- **[All]** `New-Item` does **not** support `-LiteralPath`; use `-Path` with `New-Item` → [Prefer `-LiteralPath` Over `-Path` for Concrete Paths](#prefer--literalpath-over--path-for-concrete-paths)
- **[All]** For directory creation from variable-derived paths that may contain wildcard characters, prefer `[System.IO.Directory]::CreateDirectory()` → [Prefer `-LiteralPath` Over `-Path` for Concrete Paths](#prefer--literalpath-over--path-for-concrete-paths)
- **[All]** Paths passed to .NET file APIs (`System.IO.*`) **MUST** be resolved to absolute via `GetUnresolvedProviderPathFromPSPath()` first; non-FileSystem provider paths **MUST NOT** be used → [Resolving Paths for .NET Static Methods](#resolving-paths-for-net-static-methods)

### Documentation and Comments (Quick Reference)

- **[All]** All functions **MUST** have full comment-based help → [Comment-Based Help: Structure and Format](#comment-based-help-structure-and-format)
- **[All]** Comment-based help **MUST** be placed inside function body, above param block → [Comment-Based Help: Structure and Format](#comment-based-help-structure-and-format)
- **[All]** Comment-based help **MUST** use single-line comments (#) with dotted keywords (.SYNOPSIS, .DESCRIPTION, etc.) → [Comment-Based Help: Structure and Format](#comment-based-help-structure-and-format)
- **[v1.0]** Block comments (`<# ... #>`) **MUST NOT** be used — they cause parser errors in PowerShell v1.0; use single-line comments (`#`) instead → [Help Format Options: Comparison](#help-format-options-comparison)
- **[All]** Comment-based help **MUST** include sections: .SYNOPSIS, .DESCRIPTION, .PARAMETER (one per parameter, if any), .EXAMPLE, .INPUTS, .OUTPUTS, .NOTES → [Comment-Based Help: Structure and Format](#comment-based-help-structure-and-format)
- **[All]** Explanatory or output-description lines within `.EXAMPLE` blocks **MUST** use double `#` (`# # <text>`) so that `Get-Help` renders them as valid PowerShell comments (`# <text>`) → [Inline Comments Within `.EXAMPLE` Blocks](#inline-comments-within-example-blocks)
- **[All]** Functions **SHOULD** provide multiple examples with input, output, and explanation → [Help Content Quality: High Standards](#help-content-quality-high-standards)
- **[All]** Every possible output/return value **MUST** be documented in .OUTPUTS with exact type and meaning; integer status codes **MUST** include full code-to-meaning mapping; output examples **MUST** be placed in .EXAMPLE blocks → [Help Content Quality: High Standards](#help-content-quality-high-standards)
- **[All]** Positional parameter support **MUST** be documented in .NOTES → [Help Content Quality: High Standards](#help-content-quality-high-standards)
- **[All]** Private/internal helper functions' `.NOTES` **MUST** begin with a private-helper banner → [Private/Internal Helper Function Documentation](#privateinternal-helper-function-documentation)
- **[Modern]** Functions omitted from module manifest `FunctionsToExport` are treated as private/internal helpers → [Private/Internal Helper Function Documentation](#privateinternal-helper-function-documentation)
- **[All]** Positional parameter documentation for private/internal helpers **SHOULD** state it is an internal-caller contract only → [Positional Parameter Support](#positional-parameter-support)
- **[All]** Version number **MUST** be included in .NOTES (format: Major.Minor.YYYYMMDD.Revision) → [Function and Script Versioning](#function-and-script-versioning)
- **[All]** Version build component **MUST** be current date in YYYYMMDD format → [Function and Script Versioning](#function-and-script-versioning)
- **[All]** Inline comments **SHOULD** focus on "why" not "what" → [Inline Comments: Purpose and Placement](#inline-comments-purpose-and-placement)
- **[All]** Code **SHOULD** use #region / #endregion for logical code folding → [Structural Documentation: Regions and Licensing](#structural-documentation-regions-and-licensing)
- **[All]** The param() block **MUST** be placed before license region (if applicable) → [Structural Documentation: Regions and Licensing](#structural-documentation-regions-and-licensing)
- **[All]** Distributable helpers **SHOULD** use per-function licensing (#region License after param block) → [Structural Documentation: Regions and Licensing](#structural-documentation-regions-and-licensing)
- **[All]** Parameter documentation **SHOULD** be centralized in help block, not above individual parameters → [Parameter Documentation Placement: Strategic Choice](#parameter-documentation-placement-strategic-choice)

### Functions and Parameter Blocks (Quick Reference)

- **[v1.0]** v1.0-targeted functions **MUST NOT** use [CmdletBinding()] attribute → [Function Declaration and Structure](#function-declaration-and-structure)
- **[v1.0]** v1.0-targeted functions **MUST NOT** use [OutputType()] attribute → [Function Declaration and Structure](#function-declaration-and-structure)
- **[v1.0]** v1.0-targeted functions **MUST NOT** use begin/process/end blocks → [Function Declaration and Structure](#function-declaration-and-structure)
- **[v1.0]** v1.0-targeted functions **MUST NOT** support pipeline input → [Pipeline Behavior: Deliberately Disabled](#pipeline-behavior-deliberately-disabled)
- **[v1.0]** v1.0-targeted functions **MUST** use simple function keyword with param() block → [Function Declaration and Structure](#function-declaration-and-structure)
- **[v1.0]** Parameters **MUST** use strong typing → [Parameter Block Design: Detailed Analysis](#parameter-block-design-detailed-analysis)
- **[v1.0]** v1.0-targeted functions **MUST** use explicit return statements → [Return Semantics: Explicit Status Codes](#return-semantics-explicit-status-codes)
- **[v1.0]** Reference parameters ([ref]) **MUST** be used for outputs requiring caller modification → [Input/Output Contract: Reference Parameters](#inputoutput-contract-reference-parameters)
- **[v1.0]** Functions **MUST** return single integer status code (0=success, 1-5=partial, -1=failure) → [Return Semantics: Explicit Status Codes](#return-semantics-explicit-status-codes)
- **[v1.0]** Exception: Test-* functions **MAY** return Boolean when no practical error handling needed → [Return Semantics: Explicit Status Codes](#return-semantics-explicit-status-codes)
- **[v1.0]** Positional parameters **SHOULD** be supported for v1.0 usability → [Positional Parameter Support](#positional-parameter-support)
- **[v1.0]** v1.0-targeted functions **MUST** use trap-based error handling (not try/catch) → [Core Error Suppression Mechanism](#core-error-suppression-mechanism)
- **[Modern]** Modern functions and scripts **MUST** use [CmdletBinding()] attribute → [Rule: "Modern Advanced" Function/Script Requirements (v2.0+)](#rule-modern-advanced-functionscript-requirements-v20)
- **[Modern]** Modern functions and scripts **MUST** use [OutputType()] declaring singular primary type → [Rule: "Modern Advanced" Function/Script Requirements (v2.0+)](#rule-modern-advanced-functionscript-requirements-v20)
- **[Modern]** Modern functions and scripts **MUST** use streaming output (write objects directly to pipeline in loop) → [Rule: "Modern Advanced" Function/Script Requirements (v2.0+)](#rule-modern-advanced-functionscript-requirements-v20)
- **[Modern]** Modern functions and scripts **MUST** use try/catch for error handling → [Rule: "Modern Advanced" Function/Script Requirements (v2.0+)](#rule-modern-advanced-functionscript-requirements-v20)
- **[Modern]** Modern functions and scripts **MUST** use Write-Verbose and Write-Debug (not manual preference toggling) → [Rule: "Modern Advanced" Function/Script Requirements (v2.0+)](#rule-modern-advanced-functionscript-requirements-v20)
- **[Modern]** Exception: Modern functions and scripts **MAY** temporarily suppress $VerbosePreference for noisy nested commands using try/finally → ["Modern Advanced" Functions/Scripts: Exception for Suppressing Nested Verbose Streams](#modern-advanced-functionsscripts-exception-for-suppressing-nested-verbose-streams)
- **[Modern]** [Parameter(Mandatory=$true)] **SHOULD** be used only when function cannot work without value → ["Modern Advanced" Functions/Scripts: Parameter Validation and Attributes (`[Parameter()]`)](#modern-advanced-functionsscripts-parameter-validation-and-attributes-parameter)
- **[Modern]** [ValidateNotNullOrEmpty()] **SHOULD** be used for optional-but-not-empty parameters and for mandatory [string] parameters whose logic depends on a non-empty value → ["Modern Advanced" Functions/Scripts: Parameter Validation and Attributes (`[Parameter()]`)](#modern-advanced-functionsscripts-parameter-validation-and-attributes-parameter)
- **[Modern]** [ValidateRange(min, max)] **SHOULD** be used on numeric parameters with a constrained valid domain (counts, delays/timeouts, thresholds, percentages) so invalid input fails at parameter binding rather than producing a confusing downstream error → ["Modern Advanced" Functions/Scripts: Parameter Validation and Attributes (`[Parameter()]`)](#modern-advanced-functionsscripts-parameter-validation-and-attributes-parameter)
- **[Modern]** Multiple [OutputType()] **SHOULD** only be used for intentionally polymorphic returns → ["Modern Advanced" Functions/Scripts: Handling Multiple or Dynamic Output Types](#modern-advanced-functionsscripts-handling-multiple-or-dynamic-output-types)
- **[Modern]** Subset-only positional contracts **MUST** use `PositionalBinding = $false` with explicit `[Parameter(Position = N)]` → [Positional Parameter Support](#positional-parameter-support)
- **[All]** Functions **MUST** be atomic, reusable tools with single purpose → [Function Declaration and Structure](#function-declaration-and-structure)
- **[All]** Polymorphic parameters (multiple incompatible types) **SHOULD** be left un-typed or [object] → [Parameter Block Design: Detailed Analysis](#parameter-block-design-detailed-analysis)
- **[All]** [ref] **MUST** be used exclusively for output requiring write-back to caller scope → [Input/Output Contract: Reference Parameters](#inputoutput-contract-reference-parameters)
- **[All]** [ref] **MUST NOT** be used for complex objects that don't need modification → [Input/Output Contract: Reference Parameters](#inputoutput-contract-reference-parameters)

### Error Handling (Quick Reference)

- **[v1.0]** v1.0-targeted functions **MUST** use trap {} for error suppression → [Core Error Suppression Mechanism](#core-error-suppression-mechanism)
- **[Modern]** catch blocks **MUST NOT** be empty; default pattern is `Write-Debug` + `throw` → [Modern catch Block Requirements](#modern-catch-block-requirements)
- **[Modern]** Non-throwing catch (no `throw`) **MUST** have a documented non-throwing contract → [Modern catch Block Requirements](#modern-catch-block-requirements)
- **[Modern]** `throw "message"` and `throw ("fmt" -f $args)` **MUST NOT** be used in catch blocks intended to rethrow → [Rethrow Anti-Pattern](#rethrow-anti-pattern)
- **[Modern]** Exception wrapping **SHOULD** use `$PSCmdlet.ThrowTerminatingError()` with the original as `InnerException` → [Wrapping Exceptions with `$PSCmdlet.ThrowTerminatingError()`](#wrapping-exceptions-with-pscmdletthrowterminatingerror)
- **[Modern]** Variables referenced in `finally` that are assigned in `try` **MUST** be initialized before the `try` block → [Set-StrictMode Considerations for finally Blocks](#set-strictmode-considerations-for-finally-blocks)
- **[Modern]** In files bundled into a module or other aggregate script artifact, `Set-StrictMode -Version Latest` **MUST** be placed at script scope as the first executable statement in the file, after any `#requires` comments, `using` statements, and any script-level `[CmdletBinding()]`/`param` block → [Set-StrictMode Placement for Dot-Sourced Files](#set-strictmode-placement-for-dot-sourced-files)
- **[Modern]** In files intended to be dot-sourced directly into the caller's scope (test fixtures, ad-hoc scripts, build tooling), `Set-StrictMode -Version Latest` **MUST NOT** be placed at script scope; it **MUST** be placed inside the function body (as the first statement in `begin {}` when using a `begin/process/end` layout, or otherwise as the first statement in the function body) → [Set-StrictMode Placement for Dot-Sourced Files](#set-strictmode-placement-for-dot-sourced-files)

### File Writeability Testing (Quick Reference)

- **[All]** Scripts **MUST** verify file writeability before significant processing when writing output to files → [File Writeability Testing](#file-writeability-testing)
- **[v1.0]** v1.0-targeted scripts **MUST** use `.NET` approach (`Test-FileWriteability` function) → [Approaches](#approaches)
- **[Modern]** Scripts **MAY** use `.NET` or `try/catch` approach based on requirements → [Approaches](#approaches)

### Operating System Compatibility Checks (Quick Reference)

- **[All]** Scripts/functions supporting only specific operating systems **MUST** include OS compatibility checks → [Operating System Compatibility Checks](#operating-system-compatibility-checks)
- **[Modern]** PowerShell Core 6.0+ only scripts **SHOULD** use built-in `$IsWindows`, `$IsMacOS`, `$IsLinux` variables → [PowerShell Core 6.0+ OS Detection](#powershell-core-60-os-detection)
- **[v1.0]** Scripts supporting older versions **MUST** use `Test-Windows`, `Test-macOS`, `Test-Linux` functions from PowerShell_Resources → [Cross-Version OS Detection](#cross-version-os-detection)
- **[All]** Wrong OS errors **MUST** be reported consistently with existing error handling patterns → [Error Handling for Wrong OS](#error-handling-for-wrong-os)

### Output Formatting and Streams (Quick Reference)

- **[Modern]** Modern functions **MUST NOT** collect results in `List<T>` and return; **MUST** stream objects to pipeline → [Processing Collections in Modern Functions (Streaming Output)](#processing-collections-in-modern-functions-streaming-output)
- **[Modern]** Streaming function calls **SHOULD** be wrapped in @(...) to handle 0-1-Many problem → [Consuming Streaming Functions (The `0-1-Many` Problem)](#consuming-streaming-functions-the-0-1-many-problem)
- **[All]** Code **MUST** use Write-Warning for user-facing anomalies; Write-Debug for internal details → [Choosing Between Warning and Debug Streams](#choosing-between-warning-and-debug-streams)
- **[All]** .NET method output **MUST** be suppressed with [void](...), not | Out-Null → [Suppression of Method Output](#suppression-of-method-output)
- **[All]** `Write-Verbose` / `Write-Debug` **MUST NOT** emit raw PII, credentials, tokens, or other sensitive identifiers → [Sensitive Data in Verbose and Debug Streams](#sensitive-data-in-verbose-and-debug-streams)
- **[Modern]** Hot-path `Write-Verbose` / `Write-Debug` with string formatting **SHOULD** be guarded behind a preference check → [Performance-Sensitive `Write-Verbose` / `Write-Debug` in Hot Paths](#performance-sensitive-write-verbose--write-debug-in-hot-paths)
- **[All]** `-f` format operator **MUST** be applied inside the argument-expression parentheses of cmdlet calls → [String Formatting in Cmdlet Arguments (`-f` Scoping)](#string-formatting-in-cmdlet-arguments--f-scoping)

### Language Interop and .NET (Quick Reference)

- **[All]** `System.Collections.ArrayList` is deprecated and **MUST NOT** be used in new code; use `System.Collections.Generic.List[T]` instead → [.NET Interop Patterns: Safe and Documented](#net-interop-patterns-safe-and-documented)
- **[All]** Generic collections **MUST** provide specific type T (List[PSCustomObject], not List[object]) → [.NET Interop Patterns: Safe and Documented](#net-interop-patterns-safe-and-documented)

### Testing (Quick Reference)

- **[All]** New functions **SHOULD** have corresponding Pester tests when testability is a project requirement → [Testing with Pester](#testing-with-pester)
- **[All]** Test files **MUST** use `*.Tests.ps1` naming convention → [Test File Naming and Location](#test-file-naming-and-location)
- **[All]** Tests **MUST** use Pester 5.x syntax (BeforeAll, Describe, Context, It) → [Pester 5.x Syntax Requirements](#pester-5x-syntax-requirements)
- **[All]** Tests **SHOULD** use Arrange-Act-Assert pattern in test cases → [Test Structure: Arrange-Act-Assert](#test-structure-arrange-act-assert)
- **[All]** Tests **MUST** verify all documented return codes for functions → [Testing Return Code Conventions](#testing-return-code-conventions)
- **[All]** Test-* functions **MUST** have tests for both `$true` and `$false` cases → [Testing Return Code Conventions](#testing-return-code-conventions)
- **[All]** Tests asserting property names on `[pscustomobject]` **MUST** use order-insensitive comparisons → [Testing Property Names on PSCustomObject](#testing-property-names-on-pscustomobject)
- **[All]** Tests asserting strongly-typed array properties **MUST** check non-emptiness first, then assert the exact array type with `-is`; **MUST NOT** permit `[object[]]` fallback → [Testing Strongly-Typed Array Properties](#testing-strongly-typed-array-properties)
- **[All]** Test `BeforeAll` dot-sourcing **MUST** use the `Split-Path` + `Join-Path` two-step pattern; multi-segment `Join-Path` forms **MUST NOT** be used → [Test File Dot-Sourcing Pattern](#test-file-dot-sourcing-pattern)
- **[All]** Tests iterating a returned collection with `foreach` **MUST** assert non-emptiness before the loop → [Defensive Assertions Before Iteration and Indexing](#defensive-assertions-before-iteration-and-indexing)
- **[All]** Tests accessing specific indices of a returned collection **MUST** assert count before any indexed access → [Defensive Assertions Before Iteration and Indexing](#defensive-assertions-before-iteration-and-indexing)

<!-- rationale-anchor: executive-summary-author-profile -->

## Code Layout and Formatting

### Indentation Rules

Indentation **MUST** use four spaces for all logical blocks, including param declarations, conditional statements (if/else), loops, and function bodies—tabs **MUST NOT** be used.

### Brace Placement (OTBS)

Bracing **MUST** strictly adhere to the "One True Brace Style" (OTBS): opening braces **MUST** be placed at the end of the statement line, and closing braces **MUST** start on a new line, aligned with the opening statement. This applies universally to functions, conditionals, and most script blocks.

### Exception: catch, finally, and else Keywords

> **Exception for `catch`, `finally`, and `else`:** These keywords are the major exception to this rule. To be syntactically valid, the `catch`, `finally`, and `else` (or `elseif`) keywords **MUST** follow the closing brace (`}`) of the preceding block on the **same line**.
>
> **Compliant `if/else`:**
>
> ```powershell
> if ($condition) {
>     # ...
> } else {
>     # ...
> }
> ```
>
> **Compliant `try/catch`:**
>
> ```powershell
> try {
>     # ...
> } catch {
>     # ...
> } finally {
>     # ...
> }
> ```

### Operator Spacing and Alignment

Whitespace **MUST** be used precisely to enhance clarity: a single space **MUST** surround operators (e.g., -gt, =, -and, -eq) and **MUST** follow commas in parameter lists or arrays, with no unnecessary spaces inside parentheses, brackets, or subexpressions. Line terminators **SHOULD** avoid semicolons entirely, as they are unnecessary and can complicate edits. Line continuation **SHOULD** eschew backticks, preferring natural breaks at operators, pipes, or commas where possible—though in v1.0-focused code, long lines (e.g., in comments or regex patterns) **MAY** be tolerated for completeness. Line lengths **SHOULD** aim for under 115 characters where practical, but verbose comments **MAY** exceed this; this is acceptable per flexible guidelines, as it prioritizes detailed explanations without sacrificing core code readability.

Code **MUST** use **exactly one space** on either side of an operator (e.g., `=`, `-eq`). Code **MUST NOT** add extra whitespace to vertically align operators across multiple lines. This ensures compliance with standard PSScriptAnalyzer rules.

### Multi-line Method Indentation

When a method call (like `.Add()`) is wrapped (e.g., in a `[void]` cast) and its parameter is a multi-line script block (like a hashtable or `[pscustomobject]`), an **additional** level of indentation **MUST** be used for the contents of that script block.

```powershell
[void]($list.Add(
        [pscustomobject]@{
            # This line is indented three times:
            # 1. For the opening parenthesis
            # 2. For the .Add() method
            # 3. For the [pscustomobject]@{...} block
            Key = $Value
        }
    ))
```

### Blank Line Usage

Blank lines **SHOULD** be used sparingly but effectively: two **SHOULD** surround function definitions for visual separation, and single blanks **SHOULD** group related logic within functions (e.g., before a block comment or between setup and main logic). Files **MUST** end with a single blank line. Regions (#region ... #endregion) **SHOULD** logically group elements like licenses or helper sections, improving navigability in larger scripts.

**Important:** Blank lines **MUST** be completely empty—they **MUST NOT** contain any whitespace characters (spaces or tabs). This ensures consistency and prevents issues with some editors and linters.

**Compliant (blank line is truly empty):**

```powershell
{
    Invoke-SomeCmdlet

    Invoke-AnotherCmdlet
}
```

**Non-Compliant (blank line contains spaces):**

```powershell
{
    Invoke-SomeCmdlet

    Invoke-AnotherCmdlet
}
```

In the non-compliant example, the blank line (line 3) contains spaces, which is not allowed.

### Trailing Whitespace

**Lines MUST NOT end with trailing whitespace** (spaces or tabs). Most modern editors can be configured to automatically remove trailing whitespace on save, which is **RECOMMENDED**.

### Variable Delimiting in Strings

When a variable in an expandable string (`"..."`) is immediately followed by punctuation (especially a colon `:`) or other text that is not part of the variable name, it can cause parsing errors.

- **Non-Compliant (Ambiguous):**

  ```powershell
  $strMessage = "$SSORegion: Error occurred"
  ```

- **Compliant (Preferred):** Use curly braces to explicitly delimit the variable name:

  ```powershell
  $strMessage = "${SSORegion}: Error occurred"
  ```

- **Compliant (Also Preferred):** Use the `-f` format operator, which avoids all parsing ambiguity.

  ```powershell
  $strMessage = ("{0}: Error occurred" -f $SSORegion)
  ```

### String Formatting in Cmdlet Arguments (`-f` Scoping)

When a composed string expression is passed to a cmdlet or language construct using parentheses as the argument expression (for example `Write-Warning`, `Write-Host`, `Write-Error`, `Write-Verbose`, `Write-Debug`, `Write-Output`, or `throw (...)`), any `-f` format operator **MUST** be applied inside the same parentheses that form the argument expression. Once the argument-expression parentheses close, PowerShell may parse `-f` as a parameter token rather than as the format operator.

See also [Variable Delimiting in Strings](#variable-delimiting-in-strings) for broader guidance on composing strings safely.

- **Non-Compliant:**

  ```powershell
  Write-Warning ("foo {0}" + "bar") -f $x
  ```

- **Compliant (Preferred):** Place the `-f` operator inside the argument-expression parentheses:

  ```powershell
  Write-Warning (("foo {0}" + "bar") -f $x)
  ```

- **Compliant (Alternative):** Assign the formatted string to a variable first:

  ```powershell
  $strMessage = ("foo {0}" + "bar") -f $x
  Write-Warning $strMessage
  ```

### File Encoding

PowerShell `.ps1` source files **MUST** be saved as UTF-8 **without** a Byte Order Mark (BOM, `U+FEFF`), **unless** the script contains non-ASCII characters (e.g., accented characters, CJK text, or special symbols in string literals or comments) **and** must run on Windows PowerShell v5.1 or earlier. In that case, the file **MUST** either (a) be saved as UTF-8 **with** BOM so that Windows PowerShell can detect the encoding, or (b) remain ASCII-only so that BOM-less UTF-8 and the system ANSI code page produce identical byte sequences. This exception does not apply to PowerShell 7+, which defaults to UTF-8. Editors used for PowerShell development **SHOULD** be configured to save `.ps1` files as UTF-8 without BOM by default. If tool-specific examples are included, they **SHOULD** be presented as examples rather than assumptions that all environments behave identically.

### Programmatic File Writing Encoding

When writing or generating text files programmatically (for example, build scripts producing `.psm1` files or code generators producing repository artifacts), the output encoding **MUST** be specified explicitly so results are deterministic across PowerShell versions.

The preferred cross-version pattern for UTF-8 without BOM **SHOULD** use a `.NET` encoding object:

```powershell
$objUtf8NoBomEncoding = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($strOutputFilePath, $strFileContent, $objUtf8NoBomEncoding)
```

`Set-Content` and similar cmdlets **MUST** include an explicit `-Encoding` parameter when writing generated artifacts, because default encoding behavior varies across PowerShell versions and can make output non-deterministic.

`-Encoding utf8NoBOM` **MUST NOT** be the required cross-version pattern, because it is unavailable in Windows PowerShell 5.1. For code that explicitly targets only PowerShell 7+, it **MAY** be used.

### Line Endings for Byte-Exact Text Artifacts

When a PowerShell script or test produces text output whose identity is its exact byte sequence (for example, golden baselines, snapshot fixtures, hash inputs, or signed payloads), the producer **MUST** normalize line endings to LF at serialization time. Consumers reading the entire file as text **MUST NOT** use `Get-Content` without `-Raw`; they **MUST** use `Get-Content -Raw` or the equivalent .NET `[System.IO.File]::ReadAllText()` API. Those text-returning APIs are acceptable only for text-level comparison when the encoding convention, including BOM presence or absence, is already fixed. For true byte-for-byte identity (for example, hash inputs and signed payloads), consumers **MUST** use `[System.IO.File]::ReadAllBytes()`, because `Get-Content -Raw` and `[System.IO.File]::ReadAllText()` decode bytes into a `System.String` and can mask byte-level differences such as a UTF-8 BOM or other encoding distinctions.

Cross-version differences in `ConvertTo-Json` and other serializers can emit CRLF on some hosts and LF on others, causing byte-exact comparisons to fail unless line endings are normalized in memory before writing or comparing. The recommended pattern is to normalize CRLF to LF immediately after serialization:

```powershell
$strJson = $objInput | ConvertTo-Json -Depth 5
$strJson = $strJson -replace "`r`n", "`n"
# If the artifact convention requires a trailing LF, also append one:
# $strJson = $strJson + "`n"
```

`Get-Content` without `-Raw` strips line terminators and returns an array of lines rather than the original on-disk text, so it **MUST NOT** be used for byte-exact comparison. Use `Get-Content -Raw` or `[System.IO.File]::ReadAllText()` to read the decoded text as a single string when the comparison is text-level, or use `[System.IO.File]::ReadAllBytes()` when true byte-for-byte identity is required. When using the .NET APIs, paths **MUST** first be resolved to an absolute filesystem path per [Resolving Paths for .NET Static Methods](#resolving-paths-for-net-static-methods).

## Capitalization and Naming Conventions

Public identifiers (functions, parameters, properties) **MUST** use PascalCase. Keywords (`function`, `param`, `if`, `else`, `return`, `trap`) **MUST** be lowercase. Operators (`-gt`, `-eq`) **MUST** be lowercase with surrounding spaces. Local variables **MUST** use camelCase with a type-hinting prefix (e.g., `$strMessage`, `$intReturnValue`, `$boolResult`, `$arrElements`).

<!-- rationale-anchor: overview-of-observed-naming-discipline -->

### Script and Function Naming: Full Explicit Form

**Function names** **MUST** strictly adhere to the **Verb-Noun** pattern using **approved verbs** and **singular nouns**, rendered in **PascalCase**. Examples include:

- `Convert-StringToObject`
- `Get-ReferenceToLastError`
- `Test-ErrorOccurred`
- `Split-StringOnLiteralString`

### Script and Function Naming: Approved Verbs

Functions **MUST** use approved PowerShell verbs. Run `Get-Verb` for the complete list. If a verb (like `Review` or `Check`) is not approved, choose the closest alternative (e.g., `Get-` or `Test-`). For the full reference, see [Microsoft's Approved Verbs](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.5).

> **Note:** The term *verb* in PowerShell describes any word implying an action, even if it isn't a standard English verb (e.g., `New`).

**Reserved verbs** (do not use): `ForEach` (`foreach`), `Ping` (`pi`), `Sort` (`sr`), `Tee` (`te`), `Where` (`wh`).

#### Similar Verbs for Different Actions

The following similar verbs represent different actions.

##### `New` vs. `Add`

Use the `New` verb to create a new resource. Use the `Add` to add something to an existing container or resource. For example, `Add-Content` adds output to an existing file.

##### `New` vs. `Set`

Use the `New` verb to create a new resource. Use the `Set` verb to modify an existing resource, optionally creating it if it doesn't exist, such as the `Set-Variable` cmdlet.

##### `Find` vs. `Search`

Use the `Find` verb to look for an object. Use the `Search` verb to create a reference to a resource in a container.

##### `Get` vs. `Read`

Use the `Get` verb to obtain information about a resource (such as a file) or to obtain an object with which you can access the resource in future. Use the `Read` verb to open a resource and extract information contained within.

##### `Invoke` vs. `Start`

Use the `Invoke` verb to perform synchronous operations, such as running a command and waiting for it to end. Use the `Start` verb to begin asynchronous operations, such as starting an autonomous process.

##### `Ping` vs. `Test`

Use the `Test` verb.

#### Common Verbs

| Verb (alias) | Synonyms to avoid |
| --- | --- |
| `Add` (`a`) | Append, Attach, Concatenate, Insert |
| `Clear` (`cl`) | Flush, Erase, Release, Unmark, Unset, Nullify |
| `Close` (`cs`) | |
| `Copy` (`cp`) | Duplicate, Clone, Replicate, Sync |
| `Enter` (`et`) | Push, Into |
| `Exit` (`ex`) | Pop, Out |
| `Find` (`fd`) | Search |
| `Format` (`f`) | |
| `Get` (`g`) | Read, Open, Cat, Type, Dir, Obtain, Dump, Acquire, Examine, Find, Search |
| `Hide` (`h`) | Block |
| `Join` (`j`) | Combine, Unite, Connect, Associate |
| `Lock` (`lk`) | Restrict, Secure |
| `Move` (`m`) | Transfer, Name, Migrate |
| `New` (`n`) | Create, Generate, Build, Make, Allocate |
| `Open` (`op`) | |
| `Optimize` (`om`) | |
| `Pop` (`pop`) | |
| `Push` (`pu`) | |
| `Redo` (`re`) | |
| `Remove` (`r`) | Clear, Cut, Dispose, Discard, Erase |
| `Rename` (`rn`) | Change |
| `Reset` (`rs`) | |
| `Resize` (`rz`) | |
| `Search` (`sr`) | Find, Locate |
| `Select` (`sc`) | Find, Locate |
| `Set` (`s`) | Write, Reset, Assign, Configure, Update |
| `Show` (`sh`) | Display, Produce |
| `Skip` (`sk`) | Bypass, Jump |
| `Split` (`sl`) | Separate |
| `Step` (`st`) | |
| `Switch` (`sw`) | |
| `Undo` (`un`) | |
| `Unlock` (`uk`) | Release, Unrestrict, Unsecure |
| `Watch` (`wc`) | |

#### Communications Verbs

| Verb (alias) | Synonyms to avoid |
| --- | --- |
| `Connect` (`cc`) | Join, Telnet, Login |
| `Disconnect` (`dc`) | Break, Logoff |
| `Read` (`rd`) | Acquire, Prompt, Get |
| `Receive` (`rc`) | Read, Accept, Peek |
| `Send` (`sd`) | Put, Broadcast, Mail, Fax |
| `Write` (`wr`) | Put, Print |

#### Data Verbs

| Verb (alias) | Synonyms to avoid |
| --- | --- |
| `Backup` (`ba`) | Save, Burn, Replicate, Sync |
| `Checkpoint` (`ch`) | Diff |
| `Compare` (`cr`) | Diff |
| `Compress` (`cm`) | Compact |
| `Convert` (`cv`) | Change, Resize, Resample |
| `ConvertFrom` (`cf`) | Export, Output, Out |
| `ConvertTo` (`ct`) | Import, Input, In |
| `Dismount` (`dm`) | Unmount, Unlink |
| `Edit` (`ed`) | Change, Update, Modify |
| `Expand` (`en`) | Explode, Uncompress |
| `Export` (`ep`) | Extract, Backup |
| `Group` (`gp`) | |
| `Import` (`ip`) | BulkLoad, Load |
| `Initialize` (`in`) | Erase, Init, Renew, Rebuild, Reinitialize, Setup |
| `Limit` (`l`) | Quota |
| `Merge` (`mg`) | Combine, Join |
| `Mount` (`mt`) | Connect |
| `Out` (`o`) | |
| `Publish` (`pb`) | Deploy, Release, Install |
| `Restore` (`rr`) | Repair, Return, Undo, Fix |
| `Save` (`sv`) | |
| `Sync` (`sy`) | Replicate, Coerce, Match |
| `Unpublish` (`ub`) | Uninstall, Revert, Hide |
| `Update` (`ud`) | Refresh, Renew, Recalculate, Re-index |

#### Diagnostic Verbs

| Verb (alias) | Synonyms to avoid |
| --- | --- |
| `Debug` (`db`) | Diagnose |
| `Measure` (`ms`) | Calculate, Determine, Analyze |
| `Ping` (`pi`) — *deprecated; use `Test`* | |
| `Repair` (`rp`) | Fix, Restore |
| `Resolve` (`rv`) | Expand, Determine |
| `Test` (`t`) | Diagnose, Analyze, Salvage, Verify |
| `Trace` (`tr`) | Track, Follow, Inspect, Dig |

#### Lifecycle Verbs

| Verb (alias) | Synonyms to avoid |
| --- | --- |
| `Approve` (`ap`) | |
| `Assert` (`as`) | Certify |
| `Build` (`bd`) — *PS 6+* | |
| `Complete` (`cp`) | |
| `Confirm` (`cn`) | Acknowledge, Agree, Certify, Validate, Verify |
| `Deny` (`dn`) | Block, Object, Refuse, Reject |
| `Deploy` (`dp`) — *PS 6+* | |
| `Disable` (`d`) | Halt, Hide |
| `Enable` (`e`) | Start, Begin |
| `Install` (`is`) | Setup |
| `Invoke` (`i`) | Run, Start |
| `Register` (`rg`) | |
| `Request` (`rq`) | |
| `Restart` (`rt`) | Recycle |
| `Resume` (`ru`) | |
| `Start` (`sa`) | Launch, Initiate, Boot |
| `Stop` (`sp`) | End, Kill, Terminate, Cancel |
| `Submit` (`sb`) | Post |
| `Suspend` (`ss`) | Pause |
| `Uninstall` (`us`) | |
| `Unregister` (`ur`) | Remove |
| `Wait` (`w`) | Sleep, Pause |

#### Security Verbs

| Verb (alias) | Synonyms to avoid |
| --- | --- |
| `Block` (`bl`) | Prevent, Limit, Deny |
| `Grant` (`gr`) | Allow, Enable |
| `Protect` (`pt`) | Encrypt, Safeguard, Seal |
| `Revoke` (`rk`) | Remove, Disable |
| `Unblock` (`ul`) | Clear, Allow |
| `Unprotect` (`up`) | Decrypt, Unseal |

#### Other Verbs

| Verb (alias) | Synonyms to avoid |
| --- | --- |
| `Use` (`u`) | |

### Script and Function Naming: Nouns

**Noun Singularity:** The noun **MUST** be singular, even if the function returns multiple objects. This is a core PowerShell convention (e.g., `Get-Process`, `Get-ChildItem`) and corresponds to the **PSScriptAnalyzer `PSUseSingularNouns`** rule. The noun describes the *type* of object the function works with, not the *quantity* of its output.

- **Correct:** `Get-Process` (returns *many* process objects)
- **Incorrect:** `Get-Processes`
- **Correct:** `Expand-TrustPrincipal` (operates on *one* principal node, even if it results in many values)
- **Incorrect:** `Expand-TrustPrincipals`

### Module Naming: Noun-Based Containers

**Modules are treated as .NET Namespaces or Class Libraries (Containers), not Actions.** Therefore, Module names **MUST** be **PascalCase Nouns** or **Noun Phrases**.

- **Correct:** `ObjectFlattener`, `NetworkManager`, `DataParser`
- **Incorrect:** `FlattenObject`, `ManageNetwork`, `ParseData`

Module names **MUST NOT** be compromised for the sake of keyword searching.

**[Modern]** In module-based code, the **Module Manifest (`.psd1`)** handles discoverability. The `Tags` key in the manifest **MUST** be populated aggressively with relevant keywords (including verbs) to ensure the module is found during searches, while keeping the architectural name pure.

### Do Not Use Aliases

Aliases (e.g., `gci`, `gps`) or abbreviated forms **MUST NOT** appear in the code. Even common operations **MUST** use full command names.

Furthermore, **Modules MUST NOT export "Compatibility Aliases"** solely to bridge a gap between a module name and a command name (e.g., do **not** export `Flatten-Object` when the correct command is `ConvertTo-FlatObject`).

**Exceptions:**

Aliases **MAY** only be exported in a Module Manifest if they provide genuine short-hand convenience for *interactive* users (e.g., `cfo` for `ConvertTo-FlatObject`) and are strictly documented as optional. They **MUST NOT** be used to mask non-approved verbs.

### Parameter Naming

**Parameter names** **MUST** use PascalCase and be highly descriptive (e.g., `$ReferenceToResultObject`, `$StringToProcess`, `$PSVersion`). The `ReferenceTo` prefix for `[ref]` parameters signals **pass-by-reference** semantics. [ref] **MUST** be used only when data needs to be written back to the caller’s scope; for passing complex objects that do not need modification, pass by value.

### Local Variable Naming: Type-Prefixed camelCase

Local variables follow a **Hungarian-style notation** combining a **type-hinting prefix** with **descriptive `camelCase`**. **The descriptive portion of each name—everything after the type prefix—MUST be fully spelled out; abbreviations and shorthand are not permitted.**

- **Prefixes:** `$str` (string), `$int` (integer), `$dbl` (double), `$bool` (boolean), `$arr` (array), `$obj` (object/default), `$hashtable` (hashtable), `$list` (generic list), etc.
- **Default prefix — `obj`:** Use `$obj` for any .NET type that does not have a dedicated approved prefix above. This includes enum values (e.g., `$objActionPreference`), complex .NET reference types (e.g., `$objMemoryStream`), and `[pscustomobject]` instances (e.g., `$objResult`).
- **Open-ended list:** The "etc." above means additional descriptive prefixes such as `$ref` and `$version` are permitted when they provide immediate type clarity (e.g., `$refLastKnownError`, `$versionPowerShell`). However, authors **SHOULD NOT** invent ad hoc abbreviated type-name prefixes (e.g., do **not** use `$enumActionPreference`—use `$objActionPreference` instead).
- **Descriptive Name:** The name **MUST** be **fully spelled out**.

**Examples:**

- `$strPolicyString` (not `$strS` or `$strPolicy`)
- `$objMemoryStream` (not `$objMs` or `$stream`)
- `$arrStatements` (not `$arrStmt` or `$stmts`)
- `$strMessage`
- `$intReturnValue`
- `$boolResult`
- `$arrElements`
- `$hashtableSettings`
- `$objActionPreference`
- `$objResult`
- `$refLastKnownError`
- `$versionPowerShell`

<!-- rationale-anchor: local-variable-naming-defensive-design-philosophy -->

### Path and Scope Handling

Code **SHOULD** avoid relative paths (`.`, `..`) and the **home directory shortcut `~`** entirely. This is due to:

- `~` behavior varies by provider (FileSystem vs. Registry vs. others).
- Relative paths depend on `[Environment]::CurrentDirectory`, which **MAY** diverge from `$PWD` when calling .NET methods or external tools.

Instead, **explicit scoping** **SHOULD** be used:

```powershell
$global:ErrorActionPreference
```

For shared state, use:

- `$Script:varName` for module/script-level variables
- `$Global:varName` for session-wide state

This eliminates environment-dependent behavior and ensures deterministic execution.

> **Note:** The guidance to avoid relative paths targets bare `.` / `..` paths
> that depend on `[Environment]::CurrentDirectory` or `$PWD`. Paths anchored to
> `$PSScriptRoot` — such as `"$PSScriptRoot/../config.json"` or
> `Join-Path -Path $PSScriptRoot -ChildPath '../src/Helper.ps1'` — are
> **deterministic** because they resolve relative to the executing script's
> directory, not the process working directory.

**Non-compliant** (CWD-dependent):

```powershell
# Bad — result changes depending on where the caller invoked the script:
Get-Content -Path '../config.json'
```

**Compliant** (`$PSScriptRoot`-anchored):

```powershell
# Good — always resolves relative to the script's own directory:
Get-Content -LiteralPath (Join-Path -Path $PSScriptRoot -ChildPath '../config.json')
```

#### Resolving Paths for .NET Static Methods

**[All]** When a script or function passes a user-provided or otherwise unresolved PowerShell path to a .NET file API (for example, `[System.IO.File]::WriteAllText()`, `[System.IO.File]::WriteAllLines()`, or other `System.IO.*` methods that expect a file-system path), the path **MUST** first be converted to an absolute file-system path via `$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath()`. This method assumes the path resolves through the FileSystem provider; non-FileSystem provider paths (such as `HKLM:\…` or `Cert:\…`) **MUST NOT** be passed to `System.IO.*` methods.

**Compliant:**

```powershell
# Resolve the PowerShell path before passing it to .NET
$strOutputPath = '.\output.txt'
$strOutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($strOutputPath)
[System.IO.File]::WriteAllText($strOutputPath, $strContent, $objEncoding)
```

**Non-Compliant:**

```powershell
# Non-Compliant: passing an unresolved PowerShell path directly to a .NET method
$strOutputPath = '.\output.txt'
[System.IO.File]::WriteAllText($strOutputPath, $strContent, $objEncoding)
```

<!-- rationale-anchor: options-for-local-variable-prefixes-analysis -->
<!-- rationale-anchor: summary-naming-as-defensive-architecture -->

## Documentation and Comments

<!-- rationale-anchor: overview-of-documentation-philosophy -->

### Comment-Based Help: Structure and Format

All functions **MUST** include **full comment-based help** using **single-line comments** (`#`) with **dotted keywords** placed **inside the function**, **immediately above the `param` block**.

**Required sections**: `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER` (one per declared parameter, if any), `.EXAMPLE` (multiple with input, output, and explanation), `.INPUTS`, `.OUTPUTS` (document all outputs; when integer status codes are used, include full mapping of codes to meanings), `.NOTES` (positional parameters, versioning).

> **Note:** If a function declares no parameters in its `param()` block (excluding implicit common parameters), the `.PARAMETER` section is omitted entirely.

**Example of complete help block** (from a generic parsing function):

```powershell
# .SYNOPSIS
# Processes a string input with flexible handling of non-standard formats.
# .DESCRIPTION
# Attempts direct processing. On failure, iteratively handles problematic segments...
# .PARAMETER ReferenceToResultObject
# Reference to store the resulting object.
# .EXAMPLE
# $result = $null; $extras = @('','','','',''); $status = Process-String ([ref]$result) ([ref]$extras) 'input-string'
# # $status = 4, $result = processed value, $extras[3] = 'leftover'
# .INPUTS
# None. You can't pipe objects to this function.
# .OUTPUTS
# [int] Status code: 0=success, 1-5=partial success with extras, -1=failure
# .NOTES
# This function/script supports positional parameters:
#   Position 0: ReferenceToResultObject
#   Position 1: ReferenceArrayOfExtraStrings
#   Position 2: InputString
# Version: 1.0.20250218.0
```

> **Note:** The terse form is acceptable where brevity is preferred, for
> example: `# Supports positional parameters.` followed by
> `# Version: 1.0.20250218.0`. The multi-line format shown above is
> **RECOMMENDED** because it explicitly identifies which parameters are
> positional and at which positions. See
> [Positional Parameter Support](#positional-parameter-support) for full
> guidance.

#### Inline Comments Within `.EXAMPLE` Blocks

When writing explanatory or output-description lines within a `.EXAMPLE` section of comment-based help, use **double `#`** — that is, `# # <text>`. The first `#` is the standard comment-based help line prefix (required for all help content). The second `#` creates a PowerShell comment within the rendered example output so that:

1. `Get-Help -Examples` renders the line as `# <text>`, which is valid PowerShell syntax and can be safely copy-pasted.
2. The explanatory text is visually distinct from executable code lines in the example.

**Compliant** — explanatory lines use `# #`:

```powershell
# .EXAMPLE
# $arrRows = @(ConvertTo-VectorRow -Counts $arrCounts -FeatureIndexObject $objIndex)
# # $arrRows[0].PrincipalKey = 'user-abc'
# # $arrRows[0].Vector = [double[]] (fixed-length array)
```

Rendered by `Get-Help`:

```text
$arrRows = @(ConvertTo-VectorRow -Counts $arrCounts -FeatureIndexObject $objIndex)
# $arrRows[0].PrincipalKey = 'user-abc'
# $arrRows[0].Vector = [double[]] (fixed-length array)
```

**Non-compliant** — single `#` for explanation text:

```powershell
# .EXAMPLE
# $arrRows = @(ConvertTo-VectorRow -Counts $arrCounts -FeatureIndexObject $objIndex)
# Returns vector row objects with PrincipalKey, Vector, and TotalActions.
```

Rendered by `Get-Help`:

```text
$arrRows = @(ConvertTo-VectorRow -Counts $arrCounts -FeatureIndexObject $objIndex)
Returns vector row objects with PrincipalKey, Vector, and TotalActions.
```

The non-compliant form renders bare prose that (a) is not valid PowerShell, (b) can be confused with actual command output, and (c) is not safely copy-pasteable.

**Non-compliant** — triple `#` for explanation text:

```powershell
# .EXAMPLE
# $arrRows = @(ConvertTo-VectorRow -Counts $arrCounts -FeatureIndexObject $objIndex)
# # # Returns vector row objects with PrincipalKey and Vector.
```

Rendered by `Get-Help`:

```text
$arrRows = @(ConvertTo-VectorRow -Counts $arrCounts -FeatureIndexObject $objIndex)
## Returns vector row objects with PrincipalKey and Vector.
```

Lines within `.EXAMPLE` blocks that are intended to render as PowerShell comments in `Get-Help` output **MUST** use exactly two `#` characters (`# # <text>`). Using three or more `#` characters (for example, `# # # <text>`) is non-compliant because it does not preserve the intended rendered form of `# <text>` in `Get-Help` output.

---

### Help Content Quality: High Standards

1. **Behavioral Contracts**: Every possible output/return value documented with **exact type and meaning** (in .OUTPUTS) and **example** (in .EXAMPLE blocks); when integer status codes are used, include full mapping of codes to meanings.
2. **Edge Case Coverage**: Examples include valid input, invalid segments, overflow conditions, excess parts.
3. **Positional Parameter Support**: `.NOTES` explicitly documents positional ordering.
4. **Versioning**: Includes internal version in `.NOTES` for change tracking.

---

### Private/Internal Helper Function Documentation

**[All]** If a function is intended only for internal use and is not part of the script, module, or tool's public API surface, its `.NOTES` section **MUST** begin with a clear private-helper banner. That banner **MUST** state that the function is not part of the public API surface, and **MUST** warn that parameters, return shape, and positional contract may change without notice.

**[Modern]** In module-based code, a function intentionally omitted from the module manifest's `FunctionsToExport` is treated as a private/internal helper for purposes of the documentation requirements above.

All other comment-based help requirements (`.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`, `.EXAMPLE`, `.INPUTS`, `.OUTPUTS`, `.NOTES`) still apply to private/internal helpers — the banner is an addition, not a replacement.

**Compliant — private/internal helper with required `.NOTES` banner:**

```powershell
function Convert-RawRecord {
    # .SYNOPSIS
    # Transforms a raw input record into a normalized internal format.
    # .DESCRIPTION
    # Parses the raw record hashtable, validates required keys, and
    # returns a normalized [pscustomobject]. This function is used
    # only by Import-DataSet and is not part of the public API.
    # .PARAMETER ReferenceToResultObject
    # Reference to store the resulting normalized object.
    # .PARAMETER RawRecord
    # The raw hashtable to normalize.
    # .EXAMPLE
    # $objResult = $null
    # $intReturnCode = Convert-RawRecord ([ref]$objResult) $hashtableInput
    # # $intReturnCode = 0, $objResult contains the normalized record
    # .INPUTS
    # None. You can't pipe objects to this function.
    # .OUTPUTS
    # [int] Status code: 0 = success, -1 = failure (missing keys)
    # .NOTES
    # PRIVATE/INTERNAL HELPER — This function is not part of the
    # public API surface. Parameters, return shape, and positional
    # contract may change without notice.
    # This function supports positional parameters
    # (internal-caller contract only; subject to change):
    #   Position 0: ReferenceToResultObject
    #   Position 1: RawRecord
    # Version: 1.0.20260415.0
    param (
        [ref]$ReferenceToResultObject,
        [hashtable]$RawRecord
    )

    # Implementation omitted for brevity
}
```

---

### Inline Comments: Purpose and Placement

Inline comments **SHOULD** focus on **"why"** rather than **"what"**, be used only when behavior is non-obvious, and be aligned with at least two spaces from code.

---

### Structural Documentation: Regions and Licensing

The script uses **`#region` / `#endregion`** blocks to create **logical code folding**:

```powershell
#region License ########################################################
# Full MIT-style license
#endregion License ########################################################

#region FunctionsToSupportErrorHandling ############################
# Get-ReferenceToLastError
# Test-ErrorOccurred
#endregion FunctionsToSupportErrorHandling ############################
```

For distributable helper functions, the structure **MUST** be: function declaration, comment-based help, `param()` block, then `#region License` block.

**Example:**

```powershell
function Get-Example {
    # .SYNOPSIS
    # Example function with license
    # .DESCRIPTION
    # This demonstrates the correct placement of param() before license.
    # .NOTES
    # Version: 1.0.20260109.0

    param(
        [string]$Parameter
    )

    #region License ########################################################
    # MIT License or other license text
    #endregion License ########################################################

    # Function implementation
    return 0
}
```

---

### Function and Script Versioning

All distributable functions and scripts **MUST** include a version number in the `.NOTES` section of their comment-based help. This version number provides critical change tracking and **MUST** follow a strict, `[System.Version]`-compatible format: `Major.Minor.Build.Revision`.

- **`Major`**: Increment the **Major** version (e.g., `1.0.20251103.0` to `2.0.20251230.0`) **any time a breaking change is introduced**. Breaking changes include:
  - Removing or renaming a function, parameter, or public interface
  - Changing parameter types in incompatible ways
  - Altering return types or output formats that break existing consumers
  - Any modification that requires users to update their code
- **`Minor`**: Increment the **Minor** version (e.g., `1.0.20251103.0` to `1.1.20251230.0`) **any time a feature or function change is introduced that is non-breaking**. This includes:
  - Adding new functions or capabilities
  - Adding new optional parameters
  - Enhancing existing functionality without changing interfaces
  - Performance improvements that don't affect behavior
- **`Build`**: This component **MUST** be an integer in the format **`YYYYMMDD`**, representing the date the code was last modified. This date **MUST** be updated to the **current date** for *any* modification, however minor.
- **`Revision`**: This component is typically `0` for the first commit of the day. It **SHOULD** be **bumped any time a minor change is made on the same date a change has already been made**. Revisions are typically reserved for:
  - Trivial edits (typos, formatting, comments)
  - Bug fixes that don't change functionality
  - Documentation-only updates
  - Multiple commits on the same day

**Compliant Example:**

```powershell
# .NOTES
# Version: 1.2.20251230.0
```

This example assumes that the current date is December 30, 2025. In any code you write, use the current date in place of December 30, 2025.

---

### Parameter Documentation Placement: Strategic Choice

Parameter help **SHOULD** be centralized in the comment-based help block, not duplicated above individual parameters in the `param` block.

---

### Help Format Options: Comparison

Comment-based help **MUST** use single-line comments (`#`) for v1.0-compatible code. Block comments (`<# ... #>`) **MUST NOT** be used when v1.0 compatibility is required.

> **⚠ PowerShell v1.0 Compatibility Warning:** Block comments (`<# ... #>`) were introduced in PowerShell v2.0. In PowerShell v1.0, attempting to use block comments results in a **parser error** that prevents the script from running. Scripts targeting v1.0 compatibility **MUST** use only single-line comments (`#`). This applies to both comment-based help and general-purpose comments.

**Example — what fails in PowerShell v1.0:**

```powershell
# This will cause a parser error in PowerShell v1.0:
function Get-Example {
    <#
    .SYNOPSIS
        Example function.
    #>
    param ()
}
```

**Correct approach for v1.0 compatibility:**

```powershell
# This works in all PowerShell versions, including v1.0:
function Get-Example {
    # .SYNOPSIS
    #     Example function.
    param ()
}
```

---

<!-- rationale-anchor: summary-documentation-as-complete-specification -->

## Functions and Parameter Blocks

<!-- rationale-anchor: overview-of-function-architecture -->

### Function Declaration and Structure

All functions **MUST** follow a **strict, uniform template**:

```powershell
function Verb-Noun {
    # Full comment-based help block
    param (
        [type]$ParameterName1,
        [type]$ParameterName2 = default
    )
    # Implementation
    return $statusCode
}
```

**Key characteristics**:

1. **No `[CmdletBinding()]`** → intentional omission for v1.0 compatibility; v1.0-targeted functions **MUST NOT** use this
2. **No pipeline blocks** → `process` block would imply pipeline input, which **MUST NOT** be supported in v1.0-targeted functions
3. **Explicit `return`** → **MUST** be used to guarantee single-value output and prevent accidental pipeline leakage
4. **Strongly typed `param` block** → **MUST** validate input at parse time
5. `[CmdletBinding()]` and `[OutputType()]` Present → **MUST** be included for modern, non-v1.0 functions where either the function or script it sits in relies on external dependencies (e.g., a module that only supports Windows PowerShell v5.1 or PowerShell 7.x), making the function explicitly non-v1.0-compatible.

---

### Parameter Block Design: Detailed Analysis

The `param` block is the **primary contract** between caller and function. Every parameter **MUST** be:

- **Strongly typed** using .NET types
- **Fully documented** in comment-based help
- **Defaulted where appropriate** to ensure predictable behavior

**Exception for Polymorphic Parameters:**

In rare cases, a function **MAY** be intentionally designed to accept a parameter that can be one of several different, incompatible types (e.g., a string *or* an object). This is common in "safe wrapper" functions that process dynamic input, such as the `Principal` element from an IAM policy.

In this scenario, the parameter **SHOULD** be left **un-typed** (or explicitly typed as `[object]`). The function's internal logic is then responsible for inspecting the received object's type (e.g., using `if ($MyParameter -is [string])`) and handling it appropriately. This pattern **SHOULD** be used sparingly and only when required by the function's core purpose.

**Parameter typing examples**:

| Parameter | Type | Purpose |
| --- | --- | --- |
| `$ReferenceToResultObject` | `[ref]` | Output: stores processed result (used only when modification in caller scope is needed) |
| `$ReferenceArrayOfExtraStrings` | `[ref]` | Output: array for additional data (used only for write-back) |
| `$StringToProcess` | `[string]` | Input: string to handle |
| `$PSVersion` | `[version]` | Optional: runtime version for optimization |

**Reference parameters (`[ref]`)** are used **exclusively for output** where data **MUST** be written back to the caller's scope—a deliberate pattern to:

- Return multiple complex values
- Avoid pipeline interference
- Maintain v1.0 compatibility
- Ensure caller controls variable lifetime

[ref] **SHOULD NOT** be used for passing complex objects that do not require modification, as PowerShell passes object references by default without performance gains from [ref] in such cases.

**Default values** are used judiciously:

```powershell
[string]$StringToProcess = '',
[version]$PSVersion = ([version]'0.0')
```

This ensures the function can be called with minimal arguments while maintaining type safety.

---

### Return Semantics: Explicit Status Codes

Every v1.0-targeted function **MUST** return a **single integer status code** via explicit `return` statement:

| Code | Meaning |
| --- | --- |
| `0` | Full success |
| `1–5` | Partial success with additional data |
| `-1` | Complete failure |

**Exception for `Test-*` Functions:**

For PowerShell v1.0 scripts/functions that use the `Test-` verb (in a Verb-Noun naming convention) and are **not reasonably anticipated to encounter errors that the caller needs to detect and react to programmatically**, a **Boolean return** **MAY** be used instead of an integer status code.

This exception applies when:

1. The function's verb is `Test-`
2. The function is designed to return a simple true/false result (e.g., testing for the existence of a condition)
3. There is no practical need for the caller to distinguish between different error conditions or partial success states

**Example of Compliant Test Function with Boolean Return:**

```powershell
function Test-PathExists {
    # .SYNOPSIS
    # Tests whether a path exists.
    # .DESCRIPTION
    # Returns $true if the path exists, $false otherwise.
    # .PARAMETER Path
    # The path to test.
    # .OUTPUTS
    # [bool] $true if the path exists, $false otherwise.
    param (
        [string]$Path
    )

    return (Test-Path -LiteralPath $Path)
}
```

For `Test-*` functions that might encounter meaningful errors (e.g., access denied, network issues) that the caller **SHOULD** be able to detect, the standard integer status code pattern **SHOULD** still be used.

---

### Input/Output Contract: Reference Parameters

Functions **MUST** use **`[ref]` parameters** to return complex data only when write-back is required:

```powershell
[ref]$ReferenceToResultObject     → [object]
[ref]$ReferenceArrayOfExtraStrings → [string[]]
```

[ref] **SHOULD NOT** be used for passing complex objects that do not require modification, as PowerShell passes object references by default.

---

### Pipeline Behavior: Deliberately Disabled

In v1.0-targeted functions, pipeline input **MUST** be **explicitly rejected**:

- No `ValueFromPipeline` attributes
- `.INPUTS` section states "None"
- No `process` block

In scripts requiring modern PowerShell, pipeline support is added as needed.

---

### Positional Parameter Support

Functions **SHOULD** support **positional parameter binding** for v1.0 usability:

```powershell
# Named parameters
Process-String ([ref]$r) ([ref]$e) $str

# Positional parameters (documented in .NOTES)
Process-String ([ref]$r) ([ref]$e) $str $psver
```

**Important distinction:** While functions **SHOULD** support positional parameters in their declarations (for flexibility and v1.0 usability), function **calls** throughout the codebase **SHOULD** use named parameters for clarity and maintainability. The PSScriptAnalyzer configuration enforces this via the `PSAvoidUsingPositionalParameters` rule.

This enables:

- **Interactive use** without naming
- **Script compatibility** with older calling patterns
- **Flexibility** without sacrificing type safety

#### Documenting Positional Parameters in `.NOTES`

When a function or script supports positional parameters, the `.NOTES` section **SHOULD** use the following multi-line format to document which parameters are positional and at which positions:

```powershell
# .NOTES
# This function/script supports positional parameters:
#   Position 0: VectorRows
#   Position 1: KMeansResult
# Version: 1.0.20250218.0
```

Guidance for this format:

1. The header line **SHOULD** be `# This function/script supports positional parameters:` followed by each position listed on its own indented line as `#   Position N: ParameterName`.
2. Only list parameters that are expected to be used positionally. For functions or scripts with many optional parameters, listing only the mandatory or commonly-used positional parameters is acceptable.
3. The parameter name **SHOULD** match the declared parameter name without the `-` prefix (e.g., `VectorRows`, not `-VectorRows`), since the `.NOTES` section documents the parameter's identity, not its call syntax.
4. **[All]** If positional parameter behavior is documented for a private/internal helper, that documentation **SHOULD** clearly state that it is an internal-caller contract only and is subject to change. For example, the header line **SHOULD** read `# This function supports positional parameters` / `# (internal-caller contract only; subject to change):` instead of the standard header.

#### [Modern] Enforcing a Subset-Only Positional Contract

**[Modern]** When a `[CmdletBinding()]` function or script documents only a **subset** of its parameters as positional, it **MUST** use `[CmdletBinding(PositionalBinding = $false)]` and **MUST** apply explicit `[Parameter(Position = N)]` attributes only to the parameters intended to be positional. This rule does not apply to v1.0-targeted functions, which cannot use `[CmdletBinding()]`.

**Compliant — subset-only positional contract enforced:**

```powershell
function Import-DataSet {
    [CmdletBinding(PositionalBinding = $false)]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true, Position = 0)]
        [string]$InputMode,

        [Parameter(Mandatory = $true, Position = 1)]
        [string]$OutputPath,

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [int]$RetryCount
    )

    # Only InputMode and OutputPath are positional;
    # Force and RetryCount must always be named.
    # ...
}
```

**Non-compliant — default PositionalBinding contradicts documented subset contract:**

```powershell
# BAD: Documentation claims only InputMode and OutputPath are positional,
# but CmdletBinding() defaults to PositionalBinding = $true, which silently
# makes Force and RetryCount positional as well.
function Import-DataSet {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$InputMode,

        [Parameter(Mandatory = $true)]
        [string]$OutputPath,

        [Parameter()]
        [switch]$Force,

        [Parameter()]
        [int]$RetryCount
    )

    # .NOTES claims "Position 0: InputMode, Position 1: OutputPath"
    # but all parameters accept positional input — mismatch.
    # ...
}
```

---

<!-- rationale-anchor: advanced-feature-emulation-v10-native -->
<!-- rationale-anchor: options-for-return-mechanism-comparison -->

### Rule: "Modern Advanced" Function/Script Requirements (v2.0+)

The "v1.0 Classicist" style is the default for standalone, portable utilities that **MUST** maintain backward compatibility.

However, if a script or function **cannot** target v1.0, it **MUST** be written in the "Modern Advanced" style. This condition is met if the code:

1. Has external module dependencies that require a modern PowerShell version (e.g., `AWS.Tools`, `Az`, `Microsoft.Graph`).
2. Intentionally uses features from PowerShell v2.0 or later (e.g., `try/catch`, `[pscustomobject]` literals, `Add-Type -AssemblyName`), and there are no reasonable alternative approaches that can be used to ensure support for PowerShell v1.0.

Functions and scripts written in this "Modern Advanced" style **MUST** adhere to the following rules:

1. **Must Use `[CmdletBinding()]`:** All modern functions and scripts **MUST** use the `[CmdletBinding()]` attribute. This is the non-negotiable identifier of an advanced function or script and enables support for common parameters (`-Verbose`, `-Debug`, `-ErrorAction`, etc.). For modern scripts (`.ps1` files that are not functions), `[CmdletBinding()]` and the `param` block **MUST** appear as the first statement in the script, other than permitted `using` statements, comments, and blank lines. Placing other statements before `[CmdletBinding()]` / `param` causes a `ParseException` when the script is invoked via the call operator (`& $path`).
2. **Must Use `[OutputType()]`:** All modern functions and scripts **MUST** declare their primary output object type using `[OutputType()]`. This is critical for discoverability, integration, and validating the function's or script's contract.
3. **Must Use Streaming Output:** Functions and scripts that return collections **MUST** write objects directly to the pipeline (stream) from within a loop. They **MUST NOT** collect results in a `List<T>` or array to be returned at the end. (See *Processing Collections in Modern Functions*).
4. **Must Use `try/catch`:** Error handling **MUST** use `try/catch` blocks. The v1.0 `trap` / preference-toggling pattern is **prohibited** in this style.
5. **Must Use Proper Streams:** Verbose and debug messages **MUST** be written to their respective streams (`Write-Verbose`, `Write-Debug`). Manual toggling of `$VerbosePreference` is **prohibited**.

**Example of a Compliant Modern Function:**

```powershell
function Get-ModernData {
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param (
        [Parameter(Mandatory = $true)]
        [string]$InputPath
    )

    process {
        Write-Verbose "Processing file: $InputPath"

        try {
            $data = Get-Content -LiteralPath $InputPath -ErrorAction Stop
            foreach ($line in $data) {
                # This is streaming output.
                [pscustomobject]@{
                    Length = $line.Length
                    Line = $line
                }
            }
        } catch {
            Write-Error -Message "Failed to process $InputPath: $($_.Exception.Message)"
        }
    }
}
```

**Benefits**: Pipeline-friendly, discoverable

**Trade-off**: Breaks v1.0 compatibility

#### "Modern Advanced" Functions/Scripts: Exception for Suppressing Nested Verbose Streams

Rule 5 states that manual toggling of `$VerbosePreference` is prohibited. This rule's primary intent is to ensure your function or script *respects* the user's desire for verbose output from *your* script (via `Write-Verbose`).

An exception to this rule **MAY** be made when you **MUST** *surgically suppress* the verbose stream from a "chatty" or "noisy" nested command (a command you call within your function or script). This pattern allows your function or script to remain verbose while silencing the underlying tool.

In this specific scenario, you **MUST** use the following pattern to temporarily set `$VerbosePreference` and guarantee it is restored, even if the command fails:

```powershell
# Save the user's current preference
$VerbosePreferenceAtStartOfBlock = $VerbosePreference

try {
    # Temporarily silence the verbose stream for the nested command
    $VerbosePreference = [System.Management.Automation.ActionPreference]::SilentlyContinue

    # Call the noisy command.
    $result = Get-NoisyCommand -Parameter $foo -ErrorAction Stop

    # Restore the preference *immediately* after the call
    $VerbosePreference = $VerbosePreferenceAtStartOfBlock

    # All logic that depends on $result's success MUST
    # also be inside the 'try' block.
    Write-Verbose "Successfully processed result from noisy command."
    # ... (other code that uses $result) ...
} catch {
    # If Get-NoisyCommand fails, this block will run and
    # the dependent logic above will be skipped.
    # Re-throw the error so the caller knows what happened.
    throw
} finally {
    # This 'finally' block ensures the preference is restored,
    # even if the 'catch' block runs and throws an error.
    $VerbosePreference = $VerbosePreferenceAtStartOfBlock
}
```

This `try/finally` pattern is robust, safe, and compliantly achieves your goal of controlling output from third-party cmdlets.

#### "Modern Advanced" Functions/Scripts: Singular `[OutputType()]`

When a function returns one or more objects via the pipeline (streaming), the `[OutputType()]` attribute **MUST** declare the *singular* type of object in the stream (e.g., `[OutputType([pscustomobject])]`). Code **MUST NOT** use the plural array type (e.g., `[OutputType([pscustomobject[]])]`). The pipeline *always* creates an array for the caller automatically if multiple objects are returned.

#### "Modern Advanced" Functions/Scripts: Handling Multiple or Dynamic Output Types

When a function is *intentionally* designed to return different, non-related object types (e.g., a wrapper for `ConvertFrom-Json` which can return a single object, an array, or a scalar type), it is preferred to **list all primary output types** using multiple `[OutputType()]` attributes. This is far more descriptive and helpful to the caller than using a single, generic `[OutputType([System.Object])]`.

If a function's output type is truly dynamic and unpredictable, `[OutputType([System.Object])]` **SHOULD** be used only as a last resort, as it provides minimal value for discoverability.

#### "Modern Advanced" Functions/Scripts: Prioritizing Primary Output Types

When using multiple `[OutputType()]` attributes, the goal is to list the **primary, high-level** object types a user can expect. It is **not** necessary to create an exhaustive list of every possible scalar or primitive type (e.g., `[int]`, `[bool]`, `[double]`) if they are not the main, intended output of the function.

This practice avoids cluttering the function's definition and keeps the developer's focus on the most common and important return values. For example, a JSON parsing function **SHOULD** list `[pscustomobject]` and `[object[]]`, but does not need to list `[int]`.

#### "Modern Advanced" Functions/Scripts: Parameter Validation and Attributes (`[Parameter()]`)

Using `[CmdletBinding()]` unlocks powerful parameter validation attributes like `[Parameter(Mandatory = $true)]`, `[ValidateNotNullOrEmpty()]`, and `[ValidateSet()]`.

These are **not stylistic requirements**; they are **design tools** that **MUST** be used deliberately to enforce a function's operational contract.

- **Use `[Parameter(Mandatory = $true)]` when:**
  - The function **cannot possibly perform its core purpose** without this value (e.g., `$Identity` for a `Get-User` function).
  - You want the PowerShell engine to **fail fast** and prompt the user if it's missing.

- **DO NOT Use `[Parameter(Mandatory = $true)]` when:**
  - The function is a "safe" wrapper or helper designed to handle any input, including `$null`.
  - The function has a clear, graceful default behavior when the parameter is omitted (e.g., returning `$null`, an empty array, or `$false`).
  - **Example:** The `Convert-JsonFromPossiblyUrlEncodedString` function is a "safe" wrapper. Its contract is to *try* to convert a string. A `$null` string is a valid input that **SHOULD** gracefully return `$null`, not throw a script-terminating error. Making `$InputString` mandatory would violate this "safe" contract.

- **Prefer `[ValidateNotNullOrEmpty()]` over `[Parameter(Mandatory = $true)]` when:**
  - The parameter is *technically* optional, but if it *is* provided, it **MUST NOT** be an empty string.
  - This is common for optional parameters like `$LogPath` or `$Description`.

- **Also use `[ValidateNotNullOrEmpty()]` on mandatory `[string]` parameters when:**
  - The function's logic depends on the parameter having a non-empty value (e.g., computing a hash, constructing a path, or performing a lookup).
  - PowerShell coerces `$null` to `[string]::Empty` for `[string]`-typed parameters. Because `[string]::Empty` is not `$null`, a mandatory `[string]` parameter satisfied by this coercion will pass the mandatory check but silently bind an empty string. This can cause incorrect behavior—for example, hashing an empty string instead of rejecting invalid input.
  - Adding `[ValidateNotNullOrEmpty()]` alongside `[Parameter(Mandatory = $true)]` catches this edge case at parameter-binding time and produces a clear error message.
  - This guidance applies to functions and scripts targeting Windows PowerShell 2.0 or newer, because `[ValidateNotNullOrEmpty()]` is not available in Windows PowerShell v1.0.

- **Use `[ValidateRange(min, max)]` on numeric parameters when:**
  - The parameter has a constrained valid domain, such as counts, delays or timeouts, thresholds, or percentages.
  - Fail-fast parameter binding provides a clearer error than allowing an invalid value to surface later in downstream logic.
  - When the domain is naturally bounded on both sides, prefer explicit bounds (for example `0, 100` for percentages). When only a lower bound is principled, a type maximum such as `[int]::MaxValue` or `[double]::MaxValue` **SHOULD** be used as the upper bound to preserve the fail-fast benefit for the lower bound without imposing an artificial ceiling.
  - This attribute is available in Windows PowerShell 2.0 and newer.

### Consuming Streaming Functions (The `0-1-Many` Problem)

When a function or script streams its output (whether it's a "modern advanced" function/script as mandated by the "Processing Collections" rule, or whether it's a standard, v1.0-compatible function and just happens to be streaming its output), the caller's variable will be `$null` if zero objects are returned, a *scalar object* if one object is returned, or an `[object[]]` array if multiple objects are returned.

This can cause errors in subsequent code that *always* expects an array (e.g., `foreach ($item in $result)` or `$result.Count`).

To ensure the result is **always** an array (even if empty or with a single item), the caller **SHOULD** wrap the function call in the **array subexpression operator `@(...)`**. This is the standard, robust way to consume a streaming function and **SHOULD** be the default way to demonstrate usage in `.EXAMPLE` blocks.

**Compliant `.EXAMPLE`:**

```powershell
# .EXAMPLE
# # This example shows how to safely call the function and guarantee the
# # result is an array, even if only one principal is returned.
# $arrPrincipals = @(Expand-TrustPrincipal -PrincipalNode $statement.Principal)
```

---

<!-- rationale-anchor: summary-function-design-as-reliability-engineering -->

## Error Handling

<!-- rationale-anchor: executive-summary-error-handling-philosophy -->

### Core Error Suppression Mechanism

v1.0-targeted functions **MUST** use **two complementary v1.0-native suppression techniques**:

| Technique | Implementation | Purpose |
| --- | --- | --- |
| **`trap { }`** | Empty trap block at function scope | Catches **terminating errors** (e.g., type cast failures) and prevents script termination |
| **`$global:ErrorActionPreference = 'SilentlyContinue'`** | Temporarily set before risky operation, restored immediately after | Suppresses **non-terminating error output** to host |

```powershell
trap { }  # Intentional error suppression
$originalPref = $global:ErrorActionPreference
$global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
# Risky operation here
$global:ErrorActionPreference = $originalPref  # State restoration
```

**Key characteristics**:

- **No error leakage** to host → script continues
- **State preservation** → original preference restored
- **v1.0 compatibility** → works in all PowerShell versions

---

### Error Detection: Reference-Based Comparison

The author **rejects unreliable heuristics** (`$?`, `$Error[0].Exception`, null checks) and implements a **reference-equality detection system** using two custom helper functions:

1. **`Get-ReferenceToLastError`:** Returns `[ref]$Error[0]` if errors exist, `[ref]$null` otherwise
2. **`Test-ErrorOccurred`:** Compares two `[ref]` objects to determine if a **new error** appeared

**Detection workflow**:

```powershell
$refBefore = Get-ReferenceToLastError    # Snapshot pre-operation
# ... perform risky operation ...
$refAfter = Get-ReferenceToLastError     # Snapshot post-operation
$errorOccurred = Test-ErrorOccurred $refBefore $refAfter
```

**Reference comparison logic**:

| Before \ After | `$null` | Not `$null` (same) | Not `$null` (different) |
| --- | --- | --- | --- |
| `$null` | No | **YES** | N/A |
| Not `$null` | No | No | **YES** |

This eliminates false positives from `$error` array clearing and ensures **100% accurate error detection**.

---

### Atomic Error Handling Pattern

Every type conversion or risky operation **MUST** follow this **exact atomic pattern**:

```powershell
function Convert-Safely {
    param([ref]$refOutput, [string]$input)

    trap { }  # Suppress termination
    $refBefore = Get-ReferenceToLastError
    $originalPref = $global:ErrorActionPreference
    $global:ErrorActionPreference = 'SilentlyContinue'

    $refOutput.Value = [type]$input  # Risky cast

    $global:ErrorActionPreference = $originalPref
    $refAfter = Get-ReferenceToLastError

    return (-not (Test-ErrorOccurred $refBefore $refAfter))
}
```

**Key guarantees**:

- Operation is **isolated** — error cannot affect caller
- **State is restored** — preference reset
- **Result is boolean** — `$true` = success, `$false` = failure
- **No side effects** — even on failure

---

### Anomaly Reporting: Write-Warning for Logical Impossibilities

`Write-Warning` **MUST** be used **sparingly** to flag **logically impossible states** (contract violations). Code **MUST NOT** suppress these warnings.

```powershell
Write-Warning -Message 'Conversion failed even though individual parts succeeded. This should not be possible!'
```

---

### Error Context Preservation

Despite suppression, **full error context is preserved** in the global `$Error` array (original `ErrorRecord` objects remain intact with stack trace and exception details).

---

<!-- rationale-anchor: comparison-with-modern-alternatives -->

### Modern `catch` Block Requirements

In modern functions using `try/catch` (i.e., those not targeting v1.0), `catch` blocks **MUST NOT** be empty. An empty `catch` block is flagged by PSScriptAnalyzer and provides no diagnostic value.

#### Architectural Context: Library/Helper Functions vs. Higher-Level Code

The return-code and error-swallowing patterns described in the preceding v1.0 sections are primarily associated with **library/helper functions** — highly reusable building blocks that handle operational errors internally and communicate failure through an explicitly documented contract (e.g., integer return codes, reference outputs). These functions are designed to **never throw**, and their non-throwing behavior **MUST** be documented in `.DESCRIPTION` and `.OUTPUTS`. While v1.0 compatibility is a common consequence of this design goal, the non-throwing contract itself is the primary architectural motivation; a modern function can adopt the same pattern when the design requires it.

For **modern higher-level functions and scripts** — code that orchestrates these building blocks or performs tasks for end users — the default expectation is that unexpected failures **propagate** to the caller.

#### Default Pattern: `Write-Debug` + `throw`

The standard `catch` pattern for modern advanced functions and scripts **SHOULD** log the error to the **Debug** stream and then **re-throw** it so that unexpected failures propagate to the caller. This **SHOULD** be the default unless the function is explicitly designed as a non-throwing wrapper with a documented contract.

```powershell
# Default: log and re-throw
try {
    ...
} catch {
    Write-Debug ("Failed to do X: {0}" -f $_)
    throw
}
```

#### Rethrow Anti-Pattern

When a `catch` block is intended to rethrow, `throw "message"` and `throw ("format string" -f $args)` **MUST NOT** be used. These forms throw a string that PowerShell wraps into a **new** `RuntimeException`/`ErrorRecord`, discarding the original exception type, stack trace, and `ErrorRecord`. This makes root-cause analysis significantly harder and breaks any caller logic that catches specific exception types. This prohibition applies only to catch blocks whose intent is to preserve and propagate the original failure; catch blocks that intentionally translate an error into a new, independently documented message (such as the [file writeability tests](#file-writeability-testing)) are not subject to this rule.

```powershell
# WRONG — destroys the original exception:
try {
    Get-Item -LiteralPath $strPath -ErrorAction Stop
} catch {
    throw "Failed to get item: $($_.Exception.Message)"
}

# WRONG — same problem with -f operator:
try {
    Get-Item -LiteralPath $strPath -ErrorAction Stop
} catch {
    throw ("Failed to get item: {0}" -f $_.Exception.Message)
}
```

#### Adding Context Before Rethrowing

If contextual information is needed before rethrowing, it **SHOULD** be logged via `Write-Debug` before the bare `throw`. This preserves the original exception while still providing diagnostic context on the Debug stream, reinforcing the [Default Pattern](#default-pattern-write-debug--throw).

```powershell
# Correct — context logged, original exception preserved:
try {
    Get-Item -LiteralPath $strPath -ErrorAction Stop
} catch {
    Write-Debug ("Failed to get item at path '{0}': {1}" -f $strPath, $_)
    throw
}
```

#### Wrapping Exceptions with `$PSCmdlet.ThrowTerminatingError()`

If an exception **must** be wrapped with additional context while still propagating, the preferred pattern for advanced functions **SHOULD** use `$PSCmdlet.ThrowTerminatingError()` and preserve the original exception as the `InnerException`. This approach maintains the full exception chain for callers while adding meaningful context.

```powershell
# Correct — wraps with context, preserves original as InnerException:
function Get-ResolvedItem {
    [CmdletBinding()]
    param (
        [string]$Path
    )

    try {
        Get-Item -LiteralPath $Path -ErrorAction Stop
    } catch {
        $objException = [System.InvalidOperationException]::new(
            ("Failed to resolve item at path '{0}'" -f $Path),
            $_.Exception
        )
        $objErrorRecord = [System.Management.Automation.ErrorRecord]::new(
            $objException,
            'ResolvedItemFailure',
            [System.Management.Automation.ErrorCategory]::ObjectNotFound,
            $Path
        )
        $PSCmdlet.ThrowTerminatingError($objErrorRecord)
    }
}
```

> **Note:** The above wrapping pattern is appropriate only when additional context is genuinely needed beyond what `Write-Debug` + bare `throw` provides. In most cases, the [Default Pattern](#default-pattern-write-debug--throw) is sufficient.

#### Documented Non-Throwing Exception

A modern function **MAY** intentionally handle an exception without re-throwing **only** when its contract explicitly specifies non-throwing behavior. In that case, the function's comment-based help (`.DESCRIPTION` and `.OUTPUTS`) **MUST** clearly document that failures are communicated through return values, output state, warnings, or another defined mechanism rather than by throwing.

```powershell
# Non-throwing wrapper with documented contract
function Convert-SafelyFromJson {
    # .DESCRIPTION
    # Attempts to convert a JSON string to an object. This function does
    # NOT throw on invalid input; instead it returns $null and logs the
    # error to the Debug stream. Callers MUST check the return value.
    #
    # .OUTPUTS
    # [object] on success; $null on failure.
    [CmdletBinding()]
    [OutputType([object])]
    param (
        [string]$JsonString
    )

    if ([string]::IsNullOrEmpty($JsonString)) {
        return $null
    }

    try {
        $JsonString | ConvertFrom-Json -ErrorAction Stop
    } catch {
        Write-Debug ("JSON conversion failed: {0}" -f $_)
        $null
    }
}
```

---

### Set-StrictMode Considerations for `finally` Blocks

When `Set-StrictMode -Version Latest` is in effect, referencing a variable that has never been assigned raises a terminating error. This creates a subtle but important pitfall when a `finally` block references a variable that is assigned inside the corresponding `try` block (for example, a disposable resource). If an exception occurs before the assignment executes, `Set-StrictMode` will raise a terminating error for the uninitialized variable inside `finally`, which can mask the original exception and interfere with proper cleanup.

**Rule:** When a `finally` block references a variable that is assigned inside the corresponding `try` block, that variable **MUST** be initialized before the `try` block, typically to `$null`.

**Compliant Example:**

```powershell
$objResource = $null
try {
    $objResource = [SomeDisposable]::Create()
    # ... use $objResource ...
} finally {
    if ($null -ne $objResource) {
        $objResource.Dispose()
    }
}
```

In this example, `$objResource` is initialized to `$null` before the `try` block. If `[SomeDisposable]::Create()` throws before the assignment completes, the `finally` block can safely check `$null -ne $objResource` without triggering a `Set-StrictMode` violation.

---

### Set-StrictMode Placement for Dot-Sourced Files

Where `Set-StrictMode -Version Latest` belongs depends on how the `.ps1` file is consumed at runtime. A `.ps1` file that is dot-sourced executes its script-scope statements in the **caller's scope**, which means a script-scope `Set-StrictMode` call leaks into the caller and silently changes the caller's strict-mode setting. By contrast, when code is consumed through an imported module or by executing a script or aggregate artifact normally (for example, `.\Helpers.ps1`, `& .\Helpers.ps1`, or `Import-Module`), script-scope statements run in that artifact's own script scope, so a script-scope `Set-StrictMode` call is contained to that scope.

**Rule (bundled files):** For files bundled into a module or other aggregate script artifact, `Set-StrictMode -Version Latest` **MUST** be placed at script scope as the first executable statement in the file, after any required file-header constructs such as `#requires` comments, `using` statements, and any script-level `[CmdletBinding()]`/`param` block. The bundled artifact may also establish strict mode, making this redundant at runtime, but it preserves file-level correctness if the source file is ever executed directly. This rule does **not** make dot-sourcing the source file safe: dot-sourcing any `.ps1` file — including an individual bundled source file or a monolithic bundled artifact — still runs its script-scope statements in the caller's scope and will leak strict mode.

**Rule (dot-sourced files):** For files that are not bundled and are instead intended to be dot-sourced directly into the caller's scope (for example, test fixtures, ad-hoc scripts, or build tooling), `Set-StrictMode -Version Latest` **MUST NOT** be placed at script scope. Instead, it **MUST** be placed inside the function body — as the first statement in `begin {}` when the function uses a `begin/process/end` layout (so strict mode covers `begin`, `process`, and `end`, and is not re-invoked for every pipeline input), or otherwise as the first statement in the function body.

#### Bundled File — Compliant Example

```powershell
#requires -Version 5.1
using namespace System.Text

Set-StrictMode -Version Latest

function Get-Thing {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [string]$Name
    )

    process {
        # ... implementation ...
    }
}
```

#### Bundled File — Non-Compliant Example

```powershell
# Set-StrictMode is missing at file scope. If the bundled artifact fails to
# establish strict mode, or if this file is executed independently,
# strict-mode guarantees are lost.
function Get-Thing {
    [CmdletBinding()]
    [OutputType([string])]
    param (
        [string]$Name
    )

    process {
        # ... implementation ...
    }
}
```

#### Dot-Sourced File — Compliant Example

```powershell
function Invoke-TestFixture {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [string]$Path
    )

    begin {
        Set-StrictMode -Version Latest
    }

    process {
        # ... implementation ...
    }
}
```

#### Dot-Sourced File — Non-Compliant Example

```powershell
# WRONG — when this file is dot-sourced, Set-StrictMode executes in the
# caller's scope and silently changes the caller's strict-mode setting.
Set-StrictMode -Version Latest

function Invoke-TestFixture {
    [CmdletBinding()]
    [OutputType([void])]
    param (
        [string]$Path
    )

    process {
        # ... implementation ...
    }
}
```

---

<!-- rationale-anchor: summary-error-handling-as-diagnostic-instrumentation -->

## File Writeability Testing

Scripts that write output to files **MUST** verify the destination path is writable **before performing any significant processing** (preflight check for invalid paths, missing directories, insufficient permissions, read-only locations, locked files).

### Approaches

1. **`.NET` approach** (`Test-FileWriteability`): Comprehensive, uses .NET file operations. **MUST** be used for v1.0-targeted scripts (since `try/catch` causes parser errors in v1.0).
2. **`try/catch` approach**: Shorter (~10 lines), requires PowerShell v2.0+.

Both use a **create-then-delete pattern**. The delete step catches additional failure modes (e.g., file locks on Windows) that file creation alone may miss.

**[v1.0]** scripts **MUST** use the `.NET` approach. **[Modern]** scripts **MAY** use either approach.

Prefer `.NET` for mission-critical/unattended scripts, or where v1.0 parseability is needed. Prefer `try/catch` for simple utilities or when minimizing size.

---

### Code Examples

#### .NET Approach

Bundle `Test-FileWriteability` from the [reference implementation](#reference-implementation):

```powershell
$errRecord = $null
$boolIsWritable = Test-FileWriteability -Path 'Z:\InvalidPath\file.log' -ReferenceToErrorRecord ([ref]$errRecord)
if (-not $boolIsWritable) {
    Write-Warning ('Failed to write to path. Error: ' + $errRecord.Exception.Message)
    return # replace with an appropriate exiting action
}
```

#### try/catch Approach

```powershell
try {
    $strOutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
    $strWriteTestPath = [System.IO.Path]::Combine([System.IO.Path]::GetDirectoryName($strOutputPath), ('.write_test_{0}.tmp' -f [Guid]::NewGuid().ToString('N')))
    [System.IO.File]::Open($strWriteTestPath, [System.IO.FileMode]::CreateNew, [System.IO.FileAccess]::Write).Dispose()
    [System.IO.File]::Delete($strWriteTestPath)
} catch {
    throw ("Cannot write to '{0}': {1}" -f $OutputPath, $_.Exception.Message)
}
```

> **Warning:** File APIs with create-or-overwrite semantics (e.g., `[System.IO.File]::Create()`, `New-Item -Force`) **SHOULD NOT** be used for writeability probes unless the probe filename is guaranteed unique. Using the actual output path as the probe can destroy pre-existing data or cause false failures when the file already exists.

---

### Reference Implementation

Full `Test-FileWriteability` implementation: <https://github.com/franklesniak/PowerShell_Resources/blob/master/Test-FileWriteability.ps1>

## Operating System Compatibility Checks

Platform-specific scripts/functions **MUST** include OS checks before platform-specific operations. **Fail early** — perform checks at the beginning of the function or script.

### PowerShell Core 6.0+ OS Detection

Use built-in variables: `$IsWindows`, `$IsMacOS`, `$IsLinux`.

```powershell
if (-not $IsWindows) {
    Write-Error -Message "This function only runs on Windows."
    return -1
}
```

---

### Cross-Version OS Detection

For scripts supporting PowerShell older than 6.0 (including Windows PowerShell 1.0–5.1), `$IsWindows`/`$IsMacOS`/`$IsLinux` do not exist; referencing them yields `$null` or throws under strict mode, causing incorrect behavior. Use safe detection functions from [`PowerShell_Resources`](https://github.com/franklesniak/PowerShell_Resources):

| OS | Function | Link |
| --- | --- | --- |
| Windows | `Test-Windows` | [`Test-Windows.ps1`](https://github.com/franklesniak/PowerShell_Resources/blob/master/Test-Windows.ps1) |
| macOS | `Test-macOS` | [`Test-macOS.ps1`](https://github.com/franklesniak/PowerShell_Resources/blob/master/Test-macOS.ps1) |
| Linux | `Test-Linux` | [`Test-Linux.ps1`](https://github.com/franklesniak/PowerShell_Resources/blob/master/Test-Linux.ps1) |

```powershell
$boolIsWindows = Test-Windows
if (-not $boolIsWindows) {
    Write-Warning -Message "This function only runs on Windows."
    return -1
}
```

### Error Handling for Wrong OS

Report errors **consistently** with the script's existing error handling pattern (status codes, exceptions, or `Write-Error`). Error messages **SHOULD** clearly state which OS(es) are required.

## Language Interop, Versioning, and .NET

<!-- rationale-anchor: executive-summary-interop-and-versioning-strategy -->

### Runtime Version Detection: `Get-PSVersion`

A **dedicated version probe** returns a `[System.Version]` object:

```powershell
function Get-PSVersion {
    if (Test-Path variable:\PSVersionTable) {
        return $PSVersionTable.PSVersion
    } else {
        return [version]'1.0'
    }
}
```

Returns actual version on v2.0+; falls back to `[version]'1.0'` when `$PSVersionTable` is absent.

---

### Conditional .NET Feature Usage: Progressive Enhancement

Use PowerShell version as a feature flag for .NET types:

```powershell
if ($versionPowerShell.Major -ge 3) {
    $boolResult = Convert-StringToBigIntegerSafely ...
} else {
    $boolResult = Convert-StringToDoubleSafely ...
}
```

| PowerShell Version | .NET Type Used | Numeric Range |
| --- | --- | --- |
| v3.0+ | `[System.Numerics.BigInteger]` | Unlimited (subject to memory) |
| v1.0–v2.0 | `[double]` | ±1.7 × 10³⁰⁸ (IEEE 754) |
| All versions | `[int]`, `[int64]` | Built-in safe conversions |

---

### .NET Interop Patterns: Safe and Documented

| .NET Usage | Technical Justification |
| --- | --- |
| `[regex]::Escape()` + `[regex]::Split()` | Literal string splitting in v1.0 (alternative to v2.0+ `-split`) |
| `[System.Numerics.BigInteger]` | Overflow handling — only when PS v3+ detected |

**Deprecation of `System.Collections.ArrayList`:** `ArrayList` is **deprecated** and **MUST NOT** be used in new code. Use `System.Collections.Generic.List[T]` instead (available since .NET 2.0 / PS v1.0). `ArrayList` is only permitted as a caught-exception fallback, reported via debug stream.

```powershell
# Compliant
$list = New-Object System.Collections.Generic.List[PSCustomObject]

# Non-Compliant (Deprecated)
$list = New-Object System.Collections.ArrayList
```

**Typed Generic Collections:** The specific type `T` **MUST** be provided if known (e.g., `[PSCustomObject]`, `[string]`), not `[object]`.

---

<!-- rationale-anchor: type-conversion-safety-chain -->
<!-- rationale-anchor: version-aware-fallback-logic -->

### .NET Type Usage Summary

| .NET Type | First Available | Technical Purpose |
| --- | --- | --- |
| `[regex]` | .NET 2.0 (PS v1.0) | Literal string parsing |
| `[System.Numerics.BigInteger]` | .NET 4.0 (PS v3.0+) | Unlimited integer precision |
| `[version]` | .NET 2.0 | Standard version semantics |
| `[ref]` | .NET 2.0 | Multiple return values (only for write-back) |

All types are **v1.0-safe** except `BigInteger`, which is **guarded by version check**.

---

<!-- rationale-anchor: modernization-path-v20 -->
<!-- rationale-anchor: summary-interop-as-adaptive-resilience -->

## Output Formatting and Streams

<!-- rationale-anchor: executive-summary-output-discipline -->

### Primary Output: Integer Status Code via `return`

v1.0-targeted functions return a **single `[int]` status code** via explicit `return`:

```powershell
return 0    # Full success
return 4    # Partial success
return -1   # Complete failure
```

Document in `.OUTPUTS`: `# [int] Status code: 0=success, 1-5=partial with additional data, -1=failure`

---

### Processing Collections in Modern Functions (Streaming Output)

A modern (non-v1.0) function **SHOULD NOT** build a large collection (like a `List<T>`) and return it at the end. This is memory-inefficient, as it requires holding all results in memory, and often creates an unnecessary O(n) performance hit when the list is copied.

The preferred, idiomatic PowerShell pattern is to **"stream" the output**: write each result object *directly to the pipeline from within the processing loop*. This is highly memory-efficient and aligns with the pipeline's "one object at a time" philosophy.

- **Compliant (Streaming):** Write objects to the pipeline *inside* your loop.
- **Non-Compliant (Collecting):** Adding all objects to a `$list` and returning `$list` at the end.

**Compliant (Streaming) Example:**

```powershell
[CmdletBinding()]
[OutputType([pscustomobject])]
param(...)

foreach ($objItem in $SourceData) {
    # ... logic to create $objResult ...
    $objResult # This writes the object to the pipeline
}
# Note: There is no 'return' statement for the collection
```

**Non-Compliant (Collecting) Example:**

```powershell
[CmdletBinding()]
[OutputType([pscustomobject[]])] # Unnecessary plural
param(...)

$listOutput = New-Object System.Collections.Generic.List[PSCustomObject]
foreach ($objItem in $SourceData) {
    # ... logic ...
    [void]($listOutput.Add($objResult))
}
return $listOutput.ToArray() # Unnecessary copy and non-idiomatic
```

This rule is distinct from the v1.0-native pattern, which uses explicit integer `return` codes and passes data via `[ref]` parameters. The v1.0-native pattern **MAY** be desireable in situations where the function **SHOULD** return no output in the event of any error occurring during processing, or where error/warning status needs to be passed back to the caller.

---

### Complex Output: Reference Parameters (`[ref]`)

All **structured data** is returned via **`[ref]` parameters** only when write-back to the caller is required.

---

### Stream Usage: Clear Mapping

| Stream | Command | Purpose |
| --- | --- | --- |
| **Success** | `return` | Primary result (status code) |
| **Warning** | `Write-Warning` | Logical anomalies (contract violations) |
| **Host** | *Never used* | **Prohibited** — `Write-Host` **MUST NOT** be used |

v1.0-targeted functions **MUST NOT** emit mixed object types on the success stream.

---

---

<!-- rationale-anchor: format-files-future-proof-design-pattern -->
<!-- rationale-anchor: modern-stream-capabilities-v20-context -->
<!-- rationale-anchor: summary-output-as-controlled-interface -->

### Choosing Between Warning and Debug Streams

The choice of output stream is critical for communicating intent:

- **Warning Stream (`Write-Warning`):** Reserved for logical anomalies or conditions that the **end-user** **SHOULD** be aware of, but which do not halt execution (e.g., "Could not determine root user email for account X").
- **Debug Stream (`Write-Debug`):** Used for logging **internal function details** that are not relevant to the end-user but are critical for diagnostics. This includes handled `catch` block errors, or fallback logic (e.g., "Failed to create generic lists; falling back to ArrayLists.").

### Suppression of Method Output

When calling .NET methods that return a value (like `System.Collections.ArrayList.Add()`), that output **MUST** be suppressed to avoid polluting the pipeline. The preferred method is to cast the entire statement to `[void]` for performance, as it is measurably faster than piping to `| Out-Null`.

```powershell
# Compliant (Preferred for performance)
[void]($list.Add($item))

# Non-Compliant (Typically slower than casting to void)
$list.Add($item) | Out-Null
```

### Sensitive Data in Verbose and Debug Streams

Functions **MUST NOT** emit raw PII, credentials, secrets, tokens, or sensitive identifiers via `Write-Verbose` or `Write-Debug`. Use safe alternatives: boolean presence flags, non-sensitive metadata (length, count, type name), or redacted values.

```powershell
# Non-Compliant
Write-Verbose -Message ('PrincipalKey: ' + $PrincipalKey)

# Compliant - logs whether the value is present (boolean)
Write-Verbose -Message ('PrincipalKey present: {0}' -f ($null -ne $PrincipalKey))
```

### Performance-Sensitive `Write-Verbose` / `Write-Debug` in Hot Paths

**[Modern]** functions that are called per-record or inside tight loops (that is, hot paths) **SHOULD** guard `Write-Verbose` and `Write-Debug` calls that perform string formatting — such as with the `-f` operator or string concatenation — behind an appropriate preference check to avoid unconditional string allocation overhead when the stream is not enabled.

**Recommended pattern for `Write-Verbose`:**

```powershell
if ($VerbosePreference -ne 'SilentlyContinue') {
    Write-Verbose ("Processing item: {0}" -f $strCurrentItem)
}
```

**Recommended pattern for `Write-Debug`:**

```powershell
if ($DebugPreference -ne 'SilentlyContinue') {
    Write-Debug ("Processing item: {0}" -f $strCurrentItem)
}
```

> **Note:** This guard is recommended only for performance-sensitive code paths and is **NOT** required for functions that run once, or only a small number of times, per pipeline or script execution.

## Testing with Pester

**Pester 5.x** is required. Legacy 3.x/4.x patterns **MUST NOT** be used. Pester requires PowerShell 3.0+ to run, but scripts under test can target any version. See [pester.dev](https://pester.dev/).

---

### Test File Naming and Location

- Test files **MUST** use `*.Tests.ps1` suffix
- Test files **SHOULD** be in a `tests/` directory at the repository root
- One test file per function/script **SHOULD** be created

---

### Pester 5.x Syntax Requirements

Tests **MUST** use Pester 5.x syntax. Legacy Pester 3.x/4.x patterns **MUST NOT** be used.

| Block | Purpose |
| --- | --- |
| `BeforeAll` | One-time setup at the beginning of a `Describe` or `Context` block (e.g., dot-sourcing the function under test) |
| `BeforeEach` | Setup before each `It` block (use sparingly) |
| `AfterAll` / `AfterEach` | Teardown (cleanup resources, restore state) |
| `Describe` | Groups tests for a single function or script |
| `Context` | Groups tests for a specific scenario or condition |
| `It` | Defines an individual test case |
| `Should` | Assertion cmdlet for validating expected outcomes |

**Key Pester 5.x Changes:**

- Use `BeforeAll` for dot-sourcing scripts (not at the file level outside blocks)
- Discovery and Run phases are separate—code at the top level runs during discovery
- Code **MUST** use `Should -Be`, `Should -BeExactly`, `Should -BeNullOrEmpty`, etc. (not legacy `Assert-*` patterns)

---

### Test File Dot-Sourcing Pattern

Pester test files that dot-source scripts under test in `BeforeAll` **MUST** use the `Split-Path` + `Join-Path` two-step pattern. This pattern resolves the parent directory of the test file's directory and then builds the path to the source file:

```powershell
BeforeAll {
    $strSrcPath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'
    . (Join-Path -Path $strSrcPath -ChildPath 'FunctionName.ps1')
}
```

**Why this pattern is required:**

- Multi-segment `Join-Path` forms such as `Join-Path $PSScriptRoot '..' 'src' 'FunctionName.ps1'` rely on the `-AdditionalChildPath` parameter, which was introduced in PowerShell 6.0 and is **not available** in Windows PowerShell 5.1. Test files **MUST NOT** use this form.
- For consistency and canonical style in test files, `$PSScriptRoot`-anchored `..` path forms such as `$PSScriptRoot/../src/...` or `Join-Path -Path $PSScriptRoot -ChildPath '../src/...'` **MUST NOT** be used; use the explicit parent-resolution pattern instead.

---

### Test Structure: Arrange-Act-Assert

Tests **SHOULD** follow the **Arrange-Act-Assert (AAA)** pattern for clarity and maintainability:

1. **Arrange:** Set up test data, preconditions, and inputs
2. **Act:** Execute the function or script under test
3. **Assert:** Verify the output matches expectations

Each `It` block **SHOULD** test **one specific behavior**. Use comments to delineate the AAA sections for readability.

**Example:**

```powershell
It "Returns success code 0 when given valid input" {
    # Arrange
    $refResult = $null
    $strInput = "valid-input"

    # Act
    $intReturnCode = Get-ProcessedData -ReferenceToResult ([ref]$refResult) -InputString $strInput

    # Assert
    $intReturnCode | Should -Be 0
}
```

---

### Defensive Assertions Before Iteration and Indexing

When a test iterates or indexes into a collection returned by the function or script under test, the test **MUST** include defensive pre-assertions so that an empty or `$null` result produces a clear, immediate Pester failure instead of silently passing or generating a confusing runtime error.

1. **Pre-iteration non-emptiness.** Tests that iterate a collection with `foreach ($x in $collection) { ... }` **MUST** assert `$collection | Should -Not -BeNullOrEmpty` before the `foreach`. A `foreach` over `$null` or an empty collection executes zero iterations, causing all inner assertions to be silently skipped.

2. **Pre-index count assertion.** Tests that access specific indices of a returned collection (e.g., `$arrResult[0]`) **MUST** assert `$arrResult.Count | Should -Be <N>` before any indexed access when the exact count is part of the contract being tested. If exact count is not part of the contract, the test **MUST** assert a minimum-count condition that covers the highest index accessed—for example, `Should -BeGreaterThan <highest-index-accessed>` (since collections are zero-based, `$arr.Count | Should -BeGreaterThan 2` guarantees that `$arr[0]`, `$arr[1]`, and `$arr[2]` are safe to access).

3. **Pre-index non-empty on nested properties.** When a test indexes into a property of a returned element (e.g., `$arrResult[0].Principals[0]`), the test **MUST** also assert `$arrResult[0].Principals | Should -Not -BeNullOrEmpty` before the inner index.

4. **Ordering.** For a test that accesses `$arr[i].Prop[j]`, assertions **SHOULD** follow this order:
   1. `$arr | Should -Not -BeNullOrEmpty` or `$arr.Count | Should -Be <N>`
   2. `$arr[i].Prop | Should -Not -BeNullOrEmpty`
   3. Strong-type check on `$arr[i].Prop`, if applicable
   4. Assertions that verify the actual behavior under test

**Compliant** (`foreach` — assert non-emptiness before iterating):

```powershell
It "Each ClusterActions entry includes a Principals array" {
    # Assert
    $script:objResult.ClusterActions | Should -Not -BeNullOrEmpty
    foreach ($objCluster in $script:objResult.ClusterActions) {
        $objCluster.PSObject.Properties.Name | Should -Contain 'Principals'
        $objCluster.Principals | Should -Not -BeNullOrEmpty
        ($objCluster.Principals -is [string[]]) | Should -BeTrue
    }
}
```

**Non-Compliant** (`foreach` — missing non-emptiness assertion):

```powershell
# Non-Compliant: foreach over $null or an empty collection can execute zero
# iterations and leave the test without any evaluated inner assertions.
It "Each ClusterActions entry includes a Principals array" {
    # Assert
    foreach ($objCluster in $script:objResult.ClusterActions) {
        $objCluster.PSObject.Properties.Name | Should -Contain 'Principals'
    }
}
```

**Compliant** (indexed access — count and nested non-emptiness before indexing):

```powershell
# Assert
$arrResult.Count | Should -Be 1
$arrResult[0].Principals | Should -Not -BeNullOrEmpty
$arrResult[0].Principals.Count | Should -Be 2
$arrResult[0].Principals[0] | Should -Be 'userA'
$arrResult[0].Principals[1] | Should -Be 'userB'
```

**Non-Compliant** (indexed access — no count assertion before `[0]`):

```powershell
# Non-Compliant: no count assertion before [0].
# Assert
$arrResult[0].Principals.Count | Should -Be 1
$arrResult[0].Principals[0] | Should -Be 'userA'
```

---

### Testing Return Code Conventions

For functions and scripts that use explicit integer status codes, tests **MUST** verify the return code conventions documented in [Return Semantics: Explicit Status Codes](#return-semantics-explicit-status-codes).

> **Note for functions and scripts that return objects:** If a function or script returns `[pscustomobject]` or other structured data instead of integer status codes, this section does not apply. For such cases, output contract verification — including edge cases such as `$null` returns — SHOULD be covered by Pester tests in accordance with [Testing with Pester](#testing-with-pester), where applicable.

#### Functions Returning Integer Status Codes

For functions that return integer status codes (`0` = success, `1-5` = partial success, `-1` = failure), tests **MUST** cover:

| Return Code | Test Requirement |
| --- | --- |
| `0` | At least one test verifying success case |
| `1-5` | At least one test for partial success cases (if applicable to the function) |
| `-1` | At least one test verifying failure case |

Additionally, if the function uses `[ref]` parameters for output:

- Tests **MUST** verify the reference parameter is populated correctly on success
- Tests **MUST** verify the reference parameter state on failure (typically `$null` or unchanged)

**Example for Integer Status Code Function:**

```powershell
Describe "Convert-StringToObject" {
    BeforeAll {
        $strSrcPath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'
        . (Join-Path -Path $strSrcPath -ChildPath 'Convert-StringToObject.ps1')
    }

    Context "When given valid input" {
        It "Returns 0 for success" {
            # Arrange
            $refResult = $null
            $strInput = "valid-data"

            # Act
            $intReturnCode = Convert-StringToObject -ReferenceToResult ([ref]$refResult) -StringToConvert $strInput

            # Assert
            $intReturnCode | Should -Be 0
        }

        It "Populates the reference parameter with the converted object" {
            # Arrange
            $refResult = $null
            $strInput = "valid-data"

            # Act
            [void](Convert-StringToObject -ReferenceToResult ([ref]$refResult) -StringToConvert $strInput)

            # Assert
            $refResult | Should -Not -BeNullOrEmpty
        }
    }

    Context "When given invalid input" {
        It "Returns -1 for failure" {
            # Arrange
            $refResult = $null
            $strInput = ""

            # Act
            $intReturnCode = Convert-StringToObject -ReferenceToResult ([ref]$refResult) -StringToConvert $strInput

            # Assert
            $intReturnCode | Should -Be -1
        }
    }
}
```

#### Test-* Functions Returning Boolean

For `Test-*` functions that return Boolean values (as documented in the exception for Test-* functions), tests **MUST** verify:

- A case that returns `$true`
- A case that returns `$false`

**Example for Boolean Test Function:**

```powershell
Describe "Test-PathExists" {
    BeforeAll {
        $strSrcPath = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'src'
        . (Join-Path -Path $strSrcPath -ChildPath 'Test-PathExists.ps1')
    }

    Context "When the path exists" {
        It "Returns true" {
            # Arrange
            $strPath = $env:TEMP  # Known to exist

            # Act
            $boolResult = Test-PathExists -Path $strPath

            # Assert
            $boolResult | Should -BeTrue
        }
    }

    Context "When the path does not exist" {
        It "Returns false" {
            # Arrange
            $strPath = "C:\NonExistent\Path\That\Does\Not\Exist"

            # Act
            $boolResult = Test-PathExists -Path $strPath

            # Assert
            $boolResult | Should -BeFalse
        }
    }
}
```

---

### Testing Property Names on PSCustomObject

When testing that a `[pscustomobject]` contains the expected property names, assertions **MUST** use an **order-insensitive** comparison. Although `PSObject.Properties.Name` preserves declaration order in practice for objects created via the `[pscustomobject]` type accelerator with a hashtable literal, this ordering is not a documented guarantee. Tests **SHOULD NOT** rely on property ordering because:

1. Future refactors might change the property declaration order.
2. Objects constructed via `Add-Member` or other mechanisms may not preserve insertion order.
3. Order-insensitive tests are more resilient and communicate intent more clearly.

**Per-property containment** (preferred when property count is small):

```powershell
$objResult.PSObject.Properties.Name | Should -Contain 'Key'
$objResult.PSObject.Properties.Name | Should -Contain 'Type'
$objResult.PSObject.Properties.Name | Should -HaveCount 2
```

**Sorted array comparison** (acceptable alternative — the expected array must be in sorted order to match the `Sort-Object` output):

```powershell
($objResult.PSObject.Properties.Name | Sort-Object) |
    Should -Be @('Key', 'Type')
```

**Non-Compliant** (order-sensitive — fragile):

```powershell
# Non-Compliant
$objResult.PSObject.Properties.Name | Should -Be @('Key', 'Type')
```

---

### Testing Strongly-Typed Array Properties

When asserting that a property on a returned object is a non-empty, strongly-typed array, tests **MUST** follow these rules:

1. **Non-emptiness first.** Tests **MUST** use `Should -Not -BeNullOrEmpty` before any `.Count`-based assertion. This produces a clear failure message when the property is `$null` or empty, rather than a confusing "expected greater than 0" when the property is `$null`.

2. **Strongly-typed assertion.** When production code explicitly casts an output property to a strongly-typed array (e.g., `[string[]]`), tests **MUST** assert that exact array type using the `-is` operator wrapped in `Should -BeTrue`:

   ```powershell
   ($obj.Prop -is [string[]]) | Should -BeTrue
   ```

   Tests **MUST NOT** use a disjunction that also permits `[object[]]`, because that masks regressions when the intended production cast is accidentally removed.

3. **Avoid `Should -BeOfType [string[]]` for array types.** Tests **SHOULD NOT** use `$x | Should -BeOfType [string[]]` to assert array type, because the pipeline unrolls the array before Pester evaluates the type. Prefer the `-is [string[]]` pattern.

4. **Ordering.** When combined with a property-name check, the recommended assertion order **SHOULD** be: property name first, then non-empty assertion, then strongly-typed assertion.

**Compliant** (preferred pattern):

```powershell
$script:objResult.ClusterActions | Should -Not -BeNullOrEmpty
foreach ($objCluster in $script:objResult.ClusterActions) {
    $objCluster.PSObject.Properties.Name | Should -Contain 'Principals'
    $objCluster.Principals | Should -Not -BeNullOrEmpty
    ($objCluster.Principals -is [string[]]) | Should -BeTrue
}
```

**Non-Compliant** (too permissive):

```powershell
# Non-Compliant: [object[]] disjunction masks regressions in the
# production strongly-typed cast.
(($objCluster.Principals -is [string[]]) -or ($objCluster.Principals -is [object[]])) |
    Should -BeTrue

# Non-Compliant: .Count on a potentially-null value is asserted before
# proving the property is non-empty.
$objCluster.Principals.Count | Should -BeGreaterThan 0
```

**Non-Compliant** (pipeline unrolling):

```powershell
# Non-Compliant: the array is unrolled before Pester evaluates the type assertion.
$objCluster.Principals | Should -BeOfType [string[]]
```

---

### Mocking External Dependencies

Use Pester's `Mock` command to isolate the function under test from external dependencies:

```powershell
Context "When external service is unavailable" {
    BeforeAll {
        Mock Get-ExternalData { throw "Connection failed" }
    }

    It "Returns failure code -1 and does not throw" {
        # Arrange
        $refResult = $null

        # Act
        $intReturnCode = Process-ExternalData -ReferenceToResult ([ref]$refResult)

        # Assert
        $intReturnCode | Should -Be -1
    }
}
```

**Mocking Guidelines:**

- Mock cmdlets and external commands that introduce dependencies (network, file system, cloud services)
- Mock at the narrowest scope possible (prefer `Context`-level mocks over `Describe`-level)
- Use `Assert-MockCalled` to verify expected interactions when appropriate

---

### Running Pester Tests

Use `Invoke-Pester -Path tests/ -Output Detailed` for standard test runs.

## Performance, Security, and Other

<!-- rationale-anchor: executive-summary-holistic-design-constraints -->
<!-- rationale-anchor: performance-measured-pragmatism -->
<!-- rationale-anchor: security-defense-in-depth-by-design -->
<!-- rationale-anchor: other-maintainability-extensibility-and-modernization -->
<!-- rationale-anchor: summary-performance-security-and-holistic-design -->

### Prefer `-LiteralPath` Over `-Path` for Concrete Paths

When a cmdlet supports both `-Path` and `-LiteralPath`, and the code is operating on a **single concrete path value**—not an intentionally wildcarded pattern—`-LiteralPath` **SHOULD** be used instead of `-Path`. This especially applies when the path is derived from variables, `Join-Path`, or string construction, because `-Path` interprets wildcard characters (`[`, `]`, `*`, `?`) and can silently match the wrong files or match nothing at all.

For **destructive** operations—`Remove-Item`, `Move-Item`—`-LiteralPath` **MUST** be used when the path value comes from a variable or expression. Wildcard interpretation of a variable-derived path in a destructive cmdlet can silently delete or move unintended files.

Reserve `-Path` for cases where wildcard expansion is **explicitly intended**.

**Exception — `New-Item`:** `New-Item` does **not** have a `-LiteralPath` parameter (across Windows PowerShell 5.1 and PowerShell 7.x). Use `New-Item -Path` for item creation. Because `-Path` still interprets wildcard characters, code **SHOULD** validate or reject untrusted input containing `[`, `]`, `*`, or `?` as literal characters, or use a .NET file API (e.g., `[System.IO.File]::Create()`) when literal path semantics are required.

**Directory creation:** When creating a directory from a variable-derived path that may contain wildcard characters (`[`, `]`, `*`, or `?`), code **SHOULD** prefer `[System.IO.Directory]::CreateDirectory()` over `New-Item -Path ... -ItemType Directory`. The path **MUST** first be resolved to an absolute filesystem path per [Resolving Paths for .NET Static Methods](#resolving-paths-for-net-static-methods).

**Compliant** (wildcard-safe directory creation):

```powershell
$strOutputPath = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputPath)
if (-not (Test-Path -LiteralPath $strOutputPath)) {
    [void]([System.IO.Directory]::CreateDirectory($strOutputPath))
}
```

**Common cmdlets where this rule applies:** `Copy-Item`, `Get-ChildItem`, `Get-Content`, `Get-Item`, `Move-Item`, `Remove-Item`, `Set-Content`, `Test-Path`.

**Compliant:**

```powershell
Test-Path -LiteralPath $strFilePath
Get-Content -LiteralPath $strConfigFile -ErrorAction Stop
Remove-Item -LiteralPath $strTempFile -Force
```

**Non-compliant** (variable-derived path with `-Path`):

```powershell
# Risk: $strFilePath may contain [] or wildcard characters
Test-Path -Path $strFilePath
Get-Content -Path $strConfigFile -ErrorAction Stop
Remove-Item -Path $strTempFile -Force   # Dangerous: destructive + wildcard
```

**Acceptable** (intentional wildcard):

```powershell
# Intentional wildcard — -Path is correct here:
Get-ChildItem -Path 'C:\Logs\*.log'
Remove-Item -Path 'C:\Temp\*.tmp' -Force
```
