<!-- markdownlint-disable MD013 -->
# A02 heading-policy compatibility clarification

**Conclusion:** the governing PS and TF policies do not differ on a mandatory Metadata heading. Both permit a direct metadata bullet list and conditionally constrain a Metadata section when one is used. TF implements that distinction. PS's current helper unconditionally requires the heading. The PS restriction predates A02; the candidate retains it and extends its reach through newly discovered documents. This is a pre-existing PS consumer/policy mismatch with current A02 exposure, not a justified language/repository policy exception.

Read-only source assessment. No test, product/planning/native mutation, repair design or implementation was performed. Transfer remains 0/12. This clarifies the peer map's statement about TF's supported metadata form; it does not authorize a broader parser port.

## Exact governing clauses

PS native docs.instructions.md is mode 100644 blob `0b0c1ddc83938cfa9706418d45f619b1bfa03ffd` at `48f4d8a36c8faceee12afac78aaecea0d176125d`; the PR head has the same blob. TF native counterpart is mode 100644 blob `4a8f2addc02af857928205199b66cf3918ae9a82` at `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`.

Both policies have these identical clauses at the same lines:

- Line 102: the block must be document-level, outside fences/quotes/examples.
- Line 104: when an H1 appears within the first 30 body lines, the block must follow it immediately; a single optional Version line may intervene.
- Line 105: otherwise, the block follows the leading markdownlint directive or starts the body.
- Line 106: **“For documents that already use a top-level `## Metadata` section to host the bullet list”**, that section must be the first H2 after H1/optional Version and contain the list.

The qualification “already use” makes line 106 conditional. Lines 104–105 directly specify block placement without requiring a heading. The Tier 1 field list at 71–78 requires Status, Owner, Last Updated and Scope; it does not add a mandatory section title. This reading is also consistent with each repository's explicit placement wording and TF's direct-list branch.

Primary links: [PS placement](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/instructions/docs.instructions.md#L100-L107), [TF placement](https://github.com/franklesniak/TerraformStyleGuide/blob/06ad4f7c9b6847028cafdacf1ae55128d0f2d56c/.github/instructions/docs.instructions.md#L100-L107).

## Actual helpers, callers and history

At PS native 48f4, Get-DocumentMetadataContext lines 4499–4526 fails when no H2 exists, then requires the first H2 text to equal Metadata, exactly one such heading, and immediate H1/Version adjacency. The same function text remains at PR fe3d673 lines 5105–5132 and frozen candidate lines 5267–5294. Extracted function text compares exactly equal across all three; normalized-text SHA256 is `aeb84c781756ab105d053712a9f93c5437cc4b9a1fd532b366c2acb6141db85c`. This hash identifies the extracted text comparison, not a raw Git blob.

The frozen candidate's discovery call at 6765 adds tracked documents to the governed set. At 6946 it parses prior metadata before the initial-coverage decision. At 7069/7078 its versioned/nonversioned transition callers route through that same strict helper. Thus direct-list current content still encounters the unconditional heading guard, and a direct-list prior document can appear parser-invalid to the bootstrap path. A02 did not introduce the guard, but its broader discovery makes the restriction relevant to documents outside the old hardcoded catalog.

TF validator is mode 100644 blob `c84d9067c1b315e037850f2cd40e79c0704356b5`. Its Get-DocumentMetadataContext at 4288–4350 first asks whether a Metadata heading exists. If present, it enforces conditional section placement. Otherwise, it requires a top-level bullet-list block directly after H1/optional Version, within the body limit, then validates the same required field values. The unified Get-DocumentMetadataTransitionFailure calls this parser, and actual repository validation calls that transition at 6313–6321. This is an active implementation path, not a hypothetical unused helper.

Primary links: [PS native mandatory-heading branch](https://github.com/franklesniak/PSStyleGuide/blob/48f4d8a36c8faceee12afac78aaecea0d176125d/.github/workflows/Test-AgentInstructions.ps1#L4494-L4526), [TF conditional-heading/direct-list branch](https://github.com/franklesniak/TerraformStyleGuide/blob/06ad4f7c9b6847028cafdacf1ae55128d0f2d56c/.github/workflows/Test-AgentInstructions.ps1#L4288-L4350).

## What D10 establishes, and what it does not

I read the complete integrated decision-metadata-bootstrap.md before reaching this conclusion. D-A02-10 explicitly observes that native PS docs/dependency-maintenance.md has the required fields immediately after H1 but lacks Metadata. It says the candidate has the “correct heading” and that the current nonversioned transition rejects the parent. Native file blob `34c9dec3cd9f640fd3a8346583fe8b1569056fb8` confirms the direct list at lines 5–8.

D10 selects a narrow prior-coverage/bootstrap rule so a newly governed file can transition without rewriting published history. It binds the prior validator identity and does not permit blanket invalid-parent acceptance. Those are real, separately bounded controls. But its validation premise treats the existing parser's heading demand as the correctness criterion; it does not cite a policy clause mandating that heading. It does not select a protected-policy change or explicitly justify a universal stricter heading rule. Adding an optional heading to the candidate is permissible formatting; that does not establish that every direct-list document was policy-invalid or authorize rejecting future direct-list documents.

Therefore D10 explains how the candidate encountered and accommodated the mismatch. It does not turn the mismatch into a supported PS/TF policy difference. No runtime behavior beyond the inspected deterministic branches is claimed here, and no repair option is selected. Parent should account for this precise distinction before treating the parser difference as an allowed peer-transfer exception or accepting D10's “invalid parent” wording as a normative policy finding.
