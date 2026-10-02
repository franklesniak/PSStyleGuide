<!-- markdownlint-disable MD013 -->
# D-A02-09: Preserve parser JSON strings on supported PowerShell hosts

**Validate.** Full native agent validation fails at the existing Markdown prose shape guard after A02 discovers `docs/P1-SUPPLY-FREEZE-REPRODUCTION.md`. The inline code `2026-10-29T23:59:59Z` arrives from Node as a JSON string. PowerShell 7.6.5 `ConvertFrom-Json` changes it into DateTime. Debugger inspection proved the resulting code array contains one nonstring. The same decoding operation consumes the bounded Python TOML result. The validator already uses PowerShell 7 automatic variables and System.Text.Json; its root host promise is PowerShell 7. Generator PowerShell 5.1 support is separate.

**Stakeholders.** Both maintainers, Windows/Linux PowerShell 7 users, documentation authors, metadata and parser maintainers, local/CI agent operators, security reviewers, historical-evidence custodians, and cost/schedule owners need exact parser content and unchanged rejection rules. Cloud administrators, privacy owners, accessibility and localization users have no distinct operation or exposure in this local typed-data decoding change.

**Options.** A: retain the conversion and exempt the current document or defer the consumer. B: use unconditional `-DateKind String`. C: use conditional DateKind with the existing default on older hosts. D: use one bounded System.Text.Json decoder at both actual output boundaries. E: convert DateTime back to text. F: use a private Newtonsoft setting, version-dependent adapter, or a second parser process. A violates governed discovery; C and E cannot preserve original strings; F adds runtime coupling or a process without a distinct safety advantage. Removal of type guards collapses into A and violates the hard constraints.

**New rubric.** Exact typed-data fidelity 35%; rejection/bound preservation 30%; promised host compatibility 20%; operational simplicity 10%; bounded change cost 5%. Scores 1–5 are reasoned judgments; total is weighted sum divided by 5. Hard constraints: preserve string offsets/precision, arrays, null, numeric and Boolean types; retain caller shape validation and native failure behavior; no host minimum-version bump or general parser rewrite.

| Option | Fidelity | Rejection | Compatibility | Simplicity | Cost | Total /100 | Uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 1 | 5 | 5 | 5 | 48 | Leaves proved discovery failure; fails constraints |
| B | 5 | 5 | 1 | 5 | 5 | 84 | Requires PowerShell 7.5; fails promised host constraint |
| C | 2 | 4 | 5 | 4 | 4 | 70 | Older hosts still coerce; fails fidelity |
| D | 5 | 5 | 5 | 4 | 3 | 96 | Must test array/null behavior and rejection |
| E | 1 | 3 | 5 | 4 | 4 | 57 | Original offset/precision already lost; fails fidelity |
| F | 5 | 4 | 3 | 2 | 2 | 77 | Additional dependency/version or process surface |

**Selection.** Use D. Decode strings with JsonElement.GetString. Decode JSON arrays as arrays, including zero and one elements. Decode null as null, Boolean values as Boolean, and integer values as Int64. Preserve numeric values that are not Int64 as finite Double. Reject duplicate/case-conflicting properties, comments, trailing commas, nonobject roots, excessive depth and oversized output. Keep all existing caller type, range, property and process failure checks. Use the existing 4096-byte TOML bound. Set the Markdown typed-context decoding bound to 16 MiB and depth to 64; this exceeds current bounded documents while stopping unbounded JSON materialization. Do not change transport retries, process cleanup, Markdown token generation or other parser contracts.

[Microsoft ConvertFrom-Json documentation](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertfrom-json?view=powershell-7.5) confirms DateKind was introduced in 7.5 and default conversion can change offsets. System.Text.Json is already an actual validator dependency. Test exact offset and fractional-second strings through the real Node parser, the reported native document, typed empty/single arrays and null/number/Boolean fields, malformed/deep/oversized JSON, and the full native mutation suite. The implementation is not accepted until those tests pass. No older PowerShell runtime is installed here; compatibility is bounded to using APIs already present in the existing PowerShell 7 validator, not a measured cross-version run.
