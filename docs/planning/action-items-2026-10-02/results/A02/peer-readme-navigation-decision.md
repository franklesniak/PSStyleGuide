<!-- markdownlint-disable MD013 -->
# Proposed A02 peer finding: stale Terraform README navigation

Status: scratch preparation; recommended solution only. No product edit, transfer, PR or acceptance. Source PS d9b9e1c4597f91b9f5d2de0cc376c28305207654 is unmerged; TF input is main06ad4f7c9b6847028cafdacf1ae55128d0f2d56c. Recheck actual mains after source merge.

## Validate

TF README blob f04368718d580fe61d9a22f4c92cdfdf8287b28d contains fourteen STYLE_GUIDE section links. Locked markdown-it parses 228 actual TF headings. Seven README fragments have no heading-derived target or literal custom anchor in the exact guide: executive-summary-terraform-philosophy, file-organization, resource-configuration-1, module-design-1, state-management-1, cross-stack-data-sharing-1, provider-management-1. All eight corresponding PS navigation targets match its own guide. This finding concerns user-facing navigation in TF README, not shared normative content or PR224's validator.

[GitHub's section-link rules](https://docs.github.com/en/get-started/writing-on-github/getting-started-with-writing-and-formatting-on-github/basic-writing-and-formatting-syntax#section-links) specify lower-case headings, space replacement, punctuation removal and suffixes only for duplicate anchors. Actual parsed TF headings have no duplicate base anchor for the five suffixed names. The guide contains Quick Reference Checklist at line22 and File Organization (Quick Reference) at line54; these supply truthful narrow replacements for the two removed headings. Evidence: readme-heading-evidence.json and its exact Node24.18.1/markdown-it harness. No browser-rendered click test or native CI run was performed.

## Stakeholders

Terraform readers, new contributors and coding agents need working entry navigation. Both maintainers and documentation reviewers need truthful topic labels and a bounded patch. Generated-guide maintainers must not receive an unnecessary source edit or regeneration duty. Accessibility and localization readers benefit from explicit accurate link names. CI maintainers and schedule owners need a cheap meaningful link check. No cloud/backend execution, security policy, privacy flow, license or recovery procedure changes; these stakeholders add no distinct requirement to this navigation repair.

## Options

A: leave the seven broken entries. B: repair these seven labels/targets to existing exact headings. C: remove the seven broken entries. D: replace the whole list with a newly generated complete TOC and introduce a synchronization mechanism. E: recreate old guide headings/sections solely to restore the old README targets. F: defer to A18 and preserve broken navigation meanwhile. A target-specific permanent exception would equal A; a generic external link framework equals D. A21 cannot repair this by installing a validator mode, so its code port is not a reason to defer this independent README correction.

## New rubric and scores

Navigation40: each reported link reaches a useful existing topic. Factuality25: link text describes the exact destination. Preservation15: retain topic access and existing guide authority. Cost10: minimize new ongoing generation/check machinery. Scope10: avoid unrelated guide or architecture edits. Scores1–5 are poor–strong judgments, not empirical measurements. Hard constraints: do not invent guide content; do not overwrite language-specific instructions; do not infer accepted-main equality from a scratch patch.

| Option | Navigation40 | Factuality25 | Preservation15 | Cost10 | Scope10 | Total/100 | Main uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 1 | 1 | 5 | 5 | 36 | Broken links stay visible |
| B | 5 | 5 | 5 | 5 | 5 | 100 | Recheck headings at actual transfer |
| C | 4 | 5 | 3 | 5 | 5 | 86 | Removes useful reader entry points |
| D | 5 | 5 | 4 | 2 | 4 | 89 | Introduces continuing synchronization surface |
| E | 3 | 1 | 1 | 1 | 1 | 36 | Changes guide structure without a guide need; fails constraints |
| F | 1 | 1 | 1 | 4 | 5 | 34 | Known failure remains until a later outcome |

Total=(40*N+25*F+15*P+10*C+10*S)/5. Arithmetic checked for all six rows. B changes only actual failed navigation and clears the hard constraints. D's completeness benefit does not require a new permanent mechanism for seven static references.

## Recommended selection and verification

Use B after source acceptance and input refresh. Point entry1 to Quick Reference Checklist. Point entry5 to File Organization (Quick Reference). Remove the obsolete -1 suffix from the five detailed-section targets. Keep all other entries. Keep the guide unchanged. Do not use a PS heading in TF.

The separate TF-readme-links-unselected.patch proposes these seven edits. It applies in disposable scratch after TF-mechanical-only.patch; native git apply --check and actual scratch application exited0. This is patch feasibility, not a peer validator/CI pass. At transfer, parse the exact accepted TF guide, check every README STYLE_GUIDE link and duplicate-anchor suffix, run the affected normal Markdown checks, and perform the ordinary peer review/merge/reverse-diff lifecycle. Do not write a new unit test that repeats these static seven edits. Preserve the factual README language/provenance exceptions separately. This proposal has not been implemented in a repository.
