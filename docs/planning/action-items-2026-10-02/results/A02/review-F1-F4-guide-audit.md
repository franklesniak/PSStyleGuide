<!-- markdownlint-disable MD013 -->
# PR224 step8 guide-impact audit: F1/F4

Bounded read-only assessment. Requested gpt-6.1-sol/medium; effective settings unavailable. No descendants, tests, native writes, repository edits or protected recommendation/authorization prompt. Parent retains final implementation/audit acceptance. F2/F3 were not reassessed because this handoff's selected scope is F1/F4.

## Result

No additional generic documentation or PowerShell guide rule is required for selected D-A02-11/F1 or D-A02-13/F4. Existing rules define the relevant contract and require accurate local helper documentation and meaningful true/false tests. One concrete in-flight F1 help correction remains; F4 implementation was not present in the inspected diff, so final conformance is pending.

F1 is a consumer repair for an existing policy. docs.instructions.md's Tier1-content precedence permits onboarding/community content to become governed content; its finalization section defines published baseline and current metadata requirements. The selected trusted-baseline exemption evidence preserves that transition without allowing candidate classifications to waive prior governance. A generic style rule about this particular validator's trusted exemption parameter would duplicate repository policy and leak implementation into the guide. The PowerShell guide already requires fully documented parameters and precise behavioral contracts, including outputs and edge cases.

Actual remaining implementation-help issue: in the worker's in-flight Test-InitialMetadataCoveragePath, .DESCRIPTION still says "Requires the accepted native prior validator identity" without qualification. The new manifest-present branch instead uses the validated trusted baseline exempt array and does not perform that SHA check. Clarify the two evidence branches and the SHA parameter's manifest-absent applicability in the existing function help. This follows PowerShell lines682â€“684 and850â€“855; it is not a reason to add another guide rule. Keep candidate declarations excluded from trusted prior proof. Final helper/caller tests and acceptance belong to the worker/parent.

F4 preserves the native CLAUDE.md line36 obligation: tracked personal memory is prohibited at every supported project scope, root personal memory stays ignored, and all personal memory stays untracked. Its canonical recursive rule is the chosen finite validator proof, not a universal new PowerShell coding standard. The root-only tracked-ignore-file boundary and conservative treatment of later negations are implementation acceptance limits; the future helper's DESCRIPTION/parameters/outputs and actionable failure diagnostic must state them. A new nested/case-alias .gitignore invalidates this proof and needs a new coverage decision. Existing full-help rules already require this explanation. Native effectiveness/public-file probes and meaningful negative controls remain necessary, as selected. No new protected root clause or generic ignore-pattern guide is recommended by this assessment.

The docs guide's Change Hygiene and definition-of-done rules remain applicable if the final repair changes a documented user-facing contract or operational procedure. Its existing content-precedence policy needs no rewrite for F1. The inspected scripts-README describes nested Markdown only; it does not promise general lower-directory Git-ignore coverage. Do not invent such a guarantee or duplicate the chosen implementation algorithm there solely to manufacture a guide change.

## Exact sources and read scope

Pinned product commit: fe3d6738d5b331f88e21bf6b9815883b3bb353b8. Pinned decision/planning commit: 50842cb57ae03cb127cafba174c33e11381653a0. All sources below have Git mode100644; SHA256 values are over raw Git blob bytes, not decoded/reencoded text.

