---
applyTo: "**/*.md,**/*.mdc"
description: "Documentation standards:  contract-first, traceable, drift-resistant Markdown."
---

<!-- markdownlint-disable MD013 -->

# Documentation Writing Style

**Version:** 1.6.20260822.0

## Metadata

- **Status:** Active
- **Owner:** Repository Maintainers
- **Last Updated:** 2026-08-22
- **Scope:** Defines documentation standards for Markdown (`**/*.md`) and Cursor Markdown rule (`**/*.mdc`) files in this repository, including specs, design docs, runbooks, ADRs, instruction files, and developer documentation. Does not cover code comments or inline documentation in source files.
- **Related:** [Repository Copilot Instructions](../copilot-instructions.md)

## Purpose and Scope

Documentation in this repository is treated as a **first-class engineering artifact**, not an afterthought.  Docs are expected to function as:

- A **contract** (what the system does, does not do, and why)
- A **design record** (how it works, constraints, trade-offs, failure modes)
- A **maintenance tool** (how to safely change and operate it without regressions)

This file governs all Markdown (`**/*.md`) and Cursor Markdown rule (`**/*.mdc`) documentation in this repository, including `README.md`, `docs/**`, ADRs, runbooks, release notes, instruction files under `.github/instructions/`, and Cursor project rules under `.cursor/rules/`.

## Core Principles

- **Contract-first:** State behavior precisely.  Prefer normative language:  **MUST**, **SHOULD**, **MAY**, **MUST NOT**, **SHOULD NOT**.
- **Deterministic and explicit:** Avoid vague words like "simple," "fast," "robust," "soon," "etc." Replace with measurable claims or concrete boundaries.
- **Traceable:** Requirements, design decisions, and implementation details must connect via stable identifiers and links.
- **Drift-resistant:** Docs evolve with code; no "document later" in canonical docs.
- **Explain "why," not just "what":** Capture rationale and trade-offs so future changes can be made safely.

## Documentation Taxonomy

- **Normative PowerShell style:** `STYLE_GUIDE.md` (required rules and examples)
- **PowerShell style rationale:** `STYLE_GUIDE_RATIONALE.md` (rationale and trade-offs)
- **Developer documentation:** `docs/` (how to build, test, extend, and operate)
- **Decision records:** `docs/decisions/` (durable repository decisions)

If you introduce a new **top-level documentation category** (a bucket that represents a distinct kind of document), it MUST be added to this taxonomy section. Purely **organizational subdirectories under an existing category** (for example, grouping related developer docs under `docs/<topic>/`) are a filing convention, MUST NOT be treated as new top-level categories, and MUST NOT trigger an update to this section. When in doubt, prefer treating a new directory as a subdirectory of an existing category unless it represents a fundamentally different kind of document.

This taxonomy is specific to PSStyleGuide and MUST be updated when the repository's documentation ownership or tracked structure changes.

## Canonical Source of Truth

`STYLE_GUIDE.md` is the authoritative source for normative PowerShell style requirements. `STYLE_GUIDE_RATIONALE.md` owns the rationale and trade-offs for those requirements and MUST remain aligned with the normative guide. Developer documentation under `docs/` and durable decisions under `docs/decisions/` MUST link to these sources rather than redefine conflicting PowerShell style requirements.

## Metadata Header Block Policy (Tiered by Audience)

This repository classifies documents into two tiers based on their primary audience and content type. The tier determines whether a visible metadata header block is required.

### Tier 1 — Required

The metadata header block is **REQUIRED** for documents whose primary purpose is governance, specification, instruction, process, runbook, or ADR-style design rationale. Tier 1 covers, for example:

- Repository-level instruction files matching `.github/instructions/*.instructions.md`. The repository's `.github/copilot-instructions.md` remains governed instruction content but is an explicit exception to the visible metadata-header requirement and MUST remain listed explicitly as `RequiresMetadata = $false` in the validator catalog.
- Root agent entry-point files such as `AGENTS.md`, `CLAUDE.md`, `GEMINI.md`, `.hermes.md`, and future equivalents.
- Cursor project rules matching `.cursor/rules/*.mdc`.
- ADR-style or formal design-decision records, regardless of where they live (`.github/`, `docs/`, or another documented ADR/design-decision location).
- Process and operational documents intended as durable repository policy, such as review guides, linting guides, testing guides, and release runbooks.
- READMEs whose content is itself authoritative repository policy, for example schema-policy READMEs, as opposed to reader-facing onboarding or starter content.
- Future project specifications, formal design docs, process docs, and runbooks.

The Tier 1 metadata header block consists of these fields:

- **Status:** Draft | Active | Deprecated **(REQUIRED)**
- **Owner:** Person or team **(REQUIRED)**
- **Last Updated:** YYYY-MM-DD **(REQUIRED)**
- **Scope:** What this doc covers (and does not cover) **(REQUIRED)**
- **Related:** Links to related docs and relevant requirement IDs / ADR IDs **(RECOMMENDED)**

`Status`, `Owner`, `Last Updated`, and `Scope` MUST be present in every Tier 1 document. `Related` SHOULD be included when useful related documents, requirement IDs, ADR IDs, or policy references exist. It MAY be omitted when no meaningful related target exists. Authors MUST NOT invent placeholder or low-value links solely to populate the field.

### Tier 2 — Not Required

The metadata header block is **NOT REQUIRED** for documents whose primary purpose is end-user onboarding, customization, community health, or shipping starter content for downstream consumers. Tier 2 documents SHOULD NOT add the metadata header block without a concrete consumer for the metadata. Tier 2 covers, for example:

