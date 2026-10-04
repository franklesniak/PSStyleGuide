<!-- markdownlint-disable MD013 -->
# Post-PR230 coherent Terraform handoff refresh

Read-only bounded refresh, 2026-10-04. The target remains all22 outcomes,402 original contracts and5 live issues. A02 stays1/12 transfers; A03 stays0/12. Other counters are unchanged. This report establishes no source-follow-up, Terraform, A03 or overall completion.

Accepted PS native main is fb3288934215dfa9a25114cf79ad86e60b5fb107, tree ed7ad456a7147152d2c289908066195689127e85. TF native main is06ad4f7c9b6847028cafdacf1ae55128d0f2d56c, tree dc8f6b82588b8f874d34cd5d0155791aea5793f1. Direct remote start/end ref readings are in native-start.json and native-end.json. No fetch or native mutation was used.

**Release gate remains full A03 source acceptance before any coherent TF implementation.** PR230 closes only its accepted eleven-path batch. The existing acceptance reports all9 candidate/all4 exact-merge workflows passed, clean current-input Copilot Balanced and remote Codex, and independent final-quality PASS. This worker reread the acceptance and hash-verified its native evidence; it did not repeat requests or CI operations.

The follow-up is frozen on codex/workflow-setup-convergence at HEADfb328, immutable candidate tree d13fff62fdfb88dbb2fadad77d852329f92bfe22. It changes only Copilot YAML, devcontainer YAML and Test-CiHelpers.test.mjs. All75 accepted-base and all75 candidate identities match Git objects and the frozen execution record (mode/blob/length/SHA256); the other72 files are unchanged. Sole aggregate89382 was recorded running. No tests, installations, product/index edits, cancellation, commit, PR, settings or lifecycle operations were performed.

One new material omission was validated: TF's pre-install package/parser policy preflight has no equivalent before candidate npm installation. PREINSTALL-PROPOSAL.md provides the transitive analysis, eight options, distinct correctness-heavy rubric, arithmetic-checked scores and recommended P98. It is for coordinator verification/display, not implementation or an owner question. Existing D6/D8/D9 selections remain.

## Concrete replacement map

Paths below are relative to .github/workflows/. Use final accepted source after the pending lifecycle and any selected repair. Current d13 is inspectable candidate evidence, never accepted authority. Do not reuse obsolete d527 or the old3e source pin.

| Paths | Common bytes and exact necessary adaptation |
| --- | --- |
| Check-NpmAudit.mjs/test | Replace the old A07-era pair with accepted PR230 D7/D10. Production helper adapts only expectedRepository to franklesniak/TerraformStyleGuide. All authority/scope code stays common. The accepted tests import expectedRepository and need no name fork. Keep D10's FETCH_HEAD pinning explanation. |
| agent-instructions.yml | Use accepted metadata admission/event/ref logic; adapt fixed TF repository identity/origins. Retain the sixth Node caller Test-LocalValidation.test.mjs alongside classifier, workflow-policy, CI-helper, NpmTools and audit tests. |
| build.yml | Common broad live push/all-base PR coverage/deletion guard. Keep TF verifier job verify and publisher needs verify. Adopt common publisher job publish_committed_artifacts and step IDs generate_style_guide_artifacts, checkout_repository, publish_committed_style_guide_artifacts. Use common run/attempt artifact name. Adapt fixed repository identity and terraform.instructions.md. Preserve TF's actual recovery-aware artifact-helper call. Old publisher/step spellings are not protected verifier names. |
| markdownlint.yml | Common unfiltered push/PR events, deletion guards, retained schedule, policy/markdownlint names and literal Check-NpmAudit.mjs --ci plus failure propagation. Adapt fixed repository identities only. |
| Validate-WorkflowPolicy.mjs/test, workflow-policy-cases.json | Final accepted source raw bytes/mode100644 should be identical. Common schemas and finite verifier-role algorithm replace repo-specific v2. Tests run both roles through the same cases. TF's omitted-workflow-dependencies case already exists with exactly the same workflow/path/operation/value/category in the current common catalog; its movement is not lost coverage. |
| workflow-policy-contract.json | Common v3 schema, parser/actions and publisher interface. Exactly two data adaptations: roles.artifactVerifier=verify and terraform.instructions.md upload path. No extra role keys or arbitrary-name profile. |
| Classify-InstructionMaintenance.test.mjs | Final accepted source raw bytes/mode should be identical. Includes actual push/new-ref/full-ref/main-publication caller tests, admission ordering and shared callable closure including recovery. A21 owns the common algorithm, unchanged by PR230. |
| copilot-setup-steps.yml | Final accepted D9/F97/D6 source, after resolving preflight finding; adapt fixed repository/credential-free origins only. Do not preserve obsolete default_branch/origin-HEAD discovery, current-only layout behavior or job.env dependency. Current d13 is not cleared for transfer. |
| devcontainer-ci.yml | Selected D8 source can be raw-byte/mode identical: native context, common messages/staging name, no repository literal. Preserve recursive NUL tree inventory including empty trees and all embedded controls. |
| Test-CiHelpers.test.mjs | Reconcile final combined D2/D3/D6/D8/D9 source with actual TF test union below. Adapt bootstrap fixture identities and artifact schema/filename/semantic fixture to the real TF artifact gate. Common behavior stays common; never blanket-copy away TF recovery oracles. |
| Test-CheckoutCredentials.ps1 | Existing algorithm needs no change. Raw equality is proved after changing only the origin repository literal; retain TF identity. |

