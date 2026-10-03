<!-- markdownlint-disable MD013 -->
# Independent quality: A02 landed push completion-status repair

State: FINAL INDEPENDENT LOCAL QUALITY PASS, refreshed for PR226 round10, on unchanged actual commit `a7b57b58d291068ed12575f66224e0e0a2f5f1af`. Source, focused evidence, final freeze, terminal aggregate, actual commit, committed B/H and both current-input remote-review reconciliations pass. No material finding is open in the reviewed two-path change. Candidate instruction CI remains live; this is not merge/landing approval or owner authority.

## Inputs and scope

Read current STATUS first, then the A02 task/current result and canonical F13 completion-boundary continuation published at planning commit `b2d7c5138438a3eaa831cd53cc1c5eee1d43e15b`. The selected S96 repair is reviewed without revisiting the base-selection decision. Product worktree: `C:/Users/flesniak/.codex/worktrees/governance-push-exit/PSStyleGuide`, branch `codex/governance-push-exit`. Accepted native baseline is `3ba0f4d9686af41ae0e77c65ea374fff9d1cef53`, tree `ea7e8d7da19cc80b4ec727d5a9c3dfd0e599f9b3`.

Reviewed the complete contents of both changed files and their entire diff against HEAD. The change is exactly one production status-guard replacement plus its existing caller regression test; current diff counts are workflow +1/-1 and test +28/-9. No validator, SelfTest, manifest, classifier algorithm, package, protected instruction, permission, trigger or other caller change is present.

| Current restored-indentation input | Git blob | Raw SHA256 |
| --- | --- | --- |
| `.github/workflows/agent-instructions.yml` | `bd559e5e9b7015d83f45f705a4e7862dc2dc11d5` | `ee0595c59dd9601e0a6296b295969842faa5d4db35b2ba20fffa2d5273e915d7` |
| `.github/workflows/Classify-InstructionMaintenance.test.mjs` | `e05a22e85727e64cf491b1bd009fd943029dd770` | `44080988676f921d472569bdde743edc25c2b66acd50565f9ff51f3edeb28acc` |

The first available freeze recorded pre-indentation tree `5afca945e65092a064a33727d45118f63f64aebb` and workflow hash `43fc4cb1e5486bb000ac7310d705373f1998d4a267724c451dc718ff1b9d272e`. It is not the final reviewed identity. Root identified the formatting correction and the author restored the neighboring fourteen-space indentation. An independent raw-file comparison correctly rejected that stale freeze; the replacement must be reconciled below. The PowerShell expression and durable test bytes did not change during that formatting correction.

## Semantic and safety assessment

The repaired direct script call immediately tests `if (-not $?)`. No intervening command overwrites its execution status. The workflow still sets `ErrorActionPreference=Stop` and disables automatic native-error promotion for native calls whose exits it checks explicitly. A thrown checker exception remains terminating. An explicit nonzero script exit is rejected before the subsequent Node invocation. Successful direct script completion is accepted even when an internal native query leaves a legitimate nonzero `LASTEXITCODE`. The native fetch, identity and later Node guards retain `LASTEXITCODE` because those boundaries are native-process results.

This distinction agrees with Microsoft's primary [automatic-variable documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_automatic_variables?view=powershell-7.5): direct/call-operator scripts can leave the last internal native exit value, while `$?` describes immediate command execution status. The existing direct-real-checker reproductions supply the repository-specific evidence rather than relying on documentation alone.

Exact event B/H validation, nonzero/distinct endpoints, H==GITHUB_SHA, bounded credential-free baseline acquisition, replacement-object refusal, correct checkout role and no-authority diagnostics are unchanged. The accepted-policy job is unchanged. There is no automatic-variable reset, output-text success heuristic, exception waiver, weakened validator input or generalized initialization grant.

## Test relevance and evidence integrity

The durable test extracts the actual candidate-test run block. It preserves both checker call sites and writes a real `.ps1` at their actual relative path, with the fixture directory as cwd. This exercises a PowerShell script boundary instead of a function that assigns a conveniently successful global native exit value. The positive fixture runs a real native child returning37, then completes normally. Negative fixtures throw a genuine exception or explicitly exit9. The later Node stub records reach and obtains a genuine native0/7 result. Acquisition and later Node remain declared substitutes; these tests do not prove hosted fetch, real Node suite behavior, or the full validator by themselves.

The test asserts normal completion, intended rejection diagnostics, Node reach/non-reach, exact ProposedPolicy arguments, event discrimination and bounded fetch behavior. PR/manual controls skip ProposedPolicy. Existing malformed/missing/zero/same/mismatched/unavailable endpoints and native identity failure cases remain. The eight other classifier tests remain unchanged. Private temporary paths are created by `mkdtemp` and cleanup verifies their parent/prefix. Each PowerShell invocation is bounded to30 seconds; the driver's overall child test limit is120 seconds.

