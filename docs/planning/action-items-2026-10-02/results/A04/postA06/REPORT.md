<!-- markdownlint-disable MD013 -->
# A04 post-A06 read-only readiness, 2026-10-05

D04-1 R93, D04-2 Q99 and D04-3 C93 remain applicable. No distinct material defect was found within the changed relevant inputs. A04 remains validating, implementation unaccepted, transfers 0/8, review rounds 0/80 and review clock not started. This is readiness inspection only; no runtime tests, suite passes, source/peer acceptance or independent product-quality gate is claimed. The original both-repository outcome and caller contracts remain intact.

## Exact inputs and provenance

- Accepted identities supplied by the coordinator: PS d7b206adbce4f54edd6dd3d86d3dc2fa8e344b48 / tree d0025e28eaaef57f4466bc83e9154cd9e7115fb3; TF e21b74fe0b56551008f78f9f2946cd2a0f9c19ce / tree 89f470ceb6b3e6e9d4ae757e38997f1c6e7bd631. Local raw objects confirm these commit/tree relationships and file identities; they do not reverify moving GitHub main refs or independently grant acceptance.
- Prospective A06 local commit d7bb8ada326d52fab091b1d59b932288d56c4d91 / tree 0d0be7e39c29abf29b67384f3c44796a06118abf and prospective staged final tree fd66ed6c5b94d8c012a0aa06c8d30f2ae16746c6 remain unaccepted. Only the supplied immutable objects were read; the index was not queried or rewritten.
- Native PR234 remains coordinator-supplied head 07636c8633b8544eb30c71ce1b24d2bcdef4c74e, unaccepted. No native GET was needed and no fresh native-ref verification is implied. Root v6/session24813 source guard remains live.

The accompanying identity-change-catalog.json records mode/type/blob/SHA-256/size for all 19 already-scoped paths in each of four snapshots (76 identities), prior identities, changed-path comparisons and retained evidence hashes. All are ordinary 100644 blobs; no missing or renamed scoped path was found. This does not expand the old census.

| Comparison over existing 19 paths | Unchanged | Changed |
| --- | ---: | ---: |
| Prior PS f168f83 to accepted d7b206a | 13 | 6 |
| Prior TF 56cb041 to accepted e21b74f | 17 | 2 |
| Accepted PS d7b206a to prospective A06 d7bb8ad | 11 | 8 |
| Prospective A06 d7bb8ad to staged final tree fd66ed6 | 19 | 0 |

Prior PS changed inputs: .github/workflows/Test-CiHelpers.test.mjs, .github/workflows/Validate-WorkflowPolicy.mjs, .github/workflows/Classify-InstructionMaintenance.mjs, .github/workflows/agent-instructions.yml, .github/workflows/copilot-setup-steps.yml, .github/workflows/scripts-README.md. Prior TF changed inputs: .github/workflows/Classify-InstructionMaintenance.mjs, .github/workflows/scripts-README.md. These replace the old test/policy integration snapshot; prior native checks and suite successes are historical, scoped evidence.

## Unchanged download preimage and decisions

Both complete ordinary initializer identities match their respective prior postTF66 identities: PS blob dc0d195c72d8404e45c6eb39cb102898fd22b667 and TF blob 906460d818674199b32294185ed6525c143b48bb. A06 local and staged trees retain the PS initializer. All four download/native-exit/digest segments remain exactly 611 bytes, SHA-256 5e84f78352fcfa91d07bba26533e11acbe6010ce41083be4075daa36a95a29d0. They still use connect20 / attempt180 / retry2 with neither first-argument --disable nor --retry-max-time. Thus the confirmed retry-admission and curlrc findings remain unchanged and require the selected implementation, not new scoring or research.

Keep the official pinned Node24.18.1/npm11.16.0 archive, SHA-256 d6c664df3f3f61458e8c277585571328522d705166723a7c7823a9253a4d15a0, fixed curl/tar resolution, native failure before digest, digest before extraction/runtime, safe npm inputs and permission-limited preflight. No --retry-all-errors or outer process watchdog was selected. Retry-max300 bounds retry admission rather than killing an admitted transfer. D04-1's nominal483-second algorithm envelope and platform/curl-version limits survive; neither old Windows timings nor short fixture constants establish a strict300-second deadline.

## Current fixture and classified-caller integration

