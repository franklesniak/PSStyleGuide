<!-- markdownlint-disable MD013 -->
# A05 immutable event acquisition preparation

This is read-only preparation and a proposed protected change, not product acceptance. A01 is accepted; A02/A03 remain implementation prerequisites. The coordinator performed this analysis without a new model override. Transfers 0/8. No product write, PR, review, public comment or settings mutation occurred.

## A05-D1: acquire the recorded event object

**Validation.** PS175 remains open, unchanged since 2026-08-22, with zero comments. Its body explicitly withholds protected-file authority. Both native YAML guides require exact post-fetch comparison but omit the immutable-source requirement. Their only raw differences are Version and Last Updated. Reading the complete guide found no equivalent acquisition rule elsewhere. A local Git fixture moved an event branch from A to B: fetching A by full object ID returned A and its event content; fetching the mutable branch returned B, so comparison against A failed. A missing object returned native exit128. This demonstrates the reported availability/determinism problem without a live outage.

The historical PS174 commit 00d380586bb728544bad921f1ab809d49646a89b has the exact recorded tree 9dbea0305812650d4143df6f8cba8f195881fc12. Its devcontainer-ci.yml already maps github.sha to EXPECTED_REVISION, validates a full40-hex ID, uses a fresh isolated repository, fetches that ID at depth1 without force or submodules, and verifies the resulting commit. It has empty permissions and a ten-minute job bound. This is source conformance at the historical identity, not a rerun or a reason to redo its completed merge. Current live workflow work remains A03.

**Stakeholders.** Workflow authors, both maintainers, PR authors and guide readers need deterministic acquisition after ref movement. CI/security engineers need least privilege, bounded object acquisition, trusted execution and exact identity checks. Reviewer and incident/history custodians need a reproducible ref-move result and truthful historical attribution. Cost owners bear needless race failures and reruns. No new personal-data destination, cloud operation, translation or accessibility behavior is introduced by this instruction/test scope.

**Options before scoring.** N: keep post-fetch comparison alone. I: add one shared immutable-source rule, compliant/noncompliant examples and a local ref-move fixture. R: retry the mutable ref until it matches the old event. C: cancel superseded events or silently redefine the validated commit as the current ref. F: add a general acquisition service/controller or download fallback. Deferral preserves the missing instruction and supplies no new evidence. I may reuse native Git and the existing workflow test harness; it does not need a new production helper. R cannot recover A after a ref moves permanently; C changes the event contract; F adds an unsupported trust/install surface.

**New rubric.** Event correctness40%; preserved trust/failure boundaries30%; author clarity15%; regression value10%; maintained complexity5%. Scores1–5, higher better. Hard constraints: immutable source and exact post-acquisition verification; no force, credential expansion or privileged proposed-code execution; bounded depth/time; no silent event substitution; direct protected authority before product edits. Scores are judgments, not performance measurements.

| Option | Correctness | Boundaries | Clarity | Regression | Complexity | Total /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 4 | 3 | 1 | 5 | 48 |
| I | 5 | 5 | 5 | 5 | 4 | 99 |
| R | 1 | 3 | 2 | 2 | 3 | 39 |
| C | 1 | 2 | 2 | 1 | 4 | 32 |
| F | 5 | 2 | 2 | 4 | 1 | 67 |

**Selection.** Use I. Select the full immutable object ID for the event role. Fetch or check out that ID. Verify the acquired commit before reading its objects. Do not resolve a mutable branch or tag as a substitute. Fail if the event object is unavailable. Preserve existing least privilege and trusted-code rules. Do not execute proposed code in a privileged job. Keep bounded history and operation time. Use a fresh isolated destination for the example. Do not assume that omitting force alone makes every Git ref namespace reject non-fast-forward updates.

Git's documented refspec accepts a full object ID. GitHub documents event-dependent github.sha, including the default-branch commit for pull_request_target and the separate proposed head field. This distinction selects a role; it grants no trust. [Git fetch](https://git-scm.com/docs/git-fetch), [GitHub event reference](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows), [GitHub context reference](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts#github-context).

## Concrete protected scope and fixture

The two proposed patches touch only `.github/instructions/yaml.instructions.md` in PSStyleGuide and TerraformStyleGuide. Add the shared immutable-acquisition section and examples, one checklist item and one done criterion. Synchronize Version/Last Updated at actual finalization; previews use1.6.20261002.0 and2026-10-02. Preserve every existing least-privilege, trust-root, bounded-acquisition and non-forcing rule. No historical workflow edit, broader protected policy rewrite, setting, dependency or credential change is proposed. Both resulting guide previews are raw-byte identical.

The compliant example is a Bash step in a Linux Actions job with a two-minute step deadline. Its surrounding job must have least-privilege permissions and a fresh isolated Git repository with a verified fixed origin. It uses a depth1, no-tag/no-submodule fetch, empty refmap, a full validated immutable ID and exact post-fetch comparison. The example does not update an existing persistent ref. The noncompliant example differs in source choice and still checks the expected ID, exposing the ref-move failure. No unavailable commit falls back to a branch.

After A03 acceptance, append the focused portable Git ref-move fixture to the existing `.github/workflows/Validate-WorkflowPolicy.test.mjs` harness. Reuse its native-process and temp-directory idioms. Keep the fixture's exact fetch options aligned with the guide. Create two commits, move a local bare origin's branch, and use separate fresh destinations for immutable and mutable acquisition. Assert exact commit and file content, the mutable negative control and native missing-object failure. Bound every native process. Wire into the actual accepted test invocation if A03 does not already execute that harness; do not claim a test merely because a file exists. Confirm Windows and Linux behavior on the final implementation. Do not introduce a general production fetch wrapper for this guide-only rule.

The current local preparation ran native Git2.55.0.windows.5 via Python3.12 on Windows with a local file URI and15-second per-process watchdog. Every Git process returned its asserted native exit; no watchdog expired. It does not prove hosted GitHub transport, Linux execution, a network deadline, privileged isolation or final candidate acceptance. Probe evidence includes exact commands, commits and contents. Product implementation must still run front-matter YAML parsing, instruction validation, outer/nested Markdown and two clean full pre-commit passes as PS175 expressly requires. Refresh metadata against the actual published baseline. Complete the protected grant, PS review/quality/merge, peer port and reverse byte comparison before closure.

Next action: obtain the exact two-guide authority after reviewing the proposed patches. PS175 explicitly says that its creation does not authorize implementation. The repository's Protected Instruction Files rule also requires direct authorization. This pending grant is separate from A02 and A08.
