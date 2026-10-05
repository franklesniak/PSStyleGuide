<!-- markdownlint-disable MD013 -->
# A06 release readiness after accepted TF67

**Conditional go after the current PS compare-back is accepted and root records C98 foundation acceptance. Do not release an A06 writer yet.** A06 D1=C96, D2=C97.4, D3=C96.6 and frontmatter D4=C98 remain applicable. The separate foundation-dependency C98 remains applicable. No new material finding was demonstrated; reuse the canonical decisions rather than add duplicate options, rubrics or scores. No implementation or tests ran.

## Inputs and changed observations

| Role | Immutable object | Tree/status |
| --- | --- | --- |
| Accepted PS232 | f0684acd81a1a6e53d87e43881c1ec4f1310b17c | 2cf6900441e7a64d2248769e6b9159caa48cc313; accepted |
| Accepted TF67 | e21b74fe0b56551008f78f9f2946cd2a0f9c19ce | 89f470ceb6b3e6e9d4ae757e38997f1c6e7bd631; accepted |
| Conditional PS compare-back | d0025e28eaaef57f4466bc83e9154cd9e7115fb3 | Immutable candidate tree; not accepted main |

Accepted status comes from root and retained acceptance receipts, not a new native query. TF checkout HEAD443b2fe is not substituted for accepted e21. All product reads use immutable objects. Root owns the PS index and running aggregate. The candidate differs from accepted PS in exactly two files: two Version comments in Test-AgentInstructions.ps1 and the unreachable lint-wrapper fallback removal. Both complete postimages equal accepted TF. This proves static scope, not aggregate, publication, review, merge or landed acceptance.

The previous results/A06/postTF66-readiness report remains the detailed baseline. Its38-path map per lane was checked by raw Git blob/type/mode. Accepted PS changes11 entries, accepted TF changes five, and the current PS candidate changes two relative to the old proposed tree. Unchanged entries reuse the prior record; evidence.json stores exact changed identities and names. The wrapper is separately covered by the current two-path diff and existing22-path catalog. No checkout newline normalization was used.

PS changes are classifier main detection; NpmTools and its tests; instruction validator/SelfTest; CI-helper tests; new local-validation test; policy main detection; instruction workflow's added existing suites; Copilot trigger simplification; and scripts README. TF changes are classifier unused-import removal, validator/SelfTest metadata alignment, neutral local-test scratch naming and README interface detail. Current PS versus old proposed changes only validator notes and README. These are governed A03/A07/A21 changes, not new A06 findings.

All three production generator/verifier implementations, both guide sources, four generated outputs and language semantic children are unchanged. PS artifact-child tests473–543 retain SHA256 `e1a9fac3ad87f8714cca38099273f6b5ec2d67069812a13ae2db31e74caa5bee`; TF473–557 retain `90feff7e41f85f1fa866cfc7bfb21dc358439ea157d03ddb090c20db405e5e23`. Their complete helper-test files equal the previous proposed-PS/accepted-TF blobs. Keep both oracle regions and current caller changes; do not restore an older whole-file test snapshot.

PS232's receipt records five landed workflows,507 passing Node tests with no failures/skips and11 hooks. TF67 records five landed workflows,515 passing Node tests with no failures/skips and11 hooks. Those results support their exact accepted inputs. They do not test future A06 bytes, Windows generator execution or native-ext4 storage.

## Finite C98 foundation assessment

The workflow foundation is structurally coherent on conditional PS candidate/accepted TF. All actual PS/TF blob/type/mode/length/SHA256 values match the reused22-path catalog:13 equal paths and the same nine bounded differences. No catalog was rebuilt. Additional raw checks cover build, Markdown workflow, devcontainer, credentials, policy contract/test/cases. Devcontainer workflow, policy implementation, policy tests and negative cases are raw equal. Current classifier is raw equal. D6/D9/D11/D12/D13 setup/security behavior remains at the retained bodies; lifecycle receipts supply their current coupled-run evidence.

