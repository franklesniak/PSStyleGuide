<!-- markdownlint-disable MD013 -->
# What was completed, and what remains unproved

The user's estimate of 210–240 completed tasks is consistent with a saved list of **230 completed IDs**. It is not evidence that all those original contracts were fully satisfied. The restoration review used a stricter original-contract standard and verified 26 historical leaves. It did not establish that the other 376 were untouched.

| Measure | Count | Interpretation |
| --- | ---: | --- |
| Original numbered plan | 402 | Stable historical IDs |
| Amended resume completed list | 230 | IDs 1–220 plus 223, 226, 233, 261, 288, 306, 324, 352, 379, 402 |
| Conservative verified historical leaves | 26 | Specific historical review/quality/merge instances |
| RETAIN in original-contract audit | 376 | 204 previously claimed complete plus 172 not in that list |
| Literal task IDs 210–240 | 31 | Only 14 were marked complete: 210–220, 223, 226, 233 |

The count/ID distinction matters: “about 230 tasks completed” does not mean “Tasks 210 through 240 completed.” The original 376-retained plan preserved uncertainty, but its execution instructions risked treating uncertainty as missing implementation. This plan fixes that interpretation.

## Evidence preserved with this plan

[historical-completion-counts.json](evidence/historical-completion-counts.json) preserves both ID sets and source hashes. [historical-map.json](historical-map.json) preserves each old audit status, its exact reason, established historical identities and native evidence URLs. Each original contract has its own file. The original [August source](../action-items-2026-08-30.md) remains unchanged with raw SHA-256 `03e755a9c1035712cc46a1231fdb22cb3a6b0512a5de145c696597a37c90a416`.

The source records used were the local restoration `compact-state-before-restoration.json`, `completion-audit.json` and original task extraction, plus native GitHub PR/issue reads. Durable extracts here avoid requiring those pre-existing untracked audit directories or TEMP reports after a clone. This review reused the detailed restoration audit; it did not independently rerun all 402 original acceptance procedures or all historical CI jobs.

## Verified historical credits

| Original IDs | Native PR |
| --- | --- |
| 83–85 | [PS #198](https://github.com/franklesniak/PSStyleGuide/pull/198) |
| 92–94 | [PS #199](https://github.com/franklesniak/PSStyleGuide/pull/199) |
| 101–103 | [PS #200](https://github.com/franklesniak/PSStyleGuide/pull/200) |
| 110–112 | [TF #49](https://github.com/franklesniak/TerraformStyleGuide/pull/49) |
| 120–121 | [PS #202](https://github.com/franklesniak/PSStyleGuide/pull/202) |
| 131–132 | [PS #203](https://github.com/franklesniak/PSStyleGuide/pull/203) |
| 140–141 | [TF #53](https://github.com/franklesniak/TerraformStyleGuide/pull/53) |
| 148–150 | [PS #205](https://github.com/franklesniak/PSStyleGuide/pull/205) |
| 159–160 | [PS #206](https://github.com/franklesniak/PSStyleGuide/pull/206) |
| 167–169 | [TF #57](https://github.com/franklesniak/TerraformStyleGuide/pull/57) |

The earlier audit also corroborates a later TF #55 instance for Tasks139–141. Preserve instance identity: an old clean review or successful merge cannot authorize a changed candidate. Conversely, an accepted merge must not be repeated merely because the old plan retained its ID.

## Useful deliveries outside the 26-leaf count

| Requirement family | Reusable native evidence | Remaining distinction |
| --- | --- | --- |
| Setup/failure handling | [PS #212 acceptance](https://github.com/franklesniak/PSStyleGuide/pull/212#issuecomment-5921781405), [TF #62](https://github.com/franklesniak/TerraformStyleGuide/pull/62#issuecomment-5934618037) | Actual repairs, not proof of all historical convergence cycles |
| Contributor-owned artifact publication | [PS #221](https://github.com/franklesniak/PSStyleGuide/pull/221#issuecomment-5936332228), [TF #63](https://github.com/franklesniak/TerraformStyleGuide/pull/63#issuecomment-5936949538) | Automatic writer superseded, not implemented; merits reviewed separately |
| Visible PS blank-line examples | [PS #222](https://github.com/franklesniak/PSStyleGuide/pull/222#issuecomment-5939563496) | Reuse current accepted behavior; inspect any actual original residual |
| TF state-version discovery/retrieval | [TF #64](https://github.com/franklesniak/TerraformStyleGuide/pull/64#issuecomment-5941926849) | Seven surfaces do not complete destructive/manual scope in TF #25 |
| Dependency remediation | [PS #219/#220 acceptance](https://github.com/franklesniak/PSStyleGuide/pull/220#issuecomment-5925589817), TF #62 | Preserve PS #219's initial failed-service result and current risk decisions |
| Bounded preflight | [PS #223](https://github.com/franklesniak/PSStyleGuide/pull/223#issuecomment-5942762335), [TF #65](https://github.com/franklesniak/TerraformStyleGuide/pull/65#issuecomment-5943280033) | Ordinary retry duration still has PS #213 follow-up; preflight is not malicious-code isolation |
| Filesystem residual assessment | [PS #155 decisions](https://github.com/franklesniak/PSStyleGuide/issues/155#issuecomment-5943334454) | Open residual, not a repaired race; closed-not-planned PS #156 is not completion |

The independent audit read the native PS #223 and TF #65 acceptance comments, which identify landed inputs and recorded passing tests. It did not rerun them. Current input changes invalidate only affected evidence; they do not erase the historical facts.

## How to use the retained tasks

Some review leaves (119, 130, 139, 158) were retained despite corroborated clean exact-head review outcomes because historical fresh `gpt-5.6-sol/xhigh` dispatch metadata could not be proved. Mark that metadata unverified. Do not spend a new product-review loop trying to recreate an unexposed historical setting. A new candidate still receives current required reviews.

Some old merge leaves were retained because a complete original stage package was not established, while native merged PRs exist. Verify the native object and exact result; do not create a second issue, commencement comment, PR or merge solely to satisfy administrative separation. Keep raw failed/substitute review results honest rather than relabeling them clean.

Each current outcome must disposition its original requirements: satisfied on current inputs, historically executed but needing current validation, replaced by a justified current control, deliberately retired with a merits decision, conditional with no trigger, remaining gap, or unverified. Keep those labels separate. A00 initializes that reconciliation; each owner updates its actual result; A19 checks complete coverage. Generic audit uncertainty alone is not a bug.

Old date-based choices also require care. Do not backdate a new fallback to August22, and do not silently extend the original October29 risk-expiry decision. Assess the live dependency state and obtain any actual owner decision required by its current risk.
