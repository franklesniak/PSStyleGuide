<!-- markdownlint-disable MD013 -->
# Independent A21 core-slice review

The mechanical guide-conformance finding is resolved. Bounded source-quality approval is confirmed for the corrected initial slice; no unresolved functional or documentation finding remains in this review. Focused behavioral evidence remains Windows/local only, and all pending integration/acceptance gates remain. I did not author this implementation, change product/index/planning/native state, rerun suites or spawn descendants.

## Original reviewed inputs and resolved finding

Reviewed current STATUS, A21 task/result, the complete selected P94 decision and its two-file release, complete actual diff, changed function/caller boundaries and saved evidence. Product branch is `codex/instruction-validator-convergence`, HEAD `3ba0f4d9686af41ae0e77c65ea374fff9d1cef53`, unstaged scope only the two released files; index has no delta from `ea7e8d7da19cc80b4ec727d5a9c3dfd0e599f9b3`.

| Input | SHA256 | Git blob |
| --- | --- | --- |
| Validator,451674 bytes | `44d5c8bc3a42927aded095b9cd75f1744ec1ac0d15d076f676f21c49f7ec193f` | `9d4d88ffc6e50a8550247af47d048da644f908fb` |
| SelfTest,199979 bytes | `76e64e5b670bf6d5b9408d36bc1dc13f1f9bc81ef1803edb5bdbb89593528438` | `58e247b752307b0e584a798e26293b7c02a053b4` |
| Implementation RESULT | `6ba8c4718b836dd232166b40abc85b0b975eda7316232ad0047c909e68135aaa` | Scratch |

**Original finding, now resolved:** all seven newly introduced script-specific helpers omitted the private-banner warning that parameters, return shape and positional contract may change without notice. Their existing non-public-API sentence was present. Affected validator functions: `Read-GitStagedInputPath`1138, `Test-Python312Application`1914, `Get-Python312CommandContext`1972, `Invoke-NodeRuntimeProbe`2074 and `Get-NodeApplicationContext`2127. Affected SelfTest functions: `Assert-StagedInputSelfTest`2263 and `Assert-ApplicationRuntimeSelfTest`2380. Lines refer to the original exact inputs above.

Native STYLE_GUIDE.md856 makes that warning mandatory for script-specific private helpers; none of these functions has a distributable-helper license/reuse exemption. This is the identical guide/help omission already adjudicated in canonical planning `results/A02/review-implementation-supplement.md`22–36. Reuse that existing disposition: add only the neighboring complete warning to these seven .NOTES banners, preserve behavior, then inspect the comment-only delta and refresh final identities. It needs no second rubric, protected-guide edit, new policy or repeated behavioral suite solely for comments.

## Source and evidence assessment

The slice faithfully retains the selected complete PS architecture. Public staged mode is local, including SelfTest, and rejects all revision/endpoint combinations before processing inputs. Its NUL ACMR query is shell-free, byte/time bounded and checked for native failure. Matching uses the existing safe local reader and exact stage0/100644 blob resolution, bounded index read, strict UTF-8 decoding and ordinal content equality. The two executable inputs are checked before the later SelfTest load; all seven prior local reader call sites propagate the switch only for selected staged members. Unstaged/ordinary worktree semantics remain. Coupled setup enforcement and caller activation are explicitly held, not reported as checked.

Python application-only resolution preserves exact3.12, launcher/PATH order, alias/function exclusion, isolated fixed probe and live cache keyed by selection. Node resolution validates application candidates, bounded strict identity JSON, absolute reported direct application and supported22+ version, with live cache and preload removal. Their operational probes use the selected process reader's existing time/output/tree-kill/reaping/disposal path. Opt-in stderr rejection reads one byte, refuses noisy completed probes and does not change existing callers' prior stderr behavior. Parser arguments, strict JSON/parser transport and data-only ordering remain in the selected core; schema, exact a71/hash/table bootstrap and existing metadata/provenance protections are unchanged by this diff.

