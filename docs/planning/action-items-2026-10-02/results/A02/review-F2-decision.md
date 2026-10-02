<!-- markdownlint-disable MD013 -->
# D-A02-F2: Check the date at author finalization and preserve delayed verification

**Finding:** [Codex4163722048](https://github.com/franklesniak/PSStyleGuide/pull/224#discussion_r4163722048), review5389295737, head `fe3d6738d5b331f88e21bf6b9815883b3bb353b8`, base `48f4d8a36c8faceee12afac78aaecea0d176125d`. This is the canonical F2 decision. It supersedes the A02 worker's unpublished provisional strict-now decision. Parent verification and public release precede implementation. Requested route: gpt-6-astra/high; effective settings unavailable. No product/native changes or implementation acceptance are recorded here.

## 1. Validate the actual failure and limit

The unchanged [documentation policy](https://github.com/franklesniak/PSStyleGuide/blob/fe3d6738d5b331f88e21bf6b9815883b3bb353b8/.github/instructions/docs.instructions.md) requires the UTC date at the last author- or agent-controlled update before merge, queue entry or direct push. It compares the published baseline with that finalization point. Internal commits are not separate published updates. A delayed CI rerun is not a new finalization. Mechanical exemptions and automatic target movement retain their stated treatment.

The [actual workflow](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/workflows/agent-instructions.yml) supplies exact B/H on pull_request_target opened/reopened/synchronize/edited. It supplies no finalization date. Only the ordinary branch invokes published endpoint validation; maintenance handling remains the separate F3/D1 concern. Candidate push/PR/dispatch tests, pre-commit and npm invoke -SelfTest without published endpoints. No CLI finalization-date mode exists at this head.

The real null-base helper accepts a new document dated 2020 with no date context and its strict flag false. That is missing exact-finalization-date enforcement. It is not proof that any older date on a new file is invalid. A file can be finalized on October 2, remain absent from B, and first appear in a PR on October 3. Its older date can satisfy the policy. B/H alone cannot distinguish that history from a falsely backdated file authored on October 3.

The [independent probe](independent-F2-probe.json), described in the [supporting assessment](independent-F2-assessment.md), uses exact production function definitions, with only the parser dependency root adapted. It fixes the clock to October 3 and a valid null-base document to October 2. Current published behavior passes. The proposed unconditional null-parent strict-now flag fails. Explicit October 2 context passes; incorrect October 1 context fails. All four expected outcomes passed under PowerShell 7.6.5 with the existing locked parser and Node 24.18.1. This is helper characterization, not candidate/full-workflow acceptance. GitHub confirms reruns retain original SHA/ref in its [rerun documentation](https://docs.github.com/en/actions/how-tos/manage-workflow-runs/re-run-workflows-and-jobs).

Local staged creation already differs from HEAD and receives current UTC enforcement. Tracked discovery excludes untracked paths. A clean committed HEAD comparison is not proof that the author finalized now. The existing initial-coverage/promotion nulling can also force current time without a published date context; the repair must not preserve that delayed-rerun failure merely because it occurs through bootstrap rather than new-file discovery.

## 2. Stakeholders

- Authors, new contributors and local/remote agents need one usable finalization command and must not edit correct metadata merely because CI starts late.
- Both maintainers and the owner need exact endpoint/date evidence they can interpret without a new receipt service or repeated approval ritual.
- Readers, auditors and governance consumers need a truthful freshness claim. Structural success must not masquerade as proof of the authoring date.
- Reviewers and independent-quality engineers need an actual caller and tests for both versioned and nonversioned documents, not an unused parameter or helper-only green result.
- CI/platform engineers and Windows/Linux PowerShell users need deterministic later verification, explicit failure modes, unchanged exact-base trust guards and no dependence on mutable PR timestamps.
- Security owners need candidate timestamps/header dates distinguished from authenticated clock observations. The local command trusts its operator/host clock; it does not prove remote workflow immutability.
- Project/cost owners need a small repair using existing validation output and contributor documentation. A new timestamp service, ledger or broad workflow redesign has no necessary consumer here.

No cloud credentials, recovery operation, personal-data collection, translated interface or accessibility behavior changes. Those stakeholders have no separate affected requirement. Generated-artifact consumers benefit from accurate existing metadata checks but need no new generated format.

## 3. Options before scoring

| ID | Option | Consequence |
| --- | --- | --- |
| N | No change | Keeps limited endpoint checks but leaves an ambiguous freshness claim and no supported deliberate finalization caller. |
| A | Require current UTC for every null published parent | Rejects legitimately older finalized new content and delayed identical-head reruns. |
| E | Use original synchronize/PR/run event time | Can be stable on rerun but proves an event/publication time, not necessarily the final author update. Open/reopen/edit events further differ. |
| C | Use author/committer timestamp | Stable but candidate-controlled; authenticated object identity does not authenticate its claimed date. Unrelated later commits do not prove document finalization. |
| U | Add a date parameter without an actual documented caller | Enables a helper capability but leaves the practical consumer and provenance undefined. |
| F | Fail all published checks when context is absent | Honest fail-closed status, but every current ordinary workflow call lacks the fact. Installing it alone blocks valid work without supplying an exact date. |
| L | Restrict repair to local null-parent/current-date handling | Existing staged creation already checks current UTC. Does not provide committed B/H finalization or its documented delayed-check workflow. |
| P | Add deliberate FinalizeMetadataNow and document its accepted-base B/H invocation; label no-context checks | Covers actual finalization and delayed CI. Reuse the original successful finalization evidence for identical B/H; later no-context checks retain their stated limits. |
| PR | P plus optional caller-supplied original finalization-date replay for exact B/H | Rechecks consistency with a supplied date but creates no authenticated fact. No current required caller gains a unique capability beyond P and its original evidence. |

A global helper-default change has A's semantic defect with a wider impact. A RUNBOOK-only exception does not solve the governing date rule. Candidate header as trusted time is circular and is excluded with C. E or C combined with PR would silently invent provenance and is not selected. F could be selected only with a concrete supported finalization-context producer and required-gate contract; no such automatic producer exists in the current workflow. Do not add a service or approval merely to manufacture this fact.

## 4. Fresh rubric before scoring

Scores 1–5: 1 fails; 2 has major limitations; 3 is useful but incomplete; 4 meets the requirement with a bounded limit; 5 directly meets it. Total=sum(weight*score)/5. Scores are engineering judgments, not measurements.

- **Policy/date semantics40%:** enforces actual author-finalization date where known, preserving unchanged delayed input and mechanical exemptions.
- **Provenance honesty25%:** distinguishes trusted current local clock, caller-supplied historical context and absent evidence; retains accepted B/H source authority.
- **Useful actual caller15%:** provides an executable, documented author and verification workflow rather than an unused parameter.
- **Operational compatibility10%:** supports legitimate old/unchanged content and does not disable ordinary CI without a date producer.
- **Bounded maintenance10%:** reuses existing helpers, contributor guide and validation evidence with minimal interfaces.

Hard constraints: no rerun-driven metadata bump; no candidate date promoted to authenticated time; no weakened B/H/accepted-checkout guard; no suppressed structural/calendar/version/regression checks; no full automatic-date-proof claim for absent context or replay input; no protected policy rewrite, new service, permission ledger or inferred D1 waiver. The selected mode is an ordinary validation action under existing task authority, not a new owner-approval prerequisite.

## 5. Scores before selection

| Option | Semantics40 | Provenance25 | Caller15 | Compatibility10 | Cost10 | Total /100 | Key limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 2 | 3 | 1 | 5 | 5 | 54 | Missing author-finalization consumer |
| A | 1 | 2 | 4 | 1 | 5 | 42 | Wrong time for legitimate delayed input; excluded |
| E | 2 | 2 | 4 | 3 | 3 | 50 | Event time is not the required fact |
| C | 2 | 1 | 4 | 4 | 4 | 49 | Candidate clock; excluded as authentication |
| U | 3 | 3 | 1 | 4 | 4 | 58 | No real caller/provenance contract |
| F | 3 | 5 | 1 | 1 | 4 | 62 | Blocks existing CI without supplying context |
| L | 3 | 4 | 2 | 4 | 5 | 68 | Already covered staged case; incomplete endpoint workflow |
| P | 5 | 5 | 5 | 5 | 4 | 98 | Actual required finalization and delayed-check consumers covered |
| PR | 5 | 5 | 5 | 5 | 3 | 96 | One extra bounded input; replay remains caller-supplied |

**Evidence-based reassessment before publication.** The provisional record scored P's actual-caller criterion 4 because it assumed delayed verification required a new public replay-date interface. That assumption was unsupported. P already checks current UTC at actual finalization, records the exact B/H/date in normal output, and preserves legitimate identical-head delayed CI through explicitly limited no-context checks. The original successful finalization evidence remains applicable to unchanged inputs. The independent helper replay probe proved a conditional comparison, not a need for a new public caller. Therefore P's caller score is corrected to 5. All rubric definitions, weights and other scores remain unchanged.

Select P. P and PR meet the same currently required semantics, provenance and callers. PR adds a public input, date-validation cases, mode combinations, documentation and tests without a distinct supported requirement or new authenticated fact. P objectively has less ongoing interface/validation maintenance for the same required result. The numerical gap is only 2 points; it is not treated as proof. Native AGENTS requires escalation when scores are tied or too close to differentiate objectively. That condition does not apply because the concrete required-consumer coverage is equal and the additional public surface is objectively identifiable. If a real unique replay consumer is later demonstrated, reassess this same decision; do not invent a consumer or adjust weights to obtain a margin. P is not an automatic remote freshness gate.

## 6. Selected solution: P

Add FinalizeMetadataNow to Test-AgentInstructions.ps1. Require exact InputRevision H and PublishedBaselineRevision B. Keep checkout HEAD==B. Capture the existing validation clock once. Use its UTC date for a deliberate author-finalization check. Do not infer this mode from missing parents, initial coverage, promotion, CI events or a clean worktree.

Do not add a public replay-date parameter. Reject FinalizeMetadataNow with MetadataClassificationOnly or SelfTest. Reject missing, short, unresolved or inconsistent endpoints through the existing guards. Validate option combinations before expensive parser work. Do not select a date from Git metadata, candidate headers or PR events. Keep internal date-context helpers where existing callers need them; an internal helper parameter does not require a new public API.

Propagate the chosen date and an explicit require-date condition to all existing changed-document consumers, including the versioned helper. That helper checks ExpectedUtcDate only when RequireExpectedUtcDateForRenderedChange is true. Setting a string alone is insufficient. Preserve rendered-change tests, null/new revision-zero behavior, version-date synchronization, published revision arithmetic, nonfuture/backward checks and mechanical exemptions. Preserve ordinary local worktree current-date checks.

For published calls without FinalizeMetadataNow, keep structural, calendar, baseline and version checks. Do not require now solely because a document is new, promoted or under initial coverage. Emit an explicit limited result: finalization date was not verified. Do not describe the whole validation as structural-only if it also checks version/baseline rules. Distinguish two date states in ordinary output: current local finalization clock checked; finalization date not verified. Include the exact B/H and applied date when present. Use normal validation output/evidence; do not create a new evidence file format or registry.

Document the real caller in the existing nonprotected CONTRIBUTING.md. Explain when to run it and how later checks reuse existing evidence without declaring a new finalization. Do not rewrite protected docs policy. The author sets the correct date/version in H, completes the last author-controlled update, and runs Now at that finalization step. A failure requires correcting the candidate and selecting the new exact H. After another author-controlled update, recheck the applicable baseline/finalization; do not reuse an old successful result for changed endpoints. Merely rerunning CI on identical finalized inputs does not create a new author finalization.

The guide must show an accepted-base policy worktree invocation, with these concrete commands after the accepted base supports the mode and its locked tools are installed. The caller resolves the intended accepted B and final H first and retains those exact values in normal final-validation evidence:

```powershell
# Run from the candidate repository. Refresh origin/main by the normal fetch procedure first.
$finalHead = (git rev-parse --verify 'HEAD^{commit}').Trim()
if ($LASTEXITCODE -ne 0) { throw 'Candidate head is unavailable.' }
$policyBase = (git rev-parse --verify 'origin/main^{commit}').Trim()
if ($LASTEXITCODE -ne 0) { throw 'Accepted base is unavailable.' }
# Use an absent path for this dedicated worktree. Do not overwrite an existing checkout.
$policyPath = Join-Path (Split-Path (Get-Location).Path -Parent) 'PSStyleGuide-finalization-policy'
git worktree add --detach $policyPath $policyBase
if ($LASTEXITCODE -ne 0) { throw 'Policy worktree creation failed.' }
Push-Location $policyPath
try {
    # Follow docs/dependency-maintenance.md in this accepted worktree for its locked prerequisites.
    pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-AgentInstructions.ps1 -InputRevision $finalHead -PublishedBaselineRevision $policyBase -FinalizeMetadataNow
    if ($LASTEXITCODE -ne 0) { throw 'Author finalization validation failed.' }
} finally {
    Pop-Location
}
```

The worktree shares the original repository's objects, so locally committed H is available without executing H. Use the actual PR/destination B if it differs from refreshed origin/main. Resolve/fetch that exact accepted commit before creating the policy worktree. Reuse a suitable existing accepted-B worktree when available. Dependency setup is the existing guide's prerequisite, not an implicit assertion that a new worktree has node_modules. Do not add execution-policy workarounds.

For later verification of identical B/H, run the same accepted-policy command without FinalizeMetadataNow. It checks the existing structural/calendar/baseline/version rules and reports that this invocation did not verify finalization date. Reuse the original successful finalization output, including its exact B/H/date, in normal final-validation evidence. Do not relabel the later invocation as a new finalization pass. Missing original evidence means no historical author-date proof is available; a caller-supplied date would not restore that proof. No ordinary workflow caller should inject its current time to fill this gap. Changed endpoints require the applicable new author-finalization check; automatic target movement retains the policy's existing exception.

**First installation:** native PS B48f4 does not contain the mode. The above installed-mode command is therefore unavailable for PR224's current bootstrap. Do not claim that it ran successfully there. Test the proposed implementation on isolated immutable B/H fixtures, including a fixture with installed accepted checker code and a later candidate; independently inspect the current first-install data/date evidence. Label tests using proposed code as such. Do not copy candidate code into the accepted native workflow and relabel it trusted. The parent retains current bootstrap/review/authority disposition. Once an accepted base contains the mode, the documented caller is executable as described. A03 D1 remains unanswered and is not resolved by this local validation capability.

Minimal paths: Test-AgentInstructions.ps1 for modes/context/status, Test-AgentInstructions.SelfTest.ps1 for focused production-caller tests, and CONTRIBUTING.md for the actual command and limits. No agent-instructions.yml timestamp inference or protected-file edit is selected. The parent assigns any new path to the sole product writer before release.

## 7. Required implementation verification

No F2 implementation has been run. Before acceptance, test these actual caller behaviors:

1. Now accepts a valid current-date new null-base document and rejects stale/future/malformed dates. Run the versioned and nonversioned paths, including supported promotion and initial-coverage contexts.
2. A successful Now invocation records exact B/H/date. Under a later simulated clock, the same B/H passes the no-context published checks with its explicit limited status, without changing metadata or claiming another finalization pass. The original evidence remains unchanged. Preserve version/revision and unchanged-content exemptions. Test the actual caller, not merely the helper.
3. No-context published mode accepts legitimate earlier-finalized content while retaining all structural/calendar/baseline checks and stating date proof is absent. New/null/promotion/bootstrap must not silently force the rerun date.
4. Local staged creation retains current UTC enforcement. Clean committed checking is not automatically Now. Existing self-tests must not silently become publication/finalization evidence.
5. Now with SelfTest/MetadataClassificationOnly, missing endpoint, wrong checkout and mismatched/unavailable commits fail. No unsupported public replay-date parameter is introduced. Candidate-only code remains outside the accepted-source claim.
6. Exercise the documented command in an isolated fixture that actually has the mode installed in its accepted B, with exact H available and locked dependencies. Verify deliberate finalization and later limited checks against identical endpoints. Also assert the real old PS B lacks the mode and report that first-install limit.
7. Mutate the caller to omit the require-date flag, use current time during later no-context verification, omit the limited status, or restore the initial-coverage strict-now fallback. Focused tests must fail. Then run the required current-head repository validation and paired reviews on the repaired candidate.

The independent assessment author contributed to this selection. Later quality review must test the actual implementation and negative controls, with supplemental independent review. This decision is not itself a final-quality pass, automatic-date-proof claim or residual waiver.
