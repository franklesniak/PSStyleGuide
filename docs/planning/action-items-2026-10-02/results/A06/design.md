<!-- markdownlint-disable MD013 -->
# A06 generator and artifact preparation

This is research ahead of A02/A03 acceptance, not product acceptance. No product, planning or native object changed. Only assigned scratch was written. Requested route is `gpt-6-astra/high`; effective settings are unavailable. Transfers are 0/12; no PR clock exists.

Both authenticated native main pins remain PS `48f4d8a36c8faceee12afac78aaecea0d176125d` and TF `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. [Native evidence](native-evidence.json) supplies their trees and 30 exact source/output blobs, modes and SHA-256 values. Local snapshots came from those Git objects with LF checkout. Mutable A02 work was not used as accepted input.

Read STATUS first, A06, the current lifecycle/decision process, A00/R01–R07, A03 design, A14 conditional assessment, A15 design, and original069–097/183–209/223–260 ownership. Original070/071,079,088 and184 supplied the relevant identity, culture, diagnostics and P1A contracts. [Original dispositions](original-dispositions.json) preserve all94 IDs: 35 replaced,59 unverified, with existing owners and source hashes. No disposition changed here. Writer/archive obligations remain replaced through A00 R06; original226/229/230 retain their distinct assessment/authority/settings ownership. The old direct-main exceptions are not new authority.

## Measured baseline

[Probe results](probe-results.json) record bounded experiments in isolated scratch copies, not a new product test suite:

- PowerShell7.6.5 on Windows ran each actual pinned generator twice. All four runs returned exit0/`NoChange`; raw committed outputs and clean tracked state were retained.
- In each repository, one stale tracked Copilot artifact exercised real `File.Replace`; one absent index-tracked Copilot artifact exercised real `File.Move`. All four cases returned exit0/`Success`, restored the original SHA-256, and reported candidate/final identity and digest equality. Other outputs remained unchanged. These are ordinary supported writes, not competing-writer attacks.
- Ten extracted actual `New-FullPayload` controls/mutations ran under PowerShell7.6.5: en-US/tr-TR, two independently mutated PS casing sites and one TF site. Baselines inserted the rationale; each culture-sensitive mutation failed its Turkish-culture expectation. These tests execute only the extracted pinned function in an isolated process scope and restore that scope's culture.
- Windows PowerShell5.1.26100.9549 parsed both generators and both exact-path verifiers with zero syntax errors. Its four attempted generator file launches were blocked before execution by the host's default Restricted policy (all explicit scopes Undefined). No policy or bypass was used. This is an environment limitation, not a generator failure or runtime pass.
- Linux/ext4, macOS/BSD, full Linux artifact verification, Linux-only CI-helper tests and adversarial path races did not run. The current artifact wrapper requires PowerShell7 and is explicitly a Linux CI caller; its requirements are distinct from the contributor generator's5.1 support.

## Finding A06-D1: converge composition without losing language content

**Validation.** Each repository has66 named functions across generator, exact-path verifier and artifact gate. A token comparison used only to locate differences found identical executable function tokens throughout `Test-ExactGitPathSet.ps1`; its differing whole-file bytes are version/schema strings and whitespace. Generator filesystem functions differ chiefly in type namespace/help versions. `New-FullPayload` is materially different: PS builds heading-linked rationale and recognizes `rationale-anchor`/`rationale-toc`; TF uses body-only `RATIONALE` markers, inserts the executive summary before Terraform Version Requirements and appends unreferenced top-level rationale sections. Copying either whole implementation blindly loses supported content. Comment/whitespace-normalized analysis is not raw-byte acceptance.

**Stakeholders.** Documentation authors/readers and LLM instruction consumers need the same language content and stable output roles. Both maintainers, reviewers and future agents need one parser/publication implementation. Windows5.1/7 and Linux contributors need the existing executable support. Security engineers need fixed destinations and refusal semantics. A15 recovery authors must retain TF's standalone/recovery sections. No new cloud permissions or user data are needed.

**Options before scoring.** N: retain divergent algorithms as broad exceptions. P: copy the PS generator and rewrite TF source markers/content layout now. C: use common parser, composition and publication functions with finite local artifact descriptors that preserve both current source representations and output bytes. R: restore old exact-source/version profile machinery. A general template/plugin language is excluded: no current consumer needs arbitrary code, paths or commands.

**New rubric.** Content/safety preservation40%; common-algorithm identity25%; supported-source compatibility20%; maintainability10%; migration cost5%. Scores1–5, high is better; total `sum(weight*score)/5`. Hard constraints: fixed two source files/four output destinations; no guide content loss; no unsupported5.1 API; no source-selected executable commands; no protected source edits without their direct scoped authority.

| Option | Preservation | Identity | Compatibility | Maintainability | Cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 3 | 1 | 5 | 2 | 5 | 58 |
| P | 3 | 5 | 2 | 3 | 2 | 65 |
| C | 5 | 5 | 5 | 4 | 3 | 96 |
| R | 4 | 3 | 3 | 1 | 1 | 62 |

**Selected solution.** Use C. Start in PS after A02/A03 acceptance. Keep one implementation of source decoding, anchor normalization, section parsing, block filtering/link conversion, whitespace normalization, fence sizing, payload serialization and safe publication. Add the currently supported TF composition semantics through the same section/emission engine. Do not retain two whole `New-FullPayload` callbacks disguised as profiles. Do not migrate protected source prose merely to make the first port easier.

Use a small, marked literal descriptor block inside the existing standalone entry points initially. This avoids a new loader or generic configuration framework. Keep these exact data distinctions explicit: scoped artifact ID/path; frontmatter selector/description; chat title; guide-root link anchor; executive-summary heading/anchor and optional before-heading location; source composition policy (heading-linked or explicit-body); standalone-section inclusion policy; semantic test role. Values must come from the reviewed fixed block, not command-line paths, environment, Git remote spelling or document-supplied executable code. The caller's expected output records remain independently fixed; the generator must not supply its own allowlist to the gate.

| Descriptor role | PS value | TF value |
| --- | --- | --- |
| Scoped ID / output | `powershell-instructions` / `powershell.instructions.md` | `terraform-instructions` / `terraform.instructions.md` |
| Scoped selector | `**/*.ps1` | `**/*.tf,**/*.tfvars,**/*.tftest.hcl,**/*.tf.json,**/*.tftpl,**/*.tfbackend` |
| Frontmatter description | `PowerShell coding standards` | `Terraform coding standards: secure, modular, and well-documented infrastructure as code.` |
| Chat title | `# PowerShell Writing Style Guide - Formatted for Copy-Paste Into LLM Chat` | `# Terraform Writing Style Guide - Formatted for Copy-Paste Into LLM Chat` |
| Bare-guide link anchor | `powershell-writing-style` | `terraform-writing-style` |
| Summary heading / anchor | `Executive Summary: Author Profile` / `executive-summary-author-profile` | `Executive Summary: Terraform Philosophy` / `executive-summary-terraform-philosophy` |
| Summary placement | Existing heading/explicit source marker | Before `Terraform Version Requirements`, with matching TOC placement |
| Composition / append | Heading-linked, explicit heading/TOC markers; no inferred standalone append | Explicit body markers; append top-level sections excluding TOC, executive summary, rationale groups and already present headings |
| Semantic child | Current PowerShell executable / `Test-BlankLineExamples.ps1` | First resolved Node executable / `Test-StateRecoveryExamples.mjs`,300000ms |

Preserve exact existing frontmatter whitespace too: the PS selector currently has two spaces after `applyTo:`, while TF has one. That is an output compatibility input during this factoring, not an independently justified permanent formatting exception. A later intentional output-normalization decision can remove it with regenerated outputs. The initial shared private function name can be `New-ScopedInstructionsPayload`; there is no need for separate language-named algorithms.

The shared parser must recognize all three existing marker forms with consistent meanings: body-only `RATIONALE`, heading-plus-body `rationale-anchor`, and explicit TOC text `rationale-toc`. Matching source headings remains a defined composition mode. TF's summary and standalone sections become data-directed emissions through the same parser. Preserve ordering, header depth, existing link rewriting, intentional placeholders, blank-line collapse and each four-output byte baseline. Source syntax compatibility is a real supported input; brand-specific function bodies are not a necessary exception.

Use common neutral internal C# type names. Inspect schema consumers before replacing repository-prefixed result names. The current exact schema consumers are the artifact gate and child stubs; migrate any selected neutral result schema atomically in producer/gate/tests, or retain a small explicitly documented compatibility literal if a real external consumer is found. Version/help markers must follow authoring rules, not select runtime compatibility. Do not exempt whole files for these literals.

**Verification.** Require full per-repository golden output equality before and after factoring, two actual generator runs, and separate marker/heading/standalone fixtures. Check no duplicate insertion and no missing TF executive/recovery/appendix sections. Test both source and guide casing sites independently. Compare raw common function bytes and exact remaining descriptor regions, then final whole Git blobs/modes with narrow exceptions. If preserving existing behavior reveals a real ambiguity (for example duplicate heading anchors), validate and decide it separately; do not silently alter generated content while calling the change a port.

## Finding A06-D2: retain actual useful oracles after retirement

**Validation.** Current CI-helper artifact tests stub generator and exact-path children. They verify the wrapper's failure/side-effect detection but do not execute ordinary generator publication or prove original169 platform/candidate-identity controls. The surviving workflow-policy catalog has no culture-control or hostile generator-field family. The exact-path verifier still runs its internal boundary/native-exit probes. Current culture behavior passed the focused experiment, but the reproducible regression should travel with the common implementation. R02/R07 still apply; a missing old archive harness is not proof that its live-generator oracles were replaced.

**Stakeholders.** Test authors, both maintainers, security reviewers, Windows/Linux contributors, artifact consumers, CI operators and incident investigators need failures that identify broken behavior. Cost owners need bounded fixtures instead of a revived archive test corpus. History custodians need honest preservation of old unmeasured branches.

**Options.** N: rely on current green/stub checks. C: add a focused common generator/verifier regression suite for current callers and run the affected supported hosts. R: restore every removed historical fixture. L: test only current Linux CI and accept no new Windows runtime evidence. Reusing an isolated valid historical fixture is part of C; restoring its former receipt machinery is not required.

**New rubric.** Reachable failure coverage38%; independent mutation/oracle strength28%; supported-host evidence24%; maintenance7%; execution cost3%. Hard constraints: actual production publication in positive tests; independently killable culture/identity mutations; no passing result from a skipped host; no simulated race result relabeled production proof.

| Option | Coverage | Oracle | Hosts | Maintenance | Cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 2 | 1 | 1 | 5 | 5 | 35.6 |
| C | 5 | 5 | 5 | 4 | 3 | 97.4 |
| R | 4 | 3 | 3 | 1 | 1 | 63.6 |
| L | 4 | 4 | 1 | 4 | 4 | 65.6 |

**Selected solution.** Use C. Keep a focused `Test-StyleGuideGenerator.ps1` compatible with5.1 for actual generator outcomes and narrow function controls; use separate scratch fixture repositories. Do not execute the blocked host's file through a workaround. Keep actual child launches and synthetic function controls separately labeled. Preserve en-US/tr-TR and GNU/BSD/unknown-platform dispatch controls, native failed/empty/multiline identity, hard-link refusal, final-to-candidate identity equality, and uncertain post-publication outcomes. Test raw UTF-8/LF and forbidden BOM/malformed bytes, missing anchors, large fences, wrong result shape and fixed artifact records. Do not invent a complete race harness to close PS155.

Use `windows-2025` with the normal `shell: powershell` path for5.1 and `shell: pwsh` for7, coordinated with A03's accepted graph. GitHub documents these shell selections and publishes the Windows image source; its image setup already configures script execution. No local host-policy change is needed. Record the actual image/version/edition and run the same real fixture entry point. Add action-free anonymous immutable acquisition with Windows fixed Git/neutral-config handling; do not copy Linux `/usr/bin/git` or `/dev/null` paths blindly. A03 must admit the new finite roles and A07 must validate any runtime needs. [GitHub shells](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax), [hosted Windows image](https://github.com/actions/runner-images/blob/main/images/windows/Windows2025-Readme.md), [image setup](https://github.com/actions/runner-images/blob/main/images/windows/scripts/build/Configure-BaseImage.ps1).

Run the real Linux/ext4 cell on the accepted Ubuntu runner and verify the actual filesystem type. Preserve honest macOS/FreeBSD dispatch controls; native BSD execution is separate evidence, not implied by Windows mocks. The retained original169 runtime minimum is two passes on Windows5.1, Windows7 and native ext4 PowerShell7. Do not claim the parse-only result meets it.

**Verification.** Preserve this task's measured8 successful actual generator executions (4 no-change,4 publication). Add the listed useful negative oracles during implementation. Require non-skipped expected host results and same candidate SHA. A03 owns required-check/publisher dependency wiring; the future A15 Windows recovery gate is separate and remains unimplemented.

## Finding A06-D3: share the artifact gate without losing semantic admission

**Validation.** Both wrappers snapshot worktree bytes and Git control surfaces, launch generator/exact-path children, constrain four artifact records, reject runner-channel writes, and enforce native status. PS additionally runs `Test-BlankLineExamples.ps1`; TF runs `Test-StateRecoveryExamples.mjs` in the same integrity envelope with a300-second process limit. A PS-only copy would remove TF recovery admission. TF's wrapper does not replace PS semantics. PS fixed-label result diagnostics preserve all relevant distinct failure names without printing hostile values; generator version equality has correctly ceased being a compatibility guard under R02.

**Stakeholders.** PS example readers, Terraform recovery operators, artifact consumers, CI/security reviewers, maintainers, A10/A11/A15/A16 owners, and runtime/cost owners need the correct language gate and bounded failures. Terraform state secrets are not used by these current fixture tests, but future recovery design must retain its separate privacy boundary.

**Options.** N: keep independent wrappers and drift. P: port only the PS wrapper everywhere. C: one common gate with two fixed semantic-test roles and the union of useful wrapper oracles. R: restore archive extraction/promotion and its old comprehensive harness. Automatic publication is not a present consumer and fails the scope constraint.

**New rubric.** Correct semantic admission42%; honest integrity/failure behavior27%; language compatibility18%; maintenance9%; churn4%. Hard constraints: no caller-controlled arbitrary child command; keep separate read-only committed-byte publisher; preserve PS semantic and TF recovery tests; retain current timeout until measurement justifies a bounded change.

| Option | Admission | Integrity | Compatibility | Maintenance | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 3 | 2 | 5 | 2 | 5 | 61.6 |
| P | 2 | 4 | 1 | 4 | 4 | 52.4 |
| C | 5 | 5 | 5 | 4 | 3 | 96.6 |
| R | 3 | 3 | 2 | 1 | 1 | 51.2 |

**Selected solution.** Use C. Retain PS's readable structured checks and common raw Git-path algorithms. Integrate TF's bounded recovery adapter as a fixed role. Resolve executables before repository children. Snapshot before any semantic child. Check every child effect before claiming clean output. Keep native process status distinct from JSON result status. Keep fixed ordered failure labels; never echo unchecked result values into diagnostics. Keep publisher identity and TF required context `verify` unchanged.

Port the useful union of existing child-failure tests: PS semantic failure/side effect, TF recovery missing/failure/signal/timeout/channel/config/source/self modification and first-resolved-Node behavior, plus common verifier config/channel/worktree/native failure. Add focused native/result mismatch and multiple hostile-field controls, since existing stubs usually emit a valid result. Verify malformed JSON/nonobject/cardinality/order/path/schema cases independently. Current snapshot checks detect ordinary observed mutations; they do not sandbox malicious same-user descendants or solve A14's path races.

Keep the300-second recovery budget. Do not raise or remove it for hypothetical T4 work. A15/A16 must supply actual fixture measurements before a bounded change is selected. Future Windows/Linux recovery results must gate publication in the same accepted build run, with missing/skipped/cancelled/failed cells rejected by A03's aggregate. Current Linux T2 tests are not Windows T4 acceptance.

## Ownership, staging and readiness

PS first, TF port second, then PS reverse comparison. Implement after accepted A02/A03. Do not overwrite the whole `Test-AgentInstructions.ps1`: A02 owns metadata/schema/self-test, placement literals, Git-ignore semantics and the newly assigned string-preserving JSON decoder; A07 owns its hook/tooling functions. A06 has no identified need to edit those functions merely to share generator algorithms.

A03 owns the workflow roles, classifier admission and same-run graph. The selected inline descriptors do not introduce a new external artifact-spec loader; if implementation later selects a sidecar or helper, add that real input and its reader to closure atomically. A07's broader closure list remains valid for its actual loaders: requirements-dev, locked Python hook, install-husky, staged/nested lint, both package/locks, precommit/Husky, dependency docs and affected validator inputs. Preserve credential normalization and runtime pins.

A14 D92/D93 is reusable at the inspected pins. Generator `File.Replace`/`File.Move` and cleanup remain path-based. Common-code edits must recheck those exact operations and named triggers. Keep PS155 open. Missing TF historical decision prose is an A02/A18 matter; do not import PS authority by copying a comment.

The minimal selected work needs no protected guide/source-content edit: preserve current sources and outputs using the finite descriptor. If an implementation proves a protected-source change necessary, stop that path, prepare its exact content-preserving diff and obtain the missing specific grant. Existing authorized ordinary scope does not require a new permission for each generator/test edit.

Next action: parent checks this scoped design against the accepted A03 finite roles and pending A07 result; after A02/A03 acceptance, assign one PS writer to D1/D3 and the focused D2 fixtures. Completion still requires native Windows5.1/Linux runtime evidence, relevant checks/reviews, normal merge, paired port/reverse raw-byte comparison and final conditional-risk revalidation.

Keep only this design, threat map, native evidence, compact probe results, original dispositions and validation record as durable planning evidence. Scratch clones, individual child JSON logs, publication snapshots, culture collector/script and function-analysis output are reproducibility scratch; do not commit them or treat their filenames as governance interfaces.

## Coordinator review

The parent verified all30 raw source identities/modes and12 weighted totals and reviewed the probe limits. This accepts preparation only. The source-compatible descriptor design does not authorize a permanent formatting exception: resolve the two-space/one-space applyTo difference with a finding-specific choice during A06 implementation before declaring its convergence, or prove an actual consumer need. Preserve raw golden comparisons while distinguishing an intentional reviewed output change from accidental drift. No protected source edit is currently selected.
