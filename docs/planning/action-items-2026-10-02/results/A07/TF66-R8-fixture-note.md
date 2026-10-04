<!-- markdownlint-disable MD013 -->
# R8: Test cleanup through a linked temporary directory

A real Windows junction exposed lexical-parent versus resolved-temp mismatches at six cleanup assertions. Resolve both parents; retain all directory-name guards and removal operations. Linked tests then exposed the separate [R11 production defect](TF66-R11-linked-cli-entry.md), now repaired privately.
Final focused Windows40 unique cases and Linux39 unique cases pass in each ordinary/linked mode, including all six cleanup sites. Linux repeated one hook control; earlier actual timeouts remain recorded. [independent review](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-prepublication-quality-20261004/TF66-R8-R9-R11-REPAIR-REVIEW-20261004.md) passes. See [exact commands, logs and frozen handoff](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round2-review-findings/copilot-repair/HANDOFF.md). Full aggregate8796 and product delivery remain pending.