- Top-level community-health files such as `README.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, and `SECURITY.md`.
- End-user onboarding, configuration, customization, and prompt/cookbook guides intended for repository consumers, whether downstream of a template or direct users of this repository.
- PR and issue templates such as `.github/pull_request_template.md` and files under `.github/ISSUE_TEMPLATE/`.
- Starter-content READMEs intended for downstream copy/paste, such as those matching `templates/**/README.md`, unless the README's content itself meets the Tier 1 content criteria above.

> **Precedence: Tier 1 wins on content.** Content classification is primary; file location and filename are secondary. A file is Tier 1 when its content is governance, specification, instruction, ADR-style, runbook, or process documentation, even when it lives under `docs/**`, `templates/**`, or is named `README.md`. Conversely, location alone does not promote a file to Tier 1 if the content is purely end-user-oriented. When location and content disagree, the audit must record the chosen tier and rationale in prose.
>
> Subdirectory READMEs that document files shipped for downstream copy/paste, for example `templates/**/README.md`, are Tier 2 by default; promote to Tier 1 only when the README's content itself meets the Tier 1 content criteria above, not by virtue of file length or being a long-lived document.
>
> Audits must cover both `.md` and `.mdc` files and must traverse hidden directories such as `.github/` and `.cursor/`. Use a command such as `find . -type d \( -name node_modules -o -name .venv -o -name .git \) -prune -o -type f \( -name '*.md' -o -name '*.mdc' \) -print` so Tier 1 files are not skipped without flooding the output with generated-directory noise (extend the `-prune` list with other generated directories such as `dist/`, `build/`, or `__pycache__/` if your working tree contains them).

Length and durability MAY inform classification when a new document does not obviously fit either tier, but length alone does not require the metadata header block. A long Tier 2 onboarding guide remains Tier 2; a short ADR remains Tier 1.

### Tier 2 Front-Matter Guidance (Optional)

Tier 2 documents MAY adopt YAML front matter later if a real tool consumes it, such as a docs site, a sync tool, or a search index. Do not introduce front matter without a concrete consumer. If adopted, fields such as `last-updated` SHOULD be generated from repository history (for example, from `git log`) where practical rather than maintained by hand.

### Placement Rules for the Tier 1 Metadata Header Block

- The block MUST appear at the document level. It MUST NOT be placed inside fenced code blocks, quoted excerpts, block quotes, or examples.
- "Top of body" means the first line after any YAML front matter, or line 1 if there is no front matter. "First 30 lines" means lines 1-30 of the body, counting every line (including blank lines and HTML comment directives such as `<!-- markdownlint-disable ... -->`).
- If a top-level `#` heading appears within the first 30 lines of the body, the block MUST be placed immediately after that heading. A single optional `**Version:** ...` line (with surrounding blank lines) MAY appear between the heading and the block; no other intervening content is permitted.
- Otherwise, the block MUST be placed immediately after any leading `<!-- markdownlint-disable ... -->` directive at the top of the body, or at the top of the body if no such directive is present.
- For documents that already use a top-level `## Metadata` section to host the bullet list, that section MUST be the first `##` section after the H1 (and the optional `**Version:** ...` line, if present), and the bullet list MUST appear inside it.
- This placement is compatible with the convention (see **Markdown Conventions** below) that Markdown files SHOULD include `<!-- markdownlint-disable MD013 -->` immediately after any YAML front matter, or at the very top of the file if there is no front matter.

### Synchronizing `Last Updated` and `Version` on Content Changes

This subsection applies to Tier 1 documents and to any other document that intentionally carries the metadata header block. The fields referenced in this subsection (`Last Updated`, and the optional `Version` line) are defined in the Tier 1 bullet list above; this subsection adds normative synchronization rules for those fields and does not redefine their semantics.

- When a commit modifies the rendered content or documentation meaning of a document that carries the metadata header block, the `Last Updated` field in that document MUST be bumped to the current UTC date in `YYYY-MM-DD` form as part of the same commit.
- If the document also carries a `**Version:** <major>.<minor>.<YYYYMMDD>.<revision>` line, the embedded `<YYYYMMDD>` segment MUST be updated in the same commit so that it matches the new `Last Updated` value.
- Revision convention for the `<revision>` segment of `**Version:**`:
  - The `<YYYYMMDD>` value MUST NOT move backward relative to the visible parent commit.
  - When a same-day commit modifies the document, `<revision>` MUST be greater than the visible parent revision. It SHOULD increment by `1` when the commit history preserves each source change (for example, `...20260502.0` → `...20260502.1`).
  - When `<YYYYMMDD>` moves to a later date in an ordinary commit, `<revision>` SHOULD reset to `0`.
  - A squash or another history-rewriting operation MAY preserve a higher terminal revision from the source history. This exception applies when the date moves forward or when multiple same-day source changes become one visible commit.
  - `<major>` and `<minor>` are out of scope for this synchronization rule and follow the document's own semantic-versioning conventions.
- Exemption for trivial mechanical changes. The bump MAY be omitted for commits that do not alter rendered content or documentation meaning, including pure file-mode changes, line-ending normalization, end-of-file newline fixes, or trailing-whitespace-only fixes produced by pre-commit hooks. The trailing-whitespace exemption MUST NOT be applied when the change removes or alters a Markdown hard line break (two or more trailing spaces, or a trailing backslash, immediately before a newline), because such whitespace is rendering-significant; in that case the change alters rendered content and the bump is required. Automated commits made by the auto-fix workflow (`.github/workflows/auto-fix-precommit.yml`) MAY omit the bump when they only apply those mechanical fixes, subject to the same hard-line-break carve-out.
- This rule applies to all documents in the repository that carry the metadata header block, including but not limited to `.github/copilot-instructions.md`, `.github/instructions/*.instructions.md`, `CLAUDE.md`, `AGENTS.md`, `GEMINI.md`, `.hermes.md`, and `.cursor/rules/*.mdc`.

### Non-Normative Historical Artifacts

A non-normative historical artifact is a Markdown file committed to preserve provenance, such as a verbatim AI-assistant prompt, transcript excerpt, quoted source excerpt, or similar historical material used to produce or review another artifact. For these files, "preserved" means content-level fidelity; repository hooks can still normalize trailing whitespace and final newlines.

