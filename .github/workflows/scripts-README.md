<!-- markdownlint-disable MD013 -->
# Scripts Directory

## Metadata

- **Status:** Active
- **Owner:** Repository Maintainers
- **Last Updated:** 2026-10-03
- **Scope:** Describes the maintainer-facing outer, staged and nested Markdown lint scripts, their use, configuration, and output. It does not define repository-wide documentation policy.
- **Related:** [Nested Markdown Linting Implementation Summary](MARKDOWN-LINTING-IMPLEMENTATION.md), [Documentation Writing Style](../instructions/docs.instructions.md)

This directory contains utility scripts for the repository.

## Outer and staged Markdown

The root `npm run lint:md` command delegates to the workflow package and runs [lint-markdown.mjs](lint-markdown.mjs). The helper runs the existing `--outer` child with a two-minute deadline and a two-MiB output limit. That child uses the `markdownlint` named-string API on validated literal inputs. It includes hidden `.md`/`.mdc` files and excludes `node_modules`, `.git` and `.venv` directories. An empty discovered set succeeds explicitly. It reports file, line, column, rule and detail for lint findings and preserves native tool failure evidence.

[lint-staged-markdown.mjs](lint-staged-markdown.mjs) reads exact Git index contents. It checks outer rules through the shared library adapter, then checks recursive nested snippets. An invalid worktree does not change a clean staged input, and a clean worktree does not hide a staged error. When Markdown is staged, the Husky hook runs the staged checker first, then the full outer and full nested worktree checks. The pre-commit framework runs the staged checker directly. The native hook definitions remain [.husky/pre-commit](../../.husky/pre-commit) and [.pre-commit-config.yaml](../../.pre-commit-config.yaml).

Run the focused caller, configuration, path and hook controls with:

```text
node --test .github/workflows/lint-markdown.test.mjs
```

All wrappers return 0 for success, 1 for lint findings and 2 for tooling failure. Use the exact Node version in [package.json](../../package.json). Follow [dependency maintenance](../../docs/dependency-maintenance.md) for locked setup and audit checks.

## Python hooks

[Invoke-LockedPythonHook.ps1](Invoke-LockedPythonHook.ps1) selects Python 3.12 and runs only its allowlisted modules with `-E -P`. Follow [dependency maintenance](../../docs/dependency-maintenance.md#install-python-hooks) to install the hashed binary-only requirements closure into that interpreter. Module availability does not attest installed package bytes. The actionlint hook retains its exact reviewed Git revision.

Before running the Python hooks, verify PowerShell 7 with `pwsh -NoProfile -Command 'if ($PSVersionTable.PSVersion.Major -lt 7) { exit 1 }'`. Install the locked closure into Python 3.12 with `py -3.12 -m pip --isolated install --require-hashes --only-binary=:all: --index-url https://pypi.org/simple -r requirements-dev.txt` on Windows or `python3.12 -m pip --isolated install --require-hashes --only-binary=:all: --index-url https://pypi.org/simple -r requirements-dev.txt` on Linux. Run all configured hooks with `py -3.12 -m pre_commit run --all-files` on Windows or `python3.12 -m pre_commit run --all-files` on Linux. These install commands match the [dependency-maintenance procedure](../../docs/dependency-maintenance.md#install-python-hooks), suppress pip environment-option and user-configuration inputs, and explicitly select the primary package index. Global, interpreter-level and explicitly selected configuration files can still affect pip.

## [lint-nested-markdown.js](lint-nested-markdown.js)

This script extracts Markdown code blocks from Markdown files and validates them using markdownlint. It's used by the GitHub Actions workflow to ensure that nested Markdown content (inside code fences with language identifier `markdown` or `md`) follows the same linting rules as the outer Markdown files.

**This script supports recursive nesting** - it will extract and lint markdown at any depth level (markdown inside markdown inside markdown, etc.).

### Usage

```bash
npm run lint:md:nested
```

or

```bash
node .github/workflows/lint-nested-markdown.js
```

### How It Works

1. Scans all `.md` and `.mdc` files in the repository (excluding `node_modules`, `.git`, and `.venv` directories)
2. Parses each file using `markdown-it` to extract the AST
3. **Recursively** identifies code fences with language identifier `markdown` or `md` at all nesting depths
4. Runs markdownlint on each extracted block
5. Reports any violations with context (source file, line number, nesting depth, parent path)
6. Returns 1 for violations, 2 for tooling failure, or 0 when the applicable checks pass

### Configuration

The script uses the `.markdownlint.jsonc` (or `.markdownlint.json`) configuration file in the `.github/workflows` directory, with two modifications:

- **MD041** (first-line-heading) is disabled for nested markdown blocks, since code snippets may not start with a top-level heading
- **MD051** (link-fragments) is disabled for nested snippets, since example anchors can exist outside them

The shared config loader preserves JSONC comments and rejects malformed or missing rules. Alternate repository/CLI2 configs, ignore files and `extends` are explicitly refused. The API does not load ambient rc/environment selectors, so those inputs cannot override explicit rules. Put rule changes in the workflow rules file. See [dependency maintenance](../../docs/dependency-maintenance.md) for the exact supported boundary.

### Output Example

When issues are found in nested markdown:

```text
Nested Markdown Linting Issues:

File: CopilotAgentPrompts.md
  Code fence at line 9 (markdown block #1) (line 9):
    21:1 MD032/blanks-around-lists Lists should be surrounded by blank lines
    26:1 MD032/blanks-around-lists Lists should be surrounded by blank lines

File: samples/example.md
  Code fence at line 42 [depth 1] (markdown block #2) (line 15 > block at line 42):
    45:1 (nested line 3) MD022/blanks-around-headings Headings should be surrounded by blank lines
```

The output shows:

- **File**: Original source file
- **Line**: Actual line number in the outer file where the error occurs
- **Nested line indicator**: For nested blocks (depth > 0), shows the line within the nested content in parentheses
- **Depth**: Nesting level (0 = top-level, 1 = nested once, 2 = nested twice, etc.)
- **Path**: Full nesting path showing parent block locations

When no issues are found:

```text
✓ No issues found in nested Markdown code fences
✓ Nested Markdown linting passed
```
