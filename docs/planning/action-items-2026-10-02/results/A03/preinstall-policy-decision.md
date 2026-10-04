<!-- markdownlint-disable MD013 -->
# A03-D11: preserve policy checks before package installation

Selected P98 on 2026-10-04. Root independently inspected the actual caller, classifier, NpmTools and validator, verified all eight score totals, and displayed the validated finding, options, distinct rubric, complete table and selected instructions before implementation. This decision preserves D6, D8 and D9, including F97. No implementation or runtime validation is claimed at selection.

## Validation and concrete lost property

At TF `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`, `.github/workflows/copilot-setup-steps.yml`'s `Install locked Node.js validation tools` body runs `node .github/workflows/Validate-WorkflowPolicy.mjs --preflight` when `.github/workflows/ci-toolchain.json` is a regular file. `set -euo pipefail` precedes it. Both `npm ci` calls follow it. The candidate `d13fff62fdfb88dbb2fadad77d852329f92bfe22` omits this call and invokes npm directly at lines642/647.

The validator's built-in-only `main` calls `readContract()`, `validateParserLock(contract)`, and `validatePackages(revision)` before returning preflight success. `loadYamlBindings` occurs only afterward in non-preflight mode. Package checks enforce exact manifest/lock pairing, lockfile v3, ordinary bounded inputs, finite package paths, no workspaces/bundles/links, registry tarball URL shape and integrity shape, plus the parser version/resolved/integrity agreement with the contract. This is candidate-local setup validation, not accepted-base authority.

A concrete static witness is a committed declared-current tree with all regular setup inputs and unchanged runtime tuple, but a mismatched parser `resolved` or integrity field between the workflow contract and nested lock. The existing preflight rejects with `parser-lock-identity` before npm installation. Candidate pre-install steps do not read `workflow-policy-contract.json` at all, so they cannot compare that relation. A contract-only mismatch need not change either npm manifest/lock pair. This validates lost policy ordering without claiming an executed reproduction, a malicious download, or that npm has no independent consistency checks.

Transitive inspection: acquisition and credential cleanup establish Git identity; alternate-input rejection excludes npmrc/shrinkwrap; finite classification checks file kinds, runtime declaration syntax and historical tuple/prepare text; immutable-input checks compare committed/index/worktree bytes; Node setup checks reviewed archive/runtime identity; npm environment filtering removes ambient config. None checks the contract/parser relation or full package registry closure. The workflow does not call `NpmTools.mjs`, `Initialize-CiToolchain.ps1`, or an install wrapper. The inspected NpmTools guard checks regular files, alternate inputs, versions and unchanged bytes, not this relation, and is not invoked here. `npm ls` follows installation. Hook activation and full pre-commit validation follow both installs. Later checks cannot preserve rejection before the first install. A separate parallel workflow is neither a same-job predecessor nor a substitute for this ordering.

No preflight retirement or equivalent temporal control was found in canonical D9, its F97 refinement, D3, or remaining-interfaces. D9 preserves useful TF setup validation and supports finite historical layouts. The issue is a real retained-interface omission, not a request to duplicate every old call.

## Stakeholders and options

Dependency/security maintainers need invalid contract/lock relationships rejected before installing tools; this is a useful supply-input check within unprivileged candidate execution, not a new trust root. Current and historical contributors need complete setup without breaking intentionally supported old layouts. Both maintainers and reviewers need one common implementation and clear causal failures. QA needs command-order and negative oracles with honest substitutions. Agent users and the UX owner need immediate actionable setup diagnostics; operators need the existing finite time budget. No protected prose, settings, credentials, customer data or recovery procedure changes are implicated.

Options, before scoring:

- N: keep d13 and silently lose pre-install policy checks. No implementation cost, but it leaves the documented preservation obligation unresolved.
- P: reuse the existing preflight call in the common Copilot install body, before either npm ci, guarded by the runtime declaration exactly as the retained TF caller. Keep D9's earlier fail-closed classifier and historical branches.
- U: run preflight unconditionally. Simpler guard, but historical layouts without root inputs or a compatible policy helper can fail; this contradicts retained compatibility.
- T: retain the guarded call only in Terraform. Preserves TF behavior but creates an unnecessary common-code exception and delays reverse alignment.
- S: duplicate a subset of parser/lock checks in the workflow. Could cover this witness but creates a second validator and risks omitting other retained checks.
- L: rely on npm ls/full validation after installation. May catch later failures, but cannot preserve the temporal guarantee.
- R: explicitly retire the pre-install guarantee after a new merits decision, retain later checks and describe the loss. Honest but no demonstrated benefit outweighs reusing the existing small built-in-only call.
- E: run an accepted-base external policy producer before setup. Stronger potential authority separation, but substantial orchestration and historical-compatibility work beyond this missing candidate-local check.

