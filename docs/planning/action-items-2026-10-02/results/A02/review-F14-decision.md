<!-- markdownlint-disable MD013 -->
# F14: recognize spaced emphasized optional metadata markers

Status: selected before product edits; implemented; focused controls pass; final aggregate held.

## Validation and stakeholders

Codex5397627845/comment4170495483 identifies head25b17e892f6429cf4df4f39489443d950f5902e8/tree4dba7b2766ba49233e7dd0871188255c0870ae7c. reproduce.ps1/log executes its exact production parser/intent helpers with only the locked dependency root bound. Lone `- **Owner :** Team` and `- **Scope :** Examples` return false intent although strict metadata parsing fails. Canonical emphasized Owner returns true. Generic un-emphasized Owner prose returns false as intended. Optional Tier2/catalog callers use intent for current and prior content; false intent skips validation or misclassifies prior adoption. The docs policy's intentional-header synchronization and canonical field syntax remain unchanged.

Affected stakeholders are document authors/readers, both maintainers, local and CI agents, independent/security reviewers, and example authors. They need malformed intentional fields rejected without converting generic Owner/Scope prose into metadata. Windows/Linux and localization users need stable reserved English marker behavior. Generated readers and finalization operators need unchanged exemptions/date authority. No credential, privacy, cloud or recovery operation changes.

Hard constraints: recognize intent without accepting noncanonical fields; preserve parsed header windows, optionality, prior malformed-header rejection, fences/quotes/front matter/nested/later examples, H1 title behavior and generated exclusion. Do not scan all raw text or amend protected policy.

## Options, fresh rubric and scores

N retains/defers the gap. S permits whitespace before the colon or closing emphasis only in the existing emphasized reserved-marker expression. A treats all generic Owner/Scope list prose as intent. V uses successful parsing alone. R globally scans raw labels. C adds per-path marker configuration. P changes protected syntax to accept variants. Reusing the parsed context is S; a new parser adds no necessary capability.

Fresh0–5 rubric: incomplete-intent coverage40; context/policy fidelity35; maintainability15; implementation/validation cost10. Total=sum(weight*score)/5. Hard constraints cannot be waived by scores.

| Option | Coverage40 | Fidelity35 | Maintain15 | Cost10 | Total | Key uncertainty/constraint |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| N | 0 | 4 | 5 | 5 | 53 | Demonstrated remnant still escapes |
| S | 5 | 5 | 5 | 4 | 98 | Preserve ordinary prose and excluded examples |
| A | 5 | 1 | 4 | 4 | 67 | False opt-in for generic prose |
| V | 0 | 3 | 4 | 4 | 41 | Invalid headers remain invisible |
| R | 5 | 0 | 2 | 3 | 52 | Promotes excluded examples |
| C | 3 | 3 | 1 | 2 | 52 | Duplicated path authority and omissions |
| P | 1 | 0 | 3 | 2 | 21 | Ungranted policy weakening |

S closes the reproduced boundary with one existing expression change. Scores express judgment; reproduction establishes the defect.

## Selected instructions and validation

Select S. Permit whitespace between an emphasized reserved label and its existing colon or closing emphasis. Keep the parsed context boundaries. Keep strict canonical metadata validation unchanged. Preserve un-emphasized generic Owner/Scope prose. Apply the same detector to current and prior data. Change only validator/SelfTest.

Test Owner/Scope and case/space siblings as lone incomplete markers, current and real prior metadata. Retain canonical complete headers and generic Owner/Scope prose. Retain fences, quotes, front matter, nested items, inline code, later H3 examples and H1 titles. Run a real optional current/prior B/H caller rejection. Then freeze with F13/F15 and run one normal final-byte aggregate. No guide text changes or new public interface. Parent owns native publication and final quality; round8/80, original deadline and transfer0/12 remain.

## Validation checkpoint

Implemented within the four authorized code/workflow paths. All focused controls pass; provisional tree0cde16e0dc69df235b98f6e739fa112bf7c1e3eb has no unstaged changes. RESULT.md records exact identities, terminal logs and limits. Code is frozen for independent review. No aggregate has started: the two separately authorized metadata date lines will be refreshed only on actual UTC October3, then one normal final-byte aggregate will run. No native installation/owner/immutable-workflow acceptance is claimed.