## Retained contract details and limits

D7 keeps exact event-main authority for main pushes/schedules/manual runs and exact main target B for PRs to main. Valid non-main branch/tag pushes and other PR targets acquire literal main from the fixed repository, immediately pin its SHA, and read exceptions there. No candidate/cached-origin fallback. Actual PR scope is target B to tested merge H, separately from main authority A; checkout H must match. Preserve authoritySource and applicability/base/head outputs. ciScope no longer treats an authority argument as its base. A later target fetch must not overwrite the pinned main identity. Ordinary local audit remains fetched origin/main. Snapshots do not discover later revocation or prove continuing freshness.

D2/D4/D5 retain all live pushes including tags/creation, explicit created=true with zero B and exact nonzero H for new refs, snapshot/Node checks, distinct nonzero existing B/H, bounded exact B fetch, full-ref/native syntax checks and main-only publication transitions. Non-main output remains snapshot-only. Accepted-policy pull_request_target stays separate from unprivileged candidate execution and checks metadata before classification. P remains procedural maintenance authority; green classification is not approval. No L helper/fourth check.

D9/F97 preserve nested-only20.20.2, pre-declaration24.18.0/npm11.16.0, pre-declaration24.18.1/npm11.16.0 and declared-current support. Keep regular-file guards, reviewed digests and honest Node-only messages. F97 permits only the finite declaration-absent24.18.1/absent-installer/exact scalar prepare 'cd ../.. && husky' combination, with all other full inputs. Current setup uses the current installer via the same prepare invocation and actual hook checks. A candidate can deliberately edit itself into a supported historical shape; capability detection does not authorize that edit.

Retain full event ancestry, explicit main fetch with three attempts/two-second gaps and exact unchanged event HEAD. Do not discover origin/HEAD. Full-capability setup selects guarded hosted Python3.12 and a fresh temporary venv, performs isolated/hash/binary/index-constrained pip, verifies pinned pre-commit/pip health, activates Husky, runs the full hook set and verifies setup index/worktree against HEAD before/after. D6 keeps curl --disable first plus connect20/max120/retry3/retry-max300/retry-all-errors, HTTPS restrictions and hash-before-extraction.

D9B94 bounds the job59 minutes/full validation45; acquisition5, download8, installs10 and small checks2. Caps are not additive reservations or measured sufficiency. Per-process isolation must work without job.env. Actual Actions setup, actual Copilot setup and phase timing remain separate acceptance evidence. Setup failure can leave the service agent partially prepared; focused fixtures do not prove real installs/service timing. Do not extend or rerun aggregate89382 from this report.

D8 uses native HTTPS-envelope validation, not arbitrary enterprise support or a DNS/IP policy. Exact event Git-tree exclusion is not accepted-base admission or independent PR-head proof. ls-tree -r -t --full-tree --name-only -z preserves nested/case-folded/UTF-8/newline/empty-tree behavior. Native failures are fatal. The embedded detector and positive/negative controls are literally equal between TF and d13:3829bytes/SHA256bb5b1fe9ce539bfcf8e5b1363ea50c294d7abea357f0d97ef222cc9c2cd99d6a (common-block-proof.json).

