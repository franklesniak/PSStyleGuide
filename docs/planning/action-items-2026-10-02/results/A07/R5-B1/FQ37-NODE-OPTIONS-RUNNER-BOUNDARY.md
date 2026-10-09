<!-- markdownlint-disable MD013 -->
# FQ37 — unsupported NODE_OPTIONS runner record

Root-requested extension of the read-only analysis. Proposal only; no implementation or service-run acceptance.

## 1. Validate the current flow and materiality

Initializer1285 includes the literal `NODE_OPTIONS=` in every successful runner environment publication. The setter in [actions/runner FileCommandManager.cs](https://github.com/actions/runner/blob/main/src/Runner.Worker/FileCommandManager.cs#L151-L199) compares the key case-insensitively before setting its value. It records an error issue and skips the assignment for NODE_OPTIONS. The branch has no empty-value exception. NAME= with an empty value reaches that branch normally. The same restriction applies to multiline syntax. The [GitHub restriction notice](https://github.blog/changelog/2023-10-05-github-actions-node_options-is-now-restricted-from-github_env/) and [workflow-command documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands#setting-an-environment-variable) explicitly prohibit this key. Official runner tests cover blocked simple/multiline records and ordinary empty values separately. Empty-blocked behavior follows directly from the setter's key-only condition; no native runner replay was performed here.

Do not equate an error annotation with a proven failed job. The inspected setter does not throw or explicitly set task failure for this case. [ExecutionContext.AddIssue](https://github.com/actions/runner/blob/main/src/Runner.Worker/ExecutionContext.cs#L729-L800) logs/counts the issue; it does not change Result there. The verified defect is unsupported publication plus failure to clear the runner-held value. It can coexist with a successful process/job result. No current authenticated log demonstrating this exact annotation was obtained in this analysis.

The ordinary initializer removes NODE_OPTIONS in its own PowerShell process at1202. Its children inherit the sanitized environment. Lint removes it again at271 before Node dispatch. Test-AgentInstructions removes it from dedicated child ProcessStartInfo environments at3296/4295. Those controls are real and must remain. A later shell step is a new process. Removing the key in the initializer cannot clear a runner/job/workflow value for that process. Direct later Node invocations currently occur in four blocks: markdownlint.yml policy/validate68 and markdownlint/audit134; agent-instructions.yml accepted-policy validation96/102 and candidate-tests/test211. They do not clear NODE_OPTIONS locally. Node startup options can act before the requested JavaScript file, so in-script sanitation is too late.

The runtime README promises a reviewed runtime and safe handoff; claiming that the blocked record sanitizes every future Node process would be false. A supplied ambient selector is not evidence of an active attack. Nonetheless, a stale or unintended option can affect these actual consumers. FQ23's child-process sanitation is related precedent, not a repair of runner publication. FQ35 concerns an allowed key with a supported empty-record mechanism; do not use that fix for NODE_OPTIONS.

### Why passing current checks do not settle this

`agent-instructions.yml:24/42` chooses the PR base for accepted-policy; its initializer at72 therefore comes from that base. The [landed d159ff8 initializer](https://github.com/franklesniak/PSStyleGuide/blob/d159ff83d63d4d6916dcab8e7656958f2bad8fff/.github/workflows/Initialize-CiToolchain.ps1#L93-L103) is the earlier helper and does not write NODE_OPTIONS. Conversely candidate-tests selects GITHUB_SHA at133 and calls the candidate initializer162. Markdown jobs also select GITHUB_SHA at32/93. Do not label all PR jobs as base-owned.

Copilot service setup follows a separate inline Bash/PowerShell runtime workflow; it does not invoke the ordinary initializer. Saved service log `the authenticated Copilot job113762925880 log at line393` records setup-time authority d159ff8 and event checkout c1ef946. Its separate reader/acquisition behavior is not ordinary runner-record validation. The saved head-runs inventory reports successful service37913166099 and accepted-policy runs, while the two ordinary instruction test runs were pending at that snapshot. These observations do not prove or refute ordinary candidate environment-file sanitation. No new GitHub action was requested.

## 2. Stakeholders

CI operators need runner-supported commands and trustworthy diagnostics. Maintainers and newcomers need deterministic setup without stale process selectors. Security/privacy owners need no surprise Node preload before policy/audit/test code. Policy reviewers need an exact, narrow workflow grammar change if consumer sanitation is selected. QA needs real child-start evidence and causal mutants. Recovery users need FQ35's separate allowed-variable behavior intact. Audit custodians need correct interpretation of green runs and annotations. Both repository maintainers must understand that this proposal changes only PS ordinary consumers; cross-repository carryback requires separate ownership. No new settings, public action, dependency, translation, or artifact format is required.

## 3. Options

- A: Keep NODE_OPTIONS= or defer based on green runs.
- B: Remove the blocked record only; retain existing initializer/lint sanitation and explicitly limit the guarantee to those processes.
- C: Remove the record and add job/step YAML `env: NODE_OPTIONS: ''` to the four direct-Node consumer blocks.
- D: Remove the record and add mandatory process-local removal before Node use in those four existing PowerShell blocks.
- E: Route every ordinary Node use through a new shared wrapper with a configurable environment map.
- F: Remove Node-dependent policy/audit/test steps or fail setup whenever an inherited NODE_OPTIONS exists.
- G: Try multiline, a differently cased key, deprecated commands, direct parent-environment modification, or a runner/security exception.

G cannot deliver supported runner-file clearing and is rejected. Documentation alone collapses into A. B is a valid smaller repair of the unsupported record, but leaves the identified later direct consumers dependent on ambient selectors. C and D are finite combinations, not a redesign of runner files. E offers reuse at a larger interface/loader cost. F changes valid user input handling or removes required validation.

## 4. New rubric before scoring

Scale: 0 fails, 1 poor, 2 partial, 3 adequate with limits, 4 strong, 5 fully satisfies. Total = sum(weight × score /5). Hard constraints: do not bypass runner restrictions; keep existing successful-only publication and native-exit checks; keep required validation; preserve FQ23 sanitation; do not promise global future-step deletion. Any workflow validator edit must require the exact new control and keep fixed command arguments/status checks. No generalized command allowance.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Supported runner behavior R | 31 | Eliminate unsupported record and misleading handoff |
| Consumer startup safety S | 32 | Clear actual direct Node consumers before startup |
| Usability/compatibility U | 19 | Keep required checks and deterministic valid usage |
| Policy and test assurance P | 14 | Narrow policy delta and causal evidence |
| Maintenance M | 4 | Avoid wrappers and long-term exceptions |

## 5. Scores before selection

| Option | R | S | U | P | M | Total /100 | Key limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 0 | 1 | 3 | 1 | 5 | 24.6 | Unsupported/no clearing |
| B | 5 | 2 | 4 | 4 | 5 | 74.2 | Later direct consumers retain selectors |
| C | 5 | 4 | 5 | 4 | 4 | 90.0 | Declarative env needs exact schema admission |
| D | 5 | 5 | 5 | 5 | 3 | 98.4 | Selected; four explicit caller controls |
| E | 5 | 5 | 4 | 3 | 1 | 87.4 | New bootstrap and wrapper interface |
| F | 3 | 5 | 1 | 3 | 3 | 65.2 | Rejects otherwise supported usage/checks |
| G | 0 | 0 | 1 | 0 | 0 | 3.8 | Unsupported bypass |

Scores are engineering judgments. D wins because it addresses both the invalid record and the actual next-step boundary. Its policy changes require root selection; this worker has not implemented them. B remains the explicitly smaller valid option if root chooses to bound this finding to unsupported publication, but must retain the later-consumer limitation in that selection.

## 6. Selected proposal D

Remove only NODE_OPTIONS= from the initializer runner-record array. Keep NODE_PATH and the other supported records. Keep process-local selector removal in the initializer and lint helper.

Add `Remove-Item Env:NODE_OPTIONS -ErrorAction SilentlyContinue -Confirm:$false -WhatIf:$false` before the first Node call in each of the four blocks named above. Use one removal per block. Place the accepted-policy removal before its first direct Node call. Place the candidate-tests removal before the final direct Node test command. Do not change acquisition authority, token handling, Node arguments, or native-exit checks. Do not change Copilot setup.

Update Validate-WorkflowPolicy.mjs:474–485 to require three lines for validate/audit. Require the exact removal statement as line1. Validate the existing fixed Node call as line2. Validate the existing native failure check as line3. Do not accept arbitrary extra shell commands. Update corresponding positive/mutation fixtures. Preserve the existing instruction workflow admission checks. Root must review any additional exact-source fixture dependency found during implementation; do not weaken it to accommodate the change.

State that the initializer sanitizes its own child processes. State that each later Node caller must sanitize its process before invocation. Do not describe GITHUB_ENV as a global NODE_OPTIONS reset. These instructions use explicit conditions and one action per sentence; formal ASD dictionary certification is not claimed.

## 7. Verification plan — not executed

First use the real ordinary success fixture to inspect emitted records. Assert that no NODE_OPTIONS key is present case-insensitively. Keep NODE_PATH and FQ35's recovery record expectations. A disposable mutant that restores the one removed record must fail that assertion. A finite test-local runner adapter must reject NODE_OPTIONS before applying its value; cover empty/nonempty/multiline and differently cased key controls. Label this adapter as a source-derived model, not a native GitHub runner test. It must accept a normal empty recovery record and preserve unrelated values.

For the four workflow blocks, execute the exact extracted sanitation plus direct Node call boundary under the maintained Linux fixture. Use the existing bounded fake Node observer to assert NODE_OPTIONS absence and unchanged fixed arguments. Seed a harmless synthetic option in only the child environment. Test default, inherited Low ConfirmPreference, and inherited WhatIfPreference. Use a paired one-line omission mutant for each block; require the observer to reject the retained selector. Keep each whole block's native status failure path covered by existing tests. Do not execute Git acquisition or other unrelated commands in these narrow boundary fixtures.

Add policy positives for the exact validate/audit prefix and negatives for missing removal, removed preference overrides, extra command, changed Node argument, and removed failure check. Run Validate-WorkflowPolicy.test.mjs and Test-CiHelpers.test.mjs through the maintained transport after root release. At most 16 new small child executions, each timeout15 seconds/maxBuffer256KiB; finite registrations timeout90 seconds each. Reuse the real initializer success executions planned for FQ35 instead of adding duplicate archive installs. No network, runner process, workflow dispatch, or broad environment rewrite is needed for this local qualification.

Later authorized CI should be checked for this specific runner annotation and unchanged native outcomes on the repaired head. Local tests alone do not establish live runner admission. Existing successful service/base-owned receipts remain historical evidence with their original scope.

## Root selection and current status

Root verified the frozen analysis assets and all score arithmetic. The complete options, unique rubric, scores and selected instructions were displayed to the owner before implementation. Root selects option D under the standing clear-winner instruction. The earlier proposal wording records its original analysis stage. Product implementation and required tests follow; no test result in the proposal is promoted to executed evidence. Original PR239 round2/80, deadline2026-10-16T22:53:27.970214Z and A07transfer9/12 remain unchanged.

## Local implementation at source freeze

The unsupported runner record is removed. The four existing direct Node caller blocks now clear NODE_OPTIONS before startup. The policy validator requires the exact new three-line validate/audit form. Five existing catalog cases retain their original mutation causes with the same sanitation prefix. The complete policy suite passed181/0/0 in5352e0, and its inputs are unchanged. The four actual workflow boundaries each have a separate90-second Linux registration with four15-second/256-KiB children. The common fixture.run helper is unchanged. A finite LF runner model checks five blocked-key forms (including empty, nonempty, multiline and mixed case) plus the allowed empty recovery record. It is explicitly a source-derived model and is not native GitHub runner acceptance. The real initializer restoration mutant shares the FQ35 fixture scope. Native consumer, record and runner-model tests remain unexecuted. Root checked the current primary runner source again on2026-10-09; the key is blocked before assignment regardless of value.

The [frozen source record](current-main-validation/pr239-round2-source-freeze.json) identifies that historical repair input. Root syntax and whitespace checks passeda48f78.

## Current verification

All four actual workflow caller registrations passed on Linux. The record/output controls, source-derived runner model and policy tests also passed in their recorded environments. The runner model does not prove native GitHub runner behavior; fresh published-input CI remains required. [Current candidate and validation](current-main-validation/pr239-round2-validation.md) supersedes the pending-test statements above and identifies the actual input attribution and remaining gates.
