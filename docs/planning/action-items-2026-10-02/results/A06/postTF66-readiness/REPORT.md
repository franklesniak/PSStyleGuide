<!-- markdownlint-disable MD013 -->
# A06 readiness after TF66

Read-only refresh, 2026-10-05. **Existing A06 D1=C96, D2=C97.4, D3=C96.6 and frontmatter D4=C98 remain applicable. No new material finding was established.** Published prerequisite decision D-A03-FOUNDATION-01/C98 is a separate decision; it clarifies acceptance boundaries and accepts no foundation. PS232/actual paired workflow acceptance remains pending. This report releases no implementation.

## Pinned inputs and changed assumptions

Accepted PS is `f168f83b89f64b6bca9d520ddec4b58969060fb6` / tree `c82fa2e11bfe333b9bcaf732bf12d1d9cb907380`; accepted TF is `56cb0418dcdcf71be94acc78d8963ea580b8a9e9` / tree `377d9980fdd4008e806366ca90b1ce2811c2f519`. Root supplied proposed immutable PS tree `95d5e8a1f46040c2044717e156e81638f1764bb3`. Existing HEAD `aafa9a4a41318d0cf1b61d873b321567b31ac985` has tree `e5f2aee1fbe9eb4650af69c30aa94edc914e4dcf`; it is not the staged candidate tree. Neither proposed input is accepted authority. Reads used existing raw Git objects, not index/worktree bytes; no fetch/ref/worktree operation occurred. Root subsequently reported the normal local commit `f77a58dede8f6f68b45e0d62e5b96e2fed477c58`, parent aafa, with the exact same95d5e8a tree and no source-byte change. Root reported aggregate47939 exit0/all11hooks/0skips and unchanged guards; endpoint checks7068 remain pending. This intended commit/index transition does not invalidate the immutable maps or establish PS acceptance. Native mains remain the accepted pair per root; no worker live-ref read was substituted.

Against the prior29-path readiness per repository: accepted PS has0 changes; accepted TF has12; proposed PS has4. Exact blob/mode/length/SHA256 and absences are recorded in `evidence.json`, with nine added existing caller/lock guards per lane. All observed existing entries remain100644 blobs.

TF changed paths: `Test-CiHelpers.test.mjs`, `build.yml`, `Validate-WorkflowPolicy.mjs/test`, `workflow-policy-cases.json`, `workflow-policy-contract.json`, `Classify-InstructionMaintenance.mjs/test`, `copilot-setup-steps.yml`, `devcontainer-ci.yml`, workflow `package.json`, and root `CONTRIBUTING.md`. Proposed PS changed paths: CI-helper test, workflow policy entry, classifier entry and Copilot. Paths without a prefix here are under `.github/workflows/`.

All three production generator/verifier implementations, both guide sources, four generated outputs and actual language semantic children are unchanged from prior readiness in every lane. Core identities:

| Path under .github/workflows | Accepted PS blob; proposed PS same | Accepted TF blob |
| --- | --- | --- |
| `Generate-StyleGuideArtifacts.ps1` | `a23d38c42770d7463920704e108ccd63240dc90b` | `a3e7e664e441d2e51f0b6f5709b8a010d6877e82` |
| `Test-ExactGitPathSet.ps1` | `b6ddf4f05a7f147d8e239b223dc7d5dae6bf4114` | `0a9f312d62ca753689abe05d3519cf0e64e74ea0` |
| `Test-StyleGuideArtifacts.ps1` | `18b8048aac58ed7b1d28a532a2aa413890483042` | `01b8fbd9f5dd9e34a4f0a3708f74eb8fd9336a5e` |

Current shared CI-helper test blobs are PS accepted `ed4e9ef4b5bea4967477c9b11666e90b2a8be49e`, TF accepted `6b063a8143a5737bed51c0a5282c857ffefdca95`, PS proposed `4098cd1c6d8dadd114fbd1c7a7da5b1918d9eacb`. The actual artifact-child region is byte-identical to prior readiness: PS accepted472–542/proposed473–543 SHA256 `e1a9fac3ad87f8714cca38099273f6b5ec2d67069812a13ae2db31e74caa5bee`; TF current473–557 SHA256 `90feff7e41f85f1fa866cfc7bfb21dc358439ea157d03ddb090c20db405e5e23`. Reuse the prior region evidence and preserve both semantic oracle sets. Do not replace the complete changed test file with an older snapshot.