- **Classification.** Treat a non-normative historical artifact as Tier 2, so the metadata header block is **NOT REQUIRED**, unless its current, non-quoted framing independently meets the Tier 1 criteria. Copied prompts, requirements language, review text, or source excerpts inside preserved historical content do not promote the file to Tier 1. Classify the file by its current purpose and framing, not by copied historical text.
- **Top-of-document label.** The file MUST carry a clear top-of-document label identifying it as a non-normative historical artifact that defines no repository requirements. The H1 itself MUST include the non-normative marker; an explanatory note alone is insufficient because a `**Version:**` line or metadata header block can separate the note from the H1. When a label format shows a placeholder such as `<topic>`, the placeholder MUST stay inside a code span or fenced block so it is not parsed as raw inline HTML.
- **Note placement.** The explanatory note MUST appear immediately after the H1, or, when the file intentionally carries the metadata header block, immediately after that block. This follows the placement model above. Markdown files SHOULD still include the repository-standard `<!-- markdownlint-disable MD013 -->` portability directive described in **Markdown Conventions**.
- **Optional metadata.** The file SHOULD NOT carry the metadata header block without a concrete consumer for that metadata, and SHOULD NOT carry a standalone `**Version:**` line unless a concrete consumer and synchronization convention are documented. When the metadata header block is intentionally present, authors MUST follow the placement and synchronization rules above, which govern any `**Version:**` line carried alongside it. A `**Version:**` line carried without the metadata header block has no `Last Updated` field to synchronize against and instead follows the documented synchronization convention recorded for that standalone line. Authors MUST NOT invent new metadata `Status` values such as `Historical`; use only the values allowed by the Tier 1 metadata policy.
- **Preserved content fencing.** Authors SHOULD preserve prompts, transcripts, and excerpts inside fenced `text` code blocks. Authors MAY use a `markdown` fence only when rendering and linting the preserved Markdown, including the repository's nested-Markdown check, is intentional. If the preserved content contains triple-backtick fences, authors MUST use a longer outer backtick fence. Authors MUST NOT switch to tilde fences because this repository's markdownlint configuration enforces backtick fences.
- **Fencing rationale.** Fenced code blocks keep preserved content from being parsed as live headings or directives. For an artifact under `docs/`, fenced code blocks also distinguish quoted `TODO:`, `TBD`, or `FIXME` examples from active normative text during manual authoring and review. Block quotes and other rendered quote forms are not equivalent because they can still read as live requirements.
- **Related sources.** The file SHOULD link to canonical repository documents or inspectable public sources it relates to when they exist, such as the specification, ADR, issue, public upstream source, or quoted source it was used to produce or review. These references MUST follow the existing reproducible-source and repository self-containment rules. Required interpretation MUST NOT depend on machine-local paths, agent session routes, private repositories, internal-only resources, or any other non-public resource.
- **Scope limit.** This classification MUST NOT be used as a carve-out for active prompt or cookbook guides, runbooks, process docs, specifications, ADRs, or reusable operator guidance. Classify those documents by their current content under the ordinary Tier 1 and Tier 2 policy.
- **Safety.** Historical provenance MUST NOT override existing safety rules. Authors MUST NOT commit secrets, credentials, private-only context, personal data that should not be published, or source material that cannot be safely or lawfully included.

Compliant label and note example:

```text
# Historical Artifact (Non-Normative): AI Review Prompt for ADR-0003

This file preserves the AI review prompt used while preparing ADR-0003. The preserved content is provenance/history only; it is not current specification, review, policy, requirements, or implementation guidance.
```

## Writing Rules

### Clarity and Structure

- Use informative headings that allow skimming.
- Prefer short paragraphs and bullet lists.
- Use tables only when they increase clarity (avoid tables for "pretty formatting").
- Every list of "things" should be complete or explicitly labeled as partial.

### Normative Language

- Use **MUST/SHOULD/MAY** for requirements and guarantees.
- Use **CAN** only for capability, not obligation.
- Label assumptions explicitly as **Assumption:** and keep them testable.
- **Scope conditional obligations.** When a normative keyword constrains an action that is itself optional, explicitly scope the obligation to when that action occurs, for example, "When a document cites sources, it MUST cite only inspectable sources." This prevents readers from misreading the requirement as mandating the optional action.
- **Cross-instruction-file normative-level alignment.** When a document restates a normative requirement that is also defined in an applicable file under `.github/instructions/*`, the document's requirement level (`MUST`, `SHOULD`, `MAY`, and their negations) MUST match the level used in the instruction file when the scope and context are the same, unless the document explicitly justifies a stricter or weaker level in prose immediately adjacent to the restatement. If the scope or context differs from the instruction file, the document SHOULD note that scope/context difference at the restatement. Implicit divergence (silently using a different level when the scope and context are the same as in the instruction file, with no adjacent justification) MUST NOT occur.
- **Intra-document normative-level consistency.** Within a single document, the normative requirement level for the same keyword, field, rule, and scope MUST be consistent across sections. If two sections appear to attach different levels to the same item, reconcile the wording or explicitly explain why the scopes differ.

### Status and Tense Consistency

When a tracked entry in an ADR, another decision or design record, a requirements table, or a similar status-bearing record carries a status indicating the described change is complete or realized (for example, `Addressed`, `Implemented`, `Resolved`, `Fixed`, `Done`, or `Completed`), the prose that summarizes that realized change MUST use present or past tense. For example, use "Section 25.7 defines ..." or "The spec requires ..." rather than future or pending phrasing such as "will define", "will require", or "does not yet ...". Future-tense phrasing and "not yet" phrasing remain acceptable only when the sentence explicitly describes genuinely pending work, future-scoped work, or future-triggered effects that have not occurred yet, including genuinely forward-looking ADR consequences. A status that records only that a decision was approved rather than realized, notably an ADR marked `Accepted` under this repository's `Proposed | Accepted | Superseded | Deprecated` lifecycle, does not by itself require present or past tense; match the tense to the actual state of the work. When a sentence must describe the pre-change state, scope it explicitly to that prior state (for example, "Before this change, ..." or "Prior to this revision, ...").

