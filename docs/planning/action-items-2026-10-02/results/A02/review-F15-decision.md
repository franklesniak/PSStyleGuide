<!-- markdownlint-disable MD013 -->
# F15: retain regular Git entry requirements for generated exemptions

Status: selected before product edits; implemented; focused controls and final aggregate pass.

## Validation and stakeholders

Codex5397627845/comment4170495487 identifies head25b17e892f6429cf4df4f39489443d950f5902e8/tree4dba7b2766ba49233e7dd0871188255c0870ae7c. reproduce.ps1/log installs the exact proposed checker in a private accepted B. The actual MetadataClassificationOnly CLI accepts prior-authorized activation in generatedPaths with Git modes120000,160000,100755 and100644. The classifier checks tracked path membership and authority; generated entries deliberately bypass content contexts. The defect is nonregular/executable entry admission, not demonstrated target traversal or secret disclosure. Native first-install exact category mapping remains a distinct control.

Generated artifact consumers and generator maintainers require ordinary source-generated file entries. Both repository maintainers, contributors, local/CI agents and security/independent reviewers need path/category grants to leave type constraints intact. Windows/Linux contributors need exact Git mode semantics independent of physical executable bits. Documentation authors and cost stakeholders need no new generated-content parser, size cap or repeated large reads. No cloud/state/credential operation changes; race confinement is not claimed.

Hard constraints: require exactly one100644 blob with exact ordinal path; refuse symlink/gitlink/tree/executable/unmerged/missing entries, native failure, invalid UTF-8/framing and bounded-output failures. Preserve authority/category rules, all four generated exclusions and raw generated content. Do not decode generated bodies or impose a new body cap. Index checks describe the staged candidate; Git revision checks describe exact H. Neither is an atomic worktree filesystem claim.

## Options, fresh rubric and scores

N leaves/defer the hole. M factors the existing bounded literal NUL entry inspection into an internal mode-only helper, uses it from the content reader and for active generated paths, and supports an exact stage0 index record for local mode. R reads every generated body through the existing bounded UTF-8 content reader. P checks physical filesystem attributes only. L duplicates a line-oriented ls-tree check. A removes generated exemptions. C adds trusted type grants to the manifest schema. E validates types only in artifact-generation CI.

Fresh0–5 rubric: entry safety45; generated semantic fidelity30; maintenance15; cost10. Total=sum(weight*score)/5. Hard constraints override totals.

| Option | Safety45 | Fidelity30 | Maintain15 | Cost10 | Total | Key uncertainty/constraint |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| N | 0 | 4 | 5 | 5 | 49 | Nonregular entries remain admitted |
| M | 5 | 5 | 5 | 4 | 98 | Preserve raw grammar/transport and index stage proofs |
| R | 5 | 1 | 4 | 4 | 71 | Adds unwanted body decoding/caps |
| P | 2 | 3 | 3 | 4 | 53 | Does not inspect exact candidate Git mode |
| L | 2 | 3 | 2 | 4 | 50 | Reintroduces quoted/raw-path ambiguity |
| A | 5 | 0 | 3 | 2 | 58 | Violates generated source semantics |
| C | 3 | 3 | 1 | 1 | 50 | Unnecessary schema/type authorization surface |
| E | 1 | 4 | 4 | 4 | 53 | Current data-only caller still admits unsafe entries |

M is a small reuse of the already verified entry parser, with a narrow index grammar for the existing local caller. It preserves all generated-body exclusions. Scores are judgments, not evidence of implementation.

## Selected instructions and validation

Select M. Extract the existing bounded raw Git tree entry proof into one internal helper that returns the validated blob identity. Keep Read-GitRevisionText content semantics unchanged. For local input, inspect literal NUL stage0 index metadata with the same bounds and exact path comparison. Check every active candidate generated path before the data-only early return. Do not read its body. Do not add physical chmod or follow targets. Preserve prior authorization, category provenance, missing/removed-path semantics and the closed initial mapping.

Exercise actual authorized B/H activation and already-generated mode changes for100644,100755,120000,160000, tree/missing and exact Unicode/literal paths. Test stage0 index success and invalid modes/stages. Prove metadata-only inspection accepts a100644 binary/oversized-content object without body decoding and does not call cat-file. Reuse F12 framing/native exit/overflow/timeout/raw-object controls through the factored reader. Run both data-only and full callers where applicable, then one combined final-byte normal aggregate. No schema, public mode or protected changes. Parent owns actual endpoints/native gates; private installed fixtures do not supply native installation/owner authority. Round8/80 and transfer0/12 remain.

## Validation checkpoint

Implemented within the four authorized code/workflow paths. All focused controls pass; provisional tree0cde16e0dc69df235b98f6e739fa112bf7c1e3eb has no unstaged changes. RESULT.md records exact identities, terminal logs and limits. Provisional code passed independent whole-PR quality. At actual UTC October3, only the two authorized Last Updated lines changed to2026-10-03; code blobs remain unchanged. Final six-path tree7d79b48a15f80fddabb8f062eba8819b0ad7cf6b is frozen. One normal aggregate30624 passed all10 hooks, exit0, start2026-10-03T00:01:05.9074447Z and end2026-10-03T00:40:20.8387851Z. Final readback confirms identical six-path tree/blobs/raw bytes, no unstaged changes and diffcheck0. Product/index ownership is released to the parent for normal commit and exact endpoint/native gates. No native installation/owner/immutable-workflow acceptance is claimed.

Final candidate `9652b46e9442d1fb375277f9a106b2c432877a98`, tree `855b1f44ffeaeee8dedd6825244778f60067e373`, includes the fixture-only correction to the prior F13-F15 repair61f1bec. The exact admission function passes on Windows/Linux with all three modes and both provenance rejection calls retained. One normal replacement aggregate85955 passed all ten hooks at2026-10-03T01:52:06.7758152Z; normal commit completed without bypass. Actual proposed-code B48f/H965 finalization (UTC2026-10-03), classification and full ProposedPolicy checks passed in root76260, ending01:56:36.923231Z. Static Error checks and Warning-only PSScriptAnalyzer1.24.0 checks cover both changed PowerShell files with zero findings at the recorded severities. [Independent whole-PR local quality](F13-F15-quality.md) reconciles the actual commit and final evidence. Normal non-force push and authenticated PR readback confirm965/base48f. New candidate CI, reviews and immediate native gates remain pending; predecessor61f native CI failure is retained as historical evidence.