## Preserve actual Terraform callers and oracles

- Keep the sixth Test-LocalValidation.test.mjs caller and adapt its CLI2 mocks/sentinel under already-selected A07/A21 contracts. Dropping it is not that adaptation.
- Actual artifact chain: build.yml:verify -> Test-StyleGuideArtifacts.ps1 -> Test-StateRecoveryExamples.mjs. The native recovery child runs before generation within integrity snapshots with300000ms timeout. Select the first Node application once; no fallback after failure. Policy/classifier specify the actual helper/closure. There is no invented direct workflow recovery step or pre-commit artifact-gate call in this snapshot.
- Keep recovery-missing/failure/signal/timeout, recovery channel/config/source/self side effects, multiple-node-paths and first-node-failure cases. Retain common stale-byte/verifier-child checks. PS blank-line semantic fixtures do not replace TF recovery semantics. A06/A15/A16/A18 retain later generator/recovery and Windows GateA/B duties.
- The four missing-environment helper checks are present in source at lines286–300, moved from TF's old block: Initialize-CiToolchain RUNNER_TEMP/GITHUB_PATH/GITHUB_ENV and Invoke-MarkdownLint RUNNER_TEMP. Source tests empty values; TF tests whitespace-only values. Preserve both useful classes without duplicating a whole block. This corrects the initial diff-only suspicion of disappearance.
- Preserve TF npm isolation oracles on renamed hook/full-validation steps, including malformed environment names and native status. Candidate tests cover the new dispatch, so compare actual oracles before deleting old tests. Keep selected actual Git/curl/venv/Husky/immutable-input evidence and useful positive devcontainer controls.

## Unchanged duties, budget and execution

Previous handoff responsibilities remain except for concrete interface replacements above: A20 supplies current protected previews/actual TF metadata; A21 supplies the complete accepted engine/SelfTest/manifest/classifier with serialized caller-test integration; A07 supplies package/lock/lint/hook/tooling closure and script/dependency guidance; A02 retains held README/prompt, full owed CONTRIBUTING and .venv ignore delta. Preserve staged -> outer -> nested phases, R96's narrow sentinel removal, A96's exact node lint-markdown.mjs, and no old-TF-engine hybrid. Accepted source does not clear TF's prior FINDINGS audit.

A20 previews were reread/hash-checked at32759/83446/2522 bytes. AGENTS has9 bytes below32768. Preserve both65536 configured limits and16384 reserve. No growth allowance, bypass or effective composed-chain capacity claim follows. Finalize actual TF metadata/date and remeasure. No previews, held docs, planning or counters changed.

After full source acceptance, refresh preimages, assign one TF writer, assemble selected closure and resolve this preflight omission. Then perform affected peer tests, current audit/aggregate, real publication/finalization endpoints, reviews/quality/merge/landed checks and reverse raw-byte/mode comparison. No gate is supplied by this read-only refresh.

## Evidence

identities.json binds mode/blob/length/SHA256 for scoped interfaces and real recovery callers. blobs/ contains immutable extracts; diffs/ are comparisons, not implementation patches. accepted-delta.diff is the11-path PR230 delta; candidate-delta.diff is the3-path pending delta. evidence.json binds prior handoff, acceptance/native evidence, frozen state, protected previews and canonical A01 matrix. Matrix SHA256 matches8bc2605398bd7d436c4bc56e7226762d0811ae0c3a7fc53a6785f74f0d819a9b. No issue census was repeated or fabricated. state-summary.json is a dated read-only excerpt, not lifecycle ownership.

The first comparison script stopped on Windows default decoding after writing only private extracts; explicit UTF-8 corrected it. No product/test impact. Requested gpt-6-astra/high is context only; runtime metadata is not exposed, so effective settings are not asserted.

Coordinator update at handback: root independently verified the pre-install finding, recomputed all eight scores, displayed the decision and selected P98. Root will own canonical D11 publication. The original private proposal remains unchanged; no implementation is performed here.

## Native source blob identities

