# PS reverse candidate independent quality — 2026-10-05

**Bounded PASS for the frozen 22-path source transfer and focused verification.** No unresolved material candidate defect was found. This permits root to proceed to staged preflight and the final-byte aggregate; it is not PS PR acceptance, paired convergence or permission to bypass native gates.

The reviewed destination remains accepted PS `f168f83b89f64b6bca9d520ddec4b58969060fb6`, tree `c82fa2e11bfe333b9bcaf732bf12d1d9cb907380`, on `codex/coherent-foundation-reverse`, with unstaged changes. Source is landed TF `56cb0418dcdcf71be94acc78d8963ea580b8a9e9`, tree `377d9980fdd4008e806366ca90b1ce2811c2f519`. The accepted source receipt is SHA-256 `0003dd7f852bf1854d29a8bb5dc4625af481b7142b627b1b21b799be79d68f36`.

| Frozen input | SHA-256 |
| --- | --- |
| Worker HANDOFF.md | 8e5427d52fa0ccd98720aaf5fd83ad4e6e0644d50af4f2a1aab0ee0255225b0f |
| final-catalog.json | da5fc57e81f754fa686357cfdf2dbff477ba9f5d77293db8c8a1305872a866ec |
| PS-reverse.patch | 37ca5dfdffb6a107b3fadb7a421d1ad8e3e2948dd649030fb5f51b646f35b125 |
| exact-pair-deltas.json | fa879e1a0cafed85e996d51f68bb66d8bcc63ce4202b8a57eee1e514a032df70 |
| final-source-guard.json | 4e556edca12f645180d0d4e42227665a04233b4e355543173e66f0ded05b65c0 |
| final-evidence.json | a974f641c004e31a3b2d47c953e9763338ec5314b7c8fb14afa492a27213e95e |

## Source, integration and authority

I inspected the full raw PS-base-to-candidate diff and all residual TF-to-PS differences, reusing the accepted TF source/security/test reviews for identical bodies. All 22 current postimage hashes and blob IDs match the final catalog; their PS preimages and accepted TF identities were checked against immutable Git objects. Twelve files are byte-identical to TF. Ten retain explicit PS repository identity, native artifact behavior, P1 fixture, documentation and metadata differences. Provisional and final candidate bytes are identical; the catalog schema gained accepted-TF records.

The entire validator engine matches accepted TF except three `.NOTES` values; the entire extracted SelfTest matches except three `.NOTES` values and the exact T1-to-P1 fixture substitution. The real PS baseline document exists at accepted B and remains read through real Git. No partial engine hybrid, retired exact-profile admission, TF-only recovery child, future B99/R5/B1/YAML policy, generated artifact or ADR history edit was introduced.

The retained PS artifact/blank-line test block is unchanged relative to PS B. Its actual semantic child remains `.github/workflows/Test-BlankLineExamples.ps1`, reached by Test-StyleGuideArtifacts.ps1:540; the native build job remains `verify_generated_artifacts`. The actual instruction workflow:210 retains five original Node suites and adds both new suites with the immediate native exit guard. The setup change removes only redundant event-filter literals already covered by retained globs. Its acquisition roles, PS authority strings, permissions, credential handling and finite phase limits remain intact.

The common native-entry, standalone preflight, bounded manifest/child admission, JSONC diagnostics, single-invocation configuration and staged status contracts carry over without API changes. R97 changes the historical exact-case AGENTS parent allowance only; current 32,768-byte AGENTS, 65,536-byte config and 16,384-byte reserve controls remain distinct. R22 retains actual parser coordinates, canonical Status-only exemption, legacy transition behavior and nonoperative-example boundaries. Static admission is not a TOCTOU or hostile-runner sandbox guarantee, and accepted-base classification is not owner authorization.

Scope is the released handoff/mapping and existing protected-entry-point grant, including runtime-pointer and actual metadata finalization. AGENTS/CLAUDE preserve other PS protocol bytes. Sizes are 32,654 / 83,316 / 2,517 bytes for AGENTS / CLAUDE / unchanged repository Copilot instructions. Existing documentation, YAML and PowerShell rules already cover these changes; no additional style-guide rule is warranted. Prior full documentation/YAML guide assessment is reused with the complete current-guide differences inspected; the operative YAML body is unchanged, and documentation differences retain PS-specific identity/history.

## Metadata and remaining carry-back