TF now has the selected neutral v3 workflow-policy contract/finite verifier role, all-live-branch events, renamed committed publisher/step and direct-CLI main detection. Proposed PS also has changed entry-point handling. Preserve these current interfaces. Old whole-file test/policy/install receipts do not qualify the eventual A06 candidate; new locked parser/caller guards and current entry points need its affected checks. Prior generator/probe facts remain valid only at their unchanged inputs and recorded runtime limits. The old5.1 Restricted launch is still a refusal, not a pass. No generator research or suite was repeated.

## Exact release map

| Owner/batch | Exact paths and obligation |
| --- | --- |
| A06 current common implementation | `.github/workflows/Generate-StyleGuideArtifacts.ps1`, `Test-ExactGitPathSet.ps1`, `Test-StyleGuideArtifacts.ps1`, `Test-CiHelpers.test.mjs`, new `Test-StyleGuideGenerator.ps1`. Keep one composition engine/finite literal descriptors, neutral shared result schemas and fixed semantic roles. Schema producers, gate consumers and actual test stubs change atomically. No external descriptor/loader is selected. |
| Actual generated changes | Root `powershell.instructions.md` has the selected intentional one-space `applyTo` change through the generator. Regenerate/compare `copilot-instructions.md`, `STYLE_GUIDE_CHAT.md`, `STYLE_GUIDE_FULL.md`; TF counterparts include `terraform.instructions.md`. Write only the actual generator delta. Guide sources remain unchanged. Preserve selector/description values; the second generation must make no change. |
| A03 generator platform/publication integration | `.github/workflows/build.yml`, `Validate-WorkflowPolicy.mjs`, `Validate-WorkflowPolicy.test.mjs`, `workflow-policy-cases.json`. Coordinate real generator Windows5.1/7 and verified native-ext4 Linux7 qualification with fail-closed same-revision publication. Current v3 permits one Linux verifier/three steps and scalar publisher dependency; new jobs/steps/needs require these finite validator/test/case changes. Retain TF role `verify`, PS `verify_generated_artifacts`, committed publisher and least privilege. |
| A03 conditional contract | `.github/workflows/workflow-policy-contract.json` only if implementation actually changes the finite role/schema declaration. Do not change parser/action pins merely because a job is added. No automatic Markdown workflow rewrite. |
| A21 admission | `.github/workflows/Classify-InstructionMaintenance.mjs`, `Classify-InstructionMaintenance.test.mjs`. Add exactly new generator harness selector plus isolated/case-alias/mixed-addition controls. It is absent in all three inspected inputs; both new generator and future PowerShell recovery harness paths are absent. Preserve current entry detection. No engine/SelfTest/metadata-manifest rewrite follows from adding this existing-format executable. |
| A07/A03 runtime foundation | Consume selected R5/B1 anticipated eight-path readiness under its separate owners and prerequisite sequence, if needed by the actual platform setup. Do not make a partial installer/schema port in A06 or overwrite current Copilot/D9/D11/D12/D13 bodies. A07 owns initializer/metadata/Invoke-MarkdownLint/interface docs; A03 credentials/Copilot/helper-test/graph surfaces. |

Freeze each actual owned batch and conditional generated union before release; this table is finite coordination scope, not competing writer permission. Read-only guards include sources, semantic children, CONTRIBUTING, current package/locks/hooks, protected instructions and metadata classification. No protected guide/source edit is selected. Any genuinely necessary new protected path must stop for its exact authorized proposal. Actual shared helper metadata must use its accepted predecessor and genuine author UTC, with touched common metadata synchronized; this readiness preauthors no versions or dates.

Preserve PS blank-line child semantics, TF first-resolved Node/no-fallback and300000ms recovery budget, native status separate from child result status, complete four-output allowlists, raw path/identity/channel/config/worktree checks and fixed bounded diagnostic labels. C98 spacing is not a permanent exception. Keep en-US/tr-TR invariant anchors, both rationale/source representations, TF summary/standalone/recovery appendix and narrow language descriptor/output exceptions. No whole mixed-helper exception is authorized.

## Later commands and platform requirements — not executed

