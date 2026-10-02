<!-- markdownlint-disable MD013 -->
# A02 implementation supplement

RESULT: Initial helper-banner compliance issue mechanically corrected and verified. No remaining finding in this bounded production source/help/docs inspection; no functional issue found in the scoped guard/date inspection. This is supplemental prepublication source inspection, not final independent quality acceptance or remote review.

Requested route: gpt-6.1-sol / medium; effective settings unavailable. No descendants, tests, candidate execution, execution-policy bypass, public actions, or product/planning/native writes. Only the dedicated independent scratch snapshot/report was written.

## Stable inputs and read scope

Product checkout HEAD remained `fe3d6738d5b331f88e21bf6b9815883b3bb353b8`. Read the complete three production diffs against that commit and relevant surrounding source from the isolated `A02-snapshot`; before/after raw SHA-256 matches for all three files. The focused SelfTest file was neither inspected nor run. Canonical F2 selection P at `ed6363593aa363ed64f873c2511ef2d0824412d8`, F3 selection GI at `90f474a348f1b45b87250205777718dcf8e944a8`, and integrated guide audit `244c4a6712208d53cbf991ecc3190d36affb06f0` remain the decision inputs; earlier full native guide reads were reused.

| Production path | Native base raw SHA-256 | Snapshot/after raw SHA-256 | Current bytes |
| --- | --- | --- | --- |
| `.github/workflows/Test-AgentInstructions.ps1` | `bb65599fde7cf98ecd868a608d43c85559282705df694f8a3f116c185bed2492` | `3d10373f936309b3a0f689030412957a3386305bb2386c5cc299ae102b28f5ae` | 418981 |
| `.github/workflows/agent-instructions.yml` | `1c9457868eb262fc7ed8583d1cfff2903288286f11c103a46f91703b04bef67d` | `48864f76b8511d349922614b49dafc7cde0df70ba3fc3dc8c23240fe621e7e2a` | 9769 |
| `CONTRIBUTING.md` | `fb4e2cb22a678a0b506b790dd370b8673c00eac52b11b0ba8e102c8edcb87c59` | `e6269a6addf416b7870203d4f4418d3975410cb27c4ebec3e8d1fffd9e173524` | 9036 |

Native base modes are all `100644`. Native blobs respectively: validator `3e60de7ada8f9fa356e5a69f80a7081cc9444b94`, workflow `2cd28ecaa2a8c96d2201a474905153654dc0ac27`, CONTRIBUTING `601bba20e7b86c66ad51f634ce35f0f4e31d359a`. Current uncommitted raw hashes identify inspected content, not native committed objects or acceptance.

## Initial issue and verified correction

`Test-RecursivePersonalMemoryIgnoreContract` line 3709 and `Get-InitialDocumentMetadataClassificationFailure` line 4871 in the stable validator snapshot introduce `.NOTES` banners reading only `PRIVATE/INTERNAL HELPER. Positional parameters are disabled.` Both are script-specific private helpers, with no distributable-helper exemption. The authoritative native `STYLE_GUIDE.md` line 856 (generated `powershell.instructions.md` line 861) explicitly requires the banner to state non-public-API status and warn that parameters, return shape, and positional contract may change without notice. These two banners omit those statements. Smallest repair: bring only those two banners into conformance with the already-used neighboring complete private-helper banner. This is help/documentation conformance, not a new rule or protected policy recommendation. No behavioral test was run for this comment-only repair. Final wording inspection confirms both helpers now contain the full required non-public-API and change-without-notice statements. The parent identified the same omission in two earlier PR helpers already at fe3d673; the final delta also completes `ConvertFrom-ParserJsonContext` and `Test-InitialMetadataCoveragePath` banners. All four production banners conform to the existing rule. No SelfTest helper was inspected here.

Canonical guide identity: mode `100644`, blob `21bbb515429eb5fdac47f14128a95d5fd55122aa`, raw SHA-256 `331a401e3f26dbd4c497e156784c8f3e41f17bc295ec9f6a734639f2d6bb62fd`. Previously proved complete byte relationship: generated guide is exactly a 73-byte/five-line frontmatter prefix plus the complete canonical guide. Full generated normative content was read; no unproved canonical-coverage claim is made. Docs and YAML full reads and their hashes are integrated in `docs/planning/action-items-2026-10-02/results/A02/review-F2-F3-guide-audit.md` at planning `244c4a6712208d53cbf991ecc3190d36affb06f0`.

