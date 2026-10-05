<!-- markdownlint-disable MD013 -->
# PS232 R9 — reuse the selected inline entry guard decision

Selected no-change applicability disposition for comment4182560011 on NpmTools.mjs:147, Hf77a58d/Bf168. No new product finding, implementation or decision table is needed.

The reviewer suggests factoring the duplicated isMain fallback into a shared workflow helper to reduce future drift. Canonical [TF66 R11 H-inline98](TF66-R11-linked-cli-entry.md) considered that exact tradeoff as H-shared96. It credited the shared option's maintenance benefit (5 versus3), while accounting for additional accepted-tool/materialization closure and verification responsibilities (4 versus5). It selected inline guards, with a documented condition to reopen for a substantive new use.

Immutable current inspection finds exactly the same five-site boundary: lint-markdown, NpmTools, Check-NpmAudit, Classify-InstructionMaintenance and Validate-WorkflowPolicy. All five guard blocks are raw-identical to one another and to their accepted TF56 counterpart. Each prefers native boolean import.meta.main, including false; otherwise it safely compares canonical paths and returns false for absent/unreadable argv. No diverged behavior, sixth consumer, defect, new runtime requirement or measured maintenance incident is alleged. Removing an unused classifier import in PS did not change the guard or its trust model.

Caller limits remain relevant: NpmTools is imported and directly runs locked setup; lint-markdown runs actual outer lint; Check-NpmAudit serves local and hosted audit; the classifier remains builtin-only accepted-base code; Validate-WorkflowPolicy retains standalone pre-install operation with lazy installed-parser loading. The existing standalone policy fixture copies only the policy module, contract and manifests/locks. A new shared helper is feasible, not prohibited, but becomes another executable materialization input requiring deliberate authority/fixture coverage. Current NpmTools.test.mjs already runs five-module ordinary/alias argument errors and inert imports. Source inspection proves those controls remain; no duplicate suite is needed for an unchanged design suggestion.

Recommended controlled-English disposition:

1. Keep the five selected inline guards.
2. Link the existing H-inline98 versus H-shared96 decision.
3. Retain actual CLI/import and standalone-closure tests.
4. Reassess sharing if a new substantive consumer or drift defect changes the tradeoff.

This does not claim the inline form is universally better, or that repeated code has no maintenance cost. It applies the already scored owner choice to unchanged facts. Preserve native false precedence, exact runtime policy, existing argument/status diagnostics and the documented legacy filesystem-race/argv limitations. Forced fallback evidence remains a branch probe on the pinned runtime, not an actual older-runtime test.

No product path, dependency, metadata, test or peer delta is proposed. Root owns selection, thread reply/resolution and lifecycle. evidence.json pins each raw module/mode and common guard hash, the canonical decision hash and retained-test locations. This is bounded read-only source inspection; R6's separately frozen README repair is untouched.

Root selected this disposition at09:47Z on2026-10-05 after the applicability check. Independent staged-source review confirmed all five unchanged guards and retained closure requirements. No new rubric is needed for duplicate feedback on unchanged inputs. Native reply/resolution remains separate.
