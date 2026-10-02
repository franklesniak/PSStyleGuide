<!-- markdownlint-disable MD013 -->
# F6: retain generated-category provenance

Status: selected repair implemented; focused validation and the final normal pre-commit passed. Parent owns integration and native operations.

## Validated finding

Codex review5394588826/comment4168004991 on519c420738f8f8c9c1b185dfa68138b89974343e identifies an installed-manifest admission defect. The actual helper compares only the union ExemptPaths. A Tier2-to-generated move preserves that union but removes F5 optional-header validation. The exact existing accepted-B/H classification Git fixture, with one scratch-only case insertion, accepts README reclassified as generated with Status Broken and date2099-99-99. Parsed candidate Tier2Paths is empty. Original admission, authorization and workflow-placement controls still pass. See reproduce.ps1/log. The independent reader separately confirmed the union failure. Native48f's absent-table initialization already compares exact categories; it is not the defective branch and remains unchanged.

The schema rejects duplicate/cross-category entries and overlap between active paths and authorizedExemptionPaths. The latter contains exact future path authorizations, not typed category grants. Candidate-only grants do not authorize the same change. Existing trusted authorization permits a later exemption activation. F5 treats Tier2 as optional-header validation and generated as source-generated semantics; their union is not an adequate trust boundary.

## Stakeholders and constraints

Documentation authors and readers need intentionally adopted metadata checked. Generated-artifact consumers need aggregates excluded from author-header parsing. Both maintainers, future A21 integrators and CI/agent operators need an explicit stable admission rule with a usable authorization route. Security and independent reviewers need actual accepted-base provenance and negative controls. History custodians need native closed initialization and existing review evidence preserved. Sole-maintainer time and Windows/Linux contributors favor the existing schema, tools and bounded fixture. No credentials, cloud/state operations, external service, accessibility or localization behavior changes.

Hard constraints: do not treat candidate content or same-change authorization as trusted; preserve the known native closed initializer; preserve valid published authorization-to-activation and exemption removal; do not force generated aggregates through author-header parsing; do not claim workflow immutability, owner approval, generator correctness or current-main freshness from this data guard. No protected text change.

## Options and new rubric

N: retain union-only admission or defer this confirmed gap. S: reject every category change, including generated-to-Tier2. G: retain union expansion checks and separately require candidate generated paths to be generated or explicitly authorized in trusted B. T: introduce typed category authorizations/new schema and migration. U: validate every generated document as ordinary optional author metadata. H: infer generated status from filenames or content markers. E: defer to a future external authority producer. A shared helper with new configuration has no extra consumer need here; G reuses the existing admission helper and parsed context. A per-README exception is H and misses sibling paths. Removing category admission entirely is weaker than N.

Fresh criteria, scored0–5: bypass prevention40; policy/category fidelity25; trusted authorization and legitimate transitions20; maintenance10; implementation cost5. Total=sum(weight*score)/5. High totals cannot waive the constraints. Scores are merits judgments, not measured probabilities.

| Option | Prevention40 | Fidelity25 | Authority20 | Maintenance10 | Cost5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 0 | 2 | 2 | 5 | 5 | 33 |
| S | 5 | 3 | 3 | 5 | 5 | 82 |
| G | 5 | 5 | 5 | 4 | 4 | 97 |
| T | 5 | 5 | 5 | 2 | 1 | 90 |
| U | 2 | 0 | 3 | 3 | 3 | 37 |
| H | 1 | 2 | 1 | 1 | 2 | 26 |
| E | 1 | 3 | 2 | 2 | 1 | 36 |

N/E leave the current bypass. S unnecessarily rejects moves to stronger validation and lacks the existing authorization route. T could represent a one-step typed migration but adds a schema/interface migration without a current caller requiring it. U breaks generated aggregates. H is forgeable and does not prove origin. G preserves current declared authority semantics and blocks the specific weakening; its extra category inputs are private mandatory parameters rather than a public interface.

## Selected solution

Select G. Keep the existing union expansion rule. Pass the trusted baseline generated paths and candidate generated paths to the existing helper. Require each candidate generated path to be generated in the trusted baseline or present in its authorizedExemptionPaths. Reject an unauthorized Tier2-to-generated move. Do not use the candidate authorization list for this check. Keep ordinal path comparison. Iterate each already schema-validated path directly; do not culture-sort or collapse paths before checking authority.

Allow unchanged categories. Allow generated-to-Tier2 and exemption removal; these restore validation and must pass the applicable document checks. Preserve authorized activation into either category. Because active paths cannot also be authorized under schema2, an existing Tier2 path must first leave the active exemptions and receive a published future authorization before later generated activation. The intermediate ordinary document must satisfy its applicable metadata policy. This is the existing two-step contract, not a new direct category-grant API. A future demonstrated need for a different migration would require a separate scoped decision.

