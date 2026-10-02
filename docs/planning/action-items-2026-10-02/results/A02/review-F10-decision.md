<!-- markdownlint-disable MD013 -->
# F10: retain later peer Metadata sections in optional-header validation

Status: implemented and locally validated in commit `b9c2d0ea4c04894a6ea3267e9daa662f27b5820b`; fresh remote reviews and native acceptance pending.

## Validation and relevant stakeholders

Codex review5396252708/comment4169355897 concerns exact PR224 head8b6c1da46b568cb3b44e60fc511a03ac1fc4edf0, tree6223b82bced692b5eb32e31bcbc5fd11447015f8. The detector stops at the first ordinary heading after the early H1. Actual helper reproduction returns false for an ordinary H2 followed by a peer H2 Metadata with invalid Status/date fields. The unchanged strict parser rejects its placement when called. The actual installed-policy private B/H caller nevertheless accepts that malformed retained-Tier2 README, exit0: reproduce.ps1/log. This is proposed-code caller evidence, not native initial-install authority. The initial scratch attempt omitted an existing Boolean argument and never invoked the caller; fixture-note.md preserves that limited setup error.

The immutable policy `.github/instructions/docs.instructions.md` blob0b0c1ddc83938cfa9706418d45f619b1bfa03ffd, mode100644, lines106/111 requires the optional Metadata section to be the first H2 and applies synchronization to intentional headers. Validator blobde064bb640f0e83e94bb0793ad545b14a9a86402 and SelfTest blob2a19f13914509c31e9112b0dea7987a9d3628f06 are the reproduced inputs. The actual caller also uses intent to preserve or null optional baseline content; a misplaced real prior section must not become a no-header adoption baseline.

F5's existing later example is `## Examples` followed by `### Metadata`, not a peer `## Metadata`. Preserve that negative. Quoted/fenced/list-nested/HTML/frontmatter content is not a parsed document-level H2. H1 titles alone remain optional. Ordinary later fields without a peer reserved section remain outside the bounded header-intent inference. This finding does not authorize treating all later prose or all deeper headings as metadata.

Relevant stakeholders are document authors and readers, both repository maintainers, local/remote agents, Windows/Linux contributors, CI/tooling maintainers, independent reviewers, and security/history custodians relying on real prior-header checks. They need malformed opt-in to fail without promoting examples or changing finalization authority. Generated-artifact consumers require unchanged generated exclusions. No cloud/state, credential, personal-data, external-service, localization or recovery operation changes are involved.

Hard constraints: preserve optional no-header documents, H3 example hierarchy, parsed container exclusions, exact canonical placement/date/version checks, real invalid-prior preservation, generated exclusions, F1–F9, ordinal path/category/grant authority, safe readers, and ordinary versus explicit finalization semantics. No protected policy change, manifest/schema, public mode, new naming ban or maintenance-authority waiver.

## Options and fresh rubric

N: no change/defer. D: inspect every parsed document-level H2 for the existing reserved Metadata marker; retain all other header-window logic and strict validation. L: inspect every later heading depth for that marker. V: recognize later H2 only when its metadata already parses successfully. A: require metadata on all optional documents. X: raw regex scan across the complete document. C: add per-path or per-section opt-in configuration. P: change protected policy to allow later Metadata sections. A new parser/framework adds no required capability beyond D; D reuses the current AST and validator, while a narrow path exception is C.

Fresh0–5 rubric: demonstrated current/prior coverage45; legitimate context fidelity30; reuse/maintainability15; implementation and recurring cost10. Total=sum(weight*score)/5. A high score cannot waive a hard constraint. Scores measure the concrete supported boundary, not empirical correctness.

| Option | Coverage45 | Context30 | Maintenance15 | Cost10 | Total | Key uncertainty or constraint |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| N | 0 | 4 | 5 | 5 | 49 | Confirmed caller bypass remains |
| D | 5 | 5 | 5 | 4 | 98 | Focused/current-prior tests must confirm the peer-H2 boundary |
| L | 5 | 2 | 4 | 4 | 77 | Promotes the retained H3 example |
| V | 2 | 5 | 4 | 4 | 68 | Malformed or misplaced opt-in remains invisible |
| A | 5 | 0 | 3 | 2 | 58 | Violates optional-document policy |
| X | 4 | 1 | 2 | 3 | 54 | Cannot reliably exclude parsed containers |
| C | 3 | 3 | 1 | 2 | 52 | Future opt-ins depend on duplicate configuration |
| P | 0 | 0 | 3 | 2 | 13 | Ungranted policy change; no validated need |

