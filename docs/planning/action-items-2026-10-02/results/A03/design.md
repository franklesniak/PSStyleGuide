<!-- markdownlint-disable MD013 -->
# A03 read-only preparation

This is a scoped design, not A03 acceptance. A00/A01 are accepted. A02 implementation is still a predecessor. No product file, native object, review request, or setting was changed. Requested worker route: `gpt-6-astra/high`; effective settings are not exposed. Transfers: 0/12. No PR clock has started.

Use [native-evidence.json](native-evidence.json) for the read time, both authenticated native main commits/trees, effective rules, and 26 exact source blobs/modes. PS remains `48f4d8a36c8faceee12afac78aaecea0d176125d`; TF remains `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. Source inspection used these Git objects, not working-tree differences. No product test suite was run for this preparation.

Read inputs: STATUS first; README; LOOP-POLICY; ROUTING-AND-PARALLELISM; A03; DECISION-PROCESS; RETIREMENT-REVIEW R01–R07; A00 reconciliation; A12 assessment and exact proposed ruleset; A15 read-only design; original 019/022/049/098/099 contracts and titles/ownership of 019–068/098–125. The A00 pinned research-misc comparison remains historical evidence. This task does not replace it with a new research port.

## Current boundary and scope

The accepted-policy job loads the event's accepted base, fetches the head as data, and runs the accepted classifier. Ordinary changes receive accepted instruction and workflow validation. Maintenance changes receive a successful classification and a message requiring owner authority and independent review. No approval is checked on that branch. Candidate behavior tests run separately with empty permissions. The classifier binds output to supplied base/head and requires the checkout to equal the supplied base. It does not query GitHub to prove those supplied endpoints are still current.

The workflow validator strictly parses the two production workflows, checks their isolated jobs and publisher, and verifies the accepted parser/lock before importing third-party code. Its bootstrap acquisition check only requires nonempty source. Actual acquisition tests and maintenance review carry that source boundary. Thus the retained small validator is useful but is not an immutable proof of every workflow body.

A02 owns adding `.github/document-metadata-classification.json` to the PS classifier and its table-only-change regression atomically with the metadata consumer. Rebase A03 on that accepted result. Do not implement a competing copy. A03 owns the remaining classifier/workflow/validator/test convergence; A04 owns ordinary download retry bounds, A06 artifact behavior, A07 runtime/dependency setup, and A09 current supply evidence.

## Decision A03-D1: maintenance admission and freshness

**Validated finding.** R03's lost approval enforcement remains present. PS has no effective main rules. TF has strict required `markdownlint`, `policy`, and `verify` checks from GitHub Actions app15368, with no bypass in the accepted A12 snapshot. The pending PS proposal requires `policy`, `markdownlint`, and `verify_generated_artifacts` from the same app. Neither list includes accepted-policy classification. Strict checks improve ordinary merge freshness. They do not turn classification into approval or bind a check to one immutable workflow. GitHub documents the source selection at app level and says status checks do not distinguish workflow/matrix/trigger types. This limitation is an architectural inference from those documented boundaries, not a performed spoofing attack. [GitHub rules](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets), [check limits](https://docs.github.com/en/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/troubleshooting-rules).

**Stakeholders.** The sole maintainer must update these public user-owned repositories without a self-approval deadlock. Contributors and agents need a clear ordinary/maintenance boundary. Security reviewers, the risk owner, branch administrators, CI operators and incident responders need truthful authority and recovery evidence. Downstream guide consumers depend on the verified bytes. Cost and schedule owners bear any external service or account migration. This finding does not expose new personal data or change accessibility/localization behavior.

**Options, before scoring.** N: keep current behavior and make no disposition. B: add a small owner-comment, label, environment approval, or in-repository admission gate. R: restore the old exact-byte authorizer/manifest with required-check integration. P: keep accepted-base validation and candidate isolation, retain exact-input review/merge procedure, add only authorized ordinary strict checks, and ask the owner to accept the remaining procedural maintenance boundary explicitly. E: install an independently operated GitHub App check, with the private key and policy outside candidate execution; organization-required protected workflows are a separately authorized alternative. V: require native approving human reviews. D: defer all A03 work. A small gate plus app15368 pinning remains B. A small gate backed by an independent external producer belongs to E. No option may call green classification approval.

**New rubric.** Scores 1–5, higher is better. Authorization integrity 40%; honest failure/freshness 25%; legitimate sole-maintainer operation 15%; controlled installation/recovery 15%; ongoing burden 5%. Total is `sum(weight*score)/5`. Hard constraints: no candidate code with privileged credentials; no invented approval; no silent settings/account/credential grant; no unapproved governing-requirement reduction. Scores express design judgments, not measured attack resistance.

| Option | Integrity | Failure/freshness | Operation | Installation | Burden | Total | Constraint or uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 1 | 2 | 5 | 5 | 5 | 53 | Leaves the material acceptance gap unresolved |
| B | 2 | 3 | 3 | 3 | 3 | 52 | Added protocol; no independent workflow identity established |
| R | 4 | 4 | 1 | 2 | 1 | 62 | Genuine former benefit; integration/bootstrap and freshness still require proof |
| P | 2 | 4 | 5 | 5 | 5 | 71 | Requires explicit owner acceptance; does not repair immutable authorization |
| E | 5 | 5 | 3 | 3 | 1 | 84 | Best strength in principle; no present installation, operator or credential authority |
| V | 4 | 5 | 1 | 2 | 3 | 69 | Owner-authored PRs cannot be approved by their author; another qualified actor is required |
| D | 1 | 5 | 1 | 3 | 5 | 50 | Truthful stop, but leaves independent useful convergence undone |

GitHub forbids PR authors from approving their own PRs. A bot review or an agent using the owner's identity is not a substitute for the actual human boundary. A new required-human-review rule is therefore not an immediately operable sole-maintainer fix. [GitHub review requirements](https://docs.github.com/en/pull-requests/how-tos/review-pull-requests/approving-a-pull-request-with-required-reviews).

**Selection and authority.** No candidate option currently both repairs independent maintenance enforcement and clears installation authority. Recommend P only as an explicit owner choice for this supported single-maintainer deployment. Until that choice exists, keep the enforcement loss unresolved. Continue independent convergence work after A02. Do not add B merely to make CI look stricter. Do not restore R automatically. If the owner requires machine enforcement independent of candidate-controlled Actions, prepare E instead and keep A03 open until that system is installed and verified. Organization-required workflows require organization-level rules/source configuration; these user-owned repositories have no such approved migration. [GitHub organization rules](https://docs.github.com/en/enterprise-cloud@latest/repositories/configuring-branches-and-merges-in-your-repository/managing-rulesets/available-rules-for-rulesets).

Concrete proposed owner choice, for the coordinator to present separately from A13: “Accept procedural maintenance authorization for these two user-owned repositories: accepted-base classification and ordinary validation remain; each maintenance change needs actual scoped owner authority and independent exact-input review before normal merge. Existing authorized task scope satisfies ordinary in-scope maintenance; it does not authorize protected-file, settings or human-gate exceptions. The required Actions checks do not independently enforce that authority and can be changed by a maintainer with repository/settings access. Keep this residual visible. Reassess it if another maintainer, an external enforcement service, an organization migration, or a bypass incident changes the assumptions.” No answer is not acceptance. This does not waive protected instruction-file grants, A13 settings approval, Terraform Gate A/B approvals, or the required remote reviewer loop.

If P is rejected, E's minimum reviewable scope must name the operator, hosting and installation, a distinct check context and app ID, read-only repository/PR permissions plus checks write, a policy source outside candidate control, exact PR head and current base validation, owner decision identity/revocation rules, missing/ambiguous-data failure, stale-result invalidation, and installation/recovery without bypass. Keep its signing key outside all repository-code jobs. Do not propose an unimplemented service as completion.

**Freshness selection.** Reuse R04 after checking the present full-SHA callers and rules. Keep the sweep retired. Re-read native head/base, expected producer, required contexts and mergeability immediately before merge. Revalidate changed relevant base inputs. Missing checks or an unrelated event/run do not satisfy readiness. GitHub accepts success/skipped/neutral conclusions for required checks; a failed dependency can leave a downstream required job skipped. A dispatched workflow is not a general substitute for an eligible PR check. Verify the actual PR-associated result and expected producer. [GitHub required-check behavior](https://docs.github.com/en/pull-requests/how-tos/merge-and-close-pull-requests/troubleshooting-required-status-checks).

**Verification required.** For P, verify ordinary and maintenance classification, candidate-authority rejection, missing/current checks, changed head/base and the actual final native PR inputs. Record owner acceptance separately. For E, additionally demonstrate same-name wrong-source rejection and that modifying candidate workflows cannot issue the trusted result; demonstrate new-head/base invalidation and an ordinary legitimate maintenance approval. These native gates have not been tested here.

## Decision A03-D2: restore useful event coverage

**Validated finding.** Original098/099 require unfiltered push and pull-request coverage. Both current build/lint files and their validators mandate main-only branch filters. PS instruction validation is similarly filtered; TF instruction validation is broader. No current native result proves off-main coverage or an owner-approved narrowing. This is a supported contract gap, not a reason to restore the global sweep.

**Stakeholders.** Branch and release authors, PR authors targeting non-main branches, CI maintainers, maintainers merging branch work, policy reviewers and artifact consumers need predictable checks. Security engineers need unchanged permissions/publication isolation. Cost owners pay additional useful branch runs; there is no measured runtime saving that justifies silent coverage loss.

**Options.** N: keep the gap. R: remove branch/path filters for live push and PR events and test the exact graph, with explicit handling of deleted refs. E: retain main-only coverage after a scoped owner exception. G: restore a global dispatcher/sweep to compensate. A selective workflow split belongs to R only if every supported event still receives the applicable checks.

**New rubric.** Supported-event completeness 35%; truthful event/failure behavior 25%; unchanged security boundary 20%; maintainability 15%; churn 5%. Scores 1–5. Hard constraints: retain action-free repository-code jobs, empty permissions, immutable acquisition, read-only isolated publication, stable required-check names; no tag/branch coverage claim based only on a branch glob.

| Option | Completeness | Failure | Security | Maintainability | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 2 | 4 | 5 | 5 | 53 |
| R | 5 | 4 | 5 | 4 | 3 | 90 |
| E | 2 | 3 | 4 | 5 | 5 | 65 |
| G | 3 | 3 | 3 | 2 | 1 | 55 |

**Selected solution.** Use R after A02. Remove the main-only event filters in build, lint and instruction validation. Preserve the accepted-policy event split. Ignore a deleted-ref event explicitly because it has no live triggering tree. Test ordinary branch push, tag push, main/non-main PR targets, target events, and deleted refs. Keep a required PR job runnable on every supported PR; do not add a permissive conditional skip to it. Change the closed validator event shape and catalog atomically. Keep the weekly lint schedule. Do not add a writer or privileged candidate path. Preserve TF `verify` and PS `verify_generated_artifacts` until an expressly authorized settings migration replaces them. Confirm exact event/check behavior on the implementation PR; local structural tests alone do not prove native association.

## Decision A03-D3: share the common algorithms without a new profile framework

**Validated improvement.** Paired classifier, validator and helper tests contain common algorithms with differing repository literals and role IDs. Build verifier IDs are real native-check interfaces. Parser result/contract prefixes, publisher step labels, artifact name spelling and differing tests are not all proven necessary differences. The current co-located contract has a closed parser/actions schema, which is a sufficient place for a small reviewed role map if required. The accepted code must continue to load its own accepted contract, not a candidate replacement.

**Stakeholders.** Both maintainers, security and CI reviewers, new contributors, dependency maintainers and future agents need one understandable behavior. Existing native checks and artifact consumers need stable compatibility. A06/A07/A15 implementers need narrow extensibility without arbitrary commands or graph configuration. Auditors need raw byte proof rather than normalized summaries.

**Options.** N: maintain divergent algorithms and exception labels. C: identical common code with a minimal closed repository-role configuration and shared behavioral cases. A: force every literal identical now, including required-check names, with settings migration. D: revive generalized source/version profiles or generated workflow templates. Shared code with arbitrary shell, conditions or permissions is not C; it fails the hard constraint.

**New rubric.** Equal security/failure behavior 35%; shared algorithm identity 30%; compatibility 20%; understandable maintenance 10%; churn 5%. Scores 1–5. Hard constraints: never read candidate configuration as accepted policy; no arbitrary expression/command schema; no silent required-check rename; no generic directory exception; validate the finite roles and exact keys before using them.

| Option | Security | Identity | Compatibility | Maintenance | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 3 | 1 | 5 | 3 | 5 | 58 |
| C | 5 | 5 | 5 | 4 | 3 | 96 |
| A | 5 | 5 | 1 | 2 | 1 | 74 |
| D | 3 | 3 | 2 | 2 | 2 | 53 |

**Selected solution.** Use C. Keep the classifier algorithm identical and use the union of actual supported loader paths in both repositories; an absent language-specific path can still require maintenance when introduced. Include A02's metadata path. Keep package-shadow and platform-discovered-workflow classification. Do not turn the classifier into an approval parser.

Use one validator implementation. Put only necessary finite role identities in the existing accepted contract. The initial legitimate role difference is the verifier job ID required by native settings. Converge publisher step IDs and common artifact naming unless an actual consumer proves compatibility needs. Keep language-specific artifact filenames as narrow contract data. Before changing schema/result names, search actual consumers; preserve required compatibility or migrate both sides atomically. The inspected initializer consumes exit status, not repository result prefixes; no reason has yet been established for separate algorithm bodies. Do not assert that a schema compatibility exception is permanent merely because it exists today.

Use identical common test sources/cases where behavior is shared. Parameterize only those same closed roles; do not parameterize away permissions, acquisition, parser integrity, failures, or required graph edges. Compare raw Git blobs and modes after each port. A mixed workflow may differ only at the fixed repository identity and proved native check interface or language output; record the exact differing region and why accepted configuration cannot replace a bootstrap literal before repository data exists. Every additional exception needs evidence.

Reuse R02 and R07 for behavioral tests. Reuse R01 for native review-input identity without a body writer; R05 for current supply rather than compulsory historical reproduction; R06 for contributor generation plus committed-byte publication. Their inspected current consumers still match. See [threat-map.md](threat-map.md) for the bounded verification work.

## Installation boundary and next action

Implementation must wait for accepted A02. Ordinary workflow/test changes are within the execution plan; no separate protected-file authority is presumed necessary for those files. Any resulting changes to protected root/instruction/style-guide prose need their own exact owner grant; A02's six-file request does not authorize unrelated A03 changes. Settings stay in A13. No historical direct-main installation exception is reused.

A15 cannot be declared satisfied by the current Linux harness. When its approved Windows implementation exists, preserve the actual same-run build dependency and required check name. An always-running aggregate must fail on missing, failed, cancelled or skipped mandatory Windows/Linux results; publication must depend on that aggregate in the same run. Agree its finite roles, Windows installation and time budget with A06/A07/A16 before expanding the validator. Do not add empty Windows jobs now. Genuine Gate A/B human operator/peer approvals remain separate.

Next action: parent reviews these three decisions and prepares the explicit D1 owner choice while A02 completes. Then assign one A03 writer to the rebased PS candidate, first proving D2's event fixtures and D3's finite contract interface. A03 acceptance still requires affected tests, native PR graph evidence, remote review/final quality, normal merge, paired port/reverse comparison, and an explicit D1 disposition. Final refs/settings/callers must invalidate and refresh this design where they change.
