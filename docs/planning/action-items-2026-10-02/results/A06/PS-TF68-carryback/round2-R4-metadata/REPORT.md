<!-- markdownlint-disable MD013 -->
# PS235 R4: retain the script index's October 6 date

Status: proposal for root selection; no product or native action. R4 is comment4202576730/threadPRRT_kwDOQkjdhM6pvNci from Copilot review5437075963, observed Lite, on H5e8ccbbe45679ab58a202c672554ffda56a0a9f5 over B98177628b7bc02c646724bfc8aa0fd73fed0cd24.

## 1. Validate

The date difference is real. A need to change scripts-README to October 7 is not supported by its actual transition or the accepted checker. This is the exact metadata boundary already settled in [FINAL-VALIDATION-SELECTION](https://github.com/franklesniak/PSStyleGuide/blob/61e4d95832fafca1df829cfe9aa3e36ec75d39a4/docs/planning/action-items-2026-10-02/results/A06/PS-TF68-carryback/empty-array-trial/FINAL-VALIDATION-SELECTION.md). Its applicability is proved below. A fresh evaluation still records the new reviewer concern.

- Raw 100644 README blobs: accepted B `8510f350f0247b919b6e1527bcd7b7b7091b103f`; both H504 and current H5e8 `e6221de4ca0f42b3a3c7230dfe88604d0cb31030`. B-to-H replaces only line8 Last Updated Oct5 with Oct6. That single full-line replacement recovers every current byte; no rendered body changed.
- Git author and committer time for 504 is 2026-10-06T19:48:28Z. H5e8 is 2026-10-07T01:58:29Z and changes only validator, SelfTest and dependency-guide date. It leaves the README blob untouched. These dates corroborate the preparation/source history; commit time is not a substitute rule for every document's substantive update.
- Accepted B's ConvertTo-MetadataComparisonText4246-4317 and current H's4687-4758 are raw-identical. They validate metadata indexes, mask Last Updated and Version if present, then normalize mechanical whitespace. The date checker compares those texts at accepted4403-4408/current4860-4865. Accepted4438-4440/current4898-4900 returns for unchanged rendered content before trusted event/current-date enforcement. Calendar validity, future-date and backward-date checks still apply before this return. There is no blanket waiver.
- D07 requires synchronized metadata when convergence touches shared files. It does not require every path in a multi-day PR to show the final PR day. The README was synchronized to accepted TF a840's October6 date during the October6 carryback. This does not invoke D07's untouched-historical-file exception. The dependency guide has a real new KaTeX paragraph relative to accepted B; its October7 finalization and the two scripts' October7 metadata are separate actual transitions.
- Exact H5e8 accepted-B finalization already ran on October7 under PowerShell7.6.5 and exited0. Its log names the actual Oct7 clock and B/H. Ordinary accepted content and other endpoint modes also passed. This corroborates the source contract; green CI alone is not the rationale. The initial endpoint attempt remains failed for a private Windows path limit; the successful short-root continuation is separate evidence.

The PR body says the final commit passed genuine October7 finalization. It does not say every touched file changed on October7. That statement is accurate under the per-document rule. No product defect, required date edit or new test gap is established.

## 2. Stakeholders

The owner and PS/TF maintainers need truthful per-file history and shared metadata alignment. Documentation authors and new contributors need an applicable rule that does not require repeated date changes at each review. README readers need an honest stamp; reviewers and independent-quality readers need a concise explanation tied to raw history and accepted authority. CI, release and Windows/Linux operators need stable inputs and reproducible date enforcement. Auditors, history custodians and cost/schedule stakeholders need preserved failures and proportionate evidence reuse. Security reviewers need calendar/future/backward checks retained, without path-specific exemptions. Language examples, generated outputs, dependency behavior, privacy and accessibility do not change; their owners receive no new action from R4.

## 3. Options, before scoring

- **A. Retain Oct6 and give a precise linked thread explanation.** Preserve current source and explain the actual transition and accepted check.
- **B. Retain Oct6 without a substantive disposition.** Keeps correct source but leaves the reviewer question unanswered.
- **C. Retain Oct6; explain in the thread and add a PR-body history sentence.** The existing body is accurate; extra publication adds no demonstrated clarity beyond the reply here.
- **D. Change PS README to Oct7 and align TF after source acceptance.** A newly made date edit could be dated truthfully, but it replaces correct carryback metadata for visual uniformity and needs new input/head validation and peer alignment.
- **E. Add permanent README explanatory content and change its date; carry it to TF later.** Makes an otherwise unchanged document a rendered-content change and duplicates review-specific history in product guidance.
- **F. Change the checker to require one PR-wide date, including metadata-only edits.** Replaces the selected per-document/rendered-change contract with a new policy.
- **G. Remove Last Updated or exempt this README from its date checks.** Weakens useful schema/date checks and introduces an unnecessary exception.
- **H. Defer disposition for a new narrow date probe or endpoint replay.** The exact current native October7 finalization and source proof already exist; no missing observation is identified.
- **I. Restore accepted-B Oct5 to remove this path from the PR.** Loses selected shared Oct6 alignment with accepted TF and disregards the carryback transition.

A plus the optional body sentence is C. A new Oct7 source date plus required later peer alignment is D. Immediate simultaneous PS/TF editing violates serialized source/peer authority. A new parser, shared-code factoring or whole-guide audit cannot resolve this proven data/history question and would expand the contract. Retention does not waive future enforcement after a genuine rendered edit.

## 4. New finding-specific rubric

Use 0-10 ratings:10 fully meets the criterion,7 meets most with a stated limitation,4 introduces a substantial weakness,0 supplies none. Total=sum(weight*rating)/10. Scores compare proposals; they are not measurements.

- **C: correct date/check semantics,32%.** Preserve calendar, future/backward and rendered-change finalization rules; distinguish actual file transition from whole-PR date.
- **H: truthful history,27%.** Represent Oct6 carryback and Oct7 three-path commit without replacing provenance for uniformity.
- **U: practical reviewer/contributor usability,21%.** Explain the difference where it was encountered; reduce ambiguity and extra contributor steps.
- **P: paired policy and authority,12%.** Respect D07 synchronization, the explicit existing selection, source/peer sequence and useful enforcement.
- **E: evidence and recoverability,5%.** Use exact blobs and native endpoint evidence; preserve failed history and current candidate.
- **B: operational burden,3%.** Avoid needless changed inputs, repeat checks/reviews and additional records. Cost cannot waive the other criteria.

Hard constraints: truthful dates, valid schema/calendar/future/backward enforcement, accepted-policy authority and D07 paired scope. Scores authorize no source edit, waiver, new request or merge. F/G cannot be adopted within this finding's unchanged contract.

## 5. Complete checked scoring

| Option | C32 | H27 | U21 | P12 | E5 | B3 | Total/100 |
| --- | --- | --- | --- | --- | --- | --- | --- |
| A | 10 | 10 | 9 | 10 | 10 | 10 | 97.9 |
| B | 9 | 9 | 4 | 10 | 8 | 10 | 80.5 |
| C | 10 | 10 | 9 | 10 | 10 | 7 | 97.0 |
| D | 7 | 6 | 7 | 7 | 6 | 4 | 65.9 |
| E | 7 | 6 | 6 | 6 | 6 | 3 | 62.3 |
| F | 3 | 2 | 3 | 2 | 2 | 2 | 25.3 |
| G | 1 | 2 | 2 | 2 | 2 | 4 | 17.4 |
| H | 9 | 9 | 7 | 9 | 9 | 3 | 84.0 |
| I | 4 | 5 | 4 | 3 | 5 | 5 | 42.3 |

A clears the constraints. C provides the same useful thread explanation; the currently accurate body needs no correction. H repeats available evidence. D/E add source/peer work without correcting a defect. B leaves ambiguity. F/G/I lose established contract, history or alignment. These judgments and every integer score numerator are bound in evidence.json. All nine totals are computed and checked.

## 6. Recommendation: A97.9, no product change

1. Keep scripts-README Last Updated at 2026-10-06.
2. Keep current H5e8 source bytes.
3. Explain the Oct6 transition in the R4 thread after root selects this disposition.
4. Link the selected metadata boundary.
5. Keep the Oct7 dependency-guide and script metadata.
6. Do not add a README-specific exemption.
7. Reassess if a rendered README edit or input change occurs.
8. Retain current review, CI, dedicated-service and paired acceptance gates.

These use short controlled-English instructions; no formal ASD-STE100 dictionary-compliance claim is made.

Proposed native reply, three lines; root alone posts and resolves:

```text
The README's October 6 date was carried in `504cd76`; `5e8ccbb` leaves that blob unchanged.
Both checkers return before event-date enforcement when rendered content is unchanged; the shared date already matches TF. [Selected metadata boundary](https://github.com/franklesniak/PSStyleGuide/blob/61e4d95832fafca1df829cfe9aa3e36ec75d39a4/docs/planning/action-items-2026-10-02/results/A06/PS-TF68-carryback/empty-array-trial/FINAL-VALIDATION-SELECTION.md).
Generated with Codex
```

No factual PR-body correction is required. If root selects C, an optional sentence is: “scripts-README retains the October6 carryback date; October7 finalization applies to the changed dependency guide and final script metadata.” Root must use normal native preimage/readback discipline; this worker posts nothing.

## 7. Verification and limits

A needs no new test because source and inputs remain unchanged. Reuse exact B/H raw comparison, accepted/current helper semantics, explicit prior selection and the actual October7 endpoint. No candidate/parser/import/probe/container/install or native call ran here; only local Git and saved evidence reads. Source/index/refs/config guards stay equal and the worktree remains clean at H5e8. A later selected source/date edit creates a new candidate that needs normal affected checks/current-head review; existing receipts cannot certify an uncreated object.

The supplied round2-terminal snapshot at02:55:50Z shows unchanged H/B/body and PR235 open/unmerged. Root reports14 ordinary workflows and Codex6029735383 successful. Dynamic run37562640212 was cancelled at02:55:09Z after its20-minute job maximum; all11 hooks passed in899seconds and the final guard passed before review processing was cancelled. That is a service failure, not a metadata failure. A date edit is not a proposed remedy. No failed-CI merge is permitted. Earliest recovery request is03:34:29Z; current-input channels1/3 and old-input3/3 remain distinct.

Retain round2, deadline2026-10-14T20:09:39.767792Z, A06transfers2/12 and B99 freeze. No new review solely because effort is Lite. R4 does not prove dedicated setup activation, stable runtime or acceptance. Primary evidence is repository code/commits/policy plus saved authenticated review and exact native endpoint receipts, all hashed in evidence.json. No external behavior uncertainty requires new web research. The earlier broad date claim remains historical; its corrected report and root selection govern this exact boundary.