N retains the demonstrated bypass. L promotes the existing nested H3 example. V loses malformed intent and cannot validate forbidden placement before selecting it. A/P change ungranted policy. X promotes containers and examples. C duplicates intent authority and requires ongoing classification. D adds the missing peer-section signal with unchanged parser and caller contracts; no close viable alternative supplies the same boundary with less maintenance.

## Selected implementation and validation

Select D. After parsing body content, inspect all top-level heading blocks with tag h2. Return true when their rendered text matches the existing case-insensitive Metadata marker, including its already recognized optional trailing colon. Keep H1 titles and later H3 examples unchanged. Keep all existing Version/list-marker windows. Pass recognized content to the unchanged strict parser. Apply the same detector to current and real prior content. Do not null an invalid prior section. Keep generated paths excluded at the caller.

Change only Test-AgentInstructions.ps1 and its SelfTest. Add focused cases for later H2 with valid-looking, malformed, missing and stale fields; multiple ordinary sections; fallback/pre-title and setext H2; noncanonical reserved heading; and fenced, quoted, list-nested, HTML, frontmatter, H1 and H3 controls. Existing placement/date/Version tests continue to validate canonical metadata rather than changing their rules.

Use the existing bounded actual B/H fixture for retained-Tier2 README and optional catalog content with later H2, invalid real prior section followed by otherwise valid current metadata, and a legitimate nested H3 example. Assert the intended placement/prior error, not arbitrary failure. Reuse unchanged safe-reader, generated-exclusion, F1–F9 and identity evidence. Run focused checks first, then freeze and run one normal final-byte pre-commit under the declared runtime. Any scratch/test-only correction gets a short note, not a new material rubric. No guide text changes require an extra guide audit.

Parent owns native publication, exact final B/H reconciliation and independent quality. Round6/80, original PR deadline and transfer0/12 remain unchanged; A07 stays frozen.

## Validation checkpoint

Focused session89490 exited0. focused.log records peer-H2/container distinctions with retained F5/F7 optional transitions, actual retained-Tier2 and optional-catalog current placement rejection, preservation of a malformed real prior section, and acceptance of the nested H3 example. PSScriptAnalyzer Error scans and git diff --check pass. These tests reuse the actual production parser and caller; private installed-policy fixtures remain proposed-code evidence.

Frozen staged treeed2bd7cf9e28ffc363bfd0dd7ac95e6ee63cf770 on8b6c1da46b568cb3b44e60fc511a03ac1fc4edf0 contains exactly the two assigned100644 paths, with no unstaged changes. Validator blobb8ec6e9d8c088245cd9271a53c2572204f1cea72, raw SHA2566787d259a03a1a411b1eb260f7aad9c556ea94530cfde9bf88cf50365d145bc7; SelfTest blob9d99b2beabc448930f66b68ee0d37d7a49aadb2d, raw SHA2566c33b01bd4ddcb5bf601c0e80516ae3e258c43642fbf1b242b4d644d3a8aadda. One normal final-byte aggregate15981 passed all10 hooks, exit0 at2026-10-02T21:01:38.8759123Z after start20:24:14.0163539Z. precommit.log is the terminal pass. Final readback confirms unchanged HEAD/tree, both raw hashes/modes, exactly two staged paths, no unstaged changes and clean diffcheck. Product ownership is returned to parent for normal commit, native exact-endpoint checks and publication.

## Committed endpoint reconciliation

Normal commit `b9c2d0ea4c04894a6ea3267e9daa662f27b5820b`, parent `8b6c1da46b568cb3b44e60fc511a03ac1fc4edf0`, contains the exact frozen tree `ed2bd7cf9e28ffc363bfd0dd7ac95e6ee63cf770`. The normal commit completed without bypass. Root-owned endpoint session61184 exited0: author finalization and classification both passed for actual B48f4d8a/Hb9c2d0e at UTC2026-10-02. The fixture retained its accepted HEAD and exact staged candidate tree. Independent whole-PR quality reconciles the actual commit and final local evidence. Normal non-force publication and fresh native head readback confirm b9c2d0e; initial PR readback lagged and no push was repeated. Fresh remote pair, current CI and immediate native gates remain pending.