Change only Test-AgentInstructions.ps1 and its SelfTest. Add two mandatory private category arguments and carry parsed trusted/candidate values at the existing pre-branch caller. Keep MetadataClassificationOnly, endpoint guards, all safe readers, F1–F5, and the exact absent-table initializer. No manifest, workflow, protected file or public mode changes. Broader A03-D1 authority remains unresolved; this repair does not supply that authority.

## Verification plan

Before the final freeze, exercise the transition table: unchanged Tier2/generated; Tier2-to-generated blocked; generated-to-Tier2 allowed; category swaps blocked when they introduce generated status; either exemption removed; new Tier2/generated paths blocked without prior authorization; exact published authorization activates either category; wrong/candidate-only/same-change authorization fails. Retain schema duplicate/overlap/known-governed conflict and closed initialization negatives. Use parsed actual contexts, not fabricated category/union inconsistencies.

Extend the existing bounded accepted-B/H classification CLI fixture with the category weakening negative and legitimate sibling/authorization controls. Confirm it executes accepted code even when candidate code is hostile. Reuse unchanged F5 content/date/Version evidence: admission must reject the category weakening before any metadata payload can escape. Run focused helpers and this actual caller before freezing. Run one normal full final-byte pre-commit with Node24.18.1/npm11.16.0 and Python3.12, then read back the exact tree/raw hashes/modes and scope. Parent owns publication, independent final quality and review clocks. Transfers0/12 and the original deadline remain unchanged. A07 stays frozen.

## Admission identity sibling

Before freeze, parent identified that Sort-Object -CaseSensitive -Unique collapses ordinal-distinct Unicode paths. The exact parsed-context probe confirms two valid candidate generated paths become one iteration key; moving the zero-width-joiner variant from Tier2 into generated then yields no failure. This affects both the existing union loop and the added generated loop. The parser already enforces ordinal ordering/uniqueness and the trust sets use StringComparer.Ordinal. Selected G therefore iterates those validated arrays directly. This removes redundant culture-based elision without a new path policy or schema. Add joiner and composed/decomposed negative controls plus exact authorized controls; preserve all parsed paths. This is the same F6 per-path admission invariant and does not change its options, weights or ranking.

Fixture note: the first focused run correctly rejected the category move, but PowerShell wrapped the diagnostic between the reason and path. The exact CLI oracle now accepts PowerShell line-wrap presentation at that boundary while still requiring the generated-status reason and README path. No production behavior changed; rerun the affected focused fixture.

## Final verification

Focused session61269 exited0. The existing classification/schema/closed-initializer controls and18 parsed category/authorization/ordinal-path cases passed. The real accepted-B/H admission fixture rejects the category weakening even with hostile candidate code and preserves published authorization activation. Actual full-content generated-to-Tier2 calls accept valid metadata, reject malformed current metadata and retain/reject an invalid prior header. The independent reader also reproduced both original Unicode admission failures and reviewed the final candidate.

One complete normal `py -3.12 -m pre_commit run --all-files` passed all10 hooks under Node24.18.1/npm11.16.0. Session89930 started2026-10-02T17:30:20Z and returned exit0, observed17:58:25Z. See precommit.log. No final aggregate was restarted. PSScriptAnalyzer reported no Error diagnostics; diff-check passed.

Final readback confirms tree5406a2e77ed9d8d8230e24fd978c0f5d1ef15488 on519c420738f8f8c9c1b185dfa68138b89974343e, only the two assigned staged files, no unstaged changes, and modes100644. Validator blob624ac38fdd43e40e0af94d47926b40276507d949 / SHA2562c1f10f31828128f38af6d026351cbe085760cbfbbbba925283585984f71a01f; SelfTest bloba928050115f59f88dda9d87e7bafa1603b87ba1e / SHA256e9a28e9ec804b2d28099e5962d1a120449a4476995908f069f29ec7cbf55edd6. Product ownership is returned to the parent. No commit, push, native mutation or A07 edit was performed by this worker. Proposed-code proof does not supply installed-native or owner authority.

Parent publication: normal commit `b8976a4b4c42d2c888051bbef015c45ba3daeac9` has the exact reviewed tree `5406a2e77ed9d8d8230e24fd978c0f5d1ef15488` and is published without force. Actual proposed-code B `48f4d8a36c8faceee12afac78aaecea0d176125d` / H `b8976a4b4c42d2c888051bbef015c45ba3daeac9` finalization and classification calls both exited0; finalization captured UTC2026-10-02. The accepted-base fixture remained at B with the reviewed staged tree and no unstaged changes. [Local quality](F6-quality.md) reconciles the actual commit and validation. Fresh current-head reviews and CI remain required; this is not merge or paired acceptance.
