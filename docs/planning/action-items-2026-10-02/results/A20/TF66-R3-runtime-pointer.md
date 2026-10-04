<!-- markdownlint-disable MD013 -->
# R3: direct exact-runtime instructions to the actual version authority

Status: selected D98.4 before implementation. The four-document private repair is released under the retained owner authority; all existing policy and capacity limits remain.

## 1. Validated finding and root cause

[Codex comment 4178502051](https://github.com/franklesniak/TerraformStyleGuide/pull/66#discussion_r4178502051) identifies AGENTS.md line 58 on H `e2f0652654ef0954e17fc3a255b87375908d0521`. The instruction says, “Use exact Node/npm from” and links `.github/workflows/ci-toolchain.json`. That object contains only `linuxX64Sha256`; it supplies neither version. Root `package.json.engines` declares Node 24.18.1 and npm 11.16.0, consistent with `packageManager: npm@11.16.0`. This is an actionable navigation error: a contributor cannot obtain the required versions from the linked object.

The same incorrect sentence occurs in CLAUDE.md line 59. `.github/workflows/scripts-README.md` line 36 also calls `ci-toolchain.json` the runtime declaration. `docs/dependency-maintenance.md` already directs contributors to root package.json for versions; it is the appropriate existing location to distinguish the CI archive digest. The root cause is stale documentation after separation of the version declaration and Linux archive integrity pin, not divergent runtime implementations.

The bounded census [reference-census.json](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/reference-census.json) records 78 textual matches across the 78 frozen files. Initialize-CiToolchain.ps1 reads the digest object at line 42 and root manifest engines at lines 44–45, constructs the download from that Node version, and verifies the pinned digest. NpmTools.mjs gates exact Node and bundled npm; the outer and staged lint adapters and Husky hook read the root engine declaration. Other ci-toolchain references identify a file for classification, validation, fixtures or history; they do not all assert that it contains versions. No runtime declaration or reader change is required. Immutable blobs, modes and SHA-256 identities are retained in [source-identities.json](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/source-identities.json).

## 2. Stakeholders and hard constraints

New contributors need one direct, correct path to both required versions before setup. Maintainers need one existing version authority and a clear integrity-pin update location. Instruction consumers need identical accurate directions in AGENTS and CLAUDE. Security and review owners need exact-version requirements and archive verification preserved. Governance owners need the protected byte limits, every operative rule, actual published baseline, and metadata roles retained. Future updaters need descriptions that remain true when version values change.

An admissible solution preserves the exact-version requirement and existing bootstrap commands; creates no second version authority; does not change runtime behavior to fit incorrect prose; fits current document limits without removing policy; and uses actual B/H metadata semantics. Correct all coupled false user-facing pointers. Adding explanatory text to protected documents is not necessary when the existing dependency guide can hold it.

## 3. Relevant options and combinations

- **N — Keep the present instructions.** Accept the wrong target and rely on readers to discover package.json. This leaves the validated finding unresolved.
- **L — Fix only the reported AGENTS pointer.** Direct AGENTS readers to package.json engines; leave CLAUDE and scripts-README inconsistent.
- **C — Fix both protected pointers only.** Correct AGENTS and CLAUDE but leave the false scripts-directory runtime declaration. The dependency guide continues to omit the digest distinction.
- **D — Coordinate both direct pointers and the two existing supporting descriptions.** Link root package.json engines from AGENTS and CLAUDE; distinguish versions from the archive digest in scripts-README; add one concise digest sentence to the existing dependency guide. Do not duplicate literal versions. This is the recommended combination.
- **S — Centralize all runtime directions in the dependency guide.** Link AGENTS, CLAUDE and scripts-README to the guide, which links package.json engines and the digest. This is accurate and maintainable but adds navigation for a basic prerequisite and moves the direct version instruction behind another document.
- **P — Inline the current version numbers in instructions and describe the digest separately.** This improves immediate visibility but duplicates values already validated in the root manifest and creates future drift opportunities across documents.
- **M — Move or duplicate version declarations into ci-toolchain.json and change consumers.** Make the existing links true through runtime/configuration changes. This unnecessarily broadens scope, risks two authorities and changes the working bootstrap contract.
- **A — Add a full version/digest explanation to protected instructions while preserving the old wording and all policy.** This adds unnecessary protected prose, leaves an ambiguous old assertion unless replaced, and is not viable with AGENTS only nine bytes below its limit. Moving equivalent detail into the existing dependency guide is D.
- **R — Remove the exact-version instruction.** Avoid the bad link by weakening an operative requirement. This violates the retained requirement.

These cover retaining, narrowing, coordinating, centralizing, duplicating values, changing the runtime authority, adding protected detail and deleting the rule. Combining direct pointers with explanation in the existing supporting guide is D; combining central navigation with that explanation is S. Additional combinations do not resolve a distinct reader need without inheriting one of these tradeoffs.

## 4. Finding-specific weighted rubric

Use scores 0–5, with 0 unacceptable, 1 weak, 2 materially incomplete, 3 adequate with material drawbacks, 4 strong and 5 fully satisfies the criterion. Total is `sum(weight * score / 5)`. Hard constraints are eligibility conditions, not costs that a large total can waive.

| Criterion | Weight | What a score of 5 means |
| --- | ---: | --- |
| Declaration accuracy | 32 | Versions and digest point to their actual authoritative inputs; no duplicate version values or changed working runtime is needed. |
| Contributor findability | 25 | A reader reaches the exact Node/npm prerequisite directly from either instruction document with clear field and repository scope. |
| Coupled-reader consistency | 18 | Both protected readers and the scripts/dependency descriptions agree and explain the useful distinction. |
| Protected capacity and policy | 12 | Fits the current byte limits and preserves every operative rule and bootstrap command. |
| Future update maintenance | 8 | Version updates do not require synchronizing copied values or unnecessary description sites. |
| Implementation/review effort | 5 | A small, readily checked documentation change solves the issue without runtime/configuration changes. |

The first three correctness/usability criteria carry 75 points; capacity/policy carries another 12. Churn alone cannot outweigh correct instructions.

## 5. Scored table, arithmetic and selection

| Option | Accuracy 32 | Findability 25 | Consistency 18 | Capacity 12 | Maintenance 8 | Effort 5 | Total /100 | Eligibility |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 0 | 0 | 1 | 5 | 1 | 5 | 22.2 | Fails truthful-pointer constraint |
| L | 3 | 5 | 1 | 5 | 3 | 5 | 69.6 | Leaves coupled false pointers |
| C | 4 | 5 | 2 | 5 | 4 | 5 | 81.2 | Leaves scripts description false |
| D | 5 | 5 | 5 | 5 | 4 | 5 | **98.4** | Eligible; recommended |
| S | 5 | 4 | 5 | 5 | 5 | 4 | 94.0 | Eligible; extra navigation |
| P | 4 | 5 | 4 | 4 | 2 | 4 | 81.8 | Duplicates version authority in prose |
| M | 4 | 3 | 4 | 5 | 2 | 1 | 71.2 | Unnecessary runtime/configuration change |
| A | 5 | 5 | 5 | 0 | 3 | 3 | 82.8 | Violates current capacity |
| R | 0 | 1 | 2 | 5 | 3 | 5 | 34.0 | Removes operative requirement |

[score-verification.json](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/score-verification.json) computes every row and checks both finding rubrics sum to 100. D is 32 + 25 + 18 + 12 + 6.4 + 5 = 98.4. D exceeds the next eligible option S by 4.4 points because direct prerequisite lookup matters more here than saving one explanatory sentence site. No need to change a working manifest or protected policy to correct a link.

## 6. Selected controlled-English steps and exact scope

1. Replace only the incorrect runtime sentence in AGENTS.md and CLAUDE.md.
2. Use the exact sentence in [runtime-pointer-proposal-data.json](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/runtime-pointer-proposal-data.json).
3. Link root `package.json` with the relative target `package.json` in both documents.
4. In `.github/workflows/scripts-README.md`, identify root `package.json` field `engines` as the version source.
5. Use `../../package.json` as that guide's version link target.
6. Identify `ci-toolchain.json` as the Linux Node archive digest source in that guide.
7. Add the digest explanation next to the existing version directions in `docs/dependency-maintenance.md`.
8. Identify `linuxX64Sha256` and link to `../.github/workflows/ci-toolchain.json` there.
9. Keep literal version numbers out of these new directions.
10. Preserve all operative rules, setup commands, runtime readers and current limits.
11. Keep the existing 2026-10-04 metadata and `.0` revisions for comparison with actual B.
12. Validate the links, bytes and actual B/H metadata roles with the sequence below.

This follows the owner's short controlled-English intent; it does not claim formal ASD-STE100 certification. Likely product scope is exactly four documentation paths listed above. Existing D08/A20 protected-document authority and the owner's clear-winner grant cover the two instruction documents; no new permission request is needed. Root selection and implementation release still precede any edit.

Exact LF UTF-8 measurements for the single protected sentence replacement: AGENTS 32,759 → 32,746 bytes (22 bytes below 32,768); CLAUDE 83,446 → 83,433 bytes. Both save 13 bytes. No guide body, cap, default, version declaration, package file or production helper changes.

## 7. Actual published baseline and private helper proof

Actual B is `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`; H is the unaccepted PR candidate `e2f0652654ef0954e17fc3a255b87375908d0521`. B versions are AGENTS `1.7.20261001.0` and CLAUDE `1.10.20261001.0`. H and proposed directions retain `1.7.20261004.0` and `1.10.20261004.0`. Because the date tuple advanced against B, revision must be exactly zero. H does not become a published baseline merely because it was committed or reviewed.

The private probe loads the unchanged current production helper definitions and calls `Get-PublishedEndpointMetadataFailure` against the actual immutable B and H document strings. Only the proposed instruction sentence is changed in memory. For each document, all five expectations matched: H versus B accepted; proposed `.0` versus B accepted; proposed `.0` versus H rejected with exact revision-1 diagnostic; proposed `.1` versus B rejected with exact revision-0 diagnostic; proposed `.1` versus H accepted. Ten cases total. See [metadata-role-results.json](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/metadata-role-results.json) and [metadata-role-probe.json](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/metadata-role-probe.json), exit 0, with log SHA-256 `6036d86207af3fbe3ef5f31e02f46761cffc30c12a40a0e3372ce1b26525c525`. This is helper evidence, not a full validator or acceptance run.

`Get-PublishedBaselineDocumentContext` uses HEAD for an ordinary dirty local checkout. Thus editing the current H worktree and demanding its ordinary staged check would compare against H and ask for `.1`, contrary to actual B/H publication semantics. `-RequireStagedInputMatch` cannot be combined with explicit endpoint modes. ProposedPolicy requires distinct nonzero endpoints and the exact candidate checkout; it is diagnostic and cannot confer acceptance. FinalizeMetadataNow has its own B-checkout role and is not available in old accepted TF B. Do not invoke an invented accepted-B finalizer or describe candidate code as accepted authority.

Root verified the normal Husky commit runs staged/outer/nested Markdown checks; the long full pre-commit aggregate is separate. The supported planned sequence is: root validates the current-date/staged transition using the candidate checker in a clearly proposed disposable B-owned checkout containing the complete staged candidate; root makes the normal commit on H without hook bypass; root runs the final-byte aggregate on the clean new H plus explicit new-H/B ProposedPolicy. The disposable proposed-code result is not an accepted-B authority result. Root retains the actual B-owned classifier and native lifecycle. This preserves `.0` for the real published baseline without changing a validator interface or suppressing an error.

## 8. Evidence, remaining verification and limits

All reproduction scripts, command records, immutable raw input and results are in this private directory. `analyze-references.py` generated the bounded census and in-memory size proposals. Exact helper invocation and environment are retained in `metadata-role-probe.json`; pinned Node 24.18.1 and pwsh 7.6.5 were used. Neither product text nor installed dependencies were edited, and no full suite was run.

After root selects and releases implementation: check exact source-to-postimage diff and only these four documentation changes; resolve each relative link and engines/digest declaration; verify byte limits and retained operative content; run focused metadata/guard and Markdown checks on the real proposed text; then root runs the supported staged/clean candidate sequence and independent final quality. A direct helper pass does not claim full candidate, native review, paired completion or future accepted-main equality.

## Coordinator selection and execution boundary

Root read this full proposal and the actual source, verified the cited private log hashes, recomputed every weighted total, and displayed options, the distinct rubric, scores and selected instructions in that order before release. This is the canonical selected decision; the linked private proposal is retained historical evidence. One writer is released for private postimages and focused tests only. Product integration, final validation, native review and acceptance remain due.