Use a disposable candidate checkout after root release. Bind each result to its actual immutable candidate, tool identities and filesystem. Commands below identify existing or selected future no-argument entries; they are not executions in this refresh.

```text
pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Generate-StyleGuideArtifacts.ps1
pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Generate-StyleGuideArtifacts.ps1
pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-StyleGuideGenerator.ps1
node --test .github/workflows/Test-CiHelpers.test.mjs .github/workflows/Validate-WorkflowPolicy.test.mjs .github/workflows/Classify-InstructionMaintenance.test.mjs
node .github/workflows/Validate-WorkflowPolicy.mjs .github/workflows/build.yml .github/workflows/markdownlint.yml
pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-StyleGuideArtifacts.ps1
```

Compare raw bytes/modes of all four outputs and tracked state across actual generations. Execute the new focused real-generator harness twice per required cell: actual Windows PowerShell5.1, reviewed Windows PowerShell7, and PowerShell7 on verified native ext4. Use the actual fixed reviewed PowerShell executable for each Windows edition with `-NoLogo -NoProfile -NonInteractive -File`; no execution-policy bypass, compatibility-module substitute, ambient-tool fallback or skipped-pass. Normal windows-2025 shells are the selected intended host, subject to real observed version/storage/tool proof. Existing Linux image qualification alone does not establish native-ext4 generator evidence. BSD/unknown dispatch controls remain synthetic and separately labeled.

Run actual publication/no-change, hard-link/refusal/identity, Unicode/raw UTF-8/LF/BOM, anchors/fences/marker/order, malformed result/native-exit mismatch and bounded hostile-field controls selected by D1/D2/D3. Retain actual File.Replace/File.Move evidence limits. Execute the Linux artifact gate on a clean committed candidate with the real semantic child; it already runs TF T2, so do not immediately duplicate that same cell. Whole Linux artifact verification is not a Windows5.1 generator command. Linux-gated helper skips do not supply Windows proof. Verify missing/failed/skipped/cancelled/wrong-revision required cells prevent publication. Root owns normal changed-candidate aggregate, review/quality/merge/landed/peer lifecycle; old checks never qualify new bytes.

## Prerequisites, history and later recovery work

Foundation-dependency C98 requires actual accepted paired coherent A03 workflow results before A06 implementation, including PS232's repaired lifecycle and applicable compare-back. A00/A01/A02 prerequisites remain. Root must refresh actual accepted refs/tree/path guards at release; no fetch or ref refresh was attempted during the frozen aggregate. PS source delivery, necessary TF counterpart and reverse raw comparison follow the existing lifecycle. A06 remains0/12 and has no PR clock; this analysis creates no transfer or fresh budget.

For the A16 start boundary, the accepted A06 foundation must include selected shared generator/verifier work, current TF T2 admission, required generator platform proof, artifact integrity and paired result. Keep A06's actual new-harness/Node22 caller integration and imported-input mutation tests open. A16 supplies its real13-path batch after accepted prerequisites; A03/A06/A07/A21 then integrate actual D2 recovery graph/runtime/loaders before real Gate A acceptance. Preserve all selected D5 cells, helper-only Windows B scope, later nine-path Gate B, real operator/independent-peer approvals and renewed approval when A security inputs change. Generator Windows evidence is not recovery acceptance. Consume exact returned `STYLEGUIDE_RECOVERY_NODE22` later; no ordinary root package setup under22. Keep300000ms until actual expanded fixtures justify an independently selected bound.

All86 current A06 primary remaining-owner IDs and original source hashes/dispositions remain pinned in the one canonical ledger; the larger historical design family keeps its original ownership distinctions. Restore no archive promotion/publisher without its actual reopen trigger. A14 live filesystem race/alias/cleanup residuals and PS155 remain; mutation snapshots are not malicious same-user confinement. A18/A19 retain full-union/conditional/issue/all402 verification. No new completion credit or broad A06 acceptance is claimed.

Checks here:87 prior-scope identity observations plus27 added existing guards; exact retained artifact-test region comparison; current finite caller/policy/selector trace; selected decision and ledger reads. All checks are static raw-object evidence. No tests, installs, runner imports, Git writes, native mutations, descendants or changes to the live aggregate/earlier evidence.
