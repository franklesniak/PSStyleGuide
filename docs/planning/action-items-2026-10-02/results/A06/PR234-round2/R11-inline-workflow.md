<!-- markdownlint-disable MD013 -->
# R11: inline acquisition/proof duplication — retain the bounded design

Review5420961221, comment4189169357, reviewed input07636c8633b8544eb30c71ce1b24d2bcdef4c74e. This record evaluates the real maintenance opportunity; duplication itself is not denied. Product is unchanged.

## 1. Validate

Read the actual build, policy, mutation catalog and behavior tests. The two Windows acquisition bodies are text-identical after selecting their run blocks; the Linux generator and verifier acquisition bodies are also identical. They are5547/2641 characters respectively in the normalized extracted bodies. There is no current divergence in those pairs. Windows versus Linux differences implement distinct fixed Git paths, neutral configuration and credential verification arrangements, not an accidental host choice.

Acquisition starts in an empty workspace and verifies the fetched and checked-out immutable revision before repository children may run. A repository .ps1 helper therefore does not exist at the point where the reviewer proposes using it for acquisition. Loading it requires a new bootstrap/acquisition path or external trusted source, not just moving a function. D2 explicitly selected action-free immutable acquisition with fixed Windows Git and neutral configuration. Existing policy validateRunStep documents this bootstrap boundary and deliberately does not claim acquisition source spelling is proved by the policy.

Proof blocks execute after acquisition, so factoring those alone is feasible. Current policy independently defines all23 visible proof lines per platform: exact current-host executable, correct ExpectedHost, two native passes, immediate integer/nonzero checks, fixed Git path, SHA equality and revision publication. Test-CiHelpers executes each actual proof body with success/first-pass7/second-pass7/exception controls and checks absent revision on failure. The mutation catalog independently rejects proof changes. R1 fixes the actual native-exit issue. R3 preserves policy/workflow/test independence. R4 tests both actual Linux acquisition bodies and Windows credential/native controls. Acquisition behavior still relies on bounded tests and maintenance review; this is not a universal equivalence or shell-safety proof.

The opportunity is fewer repeated lines versus new helper trust/input closure, policy admission and diagnostics surfaces. No unsupported drift or failure is demonstrated. A full merits table is recorded because the proposed factoring would alter a selected caller/security architecture, not because line count alone establishes a defect.

## 2. Stakeholders

CI/security owners need code-free acquisition until exact checkout and unchanged token-free permissions. Windows/Linux operators need the correct fixed host paths and shell behavior. PS/TF maintainers and new contributors benefit from reuse but also need finite, visible caller contracts. Reviewers/QA need independent proof expectations and actual-body negative controls rather than a shared mistaken source of truth. Supply-chain auditors need an explicit bootstrap trust chain. Cost owners need sustainable maintenance, not churn as an overriding objective. No artifact semantics, privacy data, cloud permissions or recovery authority changes are needed.

## 3. Options before scoring

- A: Retain current inline acquisition/proof and its independent policy/behavior controls. No-change and deferral of an unneeded factoring project have the same current behavior.
- B: Move acquisition and proof directly to repository helpers and invoke them before checkout, as a literal reading of the proposal.
- C: Keep acquisition inline; factor only post-acquisition proof into a parameterized repository helper, adding its classifier/input closure and independent policy/behavior verification.
- D: Replace the finite jobs with a reusable workflow or matrix that centralizes acquisition/proof while preserving host and same-revision result admission.
- E: Generate or alias shared inline blocks from a separate source, adding consistency validation while retaining emitted workflow behavior.
- F: Acquire a separately pinned external bootstrap/helper before repository acquisition, then invoke shared scripts.

B+C reduces to C when the acquisition trust constraint is enforced. C plus D or E adds two abstraction layers without an established additional control. Removing platform proofs or credential checks violates D2/R1/A03 admission and is ineligible. An external action or credential-bearing checkout is not presumed authorized. D/E feasibility and YAML/platform details would need their own bounded validation before implementation; they are alternatives, not claims of tested support.

## 4. Finding-specific rubric before scoring

Scale1–5:1 fails,2 weak,3 adequate with material limitations,4 strong,5 fully meets this actual supported need. Total=sum(weight times score)/5. Scores are judgments, not measurements.

- Bootstrap trust35%: helpers cannot be read from an absent/unverified checkout; preserve credential-free immutable acquisition and fixed host authority.
- Proof admission25%: retain independent current-host/two-pass/native-status/revision checks with no new opaque helper admission gap.
- Review/negative-oracle clarity20%: make actual executed bodies and independently defined expectations inspectable; preserve mutation attribution across platforms.
- Maintainability15%: reduce concrete update/drift work without new configuration ambiguity or cross-repository input families.
- Migration cost5%: avoid unnecessary lifecycle/runtime/input-closure work. Cost cannot override any safety requirement.

Hard constraints: no pre-trust repository helper; no new permission/credential grant; no loss of current independent controls or same-revision required-verifier admission. B is ineligible. F would need explicit expanded source/authority review. All alternatives must retain D2/R1/R3/R4 semantics; no score authorizes expansion.

## 5. Scores before selection

| Option | Bootstrap35 | Admission25 | Clarity20 | Maintenance15 | Cost5 | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 5 | 5 | 5 | 3 | 5 | 94 | Duplicate edits remain; actual bodies and independent controls are already present. |
| B | 1 | 5 | 3 | 5 | 2 | 61 | Repository helper absent before acquisition; ineligible. |
| C | 5 | 4 | 4 | 4 | 3 | 86 | Feasible, but current exact proof admission must gain a separately reviewed helper/input contract. |
| D | 5 | 4 | 3 | 4 | 2 | 81 | New role/output/host wiring and policy architecture without a demonstrated admission benefit. |
| E | 5 | 4 | 3 | 4 | 2 | 81 | Adds generated-source consistency/input ownership; shared mistakes can cross independence boundaries. |
| F | 3 | 5 | 3 | 3 | 1 | 68 | New external trust acquisition and pin maintenance; no current requirement justifies it. |

## 6. Selected controlled-English action

Select A. Keep the current workflow and helper boundaries. Do not load a repository helper before exact checkout. Keep platform proof bodies visible to the independent policy. Keep each actual-body failure control. Apply future shared acquisition changes to both host-specific callers and validate each caller. Do not claim that duplication is impossible or that acquisition is fully source-validated. Revisit factoring only when a concrete requirement warrants its trust and input-closure work. No additional product path or current implementation is selected.

These are direct controlled-English instructions; formal ASD-STE100 dictionary compliance is not claimed. Primary evidence is the exact local workflow/policy/test implementation and accepted D2/R1/R3/R4 records. No new external API behavior is relied on. This is a present merits decision, not permanent prohibition of helpers or arbitrary deferral of a demonstrated defect.

## 7. Verification and limits

Read-only source comparison confirmed both current acquisition pairs equal. Inspected actual proof policy and existing negative test definitions; did not rerun them or relabel earlier results as current execution. No new helper, workflow, selector, dependency, native setting or product change. Root owns reviewer attribution and public disposition. The proposed finite round2 product repair remains R10's harness-only change.