| Source | Blob | SHA256 | Bytes / lines | Read scope |
| --- | --- | --- | --- | --- |
| .github/instructions/docs.instructions.md | 0b0c1ddc83938cfa9706418d45f619b1bfa03ffd | d44a17724478620b5b47ca4c9990a1dc9850707c2460a3117f96157b9d58978b | 46230 /437 | Full file, recovered truncated display regions in smaller numbered reads |
| powershell.instructions.md | e68999483c41c07e732772d88b2c43dd1467f367 | fd993b9658f434af7b668d18670326c19d76a0728a170465c686d628ce2597f8 | 148832 /2825 | Full file, successive numbered reads and recovered truncated160â€“235 region |
| STYLE_GUIDE.md | 21bbb515429eb5fdac47f14128a95d5fd55122aa | 331a401e3f26dbd4c497e156784c8f3e41f17bc295ec9f6a734639f2d6bb62fd | 148759 /2820 | Entire canonical raw content independently compared against the fully read generated suffix; direct canonical opening read; no omitted canonical region |
| .github/copilot-instructions.md | 62ff9fcfb1fb56dea8fd894d4d622cd3c598f875 | e8c5d01dc227dc109e412f364c2d036ad17d59d5c56be942b87b0e5a16b2be34 | 1634 /16 | Full file; canonical normative/generated ownership context |
| CLAUDE.md | 3bb0afcae09e05b6a8022d339b12721e8a1473d2 | 527069c020934a6e73774dadef98359911bee71754ac6d67ab60796ac757c591 | 82478 /436 | Contextual opening/protected/personal-memory clause plus following framework opening; not a full root-protocol audit |
| .github/workflows/scripts-README.md | 0350d4979fd5ba109ba4dbb910e1593debd0138d | b6af48d2e2d29449c7ab302dcde88cdafa30c6573b89065fcd31ab5adf25b8f2 | 3038 /77 | Full file; checked for existing operational ignore-proof claim |
| results/A02/review-F1-decision.md at planning50842cb | 19002481ffa806652f584cbc8679d90e3bba3896 | a2f8a7dff26a73937aa5531be3b86ac63d7918d3eeb97ce63e1a8c759cdefb21 | 4562 /26 | Full selected D-A02-11 decision |
| results/A02/review-F4-decision.md at planning50842cb | 7f73edfe3e733c8a5cf767cf4f948639c17a513e | 2926bbb2216fb3e52543b01a430b9bf010a7da236bb22220314842533df45280 | 5440 /27 | Full selected D-A02-13 decision |

Decision paths above are abbreviated from docs/planning/action-items-2026-10-02/results/A02. Relevant clauses: docs Tier1/Tier2/content precedence and metadata finalization; docs examples/failure handling, traceability and change hygiene; PowerShell parameter contracts, full help, private-helper boundaries, documented outputs, explicit boolean true/false tests, safe concrete paths and exact-byte identity. This audit does not reinterpret Pester-specific requirements as a mandate to replace the repository's existing self-test harness.

### Canonical normative coverage proof

.github/copilot-instructions.md identifies STYLE_GUIDE.md as authoritative; powershell.instructions.md is its generated derivative. At exactfe3d673, complete raw Git-object comparison proves powershell.instructions.md[73:] equals STYLE_GUIDE.md byte-for-byte. The only generated-only bytes are a73-byte/five-line YAML frontmatter prefix: opening `---`, `applyTo` for all .ps1 files, the PowerShell coding-standards description, closing `---`, and a blank line. Prefix SHA256:39c9d8b0b581282c069b06fb140d3a8d0a670062bb5b0963aace27188489eb08. Complete line-diff comparison independently returns only one insertion at generated lines1â€“5; there are no canonical deletions or replacements. Every canonical line1â€“2820 is generated line6â€“2825.

The prior complete generated read therefore covers every canonical normative paragraph, example and header under this proven mapping. No previously unread canonical header/delta or omitted normative region exists; the direct canonical opening was nevertheless inspected. This is full canonical content coverage through a proved exact derivative relationship, not an unsupported claim of separately rereading every canonical line. Relevant PowerShell guide line references elsewhere in this report use generated numbering; subtract5 for canonical numbering. The generator's native New-PowerShellInstructionsPayload function, lines1030â€“1088, corroborates the fixed-frontmatter-plus-complete-guide construction and was read in full for this boundary. The relationship proof needed no generator execution or tests. No-new-guide conclusion remains unchanged.

## Current implementation evidence only

Read the complete selected-path diff from fe3d673 to the PS product worktree for Test-AgentInstructions.ps1, Test-AgentInstructions.SelfTest.ps1 and document-metadata-classification.json. Snapshot showed26 changed validator lines and78 changed self-test lines, two files94insertions/10deletions; classifier unchanged. F1 adds trusted exemption parameter/branch/caller and promotion/Git-object fixtures. F4 code was not yet present. Raw current worktree hashes captured:

- Validator:45b0ff22cf3d4839a8fec56485c509c5b1a83117730dcb1a64091e7b72324653,410425bytes.
- SelfTest:6a31124098db74d060a9fca3ebaa621458d72eaf7173aa596bfe65fdce1c5cd6,47916bytes.

These mutable snapshots are not a frozen final candidate. The worker owns edits and final tests. Guide-impact result is no new guide rule; final local help accuracy and actual F4 conformance must be checked after implementation stabilizes. No full paired/current-product acceptance is claimed.
