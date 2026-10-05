<!-- markdownlint-disable MD013 -->
# PS232 R7 — actionable Node declaration diagnostics

**Selected and implemented, 2026-10-05:** Root displayed the options, unique rubric and scores, then selected S98 at09:47Z. The clear winner needs no further owner decision. The pre-edit proposal below preserves the full analysis. Its proposal-only wording records the earlier stage; the implementation and focused evidence at the end supersede that state. Full aggregate and native acceptance remain separate gates.

Proposal only. Root must select and release before any R7 product edit. Hf77a58dede8f6f68b45e0d62e5b96e2fed477c58/Bf168f83b89f64b6bca9d520ddec4b58969060fb6. Copilot comment4182559907 on lint-markdown.mjs:25 reports an ambiguous missing engines.node message. R6's separately selected README repair is already frozen; it is not modified here.

## 1. Validated cause and useful scope

The current helper safely validates root package.json as a bounded non-symlink regular file inside the canonical repository. It parses JSON, reads engines.node, then combines exact-version-format and running-version equality in one conditional/message. Missing engines or node, and null node, all produce `Markdown lint requires declared Node version; observed 24.18.1.` Empty string produces an empty required value. A range is printed as if selecting that version alone could satisfy the exact-version rule. An array containing the running version renders required/observed equal while still being rejected by strict equality. These are real repair-guidance ambiguities, not unsafe admission.

A bounded Node24.18.1 probe called the actual current helper with nine private manifests and a real benign child marker. Missing file, missing engines, missing node, null, empty, range, array and valid mismatch all rejected without executing the child. The exact-version control executed the child and returned0. Missing package.json already gives ENOENT plus its exact path; it is different from a missing field inside an existing file and needs no replacement generic error. Valid24.18.0 versus observed24.18.1 already supplies useful required/observed detail. command.json/probe.log preserve exact command and exit0. No network, install, full suite or aggregate ran.

The selected R21 manifest filesystem boundary and R2 child boundary remain unchanged. Existing lint-markdown.test.mjs:436 onward covers actual regular/alias/symlink/missing/malformed/wrong-version/one-MiB boundaries. The new issue is not a duplicate of those security repairs. NpmTools already separates missing exact engine declarations from runtime mismatch; reuse that diagnostic principle, not its broader npm/install interface. No root manifest schema, supported runtime, CLI status or parser rule needs changing.

## 2. Stakeholders

Contributors need to distinguish repairing a manifest from selecting the declared runtime. CI/agent operators need stable exit2 and a filename/field they can locate. Maintainers and documentation owners need messages consistent with the existing exact-version setup instructions. Security reviewers need invalid input to remain rejected before child execution and no unnecessary echo of malformed input. QA needs actual admission/execution controls, not an exact-prose snapshot. Peer owners need this useful common diagnostic after PS acceptance, without changing unrelated caller or dependency contracts.

## 3. Material options

| ID | Option | Tradeoff |
| --- | --- | --- |
| N | Keep the current combined diagnostic | Correct rejection; ambiguous remedy persists. |
| D | Explain missing/invalid declarations only in documentation | Adds lookup guidance but the command still does not identify its cause directly. |
| M | Improve one combined message with package.json/engines.node and required/observed values | Names the location, but can still conflate malformed declaration with runtime mismatch. |
| S | Split invalid/missing exact declaration from valid mismatch | Names the precise field/remedy; retains useful existing mismatch detail. |
| T | Separate missing, malformed and mismatch into three branches | More categorical detail, but missing/malformed share the same immediate exact-version remedy. |
| F | Contextualize the whole manifest-read/validation pipeline, preserving cause | Could unify errors, but must preserve distinct filesystem, containment, JSON and runtime diagnostics. |
| C | Introduce a shared manifest diagnostic validator across helpers | Can centralize conventions but couples previously separate npm/lint and accepted-tool contracts. |