Independently verified both raw product identities, unchanged HEAD and empty staged delta, and all eleven evidence-manifest file lengths/SHA256. Saved `product.patch` uses CRLF while Git emits LF; its ordered diff lines are identical to the actual two-file delta. Product raw hashes, rather than patch newline normalization, remain the authoritative inputs.

`focused.ps1` extracts final production function ASTs and exactly the two new durable SelfTest functions. It does not run the whole script or full SelfTest. Its terminal log passes the real private Git-index cases and runtime controls. Meaningful negatives include partial staging and ordinal mismatch, helper-only selection, unsafe mode, path-output bound/native query failure, incompatible/alias/function identities, malformed/duplicate/oversized JSON, direct identity, actual runtimes/cache, preload removal and process stderr/stdout/timeout diagnostics. The saved mutation driver changes only extracted functions and requires the intended failures for removed matching, removed Python application filtering and lowered Node minimum; all three are terminal successes as discriminators.

`entrypoint-negative.ps1` invokes the actual complete checker through native pwsh in a private repository. It proves partial validator/SelfTest/manifest mismatch rejection and all five staged-mode conflicts with specific intended diagnostics; all eight terminal results are present. `local-entrypoint.log` confirms actual product local staged mode passes the ordinary contract and honestly states committed-input finalization date is not verified. `final-file-checks.json` pins both exact inputs to parser-errors0 and analyzer findings0; these saved static results were read, not rerun. Runtime summary reports Windows PowerShell7.6.5/Python3.12.10/Node24.18.1.

## Remaining gates

No Linux, full SelfTest, aggregate, merged-source or peer acceptance is claimed for this slice. Those are known holds, not new findings. Integrate the accepted A02 repair and actual eligible A07 callers in serialized ownership, complete setup/hook activation, manifest/classifier/test/loader closure and retained contract matrix, then freeze final inputs and run the appropriate final Windows/Linux and one aggregate/commit/BH/native review/CI/landing gates. Keep A20 protected capacity/protocol authority and A03 workflow/maintenance decisions distinct. No base reselection, new clock, transfer or premature completion is supported by this review.

## Corrected final-input reconciliation

Coordinator's2026-10-03T08:01:07.208613Z correction completes all seven new banners and four existing sibling omissions under the same adjudication: validator `Get-GitRegularFileBlobId`1420 and `Test-DocumentMetadataHeaderIntent`5606; SelfTest `Assert-OptionalMetadataSelfTest`1877 and `Assert-GitRevisionTextSelfTest`2068 (sibling locations refer to the original snapshot). The four touched historical helper .NOTES dates are Oct3; the parameterless GitRevisionText self-test now has an accurate positional statement. No protected guide or executable behavior changed.

| Corrected final input | Bytes | SHA256 | Git blob |
| --- | ---: | --- | --- |
| Validator | 452255 | `9cf6941630a647d128b9fbab7643cae013914c8f5180dd1dc0686b37d34c376d` | `552a28d7bec17b5f232cb08ccfe13d5bdc1bed7c` |
| SelfTest | 200378 | `a20d675dd148792f406b81f34008f4af377f11e26689e077a73099098f522284` | `434d1ecb3f0d29bfc91cc2edef5422bca153b2f7` |

Independently verified both current raw hashes/lengths, all eleven complete banners and exact equality of every non-full-line-comment byte against the retained before copies. Read `banner-correction/correction.json`, `token-static-proof.json` and `verification.log`: both final inputs have executable tokens equal excluding Comment/NewLine, parser-errors0 and PSSA Warning/Error0. HEAD3ba and the unstaged two-file scope/indexea7 remain. Comment-only equality preserves the previously inspected meaningful Windows focused/entrypoint/mutation evidence; it does not create Linux or aggregate evidence. Bounded source-quality approval applies to these corrected hashes, with every integration/final gate above retained.

## D-A21-02 final loader-review reconciliation

**Bounded approval:** the selected E93 loader repair conforms to D-A21-02; no actionable source or evidence finding remains in this changed two-file core. This section supersedes the earlier Windows-only focused-evidence limitation. It does not approve the pending full SelfTest, aggregate, caller/setup integration, shared-path closure, peer convergence or native lifecycle gates.

