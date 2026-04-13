# Repository instructions for PSStyleGuide

This repository uses two different documentation targets:

- `STYLE_GUIDE.md` contains actionable, normative rules and examples intended for LLM-based coding agents and for direct operational guidance.
- `STYLE_GUIDE_RATIONALE.md` contains explanatory content, rationale, additional context, design discussion, and human-oriented background material. It is an internal development file, not a consumer-facing artifact.

When making changes:

1. Put normative rules, requirements, prohibitions, and concise compliant/non-compliant examples in `STYLE_GUIDE.md`.
2. Put extended explanation, reasoning, historical context, tradeoff discussion, and other human-oriented explanatory material in `STYLE_GUIDE_RATIONALE.md`.
3. Do not place extended rationale in `STYLE_GUIDE.md` unless it is necessary to understand or apply the rule.
4. If a change introduces or modifies a rule in `STYLE_GUIDE.md`, add or update corresponding rationale in `STYLE_GUIDE_RATIONALE.md` when useful.
5. Keep `STYLE_GUIDE.md` concise, scannable, and optimized for instruction-following by coding agents.
6. Consumer-facing style guide files (`STYLE_GUIDE.md` and its generated derivatives: `copilot-instructions.md`, `powershell.instructions.md`, `STYLE_GUIDE_CHAT.md`, `STYLE_GUIDE_FULL.md`) must not cross-reference other files in this repository, including each other.
7. `STYLE_GUIDE_RATIONALE.md` may cross-reference `STYLE_GUIDE.md` to help human contributors navigate between rationale and the corresponding rule. The CI build script strips these cross-references when generating consumer-facing artifacts.