`STYLE_GUIDE.md:1025` defines previously published as the destination's published version, not intermediate work. Lines 1037–1038 require genuine modification date and revision zero for a new date tuple, otherwise the next same-day published revision. The six changed documents are finalized to October 5. AGENTS `1.7.20261005.0`, CLAUDE `1.10.20261005.0`, main script `1.18.20261005.0` and SelfTest `1.8.20261005.0` correctly use `.0` relative to their October 3 PS bases. Root explicitly selected the accepted Get-DocumentMetadataContext minor transition to `1.7`; other major/minor tuples remain preserved.

Get-PublishedBaselineDocumentContext:2118–2122 genuinely changes the parent-read delegation from Read-GitRevisionText to Read-PublishedBaselineDocumentText. Its note at2087 must therefore become `1.0.20261005.0`; retaining accepted TF's September 14 note would not satisfy the PS modification-date rule. This is a required shared metadata carry-back obligation, not justification to copy stale source metadata.

All six remaining shared note differences are explicit below. Exact PS/B/TF tuples and coordinates are in metadata-tuples.json.

| File / note | Accepted TF date | PS candidate date |
| --- | --- | --- |
| Test-AgentInstructions.ps1:454 — Get-AgentSetupPackageFailure | October 4 | October 5 |
| Test-AgentInstructions.ps1:2033 — Read-PublishedBaselineDocumentText | October 4 | October 5 |
| Test-AgentInstructions.ps1:2087 — Get-PublishedBaselineDocumentContext | September 14 | October 5 |
| Test-AgentInstructions.SelfTest.ps1:36 — script | October 4 | October 5 |
| Test-AgentInstructions.SelfTest.ps1:2297 — Assert-PublishedBaselineCapacitySelfTest | October 4 | October 5 |
| Test-AgentInstructions.SelfTest.ps1:2500 — Assert-AgentSetupSelfTest | October 4 | October 5 |

Later TF work must reconcile these notes, enclosing script metadata and actual destination baseline/date/revision under the same rules. It must not mechanically reuse PS tuples if the then-current TF baseline requires a same-day increment or a later date. This report does not assert raw metadata convergence. The candidate has no commit author date yet; root must bind genuine finalization to actual staged/committed inputs and author-date requirements. Ordinary content/proposed checks do not replace that proof.

## Focused evidence and limits

All handoff artifact hashes and every referenced focused log hash were independently verified. The complete 76-file candidate and all 1,910 retained dependencies match the Linux input tar; the private Windows runtime matches all candidate files. Product dependencies and all out-of-scope tracked bytes remain unchanged. Index entries match the preimage guard, cached diff is empty, and HEAD remains PS B.

Windows pinned Node24.18.1 evidence: Markdown/local 50 pass and 6 Linux-only skips; npm/audit 42 pass, zero skips; workflow selection 2 pass and 20 Linux-only skips. Linux exact cached image evidence: 56/56, 42/42 and 22/22 respectively, zero skips. Both actual policy CLI invocations pass. The Linux selection executes all eight preserved PS artifact/blank-line cases and actual workflow hook/failure branches, not merely text-presence assertions. New local-validation controls preserve staged-byte and reached-outer oracles; helper fixtures remain bounded substitutes for full setup execution. Accepted TF original-versus-repair discriminator evidence is reused only where the exact source/tests are unchanged.

On both platforms, retained/new lifecycle and actual parent-capacity controls passed before a scratch harness omitted the placement function's mandatory date. Separate corrected remainder runs pass actual metadata placement (including P1 Git reads) and complete setup mutations. The earlier mandatory SelfTest extraction failure and ambient Windows Node26/npm11.19 prerequisite failures remain failed historical fixture records, not relabeled clean runs. The actual dirty PS content validator passed. Both modified scripts parse; seven changed/new helper definitions have zero PSScriptAnalyzer warnings/errors. This is not a new whole-file analyzer or full SelfTest/aggregate claim.

Root still owns staged-input preflight, one final-byte full aggregate before normal commit, actual accepted-B/new-H diagnostics, fresh ordinary audit, current-head hosted/reviewer lifecycle, independent final native quality, landed-main verification and all remaining pair/A18 obligations. No reviewer suites, installs or native actions were performed.

## Review-method deviation

I mistakenly issued `git write-tree` once while inspecting the unstaged index. It returned the existing accepted-B tree `c82fa2e11bfe333b9bcaf732bf12d1d9cb907380`; I disclosed this immediately to root. That command can write Git objects/cache metadata and exceeded the read-only method restriction. Subsequent independent checks confirm unchanged product bytes, refs and staged entries; I make no claim that the raw index cache or object store was untouched. Subsequent Git inspection used read-only commands. Only private review artifacts were intentionally authored.
