# GitHub Copilot Agent Prompts for STYLE_GUIDE.md Refactoring

This document contains a series of standalone prompts to be executed sequentially by GitHub Copilot Agent. Each prompt is self-contained and assumes all previous prompts have been completed.

---

## Prompt 1: Create Upfront Checklist Structure and Add Code Layout Guidelines

`````markdown
In the file `STYLE_GUIDE.md` in this repository, add a new section immediately after the "Executive Summary: Author Profile" section and before the "Code Layout and Formatting" section.

This new section should be titled "## Quick Reference Checklist" and should contain an upfront checklist of very brief stylistic guidelines. The checklist should help both humans and LLMs (like GitHub Copilot) quickly understand the key stylistic rules.

For this first task, create the checklist structure and populate it with items covering the "Code Layout and Formatting" section. Each checklist item should:

1. Be a brief, actionable statement (one line, 10-15 words maximum)
2. Include a Markdown link to the corresponding detailed subsection in the document. Ensure all anchor links point to the correct, specific subsections in the document. Create/update headers as necessary.
3. Indicate whether the rule applies to "Modern" scripts (targeting PowerShell 5.1+ and PowerShell 7.x+), "v1.0" scripts (backward compatible to Windows PowerShell v1.0), or "All" scripts

Format each checklist item like this:
- **[Scope]** Brief guideline statement → [Link text](#anchor-to-section)

Where [Scope] is one of: **[All]**, **[Modern]**, or **[v1.0]**

For the "Code Layout and Formatting" section, create checklist items covering:
- Indentation (4 spaces)
- Opening braces placement (same line)
- Exception for catch/finally/else keywords (must be on same line as closing brace)
- Whitespace around operators
- Operator alignment (no vertical alignment)
- Multi-line method indentation
- Blank lines usage
- Variable delimiting in strings (curly braces, -f operator)

Make sure the anchor links work correctly by using the standard GitHub Markdown heading anchor format (lowercase, hyphens for spaces, remove special characters).
`````

---

## Prompt 2: Add Capitalization and Naming Conventions to Checklist

`````markdown
In the file `STYLE_GUIDE.md`, locate the "## Quick Reference Checklist" section that was created in the previous task. Add new checklist items at the end of this section to cover the "Capitalization and Naming Conventions" section of the document.

Each checklist item should follow the same format established previously:
- **[Scope]** Brief guideline statement → [Link text](#anchor-to-section)

For the "Capitalization and Naming Conventions" section, create checklist items covering:
- PascalCase for public identifiers (functions, parameters, properties)
- Lowercase for PowerShell keywords (function, param, if, else, return, trap)
- camelCase with type-hinting prefixes for local variables (e.g., $strMessage, $intCount)
- Function naming: Verb-Noun pattern with approved verbs
- Singular nouns in function names
- Module naming: PascalCase nouns (containers, not actions)
- No aliases in code
- No compatibility aliases in module exports (with exception for genuine interactive shortcuts)
- Parameter naming: PascalCase, fully descriptive
- Reference parameters: use "ReferenceTo" prefix
- Local variables: type prefixes + camelCase, fully descriptive (no abbreviations)
- Avoid relative paths and tilde (~) shortcut
- Explicit scoping ($global:, $script:)

Each checklist item should indicate whether the rule applies to "Modern" scripts (targeting PowerShell 5.1+ and PowerShell 7.x+), "v1.0" scripts (backward compatible to Windows PowerShell v1.0), or "All" scripts.

Ensure all anchor links point to the correct, specific subsections in the document. Create/update headers for subsections as necessary. Verify that all anchor links are correctly formatted for GitHub Markdown and will navigate to the intended sections.
`````

---

## Prompt 3: Add Documentation and Comments Guidelines to Checklist

`````markdown
In the file `STYLE_GUIDE.md`, locate the "## Quick Reference Checklist" section. Add new checklist items at the end of this section to cover the "Documentation and Comments" section.

Each checklist item should follow the same format:
- **[Scope]** Brief guideline statement → [Link text](#anchor-to-section)

For the "Documentation and Comments" section, create checklist items covering:
- All functions must have full comment-based help
- Comment-based help placed inside function body
- Use single-line comments (#) with dotted keywords (.SYNOPSIS, .DESCRIPTION, etc.)
- Required help sections: .SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE, .INPUTS, .OUTPUTS, .NOTES
- Multiple examples showing input, output, and explanation
- Document all return codes with exact meanings
- Include positional parameter support in .NOTES
- Include version number in .NOTES (format: Major.Minor.YYYYMMDD.Revision)
- Version build component must be current date in YYYYMMDD format
- Inline comments focus on "why" not "what"
- Use #region / #endregion for logical code folding
- Per-function licensing in distributable helpers (#region License after param block)
- Parameter documentation centralized in help block (not above individual parameters)

Each checklist item should indicate whether the rule applies to "Modern" scripts (targeting PowerShell 5.1+ and PowerShell 7.x+), "v1.0" scripts (backward compatible to Windows PowerShell v1.0), or "All" scripts.

Ensure all anchor links point to the correct, specific subsections in the document. Create/update headers for subsections as necessary. Verify that all anchor links are correctly formatted for GitHub Markdown and will navigate to the intended sections.
`````

