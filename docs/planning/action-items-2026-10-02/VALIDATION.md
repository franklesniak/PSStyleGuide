<!-- markdownlint-disable MD013 -->
# Plan validation

Product work has not been executed by this planning change. The validation scope is requirement/issue/path coverage, original-contract integrity, dependency order, links, model recommendations, decision arithmetic, loop limits, Markdown formatting and publication scope. Raw comparison verifies the current difference inventory, not final product convergence.

## Environment and checks

Windows PowerShell host; Python **3.13.14**, Node **26.10.0**, Git **2.55.0.windows.5**; installed markdownlint-cli2 **0.20.0** / markdownlint **0.40.0**. Commands run from the PSStyleGuide planning checkout.

| Check | Command or method | Result |
| --- | --- | --- |
| Plan integrity | `python docs/planning/action-items-2026-10-02/verify-plan.py` | PASS: 20 unique active tasks, 402 original body hashes, acyclic dependencies, five issue owners, 81 path owners, local links, supported snapshot routes, completion counts and decision arithmetic |
| Markdown | `node .github/workflows/node_modules/markdownlint-cli2/markdownlint-cli2-bin.mjs "docs/planning/action-items-2026-10-02/**/*.md" "docs/planning/action-items-2026-10-02.md" "docs/planning/coding-agent-loop.md" "docs/planning/coding-agent-loop-without-model-routing.md" --config .github/workflows/.markdownlint.jsonc` | PASS: 440 Markdown files, zero errors |
| Raw native-main inventory | `verify-parity.py --ps C:/Users/flesniak/GitHub/PSStyleGuide --tf C:/Users/flesniak/GitHub/TerraformStyleGuide --ps-ref 48f4d8a36c8faceee12afac78aaecea0d176125d --tf-ref 06ad4f7c9b6847028cafdacf1ae55128d0f2d56c` via Python | Expected native exit **2**: 9 equal, 55 different, 6 PS-only, 11 TF-only; complete raw blob SHA-256/mode scan |
| Equal-input control | Same helper with the PS repository/commit supplied on both sides | Native exit **0**: 70 equal entries, no differences |
| Git replacement regression | Disposable local repository with original and replacement commits; default `git show` reads replacement; helper inspects original SHA with `--no-replace-objects` | PASS: helper hashes original bytes; local replace ref remains intact; no product refs changed |
| Historical preservation | Raw August-source SHA-256 and every extracted original-body hash | PASS: August source unchanged; all 402 reference bodies preserved exactly as extracted UTF-8 text |
| Existing local work | SHA-256 comparison of both pre-existing modified prompts and the three controller/schema/test files | PASS: all five unchanged by this task and excluded from its commit |
| Independent review | Bounded read-only agent audit and final recheck | Four material findings found and resolved: residual triggers, pending-input serialization, conditional-result freshness, Git replacements. No other material concern in the final recheck |

The first Markdown attempt invoked the package's library module and performed no lint. It was not counted as validation. The real CLI then found only source-preserved MD012 trailing-blank errors in 402 historical extracts. CR5 explains the narrow wrapper exception; active prose and all other checks remain enabled. Source-end markers prevent added blank lines at file end without changing the preserved contract. Decision arithmetic was recomputed from criterion scores.

## Publication checks

Stage only this dated folder, the October entry file, `coding-agent-loop.md` and its without-routing wrapper. Before commit, run the structural check, scoped Markdown check and staged whitespace check. Use the normal Git pre-commit hook; do not bypass it. Inspect the staged path set to exclude temporary research, unrelated local edits, credentials and runtime caches. Commit and push only to `planning-CRT-PR-852`; verify its remote SHA after the non-force push. No product main merge or PR review request is part of this planning delivery.

## Limits

This review does not rerun historical product CI, prove all original contracts implemented, certify every retired test equivalent, approve necessary product exceptions, authorize settings changes, or complete Terraform Gate A/B. The current trees remain different. The plan assigns those remaining outcomes explicitly. Full issue snapshots, native tree identities and historical status extracts are durable inputs; mutable state must be refreshed during execution. Exact subagent effective model/effort and model prices were not exposed, so no verified-cost or effective-override claim is made.
