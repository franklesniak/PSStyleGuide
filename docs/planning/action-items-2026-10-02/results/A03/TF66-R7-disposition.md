<!-- markdownlint-disable MD013 -->
# TF66 R7: hosted authority selector

Input H4375f2e3c98a6aeb0dd916d26620ed63a42abafe/tree099bb0f83403b6b61cfa2dafa73916b315c791d3; actual B06ad4f7c9b6847028cafdacf1ae55128d0f2d56c. Authenticated Copilot Lite review5407690955, comments4178895861 and4178895960. Native snapshot round2-observation-08.json. No new material design or product change is warranted for these two comments.

Selected no change, applying [A03-D7 M98](hosted-audit-decision.md). The full decision was read. Its selected design deliberately separates event-main immutable authority from the remote-main selector for non-main contexts. Current hostedAuthorityReference returns the reference selected by hostedContext; it is exported for tests. Repository source search found only Check-NpmAudit.test.mjs consumers, whose current main/non-main expectations explicitly include the string refs/heads/main. Root's selected existing selector test passed on pinnedNode24.18.1.

The actual audit path uses readHostedContext -> readAcceptedBase, not this test export. readAcceptedBase fetches fixed-repository main when source is remote-main, immediately resolves FETCH_HEAD into a checked full nonzero SHA, and reads the regular exception blob at that SHA. It returns an object with sha/source/exceptions. Event-main paths use exactCommit, which rejects any identity mismatch. The ordinary local path resolves local origin/main. These are the selected M98 contracts; no reference string is mistakenly read as an already-resolved accepted SHA.

The observation that the selector can return a ref is true; the claimed caller break is not established in this repository. No advertised external versioned API or undisclosed external consumer is proved. Converting a pure selector into a fetch operation or changing its exported test shape would change the accepted responsibility without repairing a demonstrated caller. Preserve existing actual authority/diff controls and M98 tests. Native exact-H success is corroborating existing evidence, not proof about hypothetical external callers.

Primary source: [selector and hosted context](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.github/workflows/Check-NpmAudit.mjs#L200), [actual immutable reader](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.github/workflows/Check-NpmAudit.mjs#L257), [current selected expectation](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.github/workflows/Check-NpmAudit.test.mjs#L362). Root evidence: round2-copilot-validation/R7-current-selector-test.log and results.json. No rerun was needed.

Root checked current applicability and selected the existing decision. Public reply and thread resolution remain pending.

Generated with Codex
