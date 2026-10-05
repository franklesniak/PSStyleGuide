<!-- markdownlint-disable MD013 -->
# A14 refresh for merged PS234

**Retain D92 B96 and D93 B100. No new material A14 finding or decision is required.** Keep PS155 open as a maintainer-owned, conditional filesystem residual. Preserve PS156's retirement and historical test limits. This bounded source assessment does not accept A06, close a race, or establish paired convergence.

## Bound inputs and delivery state

| Input | Commit or tree | Tree |
| --- | --- | --- |
| PS base | d7b206adbce4f54edd6dd3d86d3dc2fa8e344b48 | d0025e28eaaef57f4466bc83e9154cd9e7115fb3 |
| Prior A14 candidate | 180fbb1eed69730c433f0a2aca164523c3c3a343 | same tree |
| Reviewed source head | dec18a6303bd6ad5fe9a43b383a62daa70527aca | fd66ed6c5b94d8c012a0aa06c8d30f2ae16746c6 |
| Actual PS234 merge | 98177628b7bc02c646724bfc8aa0fd73fed0cd24 | fd66ed6c5b94d8c012a0aa06c8d30f2ae16746c6 |
| Supplied current TF main | e21b74fe0b56551008f78f9f2946cd2a0f9c19ce | 89f470ceb6b3e6e9d4ae757e38997f1c6e7bd631 |

The immutable merge has the stated base and reviewed head as parents; its complete tree equals the reviewed tree. Coordinator/STATUS establishes actual source landing. Landed source CI acceptance remains pending in this assessment, and TF repair has not started. Local object inspection is not a fresh native-main, issue or runner census.

Read STATUS, A14 task/result, README, routing/lifecycle policy, applicable PS/TF AGENTS and the prior impact note/JSON. [evidence.json](evidence.json) binds all 51 prior object records (including absent paths) to raw Git modes/blobs/SHA-256, records 19 current scoped objects, and preserves changed-source extents. Prior note SHA-256: `2a5258039209cee7a82075142525614e38825fea1db23921db275b4d54beedc8`; prior JSON: `87de17b89dade792cc98f0d3555c06f1b1137d30e1f96be6a0faff02065128d3`.

## Changes since the prior assessment

Only six paths differ: generator, focused generator harness, build workflow, policy validator, policy tests and CI-helper tests. The full delta and the affected production/harness bodies were inspected.

- **R3 policy factoring:** The validator constructs the admission list from its own fixed three platform IDs. Workflow admission, dependency and job mutations have separate test expectations. The policy still admits exactly Windows 5.1, Windows 7 and Linux 7 results for the same revision, retains empty validator permissions and a separate contents-read committed-artifact publisher. This is admission factoring, with no new filesystem primitive or consumer authority.
- **R4 acquisition:** Both Linux acquisition bodies reject the five added Git path/object selectors before dispatch; existing credential/config selectors remain rejected. They set and check local `core.autocrlf=false` after init and before remote/fetch/checkout. Actual-body controls replace fixed Git dispatch and inspect ordering/refusal. Those portable controls are not hosted acquisition proof. No permission increase, hostile writer requirement or atomic path protection is introduced.
- **R5 summary scanner:** `New-FullPayload` now incrementally observes all emitted guide/marker/rationale lines at summary boundaries and retains separate text/heading flags. Its cursor is clamped after separator removal. This changes in-memory composition only. Repeated-boundary cases exercise content presence; they provide no filesystem guarantee.
- **R7 candidate identity controls:** Harness lines 350-398 run real fixture publication for both Replace and Move, with stable injected final observations different from the candidate. They demand uncertain-state refusal with the guard enabled and success when that guard is disabled, plus output byte equality. These are meaningful controlled guard tests. They do not perform native hostile substitution, establish race resistance or prove universal alias safety. Production candidate/final identity checks did not change in this delta.
- **R10 cleanup:** Harness lines 460-488 retain a primary test failure if cleanup also fails, emit a bounded warning in that case, and throw for cleanup-only failure. Success output follows cleanup. The same lexical parent/name check precedes recursive pathname deletion. This improves failure reporting; a GUID and checked name do not establish directory ownership or prevent concurrent substitution. This refresh did not execute cleanup controls.

## Raw binding of unchanged primitive analysis

Current generator blob is `9e52d7482e5105f8c661b1005ba0c76a8e2a939d` (raw SHA-256 `ffbaf150e328ec2aeb202d9db99b9a23dd30d9ee666628b5ea9195351e6b7514`). Its only changed function is in-memory `New-FullPayload`. The 43,232-byte prefix before that function is raw-identical to the prior tree (SHA-256 `4bfff2c1d71c12f5b23dda61f126b13c82a0783bd4e34a2ae73013fa4069788d`); the 37,938-byte suffix from `New-StyleGuidePayloadMap` through the entry point is raw-identical (`be7c9e789a943f5b84fdfa2455df4689f79770385fe08ca3388eb9ec4dc29e03`). No normalization was used for these comparisons.

Exact-path verifier blob `76cad06fd918ac2405981d205814c7e8d85e4dc7` and artifact gate blob `6dc5276d95ac5b161ce28e6ea8eb95f85accfe7f` remain raw-identical to the prior candidate. The scoped unchanged callers/helpers and TF source identities also rebind successfully. Reuse the prior analysis with its disclosed historical token normalizations; do not reinterpret those normalized comparisons as raw PS/TF equality.

Retain all check/read/spawn windows, path-based candidate readback/publication/cleanup, neutral-directory substitution, hardlink/Windows alias limits and same-user child authority. CreateNew's retained write handle and before/after observations do not make later pathname operations atomic. Snapshot checks can miss restored intermediate changes. No deleted extractor/context consumer or historical test claim is revived.

## Remaining predicates and acceptance rechecks

Reopen for a concrete supported-caller failure with input/host/result; an explicitly admitted untrusted concurrent writer or hostile writable parent; a specific useful primitive with supported portability/failure behavior; or a materially changed writer, promotion consumer, privilege, credential, shared runner or caller. Reopen an old PS156 property only for a current supported consumer or current failure. A newly available runner is useful only with a live affected branch; date/version or runner availability alone is insufficient.

After paired acceptance, A14 must bind the actual accepted PS/TF commits/trees and reverse comparison; inspect any changed shared primitive, TF descriptor/T2 admission or caller; and verify actual same-revision Windows PowerShell 5.1/7 and Linux PowerShell 7/ext4 results, twice per cell, with their exact measured limits. Read actual landed PS234 checks at the merge commit rather than substituting reviewed-head success. Recheck acquisition/configuration, child observations, permissions, credential projection, storage/parent assumptions and the separate committed-artifact publisher. Refresh issue155/156 disposition and applicable consumers. Assess qualified R5 root/runtime/product-5.1 and A16/A17 recovery changes when delivered, then repeat conditional-trigger checks at final A18/A19 inputs.

No new supported finding warrants an options/rubric exercise; the selected D92/D93 decisions remain applicable. In controlled English: Keep issue 155 open. Keep the maintainer as the risk owner. Preserve the limits in issue 156. Do not restore deleted helpers. Recheck the named inputs after accepted changes.

Validation was read-only identity/delta inspection. No tests, probes, fetches, dependencies, product/planning/index/ref/config changes, native requests or issue edits occurred. Only this report and evidence.json were written. A14 transfers remain 0/8; no PR clock started. A06 lifecycle counters remain with the coordinator. Next action: retain this source refresh and reassess actual paired accepted inputs. Worker returns idle.
