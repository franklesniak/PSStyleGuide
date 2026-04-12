---
applyTo:  "**/*.ps1"
description: "PowerShell coding standards"
---

# PowerShell Writing Style

**Version:** 2.0.20260412.0

## Metadata

- **Status:** Active
- **Owner:** Repository Maintainers
- **Last Updated:** 2026-04-12
- **Scope:** Defines PowerShell coding standards for all `.ps1` files in this repository. Covers style, formatting, naming conventions, error handling, documentation requirements, and compatibility patterns for both legacy (v1.0) and modern (v5.1+/v7.x+) PowerShell codebases.

## Table of Contents

- [Keywords](#keywords)
- [Quick Reference Checklist](#quick-reference-checklist)
- [Executive Summary: Author Profile](#executive-summary-author-profile)
- [Code Layout and Formatting](#code-layout-and-formatting)
- [Capitalization and Naming Conventions](#capitalization-and-naming-conventions)
- [Documentation and Comments](#documentation-and-comments)
- [Functions and Parameter Blocks](#functions-and-parameter-blocks)
- [Error Handling](#error-handling)
- [File Writeability Testing](#file-writeability-testing)
- [Operating System Compatibility Checks](#operating-system-compatibility-checks)
- [Language Interop, Versioning, and .NET](#language-interop-versioning-and-net)
- [Output Formatting and Streams](#output-formatting-and-streams)
- [Testing with Pester](#testing-with-pester)
- [Performance, Security, and Other](#performance-security-and-other)

## Keywords

The key words "**MUST**", "**MUST NOT**", "**REQUIRED**", "**SHALL**", "**SHALL NOT**", "**SHOULD**", "**SHOULD NOT**", "**RECOMMENDED**", "**MAY**", and "**OPTIONAL**" in this document are to be interpreted as described in [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119).

- **MUST** / **REQUIRED** / **SHALL** — Absolute requirement. Non-negotiable.
- **MUST NOT** / **SHALL NOT** — Absolute prohibition.
- **SHOULD** / **RECOMMENDED** — Strong recommendation. Valid reasons may exist to deviate, but implications must be understood.
- **SHOULD NOT** / **NOT RECOMMENDED** — Strong discouragement. Valid reasons may exist to do otherwise, but implications must be understood.
- **MAY** / **OPTIONAL** — Truly optional. Implementations can choose to include or omit.

## Quick Reference Checklist

This checklist provides a quick reference for both human developers and LLMs (like GitHub Copilot) to follow the PowerShell style guidelines. Each item includes a scope tag indicating applicability: **[All]** applies to all PowerShell scripts regardless of target version, **[Modern]** applies only to scripts targeting PowerShell 5.1+ (with .NET Framework 4.6.2+) and PowerShell 7.x+ (requires features not available in v1.0), and **[v1.0]** applies only to scripts that **MUST** be backward compatible with Windows PowerShell v1.0. Each checklist item links to its detailed section for more information. This checklist is intentionally placed within the first 100-200 lines to give LLMs a complete picture of the style guide's requirements early in the document.

### Code Layout and Formatting

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

### Capitalization and Naming Conventions

- **[All]** Public identifiers (functions, parameters, properties) **MUST** use PascalCase → [Overview of Observed Naming Discipline](#overview-of-observed-naming-discipline)
- **[All]** PowerShell keywords (function, param, if, else, return, trap) **MUST** be lowercase → [Overview of Observed Naming Discipline](#overview-of-observed-naming-discipline)
- **[All]** Local variables **MUST** use camelCase with type-hinting prefixes, fully descriptive (e.g., $strMessage, $intCount, no abbreviations) → [Local Variable Naming: Type-Prefixed camelCase](#local-variable-naming-type-prefixed-camelcase)
- **[All]** Functions **MUST** follow Verb-Noun pattern with approved verbs → [Script and Function Naming: Full Explicit Form](#script-and-function-naming-full-explicit-form)
- **[All]** Functions **MUST** use singular nouns in function names → [Script and Function Naming: Nouns](#script-and-function-naming-nouns)
- **[All]** Modules **MUST** use PascalCase nouns (containers, not actions) → [Module Naming: Noun-Based Containers](#module-naming-noun-based-containers)
- **[All]** Aliases **MUST NOT** be used in code → [Do Not Use Aliases](#do-not-use-aliases)
- **[Modern]** Modules **MUST NOT** export compatibility aliases (exception: genuine interactive shortcuts) → [Do Not Use Aliases](#do-not-use-aliases)
- **[All]** Parameters **MUST** use PascalCase, fully descriptive names → [Parameter Naming](#parameter-naming)
- **[v1.0]** Reference parameters **MUST** use "ReferenceTo" prefix → [Parameter Naming](#parameter-naming)
- **[All]** Code **SHOULD** avoid relative paths and tilde (~) shortcut → [Path and Scope Handling](#path-and-scope-handling)
- **[All]** Code **SHOULD** use explicit scoping ($global:, $script:) → [Path and Scope Handling](#path-and-scope-handling)

### Documentation and Comments

- **[All]** All functions **MUST** have full comment-based help → [Comment-Based Help: Structure and Format](#comment-based-help-structure-and-format)
- **[All]** Comment-based help **MUST** be placed inside function body, above param block → [Comment-Based Help: Structure and Format](#comment-based-help-structure-and-format)
- **[All]** Comment-based help **MUST** use single-line comments (#) with dotted keywords (.SYNOPSIS, .DESCRIPTION, etc.) → [Comment-Based Help: Structure and Format](#comment-based-help-structure-and-format)
- **[v1.0]** Block comments (`<# ... #>`) **MUST NOT** be used — they cause parser errors in PowerShell v1.0; use single-line comments (`#`) instead → [Help Format Options: Comparison](#help-format-options-comparison)
- **[All]** Comment-based help **MUST** include sections: .SYNOPSIS, .DESCRIPTION, .PARAMETER (one per parameter, if any), .EXAMPLE, .INPUTS, .OUTPUTS, .NOTES → [Comment-Based Help: Structure and Format](#comment-based-help-structure-and-format)
- **[All]** Explanatory or output-description lines within `.EXAMPLE` blocks **MUST** use double `#` (`# # <text>`) so that `Get-Help` renders them as valid PowerShell comments (`# <text>`) → [Inline Comments Within `.EXAMPLE` Blocks](#inline-comments-within-example-blocks)
- **[All]** Functions **SHOULD** provide multiple examples with input, output, and explanation → [Help Content Quality: High Standards](#help-content-quality-high-standards)
- **[All]** All return codes **MUST** be documented with exact meanings in .OUTPUTS → [Help Content Quality: High Standards](#help-content-quality-high-standards)
- **[All]** Positional parameter support **MUST** be documented in .NOTES → [Help Content Quality: High Standards](#help-content-quality-high-standards)
- **[All]** Version number **MUST** be included in .NOTES (format: Major.Minor.YYYYMMDD.Revision) → [Function and Script Versioning](#function-and-script-versioning)
- **[All]** Version build component **MUST** be current date in YYYYMMDD format → [Function and Script Versioning](#function-and-script-versioning)
- **[All]** Inline comments **SHOULD** focus on "why" not "what" → [Inline Comments: Purpose and Placement](#inline-comments-purpose-and-placement)
- **[All]** Code **SHOULD** use #region / #endregion for logical code folding → [Structural Documentation: Regions and Licensing](#structural-documentation-regions-and-licensing)
- **[All]** The param() block **MUST** be placed before license region (if applicable) → [Structural Documentation: Regions and Licensing](#structural-documentation-regions-and-licensing)
- **[All]** Distributable helpers **SHOULD** use per-function licensing (#region License after param block) → [Structural Documentation: Regions and Licensing](#structural-documentation-regions-and-licensing)
- **[All]** Parameter documentation **SHOULD** be centralized in help block, not above individual parameters → [Parameter Documentation Placement: Strategic Choice](#parameter-documentation-placement-strategic-choice)

### Functions and Parameter Blocks

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
- **[v1.0]** v1.0-targeted functions **MUST** use trap-based error handling (not try/catch) → [Overview of Function Architecture](#overview-of-function-architecture)
- **[Modern]** Modern functions and scripts **MUST** use [CmdletBinding()] attribute → [Rule: "Modern Advanced" Function/Script Requirements (v2.0+)](#rule-modern-advanced-functionscript-requirements-v20)
- **[Modern]** Modern functions and scripts **MUST** use [OutputType()] declaring singular primary type → [Rule: "Modern Advanced" Function/Script Requirements (v2.0+)](#rule-modern-advanced-functionscript-requirements-v20)
- **[Modern]** Modern functions and scripts **MUST** use streaming output (write objects directly to pipeline in loop) → [Rule: "Modern Advanced" Function/Script Requirements (v2.0+)](#rule-modern-advanced-functionscript-requirements-v20)
- **[Modern]** Modern functions and scripts **MUST** use try/catch for error handling → [Rule: "Modern Advanced" Function/Script Requirements (v2.0+)](#rule-modern-advanced-functionscript-requirements-v20)
- **[Modern]** Modern functions and scripts **MUST** use Write-Verbose and Write-Debug (not manual preference toggling) → [Rule: "Modern Advanced" Function/Script Requirements (v2.0+)](#rule-modern-advanced-functionscript-requirements-v20)
- **[Modern]** Exception: Modern functions and scripts **MAY** temporarily suppress $VerbosePreference for noisy nested commands using try/finally → ["Modern Advanced" Functions/Scripts: Exception for Suppressing Nested Verbose Streams](#modern-advanced-functionsscripts-exception-for-suppressing-nested-verbose-streams)
- **[Modern]** [Parameter(Mandatory=$true)] **SHOULD** be used only when function cannot work without value → ["Modern Advanced" Functions/Scripts: Parameter Validation and Attributes (`[Parameter()]`)](#modern-advanced-functionsscripts-parameter-validation-and-attributes-parameter)
- **[Modern]** [ValidateNotNullOrEmpty()] **SHOULD** be used for optional-but-not-empty parameters and for mandatory [string] parameters whose logic depends on a non-empty value → ["Modern Advanced" Functions/Scripts: Parameter Validation and Attributes (`[Parameter()]`)](#modern-advanced-functionsscripts-parameter-validation-and-attributes-parameter)
- **[Modern]** Multiple [OutputType()] **SHOULD** only be used for intentionally polymorphic returns → ["Modern Advanced" Functions/Scripts: Handling Multiple or Dynamic Output Types](#modern-advanced-functionsscripts-handling-multiple-or-dynamic-output-types)
- **[All]** Functions **MUST** be atomic, reusable tools with single purpose → [Overview of Function Architecture](#overview-of-function-architecture)
- **[All]** Polymorphic parameters (multiple incompatible types) **SHOULD** be left un-typed or [object] → [Parameter Block Design: Detailed Analysis](#parameter-block-design-detailed-analysis)
- **[All]** [ref] **MUST** be used exclusively for output requiring write-back to caller scope → [Input/Output Contract: Reference Parameters](#inputoutput-contract-reference-parameters)
- **[All]** [ref] **MUST NOT** be used for complex objects that don't need modification → [Input/Output Contract: Reference Parameters](#inputoutput-contract-reference-parameters)

### Error Handling

- **[v1.0]** v1.0-targeted functions **MUST** use trap {} for error suppression → [Core Error Suppression Mechanism](#core-error-suppression-mechanism)
- **[Modern]** catch blocks **MUST NOT** be empty; default pattern is `Write-Debug` + `throw` → [Modern catch Block Requirements](#modern-catch-block-requirements)
- **[Modern]** Non-throwing catch (no `throw`) **MUST** have a documented non-throwing contract → [Modern catch Block Requirements](#modern-catch-block-requirements)
- **[Modern]** `throw "message"` and `throw ("fmt" -f $args)` **MUST NOT** be used in catch blocks intended to rethrow → [Rethrow Anti-Pattern](#rethrow-anti-pattern)
- **[Modern]** Exception wrapping **SHOULD** use `$PSCmdlet.ThrowTerminatingError()` with the original as `InnerException` → [Wrapping Exceptions with `$PSCmdlet.ThrowTerminatingError()`](#wrapping-exceptions-with-pscmdletthrowterminatingerror)
- **[Modern]** Variables referenced in `finally` that are assigned in `try` **MUST** be initialized before the `try` block → [Set-StrictMode Considerations for finally Blocks](#set-strictmode-considerations-for-finally-blocks)

### File Writeability Testing

- **[All]** Scripts **MUST** verify file writeability before significant processing when writing output to files → [File Writeability Testing](#file-writeability-testing)
- **[v1.0]** v1.0-targeted scripts **MUST** use `.NET` approach (`Test-FileWriteability` function) → [Scripts Requiring PowerShell v1.0 Support](#scripts-requiring-powershell-v10-support)
- **[Modern]** v2.0+ scripts **MAY** use `.NET` or `try/catch` approach based on requirements → [Scripts Requiring PowerShell v2.0+ Support](#scripts-requiring-powershell-v20-support)

### Operating System Compatibility Checks

- **[All]** Scripts/functions supporting only specific operating systems **MUST** include OS compatibility checks → [When OS Checks Are Required](#when-os-checks-are-required)
- **[Modern]** PowerShell Core 6.0+ only scripts **SHOULD** use built-in `$IsWindows`, `$IsMacOS`, `$IsLinux` variables → [PowerShell Core 6.0+ OS Detection](#powershell-core-60-os-detection)
- **[v1.0]** Scripts supporting older versions **MUST** use `Test-Windows`, `Test-macOS`, `Test-Linux` functions from PowerShell_Resources → [Cross-Version OS Detection](#cross-version-os-detection)
- **[All]** Wrong OS errors **MUST** be reported consistently with existing error handling patterns → [Error Handling for Wrong OS](#error-handling-for-wrong-os)

### Output Formatting and Streams

- **[Modern]** Modern functions **MUST NOT** collect results in `List<T>` and return; **MUST** stream objects to pipeline → [Processing Collections in Modern Functions (Streaming Output)](#processing-collections-in-modern-functions-streaming-output)
- **[Modern]** Streaming function calls **SHOULD** be wrapped in @(...) to handle 0-1-Many problem → [Consuming Streaming Functions (The `0-1-Many` Problem)](#consuming-streaming-functions-the-0-1-many-problem)
- **[All]** Code **MUST** use Write-Warning for user-facing anomalies; Write-Debug for internal details → [Choosing Between Warning and Debug Streams](#choosing-between-warning-and-debug-streams)
- **[All]** .NET method output **MUST** be suppressed with [void](...), not | Out-Null → [Suppression of Method Output](#suppression-of-method-output)
- **[All]** `Write-Verbose` / `Write-Debug` **MUST NOT** emit raw PII, credentials, tokens, or other sensitive identifiers → [Sensitive Data in Verbose and Debug Streams](#sensitive-data-in-verbose-and-debug-streams)
- **[Modern]** Hot-path `Write-Verbose` / `Write-Debug` with string formatting **SHOULD** be guarded behind a preference check → [Performance-Sensitive `Write-Verbose` / `Write-Debug` in Hot Paths](#performance-sensitive-write-verbose--write-debug-in-hot-paths)

### Language Interop and .NET

- **[All]** `System.Collections.ArrayList` is deprecated and **MUST NOT** be used in new code; use `System.Collections.Generic.List[T]` instead → [.NET Interop Patterns: Safe and Documented](#net-interop-patterns-safe-and-documented)
- **[All]** Generic collections **MUST** provide specific type T (List[PSCustomObject], not List[object]) → [.NET Interop Patterns: Safe and Documented](#net-interop-patterns-safe-and-documented)

### Testing

- **[All]** New functions **SHOULD** have corresponding Pester tests when testability is a project requirement → [Testing with Pester](#testing-with-pester)
- **[All]** Test files **MUST** use `*.Tests.ps1` naming convention → [Test File Naming and Location](#test-file-naming-and-location)
- **[All]** Tests **MUST** use Pester 5.x syntax (BeforeAll, Describe, Context, It) → [Pester 5.x Syntax Requirements](#pester-5x-syntax-requirements)
- **[All]** Tests **SHOULD** use Arrange-Act-Assert pattern in test cases → [Test Structure: Arrange-Act-Assert](#test-structure-arrange-act-assert)
- **[All]** Tests **MUST** verify all documented return codes for functions → [Testing Return Code Conventions](#testing-return-code-conventions)
- **[All]** Test-* functions **MUST** have tests for both `$true` and `$false` cases → [Testing Return Code Conventions](#testing-return-code-conventions)
- **[All]** Tests asserting property names on `[pscustomobject]` **MUST** use order-insensitive comparisons → [Testing Property Names on PSCustomObject](#testing-property-names-on-pscustomobject)
- **[All]** Test `BeforeAll` dot-sourcing **MUST** use the `Split-Path` + `Join-Path` two-step pattern; multi-segment `Join-Path` forms **MUST NOT** be used → [Test File Dot-Sourcing Pattern](#test-file-dot-sourcing-pattern)

## Executive Summary: Author Profile

*This section intentionally left blank.*

## Code Layout and Formatting

The layout emphasizes scannability, consistency, and readability, following community guidelines to make the code familiar and easy to maintain.

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

Example snippet illustrating bracing, indentation, spacing, and blank lines:

```powershell
function ExampleFunction {
    param (
        [string]$ParamOne
    )

    if ($ParamOne -gt 0) {
        # Spaced operator example
    } else {
        # Alternative path
    }

    return 0
}
```

### Trailing Whitespace

**Lines MUST NOT end with trailing whitespace** (spaces or tabs). Trailing whitespace can cause issues with version control systems, some editors, and linters. It also serves no functional purpose and reduces code consistency.

**Compliant (no trailing whitespace):**

```powershell
function ExampleFunction {
    param (
        [string]$ParamOne
    )
}
```

**Non-Compliant (trailing spaces on line 3):**

```powershell
function ExampleFunction {
    param (
        [string]$ParamOne   # ← trailing spaces here (not shown)
    )
}
```

In the non-compliant example, line 3 would end with trailing spaces after `$ParamOne` (before the comment), which is not allowed. The actual trailing spaces are not shown in this documentation to avoid violating the rule within this file itself.

Most modern editors can be configured to automatically remove trailing whitespace on save, which is **RECOMMENDED** to maintain compliance with this rule.

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

- **Compliant (Acceptable):** Use string concatenation.

  ```powershell
  $strMessage = ($SSORegion + ': Error occurred')
  ```

## Capitalization and Naming Conventions

Capitalization and naming **MUST** follow .NET-inspired conventions for consistency and readability, treating PowerShell as a .NET scripting language. All public identifiers—function names, parameters, and attributes—**MUST** use PascalCase (e.g., Convert-StringToObject, $ReferenceToResultObject). Language keywords (e.g., function, param, if, else, return, trap) **MUST** always be lowercase. Operators like -gt or -eq **MUST** be lowercase with surrounding spaces.

Function names **MUST** strictly use the Verb-Noun pattern with approved verbs (e.g., Convert-, Get-, Test-, Split-) and singular nouns, ensuring discoverability and avoiding duplication. Parameters **MUST** be descriptive and PascalCased, with aliases (if any) documented in help. Local variables **MUST** use camelCase with a type-hinting prefix (e.g., $strMessage for strings, $intReturnValue for integers, $boolResult for booleans, $arrElements for arrays). This prefixing is a deliberate choice to make intended types obvious in a dynamically typed language, especially without IDE support—enhancing clarity at the cost of slight verbosity.

### Overview of Observed Naming Discipline

*This section intentionally left blank.*

### Script and Function Naming: Full Explicit Form

**Function names** **MUST** strictly adhere to the **Verb-Noun** pattern using **approved verbs** and **singular nouns**, rendered in **PascalCase**. Examples include:

- `Convert-StringToObject`
- `Get-ReferenceToLastError`
- `Test-ErrorOccurred`
- `Split-StringOnLiteralString`

### Script and Function Naming: Approved Verbs

Using approved verbs is a core PowerShell convention that ensures discoverability and consistency. You **MAY** always retrieve the complete list of approved verbs by running the following command:

```powershell
Get-Verb
```

If a verb (like `Review` or `Check`) is not on this list, you **MUST** choose the closest approved alternative, such as `Get-` (to retrieve information) or `Test-` (to return a boolean).

The list of approved PowerShell verbs can be viewed [on Microsoft's Docs page](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.5). For offline scenarios, a copy of this page is included below, retrieved on November 3, 2025:

PowerShell uses a verb-noun pair for the names of cmdlets and for their derived .NET classes. The verb part of the name identifies the action that the cmdlet performs. The noun part of the name identifies the entity on which the action is performed. For example, the `Get-Command` cmdlet retrieves all the commands that are registered in PowerShell.

> **Note:** PowerShell uses the term *verb* to describe a word that implies an action even if that word isn't a standard verb in the English language. For example, the term `New` is a valid PowerShell verb name because it implies an action even though it isn't a verb in the English language.

Each approved verb has a corresponding *alias prefix* defined. We use this alias prefix in aliases for commands using that verb. For example, the alias prefix for `Import` is `ip` and, accordingly, the alias for `Import-Module` is `ipmo`. This is a recommendation but not a rule; in particular, it need not be respected for command aliases mimicking well known commands from other environments.

#### Verb Naming Recommendations

The following recommendations help you choose an appropriate verb for your cmdlet, to ensure consistency between the cmdlets that you create, the cmdlets that are provided by PowerShell, and the cmdlets that are designed by others.

- Use one of the predefined verb names provided by PowerShell
- Use the verb to describe the general scope of the action, and use parameters to further refine the action of the cmdlet.
- Don't use a synonym of an approved verb. For example, always use `Remove`, never use `Delete` or `Eliminate`.
- Use only the form of each verb that's listed in this topic. For example, use `Get`, but don't use `Getting` or `Gets`.
- Don't use the following reserved verbs or aliases. The PowerShell language and a rare few cmdlets use these verbs under exceptional circumstances.
  - `ForEach` (`foreach`)
  - `Ping` (`pi`)
  - `Sort` (`sr`)
  - `Tee` (`te`)
  - `Where` (`wh`)

You **MAY** get a complete list of verbs using the `Get-Verb` cmdlet.

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

PowerShell uses the `System.Management.Automation.VerbsCommon` enumeration class to define generic actions that can apply to almost any cmdlet. The following table lists most of the defined verbs.

| Verb (alias) | Action | Synonyms to avoid |
| --- | --- | --- |
| `Add` (`a`) | Adds a resource to a container, or attaches an item to another item. For example, the `Add-Content` cmdlet adds content to a file. This verb is paired with `Remove`. | Append, Attach, Concatenate, Insert |
| `Clear` (`cl`) | Removes all the resources from a container but doesn't delete the container. For example, the `Clear-Content` cmdlet removes the contents of a file but doesn't delete the file. | Flush, Erase, Release, Unmark, Unset, Nullify |
| `Close` (`cs`) | Changes the state of a resource to make it inaccessible, unavailable, or unusable. This verb is paired with `Open.` | |
| `Copy` (`cp`) | Copies a resource to another name or to another container. For example, the `Copy-Item` cmdlet copies an item (such as a file) from one location in the data store to another location. | Duplicate, Clone, Replicate, Sync |
| `Enter` (`et`) | Specifies an action that allows the user to move into a resource. For example, the `Enter-PSSession` cmdlet places the user in an interactive session. This verb is paired with `Exit`. | Push, Into |
| `Exit` (`ex`) | Sets the current environment or context to the most recently used context. For example, the `Exit-PSSession` cmdlet places the user in the session that was used to start the interactive session. This verb is paired with `Enter`. | Pop, Out |
| `Find` (`fd`) | Looks for an object in a container that's unknown, implied, optional, or specified. | Search |
| `Format` (`f`) | Arranges objects in a specified form or layout | |
| `Get` (`g`) | Specifies an action that retrieves a resource. This verb is paired with `Set`. | Read, Open, Cat, Type, Dir, Obtain, Dump, Acquire, Examine, Find, Search |
| `Hide` (`h`) | Makes a resource undetectable. For example, a cmdlet whose name includes the Hide verb might conceal a service from a user. This verb is paired with `Show`. | Block |
| `Join` (`j`) | Combines resources into one resource. For example, the `Join-Path` cmdlet combines a path with one of its child paths to create a single path. This verb is paired with `Split`. | Combine, Unite, Connect, Associate |
| `Lock` (`lk`) | Secures a resource. This verb is paired with `Unlock`. | Restrict, Secure |
| `Move` (`m`) | Moves a resource from one location to another. For example, the `Move-Item` cmdlet moves an item from one location in the data store to another location. | Transfer, Name, Migrate |
| `New` (`n`) | Creates a resource. (The `Set` verb can also be used when creating a resource that includes data, such as the `Set-Variable` cmdlet.) | Create, Generate, Build, Make, Allocate |
| `Open` (`op`) | Changes the state of a resource to make it accessible, available, or usable. This verb is paired with `Close`. | |
| `Optimize` (`om`) | Increases the effectiveness of a resource. | |
| `Pop` (`pop`) | Removes an item from the top of a stack. For example, the `Pop-Location` cmdlet changes the current location to the location that was most recently pushed onto the stack. | |
| `Push` (`pu`) | Adds an item to the top of a stack. For example, the `Push-Location` cmdlet pushes the current location onto the stack. | |
| `Redo` (`re`) | Resets a resource to the state that was undone. | |
| `Remove` (`r`) | Deletes a resource from a container. For example, the `Remove-Variable` cmdlet deletes a variable and its value. This verb is paired with `Add`. | Clear, Cut, Dispose, Discard, Erase |
| `Rename` (`rn`) | Changes the name of a resource. For example, the `Rename-Item` cmdlet, which is used to access stored data, changes the name of an item in the data store. | Change |
| `Reset` (`rs`) | Sets a resource back to its original state. | |
| `Resize` (`rz`) | Changes the size of a resource. | |
| `Search` (`sr`) | Creates a reference to a resource in a container. | Find, Locate |
| `Select` (`sc`) | Locates a resource in a container. For example, the `Select-String` cmdlet finds text in strings and files. | Find, Locate |
| `Set` (`s`) | Replaces data on an existing resource or creates a resource that contains some data. For example, the `Set-Date` cmdlet changes the system time on the local computer. (The `New` verb can also be used to create a resource.) This verb is paired with `Get`. | Write, Reset, Assign, Configure, Update |
| `Show` (`sh`) | Makes a resource visible to the user. This verb is paired with `Hide`. | Display, Produce |
| `Skip` (`sk`) | Bypasses one or more resources or points in a sequence. | Bypass, Jump |
| `Split` (`sl`) | Separates parts of a resource. For example, the `Split-Path` cmdlet returns different parts of a path. This verb is paired with `Join`. | Separate |
| `Step` (`st`) | Moves to the next point or resource in a sequence. | |
| `Switch` (`sw`) | Specifies an action that alternates between two resources, such as to change between two locations, responsibilities, or states. | |
| `Undo` (`un`) | Sets a resource to its previous state. | |
| `Unlock` (`uk`) | Releases a resource that was locked. This verb is paired with `Lock`. | Release, Unrestrict, Unsecure |
| `Watch` (`wc`) | Continually inspects or monitors a resource for changes. | |

#### Communications Verbs

PowerShell uses the `System.Management.Automation.VerbsCommunications` class to define actions that apply to communications. The following table lists most of the defined verbs.

| Verb (alias) | Action | Synonyms to avoid |
| --- | --- | --- |
| `Connect` (`cc`) | Creates a link between a source and a destination. This verb is paired with `Disconnect`. | Join, Telnet, Login |
| `Disconnect` (`dc`) | Breaks the link between a source and a destination. This verb is paired with `Connect`. | Break, Logoff |
| `Read` (`rd`) | Acquires information from a source. This verb is paired with `Write`. | Acquire, Prompt, Get |
| `Receive` (`rc`) | Accepts information sent from a source. This verb is paired with `Send`. | Read, Accept, Peek |
| `Send` (`sd`) | Delivers information to a destination. This verb is paired with `Receive`. | Put, Broadcast, Mail, Fax |
| `Write` (`wr`) | Adds information to a target. This verb is paired with `Read`. | Put, Print |

#### Data Verbs

PowerShell uses the `System.Management.Automation.VerbsData` class to define actions that apply to data handling. The following table lists most of the defined verbs.

| Verb (alias) | Action | Synonyms to avoid |
| --- | --- | --- |
| `Backup` (`ba`) | Stores data by replicating it. | Save, Burn, Replicate, Sync |
| `Checkpoint` (`ch`) | Creates a snapshot of the current state of the data or of its configuration. | Diff |
| `Compare` (`cr`) | Evaluates the data from one resource against the data from another resource. | Diff |
| `Compress` (`cm`) | Compacts the data of a resource. Pairs with `Expand`. | Compact |
| `Convert` (`cv`) | Changes the data from one representation to another when the cmdlet supports bidirectional conversion or when the cmdlet supports conversion between multiple data types. | Change, Resize, Resample |
| `ConvertFrom` (`cf`) | Converts one primary type of input (the cmdlet noun indicates the input) to one or more supported output types. | Export, Output, Out |
| `ConvertTo` (`ct`) | Converts from one or more types of input to a primary output type (the cmdlet noun indicates the output type). | Import, Input, In |
| `Dismount` (`dm`) | Detaches a named entity from a location. This verb is paired with `Mount`. | Unmount, Unlink |
| `Edit` (`ed`) | Modifies existing data by adding or removing content. | Change, Update, Modify |
| `Expand` (`en`) | Restores the data of a resource that has been compressed to its original state. This verb is paired with `Compress`. | Explode, Uncompress |
| `Export` (`ep`) | Encapsulates the primary input into a persistent data store, such as a file, or into an interchange format. This verb is paired with `Import`. | Extract, Backup |
| `Group` (`gp`) | Arranges or associates one or more resources | |
| `Import` (`ip`) | Creates a resource from data that's stored in a persistent data store (such as a file) or in an interchange format. For example, the `Import-Csv` cmdlet imports data from a comma-separated value (`CSV`) file to objects that can be used by other cmdlets. This verb is paired with `Export`. | BulkLoad, Load |
| `Initialize` (`in`) | Prepares a resource for use, and sets it to a default state. | Erase, Init, Renew, Rebuild, Reinitialize, Setup |
| `Limit` (`l`) | Applies constraints to a resource. | Quota |
| `Merge` (`mg`) | Creates a single resource from multiple resources. | Combine, Join |
| `Mount` (`mt`) | Attaches a named entity to a location. This verb is paired with `Dismount`. | Connect |
| `Out` (`o`) | Sends data out of the environment. For example, the `Out-Printer` cmdlet sends data to a printer. | |
| `Publish` (`pb`) | Makes a resource available to others. This verb is paired with `Unpublish`. | Deploy, Release, Install |
| `Restore` (`rr`) | Sets a resource to a predefined state, such as a state set by `Checkpoint`. For example, the `Restore-Computer` cmdlet starts a system restore on the local computer. | Repair, Return, Undo, Fix |
| `Save` (`sv`) | Preserves data to avoid loss. | |
| `Sync` (`sy`) | Assures that two or more resources are in the same state. | Replicate, Coerce, Match |
| `Unpublish` (`ub`) | Makes a resource unavailable to others. This verb is paired with `Publish`. | Uninstall, Revert, Hide |
| `Update` (`ud`) | Brings a resource up-to-date to maintain its state, accuracy, conformance, or compliance. For example, the `Update-FormatData` cmdlet updates and adds formatting files to the current PowerShell console. | Refresh, Renew, Recalculate, Re-index |

#### Diagnostic Verbs

PowerShell uses the `System.Management.Automation.VerbsDiagnostic` class to define actions that apply to diagnostics. The following table lists most of the defined verbs.

| Verb (alias) | Action | Synonyms to avoid |
| --- | --- | --- |
| `Debug` (`db`) | Examines a resource to diagnose operational problems. | Diagnose |
| `Measure` (`ms`) | Identifies resources that are consumed by a specified operation, or retrieves statistics about a resource. | Calculate, Determine, Analyze |
| `Ping` (`pi`) | Deprecated - Use the Test verb instead. | |
| `Repair` (`rp`) | Restores a resource to a usable condition | Fix, Restore |
| `Resolve` (`rv`) | Maps a shorthand representation of a resource to a more complete representation. | Expand, Determine |
| `Test` (`t`) | Verifies the operation or consistency of a resource. | Diagnose, Analyze, Salvage, Verify |
| `Trace` (`tr`) | Tracks the activities of a resource. | Track, Follow, Inspect, Dig |

#### Lifecycle Verbs

PowerShell uses the `System.Management.Automation.VerbsLifecycle` class to define actions that apply to the lifecycle of a resource. The following table lists most of the defined verbs.

| Verb (alias) | Action | Synonyms to avoid |
| --- | --- | --- |
| `Approve` (`ap`) | Confirms or agrees to the status of a resource or process. | |
| `Assert` (`as`) | Affirms the state of a resource. | Certify |
| `Build` (`bd`) | Creates an artifact (usually a binary or document) out of some set of input files (usually source code or declarative documents.) This verb was added in PowerShell 6. | |
| `Complete` (`cp`) | Concludes an operation. | |
| `Confirm` (`cn`) | Acknowledges, verifies, or validates the state of a resource or process. | Acknowledge, Agree, Certify, Validate, Verify |
| `Deny` (`dn`) | Refuses, objects, blocks, or opposes the state of a resource or process. | Block, Object, Refuse, Reject |
| `Deploy` (`dp`) | Sends an application, website, or solution to a remote target[s] in such a way that a consumer of that solution can access it after deployment is complete. This verb was added in PowerShell 6. | |
| `Disable` (`d`) | Configures a resource to an unavailable or inactive state. For example, the `Disable-PSBreakpoint` cmdlet makes a breakpoint inactive. This verb is paired with `Enable`. | Halt, Hide |
| `Enable` (`e`) | Configures a resource to an available or active state. For example, the `Enable-PSBreakpoint` cmdlet makes a breakpoint active. This verb is paired with `Disable`. | Start, Begin |
| `Install` (`is`) | Places a resource in a location, and optionally initializes it. This verb is paired with `Uninstall`. | Setup |
| `Invoke` (`i`) | Performs an action, such as running a command or a method. | Run, Start |
| `Register` (`rg`) | Creates an entry for a resource in a repository such as a database. This verb is paired with `Unregister`. | |
| `Request` (`rq`) | Asks for a resource or asks for permissions. | |
| `Restart` (`rt`) | Stops an operation and then starts it again. For example, the `Restart-Service` cmdlet stops and then starts a service. | Recycle |
| `Resume` (`ru`) | Starts an operation that has been suspended. For example, the `Resume-Service` cmdlet starts a service that has been suspended. This verb is paired with `Suspend`. | |
| `Start` (`sa`) | Initiates an operation. For example, the `Start-Service` cmdlet starts a service. This verb is paired with `Stop`. | Launch, Initiate, Boot |
| `Stop` (`sp`) | Discontinues an activity. This verb is paired with `Start`. | End, Kill, Terminate, Cancel |
| `Submit` (`sb`) | Presents a resource for approval. | Post |
| `Suspend` (`ss`) | Pauses an activity. For example, the `Suspend-Service` cmdlet pauses a service. This verb is paired with `Resume`. | Pause |
| `Uninstall` (`us`) | Removes a resource from an indicated location. This verb is paired with `Install`. | |
| `Unregister` (`ur`) | Removes the entry for a resource from a repository. This verb is paired with `Register`. | Remove |
| `Wait` (`w`) | Pauses an operation until a specified event occurs. For example, the `Wait-Job` cmdlet pauses operations until one or more of the background jobs are complete. | Sleep, Pause |

#### Security Verbs

PowerShell uses the `System.Management.Automation.VerbsSecurity` class to define actions that apply to security. The following table lists most of the defined verbs.

| Verb (alias) | Action | Synonyms to avoid |
| --- | --- | --- |
| `Block` (`bl`) | Restricts access to a resource. This verb is paired with `Unblock`. | Prevent, Limit, Deny |
| `Grant` (`gr`) | Allows access to a resource. This verb is paired with `Revoke`. | Allow, Enable |
| `Protect` (`pt`) | Safeguards a resource from attack or loss. This verb is paired with `Unprotect`. | Encrypt, Safeguard, Seal |
| `Revoke` (`rk`) | Specifies an action that doesn't allow access to a resource. This verb is paired with `Grant`. | Remove, Disable |
| `Unblock` (`ul`) | Removes restrictions to a resource. This verb is paired with `Block`. | Clear, Allow |
| `Unprotect` (`up`) | Removes safeguards from a resource that were added to prevent it from attack or loss. This verb is paired with `Protect`. | Decrypt, Unseal |

#### Other Verbs

PowerShell uses the `System.Management.Automation.VerbsOther` class to define canonical verb names that don't fit into a specific verb name category such as the common, communications, data, lifecycle, or security verb names verbs.

| Verb (alias) | Action | Synonyms to avoid |
| --- | --- | --- |
| `Use` (`u`) | Uses or includes a resource to do something. | |

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

**Rationale:**

In the .NET Framework design philosophy, a **Verb-Noun** phrase represents an executable *method* or *command* (an action). A **Noun** represents the *class*, *library*, or *tool* that contains those capabilities (the container). Naming a module using a Verb-Noun pattern (e.g., `FlattenObject`) blurs this distinction and creates cognitive dissonance, leading users to falsely expect a command named `Flatten-Object` to exist.

By naming the module `ObjectFlattener` (the tool) and the function `ConvertTo-FlatObject` (the action), the architecture remains semantically pure and aligned with Microsoft's own structural standards (e.g., the module `Microsoft.Graph` contains the command `Get-MgUser`).

**Discoverability Strategy:**

Module names **MUST NOT** be compromised for the sake of keyword searching. Instead, rely on the **Module Manifest (`.psd1`)** to handle discoverability. The `Tags` key in the manifest **MUST** be populated aggressively with relevant keywords (including verbs) to ensure the module is found during searches, while keeping the architectural name pure.

### Do Not Use Aliases

Aliases (e.g., `gci`, `gps`) or abbreviated forms **MUST NOT** appear in the code. Even common operations **MUST** use full command names. This ensures:

1. **Discoverability**: The code is immediately understandable to any PowerShell user.
2. **Future-proofing**: Changes to parameter sets in underlying cmdlets cannot break the script due to positional or partial-name matching.
3. **Syntax highlighting**: Full names trigger proper IDE and GitHub syntax coloring.

Furthermore, **Modules MUST NOT export "Compatibility Aliases"** solely to bridge a gap between a module name and a command name. For example, if a module is named `ObjectFlattener`, do **not** export an alias `Flatten-Object` just to make the syntax feel "natural." The command name `ConvertTo-FlatObject` is structurally correct; relying on an alias suggests a flaw in the underlying naming architecture.

**Exceptions:**

Aliases **MAY** only be exported in a Module Manifest if they provide genuine short-hand convenience for *interactive* users (e.g., `cfo` for `ConvertTo-FlatObject`) and are strictly documented as optional. They **MUST NOT** be used to mask non-approved verbs.

### Parameter Naming

**Parameter names** **MUST** follow the same PascalCase convention and **MUST** be highly descriptive:

- `$ReferenceToResultObject`
- `$ReferenceArrayOfExtraStrings`
- `$StringToProcess`
- `$PSVersion`

These names leave no ambiguity about the parameter’s purpose, expected type, or direction of data flow. The use of `ReferenceTo` prefix for `[ref]` parameters is a deliberate pattern that instantly signals **pass-by-reference** semantics—a critical distinction in PowerShell v1.0 where such mechanics are not visually obvious. However, [ref] **MUST** be used only when data needs to be written back to the caller's scope (e.g., for modifying variables or returning multiple outputs); for passing complex objects that do not need modification, they are passed by value, as [ref] offers no performance advantages in PowerShell.

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

This prefixing is **not** a legacy artifact but a **deliberate design decision** to compensate for PowerShell’s dynamic typing and the frequent absence of modern IDE tooling. The prefix:

- **Eliminates type inference errors** during debugging.
- **Reduces cognitive load** when reading code without IntelliSense.
- **Prevents accidental type mismatches** in complex logic flows.

While some modern styles discourage such prefixes, in this context they represent **defensive programming**—a hallmark of the author’s robustness philosophy that applies to all scripts regardless of target PowerShell version.

### Path and Scope Handling

Code **SHOULD** avoid relative paths (`.`, `..`) and the **home directory shortcut `~`** entirely. This is due to:

- `~` behavior varies by provider (FileSystem vs. Registry vs. others).
- Relative paths depend on `[Environment]::CurrentDirectory`, which **MAY** diverge from `$PWD` when calling .NET methods or external tools.

Instead, **explicit scoping** **SHOULD** be used:

```powershell
$global:ErrorActionPreference
```

For shared state, the author would use:

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
Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath '../config.json')
```

### Options for Local Variable Prefixes: Analysis

*This section intentionally left blank.*

### Summary: Naming as Defensive Architecture

*This section intentionally left blank.*

## Documentation and Comments

### Overview of Documentation Philosophy

*This section intentionally left blank.*

---

### Comment-Based Help: Structure and Format

All functions **MUST** include **full comment-based help** using **single-line comments** (`#`) with **dotted keywords** (`.SYNOPSIS`, `.DESCRIPTION`, etc.). The help block **MUST** be **placed inside the function**, **immediately above the `param` block**, ensuring:

- **Proximity to implementation** → reduces drift during refactoring
- **Visibility in plain text** → no IDE required
- **Discoverability via `Get-Help`** → works in PowerShell v1.0+

**Required sections for comment-based help**:

| Section | Purpose | Observed Implementation |
| --- | --- | --- |
| `.SYNOPSIS` | One-sentence purpose | Concise, imperative-voice summary |
| `.DESCRIPTION` | Detailed behavior | Explains logic, edge cases, and failure modes |
| `.PARAMETER` (if the function declares parameters in its `param()` block) | Per-parameter documentation | One block per parameter, even for `[ref]` types |
| `.EXAMPLE` | Usage demonstration | **Multiple examples** with input, output, and explanation |
| `.INPUTS` | Pipeline input | Explicitly "None" (correct for non-pipeline design) |
| `.OUTPUTS` | Return value semantics | Full mapping of integer codes to meanings |
| `.NOTES` | Additional context | Positional parameters, versioning, design rationale |

> **Note:** If a function declares no parameters in its `param()` block (excluding implicit common parameters), the `.PARAMETER` section is omitted entirely. Do not include an empty or placeholder `.PARAMETER` block.

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

---

### Help Content Quality: High Standards

The documentation exceeds minimal compliance and achieves **comprehensive completeness**:

1. **Behavioral Contracts**: Every possible return code is documented with **exact meaning**, **resulting state**, and **example**.
2. **Edge Case Coverage**: Examples include:
   - Valid input
   - Invalid segments
   - Overflow conditions
   - Excess parts
3. **State Transparency**: Shows **exact contents** of output variables after execution.
4. **Positional Parameter Support**: `.NOTES` explicitly documents positional ordering for v1.0 compatibility.
5. **Versioning**: Includes internal version in `.NOTES` for change tracking.

---

### Inline Comments: Purpose and Placement

Inline comments are **sparse but surgical**, focusing exclusively on **"why"** rather than **"what"**. They are:

- **Aligned** with at least two spaces from code
- **Grouped** logically (e.g., before error-handling setup)
- **Used only when behavior is non-obvious**

**Examples**:

```powershell
# Retrieve the newest error on the stack prior to doing work
$refLastKnownError = Get-ReferenceToLastError

# Set ErrorActionPreference to SilentlyContinue; this will suppress error output...
$global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
```

No redundant comments (e.g., `# Increment i by 1`) appear—code is considered self-documenting when possible.

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

In addition to top-level script regions, this pattern can be applied inside individual functions:

- **Function Structure with License**: For distributable helper functions, the structure **MUST** be: function declaration, comment-based help, `param()` block, and then the `#region License` block. The license region **MUST** be placed immediately after the function's `param()` block.

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

This enables:

- **Rapid navigation** in any editor
- **Isolation of concerns** (license, helpers, core logic)
- **Clear understanding** of design intent

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

Parameter help is **centralized in the comment-based help block**, not duplicated above individual parameters in the `param` block.

**Rationale**:

- **Single source of truth** → reduces maintenance drift
- **v1.0 compatibility** → avoids v2.0+ parameter attributes
- **Clarity in examples** → full context in one place

**Alternative considered (but not used)**: Inline comments above each parameter:

```powershell
param (
    # Reference to store the result object
    [ref]$ReferenceToResultObject,
    # Array to store extra strings
    [ref]$ReferenceArrayOfExtraStrings
)
```

- **Pros**: Immediate proximity
- **Cons**: Risk of desync, visual noise

The author’s choice prioritizes **consistency and maintainability**.

---

### Help Format Options: Comparison

The author uses **single-line comments** (`# .SECTION`) rather than **block comments** (`<# ... #>`).

| Format | Pros | Cons |
| --- | --- | --- |
| **Single-line (`#`)** | • Granular editing • Clear in diff tools • No escaping issues • Works in **all** PowerShell versions including v1.0 | • More vertical space • Slightly more typing |
| **Block (`<# ... #>`)** | • Compact • Modern aesthetic | • **Not supported in PowerShell v1.0** (causes parser error) • Harder to edit individual lines • Risk of malformed blocks |

> **⚠ PowerShell v1.0 Compatibility Warning:** Block comments (`<# ... #>`) were introduced in PowerShell v2.0. In PowerShell v1.0, attempting to use block comments results in a **parser error** that prevents the script from running. Scripts targeting v1.0 compatibility **MUST** use only single-line comments (`#`). This applies to both comment-based help and general-purpose comments.

**Finding**: Only **single-line comments** (`#`) are compatible with PowerShell v1.0. Block comments (`<# ... #>`) are valid in PowerShell v2.0+ and are discoverable by `Get-Help` in those versions, but they **MUST NOT** be used when v1.0 compatibility is required. The author’s choice of single-line format is **required** for the v1.0 compatibility goal.

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

### Summary: Documentation as Complete Specification

*This section intentionally left blank.*

## Functions and Parameter Blocks

### Overview of Function Architecture

*This section intentionally left blank.*

---

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

    return (Test-Path -Path $Path)
}
```

For `Test-*` functions that might encounter meaningful errors (e.g., access denied, network issues) that the caller **SHOULD** be able to detect, the standard integer status code pattern **SHOULD** still be used.

**Rationale for explicit `return`**:

1. **Determinism** — only the status code is returned
2. **No pipeline pollution** — prevents accidental object emission
3. **v1.0 compatibility** — `return` works identically in all versions
4. **Caller control** — status code can be stored, tested, or ignored

```powershell
$status = Process-String ([ref]$result) ([ref]$extras) $input
if ($status -eq 0) { ... }  # Full success
```

This pattern creates a **C-style error code contract** that is immediately familiar to systems programmers.

---

### Input/Output Contract: Reference Parameters

Functions **MUST** use **`[ref]` parameters** to return complex data only when write-back is required:

```powershell
[ref]$ReferenceToResultObject     → [object]
[ref]$ReferenceArrayOfExtraStrings → [string[]]
```

**Advantages**:

- **Multiple return values** without pipeline
- **Caller owns memory** — no temporary objects
- **State transparency** — caller can inspect exact contents
- **No serialization overhead** — direct reference passing

**Example post-call state**:

```powershell
$result = processed value
$extras = @('','', '', 'extra', '')
$status = 4
```

---

### Pipeline Behavior: Deliberately Disabled

In v1.0-targeted functions, pipeline input **MUST** be **explicitly rejected**:

- No `ValueFromPipeline` attributes
- `.INPUTS` section states "None"
- No `process` block

This is **not a limitation** but a **design requirement** for:

- **Deterministic ordering** — processes one input at a time
- **Stateful operations** — requires full control over input sequence
- **v1.0 compatibility** — pipeline binding attributes require v2.0+

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

---

### Advanced Feature Emulation (v1.0-Native)

*This section intentionally left blank.*

---

### Options for Return Mechanism: Comparison

*This section intentionally left blank.*

---

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
            $data = Get-Content -Path $InputPath -ErrorAction Stop
            foreach ($line in $data) {
                # This is streaming output.
                [pscustomobject]@{
                    Length = $line.Length
                    Line = $line
                }
            }
        } catch {
            Write-Error "Failed to process $InputPath: $($_.Exception.Message)"
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

### Summary: Function Design as Reliability Engineering

*This section intentionally left blank.*

## Error Handling

### Executive Summary: Error Handling Philosophy

*This section intentionally left blank.*

---

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

The author uses `Write-Warning` **sparingly and surgically** to flag **logically impossible states**:

```powershell
Write-Warning -Message 'Conversion failed even though individual parts succeeded. This should not be possible!'
```

**Purpose**:

- **Diagnostic beacon** for developers
- **Production-safe** — does not terminate execution
- **Actionable** — includes exact context (variable values, expected vs. actual)

These warnings are **never suppressed** — they represent **contract violations** in the parsing logic.

---

### Error Context Preservation

Despite suppression, **full error context is preserved** in the global `$Error` array:

- Original `ErrorRecord` objects remain intact
- Stack trace, exception details, and target object are available
- Can be inspected after execution for detailed analysis

```powershell
if ($errorOccurred) {
    # Full error details available in $Error[0]
    $lastError = $Error[0]
}
```

---

### Comparison with Modern Alternatives

*This section intentionally left blank.*

---

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
    Get-Item -Path $strPath -ErrorAction Stop
} catch {
    throw "Failed to get item: $($_.Exception.Message)"
}

# WRONG — same problem with -f operator:
try {
    Get-Item -Path $strPath -ErrorAction Stop
} catch {
    throw ("Failed to get item: {0}" -f $_.Exception.Message)
}
```

#### Adding Context Before Rethrowing

If contextual information is needed before rethrowing, it **SHOULD** be logged via `Write-Debug` before the bare `throw`. This preserves the original exception while still providing diagnostic context on the Debug stream, reinforcing the [Default Pattern](#default-pattern-write-debug--throw).

```powershell
# Correct — context logged, original exception preserved:
try {
    Get-Item -Path $strPath -ErrorAction Stop
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
        Get-Item -Path $Path -ErrorAction Stop
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

### Summary: Error Handling as Diagnostic Instrumentation

*This section intentionally left blank.*

## File Writeability Testing

### Why Test File Writeability

When a PowerShell script is designed to write output to a file (e.g., export to CSV), it **MUST** verify that the destination path is writable **before performing any significant processing**. This is a **preflight check** to catch issues such as:

- Invalid paths
- Missing directories
- Insufficient permissions
- Read-only locations
- Files locked by another application

Failing to verify writeability upfront can result in wasted processing time, user frustration, or data loss when the script fails at the final write step.

---

### Recommended Approaches

There are two approaches to testing file writeability:

1. **`.NET` approach**: Using a function like `Test-FileWriteability` that uses .NET methods such as `[System.IO.File]::Create()`, `[System.IO.File]::WriteAllText()`, or related .NET file operations with explicit file handle control and resource cleanup. This approach is comprehensive but results in a lengthy function (~1000+ lines when including helper functions and documentation).

2. **`try/catch` approach**: Using `New-Item` to create a test file and `Remove-Item` to delete it, wrapped in a `try/catch` block. This approach is much shorter (~10 lines) but requires PowerShell v2.0+ since `try/catch` was introduced in v2.0.

Both approaches use a **create-then-delete pattern**. The delete step is critical because `Remove-Item` will reliably fail if the file is locked by another process, even in cases where `New-Item -Force` might succeed in creating/overwriting the file.

---

### Scripts Requiring PowerShell v1.0 Support

Scripts that **MUST** maintain backward compatibility with PowerShell v1.0 **MUST** use the **`.NET` approach**. The `try/catch` construct is not available in PowerShell v1.0 and causes a **parser error** if present in the script.

**Rationale**: Since `try/catch` was introduced in PowerShell v2.0, any script containing this syntax will fail to parse on v1.0, even if the code path is never executed.

Use the `Test-FileWriteability` function bundled from the reference implementation (see [Reference Implementation](#reference-implementation)).

---

### Scripts Requiring PowerShell v2.0+ Support

For scripts targeting PowerShell v2.0 or later, **either approach is acceptable**. Choose based on the following criteria:

#### Prefer the `.NET` Approach (`Test-FileWriteability`) When

- Script performs **mission-critical operations** or where strict error control/avoidance (i.e., avoiding users seeing an error) is paramount
- Script runs **unattended** (scheduled tasks, automation pipelines)
- Script is part of a **larger module or library** where consistency matters, or where the script/library has to be runnable on PowerShell v1.0 without throwing a parser error (for example, the script may have a module dependency that makes it require Windows PowerShell v5.1 or newer, and you've built-in proactive, graceful PowerShell version detection with a helpful warning when the version of PowerShell is not supported, and you need this version detection/warning workflow to function if the script is run on PowerShell v1.0—in other words, the script may only support newer versions of PowerShell but it needs to be runnable on PowerShell v1.0 without crashing due to `try/catch` introducing a parser error)
- **Detailed error capture** is needed (e.g., populating a reference to an ErrorRecord for logging)
- Script size is **not a concern**

#### Prefer the `try/catch` Approach When

- Script is a **simple, single-purpose utility**
- Script runs **interactively** where users can see and respond to errors
- The typical user is **PowerShell-savvy** and would be expected to interpret any issues without trouble
- Script is **distributed to others** who may need to read/modify it (simpler code is easier to understand)
- **Minimizing script size** is important

---

### Code Examples

#### .NET Approach

To follow the `.NET` approach, the script **SHOULD** bundle `Test-FileWriteability` from the [reference implementation](#reference-implementation) and then call it following the guidance in the function header. For example:

```powershell
$errRecord = $null
$boolIsWritable = Test-FileWriteability -Path 'Z:\InvalidPath\file.log' -ReferenceToErrorRecord ([ref]$errRecord)
if (-not $boolIsWritable) {
    Write-Warning ('Failed to write to path. Error: ' + $errRecord.Exception.Message)
    return # replace with an appropriate exiting action
}
```

#### try/catch Approach

Use the following `try/catch` pattern for PowerShell v2.0+, where `$OutputPath` represents the target file path:

```powershell
try {
    [void](New-Item -Path $OutputPath -ItemType File -Force -ErrorAction Stop)
    Remove-Item -LiteralPath $OutputPath -Force -ErrorAction Stop
} catch {
    throw "Cannot write to '$OutputPath': $($_.Exception.Message)"
}
```

**Note**: Using `-LiteralPath` with `Remove-Item` is important to avoid wildcard interpretation issues.

#### try/catch Alternative (.NET Methods)

The following alternative provides `.NET` reliability without the bulk of a full function, for scripts targeting PowerShell v2.0+:

```powershell
try {
    [System.IO.File]::WriteAllText($OutputPath, '')
    [System.IO.File]::Delete($OutputPath)
} catch {
    throw "Cannot write to '$OutputPath': $($_.Exception.Message)"
}
```

This approach:

- Uses `.NET` methods directly (reliable, explicit)
- Is much shorter than a full `Test-FileWriteability` function
- Works on PowerShell v2.0+ (.NET Framework 2.0 includes these static methods)
- Still requires `try/catch`, so does not work on PowerShell v1.0
- Is less idiomatic than using `New-Item`/`Remove-Item`

---

### Reference Implementation

For scripts requiring the comprehensive `.NET` approach, a full implementation of the `Test-FileWriteability` function is available at:

<https://github.com/franklesniak/PowerShell_Resources/blob/main/Test-FileWriteability.ps1>

This implementation includes:

- Explicit file handle control and resource cleanup
- Detailed error capture via reference parameters
- Full documentation and examples
- Support for PowerShell v1.0+

## Operating System Compatibility Checks

### Overview: Ensuring Cross-Platform Compatibility

When a PowerShell script or function is designed to run only on specific operating systems (Windows, Linux, and/or macOS), it **MUST** include appropriate checks to verify that the correct operating system is running before proceeding with its core operations. This prevents runtime failures, unexpected behavior, and provides clear error messages to users running the script on unsupported platforms.

The method used to detect the operating system depends on the minimum PowerShell version the script or function targets. PowerShell Core 6.0 introduced automatic variables for OS detection (`$IsWindows`, `$IsMacOS`, `$IsLinux`), but these are not available in Windows PowerShell 1.0 through 5.1. Scripts that **MUST** support older versions **REQUIRE** a "safe" approach using dedicated detection functions.

---

### When OS Checks Are Required

If a script or function supports only specific operating systems (Windows, Linux, and/or macOS), it **MUST** include a check to verify that the appropriate operating system type(s) are running before proceeding with platform-specific operations.

**Examples of when OS checks are required:**

- Scripts that use Windows-only APIs or cmdlets (e.g., `Get-WmiObject`, `Get-CimInstance` for certain classes)
- Scripts that interact with Linux-specific paths or commands (e.g., `/etc/`, `apt-get`)
- Scripts that use macOS-specific frameworks or file locations
- Any script that cannot function correctly on all platforms

**Examples of when OS checks **MAY** not be required:**

- Scripts that use only cross-platform PowerShell features
- Scripts that gracefully degrade functionality based on available cmdlets/modules
- Scripts explicitly documented as single-platform with clear naming (though checks are still **RECOMMENDED**)

---

### PowerShell Core 6.0+ OS Detection

If the script or function **only** needs to support PowerShell Core 6.0 or newer (and does not need to run on Windows PowerShell 1.0-5.1), the built-in automatic variables can be used for OS detection:

- **`$IsWindows`** — `$true` on Windows, `$false` on other platforms
- **`$IsMacOS`** — `$true` on macOS, `$false` on other platforms
- **`$IsLinux`** — `$true` on Linux, `$false` on other platforms

**Example: Windows-only script for PowerShell Core 6.0+:**

```powershell
function Get-WindowsSystemInfo {
    # .SYNOPSIS
    # Retrieves Windows-specific system information.
    # .DESCRIPTION
    # This function only runs on Windows and uses Windows-specific cmdlets.
    # .NOTES
    # Requires PowerShell Core 6.0+
    # Version: 1.0.20260109.0

    param()

    # Check if running on Windows
    if (-not $IsWindows) {
        Write-Error "This function only runs on Windows."
        return -1
    }

    # Proceed with Windows-specific operations
    $objSystemInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    return 0
}
```

**Example: Linux or macOS script:**

```powershell
function Get-UnixSystemInfo {
    # .SYNOPSIS
    # Retrieves Unix-based system information.
    # .DESCRIPTION
    # This function runs on Linux or macOS only.
    # .NOTES
    # Requires PowerShell Core 6.0+
    # Version: 1.0.20260109.0

    param()

    # Check if running on a Unix-based system
    if (-not ($IsLinux -or $IsMacOS)) {
        Write-Error "This function only runs on Linux or macOS."
        return -1
    }

    # Proceed with Unix-specific operations
    $strOutput = uname -a
    return 0
}
```

---

### Cross-Version OS Detection

If the script or function needs to support **any version of PowerShell older than PowerShell Core 6.0** (including Windows PowerShell 1.0 through 5.1), a "safe" check **MUST** be used because the `$IsWindows`, `$IsMacOS`, and `$IsLinux` variables do not exist in those versions.

In this case, use the following dedicated functions from the [`PowerShell_Resources`](https://github.com/franklesniak/PowerShell_Resources) repository:

| Operating System | Function | Repository Link |
| --- | --- | --- |
| **Windows** | `Test-Windows` | [`Test-Windows.ps1`](https://github.com/franklesniak/PowerShell_Resources/blob/master/Test-Windows.ps1) |
| **macOS** | `Test-macOS` | [`Test-macOS.ps1`](https://github.com/franklesniak/PowerShell_Resources/blob/master/Test-macOS.ps1) |
| **Linux** | `Test-Linux` | [`Test-Linux.ps1`](https://github.com/franklesniak/PowerShell_Resources/blob/master/Test-Linux.ps1) |

These functions safely detect the operating system across all PowerShell versions and return a boolean value (`$true` if running on the specified OS, `$false` otherwise).

**Example: Windows-only script for PowerShell 1.0+:**

```powershell
# Bundle the Test-Windows function from PowerShell_Resources repository
# (Include full function definition here or dot-source it)

function Get-WindowsSystemInfo {
    # .SYNOPSIS
    # Retrieves Windows-specific system information.
    # .DESCRIPTION
    # This function only runs on Windows and uses Windows-specific cmdlets.
    # Compatible with PowerShell 1.0+.
    # .NOTES
    # Version: 1.0.20260109.0

    param()

    # Check if running on Windows using safe cross-version detection
    $boolIsWindows = Test-Windows
    if (-not $boolIsWindows) {
        Write-Warning "This function only runs on Windows."
        return -1
    }

    # Proceed with Windows-specific operations
    # Use appropriate cmdlets based on PowerShell version
    return 0
}
```

**Example: Linux or macOS script for PowerShell 1.0+:**

```powershell
# Bundle Test-Linux and Test-macOS functions from PowerShell_Resources
# (Include full function definitions here or dot-source them)

function Get-UnixSystemInfo {
    # .SYNOPSIS
    # Retrieves Unix-based system information.
    # .DESCRIPTION
    # This function runs on Linux or macOS only.
    # Compatible with PowerShell 1.0+.
    # .NOTES
    # Version: 1.0.20260109.0

    param()

    # Check if running on a Unix-based system
    $boolIsLinux = Test-Linux
    $boolIsMacOS = Test-macOS

    if (-not ($boolIsLinux -or $boolIsMacOS)) {
        Write-Warning "This function only runs on Linux or macOS."
        return -1
    }

    # Proceed with Unix-specific operations
    return 0
}
```

**Rationale for using dedicated functions:**

The `$IsWindows`, `$IsMacOS`, and `$IsLinux` variables were introduced in PowerShell Core 6.0. Attempting to reference these variables in PowerShell 1.0-5.1 results in a `$null` value, which can lead to incorrect behavior (e.g., `-not $IsWindows` evaluates to `$true` on Windows PowerShell 5.1, incorrectly suggesting the script is not on Windows).

The `Test-Windows`, `Test-macOS`, and `Test-Linux` functions from the PowerShell_Resources repository provide safe, reliable OS detection that works identically across all PowerShell versions from 1.0 onward.

---

### Error Handling for Wrong OS

If the script or function detects that it is running on an unsupported operating system, it **SHOULD** report the error in a way that is **consistent with the script's or function's existing error handling patterns**.

**Guidelines:**

1. **Match the error reporting style:** If the function returns integer status codes (e.g., `0` for success, `-1` for failure), return the appropriate error code. If it uses exceptions, throw an exception. If it uses `Write-Error`, use that.

2. **Provide clear error messages:** The error message **SHOULD** clearly state which operating system(s) are required and which OS was detected.

3. **Fail early:** Perform the OS check at the beginning of the function or script, before any significant processing occurs.

**Example: Function returning status code:**

```powershell
function Get-WindowsRegistryValue {
    # .SYNOPSIS
    # Retrieves a value from the Windows Registry.
    # .OUTPUTS
    # [int] Status code: 0=success, -1=failure (including wrong OS)

    param(
        [string]$Path
    )

    # OS check at the beginning
    if (-not $IsWindows) {
        Write-Error "This function requires Windows. Current OS is not supported."
        return -1
    }

    # Proceed with Windows-specific operations
    return 0
}
```

**Example: Function using Write-Warning for non-critical failure:**

```powershell
function Get-OptionalWindowsInfo {
    # .SYNOPSIS
    # Retrieves optional Windows information.

    param()

    # Check OS and warn if not Windows
    if (-not $IsWindows) {
        Write-Warning "This function is optimized for Windows. Some features may not be available on other platforms."
        return $null
    }

    # Proceed with Windows-specific operations
    return $objInfo
}
```

**Example: Script exiting with clear error:**

```powershell
# At the top of a Windows-only script
if (-not $IsWindows) {
    Write-Error "This script requires Windows. Current OS: $(if ($IsLinux) { 'Linux' } elseif ($IsMacOS) { 'macOS' } else { 'Unknown' })"
    exit 1
}

# Continue with Windows-specific script logic
```

---

### Summary: OS Compatibility Checks as Cross-Platform Reliability

Operating system compatibility checks are a **critical reliability requirement** for platform-specific scripts and functions:

- **Required** when scripts/functions support only specific operating systems
- **Use built-in variables** (`$IsWindows`, `$IsMacOS`, `$IsLinux`) for PowerShell Core 6.0+ only scripts
- **Use safe functions** (`Test-Windows`, `Test-macOS`, `Test-Linux`) for scripts supporting older PowerShell versions
- **Report errors consistently** with the script's existing error handling patterns
- **Fail early** to prevent unexpected behavior on unsupported platforms

This approach ensures that users receive clear, actionable error messages when attempting to run platform-specific scripts on unsupported operating systems, preventing confusion and runtime failures.

## Language Interop, Versioning, and .NET

### Executive Summary: Interop and Versioning Strategy

*This section intentionally left blank.*

---

### Runtime Version Detection: `Get-PSVersion`

The author implements a **dedicated version probe** that returns a `[System.Version]` object representing the executing PowerShell runtime:

```powershell
function Get-PSVersion {
    if (Test-Path variable:\PSVersionTable) {
        return $PSVersionTable.PSVersion
    } else {
        return [version]'1.0'
    }
}
```

**Analysis of detection logic**:

| Condition | PowerShell Version | Result |
| --- | --- | --- |
| `$PSVersionTable` exists | v2.0+ | Actual version (e.g., 5.1.22621.2506) |
| `$PSVersionTable` missing | v1.0 | Hard-coded `[version]'1.0'` |

**Critical findings**:

- **No reliance** on `$PSVersionTable.PSVersion.Major` ≥ 2 → avoids false positives
- **Explicit fallback** to `'1.0'` → prevents `$null` or exceptions
- **Returns `[version]` type** → enables direct comparison (`$version.Major -ge 3`)
- **v1.0 compatible** → uses only v1.0 features (`Test-Path`, variable access)

This function serves as the **central version oracle** for all conditional logic.

---

### Conditional .NET Feature Usage: Progressive Enhancement

The author uses **PowerShell version as a feature flag** to enable increasingly capable .NET types for handling edge cases like numeric overflow:

```powershell
if ($versionPowerShell.Major -ge 3) {
    # Use BigInteger (available in .NET 4.0+, loaded in PS v3+)
    $boolResult = Convert-StringToBigIntegerSafely ...
} else {
    # Fall back to double
    $boolResult = Convert-StringToDoubleSafely ...
}
```

**Progressive enhancement stack**:

| PowerShell Version | .NET Type Used | Numeric Range |
| --- | --- | --- |
| v3.0+ | `[System.Numerics.BigInteger]` | Unlimited (subject to memory) |
| v1.0–v2.0 | `[double]` | ±1.7 × 10³⁰⁸ (IEEE 754) |
| All versions | `[int]`, `[int64]` | Built-in safe conversions |

**Rationale**:

- **BigInteger** → handles numbers larger than `[int32]::MaxValue` (2,147,483,647)
- **Double** → v1.0-compatible approximation for large numbers
- **No runtime exceptions** → conversion functions return `$false` on failure

---

### .NET Interop Patterns: Safe and Documented

The author uses **direct .NET interop** in controlled scenarios:

| .NET Usage | Implementation | Technical Justification |
| --- | --- | --- |
| **`[regex]::Escape()`** | `Split-StringOnLiteralString` | Ensures literal string splitting (not regex) in v1.0 |
| **`[regex]::Split()`** | Same function | v1.0-compatible alternative to `-split` operator (v2.0+) |
| **`[System.Numerics.BigInteger]`** | Overflow handling | Only when PS v3+ detected |

**Example: Literal string splitting**:

```powershell
$strSplitterInRegEx = [regex]::Escape($Splitter)
$result = [regex]::Split($StringToSplit, $strSplitterInRegEx)
```

**Deprecation of `System.Collections.ArrayList`:** `System.Collections.ArrayList` is **deprecated** (consistent with [Microsoft's .NET guidance](https://learn.microsoft.com/en-us/dotnet/api/system.collections.arraylist)) and **MUST NOT** be used in new code. All new and newly-modified code **MUST** use `System.Collections.Generic.List[T]` instead. `System.Collections.Generic.List[T]` has been available since .NET Framework 2.0 (PowerShell v1.0).

`ArrayList` is only permitted as a fallback in rare, well-justified cases where an attempt to instantiate `System.Collections.Generic.List[T]` throws an exception that is caught and handled. Such fallback **MUST** be reported via the debug stream, and the debug message **MUST** include the caught exception type and message (for example: `Write-Debug "Failed to create generic list; falling back to ArrayList. Exception: $($_.Exception.GetType().FullName): $($_.Exception.Message)"`).

```powershell
# Compliant (Required for all new code)
$list = New-Object System.Collections.Generic.List[PSCustomObject]

# Non-Compliant (Deprecated — do not use in new code)
$list = New-Object System.Collections.ArrayList
```

> **Migration Note:** Legacy code that uses `System.Collections.ArrayList` **SHOULD** be refactored to use `System.Collections.Generic.List[T]` with the appropriate type parameter when the code is next modified. Replace `New-Object System.Collections.ArrayList` with `New-Object System.Collections.Generic.List[PSCustomObject]` (or the appropriate type), and verify that all `.Add()` calls and downstream consumers are compatible with the typed list.

**Typed Generic Collections:** When instantiating generic .NET collections, such as `System.Collections.Generic.List[T]`, the specific type `T` **MUST** be provided if known (e.g., `[PSCustomObject]`, `[string]`). This is more precise, safer, and more descriptive than using the generic `[object]`.

```powershell
# Compliant (Preferred)
$listAttached = New-Object System.Collections.Generic.List[PSCustomObject]

# Non-Compliant (Vague)
$listAttached = New-Object System.Collections.Generic.List[object]
```

**Advantages**:

- **v1.0 compatible** → `[regex]` class exists in .NET 2.0
- **Deterministic behavior** → no regex metacharacter interpretation
- **No external dependencies** → pure .NET Framework

---

### Type Conversion Safety Chain

The author implements a **defense-in-depth conversion chain** for numeric strings:

```powershell
# 1. Try int32 (safe, fast)
# 2. If overflow → try int64
# 3. If still overflow and PS v3+ → try BigInteger
# 4. If still overflow or PS v1.0 → try double
# 5. If all fail → treat as non-numeric
```

Each step uses the **atomic error handling pattern** (trap + preference toggle + reference comparison) to:

- Attempt conversion
- Detect failure
- Preserve original error
- Return `$false` without throwing

---

### Version-Aware Fallback Logic

Functions use version detection to **bypass expensive checks** when possible:

```powershell
if ($PSVersion -eq ([version]'0.0')) {
    $versionPowerShell = Get-PSVersion  # Detect if not provided
} else {
    $versionPowerShell = $PSVersion     # Use caller-provided value
}
```

**Benefits**:

- **Performance optimization** → skip version detection if caller knows runtime
- **Flexibility** → supports both interactive and scripted use
- **Defensive programming** → default case handles unexpected input

---

### Path and Scope Handling: Explicit and Provider-Agnostic

The author **avoids all relative path notation** and the `~` shortcut:

| Avoided | Reason |
| --- | --- |
| `.\file.txt` | Depends on `[Environment]::CurrentDirectory` |
| `..\parent` | Same issue |
| `~` | Behavior varies by provider (FileSystem vs. Registry) |

**Preferred pattern**:

```powershell
$global:ErrorActionPreference = 'SilentlyContinue'
```

For file paths, the author would use:

- **Absolute paths** via `$PSScriptRoot` (in modules)
- **Explicit provider qualifiers** (e.g., `FileSystem::C:\path`)
- **Join-Path** with validated roots

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
Get-Content -Path (Join-Path -Path $PSScriptRoot -ChildPath '../config.json')
```

---

### .NET Type Usage Summary

| .NET Type | First Available | Used In | Technical Purpose |
| --- | --- | --- | --- |
| `[regex]` | .NET 2.0 (PS v1.0) | String operations | Literal string parsing |
| `[System.Numerics.BigInteger]` | .NET 4.0 (PS v3.0+) | Overflow handling | Unlimited integer precision |
| `[version]` | .NET 2.0 | Version handling | Standard version semantics |
| `[ref]` | .NET 2.0 | Output parameters | Multiple return values (only for write-back) |

All types are **v1.0-safe** except `BigInteger`, which is **guarded by version check**.

---

### Modernization Path (v2.0+)

*This section intentionally left blank.*

---

### Summary: Interop as Adaptive Resilience

*This section intentionally left blank.*

## Output Formatting and Streams

### Executive Summary: Output Discipline

*This section intentionally left blank.*

---

### Primary Output: Integer Status Code via `return`

The **only value returned from the function** is a **single `[int]` status code**:

```powershell
return 0    # Full success
return 4    # Partial success
return -1   # Complete failure
```

**Key characteristics**:

| Property | Implementation |
| --- | --- |
| **Type** | `[int]` (32-bit signed integer) |
| **Source** | Explicit `return` statement |
| **Stream** | Success (pipeline) |
| **Cardinality** | Exactly one value |

**Documented in `.OUTPUTS`**:

```powershell
# .OUTPUTS
# [int] Status code: 0=success, 1-5=partial with additional data, -1=failure
```

This status code serves as the **function’s contract** — a machine-readable indicator of outcome.

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

All **structured data** is returned via **`[ref]` parameters** only when write-back to the caller is required:

```powershell
[ref]$ReferenceToResultObject        → [object]
[ref]$ReferenceArrayOfExtraStrings → [string[]]
```

**Advantages**:

- **No pipeline interference** — data never accidentally flows downstream
- **Caller-controlled lifetime** — variables persist after function exit
- **Multiple return values** — result + additional data in one call
- **v1.0 compatible** — `[ref]` works in all versions

**Post-call state example**:

```powershell
$result = processed value
$extras = @('','', '', 'extra', '')
$status   = 4
```

---

### Stream Usage: Clear Mapping

Code **MUST** use **exactly three output Streams**, each with a **single, immutable purpose**:

| Stream | Command | Purpose | Example |
| --- | --- | --- | --- |
| **Success** | `return` | Primary result (status code) | `return 0` |
| **Warning** | `Write-Warning` | Logical anomalies ("should not happen") | `"Operation failed despite valid inputs"` |
| **Host** | *Never used* | Interactive feedback | **Prohibited** |

**`Write-Host` **MUST NOT** be used** — its absence is a deliberate indicator of **production-grade tooling**.

---

### Warning Stream: Diagnostic Beacon

`Write-Warning` **MUST** be used **sparingly and surgically** for **logically impossible states**:

```powershell
Write-Warning -Message 'Conversion of string failed even though valid. This should not be possible!'
```

**Purpose**:

- **Developer alert** — indicates internal contract violation
- **Non-terminating** — does not halt execution
- **Actionable** — includes exact values and context
- **Production-safe** — visible only with `-WarningAction` or `$WarningPreference`

These warnings are **never suppressed** and serve as **diagnostic information** for root cause analysis.

---

### Host Stream: Deliberately Disabled

**No output ever goes to the host console** via:

- `Write-Host`
- `Write-Output` (except via `return`)
- Echo/print statements

**Rationale**:

- **Pipeline safety** — prevents data leakage
- **Script compatibility** — silent operation in automation
- **v1.0 compliance** — avoids v2.0+ stream features

---

### Output Type Consistency: Single-Type Guarantee

The function **never emits mixed object types**. The only object that can leave via the success stream is the **integer status code**.

**Guarantee**:

```powershell
$result = Process-String ...
$result.GetType().FullName  # Always "System.Int32"
```

This enables:

- **Pipeline chaining** with confidence
- **Type-based filtering** in larger scripts
- **Static analysis** of data flow

---

### Format Files: Future-Proof Design Pattern

*This section intentionally left blank.*

---

### Stream Interaction Matrix

| Caller Context | Success Stream | Warning Stream | Host Stream |
| --- | --- | --- | --- |
| Interactive | Status code visible | Warnings shown | **Never** |
| Script | `$status` captured | Warnings logged | **Never** |
| Pipeline | Status flows downstream | Warnings preserved | **Never** |

---

### Modern Stream Capabilities (v2.0+ Context)

*This section intentionally left blank.*

---

### Summary: Output as Controlled Interface

*This section intentionally left blank.*

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

When logging parameter values or internal state via `Write-Verbose` or `Write-Debug`, functions **MUST NOT** emit raw personally identifiable information (PII), credentials, secrets, tokens, or other sensitive identifiers that could be exposed in console output, transcript files, automation logs, or CI logs.

Instead, code **SHOULD** use safe alternatives such as:

- Boolean presence flags (for example, `ObjectIdPresent = $true`)
- Non-sensitive metadata (for example, string length, item count, or type name)
- Redacted or intentionally truncated values, but only when doing so does not expose sensitive information

This applies especially to values such as user principal names (UPNs), email addresses, Azure AD object IDs, application IDs, tenant IDs, access tokens, client secrets, and similar identifiers.

If diagnostic traceability is required, prefer logging whether a value was supplied, its general type, or other non-sensitive characteristics rather than the original value itself.

**Non-Compliant** — logs a raw sensitive identifier:

```powershell
# Non-Compliant
Write-Verbose -Message ('PrincipalKey: ' + $PrincipalKey)
```

**Compliant** — logs safe, non-sensitive metadata:

```powershell
# Compliant - logs whether the value is present (boolean)
Write-Verbose -Message ('PrincipalKey present: {0}' -f ($null -ne $PrincipalKey))

# Compliant - logs the value's type name with a null-safe fallback
$strPrincipalKeyTypeName = if ($null -ne $PrincipalKey) { $PrincipalKey.GetType().Name } else { '<null>' }
Write-Debug -Message ('PrincipalKey type: {0}' -f $strPrincipalKeyTypeName)

# Compliant - logs non-sensitive metadata (string length) with a type-safe fallback
$strPrincipalKeyLength = if ($PrincipalKey -is [string]) { [string]$PrincipalKey.Length } else { '<n/a>' }
Write-Verbose -Message ('PrincipalKey length: {0}' -f $strPrincipalKeyLength)
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

**Pester** is the standard testing framework for PowerShell, providing a domain-specific language for writing and executing tests. This section documents testing conventions that integrate with the coding standards in this guide. For comprehensive Pester documentation, see [pester.dev](https://pester.dev/).

> **Note:** Pester 5.x requires PowerShell 3.0+ to execute tests. However, v1.0-compatible scripts can still be tested with Pester—simply run the tests on a modern PowerShell version (e.g., pwsh 7.x on a CI platform like `ubuntu-latest`). The test files themselves will use modern Pester syntax, but the scripts under test can target any PowerShell version.

---

### Test File Naming and Location

Test files **MUST** follow consistent naming conventions to ensure discoverability:

- **Naming Convention:** Test files **MUST** use the `*.Tests.ps1` suffix (e.g., `Get-UserInfo.Tests.ps1`)
- **Preferred Location:** Test files **SHOULD** be stored in a `tests/` directory at the repository root
- **Alternative:** Test files **MAY** be placed alongside source files (e.g., `Get-UserInfo.ps1` and `Get-UserInfo.Tests.ps1` in the same directory)
- **One-to-One Mapping:** Generally, one test file **SHOULD** be created per function or script being tested

**Example directory structure:**

```text
repository/
├── src/
│   └── Get-UserInfo.ps1
└── tests/
    └── Get-UserInfo.Tests.ps1
```

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

**Basic invocation:**

```powershell
Invoke-Pester -Path tests/
```

**Detailed output:**

```powershell
Invoke-Pester -Path tests/ -Output Detailed
```

**Single test file:**

```powershell
Invoke-Pester -Path tests/Get-UserInfo.Tests.ps1
```

**With configuration object (for CI/CD scenarios):**

```powershell
$objPesterConfig = New-PesterConfiguration
$objPesterConfig.Run.Path = 'tests/'
$objPesterConfig.Output.Verbosity = 'Detailed'
$objPesterConfig.TestResult.Enabled = $true
$objPesterConfig.TestResult.OutputPath = 'test-results.xml'
Invoke-Pester -Configuration $objPesterConfig
```

## Performance, Security, and Other

### Executive Summary: Holistic Design Constraints

*This section intentionally left blank.*

---

### Performance: Measured Pragmatism

*This section intentionally left blank.*

---

### Security: Defense-in-Depth by Design

*This section intentionally left blank.*

---

### Other: Maintainability, Extensibility, and Modernization

*This section intentionally left blank.*

---

### Summary: Performance, Security, and Holistic Design

*This section intentionally left blank.*