## Scoped implementation observations

- Admission lines 6544–6571 reject mode collisions/missing endpoints, require full lowercase exact commit IDs, verify both commit objects and require checkout HEAD==B. This occurs before Markdown-parser bootstrap. Candidate classification is inert data through existing bounded regular-file/strict-UTF8 readers and shared strict schema context; the data-only branch returns at 6674 before parser bootstrap at 6677. No new candidate code/dependency execution was introduced in these changes.
- The absent-manifest branch is closed to B=`48f4d8a36c8faceee12afac78aaecea0d176125d` plus the exact prior validator hash, schema 2, empty authorizations and exact ordered Tier2/generated mappings. Existing-manifest validation uses B's actual exemption/authorization arrays. Unknown initialization does not gain authority.
- Workflow lines 100–101 call the accepted data-only guard after exact-H verification and before classification, without an ordinary/maintenance condition. Existing Stop behavior plus the explicit exit check make this fatal. The new call adds no candidate dependency installation. The already-owned A05 immutable acquisition question is outside this delta and remains with A05.
- `FinalizeMetadataNow` requires exact B/H and excludes SelfTest/data-only modes. The single previously captured trusted UTC clock is used. The explicit requirement flag reaches both versioned and nonversioned document consumers at 7066–7075. New/promoted/bootstrap input does not independently infer Now. Existing structural/calendar/nonfuture/baseline/version checks remain in the date helper branches; published invocation without Now reports date not verified, while Now success records B/H/date.
- CONTRIBUTING adds the actual accepted-worktree caller, locked dependency prerequisite, explicit-date option and honest unchanged-input later verification. It explicitly states that the older accepted checker lacks the mode and first installation needs proposed-code validation/independent review. The entire 5,909-byte native CONTRIBUTING prefix is byte-identical; only 3,127 bytes were appended, proving the prior encoding damage is absent in this snapshot. No unrelated production/doc hunk was observed among the three scoped diffs.

## Final mechanical follow-up

After the writer froze production, independently inspected the entire delta from the stable snapshot to final production. It contains exactly four completed private-helper banners and one description correction in `Get-DocumentMetadataClassificationExpansionFailure`: missing baseline now accurately fails that helper and requires the separate closed initialization proof. That description matches its actual rejection path and caller. Removing only full-line comments leaves the two validator byte streams **exactly identical**; this proves executable tokens and other non-comment text are unchanged, without executing the parser or validator. Workflow and CONTRIBUTING bytes remain exactly unchanged from the inspected snapshot. The final three SHA-256 values independently match the writer's supplied freeze identities:

| Final production path | Final raw SHA-256 | Bytes |
| --- | --- | --- |
| `.github/workflows/Test-AgentInstructions.ps1` | `da64afc90f005280f218569fd37a7a8eeb6097db0ee9738e25162671f9699f73` | 419697 |
| `.github/workflows/agent-instructions.yml` | `48864f76b8511d349922614b49dafc7cde0df70ba3fc3dc8c23240fe621e7e2a` | 9769 |
| `CONTRIBUTING.md` | `e6269a6addf416b7870203d4f4418d3975410cb27c4ebec3e8d1fffd9e173524` | 9036 |

Final hash readback remained stable. This closes the supplemental wording issue only; it does not broaden the inspection into final quality acceptance. The worker's separately running full checks and SelfTest changes remain outside this report's inspected scope.

## Limits

Source reading does not establish runtime correctness, cross-platform behavior, candidate acceptance, first-install authority, or full product acceptance. Parent-reported fixture results were not independently rerun or converted to receipts here. Native B48f4 itself lacks these modes; a proposed-code harness is not an installed accepted-B pass. Worker tests were still in progress. Subsequent edits invalidate these snapshot hashes; the final candidate still needs the parent's required checks and fresh independent/remote review. This inspection belongs to the active A02/PS224 loop: transfers 0/12, rounds 1/80, first request `2026-10-02T07:26:08.214692Z`, fixed deadline `2026-10-10T07:26:08.214692Z`. It spends no new transfer or request and has no separate loop.
