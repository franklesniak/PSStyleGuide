<!-- markdownlint-disable MD013 -->
# R18 — applicability of selected D9-D B94 timeout semantics

Comment4179947028 repeats the already assessed relationship between the59-minute job ceiling and longer cumulative phase maxima. Reuse [D9-D B94](copilot-setup-decisions.md#d-use-the-service-supported-environment-and-honest-bounded-execution), including its original stakeholders, seven alternatives, distinct rubric, complete scores and selection. This is an applicability addendum, not a second timeout decision or a new score table.

The actual current YAML is unchanged in this respect. Its step maxima sum101 minutes, including45 for full validation. D9 explicitly states that phase bounds are not additive reservations, the outer59-minute cap wins, and slow preparation can leave less than45 minutes. Therefore the job ceiling is already a real upper bound; a shorter containing bound does not make per-step failure ceilings inconsistent. A guarantee of45 minutes after arbitrarily slow preparation was never selected.

Current primary [GitHub setup documentation](https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/customize-cloud-agent/customize-the-agent-environment?tool=webui) still limits the supported setup job timeout to59. [Actions syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idtimeout-minutes) separately defines job/step cancellation and says a lower execution limit can prevail. Raising this service job to the sum is unsupported. Reducing useful phase headroom solely to make numbers add up does not establish completion. A dynamic deadline or separate review setup is a distinct redesign that needs an actual requirement and its own evaluation.

Root's authenticated `round5-copilot-service-disposition.json` provides separate actual service evidence: full repository validation succeeded00:13:58–00:33:05UTC; Processing Request (Linux) was cancelled00:33:09–00:33:25; job ended00:33:28. The annotation names a20m0s external execution ceiling. It is not a59-minute YAML timeout, and raising that YAML value is not proved to affect it. A valid Lite review with four findings was delivered; service cancellation and review result remain separate facts. Root owns this lifecycle receipt and any later service investigation.

Earlier options displayed for this report map to canonical alternatives: no change reuses B94; raising the ceiling violates the supported limit; removing inner bounds is J; splitting service workflows is S; skipping/softening checks is C. A remaining-budget mechanism is a new implementation variant without a demonstrated current necessity. An extra inline comment could restate existing documentation, but no separate product improvement was validated that justifies another record/edit. Current maintainers already have the canonical explicit explanation and the actual bounded workflow contract.

Input: TF H `dde2b9abe761af69a7f561512df7d44d0dec6745`, tree `d59a740b7b1d88f7986075ac9328d9998629aa71`, B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. Full authenticated comments are in `review-comments.json`; ten immutable raw source blobs/modes/hashes are in `source-identities.json`. Windows/Linux probe code, commands and observations are in `probe.mjs`, `windows/result.json`, `linux/result.json` and `linux-run.json`. No product edit, dependency installation, full suite or aggregate was performed. Scores are judgments, not measured reliability.

Recommended disposition: retain selected B94. Keep all phase caps. Keep the outer ceiling. Report each actual timeout at the boundary that enforced it. Do not claim that setup failure prevents the agent from starting. Do not replay a full aggregate for this duplicate. No product scope or metadata change is proposed. Reopen only if fresh evidence establishes an actual setup-bound defect or a distinct accepted service requirement. No new permission or model attestation is needed.

## Coordinator selection and evidence

Root confirmed applicability of the existing D9-D B94 decision at 2026-10-05T00:50:37.233582+00:00. This disposition introduces no second timeout rubric or product change. The native thread remains open until its bounded reply and resolution are verified.

Root read all four proposals, checked all23 new weighted totals, sampled four raw source blobs against native H, and read the complete Windows/Linux probe results and probe code. The frozen diagnostic guard covers the unchanged78 tracked files, index and1910 dependency files. The nine selector controls passed on both platforms. Actual staged execution recorded two scans before the selected repair; these are synthetic timing samples, not production benchmarks.

Private commands and full outputs are located by [STATUS](../../STATUS.md), under `TF-coherent-20261004/implementation/round5-review-findings`. Windows used pinned Node24.18.1 with `probe.mjs`; Linux used `run-linux.py` with its exact recorded Docker image, arguments and network-disabled run. No full aggregate was repeated for the diagnosis.

| Diagnostic evidence | SHA256 |
| --- | --- |
| `HANDOFF.md` | `0bf764e89a1b02aa93fc41172df3221a41de572226e51c9a1f78daafbc29e701` |
| `evidence-catalog.json` | `f08f72e90776f16ab015e628d987aec219f264364b6c0b0bea7ced21a3c8b2e5` |
| `final-source-guard.json` | `6e695acbb4820fb7e661972869b79aa8019e8cf015252f2e4d020d6cb884f5ef` |
| `windows/result.json` | `1a0477bc77a6fbd664794cfcda7ac0e36a2ccf08dbe5bb7c245fb459da27b55b` |
| `linux/result.json` | `23cc455b29f420d268b775e8e268fc7474b896b03858898d4cf4ff6ab9f6c87b` |

[Canonical peer lifecycle](../A02/coherent-peer-candidate.json) records implementation, tests, native dispositions, review rounds and acceptance separately.