| Exact surface | Retained difference and supported need |
| --- | --- |
| build.yml | Line7 verifier ID and line67 publisher dependency are PS verify_generated_artifacts/TF verify. Lines20/38 use actual repository identities; line92 names powershell.instructions.md/terraform.instructions.md. Preserve actual required contexts and language output. Other bytes match. |
| markdownlint.yml | Lines22/40/83/101 are repository/remote identities for its two jobs. Anonymous acquisition must name the actual repository. Other bytes match. |
| Test-CheckoutCredentials.ps1 | Line40 expected origin URL only. It must check its actual repository. |
| workflow-policy-contract.json | Line4 native verifier context and line34 exact language filename in four-output allowlist only. |
| Check-NpmAudit.mjs | expectedRepository identity only; exact existing catalog disposition retained. |
| agent-instructions.yml / copilot-setup-steps.yml | Four acquisition repository/URL identities / three repository/origin identities only. |
| Test-AgentInstructions.SelfTest.ps1 | Actual PS P1/TF T1 provenance-fixture path only. |
| Test-CiHelpers.test.mjs | Acquisition identity fixtures and current PS blank-line versus TF recovery child/schema oracles. Preserve distinct current consumers. Their useful union remains selected A06 work; this is not a permanent whole-file exception. |
| scripts-README.md | Actual P1/T1 provenance link, language child description/entry/command and native verifier context. Keep truthful interfaces. Document a new harness only when present, with serialized document ownership. |
| AGENTS.md / CLAUDE.md | Previously accepted exact product/scope identity, language filename, local/external canonical PS guide and final identity regions. Shared rules/metadata match. No A06 protected edit is selected. |
| docs/dependency-maintenance.md | Scope repository identity only. |

Evidence.json contains raw seven-file identities and exact diff hunks. The pinned22-path catalog retains its exact blobs and canonical regions. No wildcard exception is granted. Generator implementation differences remain A06 work; C98 does not require future generator work before releasing its writer. Two-space frontmatter is selected for removal, not a permanent exception.

C98 accepts a finite prerequisite, not broad A03 completion. Later R5/B1 credential/schema consumers and A15 D2 recovery workflow/policy/cases/publication integration remain A03 work. **Do not require all R5 or D2 before A06.** If actual generator host setup needs a selected runtime interface, integrate that real dependency under A07/A03 ownership. Do not invent an unconditional whole-runtime hold or partially port an installer.

## Exact missing implementation batch

Workflow paths below have prefix `.github/workflows/`. Root must serialize shared-file ownership and freeze the actual final union before release.

| Owner | Paths | Missing work |
| --- | --- | --- |
| A06 | Generate-StyleGuideArtifacts.ps1; Test-ExactGitPathSet.ps1; Test-StyleGuideArtifacts.ps1; Test-CiHelpers.test.mjs; new Test-StyleGuideGenerator.ps1 | One shared parser/composition/publication engine with finite literal descriptors and neutral common types/schemas where selected. Change producers, gate consumers and stubs together. Add focused actual-generator controls compatible with5.1. Preserve PS/TF oracle union. No external descriptor/loader or generic framework is selected. |
| A06 generated output | Root powershell.instructions.md; guard copilot-instructions.md, STYLE_GUIDE_CHAT.md, STYLE_GUIDE_FULL.md; TF terraform.instructions.md | Generate one-space applyTo with unchanged selector/description. Write only actual output deltas. Keep normative/rationale sources unchanged. Generate twice and compare all four raw outputs/modes. Never hand-edit artifacts. |
| A03 | build.yml; Validate-WorkflowPolicy.mjs; Validate-WorkflowPolicy.test.mjs; workflow-policy-cases.json | Add actual Windows5.1/7 and verified native-ext4 Linux7 generator jobs with fail-closed same-revision publication dependencies. Current validator502–525 fixes job set, Linux execution, three-step verifier and scalar publisher dependency. Add finite job/step/role rules and useful negative cases atomically. Preserve native contexts, read-only committed publisher, least privilege and independent output allowlists. |
| A03 conditional | workflow-policy-contract.json | Change only for actual finite role/schema declaration changes. Do not change parser/action pins or rewrite Markdown workflow merely because generator jobs are added. |
| A21 | Classify-InstructionMaintenance.mjs; Classify-InstructionMaintenance.test.mjs | Admit exactly the real new Test-StyleGuideGenerator.ps1 selector, with isolated/case-alias/mixed-addition controls. It is absent now. Keep current main detection. This existing-format executable does not justify wholesale validator/SelfTest/manifest rewrites. |
| A07/A03 conditional interfaces | Existing selected R5/B1 eight-path scope; scripts-README.md if documenting the real new supported entry | Coordinate only actual runtime/consumer needs. A07 owns initializer/runtime metadata/Invoke-MarkdownLint and two interface documents; A03 owns credentials/Copilot/helper tests/graph. Preserve D9/D11/D12/D13 and pins. Never enable nonexistent consumers. |

