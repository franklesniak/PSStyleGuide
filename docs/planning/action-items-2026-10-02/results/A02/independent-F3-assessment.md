<!-- markdownlint-disable MD013 -->
# Independent security assessment: PR224 finding4163722056

Recommendation: prefer a small accepted-base manifest-only validation phase that runs before the ordinary/maintenance branch. Reuse the existing bounded readers and schema/expansion logic. Keep the broader A03 D1 authority residual open. Removing only the selector entry is a useful smaller alternative for future pure-data changes, but it does not close the reported maintenance-path bypass for mixed changes.

This is independent read-only design advice, not the canonical finding decision, implementation selection, remote review or final quality PASS. A02's worker owns the one complete stakeholder/options/rubric/score record. I coordinated directly with that worker and reused its harmless reproduction rather than rerunning it. Requested gpt-6-astra/high; effective settings unavailable. No descendants/product/planning/native mutations. Inputs are [exact inputs](independent-review-inputs.json). Native PR224 still has head `fe3d6738d5b331f88e21bf6b9815883b3bb353b8`, base `48f4d8a36c8faceee12afac78aaecea0d176125d` at this read.

## Validated facts

- Reviewer [4163722056](https://github.com/franklesniak/PSStyleGuide/pull/224#discussion_r4163722056) is an authenticated Codex inline finding on the exact head, review5389295737. It describes candidate self-baselining after maintenance classification suppresses accepted validation.
- Head classifier adds `.github/document-metadata-classification.json` to selectorPaths. Any listed executable/workflow path also makes a mixed change maintenance. The accepted workflow's ordinary branch alone calls Test-AgentInstructions with `-InputRevision H -PublishedBaselineRevision B`; maintenance prints a requirement message and succeeds without that call.
- Candidate tests call `-SelfTest` without endpoints. Validator6451–6453 chooses checked-out HEAD as the classification baseline. This is appropriate as a local self-consistency input, not proof of previously published authorization.
- The expansion function4750–4850 compares candidate exemptions only against active/authorized paths in the supplied baseline. It correctly rejects candidate-only activation when given the actual old baseline. The worker's production-function reproduction confirms candidate self-baseline accepts README+RUNBOOK while the trusted README-only baseline rejects RUNBOOK. Reproduction files are in A02 scratch `review-round1-reproduction.ps1/.log`.
- Explicit endpoint mode validates complete Git commits and requires checkout HEAD to equal the baseline at6409–6410. Passing base/head to the candidate checkout fails that guard. Removing the guard or declaring candidate source accepted is not a repair.
- The known-prior-validator SHA guard in Test-InitialMetadataCoveragePath is a document metadata/date bootstrap rule. It is called around6765 for prior documents missing metadata. It does not restrict the initial manifest's exemption set. Get-DocumentMetadataClassificationExpansionFailure currently returns without comparison when HasTrustedBaselineManifest=false. Do not describe that as a bounded initial-manifest authorization proof.
- Native PS base48f4 has no table and no new consumer. The current PR is an executable/classifier/manifest bootstrap. It cannot acquire an already-installed trusted check merely by adding one in its own candidate. TF already has the table/consumer, but uses the same maintenance routing issue; future paired scope must account for that existing base.

## Distinct options and consequences for the canonical decision

| Option | Actual enforcement gained | Limits and operational cost |
| --- | --- | --- |
| Retain current candidate-only check | Local consistency and tests only | F3 stays open; pending A03 D1 cannot be treated as a waiver of a newly advertised manifest guarantee |
| Remove only the bounded manifest-data selector | Once a valid consumer/table exists in accepted base, pure-data PRs reach the existing accepted validator and enforce the two-stage published-data rule | Any mixed selector/executable/workflow edit still skips. Missing/introduced manifests need explicit handling; do not use absent baseline as blanket authorization. This option needs a truthful narrowed guarantee and an actual disposition for mixed changes |
| Accepted-base manifest-only phase before branch | For every input class handled by the unchanged accepted workflow, parse only candidate data and compare it against B. Mixed metadata plus code changes cannot bypass just by selecting maintenance | Adds one bounded validation mode and one workflow call. Current bootstrap still needs exact review/verification. Schema migration becomes a reviewed two-stage operation, not an implicit bypass |
| Candidate job with explicit endpoints | Can test proposed code against two data endpoints in a deliberately labeled test harness | Cannot establish accepted-code authority. Current production guard correctly rejects candidate checkout≠B. Weakening it would worsen the trust boundary |
| One-time bootstrap as the entire fix | Can establish a specific initial table after exact review | Does not protect future mixed changes. Combine only with a continuing accepted-base check and a closed bootstrap rule |
| External independent check / organization protection | May establish the stronger immutable producer boundary described in A03 D1 | Requires separate operator/installation/account/credential authority; not a small A02 patch and not currently deployed |

A small dedicated guard is a meaningful data validation control even though it is not immutable workflow enforcement. Do not score it as repairing A03 D1. Conversely, that broader residual is not a reason to keep the avoidable table self-baseline. This is the main distinction the canonical score table should preserve.

## Minimal recommended implementation scope

Prefer a mode in existing Test-AgentInstructions over a new helper/framework. A proposed name is `-MetadataClassificationOnly`; naming is not a product decision here. Require explicit full base/head and accepted checkout for that mode. Reject ambiguous mode combinations. Reuse strict UTF8, regular-file/mode and byte bounds, tracked-path inventories, strict schema2 parser and expansion function. Run only this data phase before Markdown-parser bootstrap or candidate document/parser execution. Return immediately after the data result in this mode. Ordinary validation can reuse that phase without a second independent implementation.

The accepted-policy workflow must invoke this mode after verified head acquisition and before the ordinary/maintenance branch. Every classification must receive its result; a failure must fail the job. Preserve empty/read-only permissions and immutable endpoint acquisition. Keep maintenance classification and owner-review message distinct from the manifest result. Candidate SelfTest remains useful but must not report self-baseline consistency as trusted manifest admission.

Exact likely paths: Test-AgentInstructions.ps1, its dedicated SelfTest.ps1, and agent-instructions.yml for the call. Keep the classifier/test entry as maintenance if that is still the intended routing; it no longer suppresses the independent data phase. If the canonical decision instead selects the narrower ordinary route, only the one selector entry and its regression should change, with the mixed-change residual explicitly retained. No blanket removal of executable/workflow selectors is justified.

Parent must assign the workflow path before a writer changes it; current A02 writer ownership covers bounded validator/SelfTest/classifier only. Treat this one-line caller plus small data mode as the coupled A02 defect repair, with A03 interface review. A03 should consume that accepted result later. Do not create a circular rule that A02 must wait for all A03 implementation before repairing its own consumer path.

Do not duplicate the whole validator into a new script. If a separate helper is materially preferable, it must be an accepted-base built-in-only data reader with a fixed schema and closed paths, covered by the same authority/mode/input checks. It must not read candidate modules, execute profile strings, select arbitrary commands or create an approval protocol. Any extraction must prove identical bounds/refusal behavior and avoid two diverging parsers.

## Bootstrap and the current PR gate

A baseline with no manifest is a distinct initialization state, not an empty list of already-approved exemptions. The future data guard should reject missing/malformed baseline input unless an explicitly closed bootstrap path applies. If bootstrap support is retained, bind it to the exact known prior validator/input identity and the exact intended initial table/coverage; reject arbitrary new exclusions or candidate authorizations. The existing metadata-date helper is insufficient for this purpose.

For this PR, the accepted native workflow predates the guard. It still will not execute new candidate admission code as accepted authority. Demonstrate the proposed check against exact B/H in an isolated harness, label it proposed-code validation, and independently verify the initial table and prior coverage. Preserve both facts: candidate behavior is tested; an already-installed native accepted-base control did not validate this bootstrap. Do not fetch the guard from candidate H inside the trusted job to erase that distinction.

A03 D1's owner question remains unanswered. This assessment supplies no residual acceptance, new human approval, external app, waived check or merge authorization. F3's implementation can be prepared and tested now. Its final disposition must state the bootstrap evidence and remaining native gate/authority boundary. Green candidate CI is not the sole merge criterion. Parent owns that current PR decision after actual required reviews, independent final quality and authority checks.

## Required focused tests

1. Actual trusted B plus candidate H: a new tier2 or generated path without baseline authorization fails; candidate-only authorization plus activation in the same PR also fails.
2. The same attempts mixed with each relevant selector class still fail the unconditional data guard. Include a classifier/validator edit and a workflow edit as data; do not execute those candidates in the trusted test.
3. Published authorization at B followed by activation at H passes. Moving between exempt categories does not create new unapproved coverage. Removal/revocation behavior must be explicit.
4. Unchanged manifest plus unrelated ordinary content passes the data phase. Pure manifest formatting or inert authorization additions remain bounded and do not activate an exemption in that same input.
5. Malformed/oversized/duplicate-key manifest, unsafe/untracked active paths, nonregular mode, missing candidate table and unavailable/mismatched endpoints fail before any candidate parser/module runs.
6. Missing baseline table cannot authorize arbitrary initial exclusions. Exact accepted bootstrap fixture passes only its closed mapping; altered baseline validator identity and extra RUNBOOK exemption fail.
7. Candidate checkout with claimed accepted base fails. Wrong SHA, changed head/base, replacement-object/config influence and invalid result/native failure must not become success; reuse existing endpoint/Git safety tests rather than recreate a framework.
8. A caller integration test proves maintenance classification does not skip the manifest phase and that a failing guard cannot yield a successful accepted-policy result. A mutation that removes the call or moves it back into the ordinary branch must be caught.
9. Candidate SelfTest still verifies parser/data behavior, with explicit absence of an accepted-authority claim. Avoid treating selftest, schema parsing or skipped native jobs as approval.

Retain the existing supported PowerShell7 baseline; do not add Windows5.1 execution-policy workarounds. No unrelated suites need rerun for this assessment. Actual candidate changes require focused caller and validator tests on supported CI hosts, followed by current-head review and independent final quality.

## Hard limits

This proposal does not bind app15368 checks to one immutable workflow, make accepted-policy a required native check, authenticate scoped owner permission, or prevent an administrator/maintenance change from replacing the gate. It validates the table when the accepted workflow runs and its result is actually required by the chosen merge procedure. Keep native head/base freshness and A03's unresolved producer/authority question separate. No new receipt or approval ledger is needed.
