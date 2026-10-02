<!-- markdownlint-disable MD013 -->
# F12: inspect revision entries as bounded raw Git records

Status: selected before product edits; implemented; focused validation passes; final aggregate pending.

## Validation and stakeholders

Codex5397018839/comment4169978573 reports exact headb9c2d0ea4c04894a6ea3267e9daa662f27b5820b. reproduce.ps1/log creates a harmless private100644 docs/café.md: the actual bounded NUL inventory includes its exact path, then Read-GitRevisionText rejects the same valid blob because line-oriented ls-tree C-quotes its name. The current reader then compares the quoted display name to the raw requested path. The downstream caller requires this reader for newly discovered governed documents and prior content. This is a supported false rejection, not evidence of a new naming restriction or a real repository mutation.

Input validator blobb8ec6e9d8c088245cd9271a53c2572204f1cea72 and SelfTest9d99b2beabc448930f66b68ee0d37d7a49aadb2d are100644. [Git ls-tree documentation](https://git-scm.com/docs/git-ls-tree) specifies mode/type/object/tab/path output and that -z emits verbatim names with NUL termination. [Git's literal-pathspecs option](https://git-scm.com/docs/git#Documentation/git.txt---literal-pathspecs) disables glob and pathspec-magic interpretation. These native formats avoid a custom C-unescaping implementation.

Relevant stakeholders include authors using non-ASCII filenames, Windows/Linux contributors, repository maintainers, CI/platform operators, local/remote agents, reviewers and supply-chain/security custodians depending on exact immutable input, type/mode and bounded reads. Accessibility/localization users must not lose valid named documents. No credential/cloud/state/privacy workflow changes are involved.

Hard constraints: exactly one100644 blob, original ordinal path,40/64-hex object identity, strict UTF-8, native exit checking, output/time bounds, unchanged content cap and input authority. Do not accept100755/symlink/tree/gitlink, case-fold or normalize paths, weaken missing-object errors, globally change Git configuration, or introduce an ASCII naming ban. Preserve non-RequireRegularFile behavior and F1–F11 boundaries.

## Options and fresh rubric

N: no change/defer. Z: use shell-free literal-path ls-tree -z/full-tree through existing bounded transport, parse exactly one raw mode/type/object/path record, then read its inspected blob. Q: disable core.quotePath for the command. U: implement Git C-unescaping. C: remove mode inspection and only cat-file. A: reject non-ASCII filenames. T: enumerate and parse the complete tree for every file. P: add a Node/Python/external tree parser. R: check out each revision and inspect filesystem state. Shared existing bounded process/strict decoding plus one local record grammar is Z; no new framework or public helper is required.

Fresh0–5 rubric: exact supported-path correctness40; bounded/type/authority safety30; maintainability20; cost10. Total=sum(weight*score)/5. Scores cannot waive constraints.

| Option | Correctness40 | Safety30 | Maintenance20 | Cost10 | Total | Key uncertainty or constraint |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| N | 0 | 3 | 5 | 5 | 48 | Confirmed valid path remains rejected |
| Z | 5 | 5 | 5 | 4 | 98 | Exact raw record and failure controls must be tested |
| Q | 2 | 2 | 4 | 5 | 54 | Does not remove all quoting/framing or unbounded inspection |
| U | 4 | 3 | 1 | 2 | 58 | Adds a bespoke escaping parser |
| C | 5 | 0 | 5 | 5 | 70 | Loses required mode/type authority |
| A | 0 | 4 | 3 | 4 | 44 | Invents unsupported naming policy |
| T | 5 | 5 | 3 | 2 | 86 | Repeated full inventory increases cost/limits unnecessarily |
| P | 5 | 4 | 2 | 2 | 76 | Adds transport/runtime/schema coupling |
| R | 4 | 1 | 1 | 1 | 44 | Adds mutable filesystem/filter/checkout exposure |

Z is the smallest sufficient native representation with existing transport. Q does not solve control-character quoting or exact record framing; T/P/R add no useful current capability. The mode-free and naming-ban alternatives violate constraints.

## Selection and verification

Select Z. In RequireRegularFile mode, invoke git with literal pathspecs, ls-tree -z --full-tree and separate arguments. Use the existing bounded process reader with its10000ms timeout. Bound tree output by the requested UTF-8 path byte count plus78 bytes: six mode digits, separators, blob token, maximum64-digit object ID, tab and final NUL. Guard numeric overflow. Decode strictly and accept exactly one fully anchored100644 blob record with40/64 hex object ID, one path and terminal NUL. Compare its path with Ordinal equality. Refuse empty, multiple, malformed, wrong-mode/type/path or failed-native output. Read the inspected immutable blob ID with the unchanged bounded cat-file transport and strict content decoding. Keep the existing revision:path content route when regular-file inspection was not requested.

Change only validator/SelfTest. Validate native café, spaces and literal metacharacter names without changing source configuration; preserve exact case/Unicode identity. Test100644 content success, missing path/revision,100755, symlink/tree/gitlink refusal, invalid UTF-8/content cap, and controlled raw record framing/count/path/type/object mutations. Existing bounded transport timeout/overflow/reaping tests remain applicable; targeted tree-transport controls must confirm nonzero/oversized/timeout refusal without another general framework. Use a real B/H caller for valid newly discovered café metadata and malformed content rejection. No hostile filesystem race guarantee is added.

Run affected focused checks, then one combined final-byte normal pre-commit for F11/F12. Preserve unchanged evidence and honest Windows/Git/platform limits. Parent owns native publication/quality; round7/80, original deadline, transfer0/12 and A07 freeze remain.

## Validation checkpoint

Focused74098 exited0. focused.log records the actual metadata field/context checks, native Git path/mode/type/content controls, controlled raw-record/native-exit/overflow/timeout checks through the real bounded transport, and actual current/prior B/H metadata plus valid/invalid Unicode-document callers. Static analyzer Error scans and diffcheck pass. One fixture-only empty-array enumeration correction is documented in fixture-note.md and its preserved initial log; production semantics did not change for it.

Final candidate tree4dba7b2766ba49233e7dd0871188255c0870ae7c onb9c2d0ea4c04894a6ea3267e9daa662f27b5820b changes only validator/SelfTest100644, with no unstaged changes. One normal full pre-commit95367 started2026-10-02T21:50:51.9246761Z under Node24.18.1/npm11.16.0; terminal acceptance is pending. RESULT.md holds the exact blobs/raw hashes and handoff boundary.
