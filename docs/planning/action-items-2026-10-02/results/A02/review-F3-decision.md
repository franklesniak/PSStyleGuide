<!-- markdownlint-disable MD013 -->
# D-A02-F3: Enforce the published metadata-classification boundary

**Finding:** [Codex4163722056](https://github.com/franklesniak/PSStyleGuide/pull/224#discussion_r4163722056), review5389295737, head `fe3d6738d5b331f88e21bf6b9815883b3bb353b8`, base `48f4d8a36c8faceee12afac78aaecea0d176125d`. This is the single canonical F3 decision. The A02 worker released decision ownership to the coordinator, who assigned this record to a00_history. Earlier independent-F3-assessment.md is supporting analysis, not another selection. Requested model/effort: gpt-6-astra/high; effective settings unavailable. Implementation and public release are pending.

## 1. Validate

The current classifier treats the metadata manifest as a maintenance selector. Other selector edits also make a mixed manifest/code change maintenance. The accepted-policy workflow invokes Test-AgentInstructions only inside its ordinary branch. Its maintenance branch emits an owner-review requirement and succeeds without validating the table against B. Candidate -SelfTest uses checked-out HEAD as the classification baseline. This demonstrates self-consistency, not previously published authorization.

The worker's exact-head production-helper reproduction accepts a candidate exemption set containing README.md and docs/RUNBOOK.md when the baseline is that same candidate. It rejects docs/RUNBOOK.md when the actual trusted baseline contains only README.md. Existing expansion logic is useful when the caller supplies the correct baseline. This is a caller/trust-boundary defect, not a reason to remove classification coverage.

Published endpoint mode requires complete commit identifiers and checkout HEAD==B. Candidate checkout plus explicit B/H cannot become accepted-code authority without violating that guard. The missing-baseline expansion branch currently returns without a restriction. The separate known-validator metadata-coverage helper governs initial document metadata/date validation; it does not authorize initial manifest exclusions.

PS B has neither the manifest nor this consumer. Current PR224 is its bootstrap. Proposed code can be tested against exact B/H, but an already-installed accepted-base guard did not validate this introduction. TF has an existing table/consumer and the corresponding maintenance routing issue; its future paired port must use its actual accepted manifest, not the PS bootstrap exception. A03 D1's broader producer/authority question remains unanswered.

Evidence: independent-review-inputs.json records raw blobs, modes and SHA256 values for B/H; independent-F3-assessment.md records inspected source/caller ranges. The worker's review-round1-reproduction.ps1/.log records the harmless actual-helper reproduction. No unrelated suites were rerun for this decision. PowerShell 7.6.5, locked markdown-it and Node 24.18.1 were the reproduction environment. Native current endpoints were confirmed during the immediately preceding F2 assessment; refresh them before any public mutation.

## 2. Stakeholders

- The owner and both repository maintainers need enforceable classification semantics without a new per-change approval ritual. They also need an honest account of first-install trust.
- Documentation authors, new contributors and local/remote agents need a predictable two-stage exemption change. Existing authorized exemptions and normal document edits must remain usable.
- PowerShell/Terraform instruction readers and generated-artifact consumers depend on complete metadata coverage. An exemption cannot silently suppress required checks.
- Code reviewers, independent-quality reviewers and auditors need the baseline, candidate and bootstrap evidence distinguished. A green candidate self-test must not imply prior approval.
- CI/platform engineers and Windows/Linux PowerShell users need bounded data processing with exact native failures, reproducible endpoint selection and no candidate code execution in the accepted phase.
- Security and supply-chain owners need the specific self-baseline bypass repaired without claiming immutable workflow enforcement or accepting the unresolved D1 risk.
- Project/cost/schedule owners need a small coupled repair. A new service, duplicate parser, broad policy revival or circular A02/A03 dependency would add maintenance without repairing the immediate data flow.

This change adds no personal-data processing, cloud access, infrastructure recovery action, translation or user interface. Privacy, cloud administrators, incident operators and accessibility/localization users have no distinct new requirement here. Repository credentials remain absent from the accepted acquisition/check phase.

## 3. Options before scoring

| ID | Option | Consequence |
| --- | --- | --- |
| N | No change; rely on candidate tests and pending procedural review | Leaves the actual published-data bypass. No current residual waiver exists. |
| O | Remove only the manifest literal from selectorPaths | Routes future pure-data changes through the installed accepted consumer. Mixed selector/code edits still skip it. Initial absent-manifest admission remains unresolved. |
| C | Give candidate tests explicit B/H or relax checkout==B | Useful only as proposed-code tests. Does not establish accepted authority; relaxing the guard is prohibited. |
| G | Add an unconditional accepted-base data-only phase; reject all missing baseline manifests | Protects ordinary and maintenance inputs after installation, but cannot initialize this PS table through that phase. Needs a separately bounded bootstrap disposition. |
| I | Verify and admit only the exact initial table; leave normal routing unchanged | Makes first-install evidence explicit but does not protect later pure or mixed changes. |
| GI | Combine G with one closed PS bootstrap mapping bound to exact prior input/validator identity | Preserves continuing accepted-base validation and restricts the only supported missing-baseline transition. |
| H | Implement the GI behavior in a new standalone accepted-base helper | Can provide equivalent data safety, but adds a second entry point and extraction/duplication work when the current validator already owns the safe readers and schema. |
| E | Use an external independent producer and native required-check protection | Could address the stronger D1 boundary after actual owner/operator installation. It is not currently available or authorized as this small repair. It still needs the data/bootstrap semantics. |
| R | Remove the classification manifest/consumer | Removes the failing boundary by losing discovered-document metadata coverage. Violates A02's preservation requirement. |
| D | Defer F3 until all A03 work is accepted | Keeps the bypass meanwhile and creates an unnecessary dependency cycle. A03 can consume this accepted coupled repair later. |

G+I is GI. O+GI has no necessary enforcement benefit: retaining the manifest as maintenance does not bypass GI's unconditional data check. Candidate tests remain useful with every viable repair, but never replace its accepted-base producer. E may later strengthen GI under D1; this record does not select or authorize that installation. Shared factoring must reuse one reader/schema implementation rather than copy the whole validator.

## 4. New rubric and hard constraints

Scores are judgments on a 1–5 scale: 1 fails the criterion; 2 has major unresolved limitations; 3 provides useful partial coverage; 4 meets it with a bounded limitation; 5 meets it directly. Weighted total=sum(weight*score)/5. The rubric measures this F3 outcome, not all workflow security.

- **Path coverage35%:** prevents candidate-only exemption activation for ordinary, pure-data and mixed maintenance inputs when the accepted workflow runs.
- **Baseline and bootstrap integrity25%:** preserves accepted-code/data distinction, published two-stage authorization and closed absent-baseline handling.
- **Scope and claim correctness20%:** preserves metadata coverage and reports actual authority/installation limits without substituting tests for approval.
- **Legitimate usability10%:** supports ordinary edits, published authorization followed by activation, and a concrete first installation without an invented approval system.
- **Maintenance cost10%:** reuses supported bounded primitives and has small, inspectable failure/restart behavior.

Hard constraints: do not execute candidate code in the accepted data phase; do not weaken exact B/H or accepted-checkout guards; do not allow arbitrary absent-baseline exemptions; do not lose current document coverage; do not claim this repair resolves D1, is already installed at B, supplies missing owner authority, or makes a workflow immutable. A high score cannot waive a constraint. Current authority to write the workflow must be assigned by the parent before an implementation writer touches it.

## 5. Scores before selection

| Option | Coverage35 | Integrity25 | Claims20 | Usability10 | Cost10 | Total /100 | Key uncertainty or exclusion |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 1 | 1 | 2 | 4 | 5 | 38 | Bypass persists; no accepted waiver |
| O | 3 | 2 | 3 | 4 | 5 | 61 | Mixed changes and bootstrap remain open |
| C | 2 | 1 | 1 | 3 | 4 | 37 | Cannot satisfy accepted authority; guard relaxation excluded |
| G | 5 | 4 | 5 | 2 | 4 | 87 | Safe continuing phase, unsupported first table |
| I | 1 | 4 | 4 | 4 | 4 | 59 | No continuing mixed-change enforcement |
| GI | 5 | 5 | 5 | 4 | 4 | 96 | Bootstrap still requires independent current-PR evidence |
| H | 5 | 5 | 5 | 4 | 2 | 92 | Equivalent safety; unnecessary helper/extraction surface |
| E | 5 | 5 | 4 | 1 | 1 | 80 | Conditional design capability; unavailable installation/authority |
| R | 1 | 1 | 1 | 5 | 5 | 36 | Loses required coverage; excluded |
| D | 1 | 2 | 3 | 2 | 4 | 41 | Leaves current defect and adds dependency delay |

Arithmetic was checked independently of the choice. GI has the highest score and clears the data-phase constraints by design. Its scores of 5 do not mean end-to-end native enforcement is proven. H is credible but adds implementation surface without a demonstrated consumer requiring it. E's capability scores describe what a properly installed service might provide, not existing assurance.

## 6. Selected solution: GI

Use a data-only mode in Test-AgentInstructions.ps1. Name the mode MetadataClassificationOnly unless integration finds an existing equivalent. Require exact InputRevision H and PublishedBaselineRevision B. Require the checker checkout to equal B. Reject missing endpoints and incompatible modes, including SelfTest. Keep all existing safe Git configuration and exact revision checks.

Read the manifest and tracked-path inventories as bounded data. Reuse strict UTF8, byte limits, exact 100644 mode checks, strict schema2 parsing, safe paths, duplicate rejection and the published expansion comparison. Do not load candidate modules or parser code. Run this mode before Markdown parser/dependency bootstrap. Return after the data result. Share this phase with full validation; do not maintain a second parser. Preserve native command failures as failures.

Call this mode in agent-instructions.yml after exact H fetch verification and before the ordinary/maintenance branch. Make a failed data check fail the job. Run it for both classes. Keep the maintenance routing and message. The manifest check does not grant merge authority. Keep candidate SelfTest as proposed-behavior evidence.

When B has a valid manifest, permit an active H exemption only if it is active or authorized in B. Candidate-only authorization must remain inert. Keep supported removal and revocation semantics. Reject missing/malformed candidate data. Reject a missing baseline except for the exact PS initialization below.

For that initialization, require B=`48f4d8a36c8faceee12afac78aaecea0d176125d` and its prior validator SHA256=`5a61845f756be1d1bc4ddb772ffbc6c71ab525f0394d11d8c672f998a05fb4a5`. Require the absent table at B. Parse H with the normal strict schema. Require schemaVersion 2 and authorizedExemptionPaths=[]. Require exactly these category mappings:

- tier2Paths: ACKNOWLEDGMENTS.md; CONTRIBUTING.md; README.md; samples/test-nested-markdown-linting.md; samples/test-recursive-nested-markdown.md.
- generatedPaths: STYLE_GUIDE_CHAT.md; STYLE_GUIDE_FULL.md; copilot-instructions.md; powershell.instructions.md.

Reject extra, omitted, reclassified or authorized paths in that bootstrap. Compare the parsed closed mapping, not a candidate-provided assertion. Do not reuse the date-coverage helper as exemption authority. The reviewed initial raw manifest SHA256 is `dde7762b2588b583c47bb342f0a34c938c593b9391abbcecfca0d2ab5012d89c`; this is an evidence identity, not a requirement to reject harmless JSON formatting when the strict mapping is identical. The mapping preserves the currently proposed five Tier2 and four generated facts. A new bootstrap identity needs its own justified decision; it must not be added automatically.

Modify only Test-AgentInstructions.ps1, Test-AgentInstructions.SelfTest.ps1 and the coupled agent-instructions.yml call unless focused caller-test wiring needs an existing test file. Prefer the existing dedicated SelfTest for the caller invariant. Do not edit the classifier merely to avoid the maintenance label. The parent must assign the workflow path before edits. Coordinate this narrow interface with A03; do not wait for or implement the rest of A03. Do not change protected root instructions.

For current PR224, run the proposed implementation against immutable B/H data in a clearly labeled harness and inspect the closed initial table independently. Do not fetch candidate code into the native accepted-policy job and call it accepted. Record that B's native workflow lacks the new guard. Keep this first-install boundary in the finding disposition and PR evidence. The parent retains the current PR gate, scoped authority checks, paired review lifecycle and final independent-quality decision. This record neither accepts nor waives the broader D1 residual.

## 7. Implementation and verification gate

No F3 product edit or implementation pass is recorded here. Parent verification/publication must precede writer release. Test the actual mode and caller, not only the expansion function:

1. Trusted B active README-only plus H adding RUNBOOK fails. Same-change authorization+activation fails. Each must still fail when H also edits the classifier, validator or workflow as data.
2. Authorization published in B followed by activation in H passes. Unchanged manifest and inert authorization additions pass. Supported removal/revocation and category transitions retain explicit expected outcomes.
3. Exact closed PS bootstrap passes. Extra RUNBOOK, nonempty authorization, omitted/reclassified initial path, wrong B, wrong prior validator hash and another absent-baseline state fail. Existing TF manifests never use PS initialization.
4. Invalid schema, duplicate keys/paths, oversized data, unsafe or untracked active paths, non-100644 modes, missing H table and malformed B fail through production readers. Candidate parser/module code must not run; make a candidate sentinel that would fail if executed.
5. Missing endpoints, short/unresolved/mismatched commits, candidate checkout!=B and incompatible modes fail. Reuse existing safe Git/native-failure controls; do not build a parallel Git framework. A failing native fetch/read/check must not become success.
6. A caller integration assertion must fail when the data-only call is removed, moved inside the ordinary branch, or made non-fatal. Exercise maintenance classification with a failing data guard. Check the actual workflow text/control flow or a supported existing policy contract; do not merely assert that a helper exists. Prove the data mode needs no candidate Markdown dependencies.
7. Run focused real mode/SelfTest/caller tests on supported PowerShell 7 CI hosts. Then run the required changed-head repository validation and review lifecycle. Record host limitations; do not bypass Windows 5.1 policy. The current assessment reused exact existing reproduction rather than rerunning broad unrelated suites.

A result from app 15368 does not prove immutable workflow provenance. This repair does not install a required native check, grant scoped owner authority, or prevent later administrative/workflow replacement. It enforces manifest data when the accepted workflow runs. Keep that limit and current-input freshness visible. No new persistent receipt or permission ledger is needed.

The decision author contributed to this design. Later independent quality must test the implementation and negative controls and include the parent's/A08's supplemental independent review. It must not rely solely on this authored recommendation.

Primary source links: [exact-head validator](https://github.com/franklesniak/PSStyleGuide/blob/fe3d6738d5b331f88e21bf6b9815883b3bb353b8/.github/workflows/Test-AgentInstructions.ps1), [unchanged accepted workflow](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/workflows/agent-instructions.yml), [exact initial table](https://github.com/franklesniak/PSStyleGuide/blob/fe3d6738d5b331f88e21bf6b9815883b3bb353b8/.github/document-metadata-classification.json).
