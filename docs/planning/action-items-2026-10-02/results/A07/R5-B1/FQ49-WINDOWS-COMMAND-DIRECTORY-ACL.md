<!-- markdownlint-disable MD013 -->
# FQ49: Check the Windows command directory's write authority

Selected decision, before implementation. Independent combined-source review found this gap in the first FQ46/FQ47/FQ48 candidate, manifest1f4b94afe1b6d6443ce4579c1f2720330f1f17032de8bd131d8c65b4b92f943f, staged tree830937ae366b5a23da1dea67cb33ddd30ee3a303. Initializer SHA75bde4fbdc06f10b4b961dedb27751999af842ac887b82ed5116796af9ccfe3b. This is a local review finding, not another remote review round.

## Validate the finding

The gap is real. Root inspected the complete Assert-WindowsWriter function and admission block (2b0800). The command directory is an ordinary direct child of RUNNER_TEMP. The Windows ancestor loop at1472 starts at RUNNER_TEMP. Calls1475/1476 check the two files. Assert-WindowsWriter checks only its supplied object; it does not recurse. Consequently the immediate command directory is never checked for its owner or untrusted mutation grants.

The README's existing Windows parent-chain contract and the retained trusted-writer policy apply to this folder. Directory identity and single-link file checks do not establish its permissions. A child's security descriptor does not prove the parent's security descriptor. Windows models files and directories as separate securable objects and supports both effective and inherit-only access entries. [Microsoft file security](https://learn.microsoft.com/en-us/windows/win32/fileio/file-security-and-access-rights). Directory deletion and permission-change rights are relevant to this policy. [FileSystemRights](https://learn.microsoft.com/en-us/dotnet/api/system.security.accesscontrol.filesystemrights?view=net-10.0).

This is source proof of an omitted policy check. No exploit, disclosure, or successful hostile concurrent write was observed. Existing held streams and identity checks remain useful. The selected trusted-host/account model does not become a guarantee against administrators or hostile code using the same account. FQ46 preserved the old ACL calls but did not explicitly adjudicate this newly constrained child directory. This record closes that specific omission without replacing FQ46's directory/identity/link-count design.

## Stakeholders and options

Security engineers and auditors need complete admission of every relevant object. Windows and DevOps operators need the supported trusted-owner and directory-create exceptions preserved. New developers and documentation/UX owners need one understandable permission error and a path to correction. QA needs a fixture in which only the omitted parent is unsafe, plus a causal control. Maintainers and business owners need a bounded repair using the existing policy. Cost has less weight than correctness and legitimate use. Host permission changes are outside this implementation's authority.

| Option | Approach | Consequence |
| --- | --- | --- |
| A | Keep the code, document or defer the gap. | Leaves the confirmed admission omission. |
| B | Extend the existing trusted-writer walk to include the command directory. | Applies the existing rule once to the missing object and retains the current ancestors and file checks. |
| C | Walk each channel file's complete ancestor chain separately. | Covers the directory but duplicates shared ancestors and adds failure paths. |
| D | Check the command directory only at publication. | Allows credential/capability/staging work before the missing refusal. |
| E | Check at admission and again before publication. | Covers the gap, but adds a second sample without a distinct guarantee against actors outside the accepted model. |
| F | Replace permission admission with a native directory-handle design. | Requires new platform binding and ownership semantics for a larger threat model. |
| G | Disable Windows support. | Avoids the affected path but removes required legitimate behavior. |
| H | Rewrite permissions or recreate the supplied directory. | Mutates caller/runner state and needs authority beyond the current product repair. |

Starting the existing loop at the command directory and making one explicit call immediately before the old loop are equivalent implementations of B. B uses the former to keep one continuous ancestor walk. Combining an admission repair with publication sampling is E; publication-only is D. A generic reusable ancestor helper or separate per-file walks falls under C unless it also changes native access semantics, which is F. Copying channel data through a new temporary folder does not establish the final supplied parent's permissions and does not resolve the finding. Removing the permission contract or deferring the repair is A, not a secure completion.

## Finding-specific rubric

Scores use0–5:0 fails,1 leaves a major gap,2 is partial,3 needs substantial extra conditions,4 has a bounded limitation,5 directly meets this finding's criterion. Total is the sum of weight times score divided by5. These are design judgments, not probabilities. Hard authority and supported-behavior requirements cannot be waived by a score.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Boundary completeness | 31 | Includes command-directory owner and mutation rights before write-open, while retaining ordinary-path, identity, file and ancestor checks. |
| Supported Windows behavior | 23 | Preserves trusted principals, valid runner/offline layouts and current directory-creation exceptions. |
| Causal test coverage | 19 | Supports an isolated unsafe-parent negative, valid-parent positive, exact early-phase oracle and a one-change inverse control. |
| Diagnostic clarity | 15 | Uses the existing policy and one clear unsafe-path refusal, without silently changing user settings. |
| Operational failure surface | 8 | Avoids redundant native queries, new privilege requirements and unnecessary cleanup or recovery paths. |
| Implementation cost | 4 | Limits code and test maintenance while preserving all required behavior. |

## Scores

| Option | Complete31 | Usable23 | Testable19 | Clear15 | Reliable8 | Cost4 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 0 | 2 | 1 | 1 | 4 | 5 | 26.4 |
| B | 5 | 5 | 5 | 5 | 5 | 5 | 100.0 |
| C | 5 | 5 | 4 | 4 | 3 | 3 | 88.4 |
| D | 2 | 3 | 3 | 3 | 4 | 4 | 56.2 |
| E | 5 | 5 | 4 | 4 | 4 | 3 | 90.0 |
| F | 5 | 3 | 3 | 2 | 2 | 1 | 66.2 |
| G | 2 | 0 | 4 | 2 | 4 | 4 | 43.2 |
| H | 3 | 2 | 2 | 2 | 2 | 1 | 45.4 |

B is the clear winner. C and E can cover the missing object, but add duplicate checks and additional phase-specific test obligations. F adds an unnecessary native design. D checks too late. A, G and H fail retained requirements or authority. No owner preference is needed.

## Selected instructions and validation

1. Start the existing Windows permission walk at the command directory.
2. Check that directory, RUNNER_TEMP, and each parent.
3. Keep the separate checks for both channel files.
4. Keep the existing trusted principals and rights rules.
5. Stop before channel write-open when a check fails.
6. Do not change supplied permissions or create a replacement directory.
7. Add a Windows test with unsafe permissions only on the command directory.
8. Keep both channel files and other ancestors trusted in that test.
9. Require refusal before credential work, channel writes, or runtime staging.
10. Remove only the added directory coverage in a test copy.
11. Require that same unsafe fixture to reach the next controlled boundary.
12. Test a valid directory and the retained directory-creation exception.
13. Test representative owner and effective mutation-right refusals.
14. Verify private fixture cleanup and unchanged channel bytes.

These instructions use short controlled-English steps under the owner's ASD-STE100 direction; no formal dictionary certification is claimed. Use the existing private Windows test controls. Change permissions only on newly owned test fixtures, never on the host runtime, supplied runner directories, or real account settings. A complete initializer prefix or actual Windows branch seam must prove the added call is reached; testing Assert-WindowsWriter alone is insufficient.

No repair test has run yet. Root displayed the options, new rubric, full scoring table and selected instructions before releasing the edit. Preserve the original frozen packet and native UID evidence. Reconcile affected source/test inputs after the repair. Review round5/80, original deadline2026-10-16T22:53:27.970214Z and A07transfers9/12 remain unchanged.
