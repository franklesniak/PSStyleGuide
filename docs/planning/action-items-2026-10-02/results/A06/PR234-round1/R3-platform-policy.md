<!-- markdownlint-disable MD013 -->
# PR234 R3: one finite table inside the policy

Reviewed head: `24b18795e5f6e260b095310ddd116cb0f1b19f6b`; PS base `d7b206adbce4f54edd6dd3d86d3dc2fa8e344b48`; accepted TF `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce`. This is the canonical writer decision; root owns public replies, counters, integration and lifecycle. No protected guide change is selected.

**Validation.** Comment4188451094, threadPRRT_kwDOQkjdhM6pM-HC. Silent drift is not reproduced: actual policy accepts the valid workflow and rejects independent admission-list, dependency-list and job-name changes with generator-admission, generator-dependencies and isolation-jobs respectively (pre-edit-policy-acquisition.json). There is nevertheless a narrow maintenance improvement: the same policy module spells its three fixed IDs twice. Deriving only the expected admission statement from its own fixed list can remove that internal duplication while retaining independent workflow and test literals.

**Stakeholders.** Both maintainers and new contributors need one clear internal edit point. Reviewers and supply-chain engineers require a policy independent of proposed workflow bytes. CI/platform operators need the existing exact same-revision contract. Artifact consumers need unchanged admission. No user data, cloud access or accessibility behavior changes.

**Options, before scoring.**

- A: Keep both literal policy lists, with their current fail-closed checks.
- B: Derive only the expected PowerShell array statement from the fixed policy list; keep workflow and test expectations independent.
- C: Share or infer the list from build.yml for both producer and policy.
- D: Replace exact-body validation with a general semantic PowerShell parser.
- E: Keep duplication and add a special consistency assertion/test.
- F: Remove the admission-body check. Deferral retains A and has no separate behavior.

**Fresh rubric, fixed before scoring.** Scores1–5: 1 fails the criterion, 2 weak, 3 adequate with a material limitation, 4 strong, 5 fully satisfies the bounded need. Weighted total is sum(weight × score)/5; scores are engineering judgments, not measurements.

- Independence (35%): Keep policy authority separate from workflow data and fixed at three supported cells.
- Clarity (25%): Reduce internal edit/error paths without obscuring the literal policy contract.
- Behavior (25%): Retain byte-equivalent expected statements and all current refusals.
- Verification (10%): Allow independent role-mutation controls and transparent review.
- Cost (5%): Minimize ongoing machinery and migration work.

| Option | Independence | Clarity | Behavior | Verification | Cost | Total | Key limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 5 | 3 | 5 | 4 | 5 | 88 | Correct today; two internal lists remain. |
| B | 5 | 5 | 5 | 5 | 4 | 99 | Only fixed policy data may generate expected text. |
| C | 1 | 4 | 2 | 2 | 3 | 44 | Workflow would supply its own role allowlist; ineligible. |
| D | 4 | 2 | 3 | 2 | 1 | 58 | New parser surface has no consumer need. |
| E | 5 | 3 | 5 | 5 | 3 | 88 | Adds another control to maintain instead of removing duplicate data. |
| F | 1 | 2 | 1 | 1 | 5 | 29 | Removal violates required admission; ineligible. |

**Selected solution.** Use B. Keep the three platform IDs in generatorPlatforms. Build the expected array statement from those literal IDs. Keep build.yml independent. Keep test role names independent. Do not read role names from the proposed workflow. Do not add arbitrary configuration or change the role set. The generated expected body must equal the previous body.

**Verification and limits.** Run the affected workflow-policy tests and three independent workflow mutations. Preserve A06-R1 native-exit checks and both required-context spellings. This refactor does not improve the already fail-closed runtime policy; its benefit is internal maintenance clarity. No new hosted proof is claimed.

**Primary references and existing decisions.** A06-D1 fixed independent consumer data; A06-D2 finite useful oracles; A06-R1 immediate native exit selection. Validation is repository-source evidence, with no external platform behavior needed.

Hard constraints: preserve the three finite cells, independent workflow/test oracles and exact same-revision admission. Completion: affected policy179/179 pass, including the three new independent role mutations; no workflow admission body or required-context contract changed.