Examples:

```text
Non-compliant (future tense under a completed status):
  **Status:** Addressed. Section 25.7 will define the retry budget.

Compliant (realized change in present tense):
  **Status:** Addressed. Section 25.7 defines the retry budget.

Compliant (explicitly scoped pre-change reference):
  **Status:** Addressed. Prior to this revision, no retry budget existed; Section 25.7 defines it.
```

### Examples

- When documenting behavior, include at least one example that shows:
  - Input
  - Output
  - Explanation (why that output is correct)
- For edge cases, include at least one "failure or ambiguous input" example and the expected handling.
- When a code example intentionally uses an example-only helper function, method, type, module, or similarly non-obvious symbol (i.e., one invented for the example and not defined within the example or elsewhere in the same document), the example SHOULD orient the reader in at least one of these ways: label the symbol or example as illustrative, incomplete, or example-only (in surrounding prose, a language-appropriate comment, or a clear document-level or section-level note that applies to the example); or include a minimal declaration, signature, or definition. When the example-only symbol appears as a function call, method call, or type/constructor instantiation (for example, an undefined `do_thing(x)`, `thing.do()`, `Widget()`, or `new Widget()` expression), the example MUST do at least one of these, because calls and instantiations read as runnable code more strongly than bare values. An obvious generic local variable or parameter name with clear local meaning (such as `text`, `value`, `input`, `expected`, or `result`) does not by itself trigger this rule, and neither does a reference to a known real, documented API (for example, a standard-library API, documented third-party API, or repo-owned API referenced by the surrounding document), even when that API is not defined within the document.

### Markdown Conventions

- Use fenced code blocks with language tags.
- Avoid trailing whitespace; keep blank lines truly blank.
- Prefer relative links within the repo (e.g., `docs/decisions/0001-accept-in-repository-trust-root.md`). **Exception:** Markdown links inside `.github/ISSUE_TEMPLATE/*.yml` issue-form `value:` blocks (e.g., `bug_report.yml`), the `url:` values inside `.github/ISSUE_TEMPLATE/config.yml`'s `contact_links` entries, and links inside `.github/pull_request_template.md` MUST use absolute `https://github.com/OWNER/REPO/...` URLs — `https://github.com/OWNER/REPO/blob/HEAD/<path>` for repo-internal **file** targets and `https://github.com/OWNER/REPO/<other-path>` for non-file repo-internal targets such as the GitHub Security tab (`/security`), Discussions (`/discussions`), or Issues (`/issues`). See **Issue and PR templates** below.
- Avoid raw URLs in prose; use descriptive link text when possible.
- Markdown files in this repository SHOULD include `<!-- markdownlint-disable MD013 -->` immediately after any YAML front matter (or at the very top of the file if there is no front matter), and **before any other content**, including badges, links, the H1 heading, and any prose. A single optional blank line MAY appear between the front matter terminator (`---`) and the directive for readability; blank lines are not "content" for this rule.
  - Placement matters: markdownlint's inline `<!-- markdownlint-disable RULE -->` directive only suppresses the rule for content that follows it. Placing the directive after badges or other long lines leaves those lines unprotected when the file is processed with default markdownlint settings outside this repo.
  - This intentionally duplicates the repo-wide `"MD013": false` setting in `.github/workflows/.markdownlint.jsonc`.
  - This is a deliberate **portability convention** for cases where a file is read or processed outside this repository, for example:
    - sent to an external LLM for analysis or editing
    - viewed by a tool that applies default markdownlint settings
    - imported into another project
  - The per-file directive helps ensure the file is interpreted with the same expectation that long lines (URLs, code samples, single-line paragraphs, tables) are acceptable.
  - Per-file `<!-- markdownlint-disable RULE -->` directives MUST NOT contradict the configuration in `.github/workflows/.markdownlint.jsonc`; their purpose is portability, not local override.
  - When a contributor wants an additional rule disabled, update `.github/workflows/.markdownlint.jsonc` first. Per-file directives are only for mirroring repo-wide configuration where default enforcement would harm portability.
- Code-fence info strings MUST contain only a single language tag (e.g., `powershell`, `text`, `json`, `bash`). Do NOT embed file paths, URLs, or other metadata in the info string (for example, `powershell name=src/Foo.ps1 url=https://...#L1-L9` is not allowed). To cite the source of a code excerpt, place a line of the form ``Source: [`relative/path` (lines <start>-<end>)](relative/path#L<start>-L<end>).`` in prose immediately above the fence (for example, ``Source: [`src/Foo.ps1` (lines 1-9)](src/Foo.ps1#L1-L9).``). This keeps the language tag standard, preserves syntax highlighting across Markdown renderers, and reinforces the existing rule to avoid raw URLs in prose.

#### Reproducible source citations

When committed Markdown documentation, including analysis write-ups, research notes, review artifacts, and other durable Markdown records, cites sources or evidence, it **MUST** cite only sources another reader can inspect or reproduce from repository contents or clearly linked public references. This subsection makes the repository's self-containment requirement concrete for Markdown citations; it does not create a separate source-of-truth rule.

When citing sources or evidence, Markdown authors **MUST NOT** use machine-local or ephemeral filesystem paths outside the repository, including temporary caches, agent work directories, per-host checkout directories, or tool cache paths. Authors **MUST NOT** use internal-only session/tool routes, including agent-internal skill names, session-scoped MCP resources, local connector aliases, or other non-public helper routes, as authoritative sources or evidence. Instead, cite stable sources such as repo-relative paths to committed files, canonical public documentation, or upstream repository references, following this file's existing link conventions.

This rule applies when a path or route is used as a citation, source, or evidence reference. It does not ban legitimate path examples, command examples, repo-relative links, or environment-specific paths when those paths are the documented subject.

Where a claim rests on a local check, describe the check generically and reproducibly, for example, "local CLI help output confirmed ..." or "local validation output confirmed ...", without naming ephemeral paths or session-only tooling.

#### Fenced code blocks inside list items

When a bullet item includes a fenced code block followed by continuation prose that should render as part of the same bullet, the fence **and** the continuation prose **MUST** both be indented to the column after the bullet marker. For this repository's unordered `-` bullets, that is 2 spaces after the marker (markdownlint's MD007 default, which is not overridden in `.github/workflows/.markdownlint.jsonc`). Within this pattern, blank lines between the bullet text, fence, and continuation prose **SHOULD** remain truly blank. Mixing an unindented fence with an indented continuation paragraph **MUST NOT** occur, because CommonMark-style renderers can end the list item at the unindented fence and then treat the continuation paragraph as a disconnected block.

