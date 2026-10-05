<!-- markdownlint-disable MD013 -->
# R17 — document the authority selector return domain

## 1. Validated finding and prior decision

Comment4179947014 identifies a small API documentation opportunity. `hostedAuthorityReference` at236–238 is exported without JSDoc. It returns a full commit SHA for main push/schedule/manual events and main-target PR base; it returns the literal `refs/heads/main` for supported non-main push/tag/PR contexts. Repository census finds only test callers. No external caller or current production misuse was demonstrated.

[R7](../A03/TF66-R7-disposition.md) and [D7 M98](../A03/hosted-audit-decision.md) correctly rejected changing selector/acquisition responsibilities. R17's minimal documentation alternative is narrower and compatible with those choices. The real audit path uses `readHostedContext` and `readAcceptedBase`; remote-main is acquired and pinned before exception reading. The exported helper does not perform fetch/resolution or all downstream hosted/Git checks. That no-fetch conclusion comes from the inspected call boundary, not measured network telemetry; Linux additionally ran network-disabled.

Seven positive selector cases (main push, topic push, tag named main, main schedule, main manual, main-target PR, topic-target PR) plus two invalid-context cases passed on both platforms using the actual export. No new audit or registry operation ran.

Input: TF H `dde2b9abe761af69a7f561512df7d44d0dec6745`, tree `d59a740b7b1d88f7986075ac9328d9998629aa71`, B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. Full authenticated comments are in `review-comments.json`; ten immutable raw source blobs/modes/hashes are in `source-identities.json`. Windows/Linux probe code, commands and observations are in `probe.mjs`, `windows/result.json`, `linux/result.json` and `linux-run.json`. No product edit, dependency installation, full suite or aggregate was performed. Scores are judgments, not measured reliability.

## 2. Stakeholders

API/test maintainers and future contributors need the return type visible at the export. Audit/security reviewers and risk owners need selection clearly separated from immutable authority acquisition. CI operators need unchanged main/non-main behavior. QA needs retained selector tests and native failure behavior. Reviewers and history custodians need this clarification linked to M98 rather than a second authority redesign. There is no new deployment, credential, personal-data, recovery or accessibility interface; readable comments serve new maintainers without changing user diagnostics.

## 3. Options

N keeps code/comments unchanged. J adds precise JSDoc describing both return forms, event conditions, and no-fetch boundary. R renames the export, possibly retaining an alias. O returns a discriminated object, reusing the existing context shape where useful. S splits exact-SHA and remote-ref accessors. F resolves/fetches before returning. X removes the export and tests only larger APIs. J may link the existing responsibility in prose; J+rename/object is R/O with documentation, not another independent benefit. An alias preserves compatibility but still introduces two names. No option may treat the returned ref as already resolved accepted authority.

## 4. Unique rubric

Scores0–5 mean:0 fails the objective;1 very weak;2 substantial limitations;3 useful but limited;4 strong with a stated residual;5 satisfies the criterion on the inspected design/evidence. Total=sum(weight×score)/5. Hard constraints override totals. Churn/effort are not reasons to reject a correct useful change.

Behavior35 preserves every event selection and rejection. Self-description25 makes the SHA/ref union and conditions evident beside the function. Authority clarity20 prevents confusion between a selector and a resolved accepted commit. Compatibility10 retains existing export/name/string consumers. Proof7 permits direct semantic verification without irrelevant tests. Maintenance3 limits duplicate APIs and ongoing documentation.

Hard constraints: preserve M98 authority/freshness roles; no added network operation, candidate authority, alternate repository, export-shape change without a demonstrated need, or weakening of downstream checks. Existing code is not a current admission bypass.

## 5. Scores before selection

