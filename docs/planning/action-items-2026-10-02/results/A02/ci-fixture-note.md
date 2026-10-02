# Finalization fixture diagnostic <!-- markdownlint-disable MD013 -->

Candidate CI failed because PowerShell wrapped the expected diagnostic; the checker correctly rejected stale metadata. The private caller now writes Exception.Message and exits1; production logic and the failure assertion are unchanged.
Validation: Linux reproduction preserves the message/exit1; PSScriptAnalyzer has no Warning/Error findings; one full final-byte pre-commit passed all10 hooks, actual B/H checks passed, and fresh Linux candidate CI passed.
Evidence: [failed job](https://github.com/franklesniak/PSStyleGuide/actions/runs/37014384227/job/110861550314), repair [f81f769](https://github.com/franklesniak/PSStyleGuide/commit/f81f769b8b6d096a764b69e9a16e612c2c8c1186), [successful candidate job](https://github.com/franklesniak/PSStyleGuide/actions/runs/37023858676/job/110893421268); round3 terminal: Copilot Balanced clean; Codex F5 is a separate production finding.
