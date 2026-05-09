# Contributing to PSStyleGuide

Thank you for your interest in contributing to the PSStyleGuide repository! This document describes the conventions used in this project to help you place new content in the right location.

## Style guide document conventions

This repository maintains two complementary style guide documents:

### `STYLE_GUIDE.md` — Normative rules and examples

`STYLE_GUIDE.md` is the authoritative source for actionable, normative rules. It is optimized for consumption by LLM-based coding agents and for direct operational guidance.

Place the following content in `STYLE_GUIDE.md`:

- Normative rules, requirements, and prohibitions.
- Concise compliant and non-compliant examples.
- Only enough context to understand or correctly apply the rule.

### `STYLE_GUIDE_RATIONALE.md` — Rationale and explanatory material

`STYLE_GUIDE_RATIONALE.md` is an internal development file (not a consumer-facing artifact) that provides human-oriented background material.

Place the following content in `STYLE_GUIDE_RATIONALE.md`:

- Extended explanation and reasoning behind rules.
- Historical context and design discussion.
- Tradeoff analysis and other background material.

When a rule is added or changed in `STYLE_GUIDE.md`, add or update corresponding rationale in `STYLE_GUIDE_RATIONALE.md` when useful.

### Operational metadata in consumer-facing guide files

Consumer-facing guide files **may** include a concise top-of-document metadata block when the fields help humans, tooling, or LLM-based coding agents identify how to consume the document.

For `STYLE_GUIDE.md`, the allowed metadata fields are:

- `Status`
- `Owner`
- `Last Updated`
- `Scope`

Operational metadata is subject to the following constraints:

- Metadata must remain concise and operational.
- Extended explanation, history, tradeoffs, and rationale still belong in `STYLE_GUIDE_RATIONALE.md` or other contributor-facing files.
- Consumer-facing guide files still must not cross-reference other repository files (see [No-cross-referencing norm](#no-cross-referencing-norm)).
- Do not add a `Related` field or other cross-reference-oriented metadata to consumer-facing guide metadata.

## No-cross-referencing norm

Consumer-facing style guide files must not cross-reference other files in this repository, including each other. The consumer-facing files are:

- `STYLE_GUIDE.md` (source; the authoritative style guide)
- `/copilot-instructions.md` (generated from `STYLE_GUIDE.md`; distinct from `.github/copilot-instructions.md`, which provides repository-level Copilot instructions)
- `powershell.instructions.md` (generated from `STYLE_GUIDE.md` with YAML frontmatter)
- `STYLE_GUIDE_CHAT.md` (generated from `STYLE_GUIDE.md` wrapped in a code fence)
- `STYLE_GUIDE_FULL.md` (generated; merged from `STYLE_GUIDE.md` and `STYLE_GUIDE_RATIONALE.md`)

**Permitted exception:** `STYLE_GUIDE_RATIONALE.md` may cross-reference `STYLE_GUIDE.md` to help human contributors navigate between rationale and the corresponding rule. The CI build script strips these cross-references when generating consumer-facing artifacts such as `STYLE_GUIDE_FULL.md`.

## Proposing changes

When proposing a change:

1. Determine whether your content is normative (belongs in `STYLE_GUIDE.md`) or explanatory (belongs in `STYLE_GUIDE_RATIONALE.md`).
2. Keep `STYLE_GUIDE.md` concise, scannable, and optimized for instruction-following by coding agents.
3. Do not place extended rationale in `STYLE_GUIDE.md` unless it is necessary to understand or apply the rule.
4. If your change introduces or modifies a rule, consider adding corresponding rationale in `STYLE_GUIDE_RATIONALE.md`.
5. Ensure consumer-facing files do not cross-reference other files in this repository.
