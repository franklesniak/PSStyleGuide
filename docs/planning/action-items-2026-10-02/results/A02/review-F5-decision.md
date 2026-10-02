<!-- markdownlint-disable MD013 -->
# F5: validate intentional optional metadata

Status: selected two-file repair implemented; focused checks and the final normal pre-commit passed. Parent owns integration and native review.

## Validated finding

At PR224 f81f769b8b6d096a764b69e9a16e612c2c8c1186, Codex comment4167109675 and the independent final-quality reader identify the same confirmed P2. Exact production discovery removes every classification ExemptPath before reading content. The reader loaded that AST function without modification: README.md and CONTRIBUTING.md remain absent while docs/new.md is returned. Separately, the catalog's canonical Copilot document has RequiresMetadata=false and the final loop skips it. Neither route can validate a later intentionally adopted header. Protected docs.instructions.md111 and118–130 apply synchronization to every document intentionally carrying the header, including Tier2. No guide change is needed.

The five actual Tier2 documents have no current header markers. All four generated documents contain copied source metadata and remain governed by generation; they must not be reinterpreted as optional author metadata. The existing F1 promotion test removes README from Tier2 before testing, so it does not cover retained Tier2 opt-in. The independent reproduction and input identity are recorded in `PSStyleGuide-plan-review-20261002/PR224-final-quality/REPORT.md`.

## Stakeholders and hard constraints

Documentation authors need optional headers without forcing metadata on reader-facing pages. Both repository maintainers and future A21 integrators need one bounded parser-based rule. Reviewers, CI operators and security/history custodians need real B/H comparison, nonfuture/calendar checks and truthful finalization limits. Generated-artifact users need source metadata preserved without aggregate-parser false positives. Windows/Linux contributors need unchanged safe input and parser/runtime contracts. No deployment, credential, cloud-state, privacy or localization interface changes.

Hard constraints: no protected-text or classification-authority change; no generated aggregate promotion; no valid-only detection that ignores malformed attempts; no fenced/quoted/frontmatter/example promotion; no erasure of an invalid prior intentional header; no new clock or claim that ordinary delayed CI proves historical finalization. Retain all existing raw-byte, regular-file, size and endpoint guards.

## Options and new rubric

Options were considered before scoring. N: no change/defer. R: remove optional metadata synchronization entirely. A: require headers on every Tier2/generated document. V: validate optional documents only after complete successful parsing. X: search all raw text with field regexes. C: add a separate per-path opt-in configuration requiring synchronized maintenance. T: copy TF's existing optional detector/transition behavior unchanged. P: use the existing Markdown AST to recognize header intent in optional document header regions, then use existing metadata/date/Version helpers. A whole-parser rewrite or new framework adds no supported capability over P. Narrowly exempting existing no-header documents is already P's optional branch; generated semantics stay separately excluded.

During bounded source verification, A21's reader identified the existing TF06ad4f detector (line4441) and transition helper. The exact native function was read: it already uses parser-backed optional intent, but its raw prefilter is narrower, its top-level field scan extends beyond the header into later example sections, and its transition helper nulls a malformed prior intentional header (4624–4628). This validates reusing the existing parser concept and category separation, not those incompatible boundaries. T was added to this same decision before further implementation; P and the fixed criteria remain unchanged.

Fresh scores0–5; total=sum(weight*score)/5. Criteria: policy coverage35 (both optional routes and malformed intent), baseline/trust25 (actual prior metadata and authority), context precision20 (no example/generated false positives), maintenance15 (reuse and future callers), implementation cost5. Scores are judgments, not measured probabilities.

| Option | Coverage35 | Trust25 | Precision20 | Maintenance15 | Cost5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 4 | 5 | 2 | 5 | 58 |
| R | 0 | 1 | 5 | 3 | 4 | 38 |
| A | 3 | 4 | 0 | 2 | 3 | 50 |
| V | 2 | 3 | 5 | 4 | 4 | 65 |
| X | 3 | 3 | 1 | 3 | 4 | 53 |
| C | 3 | 4 | 4 | 1 | 2 | 62 |
| T | 3 | 2 | 2 | 4 | 5 | 56 |
| P | 5 | 5 | 5 | 4 | 3 | 95 |

N/R/V leave the demonstrated policy gap. A changes optional policy and generated semantics without authority. X cannot distinguish quoted or generated sources. C creates a second coverage list and can silently miss later intentional headers. T loses the required real invalid-prior boundary and can promote later examples. Only P satisfies all hard constraints with the existing consumer architecture.

## Selected solution

Select P. Add Tier2 paths to bounded document input contexts as optional metadata documents. Keep generated paths excluded. Run the same optional rule for existing catalog entries whose metadata is not required. Keep discovery and classification admission authority unchanged.

Recognize intent from the existing parser's top-level blocks/list items. Exclude leading YAML front matter. Inspect the document header before its first ordinary section: after an early H1, or the body-start fallback when no early H1 exists. Also inspect the bounded pre-title prefix for recognizable misplaced intent; stop that prefix at its first heading so later examples remain excluded. Recognize a Metadata section heading (H2 or deeper; an H1 title alone is not a metadata section), a Version paragraph, distinctive Status/Last Updated labels, and explicitly emphasized reserved field labels. Detect incomplete, duplicate, misplaced or malformed header values without first requiring successful metadata parsing. Ignore nested/fenced/quoted/HTML-example text, ordinary generic Owner/Scope prose and later example sections. This recognizes observable header syntax; it does not infer every possible author's intent from arbitrary prose.

