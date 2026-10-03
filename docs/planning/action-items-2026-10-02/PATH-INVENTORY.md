<!-- markdownlint-disable MD013 -->
# Full native-main path inventory

## Current refresh: 2026-10-03

PS main `a71f16a8d76beeca1ba8fdc3b1c95e1958e0973c` has 72 paths; TF main `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c` has 75. The complete union is **83 paths = 9 equal + 55 different + 8 PS-only + 11 TF-only**. [Dated raw entries and current owners](results/A01/native-tree-union-20261003.json) cover every path, including the two additions below. The ten changed PS paths match merged PR225. [A01 acceptance](results/A01/CURRENT-REFRESH-20261003.md) records independent verification and bounded reuse of issue, historical absence and conditional-risk evidence. PR224 retains its eleven in-flight paths until merge.

| Added path | Raw status | Outcome owner | Exception |
| --- | --- | --- | --- |
| `.github/workflows/lint-markdown.mjs` | PS-only | A07 | none approved |
| `.github/workflows/lint-markdown.test.mjs` | PS-only | A07 | none approved |

## Historical 81-path baseline and post-PR224 ownership

PS `48f4d8a36c8faceee12afac78aaecea0d176125d`: 70 entries. TF `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`: 75 entries. Union: **81 paths = 9 equal + 55 different + 6 PS-only + 11 TF-only**. Complete raw blob IDs/modes are in [tree-union.json](evidence/tree-union.json); every path has an owner in [path-ownership.json](evidence/path-ownership.json). No product equality is claimed by this plan.

This snapshot uses native main Git objects, not the planning checkout. The planning branch and its task files are not part of the main/main product comparison and must never be merged into main. At execution, rebuild the union; do not use this list as an exclusion filter. The known counterpart mappings are powershell.instructions.md â†” terraform.instructions.md and the P1/T1 supply documents. A counterpart mapping is not an exemption.

Language guides, scoped generated outputs, real repository URLs and immutable historical facts are exception candidates. Mixed files must retain common-byte equality outside the exact necessary regions. LICENSE text is not a language-specific exception by default. No directory-wide exclusion is accepted. See LOOP-POLICY.md for required evidence and historical absence checks.

Ownership below names the post-PR224 owner. PR224 retains its exact in-flight paths until merge; A07 may not touch Invoke-MarkdownLint.ps1 or MARKDOWN-LINTING-IMPLEMENTATION.md before then. Unchanged common files outside PR224 and its explicit handoffs belong to A18's final comparison. The four exception classes in LOOP-POLICY still require per-path proof.

