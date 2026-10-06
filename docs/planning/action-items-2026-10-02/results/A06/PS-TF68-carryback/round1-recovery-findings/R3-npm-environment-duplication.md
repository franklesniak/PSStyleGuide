<!-- markdownlint-disable MD013 -->
# PS235 recovery R3: repeated npm environment sanitation

Status: READ-ONLY PROPOSAL. Recommend A96.1: retain four inline per-process blocks with independent behavior controls. Repetition and future drift risk are real. Current evidence shows no divergence and does not establish a net material benefit from a new helper/protocol. Root must display/select before corresponding edits.

## 1. Validate

Review5435249947/comment4201048196 targets H504cd7672ac9604ace765a4f451346f801f09ddd. Accepted B98177628b7bc02c646724bfc8aa0fd73fed0cd24 lacks this optional dedicated workflow. The exact committed checkout is clean. Four complete sanitation blocks572â€“593,625â€“646,676â€“697,836â€“857 are text-identical after LF decoding; evidence records each range/hash. They serve verification, locked installs, dependency-tree checks and hook activation. Six npm calls600,651,656,699,715,858 use the command array. Credential/Git-channel refusal also runs in each step. No current drift was found.

Each block reads inherited environment names with NUL separation, including names that are invalid Bash identifiers. It drops every case-insensitive npm_config_* name through /usr/bin/env -u, waits for the enumeration producer before another child, supplies only two reviewed npm config paths, and checks their device/absence/link conditions. Failed/partial enumeration fails before npm. The first step already publishes the two values to GITHUB_ENV. Those exports do not remove uppercase/mixed-case/invalid-identifier registry, script-shell or credential settings from later processes. A Bash command array is local shell state, not a transported array.

