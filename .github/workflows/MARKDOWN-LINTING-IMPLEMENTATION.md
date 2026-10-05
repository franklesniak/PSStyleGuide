<!-- markdownlint-disable MD013 -->

# Markdown Linting Implementation

## Metadata

- **Status:** Active
- **Owner:** Repository Maintainers
- **Last Updated:** 2026-10-05
- **Scope:** Current outer-file and recursive nested-Markdown lint behavior. Does not define general documentation authoring rules.
- **Related:** [Workflow script index](scripts-README.md), [Markdown workflow](markdownlint.yml), [Documentation writing style](../instructions/docs.instructions.md)

## Active checks

The outer lint checks repository `.md` and `.mdc` files with [the lint configuration](.markdownlint.jsonc). The [recursive lint helper](lint-nested-markdown.js) extracts fenced blocks whose language is `markdown` or `md`. It checks nested Markdown recursively. It excludes dependency directories and reports the source path, source line, nesting depth, and parent-block path for violations.

The recursive parser handles empty fences, different fence lengths, sibling blocks, and multiple nesting levels. It disables MD041 for extracted snippets because a snippet does not need a top-level heading. It disables MD051 because example fragment links can refer to anchors outside the extracted snippet. All other configured rules remain active.

## Local validation

Use the declared Node and npm versions. Follow [dependency maintenance](../../docs/dependency-maintenance.md) to install the locked tools. Run these commands from the repository root:

```bash
node .github/workflows/NpmTools.mjs install
npm --prefix .github/workflows run lint:md
npm --prefix .github/workflows run lint:md:nested
```

The root package also provides `npm run lint:md` and `npm run lint:md:nested`. Each phase returns 0 for success, 1 for lint findings and 2 for tooling failure. The outer command runs the shared API through a child bounded to two minutes and two MiB of output. See [the script index](scripts-README.md) for its explicit configuration and input boundaries.

## Hook and CI integration

The active local hook definitions are [.pre-commit-config.yaml](../../.pre-commit-config.yaml) and [.husky/pre-commit](../../.husky/pre-commit). The pre-commit framework checks exact Git-index Markdown through [the staged helper](lint-staged-markdown.mjs). When Markdown is staged, the Husky hook checks those staged bytes first, then runs both full-worktree lint phases. A clean worktree cannot hide a staged error; a clean staged input cannot hide an unrelated full-worktree error. Do not replace an active check with a passing check from a different input.

The [Markdown workflow](markdownlint.yml) runs the two full-worktree lint phases in a separate lint job and preserves the independent workflow-policy job. This separation keeps repository-controlled lint and policy code on separate runner filesystems. [Invoke-MarkdownLint.ps1](Invoke-MarkdownLint.ps1) runs both phases and retains each native failure. Dependency versions, trusted inputs, installation, and policy checks remain defined by their live configuration and helper files.