When no continuation prose follows the fence before the next sibling bullet or section, a fenced code block that is intended as a standalone example associated with the preceding bullet **MAY** be left at 0 indent. This preserves the existing repository convention used in standalone style-guide examples. To make the fence render as part of the bullet item, use the 2-space-indented pattern (per the MUST rule above).

MUST-compliant example:

````markdown
- Generate the local report.

  ```bash
  ./scripts/write-report.sh
  ```

  The command prints the report path after it completes.
````

MUST NOT example:

````markdown
- Generate the local report.

```bash
./scripts/write-report.sh
```

  The command prints the report path after it completes.
````

Note: A renderer can end the list item at the unindented fence and render the continuation as a separate paragraph.

#### Shell command portability

- **Scope.** Applies to fenced `bash`/`sh` shell-command examples in this repository's Markdown documentation that a reader is expected to copy and run on a Unix-like target environment (Linux, macOS, FreeBSD, WSL, or Git Bash on Windows). Applies to fenced `text` examples only when the surrounding prose clearly presents the block as copyable shell commands or a shell session, not when the block is command output, logs, diagnostics, or plain text. Applies to inline-prose backtick references only when the surrounding prose clearly presents the inline content as a copyable shell command, not when it is command output, a diagnostic fragment, or a tool-name mention. Native PowerShell examples are out of scope and SHOULD use a `powershell` fence. Examples that surrounding prose explicitly labels as GNU-only, BSD-only, Bash-only, PowerShell-only, or otherwise platform-specific are allowed.
- **Rules.**
  - For alternation in `grep`, MUST use extended regex (`grep -E "P1|P2|P3"`) or multiple `-e` patterns (`grep -e P1 -e P2 -e P3`). MUST NOT use basic-regex `\|` alternation, which is a GNU extension and is not reliably supported in BSD `grep` (the macOS default).
  - For in-place edits with `sed`, prefer the attached non-empty backup-suffix form (for example, `sed -i.bak 'SCRIPT' FILE`), which works on both GNU and BSD `sed` and produces a `.bak` backup file that surrounding prose SHOULD note so readers know to keep, delete, or `.gitignore` it. Alternatives are to pipe `sed` output to a temporary file and rename it over the original (which can drop file permissions, ownership, or extended attributes), or to explicitly state in surrounding prose that the example uses GNU `sed -i` semantics (where the suffix is optional and, when supplied, must be attached with no space) or BSD `sed -i ''` semantics (where an empty suffix is supplied as a separate argument so no backup is written; GNU `sed` would misparse the `''` as the script). The bare `sed -i` form (no suffix) and the separate-argument `sed -i ''` form are not portable across both.
  - Avoid Bash-specific syntax (`[[ ... ]]`, `(( ... ))`, `<<<` here-strings, `mapfile`/`readarray`, process substitution `<(...)`) in examples that should also run under `sh`, `dash`, or other POSIX-style shells. When Bash-specific syntax is required, the code fence MUST be `bash` (not `sh`) and surrounding prose MUST note the Bash dependency.
  - When a command is intentionally GNU-only, BSD-only, Bash-only, PowerShell-only, or otherwise platform-specific, surrounding prose MUST explicitly label it so readers know which `grep`/`sed`/shell variant is required.
  - When a shell-command example depends on a third-party CLI tool that is not part of standard installations on the target environments listed in the **Scope.** paragraph (for example, `rg`/ripgrep, `fd`/`fdfind`, `jq`, `yq`, `eza`/`exa`, `bat`, `delta`, or similar), the example MUST either document a portable fallback that uses tools available without extra installs (for example, `grep -E -R`, `find`, `awk`, `sort`, or `uniq`) or tools already established as prerequisites in the surrounding document (for example, `git grep -E` when `git` is already a documented prerequisite, since `git` itself is not a default install on every target environment listed in the **Scope.** paragraph), or explicitly label the tool dependency in surrounding prose so readers know to install it before running the example. Examples in downstream-facing setup, optional-configuration, template-update, and onboarding guides SHOULD prefer the portable form by default because adopters may be on any platform without prior tool installation.

This template ships maintainer-facing scripts, onboarding steps, and verification commands intended for cross-platform use. macOS and BSD-family defaults for `grep` and `sed` differ from GNU tools, so a command that works on a Linux CI runner can fail on a maintainer's macOS workstation. The third-party-tool guidance above applies even when an example is intended only for maintainers, because maintainers also work across macOS, Windows, WSL, Git Bash, and minimal Linux environments.

#### Issue and PR templates

This is an explicit carve-out from the "Prefer relative links" rule above. Issue forms (`.github/ISSUE_TEMPLATE/*.yml`, including `config.yml`) and the PR template (`.github/pull_request_template.md`) are not rendered from their own file paths. Three distinct failure modes apply:

