<!-- markdownlint-disable MD013 -->
# F8: recognize Markdown suffixes without changing path identity

Status: implemented; focused checks and final normal aggregate pass.

## Validation and stakeholders

Codex5395264907/comment4168569590 applies to b8976a4. Actual discovery drops tracked docs/RUNBOOK.MD and .cursor/rules/operations.MDC while returning docs/lower.md; the classification parser rejects both uppercase suffixes as unsafe. See reproduce.ps1/log. The ordinary runbook has no separate governed-family inventory rule and can escape metadata discovery. The cursor example demonstrates the helper gap, but existing full-validator governed-family alias/catalog checks can reject that path independently. Do not claim every such path passes the full validator.

Both maintainers, authors moving files across Windows/Linux, documentation readers, agents, CI operators, security reviewers and future A21 integrators need extension recognition consistent across discovery and manifest data. History custodians need exact Git names and grants preserved. No cloud, credential, privacy or localization interface changes.

Hard constraints: preserve original path bytes, ordinal identity, tracked membership, sorting, category provenance and exact prior authorization; do not introduce a naming ban or lowercase filenames; preserve existing explicit governed-family/decision-record naming rules and known-path conflicts; do not change generated semantics or metadata rules.

## Options and rubric

N: no change. A: recognize md/mdc suffixes case-insensitively in discovery and classification while retaining exact paths. R: newly reject every uppercase suffix. L: lowercase whole paths. D: repair discovery only. C: add a second special-path inventory. T: introduce an external path scanner. Native .NET/PowerShell regex matching already supplies the needed extension recognition; no framework is needed.

Fresh0–5 rubric: metadata coverage40; exact identity/authority25; consumer consistency20; maintenance10; cost5. Total=sum(weight*score)/5.

| Option | Coverage40 | Identity25 | Consistency20 | Maintenance10 | Cost5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 0 | 4 | 2 | 5 | 5 | 43 |
| A | 5 | 5 | 5 | 5 | 4 | 99 |
| R | 4 | 5 | 3 | 4 | 4 | 81 |
| L | 4 | 0 | 3 | 3 | 4 | 54 |
| D | 4 | 5 | 2 | 4 | 5 | 78 |
| C | 2 | 4 | 2 | 1 | 2 | 48 |
| T | 4 | 4 | 4 | 1 | 1 | 71 |

R adds a naming restriction with no demonstrated need. L violates exact authority. D leaves the same files ineligible for the supported classification/authorization path. C/T add maintenance without a useful new consumer. A covers the demonstrated suffix variants with four bounded recognition changes.

## Selection and verification

Select A. Make only md/mdc suffix recognition case-insensitive in the two classification path checks, discovery input selection and its safe-path guard. Keep every returned and stored path unchanged. Keep ordinal sets, ordinal schema ordering and F6 direct enumeration. Keep governed-family aliases and decision-record canonical names unchanged.

Change only validator/SelfTest. Test uppercase/mixed suffix discovery, metadata failure on a newly discovered uppercase runbook, valid uppercase content, exact uppercase exemption/grant activation, different-case grants rejected, category weakening still rejected, unsafe/non-Markdown paths unchanged, and existing governed-family aliases still rejected. Use real accepted B/H content and classification callers. Reuse unchanged F6 Unicode identity proof. No workflow/public mode/schema or guide edit is required.

## Validation checkpoint

The selected changes pass focused actual helper and private installed-policy B/H checks (focused-final.log). The uppercase synthetic path variant of the actual data-only admission fixture also passes (suffix-admission.log); it changes only the fixture path spelling, not validator code. Exact ordinal authority, existing family alias refusals, retained F6 category controls, invalid real prior headers and candidate-code isolation remain exercised. These are proposed-code fixtures, not native first-install authority.

The final three-path candidate is staged as tree6223b82bced692b5eb32e31bcbc5fd11447015f8 on b8976a4. Normal combined pre-commit session72653 exited0 at2026-10-02T19:35:21.3724355Z; all10 hooks passed. It started18:52:17.7198840Z. Final readback confirms this exact tree, three100644 staged paths, matching raw hashes and no unstaged changes. Product ownership is returned to parent for normal commit/publication and native endpoint validation. The first focused attempt exposed only a PowerShell fixture concatenation-precedence error; fixture-note.md and example-diagnostic.log retain the cause, and the corrected focused run passed. No unrelated suite was repeated.

The first aggregate (superseded tree4363284) passed nine hooks and content validation, then stopped on a new SelfTest alias assertion's unavailable parent-script variable. The explicit fixture input now passes in a separate script scope; production and guide bytes are unchanged. fixture-scope-note.md and precommit-superseded-scope.log preserve this actual reason for the replacement aggregate.

## Committed candidate

Normal product commit `8b6c1da46b568cb3b44e60fc511a03ac1fc4edf0` preserves the validated tree `6223b82bced692b5eb32e31bcbc5fd11447015f8`. Actual proposed-code finalization and classification passed with B `48f4d8a36c8faceee12afac78aaecea0d176125d` and H equal to this commit; finalization captured UTC2026-10-02. The accepted-base fixture retained its HEAD and exact staged candidate tree with no unstaged changes. These checks do not establish already-installed native enforcement. [Whole-PR quality](F7-F9-quality.md) records independent source review and final evidence reconciliation; current remote review/CI and merge gates remain separate.
