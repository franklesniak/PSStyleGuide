<!-- markdownlint-disable MD013 -->
# F11: count noncanonical reserved metadata labels before strict validation

Status: selected before product edits; implemented; focused validation passes; final aggregate pending.

## Validation and stakeholders

Codex5397018839/comment4169978567 reports exact headb9c2d0ea4c04894a6ea3267e9daa662f27b5820b/treeed2bd7cf9e28ffc363bfd0dd7ac95e6ee63cf770. The actual parser accepts all four canonical fields plus a conflicting case-variant reserved field because its ordinal prefix filter drops the extra record. reproduce.ps1/log confirms status, OWNER, last updated and ScOpE duplicates, plus the directly coupled `Status :` and `Last  Updated:` forms. Raw exact field patterns are never applied to those discarded records. Policy docs.instructions.md blob0b0c1ddc83938cfa9706418d45f619b1bfa03ffd defines the four required fields, placement and synchronization; the validator's existing contract requires one exact item for each. Validator blobb8ec6e9d8c088245cd9271a53c2572204f1cea72 and SelfTest9d99b2beabc448930f66b68ee0d37d7a49aadb2d are the reproduced100644 inputs.

Current and prior metadata use the same parser. Authors/readers, maintainers of both repositories, CI/local agents, security reviewers and history custodians need a single unambiguous operational field. Windows/Linux contributors need the same result independent of culture. Example authors need fenced/quoted/nested and later-section content to remain non-operative. Generated consumers, path grants and finalization operators need unchanged boundaries. No credentials, personal data, cloud/state or external-service behavior changes.

Hard constraints: retain exact raw spelling/syntax, values, uniqueness, continuation/list/placement checks, optional fields/Version semantics, real prior preservation, context exclusions, F1–F10 and current finalization/authority rules. No normalized acceptance, protected text or schema/public-interface change. This is reserved-label recognition, not an arbitrary ban on extra unrelated list items.

## Options and fresh rubric

N: no change/defer. D: recognize the four reserved label words with invariant case-insensitive matching and whitespace around their existing word/colon boundaries, then keep exact raw syntax and uniqueness. L: change only prefix case comparison. R: normalize and accept variants. X: scan raw text globally. C: add per-path allowed-label configuration. P: amend protected policy to permit ambiguous duplicate spellings. Reusing the current parser/field table is D; a new parser framework supplies no necessary capability.

Fresh0–5 rubric: demonstrated rejection45; context/policy fidelity25; maintenance20; cost10. Total=sum(weight*score)/5. Hard constraints override scores.

| Option | Rejection45 | Fidelity25 | Maintenance20 | Cost10 | Total | Key uncertainty or constraint |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| N | 0 | 4 | 5 | 5 | 50 | Confirmed ambiguous metadata remains |
| D | 5 | 5 | 5 | 4 | 98 | Tests must retain unrelated labels and example boundaries |
| L | 4 | 5 | 5 | 5 | 91 | Leaves reproduced whitespace-label siblings |
| R | 2 | 4 | 3 | 4 | 58 | Changes accepted canonical syntax |
| X | 4 | 1 | 2 | 3 | 55 | Promotes non-operative examples |
| C | 3 | 3 | 1 | 2 | 50 | Duplicates field authority and future coverage |
| P | 0 | 0 | 3 | 2 | 16 | Ungranted policy change without a supported need |

D is the smallest option that closes all demonstrated spellings while preserving exact validation. L is incomplete; other options either leave the defect, alter policy or add a second authority/configuration surface. Scores are judgment aids, not test evidence.

## Selection and verification

Select D. Build a reserved-label recognition pattern from each existing field name. Permit case variants and whitespace between label words or before the colon only for recognition. Apply invariant case-insensitive matching to the same parsed list-item region. Count every recognized record. Keep the original case-sensitive raw pattern, exact values, one-item count and continuation/list checks. Do not normalize accepted content. Keep ordinary unrelated labels and excluded examples unchanged.

Change only validator/SelfTest. Exercise all four fields with duplicate and replacement variants, canonical duplicates, whitespace siblings, required/optional Version and malformed prior content. Retain canonical single fields, Related/unrelated labels and fenced/quoted/nested/later-section controls. Use actual B/H caller checks for a conflicting current header and a malformed real prior header. Reuse unchanged trust/path/generated controls. Run focused tests, freeze, then one combined normal final-byte pre-commit for F11/F12. No guide text changes require a guide audit.

Parent owns native exact endpoints, publication and independent final quality. Private installed-policy fixtures are proposed-code evidence; no native initial-install/owner authority is inferred. Round7/80, original deadline and transfer0/12 remain; A07 stays frozen.

## Validation checkpoint

Focused74098 exited0. focused.log records the actual metadata field/context checks, native Git path/mode/type/content controls, controlled raw-record/native-exit/overflow/timeout checks through the real bounded transport, and actual current/prior B/H metadata plus valid/invalid Unicode-document callers. Static analyzer Error scans and diffcheck pass. One fixture-only empty-array enumeration correction is documented in fixture-note.md and its preserved initial log; production semantics did not change for it.

Final candidate tree4dba7b2766ba49233e7dd0871188255c0870ae7c onb9c2d0ea4c04894a6ea3267e9daa662f27b5820b changes only validator/SelfTest100644, with no unstaged changes. One normal full pre-commit95367 passed all10 hooks, exit0, start2026-10-02T21:50:51.9246761Z and end2026-10-02T22:30:33.3579863Z, under Node24.18.1/npm11.16.0. Final readback confirms the same HEAD/tree, two100644 staged paths, raw hashes and no unstaged changes; diffcheck passes. Product/index ownership is released to the parent for normal commit and actual endpoint validation. RESULT.md holds the exact blobs/raw hashes and handoff boundary.

## Committed endpoint reconciliation

Normal commit `25b17e892f6429cf4df4f39489443d950f5902e8`, parent `b9c2d0ea4c04894a6ea3267e9daa662f27b5820b`, contains exact frozen tree `4dba7b2766ba49233e7dd0871188255c0870ae7c`. The normal commit completed after explicit worker ownership release, with a clean product worktree. Root-owned48783 exited0: finalization and classification both passed for actual B48f4d8a/H25b17e8 at UTC2026-10-02, preserving the fixture's accepted HEAD and exact staged candidate tree. D07 reconciled independent whole-PR local quality to the actual commit and final evidence. Normal non-force push and fresh remote-ref/PR readback confirm25b17e8; the initial PR readback lagged and no push was repeated. Fresh remote reviews, current CI and immediate native merge gates remain pending.