S includes the useful message improvement from M. D can accompany S/T/F, but existing dependency-maintenance already names exact package engines; no new documentation gap warrants duplication. F+C retains both broad-interface costs without a current common validation requirement. An automatic fallback to the observed Node version or a permissive version range is ineligible: it changes mandatory exact-runtime admission. Catching all errors and replacing them with a missing-field message is also ineligible because it hides real filesystem/parser failures. No framework or dependency change is selected.

## 4. Finding-specific rubric

Scores0–5:0 absent/contradicted,3 adequate with a concrete residual,5 fully supported; total=sum(weight*score/5). Mandatory gates: keep regular/contained/bounded manifest checks, strict exact-runtime admission, rejection before child execution,0/1/2 mapping, and required/observed detail for valid mismatches.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Actionable cause/remedy precision | 32 | Identify the field to repair versus runtime to select. |
| Rejection/native execution preservation | 28 | Keep every admission and child-execution boundary. |
| Bounded safe diagnostic content | 18 | Give necessary facts without echoing arbitrary malformed values or hiding causes. |
| Supported-call-path consistency | 12 | Useful API error and CLI wrapper output under the same rule. |
| Maintenance | 7 | Avoid unnecessary diagnostic branches or validator coupling. |
| Effort | 3 | Proportionate implementation and focused verification. |

## 5. Scores and recommendation

| Option | Precision32 | Preservation28 | Safe detail18 | Consistency12 | Maintenance7 | Effort3 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 2 | 5 | 3 | 5 | 5 | 5 | 73.6 |
| D | 3 | 5 | 3 | 5 | 4 | 4 | 78 |
| M | 4 | 5 | 4 | 5 | 5 | 5 | 90 |
| S | 5 | 5 | 5 | 5 | 4 | 4 | 98 |
| T | 5 | 5 | 5 | 5 | 3 | 3 | 96 |
| F | 5 | 4 | 5 | 4 | 3 | 2 | 87.4 |
| C | 5 | 4 | 5 | 4 | 2 | 1 | 85.4 |

Recommend S98. It directly resolves the observed ambiguity and suppresses misleading malformed-value interpolation. N is safe in admission but weaker in actionable output. M is a real improvement; its remaining weakness is the different remedies still sharing one branch/message. T is fully capable, not incorrect; extra missing-versus-malformed branching provides no different action for this contract. F/C can be correct but introduce additional error/interface reconstruction requiring evidence across callers; their lower preservation/consistency scores reflect that unproved expansion, not a hard prohibition based on churn. The current bounded input limit remains; this decision does not claim an existing exploitable output disclosure.

## 6. Controlled-English selected recommendation

1. Keep the existing manifest read and filesystem checks.
2. Read the same engines.node field.
3. Reject a missing value, a non-string value or an invalid exact-version string with a fixed declaration diagnostic.
4. Name root package.json and engines.node in that diagnostic.
5. State that the field requires an exact major.minor.patch Node version.
6. Compare a valid declaration with the running Node version.
7. Keep the current required/observed mismatch diagnostic.
8. Preserve child invocation, limits and status handling.
9. Check the retained manifest-boundary cases and focused diagnostic behavior.

Concrete proposed replacement boundary, not applied:

```javascript
if (typeof required !== 'string' || !/^(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)$/u.test(required)) {
  throw new Error('Markdown lint requires root package.json engines.node to declare an exact Node version (major.minor.patch).');
}
if (required !== process.versions.node) {
  throw new Error(`Markdown lint requires declared Node ${required ?? 'version'}; observed ${process.versions.node}.`);
}
```

Keep the existing extraction expression and parse behavior. The explicit string check does not narrow accepted inputs: the previous condition already required strict equality to process.versions.node, which is a string. All non-string JSON values were rejected. It only classifies their diagnostic correctly. Null root JSON or malformed JSON retain their existing parse/property failure path; no separate schema redesign is included. The mismatch template is left unchanged, including its now-unneeded fallback expression, to avoid unrelated cleanup.

