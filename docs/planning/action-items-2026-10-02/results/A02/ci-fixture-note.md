# Finalization fixture diagnostic <!-- markdownlint-disable MD013 -->

Candidate CI failed because PowerShell wrapped the expected diagnostic; the checker correctly rejected stale metadata. The private child caller now writes the exception message directly and exits 1; production logic and the failure assertion are unchanged.
Validation: Linux reproduction preserves exit 1 and the exact message with the fix; PSScriptAnalyzer has no Warning/Error findings. One full final-byte pre-commit run is in progress.
Evidence: [failed candidate job](https://github.com/franklesniak/PSStyleGuide/actions/runs/37014384227/job/110861550314); parent commit d9b9e1c; repair is local, with no round-three request yet.
