<!-- markdownlint-disable MD013 -->
# TF67-R1: remove the unreachable mismatch fallback

The decision below was completed and displayed before the selected edit. Its analysis-only statements describe that checkpoint. The implementation and validation update at the end records the later actual result.

Current TF67 H is `b8d38effaea1a566d7f9c1d5fefc67cc688661ed`, tree `51c405ff8f5d6acebf6fe694f5c2b4007870b6f8`; B is `56cb0418dcdcf71be94acc78d8963ea580b8a9e9`. Accepted PS is `f0684acd81a1a6e53d87e43881c1ec4f1310b17c`. Finding: Copilot review5416368912, comment4185320957, thread `PRRT_kwDOSAZRhc6pFWIC`, `.github/workflows/lint-markdown.mjs`. Manual Codex5996772367 is clean on current H. Root owns public disposition, closure, requests, counters and publication.

## 1. Validation and previous-decision applicability

The reviewer identifies a real, bounded source-clarity improvement. The new type/format guard throws unless `required` is a primitive string in exact major.minor.patch form. The following mismatch branch therefore cannot evaluate a null or undefined `required`. It is a local `const`, and there is no intervening reassignment or awaited operation. `${required ?? 'version'}` always evaluates to the same string as `${required}` at that point. The fallback itself is unreachable; the mismatch branch is reachable.

This is not a runtime, rejection, security, disclosure, status or end-user diagnostic defect. Missing/invalid declarations still produce the fixed package.json/engines.node/exact-version diagnostic before the child runs. Malformed JSON, missing or unsafe manifest paths retain their existing failures. Valid runtime mismatches still include the required and observed versions. An exact runtime continues to execute the bounded outer child. Removing only the fallback cannot change any emitted text or supported result because all inputs reaching it are non-null strings.

The full wrapper and all473 lines of its existing test suite were read. Tests cover real manifest regular/root-alias/leaf-link/broken-link/directory/missing/malformed/wrong-version/size boundaries; actual API and CLI behavior; child containment and execution markers; status/native error propagation; configuration and Markdown behavior; staged inputs and the shell hook. The root records already show successful current-H endpoints, aggregate and ordinary CI. Those results are reused at their actual unchanged-input scope, not represented as new cleanup validation.

