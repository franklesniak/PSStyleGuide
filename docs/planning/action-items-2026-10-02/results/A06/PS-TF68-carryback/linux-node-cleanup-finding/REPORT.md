<!-- markdownlint-disable MD013 -->
# PS Node cleanup finding and recovery proposal

Proposal only. Root must verify, display and select it before implementation. Only this report and evidence.json are written. No tests, containers, launchers, payload imports, product/runner/Git/dependency/native/planning/state edits or counter changes occur. Windows focus session93695 is separate.

## 1. Validate the finding

The original packet failed correctly under its actual predicate. Staged preflight passed. Direct Node exited0. Its raw TAP independently records600pass,0fail/cancelled/skipped/todo and204.032958677seconds. Cleanup found82 already-exited adopted children, all stateZ:79 exact waits exit0, two exit128 and oneSIGKILL. The observer sent no signals. It reaped all82 with exact PID/start-tick waits, ownerPPID1, no collection error and no residue. The strict settlement predicate rejected `Unsuccessful adopted exit`. Aggregate never started. The old packet stays failed.

| PID | Start ticks | comm | group/session | raw wait | Result |
| --- | --- | --- | --- | --- | --- |
| 2229 | 2040 | sh | 645/645 | 32768 | normal exit128 |
| 18141 | 19007 | git | 645/645 | 32768 | normal exit128 |
| 21565 | 22139 | MainThread | 21530/21530 | 9 | SIGKILL9 |

Their former command lines were empty and executable identities unavailable. These receipts prove termination and collection, not original argv, intermediate ancestry, specific tests or causes. `MainThread` is not an executable attribution. No PID/name/status allowlist is justified. All82 birth ticks fall after direct Node's1868 and before its finished anchor. The frozen observer runs one asynchronous command in that isolated phase. Ownership evidence is adopted-child ancestry to the supervisor, exact waits and the bounded command interval; it is not a recovered per-test birth graph.

Private before/terminal identity receipts and host before/after guards match. Terminal cleanup is empty; container absence is confirmed. `affected-node-after.json` is absent because the cleanup exception occurred before ordinary TAP parsing and that guard. The Node assertions are independently evidenced; a normal passed-stage receipt must not be invented. Equal terminal guards provide retained integrity evidence. Current78-source/1914-dependency bytes were read-only rebound to their catalogs.

The current caller is a negative-test suite, unlike the earlier13-classifier-only command. `Test-CiHelpers.test.mjs`1863â€“1882 starts detached Bash, waits for an edited-copy sentinel, kills its entire group withSIGKILL, asserts the direct Bash signal and unchanged source, and does not rely on interrupted cleanup. TAP test351 passes that assertion. `NpmTools.test.mjs`23â€“35 and `lint-markdown.test.mjs`168â€“190 exercise native nonzero, timeout and output failures. Unchanged `NpmTools.mjs`10â€“20 uses bounded spawnSync withSIGKILL. These verified controls establish that a deliberately failed child can be a successful assertion. They do not identify the three old waits. No product defect is proved.

The material finding is a validation-contract mismatch. The universal adopted-exit-zero predicate treats every descendant result as a product-success oracle, although direct Node owns assertions of deliberate failures. The collector worked and must remain. A stage-specific success contract can distinguish assertions from lifecycle safety without calling an unclassified status intentional. Because this affects validation policy, the requested full decision process applies.

## 2. Stakeholders and constraints

The owner, both maintainers, QA and reviewers need truthful current assertions and useful progress without repeated broad runs. Security/platform/recovery operators need exact identity, known ownership, primary-error preservation and bounded cleanup. New contributors and agent operators need a simple result contract without fragile status exceptions. Audit/history custodians need failed history and raw outcomes retained. Cost/schedule owners benefit from reuse and missing-evidence-only runs. Guide behavior, privacy data flows, accessibility/localization and cloud authority are unchanged and add no separate criterion.

Hard constraints: preserve all600 meaningful tests and raw receipts; do not waive unknown ownership, missing/ambiguous waits, live state, observer-issued signals, collection/cleanup errors or input drift. Direct Node failure and failed/missing/cancelled/skipped/todo assertions remain failures. Keep the strict zero-exit default for setup, preflight, aggregate and terminal phases. Keep old packets failed and old causes unknown. Scores cannot waive these constraints.

## 3. Options

A keeps the rule and defers. B repeats the unchanged packet. C removes observer checks. D disables maintenance or omits negative tests. E allows old PID/name/status combinations. C/D/E violate constraints.

F makes product fixtures own/reap every descendant. It is possible if an actual fixture defect is established, but currently expands product/platform scope without cause proof. G adds an init/reaper that discards outcomes; reaping alone is not truthful observation. Combining an init with full semantics is an H transport variant with extra qualification.

