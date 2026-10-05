<!-- markdownlint-disable MD013 -->
# Scripts Directory

## Metadata

- **Status:** Active
- **Owner:** Repository Maintainers
- **Last Updated:** 2026-10-05
- **Scope:** Describes repository-owned workflow scripts, supported local entry points, setup, and Markdown lint behavior. It does not define repository-wide documentation policy.
- **Related:** [Nested Markdown Linting Implementation Summary](MARKDOWN-LINTING-IMPLEMENTATION.md), [Documentation Writing Style](../instructions/docs.instructions.md)

This directory contains utility scripts for the repository.

## Workflow tools and helpers

This table lists the workflow tools and helpers in this directory. It excludes `*.test.mjs` suites and `Test-AgentInstructions.SelfTest.ps1`; see [the directory listing](.) for those files. Selected test commands appear below.

| Script | Purpose | Supported command |
| --- | --- | --- |
| `Check-NpmAudit.mjs` | Checks the locked dependency graphs against current npm advisories. | `node .github/workflows/Check-NpmAudit.mjs` |
| `Classify-InstructionMaintenance.mjs` | Classifies whether a change requires instruction maintenance. | Called from the accepted-base checkout by `agent-instructions.yml` with the checkout root and exact base/head revisions. It does not grant maintenance authority. |
| `Generate-StyleGuideArtifacts.ps1` | Regenerates consumer style-guide artifacts from the normative and rationale sources. | `pwsh -NoLogo -NoProfile -File .github/workflows/Generate-StyleGuideArtifacts.ps1` |
| `Get-SupplyFreezeDigest.mjs` | Optional manual diagnostic; no routine CI, update, or merge requirement. Reads `historical-supply-profile.json` for the retained historical tuple. Computes the reviewed workflow supply-freeze digest. | See [Prepare and record on Linux/x64](../../docs/P1-SUPPLY-FREEZE-v1.md#prepare-and-record-on-linuxx64); bare invocation is unsupported. |
| `Initialize-CiToolchain.ps1` | Installs the reviewed Linux Node/npm runtime and selected locked dependency trees. | Called by CI with `-WorkflowDependencies` and, for instruction jobs, `-InstructionDependencies`; requires its Linux runner environment. |
| `install-husky.mjs` | Activates the retained Git hook during setup and prepare. | Called by `NpmTools.mjs install` and the workflow package's `prepare` script; no separate routine invocation is needed. |
| `lint-markdown.mjs` | Runs the bounded outer Markdown API. | `npm run lint:md` |
| `lint-nested-markdown.js` | Recursively lints `markdown` and `md` fenced content in repository `.md` and `.mdc` files. | `npm run lint:md:nested` |
| `lint-staged-markdown.mjs` | Selects and lints outer and nested staged `.md` and `.mdc` content without replacing worktree files. | `node .github/workflows/lint-staged-markdown.mjs` |
| `Invoke-LockedPythonHook.ps1` | Selects Python 3.12 for allowlisted locked hook modules. | Called by the configured pre-commit hooks. |
| `Invoke-MarkdownLint.ps1` | Runs outer and nested Markdown checks and preserves both native results. | Called by `markdownlint.yml` after runtime setup; requires the reviewed Linux runner runtime. |
| `NpmTools.mjs` | Installs both locked dependency graphs with isolated npm configuration and activates the retained hook. | `node .github/workflows/NpmTools.mjs install` |
| `Test-AgentInstructions.ps1` | Validates governed instruction capacity, operative policy, final-state metadata, staged-input matching, and behavioral mutation controls. | `npm run test:agent-instructions` |
| `Test-CheckoutCredentials.ps1` | Verifies the anonymous checkout's origin and credential policy. | Called by CI and shared helpers after anonymous acquisition; requires the expected origin and credential-free Linux runner context. |
| `Test-StyleGuideArtifacts.ps1` | Runs the blank-line semantic child, generation and committed-artifact checks. | Called by the build workflow; requires its Linux runner environment. |
| `Test-BlankLineExamples.ps1` | Checks the published PowerShell blank-line examples and their focused mutation controls. | `pwsh -NoLogo -NoProfile -File .github/workflows/Test-BlankLineExamples.ps1` (no parameters). |
| `Test-ExactGitPathSet.ps1` | Verifies an exact raw Git path set and optional worktree/index equality. | `Test-StyleGuideArtifacts.ps1` supplies the repository root, expected paths and mode; no argument-free invocation is supported. |
| `Validate-WorkflowPolicy.mjs` | Validates workflow structure, helper interfaces, and locked parser integrity; run `node --test .github/workflows/Validate-WorkflowPolicy.test.mjs` for negative fixtures. | `node .github/workflows/Validate-WorkflowPolicy.mjs .github/workflows/build.yml .github/workflows/markdownlint.yml` |

The native required checks keep their existing names. `verify_generated_artifacts` runs deterministic generation and checks the stable result schemas and committed artifacts. `policy` validates the workflow structure, helper selection, and reviewed parser integrity. `markdownlint` runs both existing Markdown lint phases. Candidate instruction tests are separate from the accepted-base maintenance classification. Classification does not grant maintenance authority; the authenticated owner/executor review process still binds scope, current head/base/policy, candidate tests, findings, and independent final quality review.

For current manifest and lock validation before dependency installation, run `node .github/workflows/Validate-WorkflowPolicy.mjs --preflight`. After the locked workflow dependencies are installed, run `node .github/workflows/Validate-WorkflowPolicy.mjs .github/workflows/build.yml .github/workflows/markdownlint.yml`. Historical runtime-selector equality admission is retired; its old implementation remains in Git history.

The shared Linux CI helpers are `Initialize-CiToolchain.ps1`, `Test-CheckoutCredentials.ps1`, `Test-StyleGuideArtifacts.ps1`, and `Invoke-MarkdownLint.ps1`. The exact Node/npm versions are in root [package.json](../../package.json) `engines`. The Linux Node archive digest is in [ci-toolchain.json](ci-toolchain.json). Run helper behavior tests with `node --test .github/workflows/Test-CiHelpers.test.mjs .github/workflows/Test-LocalValidation.test.mjs`; Linux is required for the loader, runtime, and shell-hook cases. Run classifier tests with `node --test .github/workflows/Classify-InstructionMaintenance.test.mjs`.

Run installer and audit tests with `node --test .github/workflows/NpmTools.test.mjs .github/workflows/Check-NpmAudit.test.mjs`. See [dependency maintenance](../../docs/dependency-maintenance.md) for installation behavior, audit results and the `npm-risk-exceptions.json` record.

The instruction entry point loads `Test-AgentInstructions.SelfTest.ps1` for `-SelfTest` and preserves `-RequireStagedInputMatch` for local staged checks. It also supports the accepted-base metadata finalization and classification modes and the separate proposed-policy diagnostic. Follow [governed document finalization](../../CONTRIBUTING.md#finalize-governed-document-metadata) for exact base/head requirements; a proposed-code check does not grant accepted-policy authority.

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
