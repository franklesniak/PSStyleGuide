# Nested Markdown Linting Implementation Summary

## Overview

This implementation adds the capability to lint Markdown content that appears inside code fences marked with the `markdown` or `md` language identifier. The existing markdownlint workflow only validated the outer Markdown file structure; this enhancement ensures nested Markdown also follows the repository's linting rules.

## Changes Made

### 1. Dependencies Added (package.json)

- **markdown-it** (^14.0.0): Markdown parser for extracting code blocks
- **markdownlint** (^0.36.1): Core markdownlint library for linting extracted content
- **glob** (^10.3.10): File pattern matching for finding Markdown files
- **New npm script**: `lint:md:nested` - runs the nested markdown linting

### 2. Extraction Script (scripts/lint-nested-markdown.js)

A new Node.js script that:

- Scans all `.md` files in the repository (excluding `node_modules`)
- Uses markdown-it to parse each file and extract the AST
- **Recursively** identifies code fences with language identifier `markdown` or `md` at all nesting depths
- Runs markdownlint on each extracted block
- Tracks source file, line numbers, nesting depth, and parent path for context
- Reports violations with clear error messages including depth information
- Exits with error code 1 if violations are found

**Key features:**

- **Supports recursive nesting**: Extracts and lints markdown at any depth (markdown inside markdown inside markdown, etc.)
- Uses the existing `.markdownlint.json` configuration
- Disables MD041 (first-line-heading) for nested blocks since snippets may not start with a top-level heading
- Handles different fence lengths (```, ````, ``````, etc.)
- Supports both `markdown` and `md` language identifiers
- Provides color-coded terminal output with depth indicators for readability

### 3. GitHub Workflow Update (.github/workflows/markdownlint.yml)

Updated the workflow to run nested markdown linting:

```yaml
- name: Run markdownlint on outer files
  run: npm run lint:md

- name: Run markdownlint on nested Markdown code fences
  run: npm run lint:md:nested
```

The workflow now runs two checks:

1. Original check for outer Markdown files
2. New check for nested Markdown content in code fences

### 4. Test Files

Created comprehensive test files demonstrating:

- **test-nested-markdown-linting.md**: Basic compliant examples including:
  - Compliant nested markdown blocks
  - Nested markdown with code blocks inside
  - Multiple fence lengths (4 and 5 backticks)
  - Both `markdown` and `md` language identifiers

- **test-recursive-nested-markdown.md**: Recursive nesting examples including:
  - Two levels of nesting (markdown inside markdown)
  - Three levels of nesting (markdown inside markdown inside markdown)
  - Multiple nested blocks at the same level
  - Complex nesting with code blocks

- **test-violations-recursive.md**: Demonstrates violation detection at various depths

### 5. Documentation (scripts/README.md)

Added documentation for the new script including:

- Usage instructions
- How it works
- Configuration details
- Example output

### 6. Bug Fixes

Fixed a trailing spaces issue in `ToDo-MarkdownLintingUpdates.md` (MD009 violation).

## How It Works

### Parsing Process

1. The script reads each `.md` file in the repository
2. markdown-it parses the file into an Abstract Syntax Tree (AST)
3. The script **recursively** traverses the AST looking for `fence` tokens at all nesting levels
4. For each fence with `info` field matching `markdown` or `md`:
   - Extracts the content
   - Records the source file, line number, nesting depth, and parent path
   - **Recursively processes the extracted content** to find nested markdown blocks
   - Runs markdownlint on the content
   - Collects any violations

### Error Reporting

When violations are found, the output clearly shows the nesting depth and path:

```text
Nested Markdown Linting Issues:

File: samples/test-violations-recursive.md
  Code fence at line 12 [depth 1] (markdown block #2) (line 7 > block at line 12):
    1:1 MD022/blanks-around-headings Headings should be surrounded by blank lines

File: samples/test-violations-recursive.md
  Code fence at line 32 [depth 2] (markdown block #5) (line 22 > block at line 27 > block at line 32):
    1:1 MD022/blanks-around-headings Headings should be surrounded by blank lines
```

The output includes:

- **File**: Original source file
- **Line**: Line number where the code fence starts
- **Depth**: Nesting level (0 = top-level, 1 = nested once, 2 = nested twice, etc.)
- **Path**: Full nesting path showing parent block locations (e.g., "line 22 > block at line 27 > block at line 32")

### Success Output

When no violations are found:

```text
✓ No issues found in nested Markdown code fences
✓ Nested Markdown linting passed
```

## Edge Cases Handled

1. **Multiple nested Markdown blocks in one file** ✓
2. **Empty markdown code fences** ✓ (no errors reported)
3. **Markdown fences containing other code fences (powershell, bash, etc.)** ✓
4. **Files with no nested Markdown** ✓ (no errors)
5. **Different fence lengths** ✓ (markdown-it handles this automatically)
6. **Line number mapping** ✓ (tracks source file and line numbers)
7. **Both `markdown` and `md` language identifiers** ✓
8. **Recursive nested markdown** ✓ (markdown inside markdown at arbitrary depth)
9. **Multiple nested blocks at the same depth level** ✓

## Testing

Tested with:

- Files containing nested markdown: ✓ (22 blocks found across 4 files)
- Files without nested markdown: ✓ (no false positives)
- Intentionally non-compliant nested markdown: ✓ (violations detected and reported)
- Different fence lengths: ✓
- Both `markdown` and `md` identifiers: ✓
- Recursive nesting (2 and 3 levels deep): ✓
- Multiple nested blocks at same level: ✓

## Success Criteria Met

- [x] The workflow successfully extracts Markdown content from code fences
- [x] Extracted content is validated using markdownlint with repository's configuration
- [x] Violations are reported with clear context (source file, line number, block index, depth, path)
- [x] The workflow fails if violations are found
- [x] The workflow passes if no violations are found
- [x] Handles edge cases like nested fences of different lengths
- [x] Existing markdownlint functionality remains unchanged
- [x] **Supports recursive nested markdown at arbitrary depth**

## Recent Enhancements

### Recursive Nesting Support (December 2025)

Enhanced the script to support **recursive nested markdown** - markdown inside markdown at any depth level. The script now:

- Recursively extracts markdown blocks from within extracted blocks
- Tracks nesting depth (0, 1, 2, 3, etc.)
- Maintains full parent path for context (e.g., "line 22 > block at line 27 > block at line 32")
- Reports violations with depth indicators in the output

This allows the linting to work correctly with documentation that contains examples of nested markdown within nested markdown.