H defines a Node test-owner contract. Direct Node owns assertion success. The unchanged observer owns exact collection and lifecycle safety. A separate Node-only judgment accepts well-formed, exactly owned, already-terminal waits with no live residue, observer signals or errors; it records every raw adopted exit/signal as an unclassified outcome. It does not label them deliberate or use their values as an allowlist. All other stages keep their strict default. Reuse independently valid600/preflight/guards after root verifies their scope, and obtain missing aggregate evidence separately.

I traces one full current Node invocation for fresh ancestry/cause before changing the contract. It needs an already qualified offline tracer; availability/permission are unproved. J combines that diagnostic with H. K adds one forced-stop integration control to H; it cannot explain the two old128 exits. L splits files into serial ownership diagnostics; it changes concurrency/argv and still cannot prove causes from status alone. M runs only the missing aggregate and keeps this finding open. N accepts all terminal statuses in every stage and loses the justified default. M can accompany a valid solution, but cannot replace its qualification. A later product repair remains conditional on a real finding.

## 4. Unique rubric

Scores0â€“10:0 defeats/does not provide the criterion;5 is conditional/incomplete;10 is strong supported fit. Total=sum(weightÃ—score/10). These comparative judgments are not empirical probabilities.

- **S30 â€” assertion semantics and failure boundary:** preserves actual600 counts, distinguishes asserted failures from product failure, and retains strict non-test stages. Serves QA/maintainers/reviewers.
- **O25 â€” lifecycle safety and ownership:** proves owner/PID/start-tick waits, refuses live/unknown residue, and preserves primary failures and cleanup. Serves security/platform/recovery. Per-test cause detail strengthens this score but does not replace collection proof.
- **E20 â€” evidence sufficiency and honest reuse:** binds current78/1914/current argv, retains failed/unknown history, and produces genuinely missing proof. Serves owner/independent quality/auditors.
- **U15 â€” legitimate usability and bounded progress:** avoids status allowlists, repeated suites and unqualified tools. Serves contributors/agents/schedule owners.
- **R7 â€” change and qualification risk:** reuses the collector, avoids product/platform changes, and requires meaningful controls. Churn cannot dominate correctness.
- **C3 â€” scope and convergence fit:** remains a scratch validation correction without a framework, installation or extra product transfer.

## 5. Scores before selection

| Option | Meaning | S30 | O25 | E20 | U15 | R7 | C3 | Total | Constraint/limit |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| A | Keep rule; defer | 4 | 10 | 5 | 2 | 10 | 10 | 60.0 | Admissible hold; no resolution |
| B | Repeat unchanged full packet | 4 | 10 | 4 | 3 | 8 | 9 | 57.8 | No semantic/cause repair |
| C | Node result only; omit observer | 3 | 1 | 3 | 10 | 8 | 8 | 40.5 | Rejected: loses lifecycle safety |
| D | Disable maintenance or negative tests | 2 | 2 | 2 | 7 | 3 | 2 | 28.2 | Rejected: changes behavior/safety coverage |
| E | PID/name/status allowance | 3 | 4 | 4 | 8 | 4 | 7 | 43.9 | Rejected: no owner/cause proof |
| F | Product fixture descendant ownership | 7 | 10 | 6 | 3 | 3 | 2 | 65.2 | Conditional: no product defect proved |
| G | Init/reaper discards outcomes | 4 | 3 | 3 | 7 | 5 | 6 | 41.3 | Rejected without truthful receipts |
| H | Node-specific assertion owner + lifecycle observer + reuse/missing aggregate | 10 | 9 | 9 | 10 | 8 | 10 | 94.1 | Selected proposal; new judgment needs qualification |
| I | Full Node native attribution first | 7 | 10 | 10 | 6 | 6 | 7 | 81.3 | Valid diagnostic; availability/permission unknown |
| J | H plus full native attribution | 10 | 10 | 10 | 6 | 7 | 8 | 91.3 | Valid; extra rerun/qualification |
| K | H plus forced-stop smoke | 10 | 9 | 9 | 8 | 8 | 9 | 90.8 | Valid; cannot explain old128 exits |
| L | Serial per-file diagnostics | 8 | 10 | 8 | 4 | 6 | 5 | 76.7 | Valid fallback; changes concurrency/argv |
| M | Missing aggregate only; finding open | 6 | 10 | 7 | 9 | 9 | 10 | 79.8 | Valid partial proof, not resolution |
| N | Terminal status acceptance in all stages | 4 | 7 | 5 | 9 | 7 | 8 | 60.3 | Rejected: loses strict non-test default |

H wins94.1. J offers more fresh causal detail but adds uncertain native tooling and a traced repeat. H's ownership/evidence/risk scores reflect missing old per-test lineage and the need to qualify its new judgment. Its safety gate still requires exactly owned terminal collection, no observer signals and emptiness. This delegates assertion success; it does not excuse an unknown live child or claim every orphan failure intentional.

