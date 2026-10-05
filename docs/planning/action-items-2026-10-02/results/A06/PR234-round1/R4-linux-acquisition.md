<!-- markdownlint-disable MD013 -->
# PR234 R4: Linux acquisition environment and checkout bytes

Reviewed head: `24b18795e5f6e260b095310ddd116cb0f1b19f6b`; PS base `d7b206adbce4f54edd6dd3d86d3dc2fa8e344b48`; accepted TF `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce`. This is the canonical writer decision; root owns public replies, counters, integration and lifecycle. No protected guide change is selected.

**Validation.** Comments4188451151 and4188451200 are exact duplicate text (threadsPRRT_kwDOQkjdhM6pM-Hn andPRRT_kwDOQkjdhM6pM-IE). Both build.yml Linux acquisition prefixes accept each of the five named repository/index/object selectors before Git. Twelve actual-prefix probes show both clean cases plus ten selector cases exit0. Git documents that these selectors redirect repository/worktree/index/object operations. This is a real missing early refusal, not evidence that a hosted compromise occurred. Existing GIT_CONFIG_NOSYSTEM=1, GIT_CONFIG_GLOBAL=/dev/null and COUNT/PARAMETERS refusal already exclude normal system/global and enabled command-pair injection. Orphan KEY_n/VALUE_n pairs are not processed when COUNT is absent. No current LF drift was reproduced; an explicit autocrlf=false supplies the same documented checkout intent as Windows.

**Stakeholders.** CI and platform operators need initialization confined to the expected empty workspace. Security engineers and the owner need early refusal rather than silently changing an unexpected environment. Maintainers and reviewers need bounded inline bootstrap before repository helpers exist. PS/TF consumers need stable bytes; contributors should see fixed useful diagnostics. No write credential or new native settings authority is needed.

**Options, before scoring.**

- A: Retain the current Linux bootstrap and rely on later credential/identity checks.
- B: Reject the five named Git selectors in both Linux build jobs; explicitly set local core.autocrlf=false before fetch/checkout and validate its status.
- C: Clear those selectors silently, then set autocrlf=false.
- D: Reject selectors only; retain implicit Linux autocrlf default.
- E: Replace inline acquisition with a broad shared bootstrap/runtime installer. A credential-bearing checkout action changes the approved authority model and is excluded before scoring.
- F: Block all GIT_* variables. Deferral retains A and has no separate behavior.

**Fresh rubric, fixed before scoring.** Scores1–5: 1 fails the criterion, 2 weak, 3 adequate with a material limitation, 4 strong, 5 fully satisfies the bounded need. Weighted total is sum(weight × score)/5; scores are engineering judgments, not measurements.

- Confinement (40%): Reject the named redirecting inputs before native Git work; later checks cannot undo earlier writes.
- Bytes (20%): Make checkout conversion intent explicit and preserve goldens.
- Diagnostics (15%): Fail predictably on unexpected environment and failed native configuration.
- Compatibility (15%): Keep pre-checkout standalone bootstrap and existing Linux helper contracts.
- Evidence (5%): Test both callers and each refusal/configuration status.
- Cost (5%): Avoid unrelated installer or workflow changes.

| Option | Confinement | Bytes | Diagnostics | Compatibility | Evidence | Cost | Total | Key limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 3 | 3 | 5 | 3 | 5 | 52 | Current prefixes accept every named selector. |
| B | 5 | 5 | 5 | 5 | 5 | 4 | 99 | Bounded named-selector control, not exhaustive hostile-environment isolation. |
| C | 4 | 5 | 2 | 4 | 4 | 4 | 78 | Conceals caller misconfiguration. |
| D | 5 | 3 | 5 | 5 | 5 | 5 | 92 | Leaves platform intent implicit. |
| E | 3 | 4 | 3 | 1 | 2 | 1 | 55 | Broadens bootstrap implementation without a present need. |
| F | 3 | 3 | 2 | 1 | 2 | 1 | 48 | Broad GIT_* ban rejects intentional neutral variables. |

**Selected solution.** Use B. In both Linux build acquisition steps, reject GIT_DIR, GIT_WORK_TREE, GIT_INDEX_FILE, GIT_OBJECT_DIRECTORY and GIT_ALTERNATE_OBJECT_DIRECTORIES with the existing fixed error. Keep the existing token and command-configuration checks. After successful init, set local core.autocrlf to false. Check that command result at once. Stop on failure before remote setup or fetch. Keep Linux credential helper, fixed Git path, bounded fetch retries and exact commit checks unchanged. Do not claim that this finite guard is a general sandbox or covers every possible Git environment variable.

**Verification and limits.** Add a portable actual-body dispatch test for each Linux caller, all five selectors and both COUNT/PARAMETERS controls; require no Git call on early refusal. Check autocrlf=false before fetch/checkout and reject a failed config command. Fixed Git is replaced only by a recording child fixture; real hosted allocation and native Linux acceptance remain root obligations. Run syntax/policy and affected controls only.

**Primary references and existing decisions.** [Git environment](https://git-scm.com/docs/git#_environment_variables) and [Git configuration](https://git-scm.com/docs/git-config#ENVIRONMENT) document selector and COUNT behavior. [core.autocrlf](https://git-scm.com/docs/git-config#Documentation/git-config.txt-coreautocrlf) describes output conversion. Reuse D2 inline acquisition; do not port the R5 installer.

Hard constraints: fixed Git, empty-workspace acquisition, exact SHA checks, least privilege, existing helper and bounded retries remain. Completion: actual-body control1/1 passed across18 caller/case combinations; both selector-guard mutants plus missing configuration and status-check mutants were killed by the actual assertions. Linux inline parser/analyzer0 each. These are portable dispatch probes, not fresh hosted allocation or real network acquisition.
