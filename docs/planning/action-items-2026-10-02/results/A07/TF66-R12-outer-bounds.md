<!-- markdownlint-disable MD013 -->
# R12: keep the documented outer limits independent of shared defaults

Status: coordinator selected E98.6 before implementation at 2026-10-04T21:57:48.581985+00:00. Private implementation and focused verification are released; product integration and acceptance remain pending.

Input: published TF H `055f112f762a466ed693c073083225f8ec9ee79d`, tree recorded in `source-identities.json`, accepted B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. The product was unchanged at selection. Root owns integration and native actions. Exact source and probe evidence is in the [private handoff](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round3-review-findings/HANDOFF.md).

Actual probe: `run-probe.py` invokes pinned Node24.18.1 with private TEMP/TMP/npm cache; command, timestamps and exit0 are in `probe-command.json`. Log SHA256 `f718a5ef170f36400198c49b4a3e1c27375d823235e2f19f6dd76fbd3a565743`. Supplemental option probe: `run-option-evidence.py`, exit0, log SHA256 `6ee1e410ddc072b490b53a27fb6ee637db11d13933433cb38b5aaa24ee6f8327`. Neither runs a full suite, install, audit, aggregate or native service mutation.

## 1. Validated facts and prior authority

[Copilot comment4179432266](https://github.com/franklesniak/TerraformStyleGuide/pull/66#discussion_r4179432266) concerns future drift. Current execution is bounded and agrees with the documentation. The exact H wrapper calls runBounded with cwd only. NpmTools exports frozen processLimits `{ timeout:120000, maxBuffer:2097152 }`, spreads them into spawnSync, sets SIGKILL, uses piped output and then accepts explicit caller options. The real unchanged wrapper rejects a benign3MiB output child with ENOBUFS. Its error includes4122 characters of retained bounded cause text. A real50ms overridden timeout rejects a harmless waiting child. The120000ms default is source-verified; no two-minute sleep was performed.

The actual caller is root npm lint:md -> workflow npm lint:md -> lint-markdown.mjs -> validated canonical lint-nested-markdown.js --outer. Husky also calls the full outer phase. Existing wrappers preserve success0, lint1 and tooling2. Both scripts-README44 and dependency-maintenance40 promise the particular two-minute/two-MiB bound.

The canonical [D90 selection](review-braces-decision.md#current-d-reassessment-and-implementation-contract) and [E90 selection](review-js-yaml-decision.md) intentionally use the existing bounded transport and require retained outer limits. They establish the contract and explain the correct current implementation. They do not separately choose whether this call should remain coupled to future shared defaults. This draft evaluates that narrower maintenance choice without calling D90/E90 defective or duplicating their dependency decision.

Current tests already exercise real bounded children: NpmTools tests cover nonzero, missing command, timeout, bounded cause text and output overflow. The lint suite's actual bounded-child case covers native2/7, a50ms timeout,1024-byte overflow, missing child, launch failure and API failure. Those are meaningful transport tests, not a durable assertion of the120000/2097152 outer constants. The published full suite success is reused; only the small current-behavior probes above were executed here.

The injected option probe simulates a hypothetical shared maxBuffer4MiB and passes the wrapper's actual call options afterward. The unchanged wrapper then admits3145728 bytes/status0. The probe captures rather than prints that benign payload. This is a discriminating future-default test setup, not an actual current bypass or a claim that shared defaults changed.

## 2. Stakeholders and scope

Contributors, GUI Git users and local agents need finite waiting time and useful native failure causes. CI/platform operators need the documented budget to survive an unrelated npm/audit transport change. Both maintainers and paired-repository reviewers need a clear owner for the outer limit without two transports drifting apart. Security reviewers need retained child-path checks, kill behavior and output containment. QA needs real timeout/output failures rather than literal-copy assertions. Cost/schedule owners benefit from a one-call repair and reused tests. This does not change data storage, credentials, deployment, recovery authority or language-guide semantics.

## 3. Options (communicated before rubric)

| ID | Option | Consequence |
| --- | --- | --- |
| N | Keep inherited shared defaults and link D90/E90 | Correct and bounded today; the specific outer promise remains coupled to unrelated default edits. |
| D | Add a comment or documentation explaining that coupling | Improves ownership clarity but cannot hold the particular outer limit stable. |
| E | Pass timeout120000 and maxBuffer2*1024*1024 at this outer invocation | Fixes the documented limits at their consumer while retaining the existing transport and all other controls. |
| C | Explicitly spread/import the existing processLimits into options | Makes the dependency visible but does not remove future-value coupling. |
| S | Add a distinct shared outer-limit profile and pass it here | Supports independent policy and reuse; introduces an exported profile for one current consumer. |
| M | Clamp shared values to the outer ceilings | Stops larger values, but unrelated lower defaults can unexpectedly tighten this contract and adds normalization logic. |
| A | Assert the shared values before running | Fails visibly on drift but blocks otherwise safe lint instead of preserving its own bound. |
| W | Add a separate outer spawn transport | Can meet the contract, but must duplicate native cause/status/kill/output behavior. |
| X | Remove bounds or move full outer lint into the parent | Ineligible: violates selected bounded-child behavior. |

A comment accompanying E is part of E if it explains intent, not a new design. S combines centralized naming with an independent profile. C does not become drift protection merely because options are explicit. M/A are separate enforcement policies. A new job/framework or changed lint admission has no demonstrated benefit. Deferral is N with a later revisit; no blocking current defect justifies a wait by itself.

## 4. New finding-specific rubric

Scores0–5: absent/unacceptable, weak, partial, adequate with residuals, strong, or fully supported by this design. Weighted total is sum(weight*score/5); values are judgments, not measurements.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Outer contract stability | 30 | Preserve this documented ceiling when unrelated shared defaults change. |
| Existing execution/error fidelity | 25 | Retain SIGKILL, native cause,0/1/2, exact runtime and child-path checks. |
| Maintainer/caller clarity | 20 | Make the owner of this particular limit easy to inspect. |
| Meaningful verification | 15 | Permit actual child and drift controls without implementation-mirroring tests. |
| Ongoing maintenance | 7 | Avoid parallel transport or unnecessary policy machinery. |
| Edit/validation effort | 3 | Keep work proportionate; convenience does not waive behavior. |

Hard constraints preserve current ceilings and all existing caller, error, path and authority behavior. No-change receives full current execution fidelity. No option is rejected merely for being a shared configuration refactor.

## 5. Scores before selection

| Option | Stability30 | Fidelity25 | Clarity20 | Proof15 | Maintenance7 | Effort3 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 3 | 5 | 4 | 4 | 5 | 5 | 81 |
| D | 3 | 5 | 5 | 4 | 5 | 5 | 85 |
| E | 5 | 5 | 5 | 5 | 4 | 5 | 98.6 |
| C | 3 | 5 | 4 | 4 | 4 | 5 | 79.6 |
| S | 5 | 5 | 4 | 5 | 4 | 3 | 93.4 |
| M | 5 | 4 | 3 | 4 | 3 | 3 | 80 |
| A | 5 | 3 | 4 | 4 | 4 | 4 | 81 |
| W | 5 | 4 | 4 | 4 | 2 | 2 | 82 |
| X | — | — | — | — | — | — | Ineligible |

E98.6 is recommended. Its concrete benefit is that an unrelated shared-default increase no longer changes this documented consumer; it does not repair a current unbounded process. N/D are safe today and scored accordingly. C adds syntax but keeps the same dependency. S is viable93.4; a new public profile currently has no second consumer and requires an extra lookup, so it loses clarity/effort rather than being excluded. M adds a lower-limit coupling and A converts a future shared edit into a lint outage. W can preserve behavior but adds a second transport and corresponding verification responsibility. These judgments do not override D90/E90's retained bounds.

## 6. Selected controlled-English proposal

1. Keep runBounded as the default transport.
2. Keep the current child path and --outer argument.
3. Add timeout120000 to this invocation's options.
4. Add maxBuffer2*1024*1024 to the same options.
5. Keep cwd unchanged.
6. Keep the existing cause and status handling.
7. Verify the current and injected-default output controls.
8. Run the existing affected bounded-child tests.

Exact proposed product scope: `.github/workflows/lint-markdown.mjs`, one invocation. No NpmTools, dependency, workflow, guide, metadata or doc-contract edit is required; current documentation stays accurate. Both repositories should receive the same common line after accepted-source transfer. No formal ASD-STE100 dictionary certification is claimed.

## 7. Verification after release and primary reference

Reuse the retained NpmTools/lint native failure tests. Run only their relevant named cases plus a clean outer control. Observe current3MiB rejection, current smaller valid output, and a50ms timeout through the same transport. Re-run the saved injected4MiB-default discriminator: the repaired wrapper must still reject3MiB because its explicit option wins. The original witness remains. No new durable literal/options-mirroring test is proposed for this reversible two-field maintenance change. Do not run a120-second wait merely to restate an inspected constant; if a current bound stops working, investigate its actual cause.

Node specifies timeout in milliseconds, maxBuffer in bytes on stdout/stderr, and termination when that buffer is exceeded. The repository supplies SIGKILL and its own bounded diagnostic policy. [Pinned Node child-process API](https://nodejs.org/download/release/v24.18.1/docs/api/child_process.html#child_processspawnsynccommand-args-options). This is a native child bound, not a claim of universal descendant-tree containment or precise kernel scheduling at120000ms.

## Coordinator selection

Root read the full proposal, checked both current production sites and native probes, verified the proposal SHA256 `8161c1f1e00e2d579e523017fa465839e339d96f518a84b2a767c9f768505ab1`, and recalculated all option totals. Options, separate rubrics, score tables and selected actions were displayed to the owner in that order before release. Select E98.6. The original proposal describes pre-edit evidence; no repaired candidate is accepted yet.
