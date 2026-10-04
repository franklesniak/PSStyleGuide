<!-- markdownlint-disable MD013 -->
# TF66 R10: missing tooling remedy

Input H4375f2e3c98a6aeb0dd916d26620ed63a42abafe/tree099bb0f83403b6b61cfa2dafa73916b315c791d3; actual B06ad4f7c9b6847028cafdacf1ae55128d0f2d56c. Authenticated Copilot Lite review5407690955, comments4178895861 and4178895960. Native snapshot round2-observation-08.json. No new material design or product change is warranted for these two comments.

Selected no change, applying [A07 R96 hook prerequisite decision](review-TF-hook-prerequisite.md). The full decision was read. It explicitly removed an obsolete markdownlint-cli2 binary sentinel while retaining the actual staged checker as the tooling gate and retaining staged/outer/nested phases.

Current lint-staged-markdown.mjs loads the API within try/catch, reports the actual cause and prints `Rebuild the locked tools: node .github/workflows/NpmTools.mjs install`, then exits tooling status2. The unchanged shell hook refuses that status and exits1. Root executed that actual hook/checker in a private dependency-free repository: exit1, both module-load cause and exact recovery command present. Thus the missing targeted-remedy allegation is disproved. A new directory/presence sentinel would duplicate dependency knowledge and cannot prove importability; that alternative was already considered in R96.

Primary source: [actual staged tooling failure](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.github/workflows/lint-staged-markdown.mjs#L109), [hook](https://github.com/franklesniak/TerraformStyleGuide/blob/4375f2e3c98a6aeb0dd916d26620ed63a42abafe/.husky/pre-commit). Root evidence: round2-copilot-validation/R10-actual-hook-missing-tools.log and results.json. No rerun or new sentinel is proposed. Historical R96 discussion of then-shorter PS topology does not override today's accepted common three-phase hook.

Root checked current applicability and selected the existing decision. Public reply and thread resolution remain pending.

Generated with Codex
