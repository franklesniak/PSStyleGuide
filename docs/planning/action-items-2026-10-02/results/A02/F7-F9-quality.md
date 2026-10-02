<!-- markdownlint-disable MD013 -->
# PR224 whole-candidate quality

Reviewer: independent worker d07, using source/diff inspection and saved results.

Whole-PR local-quality approval: no concrete blocker found in native base `48f4d8a36c8faceee12afac78aaecea0d176125d` to actual candidate commit `8b6c1da46b568cb3b44e60fc511a03ac1fc4edf0`, tree `6223b82bced692b5eb32e31bcbc5fd11447015f8`. Git inspection confirms parent `b8976a4b4c42d2c888051bbef015c45ba3daeac9`, the exact previously reviewed tree, and a clean product worktree. Remote acceptance remains conditional. This is a read-only source/diff and saved-results review; no new tests, probes, fixtures, or native mutations were executed. The earlier service-rejected review attempt is not credited.

The complete PR changes eleven paths. The latest repair changes exactly three, all mode 100644:

| Path | Blob | Raw SHA256 |
| --- | --- | --- |
| .github/workflows/Test-AgentInstructions.ps1 | de064bb640f0e83e94bb0793ad545b14a9a86402 | a7d8a76fa94c7e50002d14617a54735ddbc8e342979d7cfbbad016e3f4320b8b |
| .github/workflows/Test-AgentInstructions.SelfTest.ps1 | 2a19f13914509c31e9112b0dea7987a9d3628f06 | 5d07176a5008c7cf8184199f3fec7ac6b646c44fbacf41316aad1a266fa6646e |
| CONTRIBUTING.md | 229ad5e4b109d1d7c1d47e35d7a305dcbdc00e2b | be11dec87672aee506fa08aa44a08f667d5e193584306461421d736596054ab4 |

Complete changed-path review:

| Path (workflow paths under .github/workflows) | Assessment |
| --- | --- |
| .github/document-metadata-classification.json | Closed five-Tier2/four-generated schema2 mapping; empty future grants. Generated copies remain outside author-header parsing. |
| Classify-InstructionMaintenance.mjs | Adds manifest to maintenance selectors; classification does not authenticate permission. Exact B checkout and endpoint reading remain intact. |
| Classify-InstructionMaintenance.test.mjs | Manifest-only and case-alias maintenance controls match the added selector. |
| agent-instructions.yml | Adds fatal data-only admission before maintenance branching; accepted B code reads H data without checking H out. |
| Test-AgentInstructions.ps1 | Reviews covered bounded parser decoding, classification/initialization, metadata discovery and context, optional Version/date transitions, explicit finalization, recursive personal-memory ignore proof, and their callers. F5–F9 conclusions below apply. |
| Test-AgentInstructions.SelfTest.ps1 | Real Git endpoint/admission/finalization fixtures complement parser/schema/placement/optional-header controls. The separate-script correction preserves the intended alias assertion. |
| .gitignore | Removes root anchoring for personal CLAUDE.local.md. Validator requires the supported all-depth rule after negations and rejects unsupported nested/alias ignore inventories; public CLAUDE.md stays distinct. |
| MARKDOWN-LINTING-IMPLEMENTATION.md | Replaces dated implementation narration with live helper/configuration links and commands. Compared recursive helper behavior, MD041/MD051 exceptions, and hook/workflow responsibilities. |
| CONTRIBUTING.md | Preserves source/generated roles, no-cross-reference limits, generation/publication distinctions and accepted-base finalization. F9 improves only revision-output error ordering. |
| README.md | Presentation changes retain generated-artifact roles and preview-versus-accepted-output limitations. |
| docs/ISSUE_EVALUATION_PROMPT.md | Metadata date/scope/link wording changes retain its non-mutating prompt purpose. |

A direct protected-path diff is empty for AGENTS, CLAUDE, canonical Copilot instructions, docs/YAML instructions, and both style-guide source documents. Coupled workflow/classifier callers, existing generator/build separation, and recursive lint helper were inspected against the documentation claims. No additional dependency, token, public mode outside the described validator modes, or publication capability is introduced.

The trust-root review remains explicit: complete lowercase B/H hashes and checkout B are required; classification uses bounded regular Git-object/strict JSON reads before parser bootstrap. The closed absent-manifest initializer binds the exact native B and prior validator hash to the exact initial categories, not an arbitrary candidate mapping. Installed classification uses published exact grants/category provenance, with candidate-only grants inert. The workflow's added admission is unconditional before the maintenance result; candidate tests remain separate from accepted-code execution. Native B lacks the newly proposed guard, so proposed-code fixtures and independent inspection establish proposed behavior, not already-installed enforcement, immutable workflow provenance, or owner approval. The known A03 maintenance-authority boundary remains open outside this repair.

