<!-- markdownlint-disable MD013 -->
# A21 initial two-file implementation

State: focused-ready partial implementation of selected whole PS base P94. No new base selection, completion redefinition, accepted source, or convergence claim. Product changes are unstaged in `C:/Users/flesniak/.codex/worktrees/ps-shared-governance/PSStyleGuide`, branch `codex/instruction-validator-convergence`; HEAD remains `3ba0f4d9686af41ae0e77c65ea374fff9d1cef53` and the index has no delta from native tree `ea7e8d7da19cc80b4ec727d5a9c3dfd0e599f9b3`.

## Exact released scope

Only `.github/workflows/Test-AgentInstructions.ps1` and `.github/workflows/Test-AgentInstructions.SelfTest.ps1` changed. Root's scoped implementation release supplies authority. No manifest, classifier, classifier test, workflow, hook, package, protected file, planning file, TF file, index, commit or GitHub write occurred. A02 quality reconciliation is independent work with its own sole scratch report.

| File | Bytes | Git blob | SHA256 |
| --- | ---: | --- | --- |
| Validator | 451674 | `9d4d88ffc6e50a8550247af47d048da644f908fb` | `44d5c8bc3a42927aded095b9cd75f1744ec1ac0d15d076f676f21c49f7ec193f` |
| SelfTest | 199979 | `58e247b752307b0e584a798e26293b7c02a053b4` | `76e64e5b670bf6d5b9408d36bc1dc13f1f9bc81ef1803edb5bdbb89593528438` |

## Implemented contracts

The public `RequireStagedInputMatch` switch is an independent local mode, compatible with local SelfTest and rejected with authenticated revision/endpoint modes. The staged ACMR path query is shell-free, NUL-decoded, bounded to the existing Git path-list cap and ten seconds. Existing safe local readers retain filesystem metadata/link/stream checks; selected staged inputs additionally require exact stage0 mode100644 Git blobs and ordinal equality of strict UTF-8 decoded content. All seven existing local reader call sites use this mode only for staged members. Executable closure includes the validator and its actual separate SelfTest file, including helper-only staged changes. Ordinary local worktree semantics remain unchanged when the switch is absent. Coupled setup inputs are not represented as checked.

Python resolution accepts only applications, retains Windows `py -3.12` and supported PATH fallback, and verifies exact3.12 with a fixed isolated `-I -S` program. The probe bounds stdout to4 bytes, execution to5 seconds, and rejects stderr/nonzero exit. A verified live context is cached by platform/name selection; injected deterministic fixtures do not populate that cache.

Node resolution accepts only applications, probes bounded strict JSON for the executable identity and supported version22+, resolves the reported absolute direct executable back to an application, and caches the verified live context. The fixed probe removes NODE_OPTIONS and NODE_PATH and bounds stdout to4096 bytes and execution to10 seconds, rejecting stderr/nonzero exit. Existing Markdown parser arguments/transport, strict JSON decoding, recursion checks and parser data contracts remain in the selected PS architecture.

The shared process reader gained an opt-in stderr rejection mode that reads at most one stderr byte; existing callers retain their prior behavior. All probes retain the existing bounded stdout, timeout, tree-kill, reaping and disposal path. No TF parser engine or framework was imported.

Schema2, metadata/classification/finalization/provenance logic, data-only early return, exact a71 initializer and prior-validator hash, protected cap/protocol expectations and existing mutation suite remain present. No generalized bootstrap authorization was introduced. The exact selected base and original decision inputs are unchanged.

## Focused verification

Windows PowerShell7.6.5, Python3.12.10 and Node24.18.1 were measured. Both final files parse with zero errors and PSScriptAnalyzer1.24.0 reports zero Error/Warning findings. `git diff --check` passes. Final identities are in `final-file-checks.json`; scope/runtime/results are in `validation-summary.json`; the complete two-file delta is `product.patch`.

`focused.ps1` extracts final production function ASTs and the two new durable SelfTest functions without executing the full script/SelfTest. It runs real private-index positive, unchanged, unstaged, partial staging, ordinal-case mismatch, helper-only, unsafe index mode, path-output bound and native-query failure controls. Runtime tests cover Windows launcher arguments, PATH fallback, aliases/functions, incompatible versions, direct Node identity, malformed/oversized/duplicate JSON, relative identity, actual Python/Node execution, live cache retention, preload environment removal, stderr, stdout bound and timeout. Negative process tests require the intended diagnostic. Final run passes; see `focused.log`.

`entrypoint-negative.ps1` exercises actual complete-script calls in a private Git repository: partially staged validator, SelfTest and classification manifest all reject with the intended mismatch; five incompatible mode combinations reject before input processing. All8 pass in `entrypoint-negative.log`. The actual product local entrypoint with `RequireStagedInputMatch` passes the ordinary contract; see `local-entrypoint.log`.

`mutation.ps1` changes extracted in-memory functions only. Tests reject removal of staged matching, removal of Python application filtering, and lowering the Node minimum to1. All3 intended mutation discriminators pass in `mutation.log`. No product bytes change during these mutations.

No expensive full SelfTest/aggregate was run. No Linux execution is claimed for this slice. Generation snippets are construction history, not authoritative final-source renderers; final product bytes and hashes above are authoritative.

## Remaining scope and gates

This slice does not complete A21. Coupled setup/hook enforcement and activation require atomic integration with actual accepted callers; A07's frozen16-path candidate is evidence, not installed/native authority. The classifier/wrapper selector omission and actual SelfTest loader closure remain for the shared-path integration. Shared algorithm/test-byte convergence with TF and the retained full matrix remain required; temporary shared size/protocol differences are unresolved boundaries, not permanent language exceptions. A20 protected grants and A03 option L remain pending and unchanged.

Root must refresh accepted source after the separate A02 repair, integrate eligible A07 caller changes and shared A21 files in ownership order, obtain independent quality on the assembled final inputs, and run one appropriate final aggregate plus actual commit/BH/native review/CI/landing gates. There is no blocker to reviewing this bounded slice; these are explicit remaining implementation and acceptance requirements.

## Coordinator comment-only correction

Independent review found seven new private-helper banners missing the existing change-without-notice warning. Root found four existing siblings in the same touched files. The identical canonical A02 help-conformance disposition applies; no new protected rule, rubric or executable change is needed. All eleven banners now include the warning, touched historical helper dates are October3, and the no-parameter GitRevisionText helper explicitly documents positional behavior.

Corrected validator:452255 bytes, blob552a28d7bec17b5f232cb08ccfe13d5bdc1bed7c, SHA2569cf6941630a647d128b9fbab7643cae013914c8f5180dd1dc0686b37d34c376d. Corrected SelfTest:200378 bytes, blob434d1ecb3f0d29bfc91cc2edef5422bca153b2f7, SHA256a20d675dd148792f406b81f34008f4af377f11e26689e077a73099098f522284. All non-full-line-comment bytes are identical to the focused-tested inputs. Parsed executable tokens excluding comments/newlines are also identical; both final files have zero parser errors and analyzer warnings/errors. Behavioral tests were not repeated solely for this correction. Independent reconciliation and separate Linux core checks remain pending.
