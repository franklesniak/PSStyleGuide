# UNSENT — GitHub Copilot code-review setup selection and timeout

Subject: Copilot review selects coding setup despite dedicated PR workflow; 20-minute cancellation after successful setup

Hello GitHub Support,

Please help identify the supported recovery path for [PSStyleGuide PR235](https://github.com/franklesniak/PSStyleGuide/pull/235). No bypass of repository review or CI requirements is requested.

Reviewed head: `504cd7672ac9604ace765a4f451346f801f09ddd`.
Base/default-branch commit at the captured run: `98177628b7bc02c646724bfc8aa0fd73fed0cd24`.

The head adds [copilot-code-review.yml](https://github.com/franklesniak/PSStyleGuide/blob/504cd7672ac9604ace765a4f451346f801f09ddd/.github/workflows/copilot-code-review.yml). It prepares verified tools/dependencies/hooks and checks final immutable inputs, without the aggregate validation step. The [coding setup](https://github.com/franklesniak/PSStyleGuide/blob/504cd7672ac9604ace765a4f451346f801f09ddd/.github/workflows/copilot-setup-steps.yml) retains full validation. Both declare a 59-minute job timeout. The dedicated file is not yet on the captured default branch.

[Original dynamic run37524396256](https://github.com/franklesniak/PSStyleGuide/actions/runs/37524396256), attempt1, was cancelled at the service's 20-minute limit. A documented Actions rerun request at 2026-10-06T21:10:39.477709Z returned HTTP403, “This workflow run cannot be retried”; attempt1 remained unchanged.

A supported Reviewers UI re-request with Balanced selected produced request event32641329434 at22:10:58Z and [dynamic run37538942393](https://github.com/franklesniak/PSStyleGuide/actions/runs/37538942393), attempt1, job112526912328. The job ran22:11:14–22:31:32Z. It used the coding-only full validation step22:12:12–22:29:13Z, which passed all11hooks. The final immutable-input guard passed at22:29:14Z. Processing Request ran22:29:19–22:31:29Z and was cancelled. The annotation reports the job exceeded20m. The workflow became completed/cancelled at22:31:33Z.

[Review5435249947](https://github.com/franklesniak/PSStyleGuide/pull/235#pullrequestreview-5435249947), submitted22:29:47Z, reports Lite and says full agentic review did not start before the timeout. Its product suggestions are being assessed separately. All14ordinary current-head runs passed in the saved snapshot; the cancelled dynamic result still blocks our merge.

The [environment documentation](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-code-review#customizing-copilot-code-reviews-environment) states dedicated-file precedence. The inspected text does not identify the revision used for workflow lookup. The coding setup's default-branch activation rule may be relevant, but we have not established which source revision this service run selected.

Could you clarify:

1. Which exact configuration commit/blob or registered workflow supplied job112526912328, and how can a repository owner observe that identity?
2. Is a dedicated copilot-code-review.yml in an unmerged PR eligible for selection? If not, what supported registration or activation path permits testing it while preserving normal green-CI admission? Is any documented repository/account setting relevant?
3. Does the20-minute service budget include both user setup and agent processing? Can this budget be configured for code review, and why did the declared59-minute job timeout not control this run?
4. Is the Lite start-timeout warning here expected after long successful user setup, or does it indicate a separate runner/agent startup condition? Which public diagnostic distinguishes those causes?
5. Is Actions rerun intentionally unsupported for these dynamic runs? What is the supported recovery surface after a terminal cancellation, and how should its resulting check supersede the failed current-input run without deleting or ignoring evidence?
6. If larger runners are a supported remedy for this account, which selection/configuration scope controls them and what observable proof confirms selection? We have not approved paid capacity or assumed it resolves the timeout.

Please provide a supported procedure and verification signals. We have not disabled checks, merged the cancelled input, altered the default branch, or sent further requests after our current finite retry allowance. We can supply relevant public log excerpts if needed.

Thank you.

---
Draft only. No message has been sent. Before sending, the owner must authorize the external message and the coordinator must confirm that the public input details are still current.
