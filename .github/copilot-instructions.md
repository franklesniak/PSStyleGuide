# Repository instructions for PSStyleGuide

This repository uses two different documentation targets:

- `STYLE_GUIDE.md` contains actionable, normative rules and examples intended for LLM-based coding agents and for direct operational guidance.
- `STYLE_GUIDE_RATIONALE.md` contains explanatory content, rationale, additional context, design discussion, and human-oriented background material. It is an internal development file, not a consumer-facing artifact.

The following root files are generated artifacts. Do not edit them by hand:

- `copilot-instructions.md` — generated from `STYLE_GUIDE.md`; distinct from this repository guidance file, `.github/copilot-instructions.md`.
- `powershell.instructions.md` — generated from `STYLE_GUIDE.md` with YAML front matter.
- `STYLE_GUIDE_CHAT.md` — generated from `STYLE_GUIDE.md` inside a code fence.
- `STYLE_GUIDE_FULL.md` — generated from `STYLE_GUIDE.md` and `STYLE_GUIDE_RATIONALE.md`.

After either source changes, run `.github/workflows/Generate-StyleGuideArtifacts.ps1`. Review the generated changes. Commit all changed outputs with the source changes in the same pull request. CI checks generated-file drift and uploads the committed outputs. CI does not commit regenerated files. See [contributor guidance](../CONTRIBUTING.md#regenerate-and-publish-the-style-guide-artifacts).

When making changes:

1. Put normative rules, requirements, prohibitions, and concise compliant/non-compliant examples in `STYLE_GUIDE.md`.
2. Put extended explanation, reasoning, historical context, tradeoff discussion, and other human-oriented explanatory material in `STYLE_GUIDE_RATIONALE.md`.
3. Do not place extended rationale in `STYLE_GUIDE.md` unless it is necessary to understand or apply the rule.
4. If a change introduces or modifies a rule in `STYLE_GUIDE.md`, add or update corresponding rationale in `STYLE_GUIDE_RATIONALE.md` when useful.
5. Keep `STYLE_GUIDE.md` concise, scannable, and optimized for instruction-following by coding agents.
6. Consumer-facing style guide files (`STYLE_GUIDE.md` and its generated derivatives: `/copilot-instructions.md`, `powershell.instructions.md`, `STYLE_GUIDE_CHAT.md`, `STYLE_GUIDE_FULL.md`) must not cross-reference other files in this repository, including each other.
7. `STYLE_GUIDE_RATIONALE.md` may cross-reference `STYLE_GUIDE.md` to help human contributors navigate between rationale and the corresponding rule. The CI build script strips these cross-references when generating consumer-facing artifacts.
