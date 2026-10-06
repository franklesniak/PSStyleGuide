<!-- markdownlint-disable MD013 -->
# TF68 R6 — unknown-artifact diagnostic

## 1. Validation and affected users

The suggestion asks to include the invalid ArtifactId and destination keys. This repeats the substantive request in [PS234 R8](C:/Users/flesniak/GitHub/PSStyleGuide/docs/planning/action-items-2026-10-02/results/A06/PR234-round2/R8-unknown-artifact.md); the record is a prior decision, not a substitute for validating current TF input. Current private writer line 1733 tests dictionary membership and throws fixed `unknown-artifact`. Its sole entry-point caller at 2194–2206 iterates that same map's Keys and passes the identical map and current key. Current external guide text cannot select an arbitrary artifact ID. The outer catch at 2231 onward publishes fixed structured fields and the exception type, not Exception.Message. Thus interpolating this private exception does not give the requested CI message to the actual current consumer.

The function's output documentation already states that binding, lookup and initialization failures occur before artifact-record wrapping. Actual extracted-function probes for both a plain unknown ID and a newline/workflow-command-shaped ID returned exactly `unknown-artifact`, before filesystem work. The future possibility of a private caller error is real; no claim is made that this guard is unreachable for arbitrary direct callers. The supported current need is a fixed precondition and a bounded public diagnostic contract, not unchecked field echo. D1/D3 in A06 design.md and threat-map.md deliberately bound failure labels and hostile-field handling.

CI operators need usable failure categories; security reviewers need bounded output; new contributors need a map they can inspect; paired maintainers need one common engine with narrow descriptors; QA needs an independent result schema. The actual caller/schema evidence addresses these roles. No correctness or security failure is demonstrated by terse private misuse diagnostics.

## 2. Options before evaluation

- A. Retain the fixed guard and result contract; explain the actual consumer boundary in the review disposition.
- B. Add a static bounded list of allowed IDs to the private message, with no raw input echo.
- C. Interpolate the supplied ID and map keys as suggested.
- D. Add a bounded public diagnostic field, enum or documented category with full verifier/schema and hostile-field changes.
- E. Restore a fixed ValidateSet as well as or instead of membership validation.
- F. Remove the explicit guard and rely on downstream lookup errors.
- G. Add only a code comment explaining the existing boundary.

B+C inherits unchecked data exposure; B+D reduces to D's new public interface. Sanitizing and truncating C is a D-style diagnostic contract if the detail must reach CI; otherwise it is a larger B with no current consumer benefit. E plus the existing map duplicates authority. Changing all general error logging is outside the demonstrated need. No suppressed error, weaker verifier or uncontrolled output is eligible.

## 3. Unique weighted rubric

Caller correctness 35%: preserve live map authority, early failure and actual result semantics. Bounded diagnostics 25%: avoid unchecked map/ID data, uncontrolled lengths and new publication channels. Actual usability 25%: benefit the real caller and operator, rather than only hypothetical direct invocation. Paired clarity 10%: preserve one common algorithm and explicit language descriptors without duplicate enumerations. Cost 5%: count lifecycle/schema migration, never as a substitute for correctness.

## 4. Scores before selection

| Option | Caller correctness 35 | Bounded diagnostics 25 | Actual usability 25 | Paired clarity 10 | Cost 5 | Total / 100 | Reason and limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 10 | 9 | 9 | 10 | 96.5 | Only caller supplies its own map key; fixed failure and public result stay coherent. |
| B | 10 | 9 | 8 | 7 | 9 | 89 | Safe if kept static, but does not reach current CI output and duplicates language-specific descriptors. |
| C | 9 | 2 | 7 | 6 | 9 | 64.5 | Direct debugging gains detail; unchecked length/newlines and current catch still prevent the claimed CI benefit. |
| D | 9 | 9 | 9 | 7 | 4 | 85.5 | Can help a future caller; requires schema, verifier and hostile-field admission changes for an unreachable current case. |
| E | 7 | 8 | 7 | 5 | 8 | 71 | Hardcodes language IDs and changes binding errors while the live map remains the real authority. |
| F | 3 | 5 | 3 | 4 | 10 | 39.5 | Later lookup failure loses the stated private precondition; rejected. |
| G | 10 | 10 | 9 | 8 | 8 | 94.5 | No runtime gain; existing output contract already explains pre-record failures. |

## 5. Selected instructions and validation

Select A. Keep the fixed unknown-artifact guard. Keep the existing map-driven caller and result schema. Do not print the supplied ID or map keys. Explain that the current outer catch does not expose this private message. Use the actual caller and hostile-input probe as evidence. Reuse the prior PS234 decision only for these validated unchanged properties. No product edit or additional test run is required for this disposition.

## Selection and evidence

Root displayed validation, options, this unique rubric, all scores and the selected action before product release. Selected2026-10-06UTC on TF7dd48f52c9e4c17268b4a571919622f4d701e5d0, acceptedB=e21b74fe0b56551008f78f9f2946cd2a0f9c19ce and pairedPS98177628b7bc02c646724bfc8aa0fd73fed0cd24. [Decision evidence](evidence.json) and [parent verification](root-verification.json) bind all7 raw source rows,18 artifacts and29 score calculations. Runtime probes used PowerShell7.6.5/PSScriptAnalyzer1.24 and Node24.18.1. Probe limits and failed private job-selector attempt remain in evidence; no product or hosted execution is inferred from prospective analysis.