---

## Prompt 4: Add Functions and Parameter Blocks Guidelines to Checklist

`````markdown
In the file `STYLE_GUIDE.md`, locate the "## Quick Reference Checklist" section. Add new checklist items at the end of this section to cover the "Functions and Parameter Blocks" section.

Each checklist item should follow the same format:
- **[Scope]** Brief guideline statement → [Link text](#anchor-to-section)

For the "Functions and Parameter Blocks" section, create checklist items covering:

**v1.0-targeted functions:**
- No [CmdletBinding()] attribute
- No [OutputType()] attribute
- No begin/process/end blocks
- No pipeline input support
- Simple function keyword with param() block
- Strong typing in parameters
- Explicit return statements
- Reference parameters ([ref]) for outputs requiring caller modification
- Return single integer status code (0=success, 1-5=partial, -1=failure)
- Support positional parameters for v1.0 usability
- trap-based error handling (not try/catch)

**Modern functions (v2.0+):**
- Must use [CmdletBinding()] attribute
- Must use [OutputType()] declaring singular primary type
- Must use streaming output (write objects directly to pipeline in loop)
- Must use try/catch for error handling
- Must use Write-Verbose and Write-Debug (not manual preference toggling)
- Exception: May temporarily suppress $VerbosePreference for noisy nested commands using try/finally
- Use [Parameter(Mandatory=$true)] only when function cannot work without value
- Use [ValidateNotNullOrEmpty()] for optional-but-not-empty parameters
- Multiple [OutputType()] only for intentionally polymorphic returns

**All functions:**
- Functions are atomic, reusable tools with single purpose
- Polymorphic parameters (multiple incompatible types) left un-typed or [object]
- [ref] used exclusively for output requiring write-back to caller scope
- [ref] not used for complex objects that don't need modification

Each checklist item should indicate whether the rule applies to "Modern" scripts (targeting PowerShell 5.1+ and PowerShell 7.x+), "v1.0" scripts (backward compatible to Windows PowerShell v1.0), or "All" scripts.

Ensure all anchor links point to the correct, specific subsections in the document. Create/update headers for subsections as necessary. Verify that all anchor links are correctly formatted for GitHub Markdown and will navigate to the intended sections.
`````

---

## Prompt 5: Add Consuming Streaming Functions and Any Remaining Guidelines to Checklist

`````markdown
In the file `STYLE_GUIDE.md`, locate the "## Quick Reference Checklist" section. Add new checklist items at the end of this section to cover any remaining guidelines from the document that haven't been added yet.

Specifically, add checklist items for:

**Consuming Streaming Functions (0-1-Many Problem):**
- When consuming streaming functions, wrap result in @() to handle 0-1-many scenarios
- Single-item results become scalar without @() wrapper
- Using @() ensures consistent array handling regardless of result count

**Any other guidelines found in the document that are not yet in the checklist.**

Each checklist item should follow the same format:
- **[Scope]** Brief guideline statement → [Link text](#anchor-to-section)

After adding these items, review the entire checklist to ensure:
1. All major stylistic guidelines from the document are represented
2. Items are logically grouped (keep code layout together, naming together, documentation together, etc.)
3. The scope tags ([All], [Modern], [v1.0]) are accurate
4. All anchor links are correct and will work in GitHub's Markdown rendering
5. The checklist is comprehensive enough that an LLM processing the first 100-200 lines will understand all key style requirements

Each checklist item should indicate whether the rule applies to "Modern" scripts (targeting PowerShell 5.1+ and PowerShell 7.x+), "v1.0" scripts (backward compatible to Windows PowerShell v1.0), or "All" scripts.

Ensure all anchor links point to the correct, specific subsections in the document. Create/update headers for subsections as necessary. Verify that all anchor links are correctly formatted for GitHub Markdown and will navigate to the intended sections.
`````

---

## Prompt 6: Add Explanatory Introduction to Quick Reference Checklist

