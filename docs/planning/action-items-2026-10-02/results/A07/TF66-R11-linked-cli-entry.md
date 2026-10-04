<!-- markdownlint-disable MD013 -->
# R11: execute the actual CLI through a linked checkout

Status: H-inline98 selected. Root read the complete proposal, checked its hash and score arithmetic, displayed the options, rubric, scores and controlled-English selection in order, then released private implementation. This is the canonical R11 decision. Product integration and final validation remain pending.

## Inputs and validated boundary

TF H `4375f2e3c98a6aeb0dd916d26620ed63a42abafe`, tree `099bb0f83403b6b61cfa2dafa73916b315c791d3`; accepted B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`; accepted PS source `f168f83b89f64b6bca9d520ddec4b58969060fb6`. R6 remains frozen separately. R8/R9 private code is not an accepted candidate.

The current guard compares lexical `path.resolve(process.argv[1])` with the module's canonical file URL. A native directory junction leaves the alias in argv while Node loads the canonical module. The guard then returns false, so direct commands silently exit zero without their CLI body. This affects precisely these five shared modules: `lint-markdown.mjs:32`, `NpmTools.mjs:138`, `Check-NpmAudit.mjs:379`, `Classify-InstructionMaintenance.mjs:106`, and `Validate-WorkflowPolicy.mjs:574`, all under `.github/workflows/`.

The actual H probe is `R11-evidence/probe.mjs`; exact commands and outputs are in `R11-evidence/results.json` and `probe-command.json`. It ran pinned Node 24.18.1 on Windows with a real directory junction, no dependency installation and no network request. All five ordinary invalid-argument calls reach their handlers: exits 2/2/2/1/1. The corresponding five alias calls incorrectly return 0 with no output. Fifteen imports (five modules times absent, empty, or nonexistent argv[1]) remain inert and print only the probe marker. The probe log SHA256 is `c6ccfc6dfd33fe6ae187af733f81f1f5fec5901bd2c7898fd65ddc713293464a`. The existing linked-TEMP Markdown test additionally demonstrates the consequence for actual lint/native-hook behavior: eight old CLI assertions fail while all five new R9 API cases pass. This is not merely a cleanup assertion issue.

## Callers, runtime and authority

| Module | Actual use and preservation requirement |
| --- | --- |
| lint-markdown | Root npm outer lint and Husky full-file phase; retain 0/1/2 statuses, actual child checks, and usage errors. |
| NpmTools | Documented direct locked install; invoked from setup/tooling and imported by other helpers; retain install argument validation, exact-runtime check and inert imports. |
| Check-NpmAudit | Documented local audit and hosted --ci audit; retain scope, accepted authority, JSON diagnostics and status mapping. |
| Classify-InstructionMaintenance | Standalone accepted-base classifier before candidate code; retain builtin-only import closure, endpoint validation and classification output. |
| Validate-WorkflowPolicy | Standalone builtin-only pre-install preflight plus post-install YAML validation; retain lazy YAML loading, accepted contract closure and argument categories. |

Inspected Initialize-CiToolchain, Copilot setup and workflow calls run after pinned Node provisioning. AGENTS line 58, dependency-maintenance lines 10–19 and scripts README lines 34–54 require the exact root package engines for manual use too. Node 24.18.1 supports native entry metadata. There is no asserted supported-old-Node CI requirement. However, current direct commands on a runtime that can load these modules but lacks entry metadata still enter their existing usage/runtime diagnostics. The selected fallback preserves that existing behavior; it does not grant compatibility or introduce a new runtime policy. No pre-install dependency or new accepted tool is necessary for an inline guard.

`install-husky.mjs` and `lint-staged-markdown.mjs` execute directly rather than using this guard. `lint-nested-markdown.js` uses CommonJS `require.main === module`. None shares the demonstrated five-site comparison defect. A broader runtime redesign is out of scope.

## Affected stakeholders

Contributors and new developers need a command that actually runs and gives a useful failure message. Windows and Linux users can reach a repository through a directory link. QA needs actual CLI and import tests, including controls that fail on the original code. DevOps and platform engineers need the standalone classifier and pre-install check to retain their accepted inputs and built-in-only dependencies. Security engineers and accountable owners need silent success removed without making an import run installation or other commands. Maintainers and dependency authors need the native loader fact to take priority over mutable argv. Documentation and user-experience owners need the existing command names and error instructions to remain valid. Project and business stakeholders benefit from closing the five-site defect in one tested repair. Recovery, privacy and cloud administration have no new interface or data flow in this bounded change; the existing command bodies retain those responsibilities.

## Materially distinct options (sent before rubric)

- N: retain the code and document canonical-path-only operation. This leaves a silent-success defect for linked workspaces.
- W: canonicalize caller/wrapper paths. Useful for controlled launchers, but documented direct calls and future callers remain exposed.
- C: replace each guard with safe canonical filesystem identity comparison. Fixes aliases, but identity inferred from mutable argv can misidentify an imported module as the entry point.
- S: use one builtin-only shared canonical-identity helper. Same identity limitation as C; must also update standalone accepted-tool materialization and its closure tests.
- M: use native `import.meta.main` alone in all five modules. Best supported-runtime simplicity and loader identity; a runtime lacking the property silently skips existing direct-call error paths.
- H-inline: use native boolean `import.meta.main` when present; otherwise use a small safe canonical-identity fallback at each current guard. Preserves current-runtime loader identity and existing older-runtime direct-call behavior without extending the tool closure.
- H-shared: the same hybrid through a new common builtin-only helper. Reduces duplicate maintenance but adds a trusted/materialized dependency to standalone classifiers and preflights.
- U: resolve argv as a file URL through the module resolver, then compare resolved identities. A plain URL or path normalization is not sufficient. Resolver availability/error behavior and mutable argv still need explicit handling.
- E: split CLI wrappers and importable modules, preserving old command paths through wrappers. Makes the distinction explicit but moves argument/error and accepted-tool boundaries into a new module layout.
- X: remove guards and execute on every import. Ineligible: violates mandatory import nonexecution.

Combinations of W with a module fix are optional defense at a caller, not a substitute for the module fix; no demonstrated need warrants it. Native-first canonical fallback is H, already scored in both ownership forms. URL resolution plus native-first fallback has no identified advantage over H's direct canonical fallback and retains additional resolver-version surface. A shared helper may be adopted later if another substantive use justifies its closure changes.

## Unique rubric (sent before scores)

Score 0–5. Total is the sum of weight times score, divided by five. Correctness, user-visible failures and authority safety dominate maintenance cost. Hard constraints: direct CLI bodies must run for supported real aliases; imports must remain inert; existing argument/error contracts, exact runtime policy and accepted-tool authority must remain operative. A shared redesign is not excluded merely for scope or churn.

| Criterion | Weight | Meaning |
| --- | --- | --- |
| Actual direct-entry detection | 35 | Identify actual direct execution for ordinary and linked paths without a caller-specific escape. |
| Import nonexecution | 25 | Respect loader identity and avoid CLI work on imports, including absent or misleading argv. |
| Runtime/argument/error preservation | 15 | Keep existing useful diagnostics and exit behavior without creating a runtime-support promise. |
| Accepted-tool/builtin closure | 10 | Preserve standalone accepted classification and pre-install operation, with explicit ownership of any new dependency. |
| Cross-platform verification | 10 | Permit decisive Windows/Linux ordinary, alias, CLI and import controls with bounded evidence. |
| Continuing maintenance | 5 | Keep the implementation understandable and reduce future drift. |

| Option | Entry 35 | Imports 25 | Behavior 15 | Closure 10 | Evidence 10 | Maintenance 5 | Total |
| --- | --- | --- | --- | --- | --- | --- | --- |
| N | 1 | 5 | 3 | 5 | 2 | 5 | 60 |
| W | 3 | 5 | 4 | 3 | 3 | 4 | 74 |
| C | 5 | 4 | 5 | 5 | 5 | 4 | 94 |
| S | 5 | 4 | 5 | 4 | 5 | 5 | 93 |
| M | 5 | 5 | 4 | 5 | 5 | 5 | 97 |
| H-inline | 5 | 5 | 5 | 5 | 5 | 3 | 98 |
| H-shared | 5 | 5 | 5 | 4 | 4 | 5 | 96 |
| U | 5 | 4 | 3 | 5 | 4 | 3 | 85 |
| E | 5 | 5 | 4 | 4 | 5 | 5 | 95 |

H-inline is recommended at 98. M is a close 97 and is sufficient for the documented pinned runtime; its one behavior-point deduction is only for loss of existing diagnostics on metadata-absent runtimes, not a claim that CI uses those runtimes. H-inline pays two maintenance points for repeated fallback code. H-shared scores 96: full behavior, better centralized maintenance, but one closure point and one evidence point reflect the additional accepted-tool acquisition/materialization paths that must be proved. This is an authority and verification cost, not a high churn penalty. C/S lose one import point because argv-derived identity is weaker than the loader's actual-entry fact. U also has resolver-version/error compatibility costs. E is viable but must reconstruct existing CLI/error and accepted materialization boundaries; those two preservation/closure scores are 4 rather than 5. W leaves direct callers uncovered; N preserves behavior only when users avoid the trigger. No choice can claim TOCTOU elimination for filesystem identity fallback.

## Selected controlled-English proposal

1. Keep each existing CLI body.
2. Keep each existing error handler.
3. Read `import.meta.main`.
4. If the value is a boolean, use that value to identify the entry module.
5. If the value is false, do not run the CLI body.
6. If Node does not provide a boolean value, use the fallback path check.
7. In that fallback, return false if argv[1] is absent or empty.
8. Compare the real path of argv[1] with the real module file path.
9. If a path cannot be read, return false.
10. Apply this rule at the five existing guards.
11. Add only the required built-in imports.
12. Keep the existing command names, argument errors and exit codes.
13. Test the commands through ordinary and linked directories.
14. Test module imports with absent, empty, nonexistent and misleading command paths.
15. Verify the actual Markdown hook through a linked directory.

The instructions use short direct sentences and one action per instruction. Technical names refer to the existing Node interfaces above. This record does not claim formal controlled-dictionary certification.

This preserves rather than strengthens the legacy fallback's trust model. Its filesystem identity can race, and argv can be changed by a process that imports modules on an old runtime. The supported native branch avoids that ambiguity. An unreadable legacy argv path is treated as non-entry; no claim of reliable legacy deleted-entry execution is made. Older-runtime behavior is source-assessed until tested with an actual older binary; no such binary is available in the reused runtime set. Do not install one solely for this repair.

## Exact proposed edit/test scope

Production: the five modules listed above, only entry detection and necessary builtin imports. Tests: reuse their existing five counterpart `.test.mjs` files for meaningful controls; the lint test is already the joint R8/R9 postimage. No workflow/caller/config/guide/metadata edit is needed. A test may exercise multiple sites in one existing suite if this avoids duplicated setup, but it must preserve standalone module-copy fixtures and accepted closure. Root owns final scope admission.

- For every module, execute the actual file through an ordinary path and a native directory alias with invalid arguments. Require its original diagnostic and exact nonzero status; the original five alias calls must fail this regression.
- Import each actual module under absent, empty, nonexistent, and misleading same-module argv. Require an import marker only, no CLI output and zero exit. Native false must win even when argv names the module.
- Retain meaningful successful execution through an alias: the actual outer-lint clean/invalid cases and native hook; existing classifier/policy fixtures can supply valid bounded calls without installing or auditing live services.
- Reuse the R8 ordinary/linked TEMP matrix to reach all six cleanup comparisons in three suites. Ordinary Windows already passed 29 cases; rerun only changed/previously incomplete scopes after implementation.
- Preserve R9 five cases and original-vs-repaired two-conflict mutation discrimination. No unrelated API change.
- Where the native branch is available, actual process tests are authoritative. A private forced-fallback check of the actual guard can add branch evidence, clearly labeled as such; it cannot be reported as an actual old-runtime run. No implementation-mirroring durable unit test is required.
- Use pinned Windows Node and the cached Linux image, explicit private TEMP/TMP/cache, source/dependencies read-only. No full SelfTest or aggregate. Verify all source/index/dependency guards before and after.

## Linux incomplete evidence and next diagnostic

The retained Linux wrapper `copilot-repair/linux-run.mjs` gave the entire 24-case lint test process 180000 ms. `ordinary-linux-1.json` records ETIMEDOUT at 180.016 seconds; no terminal case summary exists. Its log contains three expected direct API diagnostics but no per-case completion. The log is insufficient to identify a particular slow or blocked test. It does not prove R8, R9 or R11 failure on Linux. Windows completed those 24 ordinary cases in about 37 seconds. Do not repeat the same full command solely due to elapsed time. After the changed R11 candidate exists, run the affected focused cases first with separate bounded records; if needed, run the preserved actual-hook case separately to identify the slow boundary. Record a larger whole-suite budget only when measured constituent bounds justify it; do not remove assertions or limits to obtain a pass.

## Primary references

Node documents `import.meta.main` as actual entry-module detection, added in v24.2.0, and marks it Stability 1.0 (early development); the same ESM reference explains that module filenames have symlinks resolved. The pinned runtime contains this API. [Node 24.18.1 ESM](https://nodejs.org/download/release/v24.18.1/docs/api/esm.html#importmetamain).

`fs.realpathSync` resolves filesystem links; it is not a globally unique object identity for hard links or bind mounts. [Node 24.18.1 filesystem](https://nodejs.org/download/release/v24.18.1/docs/api/fs.html#fsrealpathsyncpath-options). `path.resolve` constructs an absolute normalized path without resolving filesystem links. [Node 24.18.1 path](https://nodejs.org/download/release/v24.18.1/docs/api/path.html#pathresolvepaths).

The selected private implementation may change the five production modules and their existing counterpart test files. R6 remains frozen. Root owns integration and the final aggregate. This decision does not claim product publication, acceptance, main/main equality or a new transfer.

[Private source proposal and exact evidence](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round2-review-findings/copilot-proposals/R11-linked-entry-proposal.md).

Generated with Codex
