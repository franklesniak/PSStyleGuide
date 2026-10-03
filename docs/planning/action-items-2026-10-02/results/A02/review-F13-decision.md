<!-- markdownlint-disable MD013 -->
# F13: compare push endpoints in the explicitly proposed-policy role

Status: selected before corresponding product edits; implemented; focused controls and final aggregate pass.

## Validation and stakeholders

Codex5397627845/comment4170495474 identifies head25b17e892f6429cf4df4f39489443d950f5902e8/tree4dba7b2766ba49233e7dd0871188255c0870ae7c. The complete agent-instructions.yml runs accepted-policy only for pull_request_target. Push to main and manual dispatch run candidate-tests, acquiring GITHUB_SHA and calling SelfTest without endpoints. The checker therefore selects HEAD as its classification baseline. reproduce.ps1/log uses the actual installed-fixture data-only CLI: B/H rejects an unauthorized exemption; H/H accepts that same committed expansion. This proves the transition coverage gap, not a live push or immutable-workflow bypass. The candidate job already explicitly disclaims publication authority.

The native docs policy specifies direct-push before as the published baseline. GitHub's [push payload reference](https://docs.github.com/en/webhooks/webhook-events-and-payloads#push) defines before and after; its [event reference](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#push) explains push SHA and branch-deletion differences. Use event endpoints, not HEAD's parent or current main. Zero/missing/unavailable before cannot be replaced with H. Manual dispatch has no push transition and remains snapshot evidence.

Native B48f4d8a lacks this PR's manifest and MetadataClassificationOnly implementation. Unconditionally calling that old checker in an extended accepted-policy push job would cause a known first-merge failure. Existing closed initial classification logic already binds the exact B/hash and exact initial table, but it is proposed code, not installed authority. Default published mode also requires checkout==B; simply passing B/H in the existing H checkout fails. Copying H code into a B checkout would blur checker provenance. A03 D1 owner enforcement is still unanswered; GitHub Actions app15368 and a candidate-owned workflow do not make this immutable.

Affected stakeholders: maintainer/direct push operators and recovery operators need correct before/after evidence and predictable first installation; contributors and both repositories' maintainers need unchanged local/PR behavior; CI/platform engineers need bounded exact acquisition; application/supply-chain security and independent reviewers need explicit code provenance and no invented authority; history custodians need fixed endpoint/date semantics; cost/schedule owners need a small caller repair. No cloud credentials, personal data, external service or permission changes.

Hard constraints: preserve default checkout==B accepted mode, exact baseline/hash/initial mapping, no candidate fallback pretending to be accepted authority, no new approval waiver, no guaranteed failed first landing, no event timestamp as author-finalization proof, no force/mutable ref fetch, no zero/missing endpoint fallback. Candidate diagnostics cannot close the broader D1 enforcement boundary.

## Options, fresh rubric and scores

N leaves/defer the missing transition. A extends accepted-policy push to execute before-code unconditionally. P adds an explicit proposed-policy endpoint mode requiring checkout==H and a push-only caller with exact before/after, retaining accepted mode by default. O overlays candidate executable bytes on a B checkout. B adds a workflow-specific first-install closed bootstrap plus accepted later checks. E installs an external immutable producer. R removes push testing. I infers the parent/HEAD baseline inside the validator from ambient event data. Combining P with the existing candidate SelfTest is P; metadata data-only checks alone would omit the policy's document transition contract.

Fresh0–5 rubric: transition correctness35; provenance/authority clarity30; installed/first-landing feasibility20; maintenance/cost15. Total=sum(weight*score)/5. Scores do not override hard constraints.

| Option | Correct35 | Clarity30 | Feasible20 | Cost15 | Total | Key uncertainty/constraint |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| N | 0 | 4 | 5 | 5 | 59 | Snapshot evidence still misses transitions |
| A | 5 | 5 | 0 | 4 | 77 | Guaranteed B48f unsupported-mode first-landing failure |
| P | 5 | 5 | 5 | 4 | 97 | Explicit proposed role must never be used by accepted caller |
| O | 5 | 1 | 4 | 2 | 63 | Masks checker origin and adds overlay/dependency machinery |
| B | 5 | 3 | 3 | 1 | 68 | Duplicates bootstrap/trust policy; authority not supplied by code |
| E | 5 | 5 | 0 | 0 | 65 | Requires separate owner/install scope, still A03 |
| R | 0 | 3 | 5 | 5 | 53 | Removes useful candidate tests and leaves coverage gap |
| I | 3 | 1 | 4 | 3 | 52 | Ambient implicit behavior and false parent assumptions |

P provides actual endpoint validation with honest candidate provenance and no old-B execution dependency. It is a diagnostic improvement, not a new security authority. A/E may be useful future enforcement but do not supply a deployable repair within the current known installation boundary. Scores are reasoned comparisons, not empirical proof.

## Selected instructions and validation