| Path | Raw status | Outcome owner | Exception |
| --- | --- | --- | --- |
| `.claude/commands/review-loop.md` | different | A08 | none approved |
| `.codex/config.toml` | equal | A18 | none approved |
| `.gitattributes` | equal | A18 | none approved |
| `.github/copilot-instructions.md` | different | A20 | none approved |
| `.github/dependabot.yml` | equal | A03 | none approved |
| `.github/document-metadata-classification.json` | TF-only | A21 | none approved |
| `.github/instructions/docs.instructions.md` | different | A18 | none approved |
| `.github/instructions/yaml.instructions.md` | different | A05 | none approved |
| `.github/workflows/.markdownlint.jsonc` | equal | A07 | none approved |
| `.github/workflows/Check-NpmAudit.mjs` | different | A07 | none approved |
| `.github/workflows/Check-NpmAudit.test.mjs` | different | A07 | none approved |
| `.github/workflows/Classify-InstructionMaintenance.mjs` | different | A21 | none approved |
| `.github/workflows/Classify-InstructionMaintenance.test.mjs` | different | A21 | none approved |
| `.github/workflows/Generate-StyleGuideArtifacts.ps1` | different | A06 | none approved |
| `.github/workflows/Get-SupplyFreezeDigest.mjs` | different | A09 | none approved |
| `.github/workflows/Get-SupplyFreezeDigest.test.mjs` | different | A09 | none approved |
| `.github/workflows/Initialize-CiToolchain.ps1` | different | A04 / A07 | none approved |
| `.github/workflows/Invoke-LockedPythonHook.ps1` | TF-only | A07 | none approved |
| `.github/workflows/Invoke-MarkdownLint.ps1` | different | A07 | none approved |
| `.github/workflows/MARKDOWN-LINTING-IMPLEMENTATION.md` | different | A07 | none approved |
| `.github/workflows/NpmTools.mjs` | equal | A07 | none approved |
| `.github/workflows/NpmTools.test.mjs` | different | A07 | none approved |
| `.github/workflows/Test-AgentInstructions.SelfTest.ps1` | PS-only | A21 | none approved |
| `.github/workflows/Test-AgentInstructions.ps1` | different | A21 | none approved |
| `.github/workflows/Test-BlankLineExamples.ps1` | PS-only | A18 / A16–A17 | none approved |
| `.github/workflows/Test-CheckoutCredentials.ps1` | different | A03 | none approved |
| `.github/workflows/Test-CiHelpers.test.mjs` | different | A03 | none approved |
| `.github/workflows/Test-ExactGitPathSet.ps1` | different | A06 | none approved |
| `.github/workflows/Test-LocalValidation.test.mjs` | TF-only | A07 | none approved |
| `.github/workflows/Test-StateRecoveryExamples.mjs` | TF-only | A18 / A15–A17 | none approved |
| `.github/workflows/Test-StyleGuideArtifacts.ps1` | different | A06 | none approved |
| `.github/workflows/Validate-WorkflowPolicy.mjs` | different | A03 | none approved |
| `.github/workflows/Validate-WorkflowPolicy.test.mjs` | different | A03 | none approved |
| `.github/workflows/agent-instructions.yml` | different | A03 | none approved |
| `.github/workflows/build.yml` | different | A03 | none approved |
| `.github/workflows/ci-toolchain.json` | equal | A07 | none approved |
| `.github/workflows/copilot-setup-steps.yml` | different | A03 | none approved |
| `.github/workflows/devcontainer-ci.yml` | different | A03 | none approved |
| `.github/workflows/historical-supply-profile.json` | different | A09 | none approved |
| `.github/workflows/install-husky.mjs` | different | A07 | none approved |
| `.github/workflows/lint-nested-markdown.js` | different | A07 | none approved |
| `.github/workflows/lint-staged-markdown.mjs` | different | A07 | none approved |
| `.github/workflows/markdownlint.yml` | different | A03 | none approved |
| `.github/workflows/npm-risk-exceptions.json` | equal | A07 | none approved |
| `.github/workflows/package-lock.json` | different | A07 | none approved |
| `.github/workflows/package.json` | different | A07 | none approved |
| `.github/workflows/scripts-README.md` | different | A07 | none approved |
| `.github/workflows/workflow-policy-cases.json` | different | A03 | none approved |
| `.github/workflows/workflow-policy-contract.json` | different | A03 | none approved |
| `.gitignore` | different | A02 | none approved |
| `.husky/pre-commit` | different | A07 | none approved |
| `.pre-commit-config.yaml` | different | A07 | none approved |
| `.vscode/settings.json` | different | A18 | none approved |
| `ACKNOWLEDGMENTS.md` | different | A18 | none approved |
| `AGENTS.md` | different | A20 | none approved |
| `CLAUDE.md` | different | A20 | none approved |
| `CONTRIBUTING.md` | different | A02 | none approved |
| `LICENSE` | different | A18 | none approved |
| `README.md` | different | A02 | none approved |
| `STYLE_GUIDE.md` | different | A18 / A16–A17 | none approved |
| `STYLE_GUIDE_CHAT.md` | different | A18 / A16–A17 | none approved |
| `STYLE_GUIDE_FULL.md` | different | A18 / A16–A17 | none approved |
| `STYLE_GUIDE_RATIONALE.md` | different | A18 / A16–A17 | none approved |
| `copilot-instructions.md` | different | A18 / A16–A17 | none approved |
| `docs/ISSUE_EVALUATION_PROMPT.md` | different | A02 | none approved |
| `docs/P1-SUPPLY-FREEZE-v1.md` | PS-only | A09 | none approved |
| `docs/T1-SUPPLY-FREEZE-CURRENT-PROVENANCE-v1.md` | TF-only | A09 | none approved |
| `docs/T1-SUPPLY-FREEZE-v1.md` | TF-only | A09 | none approved |
| `docs/decisions/0001-accept-generated-artifact-lint-lag.md` | TF-only | A09 | none approved |
| `docs/decisions/0001-accept-in-repository-trust-root.md` | PS-only | A09 | none approved |
| `docs/decisions/0002-accept-repository-code-in-the-write-enabled-job.md` | TF-only | A09 | none approved |
| `docs/decisions/0002-accept-unverifiable-baseline-provenance.md` | PS-only | A09 | none approved |
| `docs/decisions/0003-accept-required-check-workflow-edit-residual.md` | TF-only | A09 | none approved |
| `docs/dependency-maintenance.md` | different | A07 | none approved |
| `package-lock.json` | different | A07 | none approved |
| `package.json` | different | A07 | none approved |
| `powershell.instructions.md` | PS-only | A18 / A16–A17 | none approved |
| `requirements-dev.txt` | TF-only | A07 | none approved |
| `samples/test-nested-markdown-linting.md` | equal | A07 | none approved |
| `samples/test-recursive-nested-markdown.md` | equal | A07 | none approved |
| `terraform.instructions.md` | TF-only | A18 / A15–A17 | none approved |

## Current native refresh after PR224

The [post224 native inventory](results/A01/CURRENT-REFRESH-POST224.md) pins PS3ba0f4d and TF06ad4f7:83 paths,10 raw-equal,55 different,8 PS-only,10 TF-only. The manifest is now shared/different and .gitignore is equal. All83 existing owners remain; eleven changed source paths map to A21five, A07one, A03one and A02four. Earlier tables remain dated history. Landed source acceptance is a separate CI gate.
