<!-- markdownlint-disable MD013 -->
# PS Linux final validation packet

Prepared 2026-10-06T18:57:56.135935+00:00 for root review. `prepared=false` and `execution_authorized=false`; no product test, container, launcher, installation, payload import or old qualification test ran. Root alone qualifies the new source-specific code and authorizes a separate manifest. No product/dependency/Git/planning/state writes or counter changes occurred.

## Candidate and commands

Actual PS worktree: `C:/Users/flesniak/.codex/worktrees/a06-generator-convergence/PSStyleGuide`, branch `codex/tf68-compareback`. HEAD/accepted B `98177628b7bc02c646724bfc8aa0fd73fed0cd24`, baseline tree `fd66ed6c5b94d8c012a0aa06c8d30f2ae16746c6`, exactly ten staged paths, candidate/index tree `a716a1f8ff7e4f385e089b0f056adbcde9c973cb`, no unstaged changes. Landed accepted TF source M `a840f21b03f0dcac0815e2f7f044928667402b42`, tree `e71b81232ba0f197acf5f126e4b14f1e90ee7da2`. Manifest binds the actual origin, branch, genuine 2026-10-06 finalization date, 78-source catalog and qualified 1,914-dependency catalog. Future UTC-date drift refuses execution; no clock override. Root rebinds actual committed B/H endpoints after normal commit.

One execution, if later released, contains exactly these three commands in the isolated private candidate repository:

```text
300s: pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-AgentInstructions.ps1 -RequireStagedInputMatch
3600s: node --test --test-reporter=tap .github/workflows/Classify-InstructionMaintenance.test.mjs .github/workflows/Validate-WorkflowPolicy.test.mjs .github/workflows/Test-CiHelpers.test.mjs .github/workflows/NpmTools.test.mjs .github/workflows/Check-NpmAudit.test.mjs .github/workflows/Test-LocalValidation.test.mjs .github/workflows/lint-markdown.test.mjs
3000s: /opt/psstyleguide-runtime/venv/bin/python -m pre_commit run --all-files
```

The seven test files are the complete current `agent-instructions.yml` selection in exact order. The existing `--test-reporter=tap` flag only selects bounded, strictly counted receipts; root accepted this reporting choice. Node must report exactly 600 passing tests with zero failed/cancelled/skipped/todo. The classifier's 13 tests are included once; no separate classifier repeat. The aggregate must pass all 11 hooks with zero skipped hooks and includes full SelfTest. No hook body, security checks or product timeout meaning is lowered.

## Mechanical adaptations from the qualified TF runner

`SOURCE-DIFFS.patch` is the complete meaningful payload/manifest difference. `common.py`, `ownership.py` and `settlement.py` are byte-identical to qualified C88/D93 files. Adapted `inside.py` selects the full PS suite and records the first-comment hook-profile identity. Adapted `launch.py` binds actual PS branch/origin/catalog, requires the real staged index to match candidate a716, and compares the complete accepted-base/candidate path union including the new review workflow; it removes the stale two-unstaged-path assumption. Container names and manifest identities are PS-specific. No generic framework or ownership redesign is added.

The pinned image's hook-profile file must hash `fd7cc87c8da07a7fa5138dcf1ce4a3b85d2e089ddab452db753782d29b211112`. Exactly one first comment `# Pre-commit configuration for TerraformStyleGuide.` is replaced with `# Pre-commit configuration for PSStyleGuide.` for comparison, yielding actual PS hash `05a6616918d519d654041f6683e380b9fbf0c308bd58fd88118615e53607a738`. Read-only raw comparison proves every remaining byte/hook body identical. All requirements and locked hook launcher profile inputs remain exact-byte checks. Dependencies are the actual root-qualified PS installation; the two generated `.package-lock.json` root identities remain PS names, explicitly catalog-bound rather than overwritten with TF bytes.

## Preserved ownership and bounds

Offline Linux image `sha256:8bdc7722fc55e19fd3df48d8fddf4568a75d8792cfc4ee105c8a8173559362f4`, pull-never/network-none; actual runtime checks require PowerShell7.6.3, Node24.18.1, npm11.16.0 and Python3.12.3. The 7,200-second container budget, 300/3,600/3,000-second stage budgets, 30-second internal terminal reserve, 8MiB stream and 64MiB output bounds retain the prior full-suite Node ceiling and current final-aggregate ceiling; they are ceilings, not runtime promises. The separate hosted service20-minute limit is not changed.

Setup subprocesses are synchronous, retain their own waits and settle after setup; the container parent is a verified subreaper. Direct Popen status belongs only to its Popen owner. Command/final ownership receipts traverse ancestry, including escaped groups/sessions. Reap proven already-exited owned children before residue judgment, accepting only exact exit-zero/no-signal waits and final emptiness. Nonzero/signaled exits, live descendants, unknown/missing/ambiguous ownership or waits, collection errors or cleanup failures fail closed even if eventual cleanup is empty. Live children are cleaned with identity-checked pidfd signals; primary test failures remain primary, with secondary cleanup failures separately recorded. Host cleanup checks the exact image+manifest label, removes only the owned container and confirms absence on every exit. Source/dependency/index/refs/config/mode guards remain before and after commands and terminally. No manual clearing, restaging or reset masks drift.

The unchanged D93 helper has four completed real controls: normal direct ownership, exited adoption, escaped live-session cleanup and primary-error preservation. The unchanged settlement filter has ten completed pure positive/negative controls (exit-zero/empty accepted; nonzero/signaled/live/eventual-empty/signals/missing-wait/unknown-owner/collection-error/residue refused). `evidence.json` binds their original verified receipts and byte-identical helpers; no old controls or syntax scripts are replayed. The old cold packet remains failed; its historical process states remain unknown. Separately verified successful C88 full validation is reuse evidence for the runner, not a destination pass.

## Root qualification plan

Read the exact manifest/diff and source binding; compile the two adapted Python files only, using `compile(read_bytes(), filename, 'exec')` without imports or execution. Verify manifest/payload hashes before and after and preserve any syntax failure. No unchanged helper/control rerun is needed. Root supplies `ROOT-READINESS.json` and its hash, true current-base/policy/dependency assertions, `prepared=true` and explicit execution authorization in a separately hash-bound manifest before invoking the launcher. This preparation grants none of those actions. Root owns Windows focused checks, release, endpoints/audit, commits, reviews/CI, state and acceptance.

Current transfers2/4/6/6 of12 are inherited root-recorded facts. No new PR/request is made; dedicated-service activation remains a separate S1/task/paired acceptance obligation.

Root factual preparation correction: the original unexecuted packet used the TF final 13-test budget for the full600 suite. Restore the previous PS/TF full-suite3600-second ceiling and derive7200 total with30-second terminal reserve. Product limits and cleanup judgments stay unchanged. Original preparation is preserved in preparation-v1.
