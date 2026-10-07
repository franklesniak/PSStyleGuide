<!-- markdownlint-disable MD013 -->
# UNSENT: Copilot review setup selection and 20-minute timeout

Subject: Successful setup followed by repeated Copilot review timeout; dedicated workflow activation is unclear

Hello GitHub Support,

Please identify the supported recovery path for [PSStyleGuide PR #235](https://github.com/franklesniak/PSStyleGuide/pull/235). We need to retain the repository's normal review and successful-CI requirements.

Current reviewed head: `5e8ccbbe45679ab58a202c672554ffda56a0a9f5`.
Base/default-branch commit at the recorded run: `98177628b7bc02c646724bfc8aa0fd73fed0cd24`.
The repository is public. The failure annotation reports a runtime limit; we have not established a billing restriction.

The PR adds a [dedicated code-review workflow](https://github.com/franklesniak/PSStyleGuide/blob/5e8ccbbe45679ab58a202c672554ffda56a0a9f5/.github/workflows/copilot-code-review.yml) that installs verified tools, dependencies and hooks and checks final immutable inputs. It omits the full repository validation step. The [coding setup](https://github.com/franklesniak/PSStyleGuide/blob/5e8ccbbe45679ab58a202c672554ffda56a0a9f5/.github/workflows/copilot-setup-steps.yml) retains that validation. Both declare a 59-minute job timeout. The dedicated file is not yet on the captured default branch.

With Balanced selected in the supported Reviewers UI, request event 32653656598 at 2026-10-07T02:34:29Z produced [dynamic run 37562640212](https://github.com/franklesniak/PSStyleGuide/actions/runs/37562640212), attempt 1, [job 112603164453](https://github.com/franklesniak/PSStyleGuide/actions/runs/37562640212/job/112603164453). The job ran the coding-only full validation step from 02:35:29Z to 02:50:28Z: 899 seconds, with all 11 hooks passing. The final immutable-input guard passed at 02:50:30Z. Processing Request ran02:50:34Z–02:55:05Z and was cancelled. The job ended at 02:55:09Z. Its annotation says, “The job has exceeded the maximum execution time of 20m0s”.

[Copilot review 5437075963](https://github.com/franklesniak/PSStyleGuide/pull/235#pullrequestreview-5437075963), submitted 02:51:34Z, reports Lite and warns that full agentic review did not start before the timeout. Its date finding has been evaluated, answered and resolved. The separate current-head Codex review found no major issues. Fifteen ordinary current-head workflow runs have succeeded, including the validation triggered by the factual PR-description update. The cancelled dynamic result still blocks merging.

The preceding head 504cd76 had the same 20-minute cancellation pattern in [run 37524396256](https://github.com/franklesniak/PSStyleGuide/actions/runs/37524396256) and [run 37538942393](https://github.com/franklesniak/PSStyleGuide/actions/runs/37538942393). An Actions rerun request for the original run returned HTTP403, “This workflow run cannot be retried”, at 2026-10-06T21:10:39.477709Z. A later Reviewers UI re-request did create a new run. These historical failures are retained separately from the current head. The current source includes a normally validated empty-array optimization; it does not establish a fix for service setup selection or the timeout.

The [environment documentation](https://docs.github.com/en/copilot/how-tos/use-copilot-agents/use-code-review#customizing-copilot-code-reviews-environment) describes the dedicated workflow. We have not established the exact configuration revision selected by the failing service job.

Please clarify:

1. Which exact configuration commit and workflow supplied job 112603164453? How can a repository owner observe that identity?
2. Can the service select copilot-code-review.yml from an unmerged PR? If it requires default-branch activation, what supported procedure tests that configuration while preserving successful-CI admission?
3. Does the 20-minute limit include both setup and agent processing? Can the code-review budget be configured? Why did the declared 59-minute job timeout not control this job?
4. Does the Lite start-timeout warning follow from long successful setup, or can it indicate a separate runner or agent startup failure? Which diagnostic distinguishes these causes?
5. What is the supported retry surface for dynamic review runs, and how does a successful recovery supersede the failed current-head check without deleting or ignoring its history?
6. Are repository/account settings or runner selection relevant here? If larger runners are a supported remedy, please identify the required configuration and observable selection proof. We have not approved paid capacity.

Please provide a supported procedure and verification signals. We have not bypassed checks or merged the failed input. Public workflow logs are linked above.

Thank you.

---

Draft only; no message has been sent. Facts are bound to the October 7 current-head terminal evidence and the successful 03:10:28Z description-validation run. At drafting, current-input recovery has used 1/3 attempts; the next permitted manual request is 03:34:29Z. This draft does not authorize a request, alter that clock or replace the permitted recovery attempts. Before sending, obtain the owner's explicit authority to contact GitHub Support and refresh only facts that changed. Preserve the previous unsent draft as historical evidence.