Metadata source review retains the actual B parent for structural/calendar and rendered-change checks. Explicit author finalization uses captured UTC; delayed ordinary checks do not manufacture a historical finalization date. Optional Version introduction/removal, retained Tier2/catalog opt-in, malformed prior intent and trusted promotion remain distinct; generated aggregates are not inferred to be optional author headers. JSON decoding preserves strings without timestamp coercion while rejecting ambiguous/bounded-invalid contexts.

Unchanged-code evidence is reused from the prior f81 whole-PR inspection, c204d80 F5 quality, and b8976a4 local reconciliation, each at its recorded immutable input. It supports the unchanged boundaries and relevant test design; their old passing aggregates, endpoint checks, and remote reviews are not passes for this tree. Current saved F7–F9 results add targeted evidence, not a substitute aggregate. No exhaustive semantic or platform certification is claimed.

F7 now recognizes case/whitespace variants of a Version-like label only in the existing top-level paragraph/header region, using invariant case-insensitive matching. The subsequent exact raw canonical syntax and placement check is unchanged. It rejects malformed intent rather than accepting alternative syntax. Saved and permanent controls cover required/optional contexts, before/after-list placement, duplicates, invalid prior metadata, and quoted/fenced/front-matter/later-section exclusions. Actual B/H current and prior-header checks are represented in `focused-final.log`.

F8 changes four extension-recognition predicates; it does not rewrite path bytes or change ordinal tracked/catalog/exemption/grant identity, sorting, F6 category provenance, or direct enumeration. Existing explicit governed-family alias rejection remains separate. Tests cover mixed/uppercase suffixes, case-distinct ordinary paths, all three manifest arrays, exact versus differently cased grants, retained category weakening rejection, and real missing/valid uppercase-runbook metadata. Saved `suffix-admission.log` additionally records the actual data-only admission variant. Broad extension coverage is not a new owner grant or permission to bypass canonical instruction-family rules.

F9 captures each native revision result as a string, checks the native exit status, and only then trims successful output. It preserves accepted-base selection, prerequisite/worktree sequence, and finalization limitations. Saved `guide-probe.log` reports the six intended missing-head/missing-base/success cases under Continue and Stop; it does not claim to exercise the unchanged worktree/finalization sequence. CONTRIBUTING remains optional no-header content.

The three canonical decisions match this scope and preserve protected contracts; their numeric option totals are arithmetically consistent. No workflow, classifier interface, manifest mapping, protected instructions, or paired-repository implementation is changed here. Prior whole-PR evidence remains limited to its identified inputs; future A21 whole-base integration still needs its own accepted-input reconciliation.

Failed evidence is not treated as success. The first focused attempt's concatenation-precedence fixture error is documented and followed by `focused-final.log` PASS. The first aggregate on tree4363284 failed because the focused harness had masked a parent-script variable dependency in the new alias assertion. The replacement differs by exactly one fixture argument: explicit `@('AGENTS.md')`. Production and guide blobs are identical. `separate-scope-probe.log` reports that exact assertion passing in separate script scope, and the replacement normal aggregate now passes.

Local evidence reconciled: `F7-F9/precommit.log` contains all ten normal hooks Passed, with independently verified SHA256 `87bdf2eb787456abc5dbdb22262cf96537d7e1281c57aeb73fd176ded449ab73`. Repair worker observed aggregate72653 terminal exit 0 at 2026-10-02T19:35:21.3724355Z. The normal commit's exact tree matches the independently inspected source, so no source review or suite rerun is needed for this reconciliation.

`F7-F9/finalization-8b6c1da.log` reports the content contract passed and author-finalization UTC date 2026-10-02 for exact B48f/H8b6c1da. `classification-8b6c1da.log` reports classification data validated for the same full endpoints. Parent reports both commands terminal exit 0 in root-owned session47653, with the D14 fixture's HEAD48f, staged tree6223b82 and no unstaged changes preserved. These are proposed-code checks bound to actual B/H data; they do not establish that native B already installs this behavior, or grant first-install, owner, maintenance, or merge authority.

Pending: fresh authenticated remote reviews for actual head8b6c1da, current CI, and immediate native head/base/body/thread/settings gate reconciliation. Neither superseded aggregate nor prior-head remote reviews satisfy those gates. This report approves local whole-PR quality and its final local evidence, not whole-PR merge acceptance.
