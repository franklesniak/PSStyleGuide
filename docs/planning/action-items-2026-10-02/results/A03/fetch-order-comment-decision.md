<!-- markdownlint-disable MD013 -->
# A03-D10: explain the saved audit authority

## Validation and stakeholders

Copilot Balanced review5404869798 on d311690 reported one low-severity finding in comment4176597870, Check-NpmAudit.mjs line261. The sentence is difficult to parse. The implementation is correct: readAcceptedBase resolves FETCH_HEAD into sha before readCiScope can fetch a distinct PR base. The existing actual-Git applicability test forces both fetches, checks their order, and asserts that authority still equals main. This is a maintainability improvement, not a newly demonstrated runtime or authority defect.

Maintainers and new contributors need the ordering reason at the relevant assignment. Security reviewers need the distinction between trusted main and PR scope. QA needs reuse of the real regression, not a test of comment wording. Documentation readers benefit from short direct language. DevOps, project and cost owners need no new runtime or unnecessary architecture work. No end-user interface, private data, deployment permission or business policy changes.

## Options before evaluation

- N: retain the comment and explain it only in the review reply.
- D: remove the comment and rely on code/tests.
- O: replace it with one precise sentence.
- T: replace it with two short sentences naming the saved main commit and later FETCH_HEAD replacement.
- E: move the explanation to external documentation and link it.
- R: refactor the fetch helper to return an immutable commit directly, then document that interface.

Combining T with R adds behavior changes without a demonstrated defect; it inherits R's additional validation burden. T plus E duplicates a two-line explanation and adds a maintenance location. No change and deferral are N. No token, setting, runtime or new test framework is needed.

## Unique rubric and scores

Scores1–5, higher is better. Total=sum(weight*score)/5. Correctness40% measures faithful preservation of the actual authority/PR-base invariant. Clarity35% measures whether a new maintainer understands the order and its cause at the assignment. Verification15% favors the existing independently useful runtime oracle plus an exact executable-text comparison. Maintainability5% favors one explanation near the code. Effort5% includes churn and validation cost. Hard constraint: preserve current acquisition, exception authority and failure behavior. Scores are engineering judgments, not empirical performance measurements.

| Option | Correctness40 | Clarity35 | Verification15 | Maintainability5 | Effort5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 5 | 2 | 4 | 5 | 5 | 76 |
| D | 5 | 1 | 3 | 5 | 5 | 66 |
| O | 5 | 4 | 5 | 5 | 5 | 93 |
| T | 5 | 5 | 5 | 5 | 4 | 99 |
| E | 5 | 3 | 3 | 3 | 3 | 76 |
| R | 4 | 5 | 3 | 3 | 2 | 81 |

## Selected solution

Use T. Replace the existing comment with these two lines:

```javascript
// Save the fetched main commit now.
// A later PR-base fetch in readCiScope can overwrite FETCH_HEAD.
```

Keep the assignment immediately below the comment. Do not change executable text. Compare the old and new files after the exact comment replacement. Run the existing PR-applicability test. Run the required aggregate on the final candidate. Preserve round2 results on d311690. Request the next review pair only after both issued round2 reviews are terminal. Keep the original deadline and transfer count. Short direct instructions follow the requested writing approach; formal controlled-dictionary certification is not claimed.

## References and evidence limits

[Git fetch documentation](https://git-scm.com/docs/git-fetch) states that fetched ref/object names go into FETCH_HEAD and that a later fetch overwrites old data unless append is selected. The current helper does not select append. The parent inspected readAcceptedBase, readCiScope, hostedAuditInputs and the actual-Git test `PR applicability uses actual target B, independently of accepted main A` before selection. D7's22/22 Windows/Linux results and native push audit remain historical evidence for d311690, not new final-byte validation. The coordinator displayed all options, rubric and scores before editing. Current validation and publication results follow here when obtained.

## Implementation and current validation

The sole changed path is Check-NpmAudit.mjs. Its raw bytes exactly equal d311690's blob with only the selected comment replacement; all74 other tracked raw files are unchanged. No new test mirrors the comment. Existing real-Git ordering/applicability test passed1/1 on Windows Node24.18.1, zero failures/skips,39.103seconds. The staged candidate tree ised7ad456a7147152d2c289908066195689127e85. Staged-input validation passed at2026-10-04T07:44:46Z. The sole full aggregate2088 started07:44:46.202129Z and owns the frozen input/state until terminal. No new commit, publication, reviewer reply or round3 request has occurred yet. Round2 Codex is clean and Copilot is terminal with this finding; preserve both results on their old input.
