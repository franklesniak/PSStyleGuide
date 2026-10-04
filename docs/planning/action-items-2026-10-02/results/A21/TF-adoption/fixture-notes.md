<!-- markdownlint-disable MD013 -->
# Retained actual-checkout fixture counterpart

Failure: original aggregate27780 passed10 hooks/content, then read absent PS `docs/P1-SUPPLY-FREEZE-v1.md` from TF B06ad; all78 inputs and1910 dependencies remained unchanged.
Cause/fix: one retained fixture literal was not mapped to A09's existing TF `docs/T1-SUPPLY-FREEZE-CURRENT-PROVENANCE-v1.md` counterpart; root applied exactly that one replacement.
Preserved:17 placement positives,18 negatives,16 transitions, required-Version removal refusal, and all four actual-document reads with8-byte rejection, metadata and initial-coverage checks; no production or guide change.
Test: the extracted preimage reproduced the missing-path failure and the corrected function passed; a census of26 root-variable uses,18 explicit real paths,12 setup inputs and7 dependency directories found no further actual-checkout omission.
Evidence: [candidate record](../../A02/coherent-peer-candidate.json) retains original failure/hash and exact focused commands; repaired staged tree37c7270 passed preflight at14:18:45Z; replacement aggregate49058 and independent reconciliation remain pending.
