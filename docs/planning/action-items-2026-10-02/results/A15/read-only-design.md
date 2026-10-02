<!-- markdownlint-disable MD013 -->
# A15 read-only design and owner decisions

Prepared 2026-10-02. This is preparation, not A15 acceptance or product completion. A00 and A01 are not accepted in the tracker read for this task. No product file, GitHub object, setting, branch, commit, or review request was changed. Transfers: **0/8**. PR clock: **not started**. Requested route: `gpt-6-astra/high`; effective settings were not exposed. The model-routing skill was read; this delegated worker did not create descendants.

## Evidence and current consumer

- Planning workspace: `PSStyleGuide`, branch `planning-CRT-PR-852`, HEAD `75d1b295723e887f9df268b12e5f9f38cb8ec248`. Read STATUS first, then README, LOOP-POLICY, ROUTING-AND-PARALLELISM, A15, DECISION-PROCESS, A16/A17, native TF AGENTS, the complete TF25 snapshot, and the complete T4 contract/fixture appendix.
- Product source: TF native main `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`, tree `dc8f6b82588b8f874d34cd5d0155791aea5793f1`; PS native main `48f4d8a36c8faceee12afac78aaecea0d176125d`, tree `640ee4c0974fb604b2ebf0a1e1e1a328bd213ddc`. Product observations below come from `git show`/`git ls-tree`/`git grep` at those objects, not planning-tree product copies. TF main was also read from authenticated GitHub.
- [TF issue 25](https://github.com/franklesniak/TerraformStyleGuide/issues/25) is OPEN, updated `2026-07-31T11:48:27Z`. The authenticated live body equals the saved 64,232-character snapshot. GitHub connector issue/comment reads succeeded; all-page comment read returned zero comments. Initial CLI issue read preceded discovery of the connector preference; subsequent supported reads used the connector. REST Discussions inventory returned HTTP 410, “Discussions are disabled for this repo.” This does not dispose of requirements.
- Every nonempty snapshot line occurs in `docs/planning/TerraformStyleGuide/06TerraformStyleGuideT4.md`, except the issue's pointer to that appendix. The appendix adds fixture detail. It contains 31 acceptance bullets, 224 unique explicit case IDs, and an additional required 18 × 3 × 2 = 108 signal IDs. These 332 IDs are a floor, not a complete finished catalog: several prose families and unsplit grouped cases need additional IDs.
- Native TF has `Test-StateRecoveryExamples.mjs` (312 lines), not `.sh`. It extracts `SR-SETUP` plus seven `SR-*` actions from the normative guide, executes Linux Bash fixtures, and uses real GNU publication calls through fault-injection wrappers. It has no `SM-*` family, T4 helper, PowerShell recovery harness, or T4 catalog. It logs JSON argv arrays, not the requested NUL framing. Its use of real `ln` does not prove T4's synchronized two-publisher race.
- `Test-StyleGuideArtifacts.ps1:490` runs the `.mjs` recovery harness with a 300-second child limit and integrity snapshots. `build.yml` upload depends on `verify`, which invokes that artifact verifier. Thus existing T2 tests already gate publication in the same build run. `Test-CiHelpers.test.mjs` tests failure, missing harness, signal, timeout and mutation of source/config/workflow-output channels.
- `markdownlint.yml` currently has independent push, PR and schedule triggers, with Linux policy/lint jobs. It is not callable and has no Windows jobs. `Initialize-CiToolchain.ps1` rejects non-Linux platforms. Current root package pins Node `24.18.1` and npm `11.16.0`. The historical minimum/preferred runtime topology must not be presumed current or restored without A07's decision.

### Current source consolidation map

Line numbers refer to TF main above. Generated copies must follow the generator; no hand edits.

| Current source occurrence | Classification and proposed owner |
| --- | --- |
| `STYLE_GUIDE.md:1986` direct pull in refactoring guidance; `2720` Bash and `2723` commented PowerShell pull | A16 replaces executable backup copies with canonical Bash/PowerShell `SM-BACKUP-PULL` references or the one canonical block. A17 verifies no old copy remains. |
| `STYLE_GUIDE.md:2742` direct old-backup push; warning `2745` | A17 replaces with exceptional guarded push/recovery procedure; warning alone is insufficient. |
| `STYLE_GUIDE.md:1969` declarative preference; `2728`/`2732` backup-before-rm/unlock explanations | Keep preference and accurate backup advice. A17 ensures unlock is never an automatic precursor to mutation. |
| `STYLE_GUIDE.md:2389` setup; `2552,2572,2595,2614,2637,2657,2683` provider actions | A11 owns these T2 canonical blocks. A15 does not duplicate them or count retrieval as permission to overwrite active state. |
| `STYLE_GUIDE_RATIONALE.md:232` upgrade backup; `318` downgrade push | A16 backup reference; A17 reviewed recovery reference. No direct lower-serial push remains. |
| Rationale `1256` and `1602` force-unlock; glossary `1877` | A17 keeps an accurate own-abandoned-lock explanation with exact nonce and verified absence of an active owner. No immediate push/rm chain. |
| Rationale `1295` direct rm; `1705` direct pull and `1708` rm | A17 prefers `removed { lifecycle { destroy = false } }`; exceptional case references canonical singleton removal. A16 removes truncating backup copy. |
| Rationale `1644` old S3 listing; `1652` push; `1659` corrupt-file move | A17 links exact T2 provider discovery/retrieval, then separately guarded recovery; replaces clobbering move with reviewed corruption-preservation procedure. |
| Rationale `683`–`757` T2 explanation, `1853` historical changelog, state-version glossary | Keep truthful history and T2 explanation. Add current rationale and version row; do not rewrite a historical row as new evidence. |

## Proposed implementation boundary

Use A16 for the nonmutating foundation: five fixed helper interfaces (inspector, difference reviewer, address resolver/parser, confirmation, plus platform path/stream adapters), canonical backup blocks, complete role allocation, catalog, and actual platform harnesses. Production helpers must not expose arbitrary command execution, environment fallback, fixture modes, or stdin confirmation. The recovery preparer may be a Gate B-only helper importing the frozen inspector; it must not modify Gate A contracts. Freeze all Gate B case definitions and shared schemas at Gate A, even though destructive-case execution belongs to Gate B.

Use A17 for corruption preservation, push, rm, recovery, post-verification, and all unknown-outcome handling. A16 must make zero mutation child calls, including test mutation stubs. A17 uses only isolated fixture backends. A normal PR review is not either operational approval. Obtain a real operator and independent peer approval on the immutable Gate A commit/tree, helper blobs and versions, role table, catalog, limits, platforms and results. Bind Gate B's second approvals to that digest and its final commit. Any changed Gate A dependency invalidates Gate A approval.

Keep each source, backup, report, verification pull and recovery candidate role distinct. Do not infer one tuple from another. Snapshot public values once; remove them from child environments. Keep fresh outputs separate from existing immutable inputs. Preserve native outcomes in structured metadata, no-clobber publication, continuous writer exclusion, locking, secret limits, and retention after unknown outcome. Scores below recommend scope clarifications; they do not grant them.

## One acceptance-to-test table

Abbreviations: **S** = normative source plus rationale and four generated copies; **B** = Bash `.mjs` exact-block harness; **P** = proposed `Test-StateRecoveryPowerShell.ps1` on Windows 5.1 and 7; **I/D/C/R/Q** = proposed Inspect / Difference / Confirm / Resolve-address / Prepare-recovery helpers. All T4 helpers/tests below are missing on pinned native main. “A → B” means foundation proof in A, caller integration in B. AC numbers preserve the issue's bullet order.

| AC | Required outcome | Current source/helper gap; test owner | Gate |
| --- | --- | --- | --- |
| 01 | No truncating final backup | S occurrences above; B BACKUP and P BACKUP refusal/publication cases; scan both sources and generated copies | A, final B sweep |
| 02 | Workspace/backend/native status/parse/lineage/serial/digest/mode/no-replace | S canonical backups + I; B/P valid and each invalid prerequisite, identity before/after publication | A |
| 03 | Backend is explicitly operator-attested | S + C input validator; false-but-valid attestation fixture must report operator-attested, never machine-proved | A → B |
| 04 | Backend grammar 16–202 bytes | Common validator; both platform boundary cases 16,201,202,203 and each 64-byte component; no child/path call on invalid value | A |
| 05 | Complete separate state-bearing roles | Platform adapters + role table; every role/platform tuple/type/identity/cleanup case; D4 omissions remain unresolved | A → B |
| 06 | Real Gate A/B approvals, zero mutations, digest binding | A fixture child counter; immutable accepted evidence and drift-invalidates-gate check; actual human approvals | A and B |
| 07 | POSIX modes and Windows SID/DACL inspection | Bash adapter + one reviewed C# Win32 adapter; owner/mode/ACL/reparse failures at every required phase | A → B |
| 08 | Raw cross-edition .NET bytes | P BACKUP-01/02 + UTF8; D3 must resolve incompatible Node/exclusive-handle instructions before implementation | A |
| 09 | 65,536-byte stderr ceiling, overflow 73, drain, secrecy | I/platform collector; P BACKUP-14/16/17/18/19/20 and independent boundary/error fixtures | A |
| 10 | Bounded full stream tokenization | I: all profile/process/UTF8/JSON/metadata/ceiling cases; no `JSON.parse` whole-state shortcut | A |
| 11 | One reviewed handle-based Windows path/identity/publication adapter | P real Win32 traversal/file-ID/link-count cases, unsupported API fail-closed; no pathname-only substitute | A |
| 12 | Real exclusive publication and race | B BACKUP-12 plus P BACKUP-11/12, ordinary/directory/link conflicts; two synchronized actual processes | A |
| 13 | Unsupported publication retains validated temp, final absent | B BACKUP-14, P BACKUP-13; no move/copy fallback; publication-uncertainty differs from proved prepublication failure | A |
| 14 | Corrupt-source preservation and paused writers, 1→2→1 | S corruption + B CORR-01..15 and appended atomic cases; zero-byte correction in D4/D5 | B; path primitive A |
| 15 | Exceptional reviewed guarded non-force push | S push + D/I/C, B PUSH-01..29; each missing prerequisite has zero mutation calls | B |
| 16 | Exact 16-lowercase-hex confirmation prefixes | C CONFIRM-09..13,57..69; B/P caller binding and mismatch zero-call check | A → B |
| 17 | Canonical terminal-byte confirmation, status 68 | C CONFIRM-01..69 and platform terminal lifecycle; no stdin, normalization, secret input recording, or second-record acceptance | A → B |
| 18 | Offline secret-safe diff and exact manifest/allowance equality | D/I; provenance drift, dynamic/unknown identity, sensitive subtree, index/report ceiling, canary/encoding/hash leakage tests | A → B |
| 19 | Next serial/no-op/serialization-only/native or serial-splice recovery | D/I/Q; B PUSH-20..29 and preparer byte-splice/overflow/drift cases; no direct old-backup push | A core, B operation |
| 20 | Exact lock timeout, no bypass, no-lock external exclusion | B exact argv and exclusion fixtures; native help for selected Terraform version; absent exclusion means zero calls | B |
| 21 | Closed rm backend mode and local-only command backup | B mode/config/workspace drift; local one validated `-backup=`, other modes zero; no second attempt after failure/unknown | A role proof, B operation |
| 22 | Declarative preference, singleton address/dry-run/recheck/backup/plan | R ADDRESS-01..35 nonmutating; ADDRESS-36 and B RM-01..17 end-to-end; exact list bytes determine cardinality | A → B |
| 23 | No lock disable/ignore-version/auto-unlock/auto-rollback | S static inventory plus B negative argv/call-sequence assertions after every failure/signal | B |
| 24 | Provider duplicates reference exact T2 blocks | S stale S3 example and all provider reference scan; preserved A11 source/harness identities | B |
| 25 | Exactly one result per applicable SM case/cell | Catalog reconciliation in B/P/helper tests; no skipped case counted as pass | A definitions, B complete runs |
| 26 | Atomic closed catalog plus 108 signals | Independent ID/product construction; D5 split grouped rows; per-cell expected calls/path/remote state | A definitions, B complete runs |
| 27 | Prior SR regression remains green | Existing B T2 inventory, plus artifact verifier/helper tests; current evidence cannot prove future unchanged behavior | A and B |
| 28 | Signals 129/130/143; one cleanup; unknown started mutation | B synchronized 108-phase product; C 54..56 separate; D5 resolves cleanup-only status conflict | A backup 24, B remaining 84 |
| 29 | Version/date/rationale and four fresh generated outputs | A06 exact generator, artifact verifier, twice-generation raw Git-byte comparison, LF/BOM/CR checks | A and B finalization |
| 30 | Windows 5.1/7 evidence in same-run approval dependency | A03/A07 integration + validator and negative workflow fixtures; D2 requires owner topology disposition | A and B |
| 31 | Exact changed/staged sixteen files | D1 approved current path manifest; staged-content tests; cannot claim literal old set and current topology simultaneously | A and B |

### Complete oracle-family allocation

This inventory preserves the appendix; ranges denote every integer ID, not representative sampling. Linux uses the supported T2 Bash/GNU tools; P means both Windows editions. Helper tests run in applicable Linux and Windows cells. Terminal signal cells are POSIX-specific; Windows termination/restoration needs a separately truthful platform oracle (D3), not simulated POSIX success.

| Family | Cases and owner | Gate/evidence |
| --- | --- | --- |
| Bash backup | `SM-BASH-BACKUP-01..20`, B + I + platform adapter | A; valid bytes, existing classes, partial/native failures, path/JSON/BOM/metadata, race, post-publication mismatch, unsupported links, cleanup substitution |
| PowerShell backup | `SM-PS-BACKUP-01..23`, P + I/collector | A on 5.1 and 7; ASCII/non-ASCII, start/native errors, reparse/conflict, real publication/race, stderr 65,535/65,536/65,537, backpressure/read/late-EOF, cleanup |
| Strict UTF8 | `SM-PS-UTF8-01..15`, P + I | A on both editions; every stated malformed/BOM/max-scalar/chunk-boundary oracle; split a grouped boundary family into atomic cells if required |
| Confirmation | `SM-CONFIRM-01..69`, C plus wrapper integration | A helper has no mutation path; B caller integration. Preserve exact serializer/serial/digest/4096/4097/terminal/mode/close/CR-LF/second-record/UTF8/field/recovery cases |
| Corruption | `SM-BASH-CORR-01..15` plus unnumbered barriers, B | B; local original-source unlink is not a Gate A activity. Real identity/link/digest preservation; retain names on uncertain publication |
| Push | `SM-BASH-PUSH-01..29`, B/D/C/Q | B; alternative selected, every missing guard, mismatch class, native/lock/provider failure, exact argv, verification/rollback refusal, serial/no-op/recovery/drift |
| Rm | `SM-BASH-RM-01..17`, B/R/C | B; declarative choice, address/prerequisite/dry-run/confirmation failures, exact local backup, verification/plan mismatch |
| Address | `SM-ADDRESS-01..36`, R + B | A 01..35 (fixed nonmutating list/dry-run only); B 36. Preserve grammar, key escaping, 2048/2049, 64-module-step limit, instance cardinality, framing/limits/stderr/native/drift; append missing atomic module/key boundary rows |
| Signals | 108 literal IDs from 18 phases × HUP/INT/TERM × OK/FAIL cleanup | A: BACKUP-PRECREATE/PULL-PARTIAL/VALIDATED/PUBLISH-UNCERTAIN (24). B: CORR-PRELINK/LINK-UNCERTAIN/PREUNLINK/UNLINK-UNCERTAIN; PUSH-PRECONFIRM/PREPUSH/REMOTE-UNKNOWN/VERIFY; RM-PREDRYRUN/DRYRUN/PRECONFIRM/PRERM/REMOTE-UNKNOWN/VERIFY (84). Each proves cleanup count 1, signal status, exact calls/path/remote state. C54..56 are not duplicated. |
| Unnumbered role/identity/input families | Each role/platform: missing versus empty, wrong literal, nested/sibling path, owner/mode/DACL/type/reparse/device, VCS/shared membership, existing target, unavailable inspection; backend/workspace/label/digest grammar | A catalog allocation and execution; B consumption. Include distinct source-writer attestation. No fallback/derived tuple. |
| Unnumbered inspector/collector families | Profile canonical numbers/default extras/hard caps/capacity; raw/show bounds −1/exact/+1; start/exit/signal/deadline/TERM/KILL/read/write/flush/close/backpressure; each UTF8/BOM/JSON/suffix/duplicate-key/metadata/format/parser limit | A I/adapter tests; success requires complete drains and reinspection. Bound duplicate-key bookkeeping memory too; streaming alone does not prove bounded memory. |
| Unnumbered diff/provenance families | Manifest schema/size/duplicate/depth/rows/string limits; commit/tree/index/untracked/config/module/lock/provider/subject/schema drift; unknown/dynamic identity; sensitivity union; per-run HMAC/key lifecycle; exact allowances; raw/Base64/hex/URL/JSON/substring/stable-or-ephemeral-hash canaries; indexes/report bounds | A D/I tests, B actual caller binding. Report values and value-derived leaf digests remain forbidden. Whole-file input digests required by the contract remain protected metadata. |
| Unnumbered recovery families | Unique serial offset; all nonserial bytes equal; zero/max/overflow; fresh current recheck; native restore/permission/locking/version behavior; ambiguous result; secret report checks | Q/B in B, importing frozen I; backend-native branch still needs new confirmation, one call and fresh verification |
| Catalog/source/generated/workflow equality | Five SM marker pairs, T2 inventory, exact source/generated block bytes, dispatch/catalog/result/cell equality; backend ceiling 206 forbidden; workflows cannot omit/fail-open Windows or recovery | A schema/fixtures, B full final equality. The current SR start-marker format may remain where its extracted equality is proved; do not silently rewrite A11. |

## Finding-specific decisions

These are recommendations awaiting the stated owner decisions. No implementation has occurred. Scores are judgments, not measured safety. For each table, 0 means fails the criterion, 3 means viable with meaningful limits, and 5 means strongest fit; total is sum(weight × score)/5 out of 100. Hard constraints override totals. Deferral preserves safety only by leaving the affected requirement open.

### D1 — Replace stale path equality with an approved current manifest

**Validity.** The old list names a nonexistent `.sh` and excludes current consumers required by Windows/CI changes. Exact sixteen-file equality would either require an artificial rename or exclude necessary tests/integration. Stakeholders: both maintainers, T2/A06/A07/A03 owners, authors, generated-output consumers, CI/review engineers, agents, audit/history owners and schedule/cost owner. End users are affected through published examples; no accessibility or cloud-permission change is proposed.

**Options/rubric.** Compare literal preservation, historical reconstruction, exact current manifest, and deferral. Weights: capability completeness 35, wrong-scope prevention 30, reviewability 25, churn 10. Hard constraints: no safety item disappears; no unowned coupled edit; owner approves the changed scope.

| Option | Complete | Scope | Review | Churn | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Keep old list unchanged | 1 | 2 | 3 | 5 | 44 | Missing file/integration |
| Restore historical `.sh` and old machinery | 3 | 2 | 2 | 1 | 45 | Unproved benefit and broad churn |
| Approve exact current per-gate manifest | 5 | 5 | 5 | 4 | 98 | Requires concrete owner disposition |
| Defer affected implementation | 1 | 5 | 3 | 5 | 62 | Requirement remains open |

**Selection.** Keep `Test-StateRecoveryExamples.mjs`. Replace the obsolete locator in the current requirement disposition. Keep exact scope checking. Approve the actual path list before implementation. Do not add a `.sh` wrapper only to meet the old count.

Concrete base list remains the same two sources and four generated files; the `.mjs` harness; new P, C, I, D, Q, R and catalog; `markdownlint.yml`; and `Validate-WorkflowPolicy.mjs` (sixteen paths with the locator substituted). Additional candidate paths, only where the accepted topology requires them: `build.yml`, `Validate-WorkflowPolicy.test.mjs`, `workflow-policy-cases.json`, `workflow-policy-contract.json`, `Classify-InstructionMaintenance.mjs` and its test, `Initialize-CiToolchain.ps1`, `ci-toolchain.json`, `Test-CiHelpers.test.mjs`, and `Test-StyleGuideArtifacts.ps1`. A03/A07/A06 own their foundation changes first; A16 consumes them. Do not claim all candidates must change. Do not touch agent instructions under this recommendation. Any later specific protected-instruction change needs its own concrete authorized proposal.

**Verification.** `git ls-tree` proves the `.mjs` locator; caller grep finds the artifact verifier and classification/test consumers. A future check compares changed/staged paths to the owner-approved per-gate manifest. Path count alone is never acceptance.

### D2 — Preserve same-run publication gating using the accepted current topology

**Validity.** Publication already depends on Linux T2 tests through `verify`; the old reusable Markdown topology no longer exists. Windows evidence and reviewed Windows runtime acquisition are absent. Stakeholders: CI/platform/security engineers, maintainers of both repos, release consumers, review/agent operators and cost owners. Backend operators need trustworthy platform evidence but do not authorize CI topology; no live backend access is required.

**Options/rubric.** Weights: same-SHA fail-closed gate 40, platform reproducibility 30, integration clarity 20, maintenance 10. Hard constraints: Windows 5.1 and 7 must execute; failure/missing/skipped evidence blocks publishing; no new privilege, unreviewed external action, or independent green-run substitution.

| Option | Gate | Platform | Clarity | Maintain | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Leave current Linux-only topology | 3 | 1 | 5 | 5 | 60 | Missing Windows requirement |
| Restore reusable Markdown workflow and caller dependency | 5 | 5 | 3 | 3 | 88 | Larger A03 change; literal AC30 |
| Add Windows verification to accepted build dependency graph | 5 | 5 | 5 | 4 | 98 | Requires explicit AC30 topology amendment |
| Run separate Windows workflow and link its badge | 1 | 4 | 2 | 3 | 46 | Fails same-run hard constraint |
| Defer to accepted A03/A07 result | 1 | 1 | 5 | 5 | 44 | Safe pause, not delivery |

**Selection.** Prefer Windows verification jobs in the accepted event-owning build graph. Require all platform results before publication. Pin the same revision in each job. Extend the validator and negative fixtures together. If A03 selects the reusable topology on its merits, consume that result instead. Do not change topology concurrently with A03.

**Verification.** Current `build.yml` and artifact-verifier call establish the existing gate. Future negative tests must prove skipped, missing, wrong-SHA and failed Windows/T2 cells prevent upload, including applicable events. A07 must supply reviewed Windows Node acquisition and the exact supported runtime matrix. Existing Linux-only installer and a hosted runner's ambient Node do not satisfy that dependency.

### D3 — Resolve incompatible Windows capture and process contracts

**Validity.** T4 requires `.NET FileShare.None` creation with an exclusive retained handle, then Node reopening that path. .NET documents that another open fails until that handle closes. AC08 requires raw .NET capture on both editions; the inspector section instead prohibits separate stream-limit implementation and mandates a shared Node collector. Windows Node signal termination is abrupt; it cannot truthfully implement POSIX graceful TERM then KILL semantics. Stakeholders: Windows/Linux operators, security and incident engineers, state-data owners, runtime/platform maintainers, reviewers, authors and cost owners. No cloud account access is needed to establish these contradictions.

**Options/rubric.** Weights: protected identity/no-clobber 35, bounded byte/process correctness 35, cross-edition clarity 20, maintenance 10. Hard constraints: no unlocked silent path handoff, no string decoding of state, all stream/timeout/cleanup oracles, honest platform termination semantics, explicit approved contract amendment.

| Option | Identity | Bounds | Clarity | Maintain | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Implement both conflicting instructions literally | 0 | 1 | 1 | 3 | 17 | Reopen fails |
| Close exclusive handle; Node reopens with verified transition | 3 | 5 | 4 | 5 | 82 | Changes exclusive lifecycle and AC08; requires exact transfer proof |
| One Windows .NET collector; common Node tokenizer; Linux Node collector | 5 | 5 | 4 | 3 | 92 | Explicit collector-contract amendment; duplicate adapter limits need parity tests |
| Native handle transfer into Node | 5 | 4 | 2 | 1 | 73 | New interop ABI without evidence; not a free Node CLI feature |
| PowerShell 7.4 redirection only | 1 | 1 | 1 | 5 | 28 | Fails 5.1 and bounds/publication |
| Defer Windows | 1 | 1 | 4 | 5 | 40 | Fails required coverage if called complete |

**Selection.** Prefer a fixed Windows .NET collector used by both PowerShell editions. Write raw bytes through the acquired exclusive handle. Drain stderr concurrently. Enforce the selected limits from one shared policy definition. Close the writer after capture and ACL/identity inspection. Run the common strict tokenizer on the same revalidated identity. Use a reviewed read-sharing lifecycle for validation and close the required handles before publication. Reinspect both names after the real hard-link call. Do not claim exclusive-write ownership persists across a necessary close. Refuse any mismatch. Use explicit Windows process-tree termination and closure evidence; retain uncertainty if descendants or inherited pipes cannot be bounded. Record POSIX TERM/grace/KILL separately from Windows termination. This is a proposed contract, not a proved adapter.

**Verification.** Official [.NET FileShare](https://learn.microsoft.com/en-us/dotnet/api/system.io.fileshare?view=netframework-4.8.1), [CreateHardLinkW](https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-createhardlinkw), [PowerShell redirection](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_redirection?view=powershell-7.5), and [Node child process](https://nodejs.org/api/child_process.html) establish these API limits. NTFS publication and ReFS explicit refusal stay distinct. Gate A must prove adapter parity on actual Windows 5.1/7, raw non-ASCII bytes, blocked/replaced path transitions, long-lived child pipes, cap overflow, deadline and close failures. No such product experiment ran in this read-only task.

### D4 — Complete role allocation and fixed acquisition interfaces

**Validity.** The “sole allocation” omits the separately required difference manifest, current/proposed show files, provider schema, HMAC indexes, configuration/module/lock identities, repeated rm match path and corruption source. Inspector's only two modes cannot capture provider schema or state-list using the same bounded collector without another fixed interface. The difference CLI calls its configuration-root argument an ordinary file although it must be a directory. These gaps can cause secret storage outside the protected context or inferred role reuse. Stakeholders: privacy/data owners, incident and backend operators, security engineers, Terraform/module/provider maintainers, developers/reviewers, and audit owners. Accessibility is not changed by file allocation; diagnostic clarity still matters to operators.

**Options/rubric.** Weights: complete secret/identity authority 40, bounded correctness 30, operator clarity 20, implementation cost 10. Hard constraints: no generic command runner, ambient temp, guessed tuple, or unreviewed directory-as-file treatment.

| Option | Authority | Correct | Clear | Cost | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Infer omitted paths from existing parents | 1 | 2 | 2 | 5 | 38 | Violates explicit role authority |
| Remove difference/recovery requirements | 0 | 1 | 4 | 5 | 32 | Unauthorized safety loss |
| Extend exact role table and fixed operation adapters | 5 | 5 | 4 | 3 | 92 | Needs approved schema/interface detail |
| General command/role plugin framework | 3 | 3 | 2 | 1 | 52 | Unneeded authority and maintenance |
| Defer incomplete features | 2 | 2 | 4 | 5 | 54 | Still open |

**Selection.** Extend the role table before code. Allocate explicit triples for externally supplied difference manifest, current show, proposed show and provider schema. Allocate a fresh repeated-match triple. Allocate the corruption-source triple already specified by the procedure. Treat configuration root and module roots as separately reviewed directories; retain their Git/module/lock identity checks. Make HMAC indexes helper-private within the difference invocation context; keep their 256 MiB ceiling and exact cleanup. Do not merge these roles with state backups. Use the same closed bounded collector core through distinct fixed operations for workspace-show, state-list, provider-schema and dry-run; do not permit arbitrary Terraform argv. Review the separate limits and output classification for those operations before freezing Gate A.

Proposed public triple prefixes: `DIFF_MANIFEST`, `DIFF_CURRENT_SHOW`, `DIFF_PROPOSED_SHOW`, `DIFF_PROVIDER_SCHEMA`, `RM_RECHECK_MATCH` (each `_PARENT`, `_PATH`, `_PARENT_ATTESTATION`). Existing raw-state and output-report role names remain unchanged. The configuration root is a Git/configuration identity, not a secret-file tuple. The helper must consume the caller's verified identity through a reviewed explicit interface; the original path-only CLI does not by itself prove the tuple. This identity handoff remains a specific interface decision before Gate A. Corrupt-source size is `0..S`; validated state remains `1..S`.

**Verification.** Cross-reading T4's role, difference, inspector, rm and corruption sections proves the omissions. Future catalog cases must cover each new role's absence/type/identity/bound/lifetime and forbidden role aliasing, plus wrong-operation/unknown-argument rejection for every acquisition mode. An attestation remains an operator statement, even when every platform inspection passes.

### D5 — Freeze consistent atomic oracle semantics

**Validity.** Native T2 cleanup-only status is 74. T4 says exact T2 reuse but specifies cleanup-only 1 and general uncertainty 72. Several “atomic” rows still combine failures (CORR-03 directory/link; CORR-04 any final class; CONFIRM-67 three field mismatches; ADDRESS-32 nonzero/signal). The corruption paragraph says both names are absent before-link failure, contradicting source retention; its role bound excludes the explicitly allowed empty corrupt source. Address prose globally forbids whitespace while allowing an internal quoted-key space. Existing-final refusal cannot make final absent, and post-publication uncertainty cannot delete output to satisfy a blanket absence sentence. Stakeholders: test authors, operators consuming status, reviewers, both maintainers, auditors and automated acceptance consumers. These differences affect recovery and not just wording.

**Options/rubric.** Weights: unambiguous failure safety 40, compatibility/evidence continuity 25, oracle completeness 25, churn 10. Hard constraints: preserve source and uncertain evidence; one exact result per ID/cell; no relaxed confirmation/address parsing.

| Option | Safety | Continuity | Complete | Churn | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Keep contradictory prose and let each harness choose | 1 | 1 | 1 | 5 | 28 | Inconsistent acceptance |
| Rewrite/renumber all cases and statuses | 4 | 1 | 4 | 1 | 59 | Breaks append-only history |
| Narrow old IDs, append atomic IDs, approve explicit semantic precedence | 5 | 5 | 5 | 3 | 96 | Owner must resolve status/grammar wording |
| Delete grouped cases | 1 | 2 | 0 | 5 | 28 | Loses required failures |
| Defer conflicting rows | 3 | 5 | 1 | 5 | 64 | Incomplete catalog |

**Selection.** Preserve each existing ID once. Narrow its fixture to one case. Append IDs for the remaining cases. Preserve native T2 status 74 and its tests. Propose T4 cleanup-only 72, while a prior nonzero primary or signal status wins; amend the obsolete cleanup-only 1 assertion explicitly. Keep signal statuses 129/130/143. Before corruption linking, retain the source and leave the destination absent. Permit zero-byte corrupt evidence. After uncertain linking, retain all remaining names. Permit space only inside the approved canonical quoted key; reject external whitespace. Existing targets remain unchanged. After publication uncertainty, retain names instead of promising final absence. No interpretation becomes operative until the owner accepts these contract corrections.

**Verification.** Static enumeration found 224 distinct explicit IDs and no duplicate table IDs; independent phase-product math gives 108. Future catalog generation must additionally enumerate all unnamed families and split grouped errors without renumbering. It must reject missing, duplicate, unexpected, multiply emitted or inapplicable results. Freeze exact status/reason/native-status precedence and path outcomes before Gate A. No oracle is considered passed by this inventory.

### D6 — Keep the manual fallback bounded; prefer native/declarative actions

**Validity.** Current direct push/rm/corrupt-move examples are real unsafe consumers. Removing all manual guidance is smaller, but loses the issue's exceptional-recovery use case. Full custom automation is also unnecessary: the issue requests copy-safe manual procedures with human authority. Stakeholders: incident responders, backend/cloud administrators, infrastructure/security/privacy owners, maintainers, new and experienced Terraform users, reviewers, auditors, vendor-support and downtime/cost owners. The PS peer needs only genuinely common tool changes, not Terraform recovery text.

**Options/rubric.** Weights: incident safety 40, supported recovery coverage 30, operator comprehension 20, maintenance 10. Hard constraints: no force/lock bypass, no blind old-backup push, no automatic retry/rollback after unknown outcome, genuine two-gate human approvals.

| Option | Safety | Coverage | Comprehension | Maintain | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| Keep current examples plus warning | 1 | 2 | 3 | 5 | 42 | Unsafe executable copies remain |
| Remove all manual operations; native/declarative only | 5 | 2 | 5 | 5 | 82 | Scope reduction requires owner; exceptional cases unsupported |
| Native/declarative first; bounded reviewed exceptional fallback | 5 | 5 | 4 | 3 | 92 | Requires full Gate A/B evidence |
| General automatic recovery tool | 2 | 5 | 2 | 1 | 56 | Unrequested destructive automation |
| Defer while leaving issue explicitly open | 1 | 1 | 4 | 5 | 40 | Does not fix current examples |

**Selection.** Prefer declarative removed/moved/import and backend-native recovery when they express the operation. Keep the exceptional manual fallback in scope. Require one approved attempt and fresh verification. Never present a downloaded version as authorization to overwrite current state. Do not port Terraform-specific helpers to PS solely for byte symmetry; compare shared tooling and record narrowly proved language exceptions.

**Verification.** HashiCorp's [state rm](https://developer.hashicorp.com/terraform/cli/commands/state/rm) confirms that removal forgets bindings and that `removed` blocks are reviewable alternatives; `-backup` is local-only. Its [state push](https://developer.hashicorp.com/terraform/cli/commands/state/push) documents exceptional use and lineage/serial safeguards. [State locking](https://developer.hashicorp.com/terraform/language/state/locking) confirms backend-dependent locking and own-abandoned-lock restrictions. The contract's exact next-serial rule is deliberately stricter than the CLI's documented guard. Validate flags and serial behavior against the chosen exact Terraform executable before a fixture contract is accepted. This research did not execute Terraform or any recovery operation.

## Required predecessor primitives and exact next decisions

1. **A00/A01:** Accept historical dispositions and the current tree/issue baseline. This report neither grants retirement nor satisfies those dependencies. Refresh mutable native state before a later mutation.
2. **A11/T2:** Supply accepted Linux Bash 5/GNU/jq runtime scope; protected-parent and exact-identity/publication/cleanup routines; all eight source markers; seven provider action tests; signal/native-status behavior and evidence. Reuse these outcomes, not `sr_run` wholesale: it infers parent from `SR_DEST`, uses a new output directory, uses jq basic state validation, and does not provide T4's separate attested direct-child file tuples or strict streaming parser.
3. **A06:** Supply exact generator/artifact integrity behavior, preservation of current recovery admission, all four output mappings, generated-copy equality and post-merge evidence. The current 300-second recovery subprocess budget needs a measured fixture-runtime decision if T4 exceeds it; do not silently remove the bound or add arbitrary retries.
4. **A03/A07:** Select/accept workflow topology and reviewed Linux/Windows Node installation and matrix. Update validator, admission closure and tests atomically for every newly executable helper. New loader files must join the accepted admission inventory; adding only test source files is insufficient. Preserve locked npm/lint/audit behavior. T4 adds no npm package by default. Do not use a Linux-only installer on Windows.
5. **Owner decision on D1/D2:** Approve current `.mjs` locator and exact per-gate changed-path manifest. Choose native build graph plus Windows gating (recommended) or the reusable workflow. Explicitly amend AC30/31 if selecting the native topology/current scope. A later A03 decision can reduce the necessary A16 path list.
6. **Owner decision on D3:** Approve the Windows .NET collector/common-tokenizer contract and truthful platform process lifecycle, or select another fully evidenced adapter. Freeze exact handle close/reopen/read-sharing/publication transitions and identity handoff before implementation. The contradictory original instructions cannot both be satisfied literally.
7. **Owner decision on D4:** Approve the complete role allocation and fixed collector operations. Freeze the explicit identity-transfer interface and bounds for workspace/list/schema/dry-run. Keep report/show/manifest/verification/source roles separate.
8. **Owner decision on D5:** Approve status precedence, append-only atomic splits, quoted-key whitespace interpretation, corrupt-source zero-size/source-retention correction, and phase-specific final-path postconditions. Allocate additional IDs for every unnamed family before Gate A; do not claim the 332-row floor is the finished catalog.
9. **Human gate authority:** Identify the accountable operator and independent peer for each actual gate. Obtain their approval only on the concrete implemented and tested immutable result. No agent score, plan approval, CI result, remote code review or general execution authorization substitutes for these assigned people. Gate B remains unstarted until Gate A is accepted.

## Validation and handoff limits

Read-only checks completed: pinned Git object/tree inspection; live issue/snapshot equality; complete comment read; discussion availability; source-command and helper/caller inventory; snapshot-to-appendix line reconciliation; 31 acceptance rows; 224 unique named-case rows; 108 independently specified signal combinations; current workflow/installer/native T2 signal inspection; primary API reference verification. Product tests, Windows experiments, Linux fixtures, generation and PR reviews were not run. The tables are test obligations, not fabricated test results.

Only this result file was created by this worker. No A00/A01 result has been accepted by this worker. Pending operation: none. Next action for the coordinator: accept/reconcile A00/A01, then review D1–D5's concrete contract choices with the owner and A03/A06/A07/A11 owners. A15 remains preparation with unresolved decisions; do not set A16 dependency-ready from this report alone.

## Coordinator verification

The coordinator reproduced D3's exclusive-handle conflict on the actual Windows host with PowerShell 7.6.5 and Node 24.18.1. A fresh empty temporary file was held through `.NET File.Open` with `FileAccess.ReadWrite` and `FileShare.None`. Node `fs.openSync(path, 'r+')` returned `EBUSY`. The retained handle was then closed and that exact scratch file removed. This confirms the conflicting open lifecycle. It does not validate a replacement collector, Windows PowerShell 5.1 parity, process-tree termination or any Terraform operation.

Before asking the owner to approve changed contracts, the coordinator must make D1's per-gate path list and D3/D4's identity handoff concrete against the accepted A03/A06/A07/A11 foundations. Candidate path families and an unresolved interface are not final approval requests. Routine fixes that preserve the original safety contract do not need an invented approval gate. A deliberate change to an explicit original contract or its real Gate A/B authority must remain explicit. The present result is retained preparation, with its test obligations intact.

## D07 concrete continuation of D1, D3 and D4

The [read-only continuation](design-continuation.md) and its linked path manifest/identity handoff make these existing recommendations concrete. They remain proposed scope, API and role amendments; no implementation, Windows feasibility, D5 resolution or real GateA/B approval is claimed. Reuse TF64 directly; superseded A11 and final A18 are not implementation predecessors.