Read the actual Windows and Linux result JSON and terminal logs, not just the author's summary. Both final runs record nine tests passed, zero failed/skipped/cancelled. Node is24.18.1; the Linux driver records PowerShell7.5.0; Windows7.6.5 is the supplied measured environment. Both platform records bind the test source to SHA256 `44080988676f921d472569bdde743edc25c2b66acd50565f9ff51f3edeb28acc`, which matches the current product file.

The old-guard mutation fails the positive push case with the production transition failure diagnostic on both platforms. The deleted-guard mutation fails the explicit-checker-exit assertion on both platforms because later Node0 otherwise masks exit9. These discriminators establish that the durable test requires both the repair and retention of an explicit completion guard; it is not an implementation-mirroring string assertion. The mutation driver changes only the read workflow guard and declared source/dependency URLs. Its failures are expected evidence, not failing candidate tests.

Reviewed `static-results.json`: Node syntax, diff check and six affected YAML/workflow/format hook checks each terminated0. These precede the indentation restoration, which changes no PowerShell behavior; final-byte static/aggregate evidence must cover the final identity. No broad rerun is required solely to claim a new behavioral result from indentation.

Checked the real unchanged-validator completion-boundary logs against `repair-status-results.json`. Exact a71/3ba succeeds and reaches the later phase; historical48/3ba rejects the exact initialization before that phase. The log hashes match `c4b5f326d728d2b7b0506ff32c2f8bfc0fcce4d248e0a0d12d9848bc455f6389` and `ada5c6c3a25c6cc31c3f7098f0131df4813d25c9d3d137cfe22893aed6b2388b`. These bounded reproductions explicitly omit the already-run long SelfTest and substitute acquisition/later Node. They prove this boundary on that real checker/input, not eventual repair-commit B/H or hosted landing.

## Paired implications and limits

A21's selected whole PS implementation remains the base. This repair changes the test companion and workflow caller only. A21 must refresh its exact source after acceptance and preserve the corrected caller regression. No region port or new base selection is implied. The known bounded-wrapper selector omission remains separately owned by A21; this repair neither fixes it nor claims it is harmless.

A03 must retain the distinction between direct PowerShell completion and native process exit when adopting the repaired push caller in TF. It need not copy a nonexistent TF push guard now. A03 owner-label/required-context decisions remain unselected. A20 protected-policy/capacity grants remain pending. A07's disjoint source work and later caller integration remain separate; this review grants no ownership of its paths or authority to merge concurrently.

The initial local review inherited A02 round9/80. PR226 now consumes round10/80 while preserving the original October10 deadline and transfer0/12. The previously failed landed run remains failed evidence. Current review/commit evidence is reconciled below; no merge or landed acceptance is claimed.

## Corrected final-freeze reconciliation

The corrected freeze is now `f5a83173a667d0d08225ec0cd391cedb4e659a77`, with `repair-final-freeze.json` SHA256 `b0fa83bcc1c6e5bf10de06eb371431b1aa1044a7624f344ef3d73aaba9044acd`. Independently verified all73 current raw file lengths/SHA256/Git blob IDs against the freeze and all71 unchanged paths against their baseline identities; the exact two-path patch hash agrees. After root staged the candidate, independently compared all73 actual index modes/blob IDs to that same frozen table. No unstaged difference remains.

The final workflow reconstructs the exercised workflow hash exactly when only its two restored indentation spaces are removed. Independently parsed the author's saved tested/final run blocks: both have zero parse errors and their ordered token Kind/Text lists are exactly equal. Reviewed final-byte `format-static/static-results.json`; diff, YAML syntax/style, actionlint and workflow schema checks all terminated0. The final corrected workflow and unchanged test hashes in the table above are the review inputs. The earlier5af freeze is historical only.

Root reports one normal final-byte aggregate running from2026-10-03T07:02:05.906333Z, session51371, on this exact staged tree. Running is not passing. The reviewer will reconcile the terminal log/result and eventual actual commit/B/H before changing the approval state.

## Final reconciliation

The normal final-byte aggregate terminated successfully at `2026-10-03T07:45:18.866999Z`: all10 hooks passed, all73 raw/index entries remained unchanged, and index tree remained `f5a83173a667d0d08225ec0cd391cedb4e659a77`. Independently read its terminal log and end receipt and verified log SHA256 `8a08f43aa8f330c8f47ebdaff5ab88a771be2476eb2d143fb9f5ba5323b171b4`. This supersedes the running state above.

