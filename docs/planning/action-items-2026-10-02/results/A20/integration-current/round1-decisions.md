<!-- markdownlint-disable MD013 -->
# PR229 round 1 finding decisions

Both findings are from automatic Codex review5401791780 of b319758478cf8626f617e362ee1fe1a86619a314. Its authenticated summary records completion. Copilot review5401800960 completed on the same head with Balanced effort and no findings. Its general final-review caution is satisfied through the existing final-quality gate; it supplies no additional technical defect or owner-approval requirement. The two distinct decisions below were shown to the owner before repair. The existing D08 protected-file grants cover these repairs to the authorized instruction behavior. No new permission is needed.

## R1: accept observable review-attribution evidence

Finding4174055981, thread `PRRT_kwDOQkjdhM6opud9`, concerns CLAUDE's detection rule. The new prose demands request attribution but does not say how ordinary GitHub evidence can establish it. A literal reader can wait for an originating request ID that the review payload does not expose. This is a material liveness and usability defect. A timestamp alone must still be insufficient: an older automatic or same-head request can return later.

The maintainer and new developer need a decision they can execute without service internals. Security reviewers need exclusion of stale and competing results. DevOps needs a rule that works with real API fields and pending requests. QA needs distinct accepted and ambiguous examples. Documentation and UX reviewers need one coherent instruction without an impossible requirement. Project and business owners need finite progress without repeated human arbitration. A service integrator could add stronger linkage when available, but this repository does not own either remote reviewer.

**Options, before scoring.** N keeps the current text. T accepts any newer timestamp. B adds a new review ID, author and head but ignores competing requests. S defines a serialized observable evidence rule. R requires a direct service-provided request link in every case. H asks the owner to identify each result. G builds an external request-tracking service. M changes the commit for each request. S can use direct linkage from R when available without requiring a new service. Combining S with T or B by discarding its ambiguity checks defeats S. Combining M with S adds commits and automatic triggers without removing the need to distinguish requests. H remains a last resort for a real unresolved ambiguity, not the ordinary path.

**Unique rubric.** Scores are 1 (poor) to 5 (fully meets the criterion); weighted totals are out of100. Correct attribution is30%: exclude stale or competing requests and bind current scope. Observable operation is30%: use evidence GitHub or the reviewer actually exposes. Result completeness is15%: distinguish findings from terminal results and read all findings. Usability is10%: a maintainer can follow the rule without repeated arbitration. Auditability is10%: preserve a reproducible baseline and request history. Implementation cost is5%: avoid unnecessary services, state or commits. Hard constraints reject timestamp-only acceptance, unresolved competing requests and invented native IDs. No score can waive those constraints.

| Option | Attribution30 | Observable30 | Completeness15 | Usability10 | Audit10 | Cost5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 5 | 1 | 4 | 1 | 3 | 5 | 61 |
| T | 1 | 5 | 2 | 4 | 1 | 5 | 57 |
| B | 3 | 5 | 3 | 4 | 3 | 4 | 75 |
| S | 5 | 5 | 5 | 4 | 5 | 4 | 97 |
| R | 5 | 2 | 5 | 2 | 5 | 2 | 73 |
| H | 4 | 3 | 4 | 1 | 4 | 2 | 66 |
| G | 5 | 2 | 4 | 1 | 4 | 1 | 65 |
| M | 3 | 3 | 3 | 2 | 3 | 2 | 57 |

**Selected instructions.** Use S. Confirm the request and record its time and input. Record all existing review results. Finish or reconcile each earlier request before you send another request to that reviewer. Accept a new review ID only when its author and commit match the request. Require submission after the request. Keep the reviewed scope unchanged. Check for competing requests. If another request could explain the result, keep it unresolved. Use a direct service link when one is available. Do not require a field that GitHub does not provide. Read the complete result before you mark the request complete. Keep stricter task limits and the existing review defaults.

**Examples and proof.** A confirmed sole pending request, complete baseline, unchanged input and a new submitted review from the configured bot on that input can establish attribution. A delayed automatic review while a manual request is also pending cannot establish it by timestamp alone. A headless comment still needs authenticated evidence of its reviewed input; the current PR head does not prove that input. The actual PR229 baseline, accepted Copilot event32406109538, exact-head run37139013686 and review5401800960 illustrate available evidence. This is a documentation correction, not a new service implementation or proof that every third-party result is attributable. Validate the edited instructions with the existing checks; preserve those negative examples during independent review.

**References.** GitHub's [review endpoint](https://docs.github.com/en/rest/pulls/reviews#list-reviews-for-a-pull-request) exposes result identity, author, submission time and commit. The [request event](https://docs.github.com/en/rest/using-the-rest-api/issue-event-types#review_requested) identifies the request, actor and reviewer but not a future review ID. The bounded attribution rule is an inference from these documented surfaces plus serialized request state; it is not a claim that GitHub supplies a universal join key.

## R2: validate the commit actually created by API placement

Finding4174055988, thread `PRRT_kwDOQkjdhM6opueC`, concerns CLAUDE's API fallback and the corresponding AGENTS placement readback. An API file write can create the intended files with a different commit ID. Requiring the original local ID incorrectly rejects valid placement and directs later review to the wrong object. This is a real correctness defect. Merely accepting the returned ID would also be wrong because it would not prove history, scope or contents.