## 6. Selected controlled-English proposal: H94.1

These instructions use short direct steps and explicit conditions. No formal ASD-STE100 dictionary certification is claimed.

1. Keep the original Linux packet failed.
2. Keep the old cold comparison failed.
3. Keep all raw wait statuses.
4. Bind the current78 source files and1,914 dependencies.
5. Use direct Node as the assertion owner for the Node stage only.
6. Require direct Node exit0 and exactly600 passing tests.
7. Require zero failed, cancelled, skipped and todo tests.
8. Keep the ownership collector unchanged.
9. Add a separate Node-stage receipt judgment.
10. Require known isolated stage ownership and one exact PID/start-tick wait for each adopted terminal identity.
11. Require consistent raw and decoded terminal status fields.
12. Refuse live or unknown state, unknown ownership, missing/duplicate waits and identity mismatch.
13. Refuse observer-issued signals, collection/cleanup errors and remaining children.
14. Record adopted exit/signal outcomes without a PID, name or value allowlist.
15. Do not attribute an old result to a specific test.
16. Keep the strict exit-zero default for other stages.
17. Preserve direct test failure as primary if cleanup also fails.
18. Qualify the new judgment with bounded pure controls.
19. Reuse preflight and600 assertion evidence only after root verifies input and ownership scope.
20. Use equal private terminal and host guards as input-integrity evidence.
21. Obtain the missing11-hook aggregate on the same bytes.
22. Keep full SelfTest, zero skips and its3,000-second bound.
23. Link the new evidence to the failed original run.
24. Do not relabel the original run as passed.
25. Stop and revise this decision if ownership cannot be verified or a new control fails.

New pure controls must refuse directNode failure, missing/mismatched TAP, fail/cancel/skip/todo counts, malformed status, foreign owner, missing/duplicate identity, live-before/eventually-empty, observer signals, collection error and residue. Correctly owned nonzero/signaled terminal waits are observations only for the successful Node assertion-owner stage. The unchanged strict judgment must still reject them elsewhere. Use the saved82 identity/wait map as qualification data; it is not a product rerun or original-command proof. Reuse the existing four real collector and ten strict-filter controls by hash; do not replay unchanged controls.

Next scope: scratch-only preparation of that small judgment and meaningful controls, followed by root qualification/release. Root is separately obtaining the missing aggregate under the unchanged strict filter; that action neither resolves this finding nor accepts the failed packet. The new result must be a truthful composite of named evidence, not an invented uninterrupted pass. Preserve the corrected3,600-second full Node allowance if a later fresh Node run is necessary. No product change, installation, generic framework, reset, restaging or disabling ordinary Git behavior is proposed.

Attribution is necessary only if ownership/scope is insufficient, an actual assertion fails, an unexpected live/unknown lifecycle appears, or a product defect is alleged. Then revise this decision and choose I/J/L before new work. A native diagnostic would run one Node-only current seven-file invocation and record bounded process/exec/wait/exit/signal/session events. It must qualify an existing tracer in the pinned offline image without installation or expanded privileges. Stop if unavailable. Sampling can miss short-lived forks. A fresh trace cannot recover old-PID causes. Do not repeat cold timing, preflight or aggregate inside that diagnostic.

## 7. Status and references

Not implemented or released. PSHEAD/B981, candidatea716, source78/deps1914 and transfers2/4/6/6of12 remain unchanged. No new PR/review/CI request occurs. Dedicated service activation remains an S1/task/paired acceptance obligation.

Exact Node24.18.1 documents isolated test-file result ownership and nonzero status for failed assertions. This supports the assertion-owner boundary, not an assertion that arbitrary orphan failures are safe. [Node test documentation](https://nodejs.org/download/release/v24.18.1/docs/api/test.html#test-runner-execution-model).

Linux waits reap waitable children and distinguish normal exit from signal termination; status does not explain former argv or intent. [Linux waitpid documentation](https://man7.org/linux/man-pages/man2/waitpid.2.html).

Native tracing can provide fresh syscall/signal/process detail. Its presence in the image is unproved. [Official strace project](https://strace.io/), [project-linked manual](https://man7.org/linux/man-pages/man1/strace.1.html).

Local anchors: current `inside.py`46â€“61 applies the strict judgment;68â€“126 waits the direct child and raises cleanup failure before normal TAP parsing;127ff parses TAP. `ownership.py` records current ancestry, PID/start ticks and exact waits. `settlement.py` rejects nonzero/signaled adopted results. `Test-CiHelpers.test.mjs`1863â€“1882 defines the forced-stop negative. Evidence.json binds exact source/helper/log/guard/catalog/control paths and hashes.