P already combines common code, native reused validation and the finite historical exception. P plus unconditional historical enforcement is U. Factoring a new helper merely relocates P or S. Deferral leaves N's concrete gap pending; neither an unchanged pending aggregate nor old passing suites can decide it.

## Distinct correctness-heavy rubric

Scores1–5, higher is better. Pre-install correctness35: actual policy checks precede all npm installation and fail closed. Supported-tree correctness25: retained current and historical capability contracts remain usable. Common semantic coverage20: reuse all retained checks without unjustified divergence. Observable failure10: exact phase, propagation and meaningful negative oracles. Continuing cost10: limited implementation/review/runtime burden. Totals are weighted sums divided by5, engineering judgments rather than measurements.

Hard constraints: no new permission/token/authority; no invented accepted-base claim; preserve D9 finite historical layouts; keep D6 and existing phase limits; no silently dropped retained control; no product change during aggregate89382.

| Option | Pre-install35 | Trees25 | Common20 | Failure10 | Cost10 | Total | Assessment |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 1 | 5 | 1 | 2 | 5 | 50 | Unresolved loss |
| P | 5 | 5 | 5 | 5 | 4 | 98 | Recommended |
| U | 5 | 1 | 5 | 4 | 5 | 78 | Fails historical constraint |
| T | 5 | 5 | 2 | 4 | 4 | 84 | Unnecessary shared-code difference |
| S | 4 | 5 | 3 | 4 | 2 | 77 | Duplicate partial policy |
| L | 1 | 5 | 2 | 3 | 5 | 56 | Temporal property absent |
| R | 1 | 5 | 2 | 4 | 5 | 58 | Explicit regression without sufficient benefit |
| E | 5 | 3 | 4 | 3 | 1 | 74 | Larger authority/orchestration change |

## Selected P98

Preserve the existing guarded preflight in the common setup flow. Place it after runtime/environment preparation and before the first npm ci. Call the existing built-in-only validator. Propagate failure without installing either npm tree. Keep the guard on the runtime declaration; do not require this newer helper in the retained declaration-absent historical layouts. Do not add an override flag or relax the common validator. Keep all other D6/D8/D9 behavior and time limits.

Prepare the repair in an isolated private copy. After the running aggregate terminates and root verifies the patch, make the smallest repair in Copilot YAML and the existing CI-helper tests. Actual call-body tests should prove preflight success precedes both installs, preflight failure prevents both, and the retained declaration-absent branch skips only this newer preflight while retaining its selected setup. Execute the actual Copilot install body with the real built-in-only preflight and an npm sentinel. A parser-contract/lock mismatch and a nonregistry lock entry must each fail with no npm invocation recorded and no installed yaml required. Include a negative control removing or moving the guard/call. Preserve all six actual historical snapshot classifications. An npm probe may record order without downloading packages; disclose that substitution. Refresh only validation invalidated by the eventual changed input, then complete normal source review/quality/native setup/timing/landed acceptance before TF implementation.

This worker selected no implementation, ran no tests, and measured no performance. The report proposes P98 for root verification/display. The candidate d13 remains unaccepted and frozen; the accepted fb328 source batch remains accepted. Later full A03 and paired acceptance remain required.

## Evidence provenance and implementation boundary

The private proposal SHA256 is `44d7855605ff3f566509b666250379563aa7d278559624b0fc6f6216b4f9b719`. Its author performed read-only source inspection. The root selection above supersedes its pending-selection wording. The preflight must also reject a non-registry package URL before either npm call. Tests must execute the actual preflight with its policy inputs and prove that no installed YAML package is required. An npm sentinel can record command order without network installation; record that limit. A passing aggregate on d13fff6 does not accept the repair. Keep that run and its evidence intact, then validate the final repaired input. No new owner approval, permission, token or repository-transfer increment is required for this same-source repair.
