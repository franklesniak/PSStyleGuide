<!-- markdownlint-disable MD013 -->
# TF68 runtime repair: implementation and measured validation

The selected [C refinement](../pair/IMPLEMENTATION-DESIGN.md) and [ownership correction](../pair/ROOT-OWNERSHIP-CORRECTION.json) are implemented in two frozen files. Independent source review found no material defect. Focused Windows and Linux checks pass. One controlled comparison shows an observed 8.03% elapsed reduction with identical output and all 59 native parser checks retained. Final aggregate, commit, exact-input remote review, hosted acceptance, landing and paired convergence remain unfinished.

| Binding | Value |
| --- | --- |
| Source parent | `5ec4bdc06431de05e93067b0e52f0dfbb1631392` |
| Accepted Terraform base | `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce` |
| Frozen candidate tree, not a commit | `cf9416f8137c0cb24c00dc0554e7929b72fd0634` |
| Validator SHA256 | `9ca8f6ab530f4e1f30a9745d38a4f70d94d48016565e568d15b4a02b4b85b011` |
| SelfTest SHA256 | `bc758e553ef32a82204aefb238ce4f95a1a3fd0c69de74fa337076077acb2c31` |
| Product status | Exactly two unstaged paths; index remains published tree441d84c |

## Change and safety boundary

The native parser and its runtime checks execute for every call. An explicit document owner can reuse validated structural data only after exact normalized text, line count, fresh raw JSON and parser/decoder/copier identity checks. Each result is a deep copy. All policy decisions still run. The main invocation retains at most eight bounded snapshots. Oversize input and a full budget use the normal fresh path. String payload, records and array elements have explicit bounds; these are not an exact CLR heap limit. Direct required-Version calls do not retain unused snapshots. LastUpdated owns local slots only for its real nested repeated calls, or borrows the caller's slots. Cleanup covers partial allocation and preserves the primary error.

## Executed validation

Windows PowerShell7.6.5 focused attempt7 passed in28.047seconds. Linux PowerShell7.6.3 passed the same final-byte focused driver in11.493seconds. Both ran persistent freshness, mutation isolation, retention limit and ownership controls plus the existing optional-metadata regressions. The final parser and PSScriptAnalyzer1.24.0 checks found zero diagnostics. Four private mutants were detected: skipped fresh parser, shared mutable result, ignored decoder replacement and a ninth retained snapshot. Source hashes remained unchanged.

| Same author-finalization case | Original | Changed |
| --- | ---: | ---: |
| Elapsed seconds | 13.564239 | 12.475015 |
| Native parser calls | 59 | 59 |
| Structural decoder calls | 59 | 51 |
| Native parser seconds | 2.826578 | 2.739442 |
| Structural decoder seconds | 6.230417 | 5.169265 |
| Copy calls / seconds | 0 / 0 | 33 / 0.496878 |

The run finished2026-10-06T09:57:59.587352Z with native/container exit0. The original and changed children used identical complete commands, working directory, actual fixture B/H, clock and expected output. Raw stdout matched. Both non-marker stderr streams were empty. Root reconstructed all522events/261complete intervals, verified29result artifacts and15payloads, and checked complete host/private identity equality for80source files,1914dependency files, indexes, refs and configuration. The real fixture and clock functions were unchanged. No source Git mutation occurred.

This is one sequential, instrumented original-then-changed comparison. It proves eight structural interpretations were avoided in this case. It does not establish a stable speedup or the hosted20minute margin. Decoder timings omit later schema-validation statements. The original ephemeral fixture from earlier diagnostics was not replayed; both variants used the same newly reconstructed case.

## Failed scratch attempts and remaining gates

Windows attempts1–3 counted runtime-identity JSON as structural decoding; the counter was narrowed to the real structural boundary without weakening production conditions. Later attempts passed. Draft parser/factory-name diagnostics were fixed and final quality is clean. A root-only evidence checker initially had a parenthesis typo and failed before execution; the corrected checker passed. All source attempts and logs remain at the roots bound by [the artifact index](ARTIFACT-INDEX.json).

The [independent review](independent-source-review.json) is `PASS_SOURCE_REVIEW_WITH_VALIDATION_PENDING`. The [root comparison verification](comparison-root-verification.json) is diagnostic proof, not final acceptance. The next action is one final-candidate mandatory aggregate on these frozen bytes, followed by normal commit, actual accepted-B/new-H validation/current audit, final review binding, fresh remote reviews and hosted checks. No PS carryback starts before TF acceptance.

At the authenticated09:59:02Z read, TF68 remained open at H5ec4bdc/Be21b74f with all16threads resolved and13ordinary successful workflows. Dynamic37430212759 remained cancelled and blocks merge. No CI relaunch occurred. Historical TF67/PS224 acceptance does not waive current failed CI. Round5/80, original deadline2026-10-13T23:47:31Z and transfer counts A06/A03/A21/A07=1/3/5/5of12 remain unchanged.
