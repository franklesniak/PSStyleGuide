<!-- markdownlint-disable MD013 -->
# Current immutable-acquisition readiness

Selected [A05-D1 I99](design.md) remains applicable. [D08](../../DECISIONS.md#d08-owner-decisions-and-revised-preparation-direction-2026-10-03) already authorizes the exact two YAML-guide patches. Product implementation still waits accepted A02/A03 foundations. This preparation adds Linux local-Git evidence; it does not claim product acceptance.

The accepted PS input is f168f83b89f64b6bca9d520ddec4b58969060fb6. TF is the unaccepted staged tree525147aac9804088b8b9e743a7e441a5276d59f2 at B06ad4f7. [The evidence record](post231-readiness.json) binds all ten inspected files. Root independently checked every raw Git blob, mode, size and hash. Both54645-byte YAML preimages remain exactly those used for the approved previews; their only differences are Version and Last Updated. The previews remain byte-identical. Final metadata must use the actual accepted parents and authoring date.

The existing Validate-WorkflowPolicy.test.mjs is identical in both inputs: mode100644/blob295da6170ae721ca8c02509b308ac3660f66a974. Append the portable Git fixture there using its existing Node test/assert, bounded native-process and temporary-directory cleanup patterns. Both actual candidate-workflow commands already invoke this harness at line210 and fail on a nonzero native exit. No A05 caller change is currently needed. Preserve TF's extra local-validation suite and all existing tests.

The bounded existing-test census inspected eight PS and nine TF test/SelfTest files and the matching acquisition fixtures. Existing injected identity failures, native devcontainer acquisition, current-main audit and historical supply-pack cases do not supply the selected moved-branch, dual-fresh-destination and exact-content oracle. This finding supports adding that focused case; it does not retire or replace their useful controls.

## Additional Linux proof

The current Linux probe ran once with Git2.43.0 and Node24.18.1 in the existing pinned image, without network or installation, as UID65534 with a read-only root and read-only input mount. Writable fixture data stayed in a64MiB temporary filesystem. Each native child had a15-second bound and the container command a60-second bound. All37 native commands returned their asserted exits; no timeout, signal or native-process error occurred. Container exit0 took0.984seconds.

The local bare origin's event branch moved from A46a56bf72dbc3aff642d9be897cc152ca22aeceb to Be4107a36ce420331cef794f137fd47df0ecf262a. With the exact guide options `git fetch --no-tags --no-recurse-submodules --depth=1 --refmap= origin source:refs/remotes/event/target`, the fresh immutable destination still acquired A and `event A`. The fresh mutable destination acquired B and `later B`; native comparison with A returned1. Both acquisitions contained one commit. Fetching the missing object returned128 and left no target ref. The temporary fixture was removed.

The original Windows Git2.55.0.windows.5/Python3.12 local-file-URI proof remains valid historical evidence and was not rerun. Root checked its original receipt hash60d5be8e. Its commands use the same selected fetch flags. This preparation proves local Git semantics only. It does not prove hosted object retention, a network deadline, privileged isolation or final cross-platform product acceptance.

## Next action

After foundation acceptance, refresh the exact guide, harness and caller inputs. Implement the approved PS guide text and portable fixture. Run final Windows and Linux tests, front-matter parsing, instruction validation, outer/nested Markdown and the two complete clean pre-commit passes required by PS175. Complete source reviews/quality/merge, peer transfer and reverse byte comparison. Existing authority is sufficient for this scope; no owner question is pending. Transfers remain0/8 and no review clock has started.
