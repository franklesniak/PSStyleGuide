<!-- markdownlint-disable MD013 -->
# A07 finding: replacement CLI pulls affected js-yaml

This is the single pre-edit decision for the newly reproduced GHSA-r3ph-w7gj-g6xm. No corresponding dependency edit has occurred. The separate braces decision is reassessed in [the canonical braces decision](review-braces-decision.md#current-d-reassessment-and-implementation-contract). Ordinary scoped implementation authority is distinct from coordinator writer placement; no risk grant or check bypass is proposed.

## 1. Validate

The first actual unchanged Check-NpmAudit invocation on the installed K candidate returned FINDINGS/native1 (current-audit.log). Both installed roots were checked against accepted48f authority and empty candidate/accepted exceptions. The workflow lock contains markdownlint-cli0.49.1 -> node_modules/markdownlint-cli/node_modules/js-yaml5.2.3. Two package summaries share one advisory; the root graph is clean and the braces chain is absent. This is a new real finding, not a tool error or retry.

[The primary advisory](https://github.com/advisories/GHSA-r3ph-w7gj-g6xm) marks js-yaml>=5.0.0<=5.4.0 affected and5.4.1 patched. Empty merge-source mappings can consume CPU without using the merge-key budget. Current registry metadata confirms5.4.1 and latest5.4.2. [The pinned maintainer changelog](https://github.com/nodeca/js-yaml/blob/494400bd45cad078123cfc057e674a9a0a8d9983/CHANGELOG.md) identifies the5.4.1 merge-budget repair and5.4.2 forceQuotes dumper correction. No exploit was run.

CLI0.49.1 requires~5.2.1, so ordinary resolution cannot select5.4.x. The CLI uses only js-yaml.load(text);5.3/5.4 AST/custom-tag/sortKeys changes are real but do not match this caller. The selected repository surface is JSONC/JSON; alternate YAML/config/ambient selectors are refused before the CLI. That limits current exposure but does not waive the info-threshold audit. A patched parent override is technically possible; it is not a risk exception. There is no current compatible newer official CLI release in the saved registry metadata.

## 2. Relevant stakeholders

- Repository owner and maintainers: remove the new affected dependency without losing required lint or altering risk authority.
- Documentation authors and Windows/Linux/GUI contributors: retain exact staged contents, nested checks, declared runtime, configured rules and useful errors.
- A07/A03/A21 and coordinator: preserve ownership, frozen c68, held paths, normal delivery and the exact PR224 new-base initializer reassessment.
- CI/platform, supply-chain/security and dependency maintainers: retain bounded children, honest graph/audit evidence, maintained provenance and patch compatibility.
- Independent reviewers and history/audit custodians: preserve native failure and distinguish static source proof from executed tests.
- Schedule/cost stakeholders: prefer a real bounded repair over a security fork, repeated unchanged probes or unnecessary interface maintenance.

No deployment, destructive recovery, personal-data collection or privacy/storage interface changes are proposed. Accessibility remains readable diagnostics; no new localization interface is introduced.

## 3. Material options

| ID | Option | Concrete benefit/limit |
| --- | --- | --- |
| A | Keep K unchanged and its red check | No behavior churn; no repair. |
| B | Upgrade to a compatible official CLI release with fixed range | Preferable if published; none is available now. |
| C | Exact CLI0.49.1 parent-scoped js-yaml5.4.1 override | Published direct security repair; preserves CLI but adds override and minor-change tests. |
| D | Exact CLI0.49.1 parent-scoped js-yaml5.4.2 override | Same security repair plus current maintained patch; same caller compatibility burden. |
| E | Remove the unused full-file CLI consumer and reuse the implemented named-string API in the existing bounded --outer child | Removes affected5.x YAML and CLI/run-con graph; retains base rules, safe discovery, staged/nested APIs and0/1/2. Must prove full caller parity and retain execution bounds. |
| F | Global js-yaml override or downgrade4.x | Alters unrelated consumers or schema/default behavior; needless wider compatibility risk. |
| G | Scoped temporary exception | Needs real owner risk/admission authority, unavailable here; no repair. |
| H | Defer admission until upstream updates | Truthful hold, unknown delay, affected graph retained. |

E resolves this finding together with the reassessed braces D path. C/D are valid fallback repair designs if a real required CLI-only consumer emerges. No mix needs an exception when a compatible published fix/removal succeeds. Removing required lint or bypassing audit is excluded by hard constraints.

## 4. Fresh rubric

Scores1–5:1 fails/unsupported,2 weak,3 useful with substantial residual,4 strong with bounded verification remaining,5 meets the objective on present design evidence. These are judgments, not measured tests. Weighted total=sum(weight*score/5).

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Actual security resolution | 40 | Remove affected consumer or use published repair, without audit silence/authority manipulation. |
| Required caller fidelity | 25 | Rules/config, exact index, hidden/MDC/nested/path and diagnostic contracts stay intact. |
| Verifiable compatibility/provenance | 20 | Immutable package/source and meaningful actual child/API tests support acceptance. |
| Sustainable dependency maintenance | 10 | Avoid unnecessary parsers, overrides, forks and duplicate paths. |
| Delivery cost | 5 | Bound scoped implementation and validation, below correctness/safety. |

Hard constraints: no weakening info-threshold/exception/credential/input/bounds policy; no dropped applicable check or config; no fabricated CLEAN; no risk inference; no held/protected path or unrelated frozen patch. Bound the full outer child using existing runBounded; API reuse must not turn a bounded child into unbounded in-process work. Tests/normal gates remain pending and cannot be replaced by this table.

## 5. Scores before selection

| Option | Security40 | Fidelity25 | Proof20 | Maintenance10 | Cost5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 5 | 5 | 2 | 5 | 70 |
| B | 1 | 5 | 2 | 5 | 4 | 55 |
| C | 5 | 4 | 4 | 3 | 3 | 85 |
| D | 5 | 4 | 4 | 4 | 3 | 87 |
| E | 5 | 4 | 4 | 5 | 4 | 90 |
| F | 5 | 3 | 3 | 2 | 3 | 74 |
| G | 2 | 5 | 3 | 2 | 4 | 61 |
| H | 2 | 5 | 4 | 5 | 4 | 71 |

E is preferred on concrete responsibility removal, not the three-point margin over D: required current consumers already use the same API/config/safe reader, and the full-file --outer child already exists. No required YAML/CLI-only feature is lost. A published patch can repair K but would retain a consumer with no demonstrated required benefit and one more override. This provides an objective discriminator despite close totals. If a required surviving CLI feature is found, revise these same records before the corresponding edit.

## 6. Controlled selection

Select E, coordinated with braces D reassessment. Remove markdownlint-cli and its affected nested js-yaml graph. Keep direct markdown-it14.3.2 and markdownlint0.41.1. Keep the declared npm phase names. Use the existing safe reader, explicit parsed rules and named-string outer adapter in the existing --outer child. Keep the two-minute/two-MiB normal outer bound through runBounded. Keep index/nested and actual hook behavior. Preserve explicit unsupported repository-selector refusal. Do not load or refuse irrelevant ambient home/env selectors; prove they cannot suppress the API rules. Keep normal error status2 and useful native causes. Do not change audit or exception files. No dependency edit implementing this proposal has yet occurred.

## 7. Implementation/verification gate

The coordinator selected E90 before corresponding edits. Change only the released manifests/locks and the needed caller/config/tests/docs within the existing scope. No override is needed for E. Regenerate locks normally, run locked setup, compare both installed/lock graphs and actual unchanged audit. Preserve this failed native1 alongside the new result.

Retain every meaningful property from the focused controls: hidden/Unicode/spaces/MDC/literal option/metachar names, empty coverage, JSONC/fallback/rule changes, malformed/missing config, introduced selector refusal, no ambient suppression, nested MD041/MD051 distinction, real partial-index/nested/hook/rename/delete/runtime/missing-tool behavior, path/nonregular refusal. Replace CLI2/3/4-internal tests with real API throw/missing-tool and actual bounded-child nonzero/unexpected/timeout/output controls. Test harmless js-yaml public load compatibility only if C/D is selected, not as an irrelevant E gate. Run Windows/Linux focused tests and actual repo phases/audit; freeze identities, then coordinator gate before one normal aggregate. Source acceptance, reviews, merge and PR224 accepted-base reassessment remain coordinator-owned.

Coordinator verification: all eight totals match the fixed rubric. Source SHA256 cde0f5ada776999d757d7b27804c9dabf03e5d079705bcb072398d4ed7ab2a4d is retained in the frozen scratch proposal. Actual failed audit SHA256 is 1fac4ad89a47ff042798817e4c85f9bc5a7fc892a5a34c31b6201cb31f9e6882. Selection releases normal scoped implementation; it does not claim an installed D graph, passing audit or final acceptance.