The maintainer and new developer need a successful fallback to be recognized. DevOps needs useful transport recovery and explicit race handling. Security reviewers need the recorded remote preimage, authorized changes and no force or bypass. QA needs differences in commit metadata, file bytes, file modes, history and scope to remain distinguishable. UX and documentation reviewers need clear identities for later review. Business and project owners need recovery that does not depend on routine manual transfer. No stakeholder needs a new metadata-identical commit-generation framework.

**Options, before scoring.** N requires the local commit ID. L removes the API fallback. B trusts the returned ID without checking its contents. V verifies the actual API commit, parent chain, exact tree and PR-head readback. G requires lower-level Git APIs to reproduce the original commit object. D accepts readable text equivalence. H requires manual transfer. G can be a supported transport inside V, but exact original-object reproduction is unnecessary for correctness and is not guaranteed by ordinary file-write tools. Multi-call placement is also V only if each intermediate operation stays in scope and the final exact tree is verified. B or D combined with V while omitting a check no longer satisfies V.

**Unique rubric.** Use the same 1–5 scale but a finding-specific set of weights. Safe history and authority is35%: the actual commits extend the recorded remote preimage and contain only authorized work. Exact tree equivalence is30%: verify every path, blob and mode without text normalization. API compatibility is15%: permit valid file-write responses with different metadata or commit grouping. Review integration is10%: actual remote identities drive reachability, current-head checks and later review. Usability is5%: the result and failure cases are clear. Implementation cost is5%: prefer bounded checks to a new commit reconstruction system. Hard constraints reject force, bypass, unrelated history or files, unverified trees and claiming a local SHA was placed when it was not.

| Option | History35 | Tree30 | API15 | Review10 | Usability5 | Cost5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 2 | 2 | 1 | 2 | 2 | 5 | 40 |
| L | 4 | 5 | 1 | 4 | 3 | 4 | 76 |
| B | 2 | 1 | 5 | 3 | 4 | 5 | 50 |
| V | 5 | 5 | 5 | 5 | 4 | 4 | 98 |
| G | 4 | 5 | 3 | 5 | 2 | 2 | 81 |
| D | 4 | 2 | 5 | 4 | 3 | 3 | 69 |
| H | 4 | 4 | 3 | 3 | 1 | 2 | 70 |

**Selected instructions.** Use V. Record the remote head before placement. Record each commit ID returned by the API. Verify that the commit chain extends the recorded head and contains only the approved changes. Compare the final tree with the tested local tree. Include file modes. Read the PR head through authenticated GitHub tooling. Require it to match the verified API result. Use that actual commit ID for reachability and review. Keep the local-to-remote mapping in the active task record. Stop on a conflict or mismatch. Do not force an update or bypass repository controls.

**Examples and proof.** Parent read the actual b319758 commit bytes, changed only the committer timestamp by one second, then ran native `git hash-object -t commit --stdin` without `-w`. The computed ID became56abb3ef229de8c31467c27003c60132e306286c while the tree and parent stayed identical. No Git object, ref or remote file was written. This proves why local commit-ID equality is too strict; it is not an API transport test. A changed file mode or an unrelated intermediate commit must still fail the selected rule. The ordinary four-path PR still uses normal Git push; no artificial API write is necessary to test the documentation repair.

**Reference.** GitHub's [create/update file response](https://docs.github.com/en/rest/repos/contents#create-or-update-file-contents) returns the new commit SHA, tree and parents, separately from the content blob SHA. Verify these actual identities instead of assuming an unchanged local commit object.

## Implementation and validation boundary

Apply R1 to CLAUDE's detection text and R2 to both roots' placement text. Keep existing exact validator anchors, all five setup commands, the full protocols and the32768-byte reader limit. Update both TF scratch previews from the corrected PS text with only the existing identity exceptions; do not start TF product implementation. Root owns native operations. One worker may edit the two product roots and the bounded preview/evidence files after selection. Preserve the other two PR product paths unless a demonstrated coupled check requires a reviewed update.

Read the full applicable documentation guide before selecting a secondary style-guide recommendation. Its existing deterministic-contract, observable-interface, examples and consistency rules already cover these failures. Correct the operative instructions; no additional general documentation-style rule is needed. No generated consumer guide changes follow from either finding.

After repair, run affected root/preview and Markdown checks, confirm raw sizes and exact scope, and run one required all-files aggregate before the fix commit. Do not repeat the separate unchanged validator SelfTest only to duplicate that aggregate. Validate actual committed endpoints and refresh invalidated lifecycle evidence. Update the PR body to describe the final behavior and reply once per finding with this decision and verified fix. Resolve only after the implementation and reply are present. Both reviewers must then review the current corrected input; retain round history and the original eight-day deadline.

## Validation placement

Ordinary validation at topic HEAD b319758 rejects the correctly retained final revision `.0`, because it treats that intermediate commit as the published parent.
The existing [D14 placement decision](../../A02/review-D-A02-14-validation-addendum.md) already selected exact accepted-base validation for this same conflict; apply that method, not a second product-policy decision.
Keep the source HEAD/index and production validator unchanged. In the private fixture at accepted425795b, stage the complete final candidate and verify all paths, blobs, modes and raw bytes against the source.
Run one current-policy all-files aggregate, verify unchanged identity afterward, then commit that identical tree normally and validate actual425-to-fix endpoints.
The earlier two-pass count in historical D14 is superseded by DECISION-PROCESS; this task requires one final-byte aggregate. The separate A03 draft-push context finding remains with A03.