`````markdown
In the file `STYLE_GUIDE.md`, locate the "## Quick Reference Checklist" section. Immediately after the section heading and before the first checklist item, add an explanatory paragraph that describes:

1. The purpose of the checklist (quick reference for both humans and LLMs)
2. How to interpret the scope tags:
   - **[All]**: Applies to all PowerShell scripts regardless of target version
   - **[Modern]**: Applies only to scripts targeting PowerShell 5.1+ (with .NET Framework 4.8+) and PowerShell 7.x+ (requires features not available in v1.0)
   - **[v1.0]**: Applies only to scripts that must be backward compatible with Windows PowerShell v1.0
3. That each item links to the detailed section for more information
4. That this checklist is designed to give LLMs (like GitHub Copilot) a complete picture of the style guide within the first 100-200 lines

The paragraph should be concise (3-5 sentences) and written in a professional, instructive tone consistent with the rest of the document.
`````

---

## Prompt 7: Review and Optimize Checklist for LLM Consumption

`````markdown
In the file `STYLE_GUIDE.md`, review the "## Quick Reference Checklist" section to optimize it for LLM processing while maintaining human readability.

Perform the following tasks:

1. **Count lines**: Determine approximately how many lines from the start of the document to the end of the Quick Reference Checklist section. If this exceeds 200 lines, consider whether any items can be made more concise without losing essential information.

2. **Verify completeness**: Cross-reference the checklist against all major sections in the document to ensure no significant stylistic guidelines are missing. If you find any, add them following the established format.

3. **Check grouping**: Ensure checklist items are logically grouped by topic (all code layout items together, all naming items together, etc.) to make scanning easier.

4. **Verify scope tags**: Review each item's scope tag ([All], [Modern], [v1.0]) for accuracy based on the detailed sections they reference.

5. **Validate links**: Verify that all anchor links are correctly formatted for GitHub Markdown and will navigate to the intended sections.

6. **Add sub-headings**: If the checklist has grown large (more than 30 items), consider adding level-3 headings (###) within the checklist to group related items (e.g., "### Code Layout", "### Naming Conventions", "### Documentation", "### Functions").

7. **Consistency check**: Ensure all items follow the same format and style conventions.

Do not change the content of other sections in the document. Focus only on optimizing the Quick Reference Checklist section.
`````

---

## Prompt 8: Add Table of Contents Entry and Final Document Validation

`````markdown
In the file `STYLE_GUIDE.md`, perform the following final tasks:

1. **Check for Table of Contents**: Look for a table of contents near the beginning of the document (typically between the title and the Executive Summary). If one exists, add an entry for the new "Quick Reference Checklist" section in the appropriate location (likely after "Executive Summary: Author Profile" and before "Code Layout and Formatting").

2. **If no Table of Contents exists**: Consider whether one should be created. If the document is long (more than 500 lines) and has multiple major sections, create a table of contents immediately after the document title and before the "Executive Summary: Author Profile" section. The table of contents should list all level-2 (##) headings as clickable links.

3. **Verify document flow**: Read through the section transitions from "Executive Summary: Author Profile" → "Quick Reference Checklist" → "Code Layout and Formatting" to ensure the flow is logical and the new section integrates smoothly.

4. **Check for duplicate information**: Ensure the Quick Reference Checklist doesn't contain so much detail that it duplicates the main sections. Each checklist item should be brief enough to serve as a reference, not a replacement for the detailed sections.

5. **Final anchor link validation**: Do one final pass through all anchor links in the checklist to ensure they work correctly.

6. **Formatting consistency**: Ensure consistent spacing, punctuation, and capitalization throughout the checklist.

After completing these tasks, the refactoring of `STYLE_GUIDE.md` should be complete. The document should now have an upfront checklist that helps LLMs quickly understand all key stylistic guidelines within the first 100-200 lines, while maintaining full human readability and not significantly duplicating content.
`````

---

## Notes on Execution

- Execute these prompts in order (1 through 8).
- Each prompt is self-contained and does not reference previous prompts by name.
- Each prompt assumes the work from previous prompts is complete.
- No line numbers are referenced; instead, sections are referenced by heading names or structural descriptions.
- Each prompt is designed to be substantial enough to make efficient use of GitHub Copilot's capabilities while remaining focused and manageable.

---

## Backlog Summary

The complete backlog of work items:

1. Create Quick Reference Checklist section structure
2. Add Code Layout and Formatting items to checklist
3. Add Capitalization and Naming Conventions items to checklist
4. Add Documentation and Comments items to checklist
5. Add Functions and Parameter Blocks items (v1.0 and Modern variants)
6. Add Consuming Streaming Functions and remaining items
7. Add explanatory introduction to the checklist
8. Review and optimize checklist for LLM consumption
9. Add table of contents entry if applicable
10. Final document validation and integration check