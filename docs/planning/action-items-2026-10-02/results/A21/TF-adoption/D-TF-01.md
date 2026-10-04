<!-- markdownlint-disable MD013 -->
# D-TF-01: retain bounded historical metadata input during capacity reduction

Decision prepared on 2026-10-04 before product repair. This is a new peer finding within A21. It does not reopen the complete-source selection or authorize concurrent PS edits.

## Validation

The actual unstaged coherent TF candidate at HEAD B=06ad4f7c9b6847028cafdacf1ae55128d0f2d56c invokes the complete accepted PS f168f83 validator. `pwsh -NoLogo -NoProfile -NonInteractive -File .github/workflows/Test-AgentInstructions.ps1` returns 1 with `HEAD:AGENTS.md must not exceed 32768 bytes.` The exact command, UTC time and log SHA256604d61e3147cb396e312b46c823784138b61372b10bcf3bb2f27cee390ff2c9b are in windows-content.json/log. Candidate AGENTS is32759 bytes; it passes the current reader before this failure. The actual baseline AGENTS is33422 bytes, regular100644, blob aa643a442d6a0c59c05d2aff8737564981147fc6. Its header is Version1.7.20261001.0/Last Updated2026-10-01 and cannot be discarded.

The accepted common code gives AGENTS one MaximumBytes=32768 in its document specification. The current input reads at7876/7884 and7965/7973 use that bound correctly. The metadata-parent loop also uses the same bound at7993 for explicit published B and8007 through Get-PublishedBaselineDocumentContext for local HEAD. The latter reads the real regular Git blob at2056. The historical TF reader allowed65536. This is a role-confusion defect: current instruction admission and inert prior metadata comparison have different historical inputs.

The executed witness is local proposed-code validation only. Static caller inspection establishes the same parent-read path for staged local/SelfTest, full explicit accepted B/H, ProposedPolicy H/B and first-landed L/B. FinalizeMetadataNow also takes that parent path after its existing accepted-checkout role guard. MetadataClassificationOnly returns earlier and never reads these document bodies. InputRevision without an explicit baseline uses the current content as parent and does not need a historical read. No staged, committed H/B or hosted result has yet been obtained.

## Stakeholders and options, before scoring

Maintainers and contributors need a valid shrinking change to be publishable without falsifying its history. Security and instruction owners need the32768 current-input cap,65536 configurations and16384 reserve unchanged. Documentation authors need the real prior header, version arithmetic and date rules. Reviewers need bounded regular strict-UTF8 data, exact B/H attribution and no proposed-policy authority claim. QA needs current versus historical bound tests plus real public caller evidence. Operators need one common implementation with no extra PR sequence, grandfather list or new initializer. UX concerns are a comprehensible capacity rule and no unexplained first-adoption failure. There is no deployment, credential, customer-data or infrastructure mutation.

| Option | Complete approach |
| --- | --- |
| N | Leave the failure and stop first adoption. |
| W | Increase current AGENTS admission to65536. |
| D | Skip, truncate or null the historical parent. |
| P | Add an exact TF B/path/blob grandfather exception with an exact33422-byte historical ceiling. |
| R | Separate historical AGENTS metadata reads from current instruction admission. Retain the previously supported65536 historical bound only for that exact path and only at the two metadata-parent call sites. Other document bounds remain unchanged. |
| U | Read every historical document with a larger generic finite one-MiB ceiling. |
| F | Land an additional old-engine-compatible shrink-only PR before this adoption, then redo affected source/baseline checks. |
| S | Build a streaming metadata-only extractor to avoid retaining the complete historical parent. |

R uses the existing bounded Git reader and metadata parser. A new public flag or caller-supplied limit is not required. P plus R is a continuing historical allowlist and inherits P's maintenance burden. D cannot preserve rendered-content and prior-header checks. F is a real alternative but requires additional intermediate protected prose compatible with the old five-command checker, a separate native lifecycle and a changed parent; it is not a no-edit solution. S must still preserve full-document comparison semantics, so a header-only truncation is D rather than S.

## Finding-specific rubric

Scores1–5; total=sum(weight*score)/5. Metadata and transition correctness30 covers the real complete parent, versions and all caller roles. Present-input safety25 covers unchanged admission and bounded non-executed history. Contributor usability20 covers an ordinary valid shrinking update without hidden prerequisites. Common maintainability15 covers one finite shared design without commit-specific permanent grants or parsing frameworks. Test discrimination10 covers actual role/bound/encoding/type negatives and reproducible caller evidence. Cost is subordinate to correctness; scores are design judgments.