## 7. Scope and meaningful verification

Proposed product scope: `.github/workflows/lint-markdown.mjs` only. No governed document or PowerShell Notes metadata applies. No new repository test or exact-message assertion: developer instructions prohibit tests that merely mirror a reversible diagnostic correction. Existing actual manifest-boundary tests can be run by name on the changed helper. A private bounded probe should confirm filename/field/remedy properties, unchanged required/observed mismatch, API rejection and actual CLI exit2, and no child execution on all rejected inputs. The exact-version control must still execute. Preserve the original nine-case log; do not claim a full suite or Linux result from this Windows probe. Root owns the final combined aggregate and native lifecycle.

The helper is shared with accepted TF. After PS landing, root refreshes native sources and carries this useful common change in `.github/workflows/lint-markdown.mjs` under A07. Together with R6, this would expand the earlier four-path conditional TF repair to six paths, still A21/A07-owned; no counter is incremented here. R9's existing inline-entry decision remains separate and unchanged.

Evidence.json pins exact H/modes/source hashes, current result data and guards. Only the earlier frozen R6 README differs from H; all other tracked bytes, HEAD/index and R6 postimage remain unchanged. No native mutation, staging, installation or test-suite run occurred. Root must display/select the ordered decision before any R7 repair.

## Implemented repair and focused validation

Selected S98 is implemented only in `.github/workflows/lint-markdown.mjs` at H `f77a58dede8f6f68b45e0d62e5b96e2fed477c58` / Bf168. Invalid/missing exact-string declarations now identify root package.json engines.node and the exact-version format. Valid-version mismatches retain the original required/observed message. Manifest read, JSON extraction, containment/size/type guards, child invocation and status handling are unchanged. No metadata applies to this JavaScript edit.

Postimage SHA256 `2936daa02f279b8701c9671e3ec610729e3fd09feb9235c26f763e0df65139bf`, 3231 bytes, mode100644. Patch SHA256 `b0eee3840bcb4ed5a97dc795ae893fc09a79792c594a5a204179727a25d66662`. Exact reversal of the two-branch replacement reconstructs the complete preimage. All76 tracked bytes checked; R7 changes only this file relative to the frozen R6 state. Combined root write set is exactly this file plus scripts-README.md; R6 remains SHA256 e782b1a213003ca19f4ece0ccb992f0343eaaec9f89dcc6255b376741dc20881. HEAD/raw index unchanged.

Pinned Windows Node24.18.1:11 existing named actual root-manifest boundary tests pass, zero failures/skips. Nine private manifest cases pass through both actual API and exact-byte copied CLI (18 calls): eight rejected inputs never execute the benign child, CLI exits2; exact-version input executes and returns0. Field diagnostics name file/field/remedy; missing-file ENOENT and valid mismatch evidence remain intact. The original nine-case pre-repair log remains in the parent finding directory for comparison. No new repository tests, install, dependency edit, full suite or aggregate. See exact command/environment/timestamp records.

Named-test log SHA256 `57cf2f7f435afe3ffa7b4aa63dec7102a0533b14248928d7705d749b06c72cf6`. API/CLI log SHA256 `c1606fb8498b3240153f94d396f9c49792f3f9fd01ed331d1bb766e72dbe2f94`. The first wrapper's console printing failed after it saved successful native results; FIXTURE-NOTE.md records the bounded issue. The saved native result was read without replaying tests. No product fix was made for that collector failure.

Root owns combined staging, one final aggregate, normal commit/native review/acceptance. R9 retains canonical H-inline98; no guard refactor. Prospective TF carry-back now has six paths under A21/A07, with no TF write/counter release here. Author writes are complete; do not change this frozen candidate without new release.

Final evidence SHA256 `bbaff32ba6ad1b904c52f820592b3d249bcf8e1997cb8a3916e0506d1ecb1239`.
