# Scripts Directory

This directory contains utility scripts for the repository.

## lint-nested-markdown.js

This script extracts Markdown code blocks from Markdown files and validates them using markdownlint. It's used by the GitHub Actions workflow to ensure that nested Markdown content (inside code fences with language identifier `markdown` or `md`) follows the same linting rules as the outer Markdown files.

**This script supports recursive nesting** - it will extract and lint markdown at any depth level (markdown inside markdown inside markdown, etc.).

### Usage

```bash
npm run lint:md:nested
```

or

```bash
node scripts/lint-nested-markdown.js
```

### How It Works

1. Scans all `.md` files in the repository (excluding `node_modules`)
2. Parses each file using `markdown-it` to extract the AST
3. **Recursively** identifies code fences with language identifier `markdown` or `md` at all nesting depths
4. Runs markdownlint on each extracted block
5. Reports any violations with context (source file, line number, nesting depth, parent path)
6. Exits with error code 1 if any violations are found

### Configuration

The script uses the `.markdownlint.json` configuration file in the repository root, with one modification:

- **MD041** (first-line-heading) is disabled for nested markdown blocks, since code snippets may not start with a top-level heading

### Output Example

When issues are found in nested markdown:

```text
Nested Markdown Linting Issues:

File: samples/example.md
  Code fence at line 42 [depth 1] (markdown block #2) (line 15 > block at line 42):
    3:1 MD022/blanks-around-headings Headings should be surrounded by blank lines
```

The output shows:

- **File**: Original source file
- **Line**: Line number where the code fence starts
- **Depth**: Nesting level (0 = top-level, 1 = nested once, 2 = nested twice, etc.)
- **Path**: Full nesting path showing parent block locations

When no issues are found:

```text
✓ No issues found in nested Markdown code fences
✓ Nested Markdown linting passed
```