Read the complete final decision and manifest. Independently verified decision SHA256 `03016f19797dd051e8ebb56fadb206fea252be58e71354ff4d89a0d4a1888908`, manifest SHA256 `5f0b6091b2b3b6ec48632a9ed5b59a671cf9d1803c91d5dedd619761b7e4e29c`, and all nineteen manifest entries' raw lengths/hashes. Reviewed the changed production and SelfTest regions, all runtime-context/default/cache accesses and actual loader/caller boundaries. HEAD remains3ba; index tree remainsea7; only the two authorized files are unstaged. Native PS2a2 source acceptance/integration is a separate coordinator-owned gate.

| Final reviewed input | Bytes | SHA256 | Git blob |
| --- | ---: | --- | --- |
| Validator | 452848 | `1c222f5baf94c3758247a41b028b4ff4d1a40cf7bc961fd3d6a25f573229936c` | `0b5789dbfc42fc05dfc4b99cd492aa578adb208a` |
| SelfTest | 203280 | `a6e1faa5e039a72f978a6d7f2d4d6cd1f69a6dc749b69adb55283fe172c0d754` | `92db79a8d552e8c9adade97818f92851b365373d` |

The validator initializes exactly five finite runtime fields in one hashtable. Private resolver parameters receive that reference; Python's platform/name defaults, live cache/key reads and writes use it, and Node's live cache uses it. Injected resolver/probe paths remain excluded from live caching. The existing Python key comparison, exact3.12 application probe, supported22+ direct Node identity, bounded process transport and environment removal are retained. The actual separate SelfTest call explicitly passes the reference, and its child binds that same object; no dot-sourcing, global state, public validator mode, extra module or authority grant is introduced. Existing root Python-name controls mutate and restore the same fields. Earlier eleven private-banner repairs remain intact and the new private parameter is documented.

The durable runtime control checks injected-fixture isolation, warms/verifies both live caches, creates a real call-operator child, confirms parent/child cache reference identity, changes Python candidate names to prove keyed-cache invalidation, restores the fields, and confirms original identity is reusable. Its temporary-child cleanup remains limited to its exact generated path under the private temporary root. This is a bounded ordinary fixture, not an atomic hostile-filesystem guarantee.

Independently compared the saved Windows and Linux generated parent/child scripts to final source AST text: all64 parent helper definitions, both exact child control functions, the child's parameter block, and the actual validator loader statement are present unchanged. The harness extracts the initializer and child binding rather than duplicating their semantics. This repairs the earlier same-scope verification gap; it does not execute the rest of SelfTest.

Read both platforms' final loader, eight actual-entrypoint negatives, four weakening-mutation, omitted-context and ordinary local-entrypoint logs. Windows7.6.5/Python3.12.10/Node24.18.1 and Linux7.5.0/Python3.12.3/Node24.18.1 show the intended positive boundaries and diagnostic-specific rejection. The fourth mutation defeats Python cache-key equality and is rejected by the actual child invalidation control. Removing the explicit loader argument produces the missing mandatory RuntimeContext diagnostic on both platforms; those are expected failing mutants, not passing candidate invocations. Ordinary local entrypoints retain the explicit committed-input finalization-date limit.

Original loader failures remain in `implementation/linux/loader-contract.log` and `linux/outputs/loader-native-origin.log`, showing the missing old script-scoped Python names. Linux diagnostic wrapping and copied executable-mode failures remain recorded separately; the subsequent harness-only whitespace normalization and private copied-file0644 correction do not change product diagnostics or authoritative bytes. Linux raw identities match the final inputs, mounts are empty, and bootstrap evidence uses the locked tools. The owned container's removal is author/coordinator-reported; I did not recreate or operate it.

Read the final-byte static receipt: both inputs have parser-errors0 and PSSA Warning/Error0; the author records clean diff checking. No behavioral suite was rerun for this independent review. All previous trust, staged-input, metadata, provenance, initializer, protected-authority and source-order requirements remain. Complete the pending assembled caller/setup/shared-file work, reconcile accepted A02/A07 inputs, then run final exact-byte platform/aggregate/commit/BH/review/CI/landing gates under serialized ownership.