The previous [PS232 R7 decision](https://github.com/franklesniak/PSStyleGuide/blob/9d593750a426e39b0ea397cd6971981f1d972383/docs/planning/action-items-2026-10-02/results/A07/PS232-R7-node-diagnostic.md) explicitly retained the now-unneeded fallback to avoid unrelated cleanup. Its S98 option separated declaration errors from valid mismatches; its principal criteria addressed actionable runtime diagnostics and admission preservation. Current TF and accepted PS exactly implement that selected outcome. There is no missed carry-back fix and no uncovered R7 behavioral failure.

The reviewer observation overlaps that known implementation detail, so a canonical no-change reply could honestly cite R7. However, R7 did not separately compare keeping versus removing the redundant expression for source clarity. This record performs that bounded comparison now, without reopening the selected declaration/mismatch behavior. The selected improvement is optional in severity but useful on its own merits; a reviewer suggestion does not automatically compel a fix.

Native attribution is separate from product merit. Copilot reported Lite after its agentic-start timeout. The later root snapshot14:55 records service37325315114 as terminal cancelled; that cancellation does not invalidate the authenticated Lite review or create a second finding. Manual Codex remains clean on H. Root reports all11 ordinary workflows successful, actual515tests/515pass/0fail/0skip on both push/PR, all11 setup hooks on both and final guards. No fresh native request or terminal inference is made by this writer.

## 2. Relevant stakeholders and outcomes

- Maintainers and experienced engineers need source code that states the actual invariant without a redundant alternative. They also need to avoid reopening the validated R7 behavior.
- New contributors and reviewers need to understand that the earlier guard guarantees a string. A fallback beside that guard can suggest that missing declarations still reach the mismatch error; this is a source-reading issue, not an incorrect message seen by users.
- Users and documentation/UX owners need the current actionable declaration diagnostic and required/observed mismatch text preserved. This finding supplies no evidence that either message needs new wording.
- QA and CI/DevOps owners need proof proportional to a behavior-preserving expression change, unchanged filesystem/runtime/child/status contracts, and no new exact-prose or implementation-mirroring repository test.
- Security, supply-chain, privacy and audit owners need admission and diagnostic bounds preserved. All eligible preservation options retain the same security behavior; no security score treats this expression as a vulnerability or credits removal with a security repair.
- Both repository owners and convergence reviewers need full-file raw comparison, not region or normalized equality. The wrapper is currently raw-identical across accepted PS and TF67 H; a TF-only edit requires a later real PS carry-back.
- Project/business owners need proportionate review and delivery cost. An existing later PS A21 transfer can carry the one A07 expression too if independently accepted and released, but scheduling convenience cannot determine correctness or authorize a transfer.

Accessibility, localization and generated-artifact consumers have no new output or interface requirement here. Platform-specific runtime acquisition, cloud configuration, guide policy and package/dependency behavior are unchanged. No distinct concern from these groups changes the decision.

## 3. Options before scoring

| ID | Material option | Benefit and residual |
| --- | --- | --- |
| K | Keep the current expression; cite the canonical R7 selection and close this nonmaterial suggestion with evidence | Valid runtime behavior and present pair equality; retains the redundant source alternative. No deferred work is implied. |
| R | Replace only `${required ?? 'version'}` with `${required}` | States the proved invariant directly; every observable message and behavior stays identical. Creates one narrow shared-byte difference until PS carry-back. |
| C | Keep the fallback and add a local comment explaining that the guard makes it unreachable | Explains the invariant to readers while retaining redundancy and another statement to maintain. Also creates a peer difference and needs the same later transfer. |
| F | Remove the fallback and factor this one error formatter into a local helper | Can isolate formatting, but introduces an extra definition/call and indirection for one use. No demonstrated reuse or broader formatting contract exists. |
| M | Remove the fallback and revise the mismatch wording to name root package.json/engines.node | Could add source-location text, but current valid mismatch guidance already meets R7. Changes user-visible text without a demonstrated missing outcome. Fails this finding's output-preservation gate. |
| D | Keep the expression now and track its removal as future deferred work | Preserves present bytes but adds a future obligation/Issue for a change that can be completed now or deliberately retained. Offers no separate functional benefit. |

R plus variable renaming, comments, new tests or broader shared-validator extraction is not a distinct necessary solution. Renaming `required` adds no new invariant or demonstrated ambiguity in its existing local context; it is an unrelated modifier of R. Comments are already represented by C, factoring by F, and wording changes by M. A new assertion for a condition the existing guard already guarantees would duplicate admission; an exact-expression/prose snapshot would mirror implementation. Neither supplies a missing test outcome. Sharing the broader NpmTools validator changes npm/install coupling and exceeds this single diagnostic-expression concern. Automatic observed-version fallback, permissive ranges, removal of the guard or a generic catch that hides parse/filesystem errors fail the existing admission/diagnostic contracts and are ineligible. Deferral cannot be selected merely to avoid worker scope or runtime cost.

## 4. Fresh finding-specific rubric

Scores are0–5:0 fails the criterion,1 has a major gap,2 is partial,3 is adequate with an explicit residual,4 is strong,5 fully serves this bounded outcome. Weighted total is sum(weight × score /5). Scores compare proposed properties and source inspection, not empirical performance or a security finding.

Hard gates: retain every manifest type/size/containment and exact-runtime guard; preserve rejection before child execution, child bounds and0/1/2 mapping; preserve byte-identical declaration and valid-mismatch diagnostics for all supported inputs; introduce no dependency, interface, guide-policy or test-framework change; retain real paired-convergence obligations. A high score cannot waive a gate. The byte-identical-message gate fits this expression-only finding, whose own validation proves no output gap. A separately validated wording defect could establish a different task; none is present here.

| Criterion | Weight | Concrete meaning |
| --- | ---: | --- |
| Runtime and contract preservation | 32 | Preserve the validated declaration/mismatch distinction, rejection order, child execution, result mapping and interfaces. |
| Observable diagnostic usability | 24 | Keep the current actionable messages and native failure causes; provide a new user-facing change only when a demonstrated gap warrants it. |
| Security and diagnostic bounds | 20 | Preserve filesystem/runtime admission and safe error-content bounds. Eligible equivalent options receive equal safety credit. |
| Source invariant clarity | 18 | Source directly communicates the guaranteed string without unnecessary alternative states or single-use indirection. |
| Paired convergence readiness | 4 | Preserve or make a narrow, exact, well-defined peer repair rather than concealing a shared-byte delta. |
| Ongoing upkeep | 1 | Avoid redundant statements, new helpers or future work tracking without a separate consumer. |
| Delivery effort | 1 | Permit a proportional implementation and existing focused checks. |

Preservation, observable usability and security carry76% of the weight; upkeep and effort only2%. Source clarity is the actual incremental benefit. Current pair equality is acknowledged, but the4% convergence criterion cannot erase a useful shared repair merely because it needs a peer transfer.

## 5. Scores, arithmetic and selection

| Option | Preserve32 | Usability24 | Safety20 | Clarity18 | Pair4 | Upkeep1 | Effort1 | Weighted total | Eligibility |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| K | 5 | 5 | 5 | 3 | 5 | 4 | 5 | 92.6 | Eligible |
| R | 5 | 5 | 5 | 5 | 4 | 5 | 4 | 99.0 | Eligible |
| C | 5 | 5 | 5 | 4 | 4 | 3 | 4 | 95.0 | Eligible |
| F | 5 | 5 | 5 | 4 | 3 | 2 | 2 | 93.6 | Eligible |
| M | 5 | 5 | 5 | 5 | 3 | 4 | 3 | 97.8 | Fails output-preservation gate |
| D | 5 | 5 | 5 | 3 | 5 | 1 | 3 | 91.6 | Eligible in principle; unearned deferral |

R is the unique eligible winner at99.0. Example arithmetic: R =32+24+20+18+3.2+1+0.8. K =32+24+20+10.8+4+0.8+1. C =32+24+20+14.4+3.2+0.6+0.8. F =32+24+20+14.4+2.4+0.4+0.4. M =32+24+20+18+2.4+0.8+0.6. D =32+24+20+10.8+4+0.2+0.6. Totals are checked against the fixed rubric.

K is correct and fully safe, not dismissed as an unfixed runtime bug. Its3 clarity score reflects one explicit redundant state in otherwise adequate code. R removes that state directly. C deserves4: a comment helps explain the invariant, but keeps the confusing alternative and an extra explanation; it cannot offer R's direct source expression. F is capable of preserving behavior and is not penalized as insecure; its4 clarity score reflects one-use indirection, with a broader peer patch and extra helper upkeep. M has no demonstrated end-user improvement beyond current adequate messages and fails a stated hard gate. D is a real option, but neither current performance nor an external prerequisite earns future work tracking.

The deciding factual distinction is the guaranteed primitive-string invariant and its simplest direct expression. There is no tied technical or owner-preference question needing escalation. The benefit is modest maintainability, not a severity upgrade, review-count goal or fabricated security advantage. The new decision changes only the earlier choice to leave this redundant implementation detail in place; all selected R7 functional outcomes remain fixed.

## 6. Controlled-English selected implementation recommendation

1. Wait for root to release this implementation.
2. Confirm the current TF head, base and full-file preimage.
3. Replace `${required ?? 'version'}` with `${required}` in the valid-runtime mismatch message.
4. Keep every other byte in `lint-markdown.mjs` unchanged.
5. Keep all existing tests and documentation unchanged.
6. Check that the same valid mismatch produces the same required and observed versions.
7. Run the existing focused manifest-boundary tests on the new file.
8. Report the exact new file hash and unchanged-file guards to root.
9. Let root publish, review and accept the changed candidate.
10. After TF acceptance, compare the full wrapper with current accepted PS.
11. If that exact common difference remains, let root release a PS A07 carry-back.

These are short controlled-English implementation instructions. No formal ASD-STE100 dictionary certification is claimed.

## 7. Minimal implementation, validation and pair plan

Exact proposed product scope is `.github/workflows/lint-markdown.mjs` only. It is JavaScript and has no governed document or PowerShell Version metadata. No helper, formatter, test, dependency, README, generated artifact, instruction file or settings change is selected. No style-guide update is needed: this is a local redundancy exposed by R7's existing guard, not a missing guide contract. No new Issue is required because no deferral is selected.

Current mode100644,3231 bytes, SHA256 `2936daa02f279b8701c9671e3ec610729e3fd09feb9235c26f763e0df65139bf`. The in-memory exact single substitution models mode100644,3218 bytes, SHA256 `ccd5ba35d181af52734d2d372eaa3af5a6c75a771f7eb7a721dc43c21b30aa68`. No product postimage or test code was written. Root must recheck actual input before release; changed pins invalidate this model.

After release, use qualified Node24.18.1 and the unchanged locked dependencies. Run `node --check .github/workflows/lint-markdown.mjs` and the existing named `actual root manifest execution boundary` cases from `lint-markdown.test.mjs`. Their real API/CLI failure and benign-child controls cover the affected guard/mismatch path. No new repository test, exact-message snapshot, broader suite replay, full aggregate, install or mutation SelfTest is justified solely by this expression cleanup. A raw single-substitution reversal and whole-file comparison prove all other source bytes and the supported-message expression are preserved. Root owns whatever new-input acceptance checks and independent review the lifecycle requires; old-H clean reviews do not certify changed bytes.

The complete wrapper currently equals accepted PS raw bytes and mode. The six-path raw catalog shows exactly three raw-equal files: classifier, local-validation suite and wrapper. The other three paths retain their unchanged, previously proved two Version-field, T1 provenance and README language/caller/check differences; their full hashes match the already inspected frozen repair, so those decisions are reused at unchanged scope. The proposed edit introduces precisely one additional shared expression delta. Do not call the pair converged until both accepted wrappers match again.

A TF review repair on this existing PR is a same-repository change and does not consume another directional transfer. After actual TF acceptance, a real PS A07 transfer4 may carry this expression alongside the independently required A21 two-note PS transfer4 if root validates and releases both. Each owner retains its own count/history. No counter is incremented now, no PS edit is released here, and no accepted input or same-day metadata tuple is invented. Later dates or changed inputs require their own refresh. Full A07/A21 outcomes and all402 contracts remain open under the existing plan.

Evidence: `evidence.json` contains actual review/comment attribution from root's complete snapshots, prior R7/full-test hashes, full six-path raw modes/hashes, model identities, original and later Copilot service states, root's prior validation references, and matching before/after tracked-byte/HEAD/index/stage0 guards. The analysis ran only read-only Git/source inspection plus private report construction. It ran no target script, test or aggregate and made no native action.

Public source references inspected through pinned local Git/source bytes: [current TF wrapper](https://github.com/franklesniak/TerraformStyleGuide/blob/b8d38effaea1a566d7f9c1d5fefc67cc688661ed/.github/workflows/lint-markdown.mjs), [complete current TF tests](https://github.com/franklesniak/TerraformStyleGuide/blob/b8d38effaea1a566d7f9c1d5fefc67cc688661ed/.github/workflows/lint-markdown.test.mjs), [accepted PS wrapper](https://github.com/franklesniak/PSStyleGuide/blob/f0684acd81a1a6e53d87e43881c1ec4f1310b17c/.github/workflows/lint-markdown.mjs), [native finding](https://github.com/franklesniak/TerraformStyleGuide/pull/67#discussion_r4185320957). No external research was needed to establish this local data-flow fact.

## 8. Implemented and locally validated

Root read the full decision, checked the totals and displayed the options, rubric, scores and selected action before release. Normal commit `443b2fe3cbeda18402f0432e5c95379d09096d6a` has parent `b8d38effaea1a566d7f9c1d5fefc67cc688661ed` and tree `89f470ceb6b3e6e9d4ae757e38997f1c6e7bd631`. Its only repair path is `.github/workflows/lint-markdown.mjs`; the whole PR retains its six-path scope. The exact3218-byte file has SHA256 `ccd5ba35d181af52734d2d372eaa3af5a6c75a771f7eb7a721dc43c21b30aa68`. Reversing the one substitution reconstructs the exact prior file. Every other tracked byte and mode is unchanged.

Windows Node24.18.1 syntax validation passed. `node --test --test-name-pattern="^actual root manifest execution boundary:" .github/workflows/lint-markdown.test.mjs` passed all11 selected tests with zero failures, cancellations or skips. Ten private before/after cases made20 actual API calls and proved identical error text, error codes, statuses and child execution. They cover missing file/engines/node, null, empty, range, array, malformed JSON, valid mismatch and exact runtime. The exact-runtime controls execute the child; rejected inputs do not. No repository test was added.

One final isolated Linux `python -m pre_commit run --all-files` passed all11 hooks with zero skips, including the instruction mutation suite. Runtime: Node24.18.1/npm11.16.0/Python3.12.3/PowerShell7.6.3; network disabled for the aggregate. The78 source files and1910 dependency files remained unchanged. Normal commit hooks, actual accepted-base classification, author-date finalization, metadata classification, proposed-policy diagnostics and the fresh ordinary two-root audit passed. These gates bind the actual repair commit and accepted base.

The [current candidate record](TF-carryback-candidate.json) preserves actual commands, log identities and limitations. The worker report SHA256 is `8e020ed7b57cc2b2868a62f35d2180fbb70c579b1ca99b99e190ebbfaa480cea` and its evidence SHA256 is `ab803d51364dceee7386724ed1cb97e0b86f90e27a20413d7d168493d19ea335`. These records support local readiness. New-input native reviews, hosted validation, independent final quality, merge and landed validation remain required. Old-H clean Codex and515-test CI results are retained as history and do not certify this changed input. No transfer counter advanced for this same-repository repair.
