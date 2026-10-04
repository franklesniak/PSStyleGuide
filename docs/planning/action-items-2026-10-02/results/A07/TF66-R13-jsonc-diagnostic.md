<!-- markdownlint-disable MD013 -->
# R13: expose one bounded JSONC parse diagnostic

Status: coordinator selected V98 before implementation at 2026-10-04T21:57:48.581985+00:00. Private implementation and focused verification are released; product integration and acceptance remain pending.

Input: published TF H `055f112f762a466ed693c073083225f8ec9ee79d`, tree recorded in `source-identities.json`, accepted B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. The product was unchanged at selection. Root owns integration and native actions. Exact source and probe evidence is in the [private handoff](C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-TF-coherent-20261004/implementation/round3-review-findings/HANDOFF.md).

Actual probe: `run-probe.py` invokes pinned Node24.18.1 with private TEMP/TMP/npm cache; command, timestamps and exit0 are in `probe-command.json`. Log SHA256 `f718a5ef170f36400198c49b4a3e1c27375d823235e2f19f6dd76fbd3a565743`. Supplemental option probe: `run-option-evidence.py`, exit0, log SHA256 `6ee1e410ddc072b490b53a27fb6ee637db11d13933433cb38b5aaa24ee6f8327`. Neither runs a full suite, install, audit, aggregate or native service mutation.

## 1. Validated facts and distinctness