All entries below are mode100644; full SHA256/bytes are in identities.json.

| Path | Accepted fb blob | Candidate d13 blob | TF06ad blob |
| --- | --- | --- | --- |
| .github/workflows/agent-instructions.yml | a35931f8a7de2c9a8d029c24ba796179399b9a56 | a35931f8a7de2c9a8d029c24ba796179399b9a56 | 7bf29f43ea081e9861ad53ecf0951831bf878075 |
| .github/workflows/build.yml | d499e1f8c2b3a8b6bc7f6af5445aa0ab97d44dc7 | d499e1f8c2b3a8b6bc7f6af5445aa0ab97d44dc7 | 6cbd7f1233baf28ea2242b2a6207b6ebd29ad073 |
| .github/workflows/Check-NpmAudit.mjs | ba9e0327030fa8288924fa5b2894bfcd7f28c75f | ba9e0327030fa8288924fa5b2894bfcd7f28c75f | 10b352c23b4abe1e7cc3b7ba6b1f32a4ea9312a0 |
| .github/workflows/Check-NpmAudit.test.mjs | 47a1831ad93a2d935106639822ddc1a95484be09 | 47a1831ad93a2d935106639822ddc1a95484be09 | 54684b739a74e0c64df50d4a9cd697f0c57b447d |
| .github/workflows/Classify-InstructionMaintenance.test.mjs | dfda67ad00c602280ec716d8407e1816de495452 | dfda67ad00c602280ec716d8407e1816de495452 | c24be2165520a02cb622f47dc03c4e4ad9ddd716 |
| .github/workflows/copilot-setup-steps.yml | 66d7cda6249a8811490742004a90f5eb644ab688 | c6e1fe859dde863586338d59a3be4bf8ab68c293 | de6d55690478deacc6bb58f65f4f437cb43cc87e |
| .github/workflows/devcontainer-ci.yml | dde42437f9f5d579abee2e944321488a2ba4f793 | ade80d635425ce90e6520dfe934aa660eed46321 | bfad83b60e7a808d6f44ae11d4e6fab8d73cfaec |
| .github/workflows/markdownlint.yml | 59054973e607c793e821f0ba21fc32143a716b43 | 59054973e607c793e821f0ba21fc32143a716b43 | e665a1b1e45de4f33b62b64fd75c4974b9156b4d |
| .github/workflows/Test-CiHelpers.test.mjs | 72b634c0664b410bca45d6331718501ff8a476f1 | e6f22852b220933691a4f05b4819d62b678ec0e9 | 7855cc0c1be90096abae979168ed1e282d535998 |
| .github/workflows/Validate-WorkflowPolicy.mjs | 997d9eac5ce93c379179b6ba75d1839cb6eb4f73 | 997d9eac5ce93c379179b6ba75d1839cb6eb4f73 | 995b72a7b48dea2636094d81226893a519950797 |
| .github/workflows/Validate-WorkflowPolicy.test.mjs | 295da6170ae721ca8c02509b308ac3660f66a974 | 295da6170ae721ca8c02509b308ac3660f66a974 | aa1be01df5a3c8b5369bf8e4313089de9c356365 |
| .github/workflows/workflow-policy-cases.json | 5f19dc9175dd7dd3f9eb2cd8369ece8986e29326 | 5f19dc9175dd7dd3f9eb2cd8369ece8986e29326 | 7e63fc866ac9ee62b5cf436ab9d06789c804ae4e |
| .github/workflows/workflow-policy-contract.json | 53d81439e58eb33b95bb1e6f97bc1a124c0b5fac | 53d81439e58eb33b95bb1e6f97bc1a124c0b5fac | 09ccc8139ef8a90da08e75f2c467ac47a0b868ff |

## Canonical publication note

This copy uses LF line endings and adds this note plus the Markdown line-length directive. The original report SHA256 is `ade10913e4d403881786c258b6df4dab3249e5ed6055a6e9999a7a4cb2fa8997`. Other evidence filenames in the report refer to `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A02-peer-post230-readiness-20261004`. The immutable input identities and root verification receipt are retained in this directory. Root selected [D11 P98](../../A03/preinstall-policy-decision.md) after displaying the complete decision process. Implementation remains private until the source aggregate finishes and root verifies the repair.
