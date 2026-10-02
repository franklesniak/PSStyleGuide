<!-- markdownlint-disable MD013 -->
# F7: reject noncanonical Version-like header labels

Status: implemented; focused checks and final normal aggregate pass.

## Validation and stakeholders

Codex5395264907/comment4168569572 applies to b8976a4. The exact production parser accepts an otherwise valid metadata header followed, before the next section, by `**version:** 1.0.20200101.7` or `**VERSION:** ...`; it reports no Version. A bounded sibling probe also accepts `**Version :** ...`. The exact canonical label in that same misplaced location fails. `reproduce.ps1/log` records these actual helper results. The header-intent detector already recognizes these labels, but the strict parser's ordinal StartsWith filters them out. This loses malformed-header rejection and can hide tuple/date/revision checks. It does not prove every placement bypasses validation: a malformed paragraph before the required list can already fail placement.

Affected stakeholders are document authors/readers, both maintainers, metadata/CI consumers, agents, security reviewers and history custodians. They need strict canonical syntax, clear errors, and unchanged date/baseline semantics. Windows/Linux contributors need identical bounded parser behavior. No credential, cloud, privacy, localization or deployment interface changes.

Hard constraints: retain the protected exact `**Version:**` syntax and placement; do not normalize malformed labels into accepted versions; preserve AST exclusion of quoted/fenced/example content and optional no-Version documents; retain actual prior-header validation and F1–F6.

## Options and rubric

N: no change. I: change only prefix casing. R: normalize and accept alternate labels. D: detect case/whitespace Version-like paragraph labels within the existing header region, then apply the unchanged exact syntax parser. A: require Version everywhere. X: scan raw text everywhere. C: add path-specific Version configuration. A new parser framework supplies no required capability beyond D.

Fresh0–5 rubric: complete demonstrated rejection45; placement/context fidelity25; maintainability20; cost10. Total=sum(weight*score)/5. Hard constraints override scores.

| Option | Rejection45 | Fidelity25 | Maintainability20 | Cost10 | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| N | 0 | 4 | 5 | 5 | 50 |
| I | 4 | 5 | 5 | 5 | 91 |
| R | 2 | 2 | 3 | 4 | 48 |
| D | 5 | 5 | 5 | 4 | 98 |
| A | 3 | 1 | 3 | 2 | 48 |
| X | 4 | 1 | 2 | 3 | 55 |
| C | 2 | 3 | 1 | 2 | 41 |

I misses the reproduced whitespace sibling. R/A alter protected semantics. X promotes examples. C duplicates coverage authority. D uses the existing parser region and exact validator, with no new accepted syntax.

## Selection and verification

Select D. Recognize `^Version\s*:` with invariant case-insensitive matching only on existing top-level header paragraphs. Keep the exact raw canonical Version pattern case-sensitive. Reject recognized noncanonical labels and misplaced/duplicate records. Do not change accepted Version/date/revision rules or the public interface.

Change only validator/SelfTest. Test lowercase, uppercase, mixed case and whitespace labels before/after the metadata list, canonical plus malformed duplicate, required/optional Version, malformed real prior header, and retained fenced/quoted/later-section negatives. Use the real B/H caller for a malformed optional Version and prior-header case. Reuse unchanged F5 placement/date controls. Run one final combined normal pre-commit after all three repairs are stable. No guide text changes belong to F7.

## Validation checkpoint

The selected changes pass focused actual helper and private installed-policy B/H checks (focused-final.log). The uppercase synthetic path variant of the actual data-only admission fixture also passes (suffix-admission.log); it changes only the fixture path spelling, not validator code. Exact ordinal authority, existing family alias refusals, retained F6 category controls, invalid real prior headers and candidate-code isolation remain exercised. These are proposed-code fixtures, not native first-install authority.

The final three-path candidate is staged as tree6223b82bced692b5eb32e31bcbc5fd11447015f8 on b8976a4. Normal combined pre-commit session72653 exited0 at2026-10-02T19:35:21.3724355Z; all10 hooks passed. It started18:52:17.7198840Z. Final readback confirms this exact tree, three100644 staged paths, matching raw hashes and no unstaged changes. Product ownership is returned to parent for normal commit/publication and native endpoint validation. The first focused attempt exposed only a PowerShell fixture concatenation-precedence error; fixture-note.md and example-diagnostic.log retain the cause, and the corrected focused run passed. No unrelated suite was repeated.

The first aggregate (superseded tree4363284) passed nine hooks and content validation, then stopped on a new SelfTest alias assertion's unavailable parent-script variable. The explicit fixture input now passes in a separate script scope; production and guide bytes are unchanged. fixture-scope-note.md and precommit-superseded-scope.log preserve this actual reason for the replacement aggregate.

## Committed candidate

Normal product commit `8b6c1da46b568cb3b44e60fc511a03ac1fc4edf0` preserves the validated tree `6223b82bced692b5eb32e31bcbc5fd11447015f8`. Actual proposed-code finalization and classification passed with B `48f4d8a36c8faceee12afac78aaecea0d176125d` and H equal to this commit; finalization captured UTC2026-10-02. The accepted-base fixture retained its HEAD and exact staged candidate tree with no unstaged changes. These checks do not establish already-installed native enforcement. [Whole-PR quality](F7-F9-quality.md) records independent source review and final evidence reconciliation; current remote review/CI and merge gates remain separate.