| Option | Behavior 35 | Self-description 25 | Authority clarity 20 | Compatibility 10 | Proof 7 | Maintenance 3 | Total | Evidence/tradeoff |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 5 | 3 | 5 | 5 | 5 | 5 | 90 | No misuse found, but the export lacks a local return-domain contract. |
| J | 5 | 5 | 5 | 5 | 5 | 4 | 99.4 | Precise JSDoc explains existing roles without changing the union or callers. |
| R | 5 | 4 | 5 | 3 | 4 | 3 | 88.4 | Renaming can help but creates migration/alias work for an unchanged value. |
| O | 5 | 5 | 5 | 2 | 4 | 3 | 91.4 | Discriminated object is clear but breaks current string consumers unnecessarily. |
| S | 4 | 5 | 5 | 2 | 3 | 2 | 82.4 | Two accessors duplicate event dispatch and need inapplicable-case semantics. |
| F | 2 | 4 | 2 | 1 | 3 | 2 | 49.4 | Ineligible: selection becomes acquisition and changes the authority timing/network contract. |
| X | 5 | 2 | 4 | 1 | 3 | 3 | 69 | Removing the test seam sacrifices useful direct coverage without documenting the distinction. |

Recommend J99.4. The gain is explicit local API meaning, not repair of a demonstrated broken caller. A structured result can be sound, but changes consumers for information already expressible in a short comment. The existing name says Reference, which is better than SHA, yet it does not document event-specific union members.

## 6. Selected controlled-English steps

Add JSDoc immediately above `hostedAuthorityReference`. Describe the helper as a selector. State that it returns a full event-main SHA or literal `refs/heads/main`. State when each form applies. State that it does not fetch or resolve the reference. Identify the production acquisition boundary. Keep the function body and export unchanged. Do not claim that this helper performs all hosted-context or ref-format validation.

Scope: `.github/workflows/Check-NpmAudit.mjs`, comment only. No guide or governed metadata changes are required. The instructions follow the owner's controlled-English intent; no formal dictionary certification is claimed.

## 7. Verification and implementation gate

After root selection, prove executable tokens/function bytes and exports unchanged, and inspect documentation against all nine observed cases. No durable test is justified for this comment-only edit; reuse existing meaningful selector tests and actual probe results. Any required repository checks belong to the later frozen combined candidate. Source/caller census and M98 are the primary contract evidence. The diagnostic phase preceded implementation. Current implementation state is recorded below.

## Coordinator selection and evidence

Root selected J (99.4/100) at 2026-10-05T00:50:37.233582+00:00, after displaying the alternatives, finding-specific rubric, complete score table and controlled-English steps in that order. The authorized author is implementing only the selected private repair. No product integration, new remote request or acceptance has occurred. No additional owner decision is needed.

Root read all four proposals, checked all23 new weighted totals, sampled four raw source blobs against native H, and read the complete Windows/Linux probe results and probe code. The frozen diagnostic guard covers the unchanged78 tracked files, index and1910 dependency files. The nine selector controls passed on both platforms. Actual staged execution recorded two scans before the selected repair; these are synthetic timing samples, not production benchmarks.

Private commands and full outputs are located by [STATUS](../../STATUS.md), under `TF-coherent-20261004/implementation/round5-review-findings`. Windows used pinned Node24.18.1 with `probe.mjs`; Linux used `run-linux.py` with its exact recorded Docker image, arguments and network-disabled run. No full aggregate was repeated for the diagnosis.

| Diagnostic evidence | SHA256 |
| --- | --- |
| `HANDOFF.md` | `0bf764e89a1b02aa93fc41172df3221a41de572226e51c9a1f78daafbc29e701` |
| `evidence-catalog.json` | `f08f72e90776f16ab015e628d987aec219f264364b6c0b0bea7ced21a3c8b2e5` |
| `final-source-guard.json` | `6e695acbb4820fb7e661972869b79aa8019e8cf015252f2e4d020d6cb884f5ef` |
| `windows/result.json` | `1a0477bc77a6fbd664794cfcda7ac0e36a2ccf08dbe5bb7c245fb459da27b55b` |
| `linux/result.json` | `23cc455b29f420d268b775e8e268fc7474b896b03858898d4cf4ff6ab9f6c87b` |

[Canonical peer lifecycle](../A02/coherent-peer-candidate.json) records implementation, tests, native dispositions, review rounds and acceptance separately.

[JSDoc return documentation](https://jsdoc.app/tags-returns) supports a return type and explanatory description; the actual selector cases and production caller determine this function's contract.
