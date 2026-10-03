<!-- markdownlint-disable MD013 -->
# A21 interface proposal: TF bounded outer command

## 1. Validate

TF main `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c` contains validator blob `c84d9067c1b315e037850f2cd40e79c0704356b5`. `Get-HuskySetupContractFailure`, lines1520–1526, accepts exactly `cd ../.. && node .github/workflows/lint-nested-markdown.js --outer` for workflow `lint:md`. D90/E90's proposed PS package instead selects `node lint-markdown.mjs`, which runs that existing outer child through `NpmTools.runBounded` with120-second/two-MiB limits. A literal ten-path peer port therefore fails the existing exact-string validator even when the intended bounded caller is installed. This is a source-established interface incompatibility, not an executed TF failure or permission to bypass the validator.

The TF root delegates to workflow phase names, and `Invoke-MarkdownLint.ps1` runs both phase names and checks their exits. TF's existing `NpmTools.runBounded` provides the required signature/default limits. The current mutation at lines6967–6973 replaces the workflow outer command with the old direct CLI command and expects rejection. Root delegate and root dependency-negative controls are separate and must remain.

## 2. Relevant stakeholders

A21 owns the validator and its negative controls; A07 owns the urgent dependency/lint transfer. TF maintainers, contributors and CI operators need the real bounded outer command to pass while aliases, bypasses and nested-only substitutions fail. Security and independent reviewers need both process bounds and a precise admission contract. The coordinator must select a current accepted A21 base after PR224 merge and preserve unresolved A03 maintenance authority. Historical review custodians need this proposal distinguished from an installed guarantee. No cloud, state-recovery, credential or protected-document interface changes are proposed.

## 3. Material options

- **N:** Keep the existing exact string and defer the transfer; expose the incompatibility honestly.
- **A:** Replace only the workflow outer expected command with the exact bounded caller, and update meaningful adjacent negative fixtures under A21 ownership.
- **B:** Accept both old direct-child and new wrapper strings. This leaves an unbounded ordinary outer route admissible.
- **C:** Replace the exact comparison with a general command parser that recognizes equivalent bounded invocations. This introduces aliases and parser maintenance without a demonstrated consumer.
- **D:** Delete the workflow outer check and rely on tests/CI alone. This loses a retained exact contract.
- **F:** Rework the old direct-child entry to supervise itself through another bounded process, preserving the old string. This adds caller responsibilities merely to avoid changing one explicitly governed interface.

Keeping the unbounded command to appease the old validator is B, not a valid smaller repair. A general wrapper/registry is C/F with more responsibility; it is not needed by either inspected caller.

## 4. Fresh rubric and constraints

Score0–5 means absent through fully supported by inspected design; total=sum(weight × score/5). **Bounded consumer integrity35** preserves the real outer bound and phase; **admission precision30** refuses bypass/obsolete alternatives; **verifiable interface20** rewards concrete caller and negative controls; **maintenance10** minimizes permanent command knowledge; **churn5** limits changes without overriding correctness. Scores are prospective judgments.

Hard constraints: no unbounded accepted alternative, generic success command, lost negative controls, weakened root delegation/runtime/dependency restrictions, wholesale validator port, protected edit or A03 authority claim. Implementation must use the future selected A21 foundation after PR224 merge; current native06ad is evidence, not the automatically selected implementation base.

## 5. Scores

| Option | Integrity35 | Precision30 | Proof20 | Maintenance10 | Churn5 | Total | Key uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 0 | 5 | 5 | 5 | 5 | 65 | Truthful hold; bounded transfer cannot be admitted. |
| A | 5 | 5 | 4 | 5 | 5 | 96 | Reconcile the exact region with the later A21 base. |
| B | 3 | 2 | 4 | 4 | 4 | 61; ineligible | Old unbounded command remains accepted. |
| C | 5 | 4 | 3 | 2 | 2 | 77 | Equivalence parser enlarges supported syntax. |
| D | 5 | 0 | 2 | 5 | 5 | 58; ineligible | Removes the retained command admission check. |
| F | 5 | 4 | 3 | 2 | 1 | 76 | New self-supervision alters additional callers. |

A wins because there is one actual new command and an existing exact contract. Retaining exact comparison provides a smaller, more reviewable boundary than parsing or duplicating a process supervisor. Future tests remain required.

## 6. Controlled selection

Select A as a conditional A21 interface adaptation. Set the workflow outer expected command to `node lint-markdown.mjs`. Keep root outer/nested delegation and workflow nested/prepare contracts. Keep the old direct CLI mutation as a rejection. Add rejection of the old direct unbounded child, a nested-only substitution and a success stub. Keep the bounded wrapper and real outer-child controls in A07 tests. Do not claim that a script-name check proves immutable workflow enforcement.

Re-read the accepted PS delivery and selected TF A21 base before implementation. Apply the smallest corresponding region change; do not copy an entire validator. This ordinary interface repair requires ownership coordination, not an invented new owner permission question. The current PS ten-path urgent scope stays unchanged.

## 7. Meaningful future verification

Evaluate the actual manifest through the selected-base contract helper and full validator. Exact bounded command must pass; direct CLI, old direct child, nested-only and success-stub mutations must fail for the intended reason. Retain root script/dependency and hook/setup negative cases. Run the actual wrapper on Windows/Linux to prove outer findings, native tooling failure and timeout/output-limit behavior; a string assertion alone is insufficient. Confirm both ordinary CI phase calls still execute and the existing required names remain `markdownlint`, `policy` and `verify`. Reuse exact unchanged D90/E90 evidence where appropriate. No implementation, test run, transfer count or A21 base selection occurred here.

Coordinator disposition: retain this selected future adaptation. All six totals were independently recalculated; exact native hook/validator source and paired Git identities were checked. Source acceptance, refreshed native inputs and the stated A21 prerequisite still control implementation. No transfer, test, base selection or product edit is released by this planning record.
