<!-- markdownlint-disable MD013 -->
# A15 foundation interface refresh

Read-only preparation, 2026-10-04. A15's selected D1–D6/D3a design remains compatible with the foundations inspected below. No new material contradiction was established. The remaining Windows acquisition, platform jobs, loader closure and collector implementation are already assigned work, not new findings. Complete accepted A03 source and coherent Terraform adoption, then the existing A06/A07 foundation prerequisites, before A16 implementation. This does not require acceptance of the future A16 recovery harness or its D2 workflow integration before that harness can be built. Do not wait for superseded A11 or final A18.

Authenticated GitHub main refs at start were PS `fb3288934215dfa9a25114cf79ad86e60b5fb107`, tree `ed7ad456a7147152d2c289908066195689127e85`, and TF `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`, tree `dc8f6b82588b8f874d34cd5d0155791aea5793f1`. Authenticated end reads returned the same two main commits. Actual Git blobs/modes were inspected from these commits. `identities.json` binds the scoped interfaces with blob IDs, raw lengths and SHA256. Every native identity in A15's existing scope manifest still matches TF06ad, including absences. No checkout text was treated as accepted product evidence.

PS PR231 head `69e1b0d1b0715bfc4025372c7282fe04c38178dc` and staged tree `c82fa2e11bfe333b9bcaf732bf12d1d9cb907380` are unaccepted. The tree differs from accepted PS only in `copilot-setup-steps.yml`, `devcontainer-ci.yml` and `Test-CiHelpers.test.mjs`. Thus its D12/D13 repairs do not change the inspected build, installer, generator, classifier or instruction-validator interfaces. Consume the final accepted helper tests after root's live aggregate and lifecycle; do not copy the old accepted or pending test file wholesale over TF recovery cases.

## Interface map

Paths without a prefix below are in `.github/workflows/`.

| Surface | Accepted interface and A16 integration |
| --- | --- |
| Exact recovery scope | Preserve `scope-manifest.json`: Gate A has 13 recovery-owned changed paths; Gate B has 9. Gate A owns two guide sources, four generated outputs, existing `Test-StateRecoveryExamples.mjs`, new PowerShell harness, Confirm/Inspect/Difference/Resolve helpers and catalog. Gate B adds Prepare and changes its listed sources/outputs/harnesses. Foundation-owner batches are separately scoped. A smaller actual patch or an additional path requires revising that same D1 manifest before implementation; never silently normalize counts or restore the obsolete `.sh`. |
| Metadata manifest | TF already has schema 2, no authorized exemptions, five Tier2 paths and four generated paths; only the language filename differs from PS. New `.mjs`, `.ps1` and catalog `.json` paths do not need document exemptions. Preserve generated provenance for `terraform.instructions.md`. The common historical initializer is restricted to PS commit `a71f16a8d76beeca1ba8fdc3b1c95e1958e0973c` and prior-validator SHA256 `5a61845f756be1d1bc4ddb772ffbc6c71ab525f0394d11d8c672f998a05fb4a5`; it is inapplicable to TF's existing manifest. Do not widen it. |
| A03 build/policy | TF's current chain is `build.yml:verify` → `Test-StyleGuideArtifacts.ps1` → recovery harness; publisher depends on `verify`. Accepted PS broadens push/PR coverage and standardizes publisher/step names. Coherent TF adoption retains role `verify`, publisher `publish_committed_artifacts`, step `generate_style_guide_artifacts`, TF output filename and actual recovery child. The accepted v3 validator permits only its finite verifier role plus publisher, Linux code jobs, exact step cardinality and scalar publisher dependency. Adding Windows jobs therefore requires the already-selected D2 coordinated validator/cases/tests change; merely adding YAML jobs will fail. Keep empty code-job permissions, same exact revision and fail-closed publication dependencies on every mandatory Linux/Windows result. Keep the current action contract unless its actual inputs change. |
| A06 generation/artifacts | Generator has a 5.1 syntax floor; artifact verifier requires PowerShell 7.0 and is currently Linux recovery-aware. Its first resolved Node application is fixed before repository children; failure does not try a second Node. Recovery runs before generation with a 300000 ms child timeout inside worktree/Git/runner-channel integrity checks. Retain this closure, exact four output mappings and `Test-ExactGitPathSet.ps1`; new imports are covered by whole-worktree inspection, not a new helper hash ledger. A06 must integrate caller/gate/platform admission and imported-input mutation negatives. Its selected frontmatter spacing comes from the generator. Adjust runtime budget only after measured fixture evidence and the existing decision process. |
| A07 toolchain | Both root manifests declare exact Node 24.18.1/npm 11.16.0. Both `ci-toolchain.json` files contain only Linux x64 archive SHA256 `d6c664df3f3f61458e8c277585571328522d705166723a7c7823a9253a4d15a0`. `Initialize-CiToolchain.ps1` requires PowerShell 7.3, explicitly rejects non-Linux, requires RUNNER_TEMP/GITHUB_PATH/GITHUB_ENV, and offers only `-WorkflowDependencies`/`-InstructionDependencies`. It verifies archive/version, runs package-policy preflight before locked script-disabled installation, and preserves manifest/lock bytes. It cannot run in 5.1 or provision Windows. A07 must supply reviewed exact Windows acquisition and the required Linux compatibility runtime; ambient runner Node and local probe availability are not that evidence. |
| A21 admission closure | Accepted PS classifier explicitly selects the existing recovery harness and artifact/generator callers but none of the seven new T4 paths. Add exactly the seven paths from `T4NewLoaderClosure`, including future Gate B Prepare, to the complete common classifier and test isolated additions, case aliases and mixed additions. This planned closure work preserves later admission when a helper changes alone. A listed caller change already makes the initial coherent change maintenance; classifier output is never human authorization. |
| Package/script/hooks | Root scripts remain bootstrap, outer/nested lint and instruction SelfTest; neither package contains a recovery test script. Node built-ins and the embedded Windows adapter require no new npm dependency. Keep the existing direct artifact-helper recovery call and planned direct Windows harness calls; an extra package alias is unnecessary. Preserve A07's accepted lint wrapper/lock/hook changes during TF adoption, including TF's `Test-LocalValidation.test.mjs`. The existing JSON hook selects the catalog; the normal aggregate includes workflow-policy and instruction SelfTest/staged matching, but does not replace platform recovery execution. Do not add an unowned package/hook edit to A16's 13 paths. |

