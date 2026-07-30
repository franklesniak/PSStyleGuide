# Criticism of the revised TerraformStyleGuide issue slate

## Review basis

This fixed-point review compares T1, T1A, T1B, T2, T3, and T4 with the latest
P1, P1A, P1B, P2, and P3 contracts, assuming each repository executes its one
listed sequential graph. It rechecked every prior Terraform criticism and
looked for newly exposed ambiguity after the PSStyleGuide cycle-2 changes.

## Result

No actionable TerraformStyleGuide issue-slate finding remains.

The previous findings are closed:

- T1/T3 now define only **T1 → T1A → T1B → T2 → T3 → T4**; advisory policy is
  a stop/rebaseline gate, not an alternate graph.
- T1/T1B freeze manifest/lock/toolchain/tree/audit inputs at implementation and
  pre-merge boundaries.
- T1A has 139 unique physical IDs, behavior-named semantic keys, singular
  per-row oracle authority, and zero-call disposed/retained terminal behavior.
- T1B names literal diagnostic producers, paths, limits, artifact names,
  conditions, and upload inputs.
- T2 owns its reusable native-Git evidence helper, uses the bounded 20-digit
  HCP page grammar, freezes the dated S3 reservation set plus `-an` policy, and
  requires Bash 4.4.0.
- T3 separates observed facts from approvals, physically allocates Node,
  manager, hook, Husky, capture, and 184 audit cases, fixes the weekly cron,
  binds one literal package-operation preimage/digest, and closes live retry/
  reset-header behavior.
- T4 has one complete state-bearing role authority, two mandatory internal
  review gates, and backend-specific state-rm argv with protected pull recovery
  in every mode and a local-only command backup.

## Cross-repository convergence

The shared layers now have explicit comparison surfaces:

- generator bytes, file replacement, LF/BOM behavior, script versions, Git
  identity, and affected-path evidence;
- candidate archive, containment, lifecycle/zero-call cleanup, physical
  semantic cases, expected production outcomes, and harness verdicts;
- artifact/action/job graph, diagnostics, approval, sole writer, credential
  lifecycle, isolated real-ref evidence, temporary-equivalent/persistent
  rulesets, and exact-lease publication; and
- Node/Corepack/npm identities, literal package operations, physical policy/
  hook/audit/live-client cases, observed-versus-approved residual governance,
  schedule/manual read-only paths, and Dependabot review-only state.

Different local case counts, P2 versus T2/T4 product work, staged versus full
lint, and Terraform state-file roles are explicitly repository-specific and do
not weaken the shared security properties.

## Convergence judgment

This review is a no-finding fixed point for the TerraformStyleGuide slate. No
issue draft should be added, deleted, renamed, reordered, or revised from this
review.