- Issue-form `value:` Markdown blocks (for example, in `bug_report.yml`) are rendered at `/{owner}/{repo}/issues/new?...`. Relative paths resolve against that rendering URL, not the source file path, and reliably 404. For example, `[SECURITY.md](blob/HEAD/SECURITY.md)` resolves to `/{owner}/{repo}/issues/blob/HEAD/SECURITY.md` (404), and `[Security tab](security)` resolves to `/{owner}/{repo}/issues/security` (404).
- PR-template Markdown bodies (`.github/pull_request_template.md`) are rendered at `/{owner}/{repo}/pull/<n>`. Properly-constructed relative paths such as `../blob/HEAD/<file>` *do* resolve correctly on GitHub.com PR pages (they walk up one segment from `/pull/<n>` and land on `/{owner}/{repo}/blob/HEAD/<file>`). However, sibling-style relative forms such as `blob/HEAD/<file>` (without `../`) resolve to `/{owner}/{repo}/pull/blob/HEAD/<file>` and 404, and even working relative forms remain unreliable across non-GitHub.com renderers, GitHub Mobile, email notifications, and copied/quoted content. Requiring absolute URLs here keeps the PR template robust across all of those surfaces.
- `.github/ISSUE_TEMPLATE/config.yml`'s `contact_links` `url:` fields are **not** Markdown links — they are URL fields that GitHub validates at form-load time and rejects outright when given a relative path; only absolute URLs render in the issue chooser.

For the issue-form `value:` and PR-template cases, relative forms are additionally unreliable across non-GitHub.com renderers, GitHub Mobile, email notifications, and copied/quoted content.

- Markdown links inside `.github/ISSUE_TEMPLATE/*.yml` issue-form `value:` blocks (for example, in `bug_report.yml`) and inside `.github/pull_request_template.md`, as well as the `url:` values inside `.github/ISSUE_TEMPLATE/config.yml`'s `contact_links` entries, that point to repo-internal files (for example, `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `README.md`) **MUST** use full absolute URLs of the form `https://github.com/OWNER/REPO/blob/HEAD/<path>`. The `OWNER/REPO` placeholder follows this template's placeholder convention (see the comment block at the top of `CONTRIBUTING.md`) and is enforced by `.github/workflows/check-placeholders.yml` **if the downstream repository keeps that workflow**. The workflow is optional and may be removed once placeholders are substituted, so authors and adopters MUST NOT rely on it as an unconditional CI guardrail. The `github.com` host is the assumed default; **GHES adopters MUST replace `github.com` with their GHES host** (e.g., `github.company.com`). The host substitution is not enforced by CI today (even when `.github/workflows/check-placeholders.yml` is kept, it only validates `OWNER/REPO`), so each affected file SHOULD include a brief inline comment reminding adopters of the host substitution, mirroring the convention already used in `.github/ISSUE_TEMPLATE/config.yml`.
- Repo-internal references that are not file paths (for example, the GitHub Security tab) **MUST** likewise use absolute URLs, such as `https://github.com/OWNER/REPO/security`. The same `github.com` host assumption applies.
- Relative paths such as `../blob/HEAD/<file>`, `blob/HEAD/<file>`, `./<file>`, or bare relative refs such as `(security)` **MUST NOT** be used in those files. Rationale: in issue-form `value:` blocks rendered at `/{owner}/{repo}/issues/new?...`, a link like `[SECURITY.md](blob/HEAD/SECURITY.md)` resolves to `/{owner}/{repo}/issues/blob/HEAD/SECURITY.md` (404), and `[Security tab](security)` resolves to `/{owner}/{repo}/issues/security` (404). In `config.yml` `contact_links` `url:` fields, GitHub itself rejects relative values at form-load time because the field is parsed as a URL rather than as Markdown. In `.github/pull_request_template.md` rendered at `/{owner}/{repo}/pull/<n>`, a parent-relative form such as `[contributing guidelines](../blob/HEAD/CONTRIBUTING.md)` does resolve correctly on GitHub.com PR pages, but a sibling-relative form such as `[contributing guidelines](blob/HEAD/CONTRIBUTING.md)` resolves to `/{owner}/{repo}/pull/blob/HEAD/CONTRIBUTING.md` (404), and even working relative forms remain unreliable across non-GitHub.com renderers, GitHub Mobile, email notifications, and copied/quoted content; requiring absolute URLs avoids both pitfalls.
- Use `blob/HEAD` rather than `blob/main` so the URL works regardless of the repository's default branch name.
- This rule applies only to the files listed above. Tree-rendered Markdown such as `README.md`, `CONTRIBUTING.md`, and files under `docs/**` continue to follow the default "prefer relative links" guidance.
- The literal `https://github.com/OWNER/REPO/...` example URL is permitted to appear in didactic prose inside style-guide and design-decision files (`.github/instructions/**`, `.github/copilot-instructions.md`, and the template design-decision document under `.github/`); section [6] of `.github/workflows/check-placeholders.yml` skips those files specifically so that adopters are not forced to edit instructional/historical prose to satisfy placeholder CI. Section [6] also skips the workflow file itself (`.github/workflows/check-placeholders.yml`) to avoid self-referential matches against the literal URL embedded in its own grep patterns. The recursive scan in section [6] only enumerates `*.md`, `*.yml`, and `*.yaml` files (`find .github -type f \( -name "*.yml" -o -name "*.yaml" -o -name "*.md" \)`); other file types under `.github/` (for example, `.github/CODEOWNERS` or scripts) are not scanned by section [6] and are covered, where applicable, by other dedicated phases of the workflow rather than the recursive URL scan. Any other Markdown or YAML file under `.github/` (i.e., not `.github/instructions/**`, not `.github/copilot-instructions.md`, not the template design-decision document under `.github/`, and not `.github/workflows/check-placeholders.yml`) that contains the literal `https://github.com/OWNER/REPO` substring outside a single-line HTML comment (in Markdown) or a YAML comment line (in YAML) is treated as a live template placeholder and **MUST** be customized by adopters. (Section [6] of the placeholder workflow filters single-line HTML comments in Markdown and YAML comment lines in YAML before matching, so a single-line HTML comment such as `<!-- https://github.com/OWNER/REPO/... -->` will not by itself cause CI to fail; authors **SHOULD NOT** rely on that filter to ship live template URLs disguised as comments.)
- Retained issue-form YAML guidance SHOULD restate this rule rather than relying on this Markdown guide, so downstream repositories may remove either style guide independently without losing the guidance for retained file types.