C98 accepted PS supplies TF66 blank/whitespace RUNNER_TEMP/GITHUB_PATH/GITHUB_ENV negatives and loader-identity/realpath direct-call detection; keep them. It also expands the candidate suite with the existing local-validation and lint test files. TF's scoped changes remove an unused path import from the classifier and clarify the script index's existing helper commands; they do not change ordinary caller behavior. The initializer and Test-CiHelpers remain maintenance-selected in both accepted trees and staged A06; A06 adds Test-StyleGuideGenerator to this classifier without changing the A04 selectors.

A06 changes Test-CiHelpers for generator platform proof/admission/acquisition and both explicit artifact semantic roles; it changes Validate-WorkflowPolicy for three platform producer jobs and aggregate admission. Those changes require integration with the current full file rather than importing an old test/validator file. StyleGuide.WorkflowPolicyContract.v3 and readContract().roles.artifactVerifier remain; PS retains verify_generated_artifacts and TF retains verify. Result/preflight schemas remain StyleGuide.*.v1. The validator still checks initializer call shape, not curl internals; no full-source hash contract or flag sidecar is needed.

The actual ordinary fixture/acquisition/runtime block is byte-identical between accepted PS and staged A06: 21,929 bytes / SHA-256 3a68b1311e9a1a08d4999c3b13031c115263746081106e1acbff275c3f55db1e. Its fixture.run still uses synchronous PowerShell spawning with a30-second timeout. The current ordinary whole-helper cases continue to capture curl, exercise native failure/wrong digest/valid digest/tar/runtime versions/npm normalization and actual restricted preflight. They do not yet provide actual retry/Retry-After/stall/contamination behavior proof for the proposed two flags.

The existing Copilot asynchronous loopback case is also byte-identical: 2,483 bytes / SHA-256 21f7dbaefcef62808eac2a5d815f4ab4a822278eaebb56485feb1dccb8789a98. It asynchronously spawns PowerShell so the parent Node event loop can serve the local HTTP server, with a15-second process timeout. A04 should reuse that asynchronous pattern for actual whole-helper cases and add an explicit failing watchdog; synchronously running its loopback child would prevent the in-process server responding. Validate production arguments before test-only endpoint/protocol/timing adaptation. Preserve the helper's real exit/digest/extraction sequence. The Copilot extracted-command fixture is distinct from ordinary whole-helper acceptance.

The four ordinary caller shapes are unchanged across the accepted and A06 prospective inputs: markdownlint policy and markdownlint jobs request WorkflowDependencies; agent accepted-policy and candidate-tests request both dependency switches. The shortest relevant job remains20minutes. Build has no ordinary initializer invocation. Both instruction jobs retain empty permissions, accepted-policy acquires accepted-base code and candidate-tests acquires candidate code. The broadened live push/PR guards and separate Copilot installer policy remain intact. A03-D6 B98 is already delivered in accepted paired Copilot workflows; do not implement it again under A04.

## Surviving runtime evidence and next action

The existing27 Windows curl8.21/PowerShell7.6.5 extracted-segment cases remain source-applicable characterization because the611-byte preimage is unchanged. The two full-helper Linux-platform rejections remain rejections. probe-results.json, native-evidence.json, validation.json and threat-map.md were hashed without modification; no old long probe, test suite or research was repeated. The prior postTF66 native refs/issue213 snapshot was not refreshed and must not be described as today's native proof. Existing accepted prerequisite runtime proof remains the coordinator's scoped evidence; A04 requires independent current Linux whole-helper proof before acceptance.

One concrete implementation delta remains after serialized A06 paired acceptance and the remaining A03/A07 owned integration gates: assign one PS writer to add first-argument --disable and --retry-max-time 300 to the existing ordinary command, preserve the retry-admission explanation, and extend the current whole-helper harness with actual Linux numeric/date Retry-After, connection/partial stalls, exhaustion/native failure, output reset, wrong/valid digest, curlrc dummy-header/additional-URL contamination and targeted bound/exit/digest-order mutations. Preserve accepted foundation controls and command-intent boundaries. Converge the common initializer under D04-3 through the normal PS source → needed TF counterpart → reverse comparison sequence; no generic initializer exception is justified. Refresh current native pins immediately before implementation and obtain independent product-quality/readiness evidence for the final candidate.

Only this REPORT.md and identity-change-catalog.json were written under the expressly permitted scratch directory. No Git ref/config/index/worktree mutation, fetch, new worktree, product/planning edit, test, generator, dependency operation, installation, native write, descendant or counter update occurred.