## Staging and ownership sequence

1. Accept the shared foundations through their existing lifecycles: A03 source/coherent TF adoption, A06 generator and artifact verification with the existing TF Linux T2 semantic child, and A07 dependency/runtime foundations. A06's Windows generator tests are their own prerequisite evidence; they are not the future Windows recovery gate. Independently usable runtime acquisition and admission preparation remain with their assigned owners.
2. Once A15 preparation and those prerequisites are accepted, A16 implements its selected recovery-owned 13-path batch against the refreshed accepted interfaces. Supply the real PowerShell harness and collector before enabling a caller that requires them. Preserve separately scoped A03/A06/A07/A21 ownership; A16 does not take their paths.
3. Root serializes the dependent integration batches into a coherent candidate: A07 supplies any remaining reviewed recovery-runtime acquisition, A21 closes the new loaders, A06 binds the actual harness/semantic inputs, and A03 adds the D2 Windows jobs, policy negatives and publication dependencies. Validate the combined candidate with the real harness present. Do not merge enabled jobs that call absent files, treat a disabled/placeholder job as passing, or require these future recovery results to start step 2. The 13-path count remains A16's batch, not the union of all owners' integration paths. Existing decisions do not prescribe a new PR partition here.
4. Finish the normal lifecycle and actual same-revision platform evidence for that coherent result. Then request the real Gate A approvals. Gate A acceptance, unlike permission to start A16 implementation, requires completed D2 recovery integration. A17 starts only after that acceptance.

This is dependency sequencing under existing selections, not a new scope or gate decision. Canonical anchors under `docs/planning/action-items-2026-10-02/`: `results/A06/design.md:84` expressly separates the future A15 Windows recovery gate; lines103–107 retain current T2 admission and assign future recovery publication gating; `results/A15/read-only-design.md:124,146,148` retain foundation ownership and select coordinated D2 integration; `results/A15/scope-manifest.json:59–106,117–121` assign integration paths and require separately scoped serialized batches; `tasks/A16.md:7,23,33` distinguish implementation prerequisites, the work to build, and final Gate A acceptance.

## Runtime and proof obligations

Keep the closed D5 cells: A-L22/A-L24/A-W51/A-W7 and B-L22/B-L24/B-W51-helper/B-W7-helper. L22's exact minor/build/digest is still an A07 input; its compatibility harness run must not masquerade as ordinary root npm setup under Node 22. L24 uses the exact preferred declaration. Windows needs actual 5.1 and 7 executions with reviewed exact OS/PowerShell/Node/npm/tool/storage identities. The current local probe's 5.1.26100.9549/.NET4 and 7.6.5/.NET10.0.11 evidence establishes only its stated sharing/raw-byte primitives. It does not pin future hosted environments or prove the selected collector.

The current Linux harness explicitly fails off Linux, below Node22, or without jq; missing support is not a skip-pass. Preserve supported Bash5/GNU/jq semantics and all eight SR source blocks/seven provider actions. Required unavailable, missing, skipped, duplicate or inapplicable-as-success cells must prevent gate approval/publication. B Windows cells prove helpers, not a Windows destructive procedure.

A16 must implement the canonical `SM-BACKUP-PULL-PS` embedded Win32/.NET collector, with the PowerShell harness extracting that exact block. Keep the common Node tokenizer and fixed policy/validate-captured interface; never capture through Node while the exclusive writer is open. Retain separate roles and explicit identity tuples, creation-time private Job Object assignment, 5000 ms bounded termination/drain, full stream/identity evidence and no fallback on unsupported Windows facilities. D3a's supported host floor and no-orphan proof remain implementation obligations. Freeze all A/B catalog definitions in A, but execute no B procedure or mutation stub in A.