For current intentional headers, run the existing exact metadata parser and date/Version transition helpers. Initialize metadata only when the optional baseline genuinely had no header intent. Preserve actual invalid or valid prior opt-in for validation and regression checks. Tighten F1 promotion nulling so a trusted exemption cannot erase an invalid prior intentional header. Keep genuine no-header F1 promotion and separate F3 closed classification initialization.

Tier2 remains optional. A deliberate complete removal of the optional header leaves no metadata fields to synchronize; no inspected policy requires permanent header retention. Malformed remaining header markers still trigger validation. Removing only Version while retaining a header uses the existing D14 baseline checks. Ordinary committed B/H checks retain the F2 limited structural/date statement; local changed inputs and explicit FinalizeMetadataNow retain current-UTC finalization checks. Do not add a public mode, clock input, manifest field or protected edit.

## Implementation and validation scope

Only `.github/workflows/Test-AgentInstructions.ps1` and its dedicated SelfTest may change. Preserve the existing published metadata tuple convention; this is the same unpublished PR transition. Add focused permanent cases for no-header actual Tier2/catalog inputs, valid and malformed opt-ins, fallback placement, optional Version transitions, malformed prior opt-in, initial adoption, date regression/calendar/future/strict-now versus delayed checks, whole-header removal, ignored examples and generated inventory exclusion. Use actual helpers and a bounded extension of the existing private installed-policy Git caller fixture for retained Tier2 and catalog paths. That fixture proves proposed caller behavior, not installed native-main authority.

Run the affected focused cases first. Then run one normal full final-byte pre-commit with the declared Node/npm and Python runtimes; preserve unchanged earlier evidence. If the topic's current baseline prevents an otherwise required reversion, use only a separately owned accepted-base fixture after coordinator handoff; do not weaken production policy. Record actual outcomes and final identities here at handoff. Parent owns native publication and final integration. A07 stays frozen. PR round3/80, original October10 deadline and transfers0/12 do not reset.

## Validation result

Final staged tree `c204d80a4bd0a8252ba05e34485d3018317dca66` passed one complete normal `py -3.12 -m pre_commit run --all-files` under Node24.18.1/npm11.16.0. All10 hooks passed; owned session69529 returned exit0, observed at2026-10-02T16:29:45Z. `precommit.log` is the final-byte aggregate evidence. Final readback confirms the same tree, unchanged parent f81f769, only the two assigned staged files, no unstaged changes, and both Git modes100644.

The focused production helpers passed32 intent cases and12 metadata transitions. The bounded actual accepted-B/H caller subset passed retained Tier2/catalog strict-date versus delayed checks, malformed headers, optional Version adoption, invalid prior opt-in rejection and whole-header removal. That subset preceded the final heading precision corrections; the completed aggregate reran the permanent actual caller on the final bytes. Current real no-header documents passed the validator. PSScriptAnalyzer produced no Error diagnostics. Generated-exclusion and Tier2-context assertions passed in the final aggregate with all existing F1–F4/D14–D17 controls.

Two earlier aggregates were deliberately interrupted and are not acceptance: b3eb7c missed recognizable pre-title metadata (also found independently), and2ac837d then overclassified an H1 title literally Metadata. The bounded prefix/section distinction and completed sibling sweep cover both. Their incomplete logs remain scratch evidence; no failed policy control was waived.

Validator SHA256 `b8fcc6dd663ddb13aadc0029e40004fd9b7a45b177503fcf85f773777bf98f15`, Git blob `64378d898e72e9bc57b09286c15f72a9a4450440`; SelfTest SHA256 `ae1c29792c6f9a6f391dd2ef98bf3e8b0a9dd19e6da13bfb458deb4f9e1a12e1`, Git blob `c11c53b6c997ca0c16510b3cbf03cd2231015809`. Evidence is limited to proposed-code behavior; this does not establish installed native-main authority or historical author-finalization time. No protected text, classification data, workflow, native state, commit, push, review clock or transfer counter changed. A07 remains frozen.

## Coordinator integration

The coordinator inspected the exact two-path diff, independently matched the raw hashes/modes, and recalculated all eight weighted totals. Normal commit `519c420738f8f8c9c1b185dfa68138b89974343e` has the exact final tree `c204d80a4bd0a8252ba05e34485d3018317dca66` and was pushed without force. Proposed-code finalization and classification passed on actual B `48f4d8a36c8faceee12afac78aaecea0d176125d` and H `519c420738f8f8c9c1b185dfa68138b89974343e`; finalization captured UTC2026-10-02. The native-base fixture retained HEAD B with the entire candidate staged and no unstaged differences. [Independent local quality](F5-quality.md) approves the actual commit within its stated scope. Fresh remote reviews and current native CI remain required; round3/80, original deadline and transfers0/12 are unchanged.