[GitHub environment-file documentation](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands#setting-an-environment-variable) describes publishing values to subsequent steps; it provides no arbitrary inherited-variable deletion or shell-array transport operation. Its NODE_OPTIONS restriction further shows that environment files are a constrained mechanism. Actual source and independent-process fixtures establish this repository's required filtering behavior, without a universal claim about every runner channel.

Test-CiHelpers943â€“1095 uses each actual coding/dedicated body, hostile uppercase/mixed-case names, invalid identifiers/newlines and dummy auth-name variables. It transports published values to another process which still has hostile names, and requires every npm subprocess to see only the reviewed npm config settings while retaining an unrelated value. Failed/partial producer cases require zero npm invocations. Hook activation1578â€“1620 separately covers sanitation, npm failure/wrong hooks and exact prepare argv. These are fixture children, not real npm installations or universal shell safety proof. Current LOCAL-VALIDATION records600 assertions without skips and explicit H94.1 interpretation; no tests were rerun here. Original failed wrappers/unknown old child causes remain unchanged.

Post-checkout factoring is feasible. These four steps run after exact anonymous acquisition, unlike pre-checkout helpers in R9. A repository helper is not categorically too early, but a new helper is absent from supported historical trees and not an admitted executable input today. Detection331â€“424 supports legacy Node-only,24.18.0 pre-declaration Node-only, modern full and the exact retained24.18.1 historical prepare command without the current installer. It does not require NpmTools.mjs or a new Bash helper. A required new helper would break those branches; unchecked absence fallback would expand trust. An independently verified accepted-source helper or workflow-owned bounded wrapper can solve availability, with new admission/lifecycle controls.

R9/PS234-R11 apply to explicit executable trust and independent actual-body oracles; their specific pre-checkout argument does not apply here, and their scores are not copied. C98.5 governs finite optional workflow presence and strict readers, not an additional helper. Current policy rejects aliases/anchors/tags at Validate-WorkflowPolicy215â€“216. GitHub platform support does not make aliases locally admitted. Export-only and a wrapper which filters every call are distinct options.

## 2. Stakeholders and constraints

Both maintainers and new contributors need an understandable policy and supported historical setup. Linux/Bash and CI/recovery operators need distinct deadlines, outputs, npm status and phase diagnosis. Security/supply-chain/privacy owners need credential/config names removed without value logging and exact admitted executable sources. QA/reviewers need independent actual-body negative controls rather than a helper generating its own oracle. Auditors need truthful legacy/current capabilities and preserved failed receipts. Cost owners benefit from fewer edits only after helper/provenance/lifecycle burdens are counted. Windows PowerShell admission is affected if helper inputs change; no new Windows Bash, cloud permission or accessibility UI requirement is proposed.

Hard constraints: filter every npm child case-insensitively; retain arbitrary-name/NUL behavior, producer failure, unrelated required values and config-source checks. Preserve argv/native exits/deadlines/phase outputs/credentials and historical branches. Admit any new executable from bounded exact verified source. No action, implicit BASH_ENV code channel, mutable PATH wrapper or broad missing-helper catch may bypass these controls. Helper/payload/alias/topology changes need finite caller/input/test closure first. High totals do not waive known failures.

## 3. Options before scoring

A retains inline code and independent controls. B adds exact synchronization checking. C uses a modern checkout helper with historical inline fallback. D acquires a helper from a separately verified accepted revision. E creates a bounded wrapper from a workflow-owned literal and calls it for each npm command. F merges npm phases into one bounded shell so one array persists. G publishes two values once and removes filtering. H exports a function/BASH_ENV/serialized array. I uses aliases or generated synchronized inline bodies. J uses a composite action/reusable workflow. K reuses NpmTools.mjs. L uses env -i with an explicit allowlist. M removes sanitation.

D/E remain per-call filters, not G. C+D reduces to D when accepted acquisition solves helper absence. C with a mandatory historical helper fails compatibility. B+generation is I plus an independent emitted-source check. B+C/D/E adds synchronization but cannot replace independent semantics controls. F+wrapper retains both topology and payload obligations. H with an explicitly verified file and invocation becomes D/E; implicit startup code is different. K changes actual invocation/runtime semantics and historical availability. Deferral/no-change is A, with no promised redesign/issue. Dropping checks is not a supported factoring variant.

## 4. Unique rubric

Ratings0â€“10 are judgments:0 violates;5 has unresolved material burden;10 directly supports the requirement. Total=sum(weight*rating)/10.

| Criterion | Weight | Specific meaning |
| --- | ---: | --- |
| S: Sanitation correctness | 31 | Six children, arbitrary inherited names, producer failure/no npm, config refusal and native argv/status. |
| A: Acquisition/history | 29 | Exact executable input, supported absent-helper trees, optional/required admission and immutability. |
| U: Usability | 20 | No setup burden, retained phase failure/deadline/output clarity and historical capability. |
| D: Drift/independent proof | 12 | Actual bodies, meaningful mutants and independent policy without one shared wrong oracle. |
| M: Maintenance | 5 | Coupled edits after provenance/lifecycle obligations are counted. |
| C: Delivery cost | 3 | Migration effort after security, authority and usability. |

## 5. Scores before selection

| Option | S31 | A29 | U20 | D12 | M5 | C3 | Total | Basis / limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A Inline + behavior controls | 10 | 10 | 10 | 8 | 7 | 10 | 96.1 | Equal now; independent process controls remain. |
| B Add synchronization test | 10 | 10 | 9 | 9 | 7 | 8 | 94.7 | Feasible but another spelling oracle is not sanitation proof. |
| C Modern helper + fallback | 9 | 7 | 8 | 8 | 7 | 6 | 79.1 | Two sources remain; new executable admission. |
| D Verified accepted helper | 9 | 9 | 8 | 9 | 7 | 4 | 85.5 | Solves historical presence with new acquisition/closure. |
| E Workflow-owned wrapper | 9 | 9 | 8 | 9 | 7 | 5 | 85.8 | New temporary executable/final guard. |
| F Merge phases | 9 | 9 | 7 | 10 | 7 | 4 | 84.7 | Must preserve all phase outputs/deadlines. |
| G Export once only | 2 | 9 | 7 | 8 | 8 | 9 | 62.6 | Ineligible: other inherited names remain. |
| H Function/BASH_ENV/array export | 5 | 7 | 5 | 8 | 5 | 4 | 59.1 | New startup-code/trust protocol. |
| I Aliases or generated bodies | 9 | 9 | 7 | 9 | 6 | 5 | 83.3 | Alias policy or generation/independent emitted checks change. |
| J Composite/reusable workflow | 7 | 7 | 6 | 9 | 6 | 3 | 68.7 | Action-free finite topology/acquisition changes. |
| K NpmTools.mjs | 7 | 5 | 6 | 8 | 6 | 6 | 62.6 | Historical/runtime and actual argv are not equivalent. |
| L env -i allowlist | 9 | 8 | 6 | 8 | 6 | 5 | 77.2 | Needs complete legitimate runner/runtime allowlist. |
| M Remove sanitation | 0 | 7 | 6 | 5 | 9 | 10 | 45.8 | Ineligible injection/config channels reopen. |

A clears constraints using equal code and qualified current controls. B is feasible but adds a spelling obligation without a demonstrated missing behavior discriminator. D/E are the strongest centralization paths; new executable/provenance/history contracts are material and the benefit currently prevents hypothetical drift. G/M fail sanitation; H/J/I need deliberate policy/authority changes. Scores do not authorize those changes.

## 6. Proposed controlled-English choice

Select A96.1. Instructions are short/direct with consistent terms; formal ASD-STE100 dictionary certification is not claimed.

1. Keep sanitation in each current npm step.
2. Keep all six npm commands inside the sanitized command array.
3. Keep the two exported values for later steps.
4. Do not use those exports as proof that other names are absent.
5. Keep the producer wait and config-source checks.
6. Apply a future sanitation change to all four blocks.
7. Test each actual body with independent hostile-input controls.
8. Keep the supported historical branches.
9. Do not add a helper or startup-code channel under this decision.
10. Let root record review disposition and final gates.

No source repair/new probe/repeated600-test run is necessary for A. Read-only comparison establishes no present drift, not a guarantee of future synchronization. Existing actual-body evidence remains at its recorded scope. No deferred helper project is promised. If actual drift or a concrete maintenance burden invalidates A, revise this decision before edits.

Any future D/E qualification must cover four callers/six argv/statuses; independent hostile uppercase/mixed-case/invalid-name/newline/dummy-auth channels; failed/partial enumeration with no npm; userconfig device/nonempty and globalconfig link/existence refusal; unrelated env preservation; missing/link/nonregular/oversized/changed-index/changed-revision helper refusal; all historical layouts; no arbitrary fallback; wrapper changes between calls; primary failure/final cleanup and immutable guards. Add exact executable inputs to validator/staged/revision/final unions before use, including absent-to-present mutation detection. Use qualified Linux Bash/env in bounded offline fixtures. No helper has been built or executed; old fixtures do not qualify a future candidate. Alias/topology/NpmTools alternatives need their own admission parity.

## 7. Limits and accounting

Evidence binds source/blob/mode, four equal blocks, six calls, inspected tests and prior decisions at proved scope. No candidate/parser/import/test/install/native API, product/Git/index/ref/planning/state/counter mutation or descendant occurred. B99 stays frozen. Lite/start warning is recorded recovery evidence, not grounds for an effort-only re-request or service-selection proof. Round1/deadline2026-10-14T20:09:39.767792Z and transfers2/4/6/6of12 are unchanged. Root owns native disposition/acceptance; recovery-cap analysis has another owner.
