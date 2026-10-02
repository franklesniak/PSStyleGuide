<!-- markdownlint-disable MD013 -->
# Were the retired systems unnecessary paperwork?

**Some retirements are justified; others replaced real safeguards and need explicit gap review.** A merged removal, a large deletion or a passing test count is not sufficient evidence that the old benefit was negligible. This assessment checks actual consumers, failures prevented, surviving controls and maintenance cost. It does not certify full equivalence of every removed test.

The independent audit inspected PS native main `48f4d8a36c8faceee12afac78aaecea0d176125d`, the source/diffs at PR218 retirement commit `70ad16235efe68aab2f35e28f7fffe3bf539fc28` and PR221 retirement commit `375c7ba634270f0be7b77654af01c95a1cc3a0c2`, their parents, and native TF63 files/current tree `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. No product tests were rerun in this planning audit.

## Findings at a glance

| System | Merits judgment | Useful outcome that must remain | Owner |
| --- | --- | --- | --- |
| Mandatory PR-body identity rewriting | Justified removal of duplicate identity storage | Exact review-input identity and accurate PR scope | A00/A08 |
| Exact source/version/presentation profiles | Justified removal of brittle coupling; full semantic replacement not proved | Security behavior, accepted inputs and meaningful negative tests | A03 |
| Per-repair exact-byte trust-root admission | Partially justified replacement; former protection was substantive | Real authorization boundary and independent enforcement assessment | A03/A12/A13 |
| Global current-base sweep | Plausible excess machinery; freshness remains essential | Current head/base readiness and truthful enforcement limits | A03/A12 |
| Mandatory historical supply reproduction | Justified as optional diagnostics | Current lock/runtime/parser integrity | A07/A09 |
| Dormant archive/context framework and future writer | Justified for current no-promotion-consumer architecture | Source/generated integrity and read-only committed-byte publication | A06 |
| Deleted or relocated runtime tests | Mixed; blanket equivalence unproved | Reachable failure-oracle coverage | A03/A04/A06/A07 |

Scores below use 1–5, with 5 strongest; total is `sum(weight*score)/5`. Each finding has its own rubric. A hard security or supported-use requirement cannot be waived by a higher total. The selected actions are planning dispositions: they preserve required outcomes and assign actual gaps, not declare the old contracts implemented.

## R01: Mandatory PR-body identity duplication

**Validation.** The old PR-target workflow watched opened/edited/reopened/synchronize events and wrote a head/tree/contract block through `Sync-PullRequestBodyIdentity.mjs`. Git/GitHub already provide the underlying immutable identities. Automatic prose synchronization adds a second mutable identity surface, including stale-block/consumer-bridge handling. PR218 removed 2,166 writer lines, 621 workflow lines and 352 case-catalog lines. These counts establish maintained surface, not measured money saved.

**Stakeholders.** Authors; reviewers; owner; maintainers; remote reviewer services; CI operators; incident investigators; release integrators; downstream consumers; future agents reading PR prose; cost owner.

**Options.** A: restore the exact automated block and writer. B: require a manually synchronized block. C: bind reviews to native head/scope and keep concise accurate PR prose. D: remove both prose and exact-input binding. Making the block optional for a useful human explanation is compatible with C; it must not become another mandatory state machine.

**Rubric.** Review-input correctness 40% (cannot review/merge the wrong bytes); mutation reliability 25% (avoid self-triggering/stale prose); reviewer clarity 20% (concrete scope); ongoing burden 10%; migration churn 5%.

| Option | Input | Reliability | Clarity | Burden | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 4 | 2 | 3 | 1 | 1 | 57 |
| B | 3 | 2 | 3 | 3 | 3 | 55 |
| C | 5 | 5 | 5 | 5 | 4 | 99 |
| D | 1 | 5 | 1 | 5 | 5 | 52 |

**Selected action.** Use C. Keep the writer retired. Bind each review to its actual head and material scope. Check the PR description before review. Fix factual prose when needed. Do not copy live orchestration state into the PR body. A00/A08 must preserve the exact-input property without restoring duplicate storage.

## R02: Exact semantic source and release-label profiles

**Validation.** The old validator pinned exact version strings, contract hashes, invocation profiles, script versions and copied reference source. Some checks described security properties; others rejected harmless comments, CRLF, whitespace, quoting or scheduling changes. Current behavior tests accept those harmless changes while checking specific contracts. PR218 removed thousands of copied-reference lines and added behavior tests. This proves a changed method, not exhaustive oracle equivalence.

**Stakeholders.** Workflow and helper authors; test maintainers; security reviewers; dependency maintainers; maintainers integrating updates; new contributors; CI operators; Windows/Linux users; release consumers; owner and cost operator.

**Options.** A: restore all byte/version profiles. B: remove validation. C: use tested behavioral contracts plus narrow structural checks for real boundaries, and map old threats to surviving tests. D: keep only an unexplained subset of old hashes. A hybrid belongs to C only when each retained exact constraint has a concrete threat/use reason.

**Rubric.** Security-contract coverage 38%; meaningful regression detection 27%; tolerance of harmless edits 20%; maintainability 10%; migration effort 5%.

| Option | Security | Regression | Tolerance | Maintainability | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 4 | 3 | 1 | 1 | 1 | 53.6 |
| B | 1 | 1 | 5 | 5 | 5 | 48 |
| C | 5 | 5 | 5 | 4 | 3 | 96 |
| D | 3 | 2 | 2 | 2 | 3 | 48.6 |

**Selected action.** Use C. Keep presentation-only coupling retired. Keep exact checks where identity or authority requires them. In A03, map each material former threat to a current test and actual caller. Repair uncovered behavior. Do not restore thousands of fixtures only to reproduce an old test count.

## R03: Exact-byte maintenance admission

**Validation.** `Test-TrustRootAuthorization.ps1` and its manifest prevented a candidate from granting itself maintenance authority. PR217 exercised a real prerequisite for an exact supported family. Current accepted-base code fetches the candidate as data and checks ordinary changes. However, `agent-instructions.yml` emits `MAINTENANCE_REQUIRED` and exits successfully for maintenance classification. It says that authorization/review is required; it does not machine-enforce that approval. Candidate tests do not supply the lost authorization guarantee. PR218 removed an 8,742-line authorizer and a 269-line manifest. That cost is material, but the former safety benefit was not negligible.

**Stakeholders.** Security authority/owner; maintainers with write and bypass rights; trust-root/workflow authors; independent reviewers; branch-protection administrators; CI service operators; untrusted contributors; supply-chain consumers; incident responders; auditors; cost owner.

**Options.** A: restore the full old authorizer/manifest. B: call classification success equivalent to approval. C: retain accepted-base/data separation and select a small enforceable maintenance gate or appropriate native protection after a current threat/settings assessment. D: rely on owner/peer procedure only, with explicit residual-risk acceptance. C may combine native controls and a small gate; which combination is useful depends on actual required-check sources and bypasses. D is a possible owner choice, not an automatic consequence of cleanup.

**Rubric.** Authorization integrity 45%; honest failure behavior 25%; legitimate maintenance usability 15%; control ownership/operability 10%; implementation burden 5%. A passing classification cannot satisfy the authorization criterion by assertion.

| Option | Authorization | Failure truth | Usability | Operability | Burden | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 4 | 4 | 1 | 2 | 1 | 64 |
| B | 1 | 1 | 5 | 3 | 5 | 40 |
| C | 5 | 5 | 4 | 4 | 3 | 93 |
| D | 2 | 4 | 5 | 4 | 5 | 66 |

**Selected action.** Use C as the required assessment and repair path. Do not claim approval from `maintenance_required`. A03 must test the real boundary. A12 must inspect native check sources and bypasses. Prepare the smallest sufficient change. Apply a settings delta only through A13 with actual authority. If the owner selects D, record the remaining enforcement limit. Do not call that limit negligible paperwork or complete this outcome while its material disposition is missing.

## R04: Global current-base status sweeps

**Validation.** The deleted helper maintained continuation/bootstrap dispatch, native PR/workflow/status reads and pending state. Current full SHA acquisition does not automatically rerun every open PR when main moves. Thus freshness remains a real requirement. The old helper/workflow had 4,142 + 87 lines. An archived five-day census reported 226 related runs but only about 25 summed job-minutes. The main alleged cost was coordination and maintenance, not large compute expenditure; this audit did not reproduce the census.

**Stakeholders.** Concurrent authors; reviewers; merge/release maintainers; CI schedulers; protection administrators; downstream users; security engineers; restart operators; owner; cost operator.

**Options.** A: restore the global sweep. B: remove freshness checks. C: check current head/base before review acceptance and merge, rerun affected validation, and assess native strict protection separately. D: rerun every test/review on every unrelated main change. Native strict checks can reinforce C but do not replace inspection of their actual source and bypass rules.

**Rubric.** Fresh-input correctness 42%; stale-result detection 28%; concurrent-work usability 15%; resume reliability 10%; operational cost 5%.

| Option | Freshness | Detection | Usability | Resume | Cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 4 | 4 | 2 | 2 | 2 | 68 |
| B | 1 | 1 | 5 | 5 | 5 | 44 |
| C | 5 | 5 | 4 | 5 | 4 | 96 |
| D | 5 | 5 | 1 | 3 | 1 | 80 |

**Selected action.** Use C. Keep targeted final readiness mandatory. If a relevant base input changes, repeat the affected checks and review. Do not claim that an agent's readiness check is platform enforcement. A03/A12 must decide whether a native control adds sufficient benefit. Do not restore the global sweep merely to achieve a status count.

## R05: Historical supply reproduction as routine admission

**Validation.** Current setup still uses reviewed runtime checksums, fixed runtime/configuration, `npm ci --ignore-scripts`, unchanged manifest/lock checks and parser integrity checks before import. The historical digest recorder and profile remain available as optional diagnostics. Reproducing an obsolete full installation/audit snapshot is not the same duty as verifying today's locked supplies. The archived recorder count (6,556 lines) is a maintenance observation, not proof all integrity checks are overhead.

**Stakeholders.** Dependency and build maintainers; incident/reproducibility investigators; security and supply-chain teams; runtime/tool vendors; CI operators; contributors installing tools; auditors; downstream consumers; cost owner.

**Options.** A: require historical reproduction for every ordinary change. B: remove all supply verification. C: enforce current lock/runtime/parser integrity and retain optional historical diagnosis. D: retain only historical hashes without current installation checks. A bounded incident investigation may invoke the historical diagnostic under C.

**Rubric.** Current supply integrity 44%; diagnostic usefulness 21%; usable updates 20%; ongoing cost 10%; migration effort 5%.

| Option | Integrity | Diagnosis | Updates | Cost | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 4 | 5 | 1 | 1 | 3 | 65.2 |
| B | 1 | 1 | 5 | 5 | 5 | 48 |
| C | 5 | 5 | 5 | 4 | 4 | 97 |
| D | 2 | 3 | 2 | 3 | 4 | 48.2 |

**Selected action.** Use C. Keep the current supply checks. Keep historical reproduction optional. Preserve historical facts and their actual provenance. A07/A09 must test any changed active check and record legitimate history differences without inventing new identical history.

## R06: Dormant archive promotion and automatic writer

**Validation.** Before PR221, tracked caller searches outside planning found extractor/context references only in those scripts and their harness. The extractor had real digest, ZIP traversal, manifest, size and ordinary-file protections. No production archive-promotion consumer was established. The current build verifies generated committed output and uploads four committed files in a separate read-only job bound to `github.sha`; it neither extracts candidate archives nor auto-commits them. Removing the cluster drops a possible future automatic-promotion capability, not an active safeguard of that current publication path.

PS221 removed 4,579 extractor, 3,473 context, 22,280 harness and 79,664 catalog lines. TF63 removed analogous code and large fixtures. Most volume is tests/data; volume alone does not decide value. A future real promotion consumer would change this judgment.

**Stakeholders.** Guide authors; generated-artifact users; maintainers; workflow/security developers; archive/path handling specialists; CI publishers; Windows/Linux users; incident responders; future automatic-publication users; owner; cost operator.

**Options.** A: restore the full future writer framework now. B: keep it retired and validate contributor-owned generation plus committed-byte publication. C: delete all generation/publication validation. D: implement a smaller automatic writer now. D is only justified by a current useful automation requirement; no such consumer was established here. Preserve historical design evidence for future evaluation without preserving dormant production code.

**Rubric.** Supported current publication integrity 43%; live-consumer fit 27%; security surface reduction 15%; author usability 10%; migration effort 5%.

| Option | Integrity | Consumer fit | Surface | Usability | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 4 | 1 | 1 | 2 | 1 | 47.8 |
| B | 5 | 5 | 5 | 4 | 4 | 97 |
| C | 1 | 3 | 5 | 2 | 5 | 48.8 |
| D | 4 | 2 | 3 | 4 | 1 | 63.2 |

**Selected action.** Use B for the supported current architecture. Keep the dormant cluster retired. A06 must verify source/generated bytes, ordinary caller failure and committed-byte publication. Record the automatic writer as superseded, not implemented. Reassess it only for a concrete consumer and useful benefit. Keep PS155's live filesystem limits explicit.

## R07: Removed and relocated runtime tests

**Validation.** Current suites exercise native failed/empty/multiline/wrong identity, digest-before-extraction, npm environment exclusion, bounded acquisition, parser tampering, permissions, credential handling and artifact side effects. PR212 repaired real defects in the simplified callers after PR218. This supports retained useful coverage; it does not establish a complete mapping for all removed security semantics. Obsolete profile/writer tests can disappear with their consumers. Reachable runtime-failure tests are not paperwork as a class.

**Stakeholders.** Test engineers; runtime/toolchain maintainers; security reviewers; contributors; CI operators; Windows/Linux and supported-edition users; incident responders; artifact consumers; reviewers of future changes; owner and cost operator.

**Options.** A: restore every old fixture. B: assume the new passing count proves equivalence. C: map supported threats/behaviors to actual callers and surviving tests, adding only uncovered material oracles. D: remove negative testing and rely on normal CI. Selective reuse of a sound old fixture is part of C; acceptance does not require its former schema or count.

**Rubric.** Reachable failure coverage 41%; test validity 29%; diagnostic clarity 15%; maintainability 10%; execution cost 5%.

| Option | Coverage | Validity | Clarity | Maintainability | Cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 4 | 2 | 2 | 1 | 1 | 53.4 |
| B | 2 | 1 | 2 | 4 | 5 | 41.2 |
| C | 5 | 5 | 5 | 4 | 4 | 97 |
| D | 1 | 1 | 3 | 5 | 5 | 38 |

**Selected action.** Use C. Build one focused coverage map in each affected outcome result. Reuse unchanged sound tests. Add a regression only for an actual useful boundary. Do not claim complete equivalence until that map is checked. Do not repeat a harmless formatting-only test on every review round.

## Primary implementation evidence

- [PS218 diff](https://github.com/franklesniak/PSStyleGuide/pull/218/files), [PS221 diff](https://github.com/franklesniak/PSStyleGuide/pull/221/files), [TF63 diff](https://github.com/franklesniak/TerraformStyleGuide/pull/63/files).
- [Accepted-policy workflow](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/workflows/agent-instructions.yml) and [maintenance classifier](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/workflows/Classify-InstructionMaintenance.mjs).
- [Behavior validator](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/workflows/Validate-WorkflowPolicy.mjs), [validator tests](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/workflows/Validate-WorkflowPolicy.test.mjs), and [actual-caller tests](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/workflows/Test-CiHelpers.test.mjs).
- [Current initializer](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/workflows/Initialize-CiToolchain.ps1), [build/publisher](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/workflows/build.yml), and [artifact verifier](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/workflows/Test-StyleGuideArtifacts.ps1).
- [PS217](https://github.com/franklesniak/PSStyleGuide/pull/217) was a genuine compatibility prerequisite under the former admission architecture; it became obsolete after that architecture changed. [PS212](https://github.com/franklesniak/PSStyleGuide/pull/212) repaired real runtime failures after cleanup. Neither should be dismissed as merely historical paperwork.

The final plan must retain this distinction: fewer records can be better, but less enforcement must be measured and decided honestly. A03/A12 own the material control losses; A03/A06/A07 own unproved behavior coverage. No unproved loss is approved by this document's score alone.
