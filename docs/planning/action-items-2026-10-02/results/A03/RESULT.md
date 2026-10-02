<!-- markdownlint-disable MD013 -->
# A03 current result

State: waiting_human. [A03-D1](design.md#decision-a03-d1-maintenance-admission-and-freshness) now includes concrete option L alongside P. No owner box was selected and no product or setting was changed.

Review the exact [PS patch](option-L-PS.patch), [TF patch](option-L-TF.patch), and separate [proposed PS ruleset variant](desired-ps-ruleset-option-L.json). The existing A12 ruleset proposal is unchanged. Prepared on PS PR224 d9b9e1c and TF main06ad4f7; rebase after PR224 merges. PS118 and TF119 tests pass, including classifier/workflow-policy regressions and real approval-helper CLI failures; [validation and limits](option-L-validation.json).

Retained label payloads do not identify who applied them. This proposal therefore requires a fresh owner-account `labeled` event for `maintenance-approved`; later maintenance events and reruns require reapplication. It checks payload identities and uses no token, but does not prove live label state, event ordering, human intent or immutable Actions provenance. Current native merge checks and independent review remain necessary. These limits and the repeated owner action must be part of the L decision.

Next: await the owner's L/P choice. If L is selected, implement PS after PR224 merges, validate actual native check behavior, and obtain A13 authority before activating the required context. Then apply the accepted design to TF with its separately required settings authority. A21 owns the classifier implementation; A03 coordinates that interface.
