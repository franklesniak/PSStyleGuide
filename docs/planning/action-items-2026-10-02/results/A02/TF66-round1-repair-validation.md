<!-- markdownlint-disable MD013 -->
# TF66 round1 repair validation

Current result at this checkpoint: private implementation and independent bounded review pass. Staged preflight passed. The sole full pre-commit aggregate is running. Product PR66 remains at e2f0652; the repair has not been committed, pushed, reviewed remotely or accepted.

## Exact scope and decisions

The eight-file repair implements existing [E97](../A07/recurring-lint-suite-decision.md), [R2 B97.6](../A07/TF66-R2-child-boundary.md), [R3 D98.4](../A20/TF66-R3-runtime-pointer.md), and [R5 C100](../A07/TF66-R5-config-diagnostic.md). Root displayed the ordered options, distinct rubric, scores and selected instructions before release. [R4 was disproved](../A03/TF66-curl-review-disposition.md); its command is unchanged.

Changed paths: `.github/workflows/agent-instructions.yml`, `lint-markdown.mjs`, `lint-markdown.test.mjs`, `lint-nested-markdown.js` and `scripts-README.md` within that same workflow directory; root `AGENTS.md`, root `CLAUDE.md`, and `docs/dependency-maintenance.md`. All eight are within the released fifty-path scope. The candidate has 78 tracked files and 1,910 unchanged installed dependency files.

- Product parent H: `e2f0652654ef0954e17fc3a255b87375908d0521`, tree `525147aac9804088b8b9e743a7e441a5276d59f2`.
- Actual published B: `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`.
- Accepted PS source: `f168f83b89f64b6bca9d520ddec4b58969060fb6`.
- Proposed complete tree: `099bb0f83403b6b61cfa2dafa73916b315c791d3`.
- Patch SHA-256: `4e2a783e127528362ca153dc5061c2b7cdb4ef7dcb8397364d8e9ca07bcedd86`.
- Final handoff SHA-256: `d0fbebb52c28fad6b8d014eb076e4d76394e8a2d9db583f194494b217c136190`.

Full identities, exact commands and logs are in [the private handoff](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round1-review-findings/repair/HANDOFF.md). Root independently read the complete patch and verified its postimages, original ten-test prefix, protected-only sentence replacements and all ten result/log hashes. The proposed fixture preparer then checked every candidate and dependency file against the final catalog; product remained clean and unchanged.

## Targeted verification

| Evidence | Windows | Linux | Scope |
| --- | --- | --- | --- |
| Complete lint suite before final assertion refinement | 19 pass, zero skip | 19 pass, zero skip | Original ten tests plus nine new boundary cases. |
| Final nine boundary cases | 9 pass, zero skip | 9 pass, zero skip | Real child execution and filesystem marker assertions. |
| Original adapter with final boundary cases | 6 pass, 3 fail | 6 pass, 3 fail | All three failures prove execution through a forbidden child or ancestor link. |
| Workflow caller controls | 2 pass | 2 pass | Existing push caller and live-workflow coverage. |

Only assertions within the nine new cases changed after the full nineteen-case runs. Those final nine cases were rerun on both platforms. Original ten tests and production bytes were unchanged. Do not label the earlier full-suite logs as runs of the final test bytes.

Ten metadata-role controls passed against actual B/H document values. Four-document Markdown lint passed. AGENTS is 32,746 bytes; its cap remains 32,768. Both protected sentence replacements save thirteen bytes, preserve operative content and retain Oct04 revision zero against the actual Oct01 published baseline. R5 changes one diagnostic string and adds no test that merely repeats that string.

Real Windows file links/junctions and Linux symbolic links were tested. Different-drive/UNC fixtures were not tested. Static identity/containment checks do not establish atomic execution, concurrent-writer confinement, hard-link identity or a module sandbox. Generator race residuals remain open. Fixture and log-printer setup failures retain their separate original records.

## Independent review and running full validation

[Independent bounded repair review](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-prepublication-quality-20261004/TF66-ROUND1-REPAIR-REVIEW-20261004.md) passed without a material finding. Reviewer `/root/a02_tf_prepublication_quality` checked all eight postimages, reconstructed the patch, verified all 78 source/candidate and 1,910 dependency files, inspected terminal results and reviewed security, scope and peer implications. Report SHA-256 is `ca490f6a1fad340280d6422ce78b0c019762eab4b72a8a27df66b644374e343b`; evidence SHA-256 is `b2bb029081a6798fb4f97faae4b3885fa61db9fb3981025aa12cbf8d00381a85`. This is a separate prepublication review, not later native final quality.

The proposed disposable checkout has actual B as HEAD and the complete proposed candidate staged. Its candidate checker does not become accepted-B authority. This role preserves correct published metadata semantics while running both staged preflight and the full aggregate **before** the normal product commit. This supersedes the earlier post-commit aggregate wording in the R3 proposal.