D1 retains PS heading-linked rationale and TF explicit-body markers, executive-summary placement, standalone/recovery appendices, TOC order, links, fences and blank lines through one engine. Descriptors may differ in language values/composition policy. Two full divergent callbacks hidden in profiles do not meet the decision.

D3 retains real PS Test-BlankLineExamples.ps1 and TF Test-StateRecoveryExamples.mjs. Keep first-resolved Node/no fallback and300000ms. Resolve tools before repository children. Snapshot before semantic execution; inspect each child's effects afterward. Separate native exit status from result status. Keep four independently fixed artifact records and bounded fixed labels. Schema changes and useful stub/oracle union form one coherent batch. A future harness must not erase T2 admission.

## Useful candidate proof, not executed here

Reuse old observations only for unchanged inputs/environments. Historical PowerShell7.6.5 Windows experiments include four no-change generations and four ordinary File.Replace/File.Move publications. Those are real historical results, not future A06 passes. Windows PowerShell5.1.26100.9549 parsed the generators/exact-path verifiers; launches were blocked by Restricted policy. There is no5.1 runtime pass. Hosted Linux artifact success does not establish native-ext4 generator or Windows cells.

Run the actual focused generator harness twice per required cell: Windows PowerShell5.1, Windows PowerShell7 and PowerShell7 on verified native ext4. Use normal selected windows-2025 powershell/pwsh shells; record actual image, edition/version, executable and storage. Use immutable anonymous acquisition with Windows fixed Git/neutral configuration, not Linux /usr/bin/git or /dev/null assumptions. No local policy bypass, host substitution, compatibility-module5.1 claim or skipped-pass. Keep GNU/BSD/unknown dispatch controls explicitly synthetic unless native execution exists.

Cover actual no-change/publication; en-US/tr-TR anchors with independently killable casing controls; identity dispatch and native failed/empty/multiline output; hard-link refusal; candidate/final identity; uncertain publication outcomes; UTF-8/LF/BOM/malformed bytes; anchors, marker/standalone order and large fences. Preserve golden outputs except the selected spacing delta. Exercise malformed JSON/nonobject/cardinality/order/path/schema, native/result disagreement and hostile-field bounded diagnostics. Catch actual behavior failures; do not mirror implementation or revive archive receipts.

Run the real Linux artifact gate on a clean committed candidate with its real semantic child. It already executes TF T2; do not immediately duplicate that identical cell. Preserve timeout/signal/missing-child/channel/config/source/self-change and first-runtime controls. Prove absent/failed/skipped/cancelled/wrong-revision platform cells block publication in the same accepted run. Snapshot evidence detects ordinary observed mutations; it does not confine malicious same-user descendants or close PS155/A14 races.

