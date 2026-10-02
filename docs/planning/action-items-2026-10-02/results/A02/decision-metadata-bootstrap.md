<!-- markdownlint-disable MD013 -->
# D-A02-10: Admit a valid first governed state without rewriting published history

**Superseded by [D-A02-14](review-D-A02-14-decision.md).** The original decision below is retained as history. The governing policy permits the native direct list; the complete native consumer census supports removing this manifest-absent invalid-parent allowance and reversing the unnecessary candidate heading/date edit. F1 trusted existing-exemption promotion and F3 closed classification initialization remain separate controls.

**Validate.** The current native `docs/dependency-maintenance.md` has the required fields immediately after H1 but lacks `## Metadata`. Its candidate now has the correct heading and finalization date. The existing nonversioned transition rejects the published parent before accepting that repair. PS prior coverage never included this path; the trusted baseline has no metadata-classification manifest. Original4 requires complete current fields/placement, published-baseline-to-final evaluation and retained safety. It does not require rewriting old ordinary documents before adding a consumer. This is a migration of validation coverage, not permission for an invalid final header or for an existing governed baseline failure.

**Stakeholders.** Both maintainers, existing and new documentation authors, metadata and dependency maintainers, local/CI operators, security reviewers, auditors/history custodians, and schedule owners need repairability with truthful immutable history. Cloud operations, privacy and accessibility have no distinct surface changed by this exact validation migration.

**Options.** A: permit a first governed state only when trusted baseline lacks the manifest, prior coverage proves the path was ungoverned, candidate header is valid, and its finalization date is current. B: normalize the legacy parent in memory. C: accept all invalid parents. D: exempt the document as Tier2. E: stop until a separate metadata repair lands. F: parse arbitrary historical validator AST to infer coverage. Combinations A+B add no useful guarantee; C/D remove required checks. E repeats the same failing transition and cannot bootstrap itself. F enlarges supported historical syntax and ambiguity without an actual second baseline needing it.

**New rubric.** Governed final-state correctness 35%; trusted coverage/exemption safety 35%; repairability/history truth 20%; bounded maintenance cost 10%. Scores 1–5 are judgments. Hard constraints: no published history normalization; candidate cannot label prior governed content ungoverned; full final header and current finalization date required; existing manifest and all prior governed baseline checks remain unchanged; unknown baseline validator fails closed.

| Option | Correctness | Safety | Repairability | Cost | Total /100 | Uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| A | 5 | 5 | 5 | 4 | 98 | Requires exact trusted prior-coverage proof |
| B | 4 | 3 | 2 | 3 | 63 | Invents a normalized historical state; fails constraint |
| C | 2 | 1 | 4 | 5 | 47 | Broad suppression; fails constraints |
| D | 1 | 2 | 3 | 4 | 41 | Incorrect tier and lost final metadata check |
| E | 4 | 5 | 1 | 2 | 71 | Separate repair faces same failure |
| F | 5 | 4 | 4 | 1 | 81 | Historical syntax/coverage interpretation unproved |

**Selection.** Use A. Read the prior validator through the existing bounded trusted Git reader. Require exact SHA256 `5a61845f756be1d1bc4ddb772ffbc6c71ab525f0394d11d8c672f998a05fb4a5`, the accepted PS native validator at `48f4d8a36c8faceee12afac78aaecea0d176125d`. Its complete prior catalog is AGENTS, CLAUDE, internal Copilot, docs/yaml instruction policies, ISSUE_EVALUATION_PROMPT, STYLE_GUIDE_RATIONALE, both operational lint documents, and exact decision-record paths. Do not derive prior coverage from candidate catalog or classifications. Reject another manifest-absent validator identity rather than guess its coverage.

Apply bootstrap only to a newly discovered path outside this proved prior coverage when the trusted parent fails metadata parsing. Validate the full final document first. Treat that final state as the first governed metadata state and require the trusted finalization UTC date. Preserve a valid prior parent's normal freshness checks. Preserve every prior governed invalid-parent check even if a candidate reclassifies that path. Preserve all existing-manifest transitions and exemption expansion controls. Do not edit published bytes.

Test first valid governed state passes; invalid current header fails; stale finalization fails; existing-manifest invalid parent fails; known prior governed invalid parent fails; candidate reclassification cannot change prior coverage; mismatched prior validator hash fails. The exact catalog/hash is a bounded bootstrap compatibility guard with no per-round receipt. It stops applying after the manifest is published. Native acceptance remains pending required full tests and paired review lifecycle.