Select P. Add ProposedPolicy as an explicit switch for full endpoint validation only. Require distinct exact nonzero B/H and checkout==H. Reject SelfTest, MetadataClassificationOnly or FinalizeMetadataNow combinations. Keep default accepted mode's checkout==B requirement and all data/baseline checks unchanged. Print the proposed-code/no-authority role and endpoint identities. Preserve ordinary no-context snapshot semantics. Do not change first-install mapping or finalization rules.

In the existing candidate-tests push caller, read event before/after through environment variables. Require distinct nonzero40-digit hashes and after==GITHUB_SHA. Fetch exact B without credentials/force/ref mutation, using existing three-attempt bounds, and verify FETCH_HEAD. Then invoke full ProposedPolicy with H/B. Keep PR candidate SelfTest and manual snapshot behavior. Keep accepted-policy PR caller free of ProposedPolicy. Current code runs only in the already proposed-code job; no new privileged execution is introduced.

Required paths: validator, SelfTest, agent-instructions.yml and existing Classify-InstructionMaintenance.test.mjs. No classifier algorithm, manifest, protected file, settings or new external helper. This narrowly justified explicit CLI mode is needed because accepted checkout==B must remain intact; it avoids silently weakening that mode.

Validate real proposed full B/H on H: ordinary success, unauthorized expansion rejection, backward metadata rejection and exact initial B48f compatibility using proposed code. Retain default wrong-checkout rejection; reject bad mode combinations and missing/zero/unavailable endpoints. Test actual extracted workflow control flow with bounded stubs for native failures, event endpoint mismatch, fetch identity, zero-before, and no push call for PR/manual. Assert accepted caller cannot select the proposed switch. Retain all prior F1–F12 controls and one final-byte combined aggregate. Actual GitHub run/landing remains a later native gate. No claim of immutable enforcement, owner acceptance or authenticated finalization date. Parent owns publication, round8/80/original deadline/transfer0/12; A07 remains frozen.

## Validation checkpoint

Implemented within the four authorized code/workflow paths. All focused controls pass; provisional tree0cde16e0dc69df235b98f6e739fa112bf7c1e3eb has no unstaged changes. RESULT.md records exact identities, terminal logs and limits. Provisional code passed independent whole-PR quality. At actual UTC October3, only the two authorized Last Updated lines changed to2026-10-03; code blobs remain unchanged. Final six-path tree7d79b48a15f80fddabb8f062eba8819b0ad7cf6b is frozen. One normal aggregate30624 passed all10 hooks, exit0, start2026-10-03T00:01:05.9074447Z and end2026-10-03T00:40:20.8387851Z. Final readback confirms identical six-path tree/blobs/raw bytes, no unstaged changes and diffcheck0. Product/index ownership is released to the parent for normal commit and exact endpoint/native gates. No native installation/owner/immutable-workflow acceptance is claimed.

Final candidate `9652b46e9442d1fb375277f9a106b2c432877a98`, tree `855b1f44ffeaeee8dedd6825244778f60067e373`, includes the fixture-only correction to the prior F13-F15 repair61f1bec. The exact admission function passes on Windows/Linux with all three modes and both provenance rejection calls retained. One normal replacement aggregate85955 passed all ten hooks at2026-10-03T01:52:06.7758152Z; normal commit completed without bypass. Actual proposed-code B48f/H965 finalization (UTC2026-10-03), classification and full ProposedPolicy checks passed in root76260, ending01:56:36.923231Z. Static Error checks and Warning-only PSScriptAnalyzer1.24.0 checks cover both changed PowerShell files with zero findings at the recorded severities. [Independent whole-PR local quality](F13-F15-quality.md) reconciles the actual commit and final evidence. Normal non-force push and authenticated PR readback confirm965/base48f. New candidate CI, reviews and immediate native gates remain pending; predecessor61f native CI failure is retained as historical evidence.

## Native965 diagnostic fixture correction

Native965 run37088281932 failed only its fixture oracle: the real checker rejected wrong-baseline execution (exit1), but Linux ConciseView wrapped `accepted baseline` across lines (`native-candidate-965-failed.log`, `diagnostic-wrap-reproduce.log`).
The private proposed-call wrapper now writes Exception.Message and exits1 on exceptions, reusing the existing finalization fixture pattern; all argument arrays, native exit checks and exact intended-reason assertions remain intact, including wrong-checkout, unauthorized and backward-Version siblings.
An initial wrapper array-splat attempt failed parameter binding on Linux; its concurrent Windows run refused changed source during materialization. Both logs are retained; corrected fixed parameter tokens and quoted values then ran on stable bytes.
Final focused exact setup/all changed caller sections pass Windows7.6.5 and Ubuntu24.04/PowerShell7.5 with Node24.18.1, CI=true, pull_request and TERM=dumb (`proposed-diagnostic-{windows,linux}-final.log`); final Warning/Error analyzer count0 and diffcheck0.
No production contract or authority rule changed; unrelated fixture sections were excluded from focused runs, disposable Linux assets removed, and no new aggregate/commit/public mutation performed. Frozen tree3f285db awaits parent gate release.