- Staged preflight: `pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-AgentInstructions.ps1 -RequireStagedInputMatch`; exit zero at 2026-10-04T17:38:47.793707Z. Log SHA-256 `9a44b1aca9035c1d913fb5d78fdda2bf43e44610a4edf0df9d589e6d1f7c4d96`.
- Full aggregate: `py -3.12 -m pre_commit run --all-files`; started 2026-10-04T17:38:47.799060Z, session90093, wrapper PID181424. It is still running at this checkpoint; no final pass is claimed.
- [Wrapper-owned record](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/round1-proposed-validation.json) and [aggregate log](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/round1-proposed-aggregate.log) contain current process evidence. Do not start another aggregate or edit that state while the wrapper owns it.

## Next action and retained gates

Collect the current aggregate. If it passes with all eleven hooks and zero skips, integrate only the eight verified postimages into the original clean e2 product. Confirm the exact candidate index tree. Make a normal commit with hooks. Run actual new-H/B proposed-policy diagnostics and the unchanged accepted-B classifier. Then publish normally, update the PR body, reply to and resolve the five reviewed threads with authenticated readbacks, and request one fresh current-input reviewer pair.

Round1 remains terminal and nonclean. Its fixed deadline is 2026-10-12T16:41:24Z; all five relevant transfer counters remain one. Fresh checks, both current-input reviews, independent final native quality, normal merge and landed acceptance remain due. Old e2 hosted passes do not validate the changed candidate. No human approval is pending now.

After TF acceptance, refresh the PS reverse-readiness map: R2/R5 add three common lint paths to the prior eleven-path map. R1 and R3 must preserve PS-specific workflow and document roles. Do not start a PS product writer or increment a reverse transfer before actual TF acceptance. A14 must reassess delivered lint behavior while retaining the separate generator race residuals.

## Publication protocol and full-guide assessment

The [bounded prepared-operation review](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-prepublication-quality-20261004/TF66-ROUND1-PREPARED-OPERATIONS-REVIEW-20261004.md) found no safety defect in the integration, actual-endpoint, normal-push, baseline and PR-body scaffolding. It preserves separate live gates and does not claim execution. Report SHA256 is `f0e5bad5ffeed50673e66a3ebfaf15fa2136cae99dcdfb1c62c9aaa06b699ce6`. Root subsequently added a fail-closed bookkeeping guard and corrected public-draft compliance as described below; no product logic or tested byte changed.

The [secondary style-guide assessment](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-prepublication-quality-20261004/TF66-ROUND1-STYLE-GUIDE-IMPACT-20261004.md) read all437 documentation-guide lines and659 YAML-guide lines. Their hashes are `d4f9f8b3f249d67a013a03d0e4611f20a1246c22237091ced8f9e4aeb31883c6` and `b009264adc0f9b488fa13ab7fdbfc23af83a3040b9b71ecb71ef3510eff73745`, unchanged in the proposed candidate. Existing guidance covers R1/R3; R2/R5 are JavaScript fixes, and R4 is a disproved claim. No secondary guide change or prompt is warranted. Root read the full report and verified SHA256 `7f9c821bc4704c6cf8aa093ec0558fbc67124a9fc44d8c1ef0cf69c3fd0beb13`.

The following execution-record correction applies before any acceptance claim:

1. AGENTS216 requires an explicit exact `@codex review` request and disallows relying on automatic review. Old round1 automatic Codex review5407227056/summary5982194609 is terminal useful feedback, with three findings, but its required manual request was not issued. Round1 remains nonclean, cannot establish acceptance and is being superseded. Do not request an obsolete e2 review merely to fill that historical step.
2. After the repaired head and final body are published, capture complete authenticated baselines. Reconcile automatic and manual requests, including any triggered by the push. Wait for pending old-input sets to become terminal. Confirm the Copilot request, then post exact `@codex review` once and record its authenticated readback. Both reviewers must pass the final current input; automatic feedback is no substitute. Preserve the original round/clock/deadline.
3. Use the available GitHub connector for inline replies and the manual Codex trigger. The authenticated connector identity is franklesniak/11204406. Missing-capability CLI fallbacks remain for PR-body updates and thread resolution. Public adjudications now end `Generated with Codex`; all five draft replies remain three lines including their decision link and footer.

[The five-line preparation note](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/round1-publication-preparation-note.md) and [structured correction](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/round1-review-protocol-reconciliation.json) retain exact evidence. This corrects mandatory execution bookkeeping and draft formatting; it changes no product policy, guide, suite input or review budget and needs no new design rubric. Do not write the live wrapper's state. Once aggregate90093 is terminal passed, first run `apply-review-protocol-reconciliation.py`, then the guarded integration/commit and actual-endpoint sequence. The integration guard refuses to proceed until this local correction is applied.
