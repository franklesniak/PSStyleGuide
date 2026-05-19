# PowerShell Writing Style — Rationale and Design Philosophy

This companion document preserves the extended rationale, design philosophy, and historical context behind the rules in [STYLE_GUIDE.md](STYLE_GUIDE.md). The main guide contains all actionable rules, normative guidance, examples, and reference material. This document explains *why* those rules exist.

## Table of Contents

- [Executive Summary: Author Profile](#executive-summary-author-profile)
- [Code Layout and Formatting Rationale](#code-layout-and-formatting-rationale)
  - [File Encoding](#file-encoding)
  - [Programmatic File Writing Encoding](#programmatic-file-writing-encoding)
  - [Line Endings for Byte-Exact Text Artifacts](#line-endings-for-byte-exact-text-artifacts)
  - [String Formatting in Cmdlet Arguments (`-f` Scoping)](#string-formatting-in-cmdlet-arguments--f-scoping)
- [Naming Rationale](#naming-rationale)
  - [Overview of Observed Naming Discipline](#overview-of-observed-naming-discipline)
  - [Module Naming: Noun-Based Containers](#module-naming-noun-based-containers)
  - [Local Variable Naming: Defensive Design Philosophy](#local-variable-naming-defensive-design-philosophy)
  - [Options for Local Variable Prefixes: Analysis](#options-for-local-variable-prefixes-analysis)
  - [Summary: Naming as Defensive Architecture](#summary-naming-as-defensive-architecture)
- [Documentation Rationale](#documentation-rationale)
  - [Overview of Documentation Philosophy](#overview-of-documentation-philosophy)
  - [Comment-Based Help Spacing](#comment-based-help-spacing)
  - [Parameter Documentation Placement: Strategic Choice](#parameter-documentation-placement-strategic-choice)
  - [Help Format Options: Comparison](#help-format-options-comparison)
  - [Private/Internal Helper Function Documentation](#privateinternal-helper-function-documentation)
  - [Summary: Documentation as Complete Specification](#summary-documentation-as-complete-specification)
- [Function Design Rationale](#function-design-rationale)
  - [Overview of Function Architecture](#overview-of-function-architecture)
  - [Advanced Feature Emulation (v1.0-Native)](#advanced-feature-emulation-v10-native)
  - [Options for Return Mechanism: Comparison](#options-for-return-mechanism-comparison)
  - [Enforcing Subset-Only Positional Contracts in Modern Functions](#enforcing-subset-only-positional-contracts-in-modern-functions)
  - [ValidateRange for Constrained Numeric Parameters](#validaterange-for-constrained-numeric-parameters)
  - [Summary: Function Design as Reliability Engineering](#summary-function-design-as-reliability-engineering)
- [Error Handling Rationale](#error-handling-rationale)
  - [Executive Summary: Error Handling Philosophy](#executive-summary-error-handling-philosophy)
  - [Comparison with Modern Alternatives](#comparison-with-modern-alternatives)
  - [Summary: Error Handling as Diagnostic Instrumentation](#summary-error-handling-as-diagnostic-instrumentation)
- [Language Interop Rationale](#language-interop-rationale)
  - [Executive Summary: Interop and Versioning Strategy](#executive-summary-interop-and-versioning-strategy)
  - [Type Conversion Safety Chain](#type-conversion-safety-chain)
  - [Version-Aware Fallback Logic](#version-aware-fallback-logic)
  - [Modernization Path (v2.0+)](#modernization-path-v20)
  - [Summary: Interop as Adaptive Resilience](#summary-interop-as-adaptive-resilience)
- [Output and Streams Rationale](#output-and-streams-rationale)
  - [Executive Summary: Output Discipline](#executive-summary-output-discipline)
  - [Format Files: Future-Proof Design Pattern](#format-files-future-proof-design-pattern)
  - [Modern Stream Capabilities (v2.0+ Context)](#modern-stream-capabilities-v20-context)
  - [Summary: Output as Controlled Interface](#summary-output-as-controlled-interface)
- [Performance, Security, and Holistic Design Rationale](#performance-security-and-holistic-design-rationale)
  - [Executive Summary: Holistic Design Constraints](#executive-summary-holistic-design-constraints)
  - [Performance: Measured Pragmatism](#performance-measured-pragmatism)
  - [Security: Defense-in-Depth by Design](#security-defense-in-depth-by-design)
  - [Other: Maintainability, Extensibility, and Modernization](#other-maintainability-extensibility-and-modernization)
  - [Summary: Performance, Security, and Holistic Design](#summary-performance-security-and-holistic-design)
  - [Prefer `-LiteralPath` Over `-Path` for Concrete Paths](#prefer--literalpath-over--path-for-concrete-paths)
  - [Resolving Paths for .NET Static Methods](#resolving-paths-for-net-static-methods)
- [Content Relocated from STYLE_GUIDE.md](#content-relocated-from-style_guidemd)

---

## Executive Summary: Author Profile

> For the actionable rules derived from this profile, see the [Quick Reference Checklist](STYLE_GUIDE.md#quick-reference-checklist) in the main guide.

The author's code writing style can be characterized as a highly disciplined "PowerShell v1.0 Classicist" approach when applicable. This is a deliberate engineering choice to ensure maximum backward compatibility with PowerShell version 1.0 in scenarios where the script could feasibly run on that platform, such as standalone string manipulation functions, data parsing utilities, or scripts that interact with basic Windows operating system information without external dependencies. It prioritizes portability, robustness, and deterministic behavior in legacy or mixed environments where newer PowerShell versions cannot be assumed. However, this v1.0 compatibility is not rigidly enforced; when external constraints require newer PowerShell versions (e.g., dependencies on modules like Az, which mandate Windows PowerShell 5.1 or PowerShell 7.x), the author readily adopts modern language constructs such as try/catch for error handling, advanced functions with [CmdletBinding()], and other features to align with the required runtime.

This explains the systematic avoidance of features introduced in v2.0 or later in v1.0-targeted scripts, such as advanced functions with the [CmdletBinding()] attribute, structured try/catch error handling, common parameters like -Verbose or -Debug, begin/process/end blocks, and modern output streams. Instead, the style relies on PowerShell's foundational mechanics, such as simple function declarations, strongly typed param blocks, explicit return statements for single values, and a custom error detection pattern using trap statements and global preference toggling.

Within these constraints, the author adheres closely to community best practices for readability, naming, documentation, and maintainability. Functions are designed as reusable tools with a single purpose—e.g., performing targeted data transformations or validations. Outputs are explicit and controlled: a status code (e.g., an integer indicating full success, partial success, or failure) is typically returned, while complex results are passed via reference parameters only when necessary to modify data in the caller's scope, avoiding unnecessary use of [ref] for read-only objects since it provides no performance benefits in PowerShell. Error handling is "fail-controlled," suppressing issues to allow graceful recovery without halting execution. The code is robust, thoroughly documented, and predictable across versions, making it ideal for tools in legacy or mixed environments. Performance is balanced with readability, favoring script constructs over pipelines. If the v1.0 constraint were lifted (e.g., due to modern dependencies), the style would evolve to incorporate features like pipeline-friendly objects and structured errors while retaining strong typing and documentation for clarity.

---

## Code Layout and Formatting Rationale

> For the formatting rules themselves, see [Code Layout and Formatting](STYLE_GUIDE.md#code-layout-and-formatting) in the main guide.

### File Encoding

> For the actionable rule, see [File Encoding](STYLE_GUIDE.md#file-encoding) in the main guide.

UTF-8 does not require a BOM. A leading BOM is an invisible character that can cause practical problems, including interfering with regex-based text processing, breaking shebang (`#!`) handling on Linux/macOS, and creating unnecessary cross-tool inconsistencies or diff noise. Saving `.ps1` files as BOM-less UTF-8 avoids these issues and aligns with modern editor and automation behavior.

However, there is an important compatibility caveat: Windows PowerShell (v5.1 and earlier) does not assume UTF-8 for BOM-less files. Instead, it falls back to the system's ANSI code page. This means non-ASCII characters in a BOM-less UTF-8 script can be silently misinterpreted on legacy hosts. The actionable rule in the main guide addresses this with an explicit exception: scripts that contain non-ASCII characters and must target Windows PowerShell either need a BOM or must stay ASCII-only. For the vast majority of scripts (which are ASCII-only), BOM-less UTF-8 is safe across all PowerShell versions.

#### VS Code Configuration Example

VS Code defaults to UTF-8 without BOM (`files.encoding: utf8`), so no change is typically needed. To verify, check the encoding shown in the status bar at the bottom-right of the window. To make the intent explicit in a workspace, add `"files.encoding": "utf8"` to `.vscode/settings.json`. The value `"utf8"` means no BOM; `"utf8bom"` would add one. For the rare case where a script must contain non-ASCII characters and target Windows PowerShell, use `"utf8bom"` instead, per the exception in the actionable rule. To scope the setting to PowerShell files only, use a `"[powershell]"` language-specific override:

```json
{
    "[powershell]": {
        "files.encoding": "utf8"
    }
}
```

### Programmatic File Writing Encoding

> For the actionable rule, see [Programmatic File Writing Encoding](STYLE_GUIDE.md#programmatic-file-writing-encoding) in the main guide.

The default encoding used by `Set-Content`, `Out-File`, and the `>` redirection operator varies significantly across PowerShell versions. In Windows PowerShell 5.1, `Set-Content` defaults to the system ANSI code page, while `Out-File` and `>` default to UTF-16 LE (with BOM). In PowerShell 7+, all three default to UTF-8 without BOM. This divergence means that a script relying on default encoding can produce different output depending on the host, making build artifacts non-deterministic.

The `.NET` `System.Text.UTF8Encoding` approach is preferred for cross-version determinism because it is available in every PowerShell version (including v1.0) and produces identical output regardless of host. The constructor argument `$false` suppresses the BOM, matching the project's source file encoding convention.

The `-Encoding utf8NoBOM` parameter value was introduced in PowerShell 6.0 (Core). It does not exist in Windows PowerShell 5.1, so requiring it as the standard pattern would break backward compatibility. For projects that explicitly target only PowerShell 7+, using `-Encoding utf8NoBOM` with cmdlets is an acceptable alternative.

### Line Endings for Byte-Exact Text Artifacts

> For the actionable rule, see [Line Endings for Byte-Exact Text Artifacts](STYLE_GUIDE.md#line-endings-for-byte-exact-text-artifacts) in the main guide.

Some PowerShell workloads produce text whose identity is its exact byte sequence: golden/snapshot test baselines, files fed into cryptographic hash functions, signed payloads, and other artifacts that are later compared byte-for-byte. For these artifacts, a single stray CRLF where an LF was expected — or vice versa — is enough to cause a hash mismatch, a signature verification failure, or a confusing snapshot diff.

The built-in serializers in PowerShell do not guarantee a stable line-ending convention across hosts. In particular, `ConvertTo-Json` has historically emitted different line endings across PowerShell versions and platforms: some versions produce CRLF inside the serialized output even on Linux and macOS, while others produce LF. Code that trusts the serializer to produce a canonical byte sequence will therefore pass on one host and fail on another. The only reliable remedy at the PowerShell layer is to normalize line endings in memory after serialization and before writing or comparing, for example by replacing `` `r`n `` with `` `n `` on the serialized string. This makes the output deterministic regardless of the serializer's per-host behavior.

On the read side, `Get-Content` without `-Raw` is also unsuitable for byte-exact comparison. It returns an array of lines rather than the original on-disk text, and the line terminators themselves are stripped during that split. The reconstructed string is therefore not guaranteed to equal the bytes that were written — it loses both the specific terminator used (CRLF vs LF) and any trailing newline. `Get-Content -Raw` reads the entire file into a single string and preserves the decoded text verbatim, including embedded and trailing newlines, which is what text-level identity comparison requires. It does still decode the file contents, however, so it is not a byte-for-byte read and can hide differences such as a UTF-8 BOM or other encoding-level distinctions. When true byte-exact comparison is required — most notably for cryptographic hash inputs and signed payloads — use `[System.IO.File]::ReadAllBytes()`, which returns the raw byte array with no decoding. `[System.IO.File]::ReadAllText()` is the corresponding .NET option for text-centric codepaths and shares the same decoding caveat as `Get-Content -Raw`. Both .NET APIs are subject to the path-resolution discipline described in [Resolving Paths for .NET Static Methods](STYLE_GUIDE.md#resolving-paths-for-net-static-methods).

Repository-level controls such as `.gitattributes` entries that pin committed text files to LF can also matter for artifacts stored in version control, because Git's own line-ending handling can otherwise rewrite bytes between commit and checkout. That concern sits above the PowerShell language layer and is intentionally out of scope for `STYLE_GUIDE.md`, which only covers how `.ps1` code serializes and reads byte-exact text.

### String Formatting in Cmdlet Arguments (`-f` Scoping)

> For the actionable rule, see [String Formatting in Cmdlet Arguments (`-f` Scoping)](STYLE_GUIDE.md#string-formatting-in-cmdlet-arguments--f-scoping) in the main guide.

When a string expression is composed inline and passed to a cmdlet using parentheses as the argument, a common mistake is to place the `-f` format operator *after* the closing parenthesis of the argument expression. For example:

```powershell
Write-Warning ("foo {0}" + "bar") -f $x
```

In this case, PowerShell's parser treats the parenthesized expression `("foo {0}" + "bar")` as the complete argument to `Write-Warning`. The `-f` that follows is then parsed as a *parameter token* on `Write-Warning`, not as the format operator. Depending on the cmdlet, this produces either a parameter-binding error (e.g., *"A parameter cannot be found that matches parameter name 'f'"*) or, on commands that happen to have a parameter starting with `f`, an unexpected and silent misbinding.

This mistake is easy to make when composing strings inline because the developer mentally groups the entire expression including `-f` as a single unit, but PowerShell's parser does not. The parentheses close the argument expression before `-f` is reached.

The preferred fix is to nest the entire format expression inside the argument-expression parentheses:

```powershell
Write-Warning (("foo {0}" + "bar") -f $x)
```

Here the outer parentheses define the argument expression, and within them the inner parentheses plus `-f` form a complete format operation. PowerShell evaluates the whole expression before passing the result to `Write-Warning`.

Alternatively, assigning the formatted string to a variable before the cmdlet call avoids the nesting entirely and may improve readability for complex expressions:

```powershell
$strMessage = ("foo {0}" + "bar") -f $x
Write-Warning $strMessage
```

In the variable-assignment case, there are no cmdlet-parameter semantics in play, so `-f` is unambiguously the format operator. This pattern is particularly useful when the format expression is long or involves multiple placeholders.

---

## Naming Rationale

> For the naming rules themselves, see [Capitalization and Naming Conventions](STYLE_GUIDE.md#capitalization-and-naming-conventions) in the main guide.

### Overview of Observed Naming Discipline

The author exhibits an uncompromising commitment to **explicit, self-documenting identifiers** across all code elements. This manifests as a complete rejection of aliases, abbreviations, or any form of shorthand in function names, parameter names, or command invocations. Every identifier is fully spelled out using clear, descriptive language that communicates intent without requiring external context or documentation lookup. This practice eliminates ambiguity and future-proofs the code against changes in command behavior or parameter sets—common sources of subtle bugs in PowerShell scripting.

The naming strategy is rooted in **.NET Framework capitalization conventions**, treating PowerShell as a .NET scripting language. This results in:

- **PascalCase** for all public-facing identifiers (function names, parameters, properties).
- **lowercase** for PowerShell language keywords (`function`, `param`, `if`, `else`, `return`, `trap`).
- **camelCase with type-hinting prefixes** for local variables. **These MUST be fully descriptive and non-abbreviated** (e.g., `$strMessage`, `$intReturnValue`, `$objMemoryStream`).
- **Noun-based naming for Modules**, treating them as containers/namespaces (e.g., `ObjectFlattener`) distinct from the executable actions they contain.

This consistent application creates a visual hierarchy that allows rapid comprehension of code structure and data flow, even in large or complex functions.

---

### Module Naming: Noun-Based Containers

> For the module naming rules, see [Module Naming: Noun-Based Containers](STYLE_GUIDE.md#module-naming-noun-based-containers) in the main guide.

In the .NET Framework design philosophy, a **Verb-Noun** phrase represents an executable *method* or *command* (an action). A **Noun** represents the *class*, *library*, or *tool* that contains those capabilities (the container). Naming a module using a Verb-Noun pattern (e.g., `FlattenObject`) blurs this distinction and creates cognitive dissonance, leading users to falsely expect a command named `Flatten-Object` to exist.

By naming the module `ObjectFlattener` (the tool) and the function `ConvertTo-FlatObject` (the action), the architecture remains semantically pure and aligned with Microsoft’s own structural standards (e.g., the module `Microsoft.Graph` contains the command `Get-MgUser`).

The discoverability strategy relies on the **Module Manifest (`.psd1`)** rather than compromising the architectural name. The `Tags` key in the manifest handles keyword searching, keeping the module name pure while ensuring findability during searches.

Module manifests (`.psd1`) are a PowerShell v2.0+ feature — they do not exist in PowerShell v1.0. Manifest-specific guidance therefore cannot carry the `[All]` scope tag, which by convention means "all PowerShell versions, including v1.0." The general module naming rule remains `[All]` because PascalCase noun naming is applicable regardless of PowerShell version, while the manifest-specific `Tags` discoverability guidance is explicitly `[Modern]`.

---

### Local Variable Naming: Defensive Design Philosophy

> For the local variable naming rules, see [Local Variable Naming: Type-Prefixed camelCase](STYLE_GUIDE.md#local-variable-naming-type-prefixed-camelcase) in the main guide.

While some modern styles discourage type prefixes on local variables, in this context they represent **defensive programming**—a hallmark of the robustness philosophy that applies to all scripts regardless of target PowerShell version.

---

### Options for Local Variable Prefixes: Analysis

> For the required prefix list, see [Local Variable Naming: Type-Prefixed camelCase](STYLE_GUIDE.md#local-variable-naming-type-prefixed-camelcase) in the main guide.

The broader PowerShell community considers the use of type prefixes on local variables a **"matter of taste"** for private variables. Some style guides recommend plain camelCase (e.g., `$message`, `$count`) as a cleaner, more modern approach that aligns with .NET naming conventions. Below is a comparison of the two approaches for context:

| Option | Description | Pros | Cons |
| --- | --- | --- | --- |
| **1. Type Prefixes** (e.g., `$strMessage`, `$intCount`) | Hungarian-style notation **(required by this style guide)** | • Immediate type visibility in plain text • Critical in v1.0 without IDE support • Reduces runtime type errors • Self-documenting in large functions | • Increases visual noise • Feels dated in modern editors • **Intentionally longer variable names** (as abbreviations are forbidden) |
| **2. Plain camelCase** (e.g., `$message`, `$count`) | Community alternative **(not permitted in this codebase)** | • Cleaner, more modern aesthetic • Aligns with .NET naming simplicity • Shorter, easier to type | • Requires IDE/IntelliSense for type clarity • Risk of confusion in complex logic • Less resilient in plain-text review |

**This style guide requires type prefixes (Option 1) in all code.** Plain camelCase is a valid community alternative, but it is **not permitted** in this codebase. The clarity benefit of type prefixes outweighs verbosity regardless of target PowerShell version, as IDE support cannot always be assumed and the prefixes provide immediate type context in any environment.

---

### Summary: Naming as Defensive Architecture

The author's naming conventions are not merely stylistic—they form a **defensive architecture** that:

1. **Eliminates ambiguity** through full explicit names.
2. **Future-proofs** against command evolution.
3. **Provides immediate type context** via type prefixes.
4. **Ensures deterministic behavior** through explicit scoping.

This results in code that is **self-documenting**, **resilient to change**, and **immediately comprehensible** to any PowerShell practitioner—regardless of their familiarity with the specific script.

---

## Documentation Rationale

> For documentation rules and examples, see [Documentation and Comments](STYLE_GUIDE.md#documentation-and-comments) in the main guide.

### Overview of Documentation Philosophy

The author treats **documentation as a first-class citizen** of the codebase, embedding comprehensive, structured, and immediately actionable information directly within every function—regardless of scope, complexity, or visibility. This is not an afterthought but a **core engineering principle**: code **MUST** be **self-explanatory** to any consumer, even in the absence of external manuals, IDE tooltips, or prior knowledge. The documentation strategy is **v1.0-native** in compatible scripts, relying exclusively on PowerShell's original comment-based help system (introduced in v1.0) without dependence on newer features like `[CmdletBinding()]`, `Get-Help` enhancements in v2.0+, or external XML help files. In scripts requiring modern PowerShell due to dependencies, the author incorporates these newer help features as appropriate.

Every function—**including nested private helpers**—receives **identical treatment** in documentation rigor. This creates a **uniform information density** across the entire script, enabling rapid onboarding, debugging, and maintenance. The documentation serves three distinct audiences:

1. **End users** (via `Get-Help`)
2. **Script maintainers** (via inline context)
3. **Code reviewers** (via complete behavioral contracts)

---

### Comment-Based Help Spacing

> For the spacing rule, see [Comment-Based Help Spacing](STYLE_GUIDE.md#comment-based-help-spacing) in the main guide.

Dense comment-based help blocks are technically valid, but they make section
boundaries harder to scan. A single comment blank line between top-level help
sections preserves the complete inline help contract while giving readers a
reliable visual rhythm for `.SYNOPSIS`, `.DESCRIPTION`, `.PARAMETER`,
`.EXAMPLE`, `.INPUTS`, `.OUTPUTS`, and `.NOTES`.

The rule uses a line containing only `#` instead of a true empty physical line
because the separator remains part of the comment-based help block. This keeps
the source visually separated without implying a break in the help content, and
it preserves predictable `Get-Help` rendering across Windows PowerShell and
PowerShell 7+.

---

### Parameter Documentation Placement: Strategic Choice

> For the parameter documentation rule, see [Parameter Documentation Placement: Strategic Choice](STYLE_GUIDE.md#parameter-documentation-placement-strategic-choice) in the main guide.

The rationale for centralizing parameter help in the comment-based help block:

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

The choice prioritizes **consistency and maintainability**.

---

### Help Format Options: Comparison

> For the help format rule and v1.0 compatibility warning, see [Help Format Options: Comparison](STYLE_GUIDE.md#help-format-options-comparison) in the main guide.

The author uses **single-line comments** (`# .SECTION`) rather than **block comments** (`<# ... #>`).

| Format | Pros | Cons |
| --- | --- | --- |
| **Single-line (`#`)** | • Granular editing • Clear in diff tools • No escaping issues • Works in **all** PowerShell versions including v1.0 | • More vertical space • Slightly more typing |
| **Block (`<# ... #>`)** | • Compact • Modern aesthetic | • **Not supported in PowerShell v1.0** (causes parser error) • Harder to edit individual lines • Risk of malformed blocks |

**Finding**: Only **single-line comments** (`#`) are compatible with PowerShell v1.0. Block comments (`<# ... #>`) are valid in PowerShell v2.0+ and are discoverable by `Get-Help` in those versions, but they **MUST NOT** be used when v1.0 compatibility is required. The single-line format is **required** for the v1.0 compatibility goal.

---

### Private/Internal Helper Function Documentation

> For the private/internal helper documentation rules, see [Private/Internal Helper Function Documentation](STYLE_GUIDE.md#privateinternal-helper-function-documentation) in the main guide.

Private/internal helper functions receive the same full comment-based help treatment as public/exported functions. However, without an explicit banner distinguishing them, a reader examining a function file in isolation cannot tell whether it is part of the stable public API or an internal implementation detail. This matters because:

1. **Drift between file presentation and actual API surface.** When a helper's comment-based help looks identical to a public function's help, consumers may treat it as a supported entry point. If the function is later renamed, restructured, or removed during internal refactoring, those consumers encounter unexpected breakage.
2. **Positional contracts differ in stability.** A public function's positional parameter ordering is a stable contract; an internal helper's ordering may be changed freely as the implementation evolves. Explicitly labeling the positional documentation as an internal-caller contract prevents external callers from relying on ordering that was never guaranteed.
3. **Module manifests are not the only scoping mechanism.** While `FunctionsToExport` in a module manifest (`.psd1`) is the primary mechanism in module-based code, the concept of private/internal helpers is broader: standalone scripts, multi-function `.ps1` files, and v1.0-targeted code all have internal helpers that are not governed by a manifest. The banner rule therefore applies at the `[All]` scope.

The banner is deliberately placed at the top of `.NOTES` so it is the first thing a reader encounters after the behavioral documentation sections. It does not reduce documentation quality; it adds a single, high-signal annotation that protects both the author's refactoring freedom and consumers' expectations.

---

### Summary: Documentation as Complete Specification

The documentation system is **comprehensive and complete**:

- **Zero ambiguity** in function contracts
- **Full behavioral coverage** including failure modes
- **Immediate usability** via `Get-Help` in any PowerShell v1.0+ host
- **Self-contained** — no external help files required
- **Future-proof** — versioned, example-rich, and example-driven

This is not merely "good documentation"—it is **executable specification**. A developer could **delete the implementation** and **reconstruct correct behavior solely from the help blocks and examples**.

The author has elevated documentation from a **maintenance task** to a **core reliability mechanism**, ensuring the code remains understandable, debuggable, and maintainable across decades and environments.

---

## Function Design Rationale

> For function rules and templates, see [Functions and Parameter Blocks](STYLE_GUIDE.md#functions-and-parameter-blocks) in the main guide.

### Overview of Function Architecture

Functions **MUST** be designed as **atomic, reusable tools** with a single, well-defined purpose. Every function **MUST** be a **self-contained unit of execution** that accepts input, performs a transformation or validation, and produces a **predictable, deterministic output**. This design philosophy is rooted in **PowerShell v1.0 constraints** for compatible scripts and deliberately avoids any feature introduced in v2.0 or later in those cases. The result is a **robust, portable, and highly maintainable** codebase that operates identically across all PowerShell versions from 1.0 onward when feasible. However, in scripts with external dependencies requiring newer versions (e.g., modern modules), the author incorporates appropriate features like pipeline processing or structured error handling.

The characteristic pattern of this architecture in v1.0-targeted scripts is the **complete absence** of:

- `[CmdletBinding()]` and `[OutputType()]` attributes
- `begin`, `process`, or `end` blocks
- Common parameters (`-Verbose`, `-Debug`, `-WhatIf`, etc.)
- Pipeline-aware processing
- Structured error handling (`try/catch`)

Instead, the author relies on **v1.0-native constructs**:

- Simple `function` keyword
- Formal `param()` blocks
- Strong typing
- Explicit `return` statements
- Reference parameters (`[ref]`) for outputs that need to modify caller variables

This creates a **C-style procedural model** within PowerShell, prioritizing **control flow predictability** over pipeline composability.

---

### Advanced Feature Emulation (v1.0-Native)

In v1.0 scripts, the author **emulates modern features** using v1.0 constructs:

| Modern Feature | v1.0 Emulation |
| --- | --- |
| `[CmdletBinding()]` | Comment-based help + strong typing |
| `-WhatIf` support | Not applicable (no state change) |
| `SupportsShouldProcess` | N/A |
| `[OutputType()]` | Documented in `.OUTPUTS` |
| Parameter validation | Strong typing + manual checks |

---

### Options for Return Mechanism: Comparison

The use of explicit `return` vs. implicit output represents a **philosophical choice**:

| Approach | Pros | Cons |
| --- | --- | --- |
| **Explicit `return` (current)** | • Full control • No accidental output • v1.0 compatible • Clear contract | • Not pipeline-friendly • Verbose |
| **Implicit output (modern)** | • Pipeline composable • Concise | • Risk of extra objects • Requires v2.0+ for safety |

**Conclusion**: The explicit `return` pattern is **correct and optimal** for v1.0-targeted, non-pipeline tools.

---

### Enforcing Subset-Only Positional Contracts in Modern Functions

> For the corresponding normative rule, see [Positional Parameter Support](STYLE_GUIDE.md#positional-parameter-support) in the main guide.

When `[CmdletBinding()]` is declared without specifying `PositionalBinding`, PowerShell defaults to `PositionalBinding = $true`. This default silently assigns positional slots to **every** declared parameter in the order they appear in the `param()` block. The implicit assignment has two consequences:

1. **Parameter reordering or insertion creates breaking changes.** If a maintainer adds a new parameter between existing ones, or reorders the `param()` block, every positional caller that relied on the original declaration order will silently bind arguments to the wrong parameters. Because the binding change is invisible at the call site, it is difficult to detect during code review or testing.
2. **Documentation/implementation mismatch.** When `.NOTES` documents only a subset of parameters as positional (e.g., `Position 0: InputMode`, `Position 1: OutputPath`) but the runtime actually permits positional binding for all parameters, callers may unknowingly pass values to unintended parameters. This silent divergence between the documented contract and the runtime behavior undermines trust in the function's interface.

`PositionalBinding = $false` eliminates both risks by requiring the author to opt in to positional binding explicitly via `[Parameter(Position = N)]` on each intended positional parameter. Parameters without an explicit `Position` attribute become name-only, regardless of their declaration order.

---

### ValidateRange for Constrained Numeric Parameters

> For the corresponding normative rule, see ["Modern Advanced" Functions/Scripts: Parameter Validation and Attributes (`[Parameter()]`)](STYLE_GUIDE.md#modern-advanced-functionsscripts-parameter-validation-and-attributes-parameter) in the main guide.

`[ValidateRange(min, max)]` shifts validation of constrained numeric inputs from runtime logic to the parameter-binding phase. This has several practical benefits:

1. **Fail-fast with clear diagnostics.** When a caller passes an out-of-range value, PowerShell raises a descriptive `ParameterBindingValidationException` before the function body executes. Without the attribute, the invalid value propagates into downstream logic where it may trigger a confusing or misleading error far from the root cause—for example, a negative retry count silently bypassing a retry loop, or a percentage above 100 producing nonsensical progress output.

2. **Single source of truth for the valid domain.** Encoding the constraint in the attribute declaration keeps the contract visible in `Get-Help` output and in the parameter block itself, rather than burying it in conditional checks scattered through the function body. This improves discoverability for both human readers and LLM-based coding agents.

3. **Consistency with other validation attributes.** The style guide already recommends `[Parameter(Mandatory = $true)]` and `[ValidateNotNullOrEmpty()]` for similar fail-fast goals. `[ValidateRange()]` extends this principle to numeric domains and follows the same design rationale: catch invalid input at the boundary, not in the interior.

**Choosing bounds:**

- When the domain is naturally bounded on both sides (e.g., a percentage from 0 to 100, or a port number from 1 to 65535), both bounds should be explicit.
- When only a lower bound is meaningful (e.g., a retry count that must be non-negative but has no principled maximum), the upper bound should be the type's maximum value (`[int]::MaxValue`, `[double]::MaxValue`, etc.). This preserves the fail-fast benefit for the lower bound without imposing an artificial ceiling.

**Motivating examples of delayed failures without `[ValidateRange()]`:**

- A `$RetryCount` parameter set to `-1` silently bypasses a standard retry loop (`for ($i = 0; $i -lt $RetryCount; $i++)`) because the condition is immediately false, so the function fails on the first attempt with no retries—and the resulting error blames the downstream operation, not the invalid argument.
- A `$TimeoutSeconds` parameter set to `0` is passed to `Start-Sleep`, which silently returns immediately, causing the function to report "timed out" on first check rather than explaining that the timeout value was invalid.
- A `$PercentComplete` parameter set to `200` is passed to `Write-Progress`, which either displays a misleading progress bar or throws a cryptic error depending on the PowerShell host.

In each case, `[ValidateRange()]` would have surfaced the real problem—an out-of-range argument—at parameter binding with a clear, actionable message.

---

### Summary: Function Design as Reliability Engineering

The function and parameter block design represents **reliability engineering at the architectural level**:

- **Atomic operations** with clear contracts
- **Strong typing** for fail-early validation
- **Explicit returns** for deterministic output
- **Reference parameters** for complex state only when write-back is needed
- **Positional support** for usability
- **Pipeline avoidance** for control in v1.0 cases

This creates **industrial-grade script components** that can be:

- Dropped into any PowerShell v1.0+ environment when compatible
- Understood without documentation (though documentation is provided)
- Maintained decades later
- Integrated into larger systems with confidence

The absence of modern features in v1.0 scripts is not a limitation—it is **evidence of mastery** over the v1.0 platform and a deliberate choice for **maximum reliability**.

---

## Error Handling Rationale

> For error handling rules and patterns, see [Error Handling](STYLE_GUIDE.md#error-handling) in the main guide.

### Executive Summary: Error Handling Philosophy

The author implements a **complete, v1.0-native error handling system** in compatible scripts that is **fail-controlled, deterministic, and self-diagnosing**. This is not a workaround for missing `try/catch` (introduced in v2.0) but a **deliberately engineered reliability layer** that:

1. **Suppresses terminating and non-terminating errors** to prevent script abortion
2. **Detects error occurrence** with 100% accuracy using reference-based comparison
3. **Preserves error context** for downstream analysis
4. **Restores original state** after error-prone operations
5. **Communicates anomalies** via the Warning stream when logic reaches "impossible" states

The system is **atomic**—each error-prone operation is isolated, measured, and reported independently. This creates a **diagnostic breadcrumb trail** that enables root cause analysis even in production environments where verbose output is disabled. In scripts requiring modern PowerShell (e.g., due to module dependencies), the author switches to try/catch and other structured mechanisms for improved readability and functionality.

---

### Comparison with Modern Alternatives

| Feature | v1.0 Implementation | v2.0+ Equivalent |
| --- | --- | --- |
| Error suppression | `trap { }` + preference toggle | `try/catch` with `-ErrorAction Stop` |
| Error detection | Reference comparison | `catch` block execution |
| State management | Manual preference restore | Automatic scope exit |
| Anomaly reporting | `Write-Warning` | `Write-Warning` (same) |

The v1.0 pattern is **functionally equivalent** but **more verbose** and **duplicate-prone**.

---

### Summary: Error Handling as Diagnostic Instrumentation

The error handling system is a **masterclass in v1.0 reliability engineering**:

- **Fail-controlled** — never crashes
- **Self-diagnosing** — detects errors with certainty
- **State-preserving** — restores environment
- **Comprehensive** — preserves full error context
- **Production-safe** — warnings for impossible states

This is not "working around" v1.0 limitations — it is **exploiting v1.0 mechanics to achieve enterprise-grade reliability**. The system transforms potentially fatal failures into **predictable, analyzable status codes** while maintaining **zero host output** in normal operation.

The only identified weakness is **helper function duplication**, which **SHOULD** be consolidated into shared nested definitions to eliminate maintenance risk. With this single improvement, the error handling system would achieve **perfect reliability scoring** across all PowerShell versions.

---

## Language Interop Rationale

> For interop rules and patterns, see [Language Interop, Versioning, and .NET](STYLE_GUIDE.md#language-interop-versioning-and-net) in the main guide.

### Executive Summary: Interop and Versioning Strategy

The author employs a **sophisticated, version-aware interoperability layer** that seamlessly bridges **PowerShell v1.0 scripting** with **.NET Framework capabilities** while maintaining **strict backward compatibility** and **deterministic behavior** across all PowerShell versions from 1.0 to modern releases in compatible scripts. This is achieved through:

1. **Runtime version detection** via a dedicated helper function
2. **Conditional execution paths** based on detected PowerShell version
3. **Progressive enhancement** — using advanced .NET types only when available
4. **Graceful degradation** — falling back to simpler types when modern features are absent
5. **Explicit .NET interop** with full documentation of rationale

The strategy transforms potentially version-breaking operations (e.g., handling large numbers) into **resilient, self-adapting code** that works identically whether running on PowerShell 1.0, 3.0, or 7.x. In scripts with dependencies requiring newer PowerShell, version detection is minimized or omitted in favor of assuming the required features.

---

### Type Conversion Safety Chain

> For .NET interop patterns, see [.NET Interop Patterns: Safe and Documented](STYLE_GUIDE.md#net-interop-patterns-safe-and-documented) in the main guide.

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

> For version detection, see [Runtime Version Detection: `Get-PSVersion`](STYLE_GUIDE.md#runtime-version-detection-get-psversion) in the main guide.

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

### Modernization Path (v2.0+)

If v1.0 compatibility were not required, the author would likely:

1. **Replace manual version detection** with `#requires -Version 3.0`
2. **Use `[bigint]` PSCustomObject** instead of `BigInteger` (PS v7+)
3. **Leverage `-split` operator** with `[regex]::Escape()` for literal splits
4. **Add `[ValidateScript()]` attributes** for input validation

---

### Summary: Interop as Adaptive Resilience

The language interop and versioning strategy represents **adaptive resilience engineering**:

- **Version detection** → knows its environment
- **Progressive enhancement** → uses best available tools
- **Graceful degradation** → never fails due to missing features
- **Explicit .NET usage** → documented, safe, and v1.0-compatible
- **Provider-agnostic paths** → deterministic across environments

This creates code that:

- Works on **PowerShell 1.0** with basic functionality
- **Automatically upgrades** performance/precision on newer runtimes
- **Never crashes** due to version differences
- **Self-documents** its capabilities and limitations

The system transforms version fragmentation from a liability into a **non-issue** — the script simply **does the right thing** regardless of where it runs.

---

## Output and Streams Rationale

> For output rules and patterns, see [Output Formatting and Streams](STYLE_GUIDE.md#output-formatting-and-streams) in the main guide.

### Executive Summary: Output Discipline

The author enforces a **zero-tolerance policy for uncontrolled output** and implements a **strict, single-typed, stream-isolated communication model**. This is not merely stylistic preference but a **core reliability requirement** driven by the function's role as a **reusable tool** in **v1.0 PowerShell environments** when applicable.

All output follows **three key principles**:

1. **Single output type** — only one kind of object ever leaves the function
2. **Explicit stream routing** — each message type uses exactly one stream
3. **No host pollution** — no output appears unless explicitly requested

This creates a **predictable, composable, and debuggable** interface that works identically whether the function is called interactively, from a script, or within a larger pipeline. In modern-dependent scripts, additional streams like Verbose or Debug are used as needed.

---

### Format Files: Future-Proof Design Pattern

While not implemented in this v1.0 script, the author's design **anticipates** the use of **`.format.ps1xml` files** for custom object display:

```xml
<!-- Hypothetical modulename.format.ps1xml -->
<Type>
  <Name>ProcessingResult</Name>
  <Members>
    <NoteProperty Name="Status"    Type="int" />
    <NoteProperty Name="Result"   Type="object" />
    <NoteProperty Name="Extras" Type="string[]" />
  </Members>
</Type>
```

**Design considerations**:

- **Raw data preserved** — objects contain full fidelity
- **Display decoupled** — formatting is external
- **Pipeline-safe** — formatting applied only at display time

---

### Modern Stream Capabilities (v2.0+ Context)

In PowerShell v2.0+, the author would likely add:

```powershell
[CmdletBinding()]
param(...)
process {
    Write-Verbose "Attempting operation on $StringToProcess"
    Write-Debug   "Pre-operation error count: $($Error.Count)"
}
```

> **Note:** This example uses `$StringToProcess` for brevity. When the logged variable could contain PII, credentials, or other sensitive data, follow the guidance in [Sensitive Data in Verbose and Debug Streams](STYLE_GUIDE.md#sensitive-data-in-verbose-and-debug-streams).

**Streams enabled**:

- **Verbose** → operational details
- **Debug** → internal state
- **Progress** → long-running operations (not applicable here)

But in **v1.0**, these are **deliberately omitted** — not due to ignorance, but **design constraint**.

---

### Summary: Output as Controlled Interface

The output formatting and stream usage represent **military-grade interface discipline**:

- **Single return type** (`[int]`) → predictable
- **Reference parameters** → complex data without pipeline risk (only for write-back)
- **Warning stream** → diagnostic beacon for impossible states
- **Host stream** → completely sealed
- **Format files** → anticipated for future display needs

This creates a **fortified boundary** between the function and its environment:

- **No data leakage**
- **No side effects**
- **Full diagnostic visibility** when needed
- **Perfect compatibility** with automation, scripting, and interactive use

The absence of `Write-Host` and mixed output types is not a limitation — it is **evidence of mastery** over PowerShell's output model and a deliberate choice for **maximum reliability** in v1.0 environments.

---

## Performance, Security, and Holistic Design Rationale

> For performance, security, and design rules, see [Performance, Security, and Other](STYLE_GUIDE.md#performance-security-and-other) in the main guide.

### Executive Summary: Holistic Design Constraints

The author operates under **three immutable design pillars** that govern every decision in performance, security, and auxiliary behavior:

1. **v1.0 Compatibility** — the code **MUST** run on PowerShell 1.0 without modification when the script's nature allows (e.g., no modern dependencies)
2. **Deterministic Execution** — every path **MUST** produce identical, predictable results
3. **Zero Side Effects** — the function **MUST NOT** alter global state or emit uncontrolled output

These constraints create a **highly constrained optimization space** where performance, security, and maintainability are balanced against **absolute portability**. The result is a **lean, defensive, and self-documenting** implementation that sacrifices micro-optimizations for **macro-reliability**. In dependency-constrained scripts, these pillars adapt to include modern optimizations.

---

### Performance: Measured Pragmatism

The author adopts a **"measure, then optimize"** philosophy, but within v1.0 constraints, **measurement is limited**. No `Measure-Command` or profiling cmdlets exist in v1.0, so performance decisions are based on **algorithmic complexity analysis** and **known PowerShell behavioral characteristics**.

#### Key Performance Characteristics

| Operation | Complexity | Technical Rationale |
| --- | --- | --- |
| **String splitting** | O(n) | `[regex]::Split` with escaped delimiter — linear pass |
| **Type casting loop** | O(1) per attempt, bounded | Bounded by input segments |
| **Error detection** | O(1) | Reference comparison — no array scanning |
| **Version detection** | O(1) | Single `Test-Path variable:\PSVersionTable` |

**Total worst-case complexity**: **O(n)** where *n* is input string length.

#### Performance-Critical Paths

1. **Literal string splitting**

    Uses `[regex]::Escape()` + `[regex]::Split()` instead of `-split` operator
    **Reason**: `-split` is v2.0+; regex method is v1.0-compatible and **faster** for literal splits (no regex engine overhead for metacharacters)

2. **Conditional BigInteger usage**
    Only invoked when:

    - Numeric segment > `[int32]::MaxValue`
    - PowerShell version ≥ 3.0

    **Avoids** costly `BigInteger` allocation in v1.0/v2.0 environments

3. **Short-circuit processing**

   On first successful parse, **excess segments are stored** and processing halts

   Prevents unnecessary type conversion attempts

#### Performance Trade-offs

| Trade-off | Decision | Technical Justification |
| --- | --- | --- |
| **Script vs. Pipeline** | Script constructs (`foreach`) | Avoids pipeline overhead; v1.0 has no optimized pipeline |
| **Regex vs. String methods** | Regex for splitting | `[regex]::Escape()` ensures literal behavior; `String.Split()` has different empty-string semantics |
| **Early version detection** | Optional `$PSVersion` parameter | Caller can skip `Get-PSVersion` if known → saves one `Test-Path` |

**Conclusion**: Performance is **bounded, predictable, and appropriate** for typical use cases. No premature optimization occurs.

---

### Security: Defense-in-Depth by Design

The function processes **untrusted inputs** (e.g., from external sources). The security model is **input-agnostic and side-effect-free**.

#### Security Posture

| Threat Vector | Mitigation | Evidence |
| --- | --- | --- |
| **Injection via string** | Strong typing + safe casting | Type casts fail fast if malformed |
| **Path traversal** | No file system access | Function is pure computation |
| **Memory exhaustion** | Bounded input handling | Max fixed segments + excess string |
| **Information disclosure** | No `Write-Host` | Only Warning stream for anomalies |
| **Privilege escalation** | No external calls | Pure .NET type usage |

#### Secure-by-Default Patterns

1. **No file/registry access** → eliminates path-based attacks
2. **No `Invoke-Expression`** → prevents code injection
3. **No external processes** → no command execution
4. **All .NET interop is read-only** → `[regex]`, `[version]`, `[Numerics.BigInteger]`

#### Credential Handling (Inferred)

While not present, the author's pattern suggests future security handling would use:

```powershell
[Parameter()]
[PSCredential]$Credential
```

With **SecureString** and **never** clear-text storage.

**Design consideration**: The function is **security-neutral** — it neither introduces nor mitigates external risks, but **cannot be exploited** due to its isolated, pure-function design.

---

### Other: Maintainability, Extensibility, and Modernization

#### Maintainability: High Cohesion, Controlled Coupling

| Aspect | Implementation | Benefit |
| --- | --- | --- |
| **Single responsibility** | Targeted operations | Clear contract |
| **No global state mutation** | Only `$global:ErrorActionPreference` (restored) | Predictable |
| **Helper consolidation needed** | Duplicate error functions | **Action item**: nest in parent scope |
| **Versioned internally** | `.NOTES: Version: 1.0.20250218.0` | Change tracking |

#### Extensibility Points

| Extension | Method | v1.0 Compatibility |
| --- | --- | --- |
| **Custom number bases** | Add parameter `[int]$Base = 10` | Yes |
| **Strict mode** | Add switch `[switch]$Strict` | Yes |
| **Output object** | Return `[pscustomobject]` | No (requires v2.0+) |

#### Modernization Path (v2.0+)

If v1.0 compatibility were not required, the author would likely:

```powershell
[CmdletBinding()]
[OutputType([PSCustomObject])]
param(
    [string]$StringToProcess
)
process {
    [pscustomobject]@{
        Status = 0
        Result = $res
        Extras = $extras
    }
}
```

**Benefits**:

- Pipeline-friendly
- `Get-Help` integration
- `-Verbose`/`-Debug` support

**Trade-off**: Breaks v1.0 compatibility

---

### Summary: Performance, Security, and Holistic Design

The **Performance, Security, and Other** aspects reveal a **mature, constrained optimization**:

- **Performance**: Bounded, predictable, and **optimized within v1.0 limits** — no premature micro-optimizations, but **algorithmic efficiency** is excellent.
- **Security**: **Inherently safe** — pure function, no external interfaces, no data leakage. **Cannot be weaponized**.
- **Maintainability**: High, with **one actionable improvement** (consolidate duplicate helpers).
- **Extensibility**: Clear points for future enhancement.
- **Modernization**: Well-defined path to v2.0+ features **without breaking core contract**.

The function is a **minimal, maximalist** design: it does **exactly one thing**, does it **perfectly**, and **refuses to do anything else**. This is the hallmark of **industrial-grade PowerShell tooling** — code that can be deployed in 2006 or 2026 with identical behavior when compatible.

**Final Assessment**: **"Fit for purpose across 18 years of PowerShell evolution."**

---

### Prefer `-LiteralPath` Over `-Path` for Concrete Paths

> For the actionable rules, see [Prefer `-LiteralPath` Over `-Path` for Concrete Paths](STYLE_GUIDE.md#prefer--literalpath-over--path-for-concrete-paths) in the main guide.

#### Why `-Path` Is Dangerous for Concrete Paths

PowerShell's `-Path` parameter interprets wildcard characters (`*`, `?`, `[`, `]`) before resolving to the file system. This is by design—`-Path` supports glob patterns—but it creates a class of subtle, silent bugs when the path is a concrete value that happens to contain these characters:

| Character | Wildcard Meaning | Real-World Source |
| --- | --- | --- |
| `[` `]` | Character-range match | Valid in Windows file names: version tags (`[1.0]`), user-generated names, bracketed metadata |
| `*` | Zero-or-more-character match | Reserved in Windows file names; may appear via user-supplied input or on non-Windows filesystems |
| `?` | Single-character match | Reserved in Windows file names; may appear via user-supplied input or on non-Windows filesystems |

When `-Path` encounters these characters, it attempts wildcard resolution. If no file matches the pattern, the cmdlet may silently return nothing or fail with a misleading error. If multiple files match, the cmdlet operates on all of them—potentially deleting, moving, or overwriting files the code never intended to touch.

#### Variable-Derived Paths Are Especially Risky

Paths built from variables, `Join-Path` output, user input, environment variables, or API results are particularly dangerous with `-Path` because their content is not visible at authoring time. A path like `$strDownloadPath` might resolve to `C:\Users\name\Downloads\report[final].docx`—and `Remove-Item -Path $strDownloadPath` would interpret `[final]` as a character class, potentially matching (and deleting) the wrong files or failing silently.

#### Why `-LiteralPath` Is the Safe Default

`-LiteralPath` treats the entire string as a literal file-system path with no wildcard interpretation. It is semantically equivalent to "this exact path" and eliminates the entire class of wildcard-injection bugs. There is no performance cost to using `-LiteralPath`; it simply bypasses the wildcard-resolution step.

#### Destructive Operations Require Stronger Protection

For `Remove-Item` and `Move-Item`, the consequences of accidental wildcard expansion are **irreversible**—deleted files cannot be recovered (without backups), and moved files may overwrite existing targets. This is why the main guide elevates the rule from **SHOULD** to **MUST** for destructive cmdlets with variable-derived paths.

#### `New-Item` Exception

`New-Item` does not expose a `-LiteralPath` parameter in any released version of PowerShell (Windows PowerShell 5.1, PowerShell 7.x). Attempting `New-Item -LiteralPath` produces a `ParameterBindingException`. Because `New-Item` creates a new item rather than deleting, moving, or modifying existing file-system entries, the wildcard-injection risk is lower than for read or destructive cmdlets, but it is not eliminated: wildcard characters supplied to `-Path` can still match existing parent directories or items and cause creation in unintended or multiple locations. Use `New-Item -Path` when the path value is trusted or validated; for untrusted input that may contain wildcard characters (`[`, `]`, `*`, `?`) as literal characters, validate or reject the input, or use an appropriate .NET API (e.g., `[System.IO.File]::Create()`, `[System.IO.Directory]::CreateDirectory()`) when literal path semantics are required.

#### Wildcard-Safe Directory Creation With `[System.IO.Directory]::CreateDirectory()`

For directory creation specifically, `[System.IO.Directory]::CreateDirectory()` is the preferred .NET alternative when the path is variable-derived and may contain wildcard characters. Unlike `New-Item -Path ... -ItemType Directory`, `CreateDirectory()` does not interpret PowerShell wildcard characters (`[`, `]`, `*`, `?`) and therefore provides deterministic behavior regardless of what characters appear in the path.

The path must be resolved to an absolute filesystem path via `$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath()` before being passed to `CreateDirectory()`, as documented in the "Resolving Paths for .NET Static Methods" rule. `GetUnresolvedProviderPathFromPSPath()` is particularly appropriate here because the target directory may not yet exist.

`CreateDirectory()` is also safe to call when the directory already exists—it returns the existing `DirectoryInfo` object without error—making a preceding `Test-Path -LiteralPath` check optional but useful for clarity. The compliant example in the main guide includes the `Test-Path` guard for readability.

For *file* creation with wildcard-safe semantics, the corresponding .NET API is `[System.IO.File]::Create()` or `[System.IO.StreamWriter]`, but that case is not covered by this rule. The directory-creation guidance is separated because it is the most common scenario where `New-Item -ItemType Directory` would otherwise be the idiomatic choice.

---

### Resolving Paths for .NET Static Methods

> For the actionable rule, see [Resolving Paths for .NET Static Methods](STYLE_GUIDE.md#resolving-paths-for-net-static-methods) in the main guide.

#### Why .NET Static Methods Require Absolute Paths

.NET static methods such as `[System.IO.File]::WriteAllText()`, `[System.IO.File]::WriteAllLines()`, and `[System.IO.Path]::GetFullPath()` resolve relative paths using `[System.Environment]::CurrentDirectory`, which is a process-wide property inherited from the .NET runtime. PowerShell, however, maintains its own working directory via `$PWD`, and the two can diverge silently—for example, when the current PowerShell location is a non-FileSystem provider such as `HKLM:` or `Cert:`, when running in PowerShell 7.x (which no longer syncs `[Environment]::CurrentDirectory` with `$PWD` on `Set-Location`), or when external .NET code changes `[Environment]::CurrentDirectory` independently of PowerShell's location state. This mismatch means that a relative path like `.\output.txt` may resolve to a completely different directory when passed to a .NET method than when used with a native PowerShell cmdlet, producing non-deterministic behavior that is difficult to diagnose.

#### Why `GetUnresolvedProviderPathFromPSPath()` Is Preferred Over `Resolve-Path`

`Resolve-Path` requires that the target path already exists on the file system; if the file has not yet been created, `Resolve-Path` emits an error and does not return a usable path. `$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath()` converts a PowerShell provider path (including PSDrive-relative and `$PWD`-relative paths) into an absolute file-system path *without* verifying that the path exists. This makes it the correct choice for output paths, new file creation, and any scenario where the target may not yet be present.

---

## Content Relocated from STYLE_GUIDE.md

> The following material was moved from `STYLE_GUIDE.md` to reduce the main guide's token footprint while preserving useful human-readable context.

### Metadata and Navigation

The main guide previously included:

- **Status**, **Owner**, and **Last Updated** metadata fields for human maintainers
- A full Table of Contents with links to all major sections
- Navigational aids for human readers

These are not required for runtime instruction processing and have been removed from the operational guide.

### Keywords — Extended Explanation

The main guide previously included the full RFC 2119 keyword definitions with all synonyms:

- **MUST** / **REQUIRED** / **SHALL** — Absolute requirement. Non-negotiable.
- **MUST NOT** / **SHALL NOT** — Absolute prohibition.
- **SHOULD** / **RECOMMENDED** — Strong recommendation. Valid reasons may exist to deviate, but implications must be understood.
- **SHOULD NOT** / **NOT RECOMMENDED** — Strong discouragement. Valid reasons may exist to do otherwise, but implications must be understood.
- **MAY** / **OPTIONAL** — Truly optional. Implementations can choose to include or omit.

### Blank Line Usage

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

The prohibition on trailing whitespace is motivated by practical concerns: trailing whitespace can cause issues with version control systems, some editors, and linters. It also serves no functional purpose and reduces code consistency.

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

### Variable Delimiting in Strings

In addition to curly braces and the format operator, string concatenation is also an acceptable approach:

- **Compliant (Acceptable):** Use string concatenation.

  ```powershell
  $strMessage = ($SSORegion + ': Error occurred')
  ```

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

#### Approved Verb Tables — Action Descriptions

The full verb tables previously included an "Action" column describing what each verb does. These descriptions are from [Microsoft's Approved Verbs documentation](https://learn.microsoft.com/en-us/powershell/scripting/developer/cmdlet/approved-verbs-for-windows-powershell-commands?view=powershell-7.5). The condensed tables in the main guide retain verb names, aliases, and synonyms to avoid.

### Do Not Use Aliases

Using full command names ensures:

1. **Discoverability**: The code is immediately understandable to any PowerShell user.
2. **Future-proofing**: Changes to parameter sets in underlying cmdlets cannot break the script due to positional or partial-name matching.
3. **Syntax highlighting**: Full names trigger proper IDE and GitHub syntax coloring.

### Parameter Naming

Examples of descriptive parameter names:

- `$ReferenceToResultObject` — clearly indicates a `[ref]` parameter for result storage
- `$ReferenceArrayOfExtraStrings` — describes both the reference mechanism and content type
- `$StringToProcess` — specifies both the type and purpose
- `$PSVersion` — follows the established PowerShell naming convention

These names leave no ambiguity about the parameter's purpose, expected type, or direction of data flow. The use of `ReferenceTo` prefix for `[ref]` parameters is a deliberate pattern that instantly signals pass-by-reference semantics — a critical distinction in PowerShell v1.0 where such mechanics are not visually obvious.

### Local Variable Naming: Type-Prefixed camelCase

This prefixing is **not** a legacy artifact but a **deliberate design decision** to compensate for PowerShell's dynamic typing and the frequent absence of modern IDE tooling. The prefix:

- **Eliminates type inference errors** during debugging
- **Reduces cognitive load** when reading code without IntelliSense
- **Prevents accidental type mismatches** in complex logic flows

#### Why Ad Hoc Abbreviated Type Prefixes Are Called Out

The prefix list in [Local Variable Naming: Type-Prefixed camelCase](STYLE_GUIDE.md#local-variable-naming-type-prefixed-camelcase) is intentionally **open-ended** for additional descriptive prefixes — the main guide explicitly permits prefixes like `$ref` and `$version` when they provide immediate type clarity — but **canonical** for the common built-in types it already names: `$obj` is established as the default prefix for any .NET type without a dedicated approved prefix (including enum values), and `$hashtable` is established as the canonical prefix for hashtable variables. Authors remain free to introduce *new* descriptive prefixes for types the list does not cover; what they **SHOULD NOT** do is invent *parallel abbreviated* prefixes for types the list already handles (such as `$enum…` for enums or `$hash…` for hashtables). Doing so fragments the convention: reviewers scanning code can no longer rely on a single, predictable token to identify a variable's type, and searches for `$hashtable` (or for `$obj` on enums) miss the ad hoc variants.

Two specific substitutions are called out because they are the most tempting mistakes:

- **`$enum…` → `$obj…`.** An enum is a .NET type without a dedicated approved prefix, so it falls under the default `$obj` bucket exactly like any other such type. Introducing a separate `$enum` prefix would imply that enums are a first-class category in the prefix list, when in fact the guide's design is for `$obj` to absorb all such types uniformly.
- **`$hash…` → `$hashtable…`.** `$hash` is a natural-looking shortening, but the approved prefix is the fully spelled `$hashtable`. The descriptive-portion rule already forbids abbreviations in the body of a variable name; applying the same discipline to the prefix keeps the type-hinting convention internally consistent and avoids ambiguity with unrelated uses of the word "hash" (e.g., cryptographic hashes, hash codes).

Consistency with the documented prefix list is what keeps the type-hinting convention useful and predictable. Every deviation that is individually "obvious" erodes the guarantee that a reader can identify a variable's type from its prefix alone.

### Comment-Based Help: Structure and Format

The help block **MUST** be **placed inside the function**, **immediately above the `param` block**, ensuring:

- **Proximity to implementation** → reduces drift during refactoring
- **Visibility in plain text** → no IDE required
- **Discoverability via `Get-Help`** → works in PowerShell v1.0+

**Detailed section reference:**

| Section | Purpose | Observed Implementation |
| --- | --- | --- |
| `.SYNOPSIS` | One-sentence purpose | Concise, imperative-voice summary |
| `.DESCRIPTION` | Detailed behavior | Explains logic, edge cases, and failure modes |
| `.PARAMETER` (if the function declares parameters in its `param()` block) | Per-parameter documentation | One block per parameter, even for `[ref]` types |
| `.EXAMPLE` | Usage demonstration | **Multiple examples** with input, output, and explanation |
| `.INPUTS` | Pipeline input | Explicitly "None" (correct for non-pipeline design) |
| `.OUTPUTS` | Return value semantics | Document all outputs; include full mapping for integer status codes when used |
| `.NOTES` | Additional context | Positional parameters, versioning, design rationale |

> **Note:** If a function declares no parameters in its `param()` block (excluding implicit common parameters), the `.PARAMETER` section is omitted entirely. Do not include an empty or placeholder `.PARAMETER` block.

#### Why Three or More `#` Characters Are Non-Compliant in `.EXAMPLE` Blocks

In comment-based help, the first `#` on each line serves as the comment-based help prefix — PowerShell strips it when rendering the help content. For explanatory lines that should appear as PowerShell comments in `Get-Help` output, the second `#` becomes the visible comment marker, producing the intended `# <text>` rendering.

When an author mistakenly uses three `#` characters (`# # # <text>`), the first `#` is consumed as the help prefix, leaving `# # <text>` as the rendered content. `Get-Help` then displays `## <text>`, which does not preserve the intended `# <text>` rendered form and introduces an extra visible comment marker that is visually inconsistent with the surrounding example content. This is a subtle authoring error that the single-`#` non-compliant example does not explicitly cover, because the failure mode is different: single `#` produces bare prose (no comment marker at all), whereas triple `#` produces a *double* comment marker that looks like a Markdown heading rather than a PowerShell comment.

### Help Content Quality: High Standards

Comprehensive help also demonstrates **State Transparency**: showing **exact contents** of output variables after execution, so callers know precisely what to expect.

### Inline Comments: Purpose and Placement

**Examples**:

```powershell
# Retrieve the newest error on the stack prior to doing work
$refLastKnownError = Get-ReferenceToLastError

# Set ErrorActionPreference to SilentlyContinue; this will suppress error output...
$global:ErrorActionPreference = [System.Management.Automation.ActionPreference]::SilentlyContinue
```

No redundant comments (e.g., `# Increment i by 1`) appear—code is considered self-documenting when possible.

### Structural Documentation: Regions and Licensing

The structural documentation using `#region` enables:

- **Rapid navigation** in any editor
- **Isolation of concerns** (license, helpers, core logic)
- **Clear understanding** of design intent

### Return Semantics: Explicit Status Codes

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

### Input/Output Contract: Reference Parameters

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

### Pipeline Behavior: Deliberately Disabled

In v1.0-targeted functions, pipeline input is deliberately disabled. This is **not a limitation** but a **design requirement** for:

- **Deterministic ordering** — processes one input at a time
- **Stateful operations** — requires full control over input sequence
- **v1.0 compatibility** — pipeline binding attributes require v2.0+

### Anomaly Reporting: Write-Warning for Logical Impossibilities

**Purpose** of `Write-Warning` for anomaly reporting:

- **Diagnostic beacon** for developers
- **Production-safe** — does not terminate execution
- **Actionable** — includes exact context (variable values, expected vs. actual)

These warnings represent **contract violations** in the parsing logic and serve as diagnostic information for root cause analysis.

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

### Set-StrictMode Placement for Dot-Sourced Files

The placement rule for `Set-StrictMode -Version Latest` (see [Set-StrictMode Placement for Dot-Sourced Files](STYLE_GUIDE.md#set-strictmode-placement-for-dot-sourced-files) in `STYLE_GUIDE.md`) is driven by how PowerShell handles scope when a `.ps1` file is dot-sourced versus when it is executed or bundled into a module.

#### Dot-Sourcing Scope Semantics

When a `.ps1` file is **dot-sourced** with the `.` operator (for example, `. .\Helpers.ps1`), PowerShell does **not** create a new script scope for the file. Instead, every script-scope statement in the file executes in the **caller's scope**. This includes not only function and variable definitions — which is typically the intended effect — but also settings that modify the execution environment, such as:

- `Set-StrictMode -Version Latest`
- `$ErrorActionPreference = 'Stop'`
- `$InformationPreference = 'Continue'`
- `$VerbosePreference`, `$DebugPreference`, `$WarningPreference`
- Any other preference variable assignment or environment-mutating cmdlet invoked at script scope

If a dot-sourced file sets any of these at script scope, the setting silently persists in the caller's scope after the dot-source completes. The caller has no way to know the setting was changed, and the change is indistinguishable from one the caller made deliberately. This is a classic source of "spooky action at a distance" bugs: a test fixture that enables strict mode for its own helpers can flip strict mode on in the caller's script, causing unrelated code downstream to start failing on previously tolerated constructs (uninitialized variables, missing properties, and so on).

By contrast, when a `.ps1` file is **executed** (for example, via `.\Helpers.ps1` or `& .\Helpers.ps1`), PowerShell creates a fresh script scope for the file. Script-scope statements affect only that scope and are discarded when the file exits. When a file is **bundled** into a module or an aggregate script artifact (for example, concatenated into a single `.psm1` or a monolithic script), the bundled artifact has its own isolated scope when it is imported (`Import-Module`) or executed (not dot-sourced), so script-scope `Set-StrictMode` calls inside the bundled source file are contained in those cases. Dot-sourcing any `.ps1` — including an individual bundled source file or a monolithic bundled artifact — still runs its script-scope statements in the caller's scope and therefore still leaks.

#### Why Require `Set-StrictMode` at All in Bundled Source Files

Requiring `Set-StrictMode -Version Latest` near the top of bundled source files — immediately after any PowerShell-required leading constructs such as `#requires` comments, `using` statements, and any allowed script-level `[CmdletBinding()]`/`param` block — is deliberately redundant at runtime: the bundled artifact itself typically establishes strict mode for the whole module, so the per-file call is a no-op in normal module use. The redundancy exists to preserve **file-level correctness** as a standalone property of the source file. Developers frequently run individual source files directly — to reproduce a bug, to execute a quick unit test, to diff two versions of a helper, or to iterate during authoring — and in those workflows the bundled artifact's strict-mode setting is not in effect. Keeping the directive at the start of each source file's executable body ensures that the file behaves identically whether it is loaded through the bundled artifact or executed on its own, which in turn means local reproduction of a bug cannot be obscured by a strict-mode mismatch.

#### Why Forbid Script-Scope `Set-StrictMode` in Dot-Sourced Files

Dot-sourced files — test fixtures, ad-hoc scripts, build tooling — are by contract supposed to *add* names (functions, variables) to the caller's scope and nothing else. Injecting strict-mode or preference-variable changes into the caller violates that contract and turns a helper file into a source of non-local behavior changes. Moving `Set-StrictMode -Version Latest` into the function body (as the first statement in `begin {}` for advanced functions that use a `begin/process/end` layout, or as the first statement in the function body otherwise) confines the setting to the function's own scope chain, so strict mode is active exactly while the function runs and is cleanly restored when the function returns. Using `begin {}` in advanced functions with named pipeline blocks ensures strict mode applies uniformly to `begin`, `process`, and `end`, and avoids re-running `Set-StrictMode` for every pipeline input. The same logic applies to any other preference variable the function needs to set: set it inside the function body, not at script scope, so the caller's environment is not silently mutated.

### Approaches

#### v1.0 Parser Error Rationale

Since `try/catch` was introduced in PowerShell v2.0, any script containing this syntax will fail to parse on v1.0, even if the code path is never executed. This is why v1.0-targeted scripts **MUST** use the `.NET` approach.

Use the `Test-FileWriteability` function bundled from the reference implementation (see [Reference Implementation](#reference-implementation)).

#### Scripts Requiring PowerShell v2.0+ Support

For scripts targeting PowerShell v2.0 or later, **either approach is acceptable**.

##### Prefer the `.NET` Approach (`Test-FileWriteability`) When

- Script performs **mission-critical operations** or where strict error control/avoidance (i.e., avoiding users seeing an error) is paramount
- Script runs **unattended** (scheduled tasks, automation pipelines)
- Script is part of a **larger module or library** where consistency matters, or where the script/library has to be runnable on PowerShell v1.0 without throwing a parser error
- **Detailed error capture** is needed (e.g., populating a reference to an ErrorRecord for logging)
- Script size is **not a concern**

##### Prefer the `try/catch` Approach When

- Script is a **simple, single-purpose utility**
- Script runs **interactively** where users can see and respond to errors
- The typical user is **PowerShell-savvy** and would be expected to interpret any issues without trouble
- Script is **distributed to others** who may need to read/modify it (simpler code is easier to understand)
- **Minimizing script size** is important

### Code Examples

#### try/catch Approach Rationale

The `try/catch` code example uses `.NET` static methods for both path construction (`[System.IO.Path]::Combine()`) and file operations (`[System.IO.File]::Open()` and `[System.IO.File]::Delete()`) instead of cmdlets. `New-Item` does not support `-LiteralPath`, and `Join-Path`'s `-Path` parameter accepts wildcard characters. Since the guide requires `-LiteralPath` for variable-derived concrete paths, the cmdlet-based approach cannot be made consistent with that rule. `.NET` path and file APIs operate on literal path strings and do not interpret PowerShell wildcard characters, avoiding the inconsistency.

The probe writes to a GUID-based temporary filename (`.write_test_{GUID}.tmp`) in the target file's parent directory instead of probing at the actual output path. This avoids two problems:

- **Data destruction**: APIs with create-or-overwrite semantics (e.g., `[System.IO.File]::Create()`, `New-Item -Force`) truncate or overwrite an existing file at the probe path, destroying pre-existing user data.
- **False failures in overwrite workflows**: If the output file already exists and the script intends to overwrite it, probing at the exact output path with `[System.IO.FileMode]::CreateNew` would throw an `IOException` — a false negative that incorrectly reports the directory as non-writable.

The probe uses `[System.IO.FileMode]::CreateNew` rather than `[System.IO.FileMode]::Create` or `[System.IO.File]::Create()`. `CreateNew` throws an `IOException` if the target file already exists, providing a safety net even in the vanishingly unlikely event of a GUID collision. `Create` (and `[System.IO.File]::Create()`) silently truncate an existing file, which would mask the collision and destroy the other file's contents.

The `[System.IO.FileAccess]::Write` parameter is specified explicitly because the two-argument `File.Open(path, FileMode)` overload defaults to `FileAccess.ReadWrite`. Since the probe only needs to verify write permission, requesting read access is unnecessary and could cause a false negative in environments where inherited ACLs deny read on newly created files while permitting write.

The path is resolved to absolute form via `$ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath()` before being passed to the `.NET` static methods. See [Resolving Paths for .NET Static Methods](STYLE_GUIDE.md#resolving-paths-for-net-static-methods) for the general rule and rationale.

### Reference Implementation

For scripts requiring the comprehensive `.NET` approach, a full implementation of the `Test-FileWriteability` function is available at:

<https://github.com/franklesniak/PowerShell_Resources/blob/master/Test-FileWriteability.ps1>

This implementation includes:

- Explicit file handle control and resource cleanup
- Detailed error capture via reference parameters
- Full documentation and examples
- Support for PowerShell v1.0+

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
        Write-Error -Message "This function only runs on Windows."
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
        Write-Error -Message "This function only runs on Linux or macOS."
        return -1
    }

    # Proceed with Unix-specific operations
    $strOutput = uname -a
    return 0
}
```

### Cross-Version OS Detection

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
        Write-Warning -Message "This function only runs on Windows."
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
        Write-Warning -Message "This function only runs on Linux or macOS."
        return -1
    }

    # Proceed with Unix-specific operations
    return 0
}
```

**Rationale for using dedicated functions:**

The `$IsWindows`, `$IsMacOS`, and `$IsLinux` variables were introduced in PowerShell Core 6.0. Attempting to reference these variables in PowerShell 1.0-5.1 results in a `$null` value, which can lead to incorrect behavior (e.g., `-not $IsWindows` evaluates to `$true` on Windows PowerShell 5.1, incorrectly suggesting the script is not on Windows).

The `Test-Windows`, `Test-macOS`, and `Test-Linux` functions from the PowerShell_Resources repository provide safe, reliable OS detection that works identically across all PowerShell versions from 1.0 onward.

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
        Write-Error -Message "This function requires Windows. Current OS is not supported."
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
        Write-Warning -Message "This function is optimized for Windows. Some features may not be available on other platforms."
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
    Write-Error -Message "This script requires Windows. Current OS: $(if ($IsLinux) { 'Linux' } elseif ($IsMacOS) { 'macOS' } else { 'Unknown' })"
    exit 1
}

# Continue with Windows-specific script logic
```

#### Summary: OS Compatibility Checks

Operating system compatibility checks are a **critical reliability requirement** for platform-specific scripts and functions:

- **Required** when scripts/functions support only specific operating systems
- **Use built-in variables** (`$IsWindows`, `$IsMacOS`, `$IsLinux`) for PowerShell Core 6.0+ only scripts
- **Use safe functions** (`Test-Windows`, `Test-macOS`, `Test-Linux`) for scripts supporting older PowerShell versions
- **Report errors consistently** with the script's existing error handling patterns
- **Fail early** to prevent unexpected behavior on unsupported platforms

### Runtime Version Detection: `Get-PSVersion`

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

### Conditional .NET Feature Usage: Progressive Enhancement

The **progressive enhancement stack** for numeric overflow handling:

| PowerShell Version | .NET Type Used | Numeric Range |
| --- | --- | --- |
| v3.0+ | `[System.Numerics.BigInteger]` | Unlimited (subject to memory) |
| v1.0–v2.0 | `[double]` | ±1.7 × 10³⁰⁸ (IEEE 754) |
| All versions | `[int]`, `[int64]` | Built-in safe conversions |

**Rationale**:

- **BigInteger** → handles numbers larger than `[int32]::MaxValue` (2,147,483,647)
- **Double** → v1.0-compatible approximation for large numbers
- **No runtime exceptions** → conversion functions return `$false` on failure

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

### Primary Output: Integer Status Code via `return`

**Key characteristics** of the primary output status code:

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

This status code serves as the **function's contract** — a machine-readable indicator of outcome.

### Complex Output: Reference Parameters (`[ref]`)

When structured data must be written back to the caller, `[ref]` parameters provide several practical **advantages**:

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

### Stream Usage: Clear Mapping

#### Warning Stream Details

`Write-Warning` **MUST** be used **sparingly and surgically** for **logically impossible states**:

```powershell
Write-Warning -Message 'Conversion of string failed even though valid. This should not be possible!'
```

**Purpose**:

- **Developer alert** — indicates internal contract violation
- **Non-terminating** — does not halt execution
- **Actionable** — includes exact values and context
- **Production-safe** — visible only with `-WarningAction` or `$WarningPreference`

#### Host Stream Rationale

**No output ever goes to the host console** via:

- `Write-Host`
- `Write-Output` (except via `return`)
- Echo/print statements

**Rationale**:

- **Pipeline safety** — prevents data leakage
- **Script compatibility** — silent operation in automation
- **v1.0 compliance** — avoids v2.0+ stream features

#### Output Type Consistency

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

#### Stream Interaction Matrix

| Caller Context | Success Stream | Warning Stream | Host Stream |
| --- | --- | --- | --- |
| Interactive | Status code visible | Warnings shown | **Never** |
| Script | `$status` captured | Warnings logged | **Never** |
| Pipeline | Status flows downstream | Warnings preserved | **Never** |

### Sensitive Data in Verbose and Debug Streams

Additional compliant examples for logging sensitive data safely:

```powershell
# Compliant - logs the value's type name with a null-safe fallback
$strPrincipalKeyTypeName = if ($null -ne $PrincipalKey) { $PrincipalKey.GetType().Name } else { '<null>' }
Write-Debug -Message ('PrincipalKey type: {0}' -f $strPrincipalKeyTypeName)

# Compliant - logs non-sensitive metadata (string length) with a type-safe fallback
$strPrincipalKeyLength = if ($PrincipalKey -is [string]) { [string]$PrincipalKey.Length } else { '<n/a>' }
Write-Verbose -Message ('PrincipalKey length: {0}' -f $strPrincipalKeyLength)
```

### Test File Naming and Location

**Example directory structure:**

```text
repository/
├── src/
│   └── Get-UserInfo.ps1
└── tests/
    └── Get-UserInfo.Tests.ps1
```

#### Pester Intro

**Pester** is the standard testing framework for PowerShell, providing a domain-specific language for writing and executing tests. This section documents testing conventions that integrate with the coding standards in this guide. For comprehensive Pester documentation, see [pester.dev](https://pester.dev/).

> **Note:** Pester 5.x requires PowerShell 3.0+ to execute tests. However, v1.0-compatible scripts can still be tested with Pester—simply run the tests on a modern PowerShell version (e.g., pwsh 7.x on a CI platform like `ubuntu-latest`). The test files themselves will use modern Pester syntax, but the scripts under test can target any PowerShell version.

### Running Pester Tests

> For the actionable rule, see [Running Pester Tests](STYLE_GUIDE.md#running-pester-tests) in the main guide.

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

#### Why CI Pester discovery must be scoped to the project test root

A CI workflow that discovers tests from the repository root can produce a misleading green result by finding tests the project does not actually own. For example, a repository can contain `samples/template/Example.Tests.ps1` from a starter project while the real `tests/` directory is missing. A root scan such as `Get-ChildItem -Path . -Filter '*.Tests.ps1' -Recurse` will find and execute the sample test, so CI reports that Pester passed even though the project's real test suite is absent.

Scoping discovery to `tests/` or to the project's documented test root converts that situation into the intended signal: either the owned tests run, or the workflow reports that no owned Pester tests were found. It also prevents vendored modules, dependencies, scaffolding, and examples from changing the test surface area behind the project's back.

#### Why discovery and execution need a single test-root source of truth

Pester discovery and Pester execution are two halves of one contract. If discovery scans `tests/` but the Pester configuration `Run.Path` later points at `.`, the workflow's preflight output no longer describes what Pester actually runs. The inverse is also risky: discovery can say test files exist in one directory while execution runs a narrower or entirely different directory and silently skips the files that justified the step.

A single source of truth, such as `PESTER_TEST_ROOT`, keeps the workflow honest. The same value defines what "this project's tests" means for both the preflight check and the Pester configuration, so a later path change is made once instead of being duplicated across separate script fragments.

#### Why missing test roots should skip cleanly

Downstream consumers often adopt a style guide or reusable workflow before they have created PowerShell tests. Some projects intentionally remove a `tests/` directory during early scaffolding, documentation-only work, or staged migrations. In those cases, a hard workflow failure from `Get-ChildItem` is mostly noise: it says the directory is absent, not that the code failed a test.

A `Test-Path -LiteralPath` guard lets the workflow produce a clear "no test files" skip when the directory is absent. That keeps CI output actionable while still making the absence of owned Pester tests visible to maintainers. `Get-ChildItem` with `-ErrorAction SilentlyContinue` is an alternative shape, but it is not equivalent: `SilentlyContinue` will also suppress non-existence-related errors such as permission or IO failures, converting genuine CI problems into a silent "no tests" skip. Preferring `Test-Path` followed by `Get-ChildItem` without `-ErrorAction SilentlyContinue` keeps the skip narrowly scoped to "directory is missing," while still surfacing real enumeration failures as workflow errors.

### Testing Strongly-Typed Array Properties

> For the normative rules, see [Testing Strongly-Typed Array Properties](STYLE_GUIDE.md#testing-strongly-typed-array-properties) in the main guide.

#### Why `Should -Not -BeNullOrEmpty` before `.Count`

When a property is `$null` or an empty array, `$obj.Prop.Count | Should -BeGreaterThan 0` can produce the same generic failure message—such as *"Expected the actual value to be greater than 0, but got 0"*—because in PowerShell `$null.Count` also evaluates to `0`. In contrast, `$obj.Prop | Should -Not -BeNullOrEmpty` immediately communicates that the value was null or empty, giving the developer a much clearer signal about what went wrong. Testing non-emptiness first also guards subsequent assertions—such as type checks—from operating on a `$null` value that would produce misleading results.

#### Why permitting `[object[]]` weakens the test

When production code intentionally casts a property to a strongly-typed array like `[string[]]`, the test exists to ensure that cast is preserved. If a future refactor accidentally removes the cast, the property silently degrades to `[object[]]`—PowerShell's default array type. A disjunction such as `($x -is [string[]]) -or ($x -is [object[]])` will still pass in that scenario, defeating the purpose of the assertion. By requiring the exact type match (`-is [string[]]` alone), the test catches the regression immediately.

#### Why `Should -BeOfType [string[]]` is discouraged for array-type assertions

Pester's `-BeOfType` assertion receives its input through the PowerShell pipeline. When an array is piped (`$x | Should -BeOfType [string[]]`), PowerShell unrolls the array and sends each element individually to `Should`. Pester then evaluates `-BeOfType` against each *element*, not against the *array itself*. This means the assertion tests whether each string is of type `[string[]]`—which it is not—and the test fails even when the property is correctly typed.

A workaround exists: the unary comma operator (`, $x | Should -BeOfType [string[]]`) wraps the array in a single-element wrapper array so that the original array survives pipeline unrolling as a single object. However, this idiom is obscure and error-prone; contributors unfamiliar with the trick may remove the comma or misunderstand the intent. The `-is` operator pattern (`($x -is [string[]]) | Should -BeTrue`) avoids pipeline unrolling entirely, is self-documenting, and is consistent across all array-type assertions.

### Defensive Assertions Before Iteration and Indexing

> For the normative rules, see [Defensive Assertions Before Iteration and Indexing](STYLE_GUIDE.md#defensive-assertions-before-iteration-and-indexing) in the main guide.

#### Why `foreach` over `$null` or an empty collection is a silent-pass risk

In PowerShell, `foreach ($x in $null) { ... }` and `foreach ($x in @()) { ... }` both execute zero loop iterations. When a Pester `It` block places all of its `Should` assertions inside such a `foreach`, a bug that causes the function under test to return `$null` or an empty array will not trigger any assertion failure—the test silently passes with zero evaluated assertions. This is one of the most dangerous patterns in Pester tests because it gives a green test result for fundamentally broken code. A single `Should -Not -BeNullOrEmpty` assertion before the loop converts that silent pass into an immediate, descriptive failure.

#### Why a direct Pester assertion is more actionable than a runtime indexing error

When a test accesses `$arrResult[0]` without first asserting the collection count, a `$null` or empty result produces a runtime error such as *"Cannot index into a null array"* rather than a structured Pester failure. This runtime error obscures the root cause—the function returned unexpected output—behind an implementation detail of the test itself. A pre-index `$arrResult.Count | Should -Be <N>` assertion produces a clear Pester message like *"Expected 1, but got 0"*, immediately signaling that the function's output contract was violated, not the test code.

#### Why outer-collection and nested-property assertions protect different failure modes

An outer assertion like `$arrResult.Count | Should -Be 1` confirms that the top-level collection has the expected number of elements, but it says nothing about the structure of each element. A nested assertion like `$arrResult[0].Principals | Should -Not -BeNullOrEmpty` confirms that a specific property within that element is populated. These guard against different regression scenarios: one where the function returns too few (or too many) top-level results, and another where the function returns the right number of results but with missing or empty nested data. Both assertions are needed to fully protect subsequent indexed access into the nested property.

#### How pre-assertions strengthen Arrange-Act-Assert

The Arrange-Act-Assert pattern structures a test into setup, execution, and verification phases. Defensive pre-assertions fit naturally at the beginning of the Assert phase as *structural guards* that validate the shape and size of the result before the test proceeds to verify specific values. This layered approach ensures that each assertion failure maps to a single, unambiguous cause: a structural guard failure means the output contract was violated at a structural level, while a value assertion failure means the structure was correct but a specific value was wrong. Without these guards, a single failure can be ambiguous—did the function return the wrong value, or did it return nothing at all?

### Asserting Successful Execution With Should -Not -Throw

> For the normative rules, see [Asserting Successful Execution With Should -Not -Throw](STYLE_GUIDE.md#asserting-successful-execution-with-should--not--throw) in the main guide.

#### Why `try/catch` plus negated assertions on exception text is a silent-pass risk

A success-case test that wraps the call in `try { ... } catch { $e = $_ }` and then asserts only `$e.Exception.Message | Should -Not -Match '<pattern>'` is structurally fragile. The test passes under two very different conditions: (1) the call did not throw at all (the intended success path), and (2) the call threw for some unrelated reason and the exception message simply did not contain the negated pattern. Case (2) is a false positive: the function under test failed, but the test reports green. Worse, as the implementation evolves, the exception text can change for reasons wholly unrelated to the behavior being tested—error messages are rephrased, wrapping exceptions are added or removed, localization is introduced—and none of those changes would cause the negated assertion to fail. The test becomes a permanent green light that cannot distinguish success from a broad class of unrelated failures.

#### Why `{ ... } | Should -Not -Throw` is the correct pattern for asserting success

`Should -Not -Throw` evaluates the script block and fails the test on **any** exception, regardless of type, message, or origin. This is exactly the semantics required of a success-case assertion: "the call completed without throwing." There is no pattern to maintain, no message text that can drift, and no silent-pass path. A regression that introduces any new exception—expected or not, related or not—immediately produces a descriptive Pester failure that names the thrown exception, making the root cause easy to diagnose. The idiom is also self-documenting: a reader sees the script block and `Should -Not -Throw` and immediately understands that the assertion under test is "this does not throw."

#### Why expected-failure tests are different and must use positive assertions

Tests that verify a *specific expected failure* are the inverse problem: their purpose is to confirm that a particular exception condition is reached. These tests legitimately need to inspect exception details, but their follow-up assertions on the captured exception **MUST** fail when the expected exception is absent or different. `Should -Throw -ExpectedMessage '<pattern>'` fails both when no exception is thrown and when an exception is thrown whose message does not match the pattern—both are defects. Capturing the exception in a `catch` block and then asserting `$e.Exception.Message | Should -Match '<pattern>'` is similarly safe, because `$e` is `$null` when no exception was thrown and the `-Match` assertion fails on `$null`. The failure mode that must be avoided is a negated assertion against exception **text** (`Should -Not -Match`, `Should -Not -Be` against `$e.Exception.Message`) used as the *only* check, because any input that makes the negated predicate true—including the absence of any exception at all, or an exception with a totally unrelated message—counts as a pass. A presence-guard assertion such as `$e | Should -Not -BeNullOrEmpty` against the captured `ErrorRecord` itself is not subject to this failure mode: it fails precisely when `$e` is `$null`, which is the "expected exception absent" case, and is therefore explicitly permitted — and recommended — as a structural guard before dereferencing `$e.Exception`.

#### How to capture the thrown exception for follow-up assertions

`Should -Throw` on its own does not implicitly expose the thrown exception to subsequent statements, so any follow-up assertion against the exception needs an explicit capture mechanism. Pester 5 supports two idioms. The first is `Should -Throw -PassThru`, which evaluates the script block, asserts that it throws, and returns the thrown `ErrorRecord` as its output so it can be assigned to a variable and inspected—for example, `$errorRecord = { ... } | Should -Throw -PassThru; $errorRecord.Exception.Message | Should -Match '<pattern>'`. The second is the classic `try { ... } catch { $e = $_ }` pattern, in which the caught `$_` is an `ErrorRecord` whose `Exception` property exposes the same detail; a presence-guard assertion such as `$e | Should -Not -BeNullOrEmpty` followed by `$e.Exception.Message | Should -Match '<pattern>'` is safe because both assertions fail when `$e` is `$null`. Both idioms are acceptable; the critical constraint is that the follow-up assertions on the captured exception fail when the expected exception is absent or different. Assertions that satisfy this constraint include both positive predicates on exception detail (`Should -Match`, `Should -Be`, `Should -BeOfType`, etc.) and the presence guard `Should -Not -BeNullOrEmpty` against the captured `ErrorRecord` itself — despite using `-Not`, the presence guard fails precisely in the absent-exception case and is therefore consistent with (and complementary to) the rule. What **MUST NOT** be used as the sole follow-up check is a negated predicate against exception **text** (e.g., `$e.Exception.Message | Should -Not -Match '<pattern>'`), because that assertion is silently satisfied by any exception whose message does not match — including unrelated exceptions and the absence of an exception altogether.

#### Motivating case

This rule was added in response to a review thread on [franklesniak/PSStyleGuide#37](https://github.com/franklesniak/PSStyleGuide/pull/37) (review comment `r3121685195`), which surfaced Pester success-case tests written as `try/catch` with `Should -Not -Match` assertions on `$e.Exception.Message`. In that context, a regression that caused the function under test to throw an unrelated exception would still have produced a green test result, because the negated message assertion was satisfied by any message that did not happen to contain the forbidden substring. Codifying the `{ ... } | Should -Not -Throw` requirement prevents that silent-pass class of test from recurring.
