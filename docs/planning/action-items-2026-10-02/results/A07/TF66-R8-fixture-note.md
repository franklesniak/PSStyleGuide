<!-- markdownlint-disable MD013 -->
# R8: Test cleanup through a linked temporary directory

Root reproduced a lexical-parent versus resolved-temp mismatch with a real Windows junction; all six assertions across lint-markdown.test.mjs, Check-NpmAudit.test.mjs and NpmTools.test.mjs are affected. Resolve both parent paths; retain directory-name guards and removal.
Private ordinary Windows29/29 pass; linked Markdown16/24 pass, with eight failures exposing the separate [R11 production finding](TF66-R11-linked-cli-entry.md). All five R9 cases pass. Linux exceeded the180-second harness timeout; no complete verdict. [Source and R11 evidence](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round2-review-findings/copilot-proposals/R11-evidence/results.json); [Node realpath](https://nodejs.org/docs/latest-v24.x/api/fs.html#fsrealpathsyncpath-options). Combined final validation remains pending.
