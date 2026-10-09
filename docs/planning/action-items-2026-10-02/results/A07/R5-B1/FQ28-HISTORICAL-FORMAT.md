<!-- markdownlint-disable MD013 -->
# FQ28: Historical-format review disposition

Codex historical-declaration comment4226341540

The asserted historical object is real. Full commit63819fd39142a946272293801bc592cb9a00e114/treeea73e4789a659ad6afe588dbc6ef2648d5bf67ce contains a132B declaration/blob48bf45ef24eb721decd234af91cfed80bc0f4d34, canonicalLF SHA38deea780451d8a92d3b4c0ce0f5e38a6c5e6882215e5c3f0edb4fc60ec49353:

    node:24.18.1
    npm:11.16.0
    linuxX64Sha256:d6c664df3f3f61458e8c277585571328522d705166723a7c7823a9253a4d15a0

Actual package engines match24.18.1/11.16.0 (packageblob6da05417d646188160941756f9daf5ab8656fb12). Both npm manifests/locks, initializer, installer, hook and staged-markdown helper exist. But immutable ls-tree confirms requirements-dev.txt and .github/workflows/Invoke-LockedPythonHook.ps1 are both absent.

The comment's regression conclusion does not follow. Both native-base workflows already start capability=full and retain it whenever a declaration is present. They require both missing Python inputs before publishing validation=full. Thus baseline6412129 also refuses the exact63819fd checkout, after its permissive JSON parse. Candidate32c rejects its three-field shape earlier, but does not turn a formerly supported complete setup into failure. The review's “previous workflow consumed its node” is true of63819fd's own historical workflow, not PR240's immediate baseline reader: baseline641 uses package engines and the flat digest.

Timeline reinforces the bounded contract. Immediate child3a2759164dbefed9e157494d854cad17f6b3da33 removed node/npm selectors and changed initializer version authority to package engines on2026-09-30. requirements-dev.txt/Invoke-LockedPythonHook.ps1 first appear in da2f1179b3764d221e7bac588ce2fb54554ecbc0 on2026-10-03, with the already flat91B declaration/blob740a7749945acbf53e9981241ea553dc1431d3c8. No evidence establishes a supported three-field/full-Python published history under the current contract.

| Actual finite capability contract | Consequence |
| --- | --- |
| Present admitted flat/schema2 declaration | Full validation; all current required Python/hook/installer inputs must be ordinary and present. |
| Declaration absent; Node24.18.0/npm11.16.0; Python lock and launcher absent | Explicit historical Node-only branch. |
| Declaration absent; Node24.18.0/24.18.1/npm11.16.0 with full required inputs | Full branch. Exact24.18.1 historical prepare command permits absent current installer only when other full inputs remain. |
| Root manifest+lock absent; declaration/Python lock/launcher absent; nested inputs present | Explicit legacy Node-only branch. |
| 63819fd: present three-field declaration, Node24.18.1, missing Python pair | Unsupported by baseline641 and32c. Not the Node-only history branch. |

Current Test-CiHelpers.test.mjs:1486-1518 and2054-2068 encode those positives and missing/partial/wrong-version/wrong-npm/legacy-declaration negatives. The “historical-flat” fixture creates the one-field declaration plus full closure, not63819fd. FQ20 explicitly preserves historical/pre-declaration/legacy behavior “where currently promised”; no all-authored-old-trees guarantee exists. Adding only the three-field reader shape would still leave63819fd refused at the full closure gate. Making it succeed would additionally create a new declared24.18.1 Node-only downgrade route, which is a separate capability/contract design, not a necessary repair to this finding.

**Disposition: refute the cited exact-checkout regression with immutable evidence.** No confirmed material defect means AGENTS step2 explicitly skips options/rubric/implementation steps3-8. No convenience deferral or new Issue is proposed. Do not extend format/capability admission merely because an old object was repository-authored. If later evidence supplies a specific supported triple-field checkout that baseline actually admits, revalidate that different input before a new decision.

Optional bounded proof, only if root wants additional native evidence: reuse the existing body fixture with exact63819fd JSON/package values and its absent Python pair. Run immutable baseline641 and immutable32c detection bodies separately. Require completed native refusal, no validation= capability and no runtime/PATH dispatch for both; preserve the earlier layout=modern line rather than claiming the output file is absent. Do not add missing Python files to manufacture a “supported historical” positive. No new controller, filter, registration or test run is proposed as a prerequisite for this static refutation.

Historical version parsing reveals no new independent admission gap: its actual node/npm strings exactly match package engines. The existing new-reader tuple terminal-$ concern is the same property as root's separate FQ27 LF work, not a second finding or score table.

Root verified the three immutable declaration/package/closure objects in native ef2a56 and the current finite capability/test branches. This refutes the cited supported-checkout regression, not a claim that every authored historical checkout succeeds. No source change or convenience deferral is selected. Public reply/resolution remains pending.

Publication checkpoint, 2026-10-09: this disposition remains applicable to PR240 commit cba3ef736167d402a3b12a764669d51034494df0 against base64121299f5db5663f08c15af606d164057c4fc20. The explicit current-head Codex response6075587082 reports no major issues. Full current-reader validation and independent local quality passed. The PR body carries the decision summary; this planning record supplies the immutable historical evidence. No new historical-format admission is proposed.