#### Adopter-substitution `OWNER/REPO` placeholders in Markdown documentation

When maintaining this repository as a template, Markdown files that intentionally ship with unresolved `https://github.com/...` URLs for adopters to customize **MUST** use the literal `OWNER/REPO` placeholder convention. Common shapes include `https://github.com/OWNER/REPO.git`, `https://github.com/OWNER/REPO/issues`, `https://github.com/OWNER/REPO/security`, and `https://github.com/OWNER/REPO/blob/HEAD/<path>`. Authors **MUST NOT** introduce alternative live-substitution styles such as `<owner>/<repo>`, `<OWNER>/<REPO>`, or `your-org/your-repo` for those unresolved template placeholders.

This convention applies most visibly in template scaffolding files that ship with this repository — community-health files (`SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `README.md`), setup guides, optional-configuration guidance, reusable prompt guides, and any other repository-root Markdown that ships placeholder URLs for downstream substitution. A single literal placeholder form keeps the bulk find-and-replace scripts in the new-repository setup guide reliable and keeps the optional `.github/workflows/check-placeholders.yml` workflow's coverage predictable.

Downstream repositories that have adopted this template **SHOULD** replace `OWNER/REPO` with their real owner/repository name, or remove the placeholder-bearing content if it no longer applies. This is a template-placeholder convention, not a requirement that ordinary downstream documentation keep `OWNER/REPO` placeholders in its finished docs.

This is a placeholder-convention rule only. It does not require converting normal tree-rendered Markdown links to absolute GitHub URLs; repo-internal links in tree-rendered Markdown should continue to prefer relative links unless an existing carve-out (such as the **Issue and PR templates** subsection above) or a concrete rendering requirement makes an absolute URL necessary.

**Scope clarifications:**

- Didactic example text inside style-guide and design-decision files (`.github/instructions/**`, `.github/copilot-instructions.md`, and the template design-decision document under `.github/`) **MAY** use alternative placeholder forms when describing the convention rather than creating a live substitution target.
- Generic GitHub Actions references in `uses:` lines and the adjacent navigation-aid comments under `.github/workflows/` use `<owner>/<repo>` as a metasyntactic placeholder for arbitrary upstream action repositories (e.g., `actions/checkout`) and are **not** template-adopter substitutions; they are unaffected by this rule.
- Illustrative post-substitution examples in adoption-guide prose, such as `your-org/your-repo`, `your-username/your-repo`, or `YOUR-USERNAME/your-repo-name`, are values a reader might type **after** substitution and are not live unresolved template placeholders; they are unaffected by this rule.

#### Template-substitution marker boundaries and replacement surfaces

When a template-substitution marker is embedded in a structured Markdown construct, such as an HTML comment, link target, fenced code block, or table cell, authors **MUST** design the substitution boundary so the post-substitution text is syntactically and semantically meaningful when read in isolation. Authors **SHOULD** prefer replacing the whole enclosing construct, for example the entire HTML comment line, over replacing only a substring inside that construct.

Authors who add or modify a template-substitution marker **MUST** keep every surface that references the marker consistent with it. This includes any automated substitution helper or allowlist, any setup-guide snippets that perform the substitution, any manual find-and-replace instructions, and any regression tests that exercise the substitution.

For example, this marker is embedded in an HTML comment:

```markdown
<!-- TODO: Replace with your support contact address -->
```

If the substitution covers only `TODO: Replace`, the resulting comment is syntactically valid but semantically incoherent:

```markdown
<!-- Support contact configured with your support contact address -->
```

The safer boundary is the whole comment line, so the substituted result is meaningful as a standalone construct:

```markdown
<!-- Support contact configured -->
```

## Decision Record Standards

Decision records exist to prevent re-litigating decisions.

- File naming pattern: `docs/decisions/NNNN-short-title.md`
- Decision records MUST include:
  - The Tier 1 **Status**, **Owner**, **Last Updated**, and **Scope** metadata fields.
  - A separate narrative decision status or history, such as Proposed, Accepted, Superseded, or Deprecated.
  - **Context**
  - **Decision**
  - **Consequences:** positive and negative
  - **Alternatives Considered**
  - **Date:** YYYY-MM-DD

ADRs MUST be short and specific. If an ADR grows into a design doc, split it.

## Requirements Documentation Standards

> **Customize this section** for your project. The patterns below are recommendations for projects that track formal requirements.

When writing or updating requirements in specification documents:

- Each requirement SHOULD have a stable identifier (example pattern):
  - `PROJ-REQ-001`, `PROJ-REQ-002`, ...
- Each requirement MUST be phrased as a testable statement:
  - "The system MUST …"
- Each requirement MUST define required behavior, limits, defaults, and ownership without unresolved placeholder markers; see the placeholder-marker rule in [Prohibited Patterns](#prohibited-patterns).
- Each requirement entry SHOULD include:
  - **Rationale:** why it exists
  - **Acceptance Criteria:** objective checks (bullets)
  - **Priority:** P0/P1/P2 (or repo standard)
  - **Verification:** how it will be tested (unit/integration/e2e/manual)

Avoid "implementation leakage" in requirements unless the constraint is truly required (e.g., "MUST NOT store secrets at rest").

### Traceability to Implementation

For each non-trivial requirement, maintain a "Traceability" note that points to:

- An ADR (if it drove a durable decision)
- The implementation module/package path
- The primary test file(s)

This can be minimal, but it SHOULD exist for high-priority requirements.

## Design Documentation Standards

Design docs SHOULD be written to survive refactors. They describe architecture and invariants, not incidental code structure.

A design section SHOULD include:

- **Context:** problem statement and why now
- **Goals / Non-Goals:** explicit boundaries
- **Key Constraints:** security, privacy, performance, portability, cost, toolchain
- **System Overview:** components and responsibilities
- **Data Flow:** what moves where, in what format, and why
- **Interfaces and Contracts:** inputs/outputs, error semantics, validation rules
- **Failure Modes:** what can fail, detection, recovery, and user-visible behavior
- **Alternatives Considered:** at least 2 credible alternatives and why rejected
- **Open Questions:** enumerated, each with an owner or next step

Design sections SHOULD reference requirement IDs they satisfy when applicable.

## Runbook Standards

Runbooks MUST optimize for "2 a.m. usability."

- **Symptoms:** what the operator sees
- **Immediate Triage:** safe checks first
- **Diagnostics:** commands/steps with expected output patterns
- **Mitigations:** reversible actions first; call out risks explicitly
- **Escalation:** when to stop and who to contact
- **Postmortem Notes:** what to capture for later analysis

All commands in runbooks MUST be copy/paste safe and must not destroy data without an explicit warning.

Placeholder text embedded **inside a fenced shell example** MUST NOT contain shell metacharacters that the target shell would interpret. In fenced `bash` examples, runbook authors MUST NOT embed backticks or `$()` command-substitution syntax inside placeholder text, including inside double-quoted strings, because a user who pastes the command before substituting the placeholder may cause the shell to attempt command substitution instead of producing a clean unresolved-placeholder error. When a placeholder needs to refer to a command name, command output, or another identifier that benefits from monospace formatting, the inline-code reference MUST be kept in the surrounding prose, not inside the placeholder string in the code fence. When practical, runbook authors SHOULD validate shell examples in a safe context with the placeholder still present and confirm they fail as literal unresolved-placeholder errors rather than attempting unintended substitution, expansion, redirection, or command execution.

## Change Hygiene and "Definition of Done" for Docs

A change is not complete unless docs remain correct.

For any PR/commit that changes externally observable behavior, at least one of the following MUST be updated:

- spec docs (if any contract/behavior/design constraints changed)
- a design doc section (if architecture/invariants changed)
- an ADR (if a durable decision changed)
- a runbook (if operational behavior changed)
- README / developer docs (if onboarding/build/test steps changed)

Before merging, verify:

- No contradictions across docs
- Examples still match actual behavior
- Open questions are either resolved or explicitly tracked

### Mirrored Excerpts and Full-File Consistency Audits

**Background.** Mirrored excerpts that drift from their source are a recurring source of documentation inconsistency, and partial fixes that touch only reviewer-flagged lines can leave parallel copies of the same excerpt inconsistent and force repeat review rounds for the same root cause.

1. **Mirrored excerpt policy.** When a Markdown document includes a literal excerpt, whether inline or fenced, that mirrors a real load-bearing file in the repository (for example, `.pre-commit-config.yaml`, a JSON schema, a workflow YAML, or a script), the excerpt **MUST** either:
   - Be a verbatim copy of the corresponding source-of-truth lines for the included literal content, without paraphrasing or selectively rewriting copied literals; if the excerpt is intentionally partial, the surrounding prose **MUST** make that scope clear and **MUST NOT** imply the excerpt is the complete file or complete configuration, **OR**
   - Be replaced with a one-line pointer to the real file (for example, `See [.pre-commit-config.yaml](../../.pre-commit-config.yaml)` from a citing document under `.github/instructions/`; adjust the relative path so it resolves from the citing document's own location) with no inline copy of the excerpt content.

   When the verbatim-copy path is taken for a fenced or multi-line excerpt, authors SHOULD use the file's existing `Source:` citation convention from the `Markdown Conventions` section to anchor the excerpt to its source-of-truth file with a line-range link.

2. **Full-file audit on consistency fixes.** When fixing a code/doc consistency issue in a mirrored excerpt that was flagged on specific lines, the fix **MUST** audit the entire mirrored excerpt block and the affected Markdown file's other excerpts of the same source-of-truth file for all literal occurrences of the old pattern, not just the lines explicitly mentioned by the reviewer. The fix is not complete until every literal in every mirrored excerpt of the affected source-of-truth file within that Markdown file matches the source of truth.

## Prohibited Patterns

- Unresolved requirement or specification content in normative or definitional text. Prohibited markers include, but are not limited to:
  - `TODO:  document later`, `TODO`, `FIXME`, and `XXX` when used as unresolved requirement content.
  - `TBD`, `to be determined`, `(default ... to be determined)`, and other parenthetical `to be determined` defaults inside requirement clauses.
  - Bare `unspecified` or `left to the implementer` language when it leaves required behavior, limits, defaults, or ownership unresolved without an explicit `**Open Question:**`, `**Assumption:**`, measurable bound, or cross-reference.
  Replace these patterns with one of:
  - A measurable value, such as `(default 10 seconds; SHOULD be configurable)`.
  - An explicit `**Open Question:**` labeled entry.
  - An explicit `**Assumption:**` labeled entry.
  - A cross-reference to another requirement or section that defines the value.
  This rule applies to unresolved requirements/specification content only. It does not ban legitimate template-substitution placeholders, didactic examples, migration notes, or code-comment TODO examples elsewhere in the repository.
- Authors and reviewers MUST manually inspect Markdown under `docs/**` for unresolved placeholder forms, including case-insensitive `TBD`, `TODO:`, `FIXME`, `XXX`, `to be determined`, and `(default ... to be determined)`. Remediate normative occurrences with a measurable value, an explicit `**Open Question:**` entry, an explicit `**Assumption:**` entry, or a cross-reference to another requirement. Fenced examples, HTML comments, changelog history, and clearly labeled didactic examples are allowed only when context makes clear that they are not unresolved repository requirements.
- Contradictory statements between the spec and other docs
- Vague guarantees without measurable definitions
- Unowned open questions ("someone should figure out…")

## AI Authorship Expectations

When generating or editing docs:

- Prefer correctness over eloquence.
- Do not invent requirements, interfaces, or behavior.  If unknown, label as **Open Question**.
- Keep language neutral and engineering-focused; avoid marketing tone.