Reuse the single 31-row acceptance table and corrected D5 mapping; no recount or new case allocation was performed. Retain T2 cleanup status74 separately from T4 cleanup72, primary/signal precedence, uncertain-evidence retention and all SR regression oracles. In `Test-CiHelpers.test.mjs`, preserve recovery missing/failure/signal/timeout, channel/config/source/self side effects, multiple Node paths and first-Node failure; retain both empty and whitespace environment negatives. PS blank-line fixtures cannot replace TF recovery semantics. Retain existing six Node-suite callers. Gate A must prove zero mutation child calls and complete applicable results; A17 carries the remaining mutation fixture obligations and final source/generated sweep.

## Verification commands for the later writer — not executed here

Refresh B from the accepted native TF target; H is the final committed candidate. Both must be full lowercase commits. Use separate unchanged B and proposed H checkouts with their own locked dependencies. Do not transplant candidate executables into B.

From accepted B, classify inert H:

```powershell
node .github/workflows/Classify-InstructionMaintenance.mjs $PWD.Path $B $H
if ($LASTEXITCODE -ne 0) { throw 'Accepted classification failed.' }
```

For first adoption from TF06ad, use its existing maintenance route and the A02 adoption-readiness report. Old B lacks `-MetadataClassificationOnly`, `-FinalizeMetadataNow` and `-ProposedPolicy`. Its ordinary full `-InputRevision $H -PublishedBaselineRevision $B` checker is not a new mandatory maintenance-admission gate. After the common engine is accepted in TF, accepted-B metadata admission is:

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-AgentInstructions.ps1 -MetadataClassificationOnly -InputRevision $H -PublishedBaselineRevision $B
```

Use that accepted-B engine's `-FinalizeMetadataNow -InputRevision $H -PublishedBaselineRevision $B` for its distinct date/transition check when applicable. It validates; it never writes metadata. During first-adoption authoring, use the complete proposed local engine with `-RequireStagedInputMatch` while its real HEAD is B. From the final H checkout, preserve explicit candidate diagnostics:

```powershell
pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-AgentInstructions.ps1 -ProposedPolicy -InputRevision $H -PublishedBaselineRevision $B
if ($LASTEXITCODE -ne 0) { throw 'Proposed transition diagnostics failed.' }
```

Run only affected tests after integration; root owns the required aggregate. These existing commands are concrete entry points, not evidence of execution:

```powershell
node --test .github/workflows/Classify-InstructionMaintenance.test.mjs .github/workflows/Validate-WorkflowPolicy.test.mjs .github/workflows/Test-CiHelpers.test.mjs .github/workflows/Test-LocalValidation.test.mjs .github/workflows/NpmTools.test.mjs .github/workflows/Check-NpmAudit.test.mjs
node .github/workflows/Validate-WorkflowPolicy.mjs .github/workflows/build.yml .github/workflows/markdownlint.yml
pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Generate-StyleGuideArtifacts.ps1
```

Perform AC29's second generation and compare raw four-output bytes; inspect and commit actual generated changes before the clean-checkout artifact verification. On a disposable clean Linux checkout with the reviewed runtime/environment, invoke `pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-StyleGuideArtifacts.ps1`; this already executes the recovery harness, so do not immediately duplicate it under the same runtime. Use `& $Node22 .github/workflows/Test-StateRecoveryExamples.mjs` for the separate required L22 compatibility cell, where `$Node22` is the reviewed exact executable. Preserve explicit native-status checks for every command.

After the new PowerShell harness exists, the planned no-argument entry points are `& "$env:WINDIR/System32/WindowsPowerShell/v1.0/powershell.exe" -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-StateRecoveryPowerShell.ps1` and `& $Pwsh7 -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-StateRecoveryPowerShell.ps1`. `$Pwsh7` must resolve to the reviewed build. These are prospective harness calls, not currently implemented public APIs; finalize the exact gate/cell admission with A03/A06/A16 and reject unsupported combinations. Do not invent a passing CLI flag or use an execution-policy bypass.

At each recovery-owned batch, compare the complete staged path set to the applicable canonical Gate list after generation. At publication, bind actual H/test-merge/landed identities to their own checks; local H diagnostics do not substitute for native merge checks. Obtain exact-run Linux and both Windows results before publication approval.

## Human boundary and handback

D08 already authorizes the clear selected design winners. Do not re-request those choices. After implementation and actual platform/failure/race/secret/build evidence, obtain the accountable operator and independent peer's Gate A approval on the exact commit/tree, helper/version identities, roles, catalog, limits, platforms and results. A17 cannot start before that approval. Gate B needs separate real approvals bound to Gate A and its final commit. Changed approved inputs—including whole source/harness blobs when that is their approval binding—return to Gate A; region equality is not an automatic waiver.

No product/planning/index/config/GitHub/lifecycle mutation, installation, test replay, review request or infrastructure operation occurred. Only this report and scoped identities were written in the assigned private directory. No product, gate, prerequisite or overall acceptance is claimed.
