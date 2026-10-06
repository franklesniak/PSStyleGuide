<!-- markdownlint-disable MD013 -->
# B99 repair-v1 provisional review

**One residual P2 concern remains within the existing P1 active-membership finding.** The new inventory guard is correctly placed and source inspection found no separate material issue in it or the added fixture flow. This is not an acceptance of either original finding: candidate runtime qualification and actual accepted-main integration remain unexecuted.

## Residual P1: YAML line breaks can hide a quoted opener

`Get-AgentPreCommitHookContext` at frozen `Test-AgentInstructions.ps1:622` normalizes CRLF and splits only on LF. Lines638–643 then discard an entire LF-delimited segment that begins with spaces and `#`. Bare CR(U+000D), NEL(U+0085), LS(U+2028) and PS(U+2029) are not split or rejected. Native YAML treats each as a line break, ending the comment. A quoted field opener after that break is therefore executable configuration syntax to YAML but invisible to this finite reader.

The exact construction is the known-prior-field variant already included in SelfTest, with the opener hidden behind a comment and a non-LF break:

1. Remove the existing `name: workflow policy contract` line from the preceding hook.
2. Immediately before the unchanged `agent-instruction-contract` block, insert the following escaped representation (eight spaces precede each field/comment): `# comment<SEP>        name: "\n`.
3. Keep the whole original agent hook block unchanged. Append `#"\n` after it.
4. Replace `<SEP>` with one actual CR, NEL, LS or PS character. `\n` above denotes the normal LF bytes, not a backslash in the YAML.

The finite reader ignores the opener segment as a comment, recognizes the apparent agent ID as hook11, and ignores the comment-looking closing quote. It neither requires the preceding workflow-policy hook's name nor detects the hidden opener. The exact seven-line agent body still compares equal at937–945. The parallel root-line regex at860–861 also does not expose syntax hidden after one of these characters. Native YAML instead places the apparent agent block inside the prior hook's quoted name; the actual guard is absent.

Root independently reproduced all four native data cases in `feedback-yaml-linebreaks/result.json` at22:14:06Z using Python3.12.10/pre-commit4.6.2. Each configuration passes native schema, has10 actual hooks, and retains the guard only as text in the prior name. I verified the receipt's original config SHA256 against exact B981 and all four fixture-file hashes. These are **native data-loader results supplied by root**, not execution of the repaired candidate or hooks. My conclusion that the finite admission misses the construction comes from source tracing; I did not run it.

The primary source corroborates the mismatch: pre-commit `yaml.py:8–10` selects a safe YAML loader; PyYAML `scanner.py:778–781` ends comments at CR/LF/NEL/LS/PS, and1424–1434 treats them as line breaks. `reader.py:137` admits the characters. The existing safe input path does not remove this gap: `Read-AgentSetupInputContent:372` returns the bounded local bytes through `ConvertFrom-StrictUtf8Data`, or `Read-GitRevisionText:2176` decodes bounded Git blob bytes through the same helper. `ConvertFrom-StrictUtf8Data:1053` rejects BOM and invalid UTF-8 only. Regular-file, path, size and staged-equality admission do not reject these valid Unicode characters or normalize their line boundaries.

Root should reconcile these four line forms within the already selected P1 finite grammar before claiming active-membership proof. Add meaningful controls for the exact hidden-opener cases and qualify finite/native interpretation at the chosen boundary. This does not require a new parser framework or a new finding rubric. No repair is selected or released by this report. The earlier quoted/flow/tag/alias and literal-comment repairs remain useful, but their current tests use normal LF boundaries and do not cover this gap.

## Other source findings and preservation

The finite reader now recognizes exactly the canonical root, three groups, one hooks sequence per group and eleven unique IDs in their assigned groups. It rejects the earlier repository-level scalar and ordinary quoted/flow/tag/alias openers, including a moved known name field. It retains indented literal `#` data in block content for exact guard comparison instead of discarding it as an outside comment. Aside from the line-break mismatch above, I found no additional concrete active-membership defect in the inspected state machine. This is a bounded source conclusion, not general YAML equivalence proof.

`.pre-commit-config.yaml` is raw-identical to B981: all eleven original hook definitions and pins remain unchanged. The ignored-artifact rules remain an exact append. The finite reader's new restrictions are deliberately narrower than arbitrary valid YAML; final native-parser parity and normal comment/blank-line positives remain required for contributor usability.

The sole name predicate at771–809 uses the selected exact case-insensitive pattern over the supplied complete target inventory. Main calls it at7966 immediately after `Read-GitTrackedPath`, before classification data/exemptions and the8075 metadata-only return. It does not scan historical B, a changed-only list, filesystem tags/existence, ignore rules or generated/metadata exemptions. The existing local `ls-files --cached -z` versus exact-revision `ls-tree -r -z --name-only` selection and strict decoding/bounds remain unchanged. Endpoint/checkout authorization still precedes this call. No candidate policy is reclassified as accepted-B authority.

SelfTest's new CLI cases create and verify exact100644/100755/120000/160000 index/revision entries while payloads are absent, then require the actual main diagnostic locally and for H. The converse B-with-match/H-clean case and unstaged-deletion case target wrong-inventory and filesystem-dependence mistakes. Predicate tests assert explicit offending paths and near matches rather than reproducing the regex as an oracle. Existing required/staged/immutable/missing/size `.gitignore` tests remain. Source inspection found no separate definite fixture defect. Main-call/case/suffix/cache mutants, present/dangling/sparse states, exemption attempts and workflow invocation are still explicit final execution obligations; these source additions are not passed tests.

I verified every77-file current source hash; all73 paths outside the four-path allowance match B981 bytes. The restored config is additionally unchanged. Only the three reported paths are unstaged modifications. All accepted-base index mode/blob rows and the saved raw index hash match; HEAD, branch and base tree remain pinned. The four frozen sources equal worktree bytes and their declared base hashes match Git blobs. All14 key handoff references plus handoff/patch/release snapshot hashes verify. The six declared read/decoder helpers and strict UTF-8 helper are raw-identical to B981.

## Status and limits

The result is **provisional source review with one residual same-P1 finding**. P2's revised complete-inventory implementation has no further material source finding from this review, but is not qualified or accepted. Frozen repair-v1 evidence remains intact; no historical result is relabeled.

Root retains all repair/test/integration/native release authority. Genuine PS235 acceptance and semantic integration onto actual accepted main remain required before final-input validation, preserving optional-input/security/parser/metadata changes. Final metadata, source/index/dependency binding, meaningful Windows/Linux qualification, one eleven-pass aggregate, actual B/H modes, current audit, independent final quality, reviews, CI and paired/service acceptance remain open. The accepted Copilot recovery request does not itself satisfy those gates. No native state was polled.

Only this REPORT and evidence.json were written. No candidate, parser, import, test, hook, dependency, Git/native/planning/state mutation or descendant occurred.
