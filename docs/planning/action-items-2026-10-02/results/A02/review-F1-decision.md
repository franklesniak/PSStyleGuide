<!-- markdownlint-disable MD013 -->
# D-A02-11: Trusted exemption promotion

**D-A02-14 correction:** [D-A02-14](review-D-A02-14-decision.md) supersedes only this record's claim that D10's manifest-absent branch remains necessary. The complete native census supports removing that branch after policy-conformant parsing. F1's selected trusted existing-exemption promotion, known-governed/ADR protections and actual-parent comparisons remain required. The original decision below records what was selected before this later finding.

**Finding:** Codex4163722040, review5389295737, exact reviewed headfe3d6738d5b331f88e21bf6b9815883b3bb353b8. No product edit preceded this decision. The coordinator owns public step6 and must release implementation after publishing this complete decision.

**Validate.** Reproduced with the actual final helper: manifest=true makes Test-InitialMetadataCoveragePath false for README, so a valid current Tier1 header fails against its metadata-less prior onboarding text. Exact log: review-round1-reproduction.log, F1. Native docs.instructions.md content precedence permits Tier2-to-Tier1 promotion; an invalid old exempt header is not an old Tier1 policy violation. Prior governed paths must not acquire this exception through a table flag. D10's manifest-absent guard remains necessary and is reused unchanged for that branch; its blanket manifest-present rejection is the new defect.

**Stakeholders.** Maintainers and policy/security reviewers need trusted prior coverage and no candidate waiver. Contributors/new developers and documentation users need a legitimate promotion path. Auditors and DevOps need exact baseline evidence, final headers and dates. Project/cost owners need a small consumer repair, not published-history rewriting. This rule introduces no data collection, privacy or localization behavior; accessibility depends on readable diagnostics.

**Options before scoring.** A retain rejection and require history repair. B admit initial coverage only when validated trusted baseline data exempted the path and the current governed catalog requires metadata, excluding known native governed paths; retain every current/header/date check and the exact D10 manifest-absent guard. C suppress all invalid parent errors. D require a separate published header while the document remains exempt. E use candidate self-classification or authorization flags as proof. Useful combinations retain B's trusted boundary; C/E combinations remain unsafe. D adds metadata without an active consumer and does not fix the already legitimate promotion transition.

**New rubric:** trusted prior coverage45%; legitimate compatibility25%; full current validation20%; clear bounded maintenance10%. Scores1-5; total=sum(weight*score)/5. Hard constraints: no candidate-as-authority, no prior-governed escape, no published-history rewrite or blanket parent suppression.

| Option | Trust | Compatibility | Current validation | Clarity | Total /100 |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 1 | 4 | 2 | 70 |
| B | 5 | 5 | 5 | 4 | 98 |
| C | 1 | 5 | 2 | 3 | 48 |
| D | 4 | 2 | 4 | 2 | 66 |
| E | 1 | 4 | 3 | 3 | 47 |

**Select B.** Add a bounded trusted-baseline exempt-path input to the existing helper. Known native governed paths and ADR paths win before any exemption lookup. For an existing validated manifest, return true only for its exact trusted exempt path. The current caller already visits governed metadata specs and invokes the helper only when a nonversioned document's prior metadata is invalid. Pass the validated baseline exempt array; never pass candidate authorizations as prior proof. Preserve original ParentContent for lifecycle/evidence and null only MetadataParentContent for the proved initial metadata transition. Valid prior headers still use their ordinary parent checks. Preserve current header/calendar/nonfuture/finalization checks. Keep initial absent-manifest native SHA256 proof unchanged.

**Required tests.** Actual helper+caller fixture for trusted exempt promotion with invalid parent and valid current header passes; stale/malformed current header fails. Existing manifest with nonexempt invalid parent fails. Candidate-only future authorization and known-governed/ADR reclassification cannot waive prior checks. Valid metadata parent remains compared and backward dates fail. Exercise actual bounded Git-object base/candidate arrays, not a candidate flag masquerading as trusted data.

**References and limits.** Native docs.instructions.md Tier1 precedence and finalization clauses; immutable fe3d673 Test-AgentInstructions.ps1 lines297-345 and6757-6779; D10; exact real-helper reproduction. Environment PS7.6.5/Python3.12.10/Node24.18.1. No older-host or full paired acceptance claim. The common D10 helper byte convergence remains A02/A06/A18 open. Implementation and full final validation are pending public step6/release. Step8 no-new-guide recommendation will be made only after the applicable guide audit and actual repair evidence.
