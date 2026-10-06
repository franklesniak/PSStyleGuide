<!-- markdownlint-disable MD013 -->
# B99-PROVISIONAL-2: enforce every matching tracked name

**Validated coverage mismatch; propose D98.4, a revision of the mechanism.** Preserve the original filename-wide objective. Recommend one complete-name check inside the existing always-run validator, remove the redundant prospective native B99 hook, and keep the original eleven-hook aggregate. Pair this with [P1 C97.0](P1-active-hook-structure.md), which proves that the actual always-run guard is structurally active. This is a proposal before repair, not a claim that the frozen source or earlier profile passes.

## 1. Validation, root cause and precise scope

The selected regex is `(?i)(^|/)__pycache__/|\.py[cod]$`. It bans matching tracked names; no regular-file-only exception exists. The frozen hook omits `types`; the default is `['file']`. Native filtering requires the filesystem tags to satisfy that set. Thus a present matching symlink, dangling symlink or gitlink checkout directory can be excluded. The native classifier first applies `os.path.lexists`, so **`types: []` alone still omits absent checkout paths**. A no-input native skip is not complete-name enforcement. These are deterministic source facts, not new native probes. [Pinned defaults/schema](https://raw.githubusercontent.com/pre-commit/pre-commit/v4.6.2/pre_commit/clientlib.py), [pinned filtering and existence checks](https://raw.githubusercontent.com/pre-commit/pre-commit/v4.6.2/pre_commit/commands/run.py).

The canonical B99 decision requires rejection of force-added tracked matches and case-insensitive filename rejection. D98's pure inventory checks every tracked name. Existing29-case native evidence on each platform uses100644; it remains valid for those cases, not symlink/gitlink/absent-path coverage. D98 would refuse clean-tree N/A when any name matches, so no false private profile pass is alleged. Neither a current repository incident nor an end-to-end CI bypass is proved.

The current validator already provides `Read-GitTrackedPath`1415–1487: local `ls-files --cached -z`, immutable `ls-tree -r -z --name-only exactRevision`,1MiB output and10s process bound. Its decoder1330–1413 validates strict UTF-8, terminal NUL, nonempty records and duplicates before emitting paths. The target inventory is loaded at7713, before the7822 `MetadataClassificationOnly` return and the later finalization/SelfTest branches. `strValidatedInputRevision` is exact input H when supplied, otherwise the index. Accepted-B historical inventory is separately read for classification; it must not supply the artifact check. [Git index semantics](https://git-scm.com/docs/git-ls-files), [Git tree semantics](https://git-scm.com/docs/git-ls-tree).

Root's saved private Git-data characterization used Git2.55.0.windows.5 and five inert index entries across100644/100755/120000/160000, with every working-tree payload absent. The index and committed-revision commands returned byte-identical complete inventories: four original-pattern matches and `safe.py` as the near-match positive. Its [result](../feedback-native-inventory/result.json) is hash-bound in evidence. This supports the primitive's absent/mode behavior only; no candidate, hook or parser ran and no future guard passed. No replay is needed.

The inspected B981 `agent-instructions.yml`2–11 has no path filters for push/PR/PR-target. Its accepted-policy call at94 validates exact input H through `MetadataClassificationOnly` **before** the classifier's ordinary/maintenance branch; line101 invokes full ordinary validation only for ordinary inputs. The proposed early inventory guard can therefore cover compiled-name-only and maintenance inputs after genuine baseline adoption without workflow expansion. Recheck this caller on actual landed PS235/final H; old B981 does not acquire the new policy retroactively.

Scope is each tracked **superproject entry name**, including100644/100755/120000/160000 and present/absent checkout state. Do not recurse into submodule content or invent a ban on untracked ignored build outputs. A staged deletion removes a name from the target index; it should succeed if no target match remains. An unstaged deletion, skip-worktree or sparse omission does not remove the indexed name. Metadata exemptions, generated-path declarations and `.gitignore` do not exempt artifact names. Ignore policy is still required inert data at65536 bytes. Source read shows a feasible repair; fresh final-input tests remain necessary.

## 2. Stakeholders and tradeoffs

The owner, both maintainers, infrastructure/supply-chain security and auditors need the promised guarantee across Git modes and checkout state. New users need a clean tree to validate normally and a clear path-based correction for force-added or absent entries. Experienced users, agents and platform maintainers need index/revision authority, no checkout materialization and explicit suppression semantics. PowerShell maintainers can reuse an existing inventory rather than maintain two patterns; CI/release and QA need actual enforcement/activation controls and truthful aggregate labels. Dependency owners prefer no new helper/runtime. Cost/schedule stakeholders benefit from reusing exact old evidence while accepting necessary new tests. Documentation/generated-output, privacy, cloud/recovery, accessibility/localization contracts receive no change; this is not a general binary or secret scanner.

## 3. Complete distinct options and combinations

- **A:** Retain the selected default native fail hook and call the current proof sufficient. Leaves mode/existence gaps.
- **B:** Narrow the guarantee to present regular artifacts. Easier, but violates the requested filename-wide objective; ineligible here.
- **C:** Add `types: []` only. Covers native tag restrictions for existing paths, not absent entries; insufficient.
- **D:** Enforce the complete target inventory in the existing always-run validator; remove the prospective B99 native hook. Keep required ignore hygiene, the original eleven hooks and a specific corrective diagnostic. One authoritative predicate/call site.
- **E:** Keep native fail with `types: []` and add D's complete-name enforcement. Complete, but native rejection is redundant; retain revised twelve-row/D98 integration and two activation paths.
- **F:** Keep the default native fail as a partial supplementary control and add D. Complete through D only; the extra partial hook/profile must be labeled honestly.
- **G:** Replace the native fail hook with a standalone always-running scanner using a bounded complete Git inventory. Complete if qualified, but adds helper/runtime/interface closure.
- **H:** Combine G with the native `types: []` hook. Complete; redundant controls and expanded validation/profile surface.
- **I:** Add a dedicated always-running system B99 hook invoking a new inventory-only mode of the existing validator. Complete, but adds a public invocation mode, another hook and duplicated activation contracts.
- **J:** Patch/fork pre-commit or its classifier to use complete Git names, or add a custom native language. Could be complete, but dependency/fork authority and future maintenance exceed this bounded repair.
- **K:** Use ignores, manual review, a private-profile-only inventory or deferral. Useful hygiene/operational hold, not continuous product enforcement.
- **L:** Materialize all indexed paths before invoking `types: []`. Changes checkout state and still needs complete inventory; does not preserve immutable-read/no-mutation requirements.
- **M:** Force `always_run: true` on `language: fail`. Native fail always returns1; this rejects the valid no-match tree. [Pinned fail implementation](https://raw.githubusercontent.com/pre-commit/pre-commit/v4.6.2/pre_commit/languages/fail.py).

A native filename hook cannot alone remove the classifier's existence gate through config. Removing the type filter plus a sentinel path/dummy file is neither complete inventory proof nor acceptable product behavior. Factoring D into a small private function in the same script is D; configuration-driven/shared scanners are G/I with added authority. G plus D duplicates the same inventory enforcement and is weaker in maintenance than either alone. A special-mode/absence exception is B. P1 structure proof is necessary for D/E/F/I; it is not a second filename scanner. No options waive accepted-B policy or broader acceptance holds.

## 4. New correctness/usability-first rubric

Scores0–5 measure absent through complete fit; totals are judgments, not measured risk. Weights total100. **Names35** covers every target indexed/immutable matching name independent of mode, existence, exemption and ignore state. **Security26** keeps exact target authority, bounded decoding, immutable operation and active enforcement with no new trust/dependency. **Usability20** permits normal clean-tree validation and understandable corrective failure without a second command, dummy artifact or ambiguous profile. **Proof11** supports actual positive/negative modes, absent paths and enforcement-removal mutations; clean count alone is insufficient. **Coupling6** measures caller/profile/parser/dependency interfaces and drift. **Cost2** favors finite reuse, without excusing coverage loss. Hard constraints reject a narrower objective, absent-name gap, lost existing check, forced clean-tree failure, unapproved dependency or validation mutation.

## 5. Checked scores and recommended choice

| Option | Names35 | Security26 | Usability20 | Proof11 | Coupling6 | Cost2 | Total /100 | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 1 | 2 | 4 | 4 | 5 | 35.8 | Type/existence gaps |
| B | 3 | 2 | 3 | 4 | 4 | 5 | 59.0 | Violates filename-wide objective |
| C | 3 | 3 | 4 | 3 | 5 | 4 | 66.8 | Absent paths still omitted |
| D | 5 | 5 | 5 | 5 | 4 | 4 | 98.4 | Final inventory/caller integration unexecuted |
| E | 5 | 5 | 4 | 4 | 3 | 3 | 90.6 | Duplicate enforcement and twelve-row profile |
| F | 5 | 5 | 3 | 4 | 3 | 3 | 86.6 | Redundant partial native control |
| G | 5 | 5 | 4 | 4 | 2 | 2 | 89.0 | New helper/runtime interface |
| H | 5 | 5 | 3 | 3 | 1 | 1 | 81.2 | Two scanners/activation paths |
| I | 5 | 5 | 4 | 4 | 2 | 2 | 89.0 | New explicit mode and extra hook call |
| J | 5 | 3 | 3 | 2 | 2 | 1 | 69.8 | Fork/dependency change outside scope |
| K | 1 | 1 | 3 | 2 | 5 | 5 | 36.6 | No continuous enforcement |
| L | 4 | 2 | 2 | 2 | 1 | 1 | 52.4 | Mutating checkout does not prove original index |
| M | 1 | 1 | 0 | 5 | 4 | 5 | 30.0 | Rejects a valid clean tree |

**Recommend D98.4**, the unique highest score. D/E/F/G/H/I can provide complete coverage after qualification; D uses the target inventory already required by the actual ordinary caller and avoids duplicate rejection/profile machinery. Its coupling/cost scores remain4 because validation and accepted-main reconciliation are real work. A/B/C/K/L/M do not close the finding; J needs expanded authority and cannot be released in this repair. The score does not itself authorize a change to selected B99/D98: root must display/select this explicit revision.

## 6. Controlled-English proposed steps and interactions

1. Keep the frozen source and all earlier results unchanged until root selects and releases repair.
2. Keep the exact filename-wide pattern and corrective intent. Do not add a regular-file exception.
3. Use the complete `arrTrackedRepositoryPaths` for the selected target index or exact input H. Do not use accepted-B historical paths, changed-only paths or pre-commit's filtered filenames.
4. Apply one bounded name predicate immediately after the complete target inventory is read. Reject a match before the metadata/classification early return. Include the offending path and the correction in the diagnostic.
5. Do not read artifact contents or filesystem tags. Do not consult exemptions, generated-path declarations or ignore rules for permission.
6. Preserve strict decoder,1MiB/10s limits, process ownership and primary errors. Enumeration/decoding/timeout failure must fail closed. Preserve existing accepted-B/exact-H authorization rules.
7. Remove the unaccepted native B99 hook and its raw exact-body admission/mutations. Keep all eleven existing hook bodies, pins and normal activation. Keep the required bounded `.gitignore` row and both ignore rules.
8. Apply P1's finite structural check to the active `agent-instruction-contract` hook. Test its actual invocation and exact `SelfTest`/staged arguments.
9. Add source tests for the name predicate, its actual main call and complete target selection. A test of a duplicated regex does not prove enforcement.
10. Retire D98's **prospective** twelve-row native binding for this selected revision. Preserve its original preparation,47 pure controls and native history as bounded historical evidence. Use the ordinary eleven identified Passed rows, native exit0 and unchanged complete source/index/dependency guards for the revised actual aggregate. Do not relabel an old receipt.
11. Reconcile with genuine accepted PS235 main before final validation. Preserve every landed optional-input, parser, metadata and security change.

P2 removes P1's B99-specific hook target. P1 remains one necessary activation proof for the now-authoritative existing guard. The combination is **one complete-name enforcement plus one active-envelope contract**, not two scanners. No source/helper/profile/planning edit is released here. These short instructions use controlled wording; no formal ASD-STE100 dictionary certification is claimed.

## 7. Exact meaningful final validation and evidence reuse

Root should release guarded private Windows/Linux fixtures on the final integrated candidate, with qualified existing runtimes and no installs/network. Test actual main invocation, not only a helper: mixed-case `.pyc/.pyo/.pyd`, cache descendants, force-added ignored names;100644 and100755;120000 existing/dangling symlink names;160000 present directory and uninitialized/absent gitlink names; indexed absent regular names, sparse/skip-worktree names, unstaged deletion; clean source/near-match/untracked-ignored positives and staged deletion. Windows mode fixtures may use normal private index construction; do not infer native symlink availability. Verify mode/name receipts and guard equality rather than assume checkout shape. The scan must reject names even when metadata/generated exclusions mention them.

Cover both local target index and committed exact-H inventories. Keep an accepted B without a match and H with one, then the converse target transition, to detect scanning B or changed-only names. Include a prior unchanged indexed match during an unrelated staged edit. Exercise ordinary/staged validation and all five established endpoint modes; `MetadataClassificationOnly` must not return before the proposed guard. Old accepted B cannot prove a policy not yet adopted: preserve first-adoption/proposed-policy meaning, then test accepted-policy behavior only from a genuinely accepted implementation. Add a main-call-removal mutant plus case/cache/suffix weakening mutants that fail the actual enforcement oracle. Preserve existing strict decoder malformed/truncated/duplicate/oversized/timeout tests; reuse them only if helper bytes and context are unchanged.

The five concrete endpoint operations are: accepted `node .github/workflows/Classify-InstructionMaintenance.mjs REPOSITORY B H`; accepted checker `pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-AgentInstructions.ps1 -InputRevision H -PublishedBaselineRevision B`; that checker with `-FinalizeMetadataNow`; that checker with `-MetadataClassificationOnly`; and candidate checker with `-ProposedPolicy -InputRevision H -PublishedBaselineRevision B`. Bind `REPOSITORY`, actual B/H, qualified runtimes and the appropriate accepted-B/candidate-H checkout before each operation. Never substitute the source-only B981 fixture or unaccepted candidate code for accepted policy. Finalization uses the real author UTC date, not today's provisional date. These are future root-owned commands, not execution permission or passed results.

One required final `python3.12 -m pre_commit run --all-files` (qualified Windows3.12 equivalent) includes the unchanged always-run `.github/workflows/Test-AgentInstructions.ps1 -SelfTest -RequireStagedInputMatch`. Its revised eleven Passed rows prove those applicable checks; complete-name negative cases remain separate. Do not rerun29 regular-mode native probes merely to recertify a removed mechanism or claim native results for unexecuted modes. Reuse bounded-reader/ownership evidence only at exact unchanged scope. Run focused changed enforcement/structure checks, parser/PSSA, actual five B/H modes, ordinary audit, independent quality and normal review/CI on final bytes. No fresh native experiment is needed to choose between these source-derived alternatives; root may qualify the proposed repair with the above narrow controls before broader acceptance.

No tests, parser/imports, installation, candidate execution, product/Git/native/planning/state changes or counter updates occurred in this decision preparation. Source remains at the handoff hashes. PS235/final integration, CI, source/paired/service acceptance and transfer holds remain intact; A06/A03/A21/A07=2/4/6/6 of12.
