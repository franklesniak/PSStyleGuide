<!-- markdownlint-disable MD013 -->
# F6 frozen-tree quality review

Disposition: scoped approval; no concrete blocker remains in the two-file F6 repair inspected. This is a read-only source/diff and saved-test-evidence review. No new probes, fixtures, or tests were constructed or executed during this review. The earlier interrupted review attempt is not credited as quality evidence.

Compared immutable tree `5406a2e77ed9d8d8230e24fd978c0f5d1ef15488` with parent `519c420738f8f8c9c1b185dfa68138b89974343e`. Exactly two paths change (152 insertions, 12 deletions), both mode 100644:

| Path under .github/workflows | Blob | Raw SHA256 |
| --- | --- | --- |
| Test-AgentInstructions.ps1 | 624ac38fdd43e40e0af94d47926b40276507d949 | 2c1f10f31828128f38af6d026351cbe085760cbfbbbba925283585984f71a01f |
| Test-AgentInstructions.SelfTest.ps1 | a928050115f59f88dda9d87e7bafa1603b87ba1e | e9a28e9ec804b2d28099e5962d1a120449a4476995908f069f29ec7cbf55edd6 |

The category check now receives generated paths parsed from the selected published baseline, alongside candidate generated paths. It rejects newly generated status unless the exact path was already generated or explicitly authorized in that baseline. Candidate authorizations remain inert. Union-expansion admission remains in place. Both loops directly enumerate schema-validated arrays and use ordinal membership sets, removing the culture-based deduplication that omitted distinct Unicode paths. The new check executes before the data-only return and ordinary parser bootstrap. The missing-manifest closed initializer is unchanged.

Legitimate unchanged categories, generated-to-Tier2 moves, removals, and prior exact authorization remain supported. The canonical F6 decision accurately documents the two-stage route needed to reclassify an active Tier2 path under the existing disjoint authorization schema, including the intermediate document's applicable validation. It does not grant owner authority, claim immutable workflows, or change protected instructions. Its option totals are arithmetically consistent; the ranking remains a documented engineering judgment rather than measured evidence.

The permanent tests are relevant to the repair: 18 parsed transition cases include ordinary weakening, swaps/removals, unauthorized additions, exact prior grants, joiner collisions in both admission paths, composed/decomposed distinction, and exact Unicode authorization. The actual admission fixture retains accepted-base execution and verifies rejection of the weakening while candidate executable bytes cannot supply authority. Separate full-content generated-to-Tier2 controls cover valid current metadata, malformed current metadata, and invalid prior metadata. Inspection of the fixture's baseline checkout confirms the invalid-prior control is built from the generated baseline; it does not accidentally test only a Tier2 parent.

Saved `F6/focused.log` reports PASS for helper/schema/closed-initializer plus the 18 transitions, actual accepted-B/H admission and workflow placement, and generated-to-Tier2 valid/malformed/prior-header caller controls. This review inspected those reports and their corresponding test code; it did not independently rerun them. The CRLF normalization warning is not reported as a failure.

Earlier whole-PR and F5 evidence remains scoped to its identified inputs. This bounded F6 diff changes neither the workflow/bootstrap trust root nor protected content, and the earlier generic trust-boundary caution is not converted into a human attestation. No additional full-validator issue is inferred from adjacent sorting sites without demonstrated behavior.

Pending gates: the final normal aggregate, actual new commit and exact base/head finalization/classification endpoints, fresh remote review results, and current native CI/check state. This tree review does not complete the PR merge gate or certify native settings/owner approval.

## Actual-commit reconciliation

Disposition: local quality approved for actual commit `b8976a4b4c42d2c888051bbef015c45ba3daeac9`, subject to the remaining remote gates. No concrete local blocker remains in this review.

Read-only Git inspection confirms parent `519c420738f8f8c9c1b185dfa68138b89974343e` and tree `5406a2e77ed9d8d8230e24fd978c0f5d1ef15488`, exactly matching the frozen-tree review above. The product worktree status is clean. The actual commit changes only the validator and its SelfTest relative to that parent, with no additional post-review bytes. The PR-wide diff against native base `48f4d8a36c8faceee12afac78aaecea0d176125d` remains the same eleven paths; no new protected or workflow path enters the F6 change. Prior whole-PR scope evidence remains applicable within its stated boundaries.

Saved `F6/precommit.log` reports all ten normal hooks Passed, including workflow policy and agent instruction contract/mutation tests. Parent reports terminal aggregate session 89930 exited 0 at 17:58:25Z and the normal Husky commit succeeded. The exact tree identity ties those reviewed bytes to the actual commit; this review did not rerun the aggregate.

Saved `F6/actual-finalization.log` reports the content contract passed and author finalization checked UTC date 2026-10-02 with exact B `48f4d8a36c8faceee12afac78aaecea0d176125d` and H `b8976a4b4c42d2c888051bbef015c45ba3daeac9`. Saved `F6/actual-classification.log` reports classification data validated for those same endpoints. Parent reports both commands exited 0 in the accepted-base D14 fixture, with its baseline HEAD and staged reviewed tree preserved. Logs expressly separate metadata/content validation from maintenance, first-install, owner, and merge authority; this reconciliation preserves that distinction.

The F6 category-provenance and ordinal-path findings are closed by the reviewed repair and saved focused evidence, as detailed in the frozen-tree review above. This reconciliation adds actual commit, normal aggregate, and real endpoint evidence. It does not execute new probes, create fixtures, or claim independently rerun tests.

Remaining gates: fresh authenticated remote reviews for this actual head, current native CI/check results, and the parent's immediate native head/base/body/thread/settings reconciliation before any merge. Previous reviews on 519c420 do not establish acceptance of b8976a4. No new remote review or CI is accepted by this report, and the whole PR merge gate remains open.
