# FQ45 validation selection

Failure and cause: initial R4 reuse included identity1, but its FQ7/FQ8 subcases execute two changed Linux credential prefixes and two corresponding Windows forms.
Fix and validation: run identity1/14 Linux children fresh; preserve historical receipts and completed source/syntax/dependency checks. Two readers confirmed the dependency. Current syntax covers the changed prefixes; fresh identity1/14 passed native0/f609b9 in session82253 and is included in the accepted163-case union.
Evidence: [current syntax attribution](current-main-validation/pr239-round4-generated-syntax-attribution.json), [dependency review](current-main-validation/pr239-round4-reuse-selection-review.md), and [complete Linux acceptance](current-main-validation/linux-current163-acceptance.json). This D07 private validation correction changes no product code or policy and grants no semantic reuse credit.
