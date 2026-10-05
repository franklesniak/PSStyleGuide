<!-- markdownlint-disable MD013 -->
# PR234 R7: independently test final-to-candidate identity rejection

Candidate preimage: HEAD07636c8633b8544eb30c71ce1b24d2bcdef4c74e, tree01e26ec47626495e76a29fe5cb407a02781d5d7a. Only product authority: .github/workflows/Test-StyleGuideGenerator.ps1. Root owns integration, full aggregate, native operations and review clocks. This is a retained negative-oracle coverage gap, not a demonstrated production failure.

## 1. Validation

The actual generator reads final identity before and after the byte read (lines1956/1960), rejects unstable final identity (1961), then independently rejects final identity unequal to candidate identity (1964). The catch returns artifact and overall ReplacementStateUncertain after publication. PublicationUncertain is a descriptive concept here, not the emitted schema value.

The shipped harness checks successful candidate/final equality (237–239). Its post-publication throw (338–350) occurs before the first final identity read. Its independent stat mutants (386–405) remove native-exit, output-cardinality or link-count guards. None supplies stable same-byte/different-identity final observations or independently kills removal of final-versus-candidate rejection. Bounded repository searches for final identity fields, mismatch diagnostics, equality mutations and uncertainty found no alternate shipped negative oracle.

Primary local requirements remain: results/A06/threat-map.md10 retains injected same-byte/different-identity failure and11 requires an independently killable equality mutation. design.md63/69/78 requires useful publication/identity controls, independently killable identity mutations and final-to-candidate equality. postTF67-readiness/REPORT.md69 retains candidate/final identity and uncertainty. No relocation or retirement is present in these bounded accepted records. Historical test retirement is not proof of relocated coverage.

## 2. Stakeholders

PS and TF maintainers need a shared regression that detects loss of candidate binding. Artifact users and supply-chain reviewers need failures after publication reported truthfully. New contributors need stable-final-read and candidate-equality checks distinguished. QA and independent reviewers need a mutation killed by the intended oracle. Windows5.1/7 and Linux7 operators need a deterministic portable test without privilege, execution-policy or tool changes. CI/cost owners need bounded additional work. History custodians need prior evidence preserved. No new cloud, privacy, dependency, recovery authority or public guide contract is introduced; concurrent-writer protection remains outside this repair.

## 3. Options before scoring

- A: Keep existing positive equality and generic uncertainty tests. Deferral has the same missing oracle and maps to A.
- B: Extract the actual publication verification block and inject controlled identities/bytes; independently disable only candidate equality; assert the thrown mismatch and uncertainty via a focused wrapper.
- C: Inject only both final identity measurements in disposable full-generator copies; keep real publication and byte reads; execute original and candidate-equality-disabled copies through existing child/JSON harness. Cover Replace and Move.
- D: Add a deterministic production publication hook to swap objects, then test actual different identities and a guard mutant.
- E: Run an actual competing-writer race repeatedly and expect a detectable substitution.
- F: Retire the candidate-identity negative requirement and rely on content hashes and positive checks.

B+C duplicates the focused oracle without a distinct needed guarantee. C uses existing native child/fixture tools; no new framework is needed. An actual same-byte replacement via a production hook exceeds scope and adds production attack/test surface. E cannot establish deterministic reachability. F needs an owner retirement and violates the retained safety obligation; removal of that guarantee is ineligible. A is also ineligible for task completion.

## 4. New rubric before scoring

Scores1–5:1 fails,2 weak,3 adequate with a material limit,4 strong,5 fully meets this bounded need. Total=sum(weight times score)/5. Scores are engineering judgments, not experimental results.

- Retained refusal coverage40%: reach final candidate mismatch with equal real bytes and stable final observations; verify post-publication uncertainty.
- Oracle independence25%: kill removal of only the candidate-equality guard without relying on final-read instability, byte drift or unrelated refusal.
- Execution fidelity15%: exercise actual publication/result/native-status paths and minimize reconstructed production behavior; synthetic boundaries must remain explicit.
- Host reliability10%: deterministic across supported hosts without privilege, timing races or runtime policy changes.
- Maintenance5%: bounded readable fixture changes without production hooks or scope expansion.
- Execution cost5%: meaningful coverage with limited extra child/process work.

Hard constraints: preserve production and golden bytes; change only the authorized harness; retain current controls; no skipped platform substituted for actual hosted evidence; no injected identity labeled native race proof. D fails the scope constraint; F/A fail the retained coverage constraint regardless of totals.

## 5. Scores before selection

| Option | Coverage40 | Independence25 | Fidelity15 | Reliability10 | Maintenance5 | Cost5 | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 1 | 3 | 5 | 5 | 5 | 42 | Missing negative oracle; ineligible. |
| B | 5 | 5 | 3 | 5 | 4 | 5 | 93 | Extracted verification/wrapper omits actual entry-point result behavior. |
| C | 5 | 5 | 5 | 5 | 4 | 3 | 97 | Four bounded extra child runs; identities are injected, not native substitution evidence. |
| D | 5 | 5 | 5 | 3 | 2 | 2 | 90 | Production hook exceeds scope and adds machinery; ineligible. |
| E | 2 | 2 | 5 | 2 | 2 | 1 | 48 | Timing can miss intended branch; cannot reliably kill the exact guard mutant. |
| F | 1 | 1 | 1 | 5 | 5 | 5 | 36 | Unapproved retirement of retained guarantee; ineligible. |

## 6. Selected action

Select C. Use the existing disposable repository. Check that each injection target occurs once in the actual generator source. Replace both final identity measurements with one stable identity that differs from the candidate. Keep the real final-byte read. For File.Replace and File.Move, run the injected generator and require native failure. Require verify-publication and filesystem-state-uncertain. Require artifact and overall ReplacementStateUncertain. Require successful publication, equal lengths and hashes, and unequal candidate/final identities. Compare all four outputs to their independent goldens.

Create a second scratch copy from the injected source. Disable only the final-versus-candidate comparison. Keep final-read stability and byte checks intact. Run the same two publication cases. Require native success and successful artifact/result status with the same equal-byte/different-identity observations. This makes the original refusal oracle fail under the exact guard mutation. Restore the scratch generator after the controls. Keep every prior test. Keep version1.0.20261005.0: this is the same unpublished landing change under STYLE_GUIDE.md1025/1038. Do not alter the production generator. Do not claim native object substitution, a race closure, or hosted results from local tests.

Instructions use short direct actions; formal ASD-STE100 dictionary compliance is not claimed. Relevant semantics are established by the exact repository implementation and local requirements above; no uncertain external API claim requires new web research.

## 7. Verification plan and boundary

After this decision is saved, edit only the named harness. Run its actual Windows7.6.5 process with ExpectedHost=WindowsPowerShell7. Parse/analyze the changed file and check the diff. Preserve decision-before-edit timestamps and raw hashes. Root owns final-byte aggregate, hosted Windows5.1/Windows7/native-ext4 Linux7 proofs, commits and publication. Save outcomes in REPORT.md/evidence.json here. No broader test repeat or product repair is selected.