[Copilot comment4179432294](https://github.com/franklesniak/TerraformStyleGuide/pull/66#discussion_r4179432294) correctly identifies lost diagnostic information. The shared loadMarkdownlintConfig safely locates the preferred JSONC/fallback JSON file, refuses a file above1MiB, parses with jsonc-parser3.3.1 and rejects errors/nonobject values. It currently collapses syntax failures and valid nonobject values into the same filename-only error.

The actual helper rejected LF missing-colon input even though the parser supplied ColonExpected at UTF16 offset13. CRLF missing-value input supplied ValueExpected at offset16. A Unicode example supplied ColonExpected at offset25. Three malformed values supplied three distinct errors, all discarded by the current message. Valid comments and a URL/comment-like string were accepted. Arrays and null were correctly rejected with no parse errors. The actual outer CLI returned2 and the generic message. There is no admission bypass or missing rejection.

The supplemental probe compared existing parser parse() errors with its existing visit/onError callback on LF, CRLF, CR, surrogate-pair and multiple-error inputs. Code, offset and total count matched. First locations were2:12,3:1,3:1,1:26 and1:7 respectively. These are1-based displays of the parser's zero-based UTF16 line/character positions; column is not a grapheme/display-cell measurement.

The [R5/C100 decision](TF66-R5-config-diagnostic.md) changes a different error: unsupported selector advice naming both allowed files. It remains unchanged and is not a duplicate solution to syntax diagnostics. Its constraint against exact-prose tests for a reversible wording edit still applies. D90/E90 require useful diagnostics and the retained JSONC/JSON behavior; neither specified this new syntax-detail projection.

The common loader feeds full outer, exact staged and nested lint. Existing tests cover valid JSONC/comment strings, JSON fallback, configured rules, malformed and nonobject input, extends, missing config and all unsupported selectors. These current behaviors remain mandatory. The ordinary CLI currently prints the error and its stack; changing stack presentation is a separate unrequested concern and is not included.

## 2. Stakeholders and scope

Documentation authors and new contributors need a file location they can navigate and a specific syntax cause. Editor, screen-reader and terminal users benefit from plain text with explicit1-based coordinates rather than a raw code number or large dump. Both maintainers and paired-repository reviewers need one shared loader diagnostic, unchanged config precedence and no new parser dependency. Security/privacy owners need bounded output without copying arbitrary configuration text. CI/agent operators need status2 and concise remediation evidence. QA needs LF/CRLF/Unicode and first-error/count fidelity, not exact sentence snapshots. Recovery/deployment administrators, data storage and credentials are unaffected; no new localization framework is warranted.

## 3. Options (communicated before rubric)

| ID | Option | Consequence |
| --- | --- | --- |
| N | Keep the generic filename error | Correct rejection; user must find syntax failure without available detail. |
| C | Add only the error count | Shows scale but gives no specific cause or location. |
| O | Add first symbolic error code, UTF16 offset and count | Small projection of existing data; offset is less convenient than an editor line/column. |
| L | Add first code, line/column and count with local position calculation | Good user detail; owns newline and UTF16-position logic. |
| V | Add the same detail using existing jsonc-parser visitor callbacks only after parse errors | Reuses native positions; one extra bounded traversal only for invalid input. |
| J | Serialize one structured error object plus count | Useful to code consumers but less directly readable, especially numeric parser codes. |
| F | Emit a capped list of several native errors | More independent detail but may include cascading failures; requires list and cap formatting. |
| E | Include a bounded source excerpt and caret | Rich context but adds source disclosure, escaping and Unicode display responsibilities. |
| S | Add a common cross-parser diagnostic framework | Can serve future JSON/YAML consumers but broadens the admission/formatting boundary without a current second need. |
| P | Replace JSONC with comment-stripping plus JSON.parse | Ineligible if it loses valid JSONC string/comment behavior or changes supported admission. |

V combines the useful first-code/location/count properties rather than adding a separate error engine. F can use V's native positions and has been scored as a genuinely bounded list, not an unbounded dump. E may add V but still needs excerpt/privacy handling. Deferral is N with a future revisit. A compatible new JSONC parser would require independent evidence and a dependency decision, with no demonstrated advantage over the already installed API; no speculative package change is proposed.

## 4. New finding-specific rubric

Scores0–5 mean absent/unacceptable, weak, partial, adequate with residuals, strong, or fully supported for that criterion. Weighted sum(weight*score/5). Hard constraints cannot be traded away.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Contributor recovery precision | 30 | Identify the first actionable syntax problem without a large diagnostic dump. |
| Admission/semantic fidelity | 25 | Preserve parser options, JSONC/JSON precedence, nonobject/extends/path checks and status2. |
| Bounded/private output | 20 | Bound the detail without leaking source text or an unbounded error list. |
| Location correctness | 15 | Preserve native error identity and honest UTF16/newline positions. |
| Maintenance | 7 | Reuse the existing parser and avoid duplicated position/format frameworks. |
| Delivery effort | 3 | Keep the correction proportionate to a diagnostic improvement. |

Keep the1MiB input cap and all rejection semantics. Add syntax detail only when parsing reports errors; do not invent a parse code for array/null. Do not silently change unknown configuration admission. Scores for N/C location reflect missing location, not an incorrect current location.

## 5. Scores before selection

| Option | Recovery30 | Fidelity25 | Bounded20 | Location15 | Maintenance7 | Effort3 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 5 | 5 | 0 | 5 | 5 | 61 |
| C | 2 | 5 | 5 | 0 | 5 | 5 | 67 |
| O | 4 | 5 | 5 | 5 | 5 | 5 | 94 |
| L | 5 | 5 | 5 | 4 | 3 | 4 | 93.6 |
| V | 5 | 5 | 5 | 5 | 4 | 4 | 98 |
| J | 3 | 5 | 5 | 5 | 5 | 5 | 88 |
| F | 5 | 5 | 5 | 5 | 3 | 3 | 96 |
| E | 5 | 5 | 3 | 5 | 2 | 2 | 86 |
| S | 5 | 4 | 5 | 5 | 3 | 2 | 90.4 |
| P | — | — | — | — | — | — | Ineligible as described |

Recommend V98. Its concrete discriminator is native, editor-usable positions with bounded first-error output and no source excerpt. O94 is a good smaller alternative; its positions are accurate, but users need an offset-aware tool to navigate. L93.6 is feasible but must own/verify position logic already supplied by the parser. F96 is scored as safe and useful, not artificially unsafe: its modest deduction is the extra list/cap maintenance and validation without demonstrated need over first-error repair and count. E86 carries real source disclosure/display costs. S90.4 is viable but changes more parser-facing surfaces and requires broader fidelity evidence; it is not excluded merely for churn. V's extra pass occurs only on syntax failure in an already bounded1MiB input.

## 6. Selected controlled-English proposal

1. Keep the existing parser and parser options.
2. Keep the source text for the current parse call.
3. Keep the existing rejection when parsing reports errors.
4. On that error path, call the installed parser's visitor API with the same options.
5. Retain only the first error callback's code and position.
6. Convert the native line and character to1-based values.
7. Show the symbolic error code, line, UTF16 column and total parse-error count.
8. Keep the filename and current diagnostic prefix.
9. Do not print source text or every parser error.
10. Keep the existing generic rejection for valid nonobject input.
11. Keep the existing extends and unsupported-selector errors.
12. Run the focused syntax, position and retained configuration controls.

The visitor is for diagnostics only. The original parse result and error array remain the admission authority. If native position detail is unexpectedly unavailable, retain the existing rejection rather than invent a position or accept the input. No generic parser abstraction, new schema, dependency or public JSON response is selected. Exact proposed product path is `.github/workflows/lint-nested-markdown.js`; a meaningful position/bounding case may extend existing `.github/workflows/lint-markdown.test.mjs` after release. No guide, workflow, metadata, cap or protected text change is needed. This is shared code for later PS reverse transfer. The instructions follow the requested short-action style; no formal dictionary certification is claimed.

## 7. Meaningful proposed verification and primary source

Reuse valid comments/URL strings, JSON fallback, nonobject, extends, missing and unsupported-selector tests. Directly observe the new syntax message through the actual helper and outer/staged/nested paths as applicable. Test LF, CRLF, lone CR and a preceding surrogate pair against the native parser's known first positions. Test multiple syntax errors: first code/location and count must be preserved, while later details/source markers are not printed. A long malformed input below the existing cap should not enlarge the added detail with input text. Above-cap input must retain its existing cap error. Valid object, array and null must retain their admission outcomes. Compare meaningful fields and bounds; do not snapshot the entire English sentence. No test is added solely to mirror a one-string change.

The installed parser's public API exposes ParseError code/offset/length, printParseErrorCode and visitor onError with startLine/startCharacter. The native error-only traversal preserves parser position semantics; it does not require comment stripping or a new dependency. [Microsoft jsonc-parser3.3.1 API](https://github.com/microsoft/node-jsonc-parser/blob/v3.3.1/src/main.ts). Installed declaration/source identities can be reused for exact dependency verification; the actual probes above confirm this pinned runtime behavior.

No post-repair result, public reply, acceptance or transfer increment is claimed by this proposal.

## Coordinator selection

Root read the full proposal, checked both current production sites and native probes, verified the proposal SHA256 `a081ec412abcad474abf8338c07a7d85d65e56f4a81ac9a7a3e42270d9dad67c`, and recalculated all option totals. Options, separate rubrics, score tables and selected actions were displayed to the owner in that order before release. Select V98. The original proposal describes pre-edit evidence; no repaired candidate is accepted yet.