Run affected CI-helper, policy/classifier tests, applicable aggregate/hooks and actual endpoint checks under root ownership. Bind final evidence to actual candidate bytes. No unchanged historical suites need repetition during readiness.

## Evidence root must add before writer release

1. Finish the current root-owned PS aggregate and unchanged-input guard. Record terminal results for treed0025e2, or refresh changed inputs. Preserve genuine author-date handling; October5 metadata assignments cannot be reused blindly after relevant date/input changes.
2. Complete ordinary commit hooks, accepted-B/proposed-H endpoint diagnostics, non-force publication, authenticated current-input Copilot/Codex dispositions, hosted checks, independent non-author final quality, current premerge base/head/scope/protection checks, normal merge and actual landed service/workflow acceptance. Preserve clocks, rounds and service limitations. An accepted request, local pass or merge alone is insufficient.
3. Refresh both actual native accepted mains/trees. Prove both delivered postimages equal accepted TF. Compare coupled workflow contracts against pinned catalog/raw hunks. Reuse13 equal/nine bounded22-path dispositions plus extra workflow rows only if relevant inputs remain unchanged; refresh actual drift. This is not A18 full-union acceptance.
4. Record finite C98 A03-to-A06 acceptance in existing A03/A06 results: exact pair, scope, coupled tests, normal lifecycle, justified differing regions, and remaining R5/B1/D2 work. Confirm A00/A01/A02 prerequisites and relevant changed-input triggers. A report or stage label alone does not accept the product prerequisite.
5. Freeze owned A06/A03/A21 batches and current preimages in a clean PS worktree from accepted main. Keep protected sources unchanged unless a real separately authorized need appears. Release one PS implementation first; accept it before TF port and reverse raw comparison. Increment actual directional repairs before starting them; inspection consumes none.

A06 remains0/12 with no PR clock. A03 remains2/12; A07/A21 remain4/12. All22 outcomes,402 contracts,26 historical credits and86 A06 primary remaining-owner IDs/dispositions are preserved. No stage resets budgets.

For A16 start, A06 must later accept shared generator/verifier work, current TF T2, actual required generator platform proof, artifact integrity and paired delivery. A07 separately needs current tooling/B99 and independently usable R5/B1 with coordinated accepted consumers. Then build A16's real13-path batch. Integrate A03 D2, A06 actual new-harness/Node22 caller/integrity tests, A07 runtime evidence and A21 loader closure against present files. Consume exact returned STYLEGUIDE_RECOVERY_NODE22; do not run ordinary root setup under22. Keep300000ms until actual measurements support a separate bound decision. Generator proof is not recovery proof. Same-revision Gate A/B cells, real operator/independent-peer approval, helper-only Windows B scope and later nine-path Gate B remain. Retired archive promotion has no new trigger.

**Next action:** root accepts the current two-path PS compare-back, records refreshed paired C98 foundation, then releases the serialized PS A06 core/harness and coupled finite workflow/admission batch. Broad A03/A06 stay open.

Only this REPORT.md and evidence.json were written. No product/index/ref/planning/root-state/other-evidence/dependency/native changes, network calls, downloads, installs, tests, aggregate, review or descendants occurred. Immutable identities/source guards are in evidence.json. Actual native freshness remains a root-owned check.

Collector note: the first static collector stopped before writing because it included a final LF in the selected test region. The baseline digest excludes that LF. Matching that convention verified both stored digests and complete-file identities. No product failure or test change occurred.

Coordinator read the complete report and independently sampled the accepted PS classifier and TF build raw blobs/modes. The later local commit4783da3 retains candidate treed0025e2; no acceptance is inferred. Private report/evidence SHA256 values are35e47f23ef03fc0c26cd8441c5fe9f4313840882d74ab0ca0c1370fde254a624/f9bf0d947fb3dcd1f4bf523a3e3a3f3c9490cfc4d697f52556dcd0baac93a898. Canonical evidence changes location labels only; private originals remain frozen.