Independently inspected actual normal commit `a7b57b58d291068ed12575f66224e0e0a2f5f1af`: its sole parent is accepted baseline `3ba0f4d9686af41ae0e77c65ea374fff9d1cef53`, its tree is the exact frozen/aggregate tree `f5a83173a667d0d08225ec0cd391cedb4e659a77`, and its complete delta is precisely the two reviewed paths. Both committed blob IDs match the table above. Normal commit evidence records successful creation after the all10-hook aggregate, and the worktree is clean. No additional suite was run by this reviewer.

Independently read `actual-endpoints-a7b57b5.json` and each of its three terminal logs, verifying every recorded SHA256. Exact B=`3ba0f4d9686af41ae0e77c65ea374fff9d1cef53` / H=`a7b57b58d291068ed12575f66224e0e0a2f5f1af` passed FinalizeMetadataNow, MetadataClassificationOnly and ProposedPolicy with process exit0; the last result completed at `2026-10-03T07:49:01.861855Z`. The logs preserve their distinct finalization, data-only and proposed-no-authority semantics. Log hashes respectively are `619babe4db1b84e5ab1a05306b559753c097cd906fdb340814ca0bc08738e040`, `1208b8aeeaa46d2ea84e5143f09c780cc32bb808cdd06e2096c789ef8384b9d7`, and `6d748dfa694a16d2911d9266764733483daf5ac9151fc4bc7b1ae0e3444bd577`.

All requested local-quality gates are reconciled. Current-input remote reviews are reconciled below; native candidate CI, normal merge gates and actual landed CI remain separate lifecycle requirements. The historical failed landed run is not relabeled as passed.

## PR226 round10 current-input review reconciliation

Read STATUS first, then the complete paginated review/comment collections in `PR226-round10-observation4.json` (captured `2026-10-03T08:02:16.147905Z`) and the full body/thread gate in `PR226-round10-review-gate.json` (captured `2026-10-03T08:02:37.396414Z`). Both bind exact H=`a7b57b58d291068ed12575f66224e0e0a2f5f1af`, B=`3ba0f4d9686af41ae0e77c65ea374fff9d1cef53` and body SHA256 `618a57385e0c1e281720551d0c4ebc4c7963e897d20cfbdb815f4bc6319b58a4`; independently recalculated the body hash and confirmed both full body strings agree. The body accurately describes the narrow change, fixture substitutions, local evidence and separate candidate/landed requirements. Reconfirmed the actual local commit's parent/tree, exact two-path delta, both committed blob identities and clean worktree; prior final-byte evidence remains applicable.

Copilot review `5399634534`, authenticated author ID `175728472`, is COMMENTED on exact H at `08:01:05Z`. Its actual overview explicitly records **Balanced** and **Findings: None**. Request event `32387153251` and successful exact-head Copilot workflow `37107779085` agree with that review. Effort is observed from the submitted body, not inferred from identity or API acceptance. The complete review-comment collection is empty; GraphQL reviewThreads is empty with `hasNextPage=false`, so no unresolved or hidden paginated thread is being treated as resolved.

The overview's “Needs a closer look” paragraph raises the sensitivity of direct PowerShell `$?` versus stale native `$LASTEXITCODE` semantics and asks for human confirmation; it supplies no concrete defect or requested code correction. I assessed that concern against the already-read real-script fixtures on Windows7.6.5/Linux7.5.0, their intended old/deleted-guard mutation failures, the immediate guard position and preserved terminating-error/native-exit handling, and the real accepted/committed B/H evidence. Those directly address the stated semantic risk and support local quality without another implementation or test cycle. This assessment does not claim a human confirmed the change or turn the bot overview into owner/merge authority; any actual human approval gate remains separate.

The remote Codex manual request is authenticated comment `5966954344`, author ID `11204406`, created `07:55:56Z`. Terminal result `5966967203`, authenticated bot ID `199175422`, reports no major issues and reviewed commit `a7b57b58d2`; summary `5966923385` from the same bot is **Completed**, **Manual request**, commit `a7b57b5`, updated `07:58:02Z`. All three complete comment bodies were read. Their chronology and exact-head identifiers bind this requested round; the earlier automatic activity is not substituted for the manual request. No concrete finding appears in either current-input review surface.

The snapshot still has instruction run `37107706676` and candidate job `111159381917` in progress on exact H, with pending status rollup/UNSTABLE merge state. **Merge is not approved by this report while that final candidate gate is live.** Its terminal outcome, fresh merge-time identities/review surfaces, ordinary merge conditions and actual landed push CI remain required. A failed candidate or landed result must be addressed; local/remote review success cannot replace it. No native settings/protected expectations or A03/A20 authority changed.

The independent reviewer has made no product/index/planning/GitHub changes and has rerun no expensive SelfTest or full suite. Its only saved output is this scratch report.
