<!-- markdownlint-disable MD013 -->
# FQ35 — clear stale recovery selection in the runner handoff

Proposal only. Root owns selection and implementation. Source identity and write limits are the same as FQ34-PROPOSAL.md.

## 1. Validate the current flow

Comment 4228859868 is valid. Initializer1202 removes STYLEGUIDE_RECOVERY_NODE22 from its process before child execution. Lines1225–1228 acquire compatibility only when the switch is set. Lines1283–1288 publish an environment record only when that verified runtime exists. The switch-off path publishes no record for this key. Lines1311–1313 assign the verified path to the current process only in the switch-on case. This separates two lifetimes: removing an environment item in PowerShell does not update the runner's job environment for later steps.

The runner accepts an empty value in NAME=VALUE and applies records in order. A later empty record overwrites an earlier value; it does not promise deletion of the key. It also supports a separate multiline syntax, which this initializer does not need because all outgoing records reject CR/LF before UTF-8 append/flush. [GitHub environment commands](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-commands#setting-an-environment-variable), [runner parser and setter](https://github.com/actions/runner/blob/main/src/Runner.Worker/FileCommandManager.cs), and [official empty-value tests](https://github.com/actions/runner/blob/main/src/Test/L0/Worker/SetEnvFileCommandL0.cs#L110-L150) support this behavior. The first `=` separates the key; an `=` inside a valid local path is part of its value.

A job/workflow or prior step can provide a stale value. Successful switch-off setup must replace that value with empty for subsequent steps. A later step can deliberately override it again; the initializer cannot prohibit that. A second setup against an occupied styleguide-node root is not supported: New-PrivateDirectory refuses the existing destination. Test on→off across two fresh owned setup roots, not by deleting the first root or making setup idempotent. Failed setup still must not publish a new clear record. FQ23 already fixes mandatory process sanitation/preferences; retain it. FQ30/FQ33 declaration validation and FQ36 stdout behavior are separate.

No maintained ordinary workflow requests IncludeRecoveryCompatibility today. The README148 advertises this opt-in handoff for recovery users. The defect affects that supported handoff and inherited job state; no executed recovery misuse is claimed. IncludeRecoveryCompatibility remains Linux x64 only (1088). Switch-off setup is supported on both Linux and Windows.

## 2. Stakeholders

Recovery operators and automation must receive either a verified Node22 path or an empty selection. New users should not clear stale job state manually. CI/platform engineers need runner-compatible append records and correct step lifetimes. Security/release owners need no stale executable authority. Both maintainers, reviewers, QA, and auditors need switch-on/off and failure tests without changing historical receipts. Linux users use compatibility; Windows users require successful switch-off sanitation. Privacy owners need synthetic values in fixtures. No Terraform recovery execution, public guide, artifact format, or accessibility behavior changes.

## 3. Relevant options

- A: No change or documentation-only deferral.
- B: Remove compatibility support and its publication contract.
- C: Add an explicit empty record only to the successful switch-off branch.
- D: Emit exactly one record from a local value that is empty by default and assigned only from the verified compatibility result.
- E: Always emit empty first, then append a verified nonempty record when present.
- F: Move sanitation to each future recovery consumer or require a workflow env reset.
- G: Rewrite the whole runner environment file or factor a configurable publication helper.

Direct .NET environment deletion is still process-local, so it collapses into A for this defect. A targeted exception for a trusted inherited path conflicts with switch-only verification. Multiline publication is unnecessary and adds delimiter failure cases.

## 4. Rubric before scoring

0 means absent/incorrect; 5 means fully satisfies the criterion. Total = sum(weight × score /5). Hard constraints: successful off means no usable inherited recovery path; successful on publishes exactly the verified path; preserve successful-only publication, process sanitation, platform restriction, exclusive channels, newline checks, and existing failure cleanup. No consumer may treat empty as proof that a runtime exists.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Handoff correctness H | 34 | Both switch states and successive successful setups |
| Executable authority A | 26 | Only verified acquired path is usable |
| Runner/user semantics U | 23 | Clear empty-versus-absent behavior without user work |
| Failure and test clarity T | 13 | One causal record and unchanged failures |
| Change cost M | 4 | Small maintainable implementation |

## 5. Scores before selection

| Option | H | A | U | T | M | Total /100 | Key limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 0 | 1 | 2 | 1 | 5 | 21.0 | Stale value remains |
| B | 2 | 5 | 0 | 4 | 2 | 51.6 | Removes supported capability |
| C | 5 | 5 | 5 | 5 | 5 | 100.0 | Selected; exact branch repair |
| D | 5 | 5 | 5 | 5 | 4 | 99.2 | Equivalent with extra temporary variable |
| E | 5 | 5 | 4 | 3 | 4 | 89.4 | Duplicate key obscures fixtures/review |
| F | 2 | 3 | 2 | 2 | 2 | 45.2 | Cannot repair arbitrary existing consumers |
| G | 3 | 3 | 3 | 2 | 1 | 55.8 | Risks other records; unnecessary framework |

## 6. Selected proposal C

Keep the verified-path branch at1286. Add an else branch. Append the literal `STYLEGUIDE_RECOVERY_NODE22=` in that branch. Keep the record in the existing success-only array. Keep CR/LF checks and channel writes unchanged. Keep current-process removal at1202. Keep current-process assignment conditional on a verified runtime. Do not publish during cleanup or after a failed setup.

```powershell
} else {
    $arrRunnerRecords += 'STYLEGUIDE_RECOVERY_NODE22='
}
```

Explain in the existing runtime README paragraph that successful setup without the switch publishes an empty recovery selection. State that later steps must require a nonempty verified path before use. Do not promise key deletion or same-root repeat setup. Instructions are deliberately short and conditional; no formal ASD dictionary certification is claimed.

## 7. Implementation and verification plan — not executed

Extend foundationFixture at3516–3585 or the real synthetic-archive initializer fixture at3080–3155. Preserve native completion checks and the real initializer publication path. Add an off success with synthetic inherited recovery selection, an on success, and off/on sequencing with fresh fixture roots. Parse actual runner output by first `=`, preserve empty values, and apply records in order to a private simulated job map seeded with a stale value. Do not use truthiness to detect the empty record or `.find` when testing history. Assert exactly one new recovery record per successful setup. Keep a sentinel unrelated key. Verify off→off remains empty, on→off becomes empty, and off→on becomes the exact new verified path. No real recovery executable dispatch is needed.

Use one genuine old-source mutant that removes only the new else branch. It must pass process-local sanitation yet leave the seeded downstream job value stale. That is the causal test. Retain on wrong-version/wrong-digest failure cases and preflight/native failure cases: channels must retain their exact prior bytes and no recovery reset may appear. Test a synthetic CR/LF compatibility path at the publication boundary and require refusal before either channel write. Existing record parsing in the separate Copilot fixture1324 is only a precedent; it is not proof of ordinary initializer publication.

Use the existing finite archives ≤64KiB and real native subprocess limits. At most 7 new initializer executions (six sequence successes plus the omission mutant), each timeout30 seconds/maxBuffer1MiB, registration timeout240 seconds. Reuse existing failure registrations; the CR/LF case is a publication-boundary test. Use safe synthetic values only. Run Linux maintained targeted tests first. For Windows switch-off, use an extracted real record-construction boundary with null compatibility result; the existing Windows maintained aggregate covers initialization/platform controls. A future full Windows success fixture can add evidence but must not be falsely claimed here. Commands after root release: `node --test --test-name-pattern='FQ35|R5 Linux compatibility and archive boundary' .github/workflows/Test-CiHelpers.test.mjs` inside the maintained transport. Then root refreshes final aggregate acceptance after all edits. None of these product tests ran in this analysis.

## Root selection and current status

Root verified the frozen analysis assets and all score arithmetic. The complete options, unique rubric, scores and selected instructions were displayed to the owner before implementation. Root selects option C under the standing clear-winner instruction. The earlier proposal wording records its original analysis stage. Product implementation and required tests follow; no test result in the proposal is promoted to executed evidence. Original PR239 round2/80, deadline2026-10-16T22:53:27.970214Z and A07transfer9/12 remain unchanged.

Root corrected two losing draft totals before implementation: A21.0 and B51.6. C100 remains the winner. The owner-facing correction and frozen table agree.

## Local implementation at source freeze

The success-only empty off record and explanatory runtime documentation are implemented. The Linux sequence is off, off, on, off with fresh roots: four successes cover off→off, off→on and on→off. One old-source omission mutant and one preserved-prior-channel failure bring the FQ35 count to six initializer executions. FQ37 shares these success records and adds one blocked-record-restoration mutant; the combined count is seven, with no duplicate archive acquisition for the same assertion. A separate cross-platform test executes the actual record-construction/newline-check boundary for off, synthetic on, LF and CRLF values. It proves empty off construction and refusal before channel use, not full Windows setup or verification of the synthetic runtime path. The earlier proposed six sequence successes are unnecessary; four cover all named transitions. All these new tests remain unexecuted.

The [frozen source record](current-main-validation/pr239-round2-source-freeze.json) identifies that historical repair input. Root syntax and whitespace checks passeda48f78.

## Current verification

Real Linux setup sequences, omitted-record controls, preserved failed handoffs and the actual record-construction/newline boundary passed in the five-test record/output group. Windows passed the record-construction boundary; this is not whole Windows recovery-setup acceptance. [Current candidate and validation](current-main-validation/pr239-round2-validation.md) supersedes the pending-test statements above and identifies the actual input attribution and remaining gates.