Hard constraints: no current cap/configuration/reserve growth; no baseline-null substitution; no removed tests or initializer changes; preserve exact endpoint/accepted versus proposed roles; read historical data through the existing regular-file strict-UTF8 bounded path; no extra product path or native operation; retain a truthful reverse common-source repair obligation.

| Option | Correctness30 | Safety25 | Usability20 | Maintainability15 | Tests10 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 5 | 1 | 4 | 2 | 51 |
| W | 5 | 1 | 4 | 4 | 4 | 71 |
| D | 1 | 2 | 4 | 3 | 1 | 43 |
| P | 5 | 5 | 4 | 2 | 5 | 87 |
| R | 5 | 5 | 5 | 4 | 5 | 97 |
| U | 5 | 2 | 5 | 3 | 3 | 75 |
| F | 4 | 5 | 2 | 3 | 4 | 74 |
| S | 3 | 4 | 3 | 1 | 2 | 57 |

W and D violate hard constraints. R is the unique winner. R's65536 historical transport limit is the maximum supported pre-adoption AGENTS reader, not a new current-file allowance. It applies uniformly in both repositories. P is safe but encodes a permanent native-commit exception for a general valid transition; it unnecessarily rejects other accepted historical AGENTS of the same previously supported size. U enlarges unrelated inputs without need. R does not accept an invalid parent header or missing baseline, and cannot authorize a large new/current AGENTS.

## Selected controlled-English implementation

Use R. Keep the current AGENTS read limit at32768 bytes. Keep all other current limits and both configuration values unchanged. Use a separate65536-byte limit for the complete AGENTS parent used only by metadata comparison. Keep the existing limit for every other historical document. Select the historical limit from the exact ordinal path inside the common checker. Do not expose a public override.

Use the historical limit at both metadata-parent reads: local HEAD and explicit published B. Do not use it for candidate worktree, staged bytes, revision input, root policy validation, or same-input snapshot data. Keep regular-file mode, exact path, bounded process, strict decoding, real parent content and all metadata checks. Keep the early data-only return and all endpoint role guards.

Test a65536-byte regular historical AGENTS followed by a32768-or-smaller current document through actual local and explicit-parent paths. Reject a65537-byte historical parent. Reject32769-byte current inputs even when the parent is allowed. Test wrong path/case, nonregular parent and malformed UTF8. Prove real parent-version/date mistakes remain rejected. Exercise actual coherent local candidate validation on the real TF B after repair; root will later supply actual staged H/B and landed gates. Add durable regression controls to the existing SelfTest surface and run only focused controls here. Do not duplicate the full SelfTest or final aggregate.

Once this source is accepted in TF, later common accepted checkers retain the finite historical read bound, while every new candidate still has32768 admission. A future supported historical baseline above65536 fails closed and needs a separate decision; no open-ended compatibility promise is made. Carry the same common algorithm/test repair back to PS only through the later normal reverse transfer. No language-profile fork is selected.

No secondary style-guide change is required: existing documentation standards already require explicit limits and truthful source/role contracts. This is an executable reader-role repair. Validation/source hashes and final regression results will be recorded with handback. Product repair had not started when this decision was selected. The execution results below are separate evidence.

## Coordinator verification and current execution

The coordinator validated the original native33422-byte parent, complete proposal and original failure before repair, independently recomputed all eight totals, and displayed the options, rubric, score table and selected R97 instructions in the main chat before release at2026-10-04T13:44:09.875617Z. The one-MiB option is finite; unbounded reads are excluded. No new owner input was required.

The actual Windows local instruction check now passes after R97 and the three ADR navigation/header corrections. The focused Windows and Linux controls pass, and four deliberate mutations are detected. [Validation](validation.json) retains the original failures and successful commands, timings and log hashes. The first Linux extraction attempt failed because the image has no Python3; extraction with its existing Node runtime then passed. Complete frozen-candidate acceptance remains pending at this recording boundary. The complete aggregate, committed H/B checks, native reviews/landing and reverse PS repair remain required. Do not treat local success as accepted-policy or human authority.

The selected instructions use short direct sentences and explicit limits. No formal ASD-STE100 dictionary-certification claim is made.
