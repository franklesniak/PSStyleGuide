<!-- markdownlint-disable MD013 -->
# A02 preparation and proposed changes

**Current checkpoint:** Owner-directed planning corrections landed in `e60425f9d7cf0799abeb806dd53c2afe939fd304`; subsequent preparation and execution checkpoints are published. PR224's earlier round2 was clean on d9b9e1c. The fixture-only Linux diagnostic repair f81f769 passed local validation and native candidate CI37023858676.

Round3 is terminal on f81f769: Copilot review5393527247 explicitly reports Balanced and no findings; Codex review5393521315/comment4167109675 identified optional-header coverage F5. The [canonical decision and final validation](review-F5-decision.md) implement the two-file repair, including malformed intent before the title and ordinary title-only negatives. Two intermediate runs were interrupted for actual detector corrections and are not accepted results.

F6 product commit `b8976a4b4c42d2c888051bbef015c45ba3daeac9`, tree `5406a2e77ed9d8d8230e24fd978c0f5d1ef15488`, was published and reviewed. The [canonical F6 decision](review-F6-decision.md) fixes the readiness-triggered review5394588826/comment4168004991 category-transition defect and its ordinal-path sibling. Its18 parsed transitions, actual admission caller, generated-to-Tier2 current/prior-header controls, and one complete normal ten-hook pre-commit passed. Actual proposed-code B48f4d8a/Hb8976a4 finalization and classification passed without changing the accepted-base fixture. [Independent local quality](F6-quality.md) approves the actual commit and reconciles the saved evidence.

Round4's manual pair and CI were clean on519c420 before the supplemental automatic F6 finding; they are historical evidence. Round5 is terminal onb8976a4: authenticated Copilot5395257580 explicitly reports Balanced/Findings None with low advisory F9 about CONTRIBUTING diagnostics; Codex5395264907 reports F7 case-variant Version labels (4168569572) and F8 mixed-case Markdown extensions (4168569590). Candidate CI37044873509/job110963697032 passed at that input. Both old-input requests are terminal and two threads remain open.

Normal repair commit `8b6c1da46b568cb3b44e60fc511a03ac1fc4edf0`, tree `6223b82bced692b5eb32e31bcbc5fd11447015f8`, implements the [F7 Version-label](review-F7-decision.md), [F8 Markdown-suffix](review-F8-decision.md), and [F9 command-diagnostic](review-F9-decision.md) decisions in three files. Focused helper, actual private B/H content/admission and six extracted guide-command checks passed. Replacement aggregate72653 passed all ten normal hooks on final bytes; the normal commit hook passed. Actual proposed-code B48f/H8b6c1da finalization and classification both passed. The fixture-expression and separate-script-scope failures remain documented and are not credited. [Independent whole-PR quality](F7-F9-quality.md) approves the actual commit across all eleven changed paths and reconciles final local evidence.

The normal non-force product push and fresh remote-ref/PR readback confirm8b6c1da; initial readback lagged and no push was repeated. Planning `1e3f63a63557f8750b8041227c45232d15ee1814` publishes the decisions and quality record. The exact updated PR body has SHA256 `9527bd5a43e265a31f0a6f61e4bf30297e59d2b9d6b74ebf412d1f474d853658`. One bounded reply per finding was posted (F7 4169246017; F8 4169257264) and read back before resolving both threads; all eight then-existing threads were resolved. F9 is explained in the body and has no inline thread.

Round6 is terminal on this exact head/body after complete paginated baselines. Fresh signed-out UI inspection showed disabled Balanced/Lite controls; the documented CLI fallback produced authenticated Copilot request32361467681 at19:53:46Z. One authenticated Codex trigger5960318125 followed at19:54:29Z. Copilot5396228239 explicitly reports Balanced and Findings None at19:59:45Z; its generic trust-root scrutiny note is retained for final whole-PR reconciliation. Codex5396252708/comment4169355897 identifies F10 at20:02:12Z: a later peer H2 Metadata section escapes optional intent detection, including prior-header retention. Independent source review and the worker's helper reproduction confirm the gap; nested H3 examples remain a distinct negative case. The worker owns the bounded validator/SelfTest repair; final validation and native acceptance remain pending.

F10's actual private B/H reproduction also confirms the bypass. Its [canonical decision](review-F10-decision.md) selects D98 before edits: recognize reserved peer H2 Metadata anywhere in parsed top-level body blocks while retaining other header windows and example exclusions. The parent checked all eight weighted totals and the three immutable policy/validator/SelfTest identities. Only the validator and SelfTest are changed. Focused89490 passed helper controls and four actual B/H cases: retained-Tier2 and optional-catalog placement rejection, malformed real prior rejection, and nested H3 example acceptance. PSScriptAnalyzer Error checks and diff checks pass.

Normal F10 commit `b9c2d0ea4c04894a6ea3267e9daa662f27b5820b`, parent8b6c1da, contains exact frozen tree `ed2bd7cf9e28ffc363bfd0dd7ac95e6ee63cf770` and only the two assigned100644 changes. Worker-owned aggregate15981 passed all ten hooks at21:01:38.8759123Z after its20:24:14Z start. The worker released ownership after final hash/mode/clean-diff readback; the parent committed normally. Root-owned61184 passed actual proposed-code B48f/Hb9c finalization and classification at21:04:20Z, preserving accepted-base fixture HEAD and exact staged tree. [Independent whole-PR quality](F10-quality.md) approves the actual commit and final local evidence, reusing earlier source evidence only for exact unchanged bytes/callers. Normal non-force push and fresh native ref/PR readback confirm b9c2d0e; initial readback lagged and no push was repeated. Fresh remote reviews/current CI remain pending; F10's thread is not yet resolved and no new-head remote acceptance is claimed.

Native candidate CI37055910803/job111000448194 passed all six steps at19:55:22Z on8b6c1da. Saved round6-progress-2 and round6-terminal-gate evidence authenticate that completed pair and its F10 finding; those prior-input results do not establish new-head acceptance.

Planning `4a3b9c444bc2996c856e9a4a7dda14f65359bb80` publishes the F10 decision/quality. The updated PR body read back exactly with SHA256 `c00474812b7daef8dc0670979fdaae882af4e57c1b7a5176ad90e71c0e0848e5`. Bounded F10 reply4169876258 was authenticated and its thread resolved; all nine then-existing threads were resolved. Round7 baselines include complete request events, requested reviewers, reviews, comments and current-head workflow/check runs. Fresh signed-out browser controls had Balanced/Lite disabled, so one documented CLI request produced authenticated Copilot event32366169805 at21:15:26Z. One authenticated Codex trigger5961606939 followed at21:16:05Z. Copilot5396978743 at21:22:16Z explicitly reports Balanced and Findings None; its general test-execution caveat is retained for final reconciliation. Current candidate CI37064769395/job111029740777 passed all six steps at21:25:13Z.

Round7 is terminal: Codex5397018839 at21:27:31Z reports F11 case-variant duplicate reserved metadata fields (comment4169978567) and F12 non-ASCII document paths rejected by a non-NUL Git tree reader (4169978573). Summary5947364790 completed the exact-head manual review at21:27:34.613483Z. Independent source inspection confirms both current-consumer gaps; actual reproduction and separate canonical decisions are assigned to the sole validator/SelfTest writer before edits. Saved terminal snapshot/gate show eleven threads, nine resolved. No issued request remains pending, no duplicate request or merge occurred, and no F11/F12 implementation acceptance is claimed. Round7/80, original October10 deadline and transfers0/12 persist; A07/A21 release remains held. Proposed-code checks do not establish already installed native-main or owner authority.

F11/F12 reproduction and separate pre-edit decisions are now complete in scratch `F11-F12`. The actual parser accepts case-variant duplicates for all four reserved fields and two whitespace siblings; the actual Git inventory preserves `docs/café.md` while its regular-file reader falsely rejects the quoted tree display. Select D98: recognize reserved case/whitespace variants within the operative list, then retain exact raw syntax/uniqueness validation. Select Z98: use literal-path NUL tree records through existing bounded transport, require one exact100644 blob/path/object, then read the inspected object. The parent recalculated all sixteen totals and checked immutable policy/validator/SelfTest blobs. D07 independently agrees from source inspection. The sole writer has implemented validator changes and is adding affected helper/native/current-prior tests; no frozen final candidate or repair acceptance is claimed. Protected text, workflows, schemas and public modes remain outside this repair.

F11/F12 focused session74098 exited0. Native UTF-8/space/literal-path reads, mode/type/missing-input/content checks, controlled bounded tree-record framing/identity/native-exit/overflow/timeout controls, metadata uniqueness/syntax/context controls, and actual current/prior/Unicode-path B/H caller cases passed. The first focused attempt exposed only a test-fixture empty-byte-array enumeration error; its correction and failed log are retained without credit. Frozen tree `4dba7b2766ba49233e7dd0871188255c0870ae7c` onb9c2d0e has exactly the two assigned100644 files and no unstaged edits. Validator blob8348d075ea3110f5c2e825e28dcd609b2c4e5cfa/SHA25641746bb66414f5ae06b2e1c81c866cb0e80af4ead312f3c6a2271fb7eb0e37a2; SelfTest blob439e85797a92db2d1be555d88376e44ce538595e/SHA25699332a6eca9f4b7ad96bc0f51772f1a22ea51ecab377b3507f9ebdd5090ca8e0. Parent verified frozen index/tree/raw bytes. One normal worker-owned aggregate95367 began21:50:51.9246761Z; D07 independently reviews whole-PR source/saved evidence in parallel. Aggregate, final quality, normal commit, exact committed endpoints and native acceptance remain pending; no new request or counter change.

The [F11 reserved-field decision](review-F11-decision.md), [F12 raw Git-record decision](review-F12-decision.md), and [independent whole-PR source quality](F11-F12-quality.md) are integrated locally. D07 independently verified exact frozen identities, relevant tests, security and paired implications across the eleven-path PR; no concrete blocker was found. Quality remains conditional on the final aggregate, actual commit/endpoints and native gates. Aggregate95367 has passed its first nine hooks; the final instruction suite is still running. No duplicate suite or native request was started.

Normal F11/F12 commit `25b17e892f6429cf4df4f39489443d950f5902e8`, parentb9c2d0e, contains exact frozen tree `4dba7b2766ba49233e7dd0871188255c0870ae7c` with only the two assigned100644 changes. Aggregate95367 passed all ten hooks, exit0 at22:30:33.3579863Z after its21:50:51Z start. The worker verified unchanged bytes/modes/index, no unstaged changes and diffcheck before explicitly releasing ownership; the parent committed normally. Root-owned48783 passed actual proposed-code B48f/H25b finalization and classification at22:33:44/47Z, preserving the accepted-base fixture HEAD and exact staged candidate tree. D07 reconciled [whole-PR local quality](F11-F12-quality.md) to the actual commit and terminal local evidence. Normal non-force push and fresh remote-ref/PR readback confirm25b17e8; the first PR readback lagged and no push was repeated. Planningaf5298d publishes the initial F11/F12 decisions/conditional quality; their final local reconciliation is now integrated. Body, bounded replies/resolution, complete baselines and round8 requests remain next. No current-head remote acceptance or merge is claimed; round7/80, original deadline and transfers0/12 persist.

Planning `676bb8b4cd33c094eae864de0600e287b2391752` publishes final F11/F12 decisions and reconciled local quality. The updated PR body read back exactly with SHA256 `6d80e56d85c1f95467cfd45edb0caf4e18e37b46af4f561fb783510a994e7afd`. Bounded replies F11 4170432206 and F12 4170432624 were authenticated before resolving their threads; fresh complete gate evidence shows all eleven threads resolved. Round8 baselines include all seven required paginated surfaces and distinguish the two author-generated reply reviews from bot acceptance. Fresh signed-out Edge controls again showed disabled Balanced/Lite and no request control; no UI request was sent. One documented CLI fallback produced authenticated Copilot request32370528244 at22:47:34Z. One authenticated Codex trigger5962683747 followed at22:48:29Z. Both current-input results, observed Copilot effort and current candidate CI remain pending. No write is ambiguous or pending, no request was repeated, and no merge occurred. Round8/80 retains the original first-request/deadline and transfers0/12.

Round8 Copilot5397611726 completed on exact25b17e8 at22:53:27Z, explicitly Balanced and Findings None, with no inline findings. Its general final-verification caveat reflects that review environment's inability to execute the suite; actual local full validation passed, and no new owner-attestation gate is inferred. Workflow37074368601 is completed/success. Authenticated Codex summary5947364790 reports the current manual review running since22:48:45.939810Z on25b17e8. Candidate CI37073297274/job111057479810 remains in progress in its proposed-behavior step after four successful setup/acquisition/credential/dependency steps; counterpart111057480584 is intentionally skipped. Saved progress-1/2/3 snapshots and candidate-jobs-1 retain these distinct live/terminal results. No second request or merge.

Round8 is terminal on25b17e8. Authenticated Codex5397627845 at22:55:28Z reports F13 missing push before/after comparison (4170495474), F14 spaced emphasized optional Owner/Scope intent (4170495483), and F15 nonregular generated-entry admission (4170495487). Summary5947364790 completed the exact-head manual review at22:55:31.363255Z. Candidate CI37073297274/job111057479810 passed all six steps at22:55:51Z; the Copilot result above remains Balanced/Findings None. Complete terminal snapshot/gate show fourteen threads, eleven resolved, open/ready/unmerged. Both issued requests are terminal; round8/80, the original October10 deadline and transfers0/12 persist.

Independent source review and actual production reproduction confirm all three findings. Installed B/H rejects unauthorized exemption expansion while H/H admits it. Spaced emphasized Owner/Scope alone escapes intent detection although strict parsing rejects it. Prior-authorized generated activation admits modes120000/160000/100755 as well as100644; this proves missing entry admission checks, not target traversal. Separate pre-edit F14/F15 decisions select S98/M98; the parent recalculated all fifteen weighted totals. The sole writer is implementing those validator/SelfTest repairs. F13 remains design-only while reconciling actual push endpoints, checkout-at-B requirements, the existing closed first-install boundary and the missing new modes at native B48f. No guaranteed first-install failure, fallback self-comparison, immutable enforcement or owner authority is silently accepted. Final freeze, aggregate, independent quality and fresh native acceptance remain pending; no merge or A07/A21 release.

The [F13 push-transition decision](review-F13-decision.md) now selects P97: add an explicit proposed-policy full endpoint mode in the existing candidate job, require checkout H and exact distinct event B/H, and retain accepted mode at B. The existing closed initializer handles the known first installation without executing unsupported old-B code or claiming new authority. Manual dispatch remains snapshot-only. D07 independently found no actionable decision gap; root checked all eight totals and the current immutable policy/validator/SelfTest identities. The [F14 optional-marker](review-F14-decision.md) and [F15 generated-entry](review-F15-decision.md) selections are also integrated. All four repair paths are within the existing eleven-path PR scope and do not overlap frozen A07 work. Implementation and focused validation are active; no frozen candidate or final acceptance is claimed.

F13–F15 focused validation is terminal and passed: classification34915, main63455, backward-date83819, extracted workflow11579 (9/9), final raw-reader39612 and native-initial-proposed43181 all exited0. The native-initial probe used exact B48f and private H42af5892/treeb5f2801, explicitly proposed-code full validation with no finalization-date or authority claim. Provisional code tree0cde16e0dc69df235b98f6e739fa112bf7c1e3eb on25b17e8 has four staged100644 paths and no unstaged changes; root verified every raw hash/blob/mode. D07 whole-PR source/saved-evidence quality is active. Code remains frozen. The current D14 procedure requires actual committed H finalization after the full pre-commit required before every commit. To avoid a known midnight-invalidated run, the worker will refresh only the two existing Last Updated lines in MARKDOWN-LINTING-IMPLEMENTATION.md and ISSUE_EVALUATION_PROMPT.md once UTC October3 actually arrives, then freeze six paths and run one final-byte aggregate. No future date, clock override or gate reordering is allowed. No aggregate, normal product commit, native request or merge has occurred.

D07 completed [independent whole-PR source quality](F13-F15-quality.md) on exact provisional tree0cde16e0 and found no concrete blocker. Source note SHA256893b1505ad18d05a720ec2bba170efc668f9bb283286de2c3619af3d3f217d9b; the parent verified it before formatting/link integration. All eleven PR paths, four changed code identities, relevant saved focused evidence, security and paired implications were reviewed. This remains conditional on the narrow actual-date/tree reconciliation, final aggregate, actual commit/endpoints and native gates. Fresh connector metadata and Git remote refs still show PR224 open/ready/unmerged at25b17e8/base48f4d8a; planningc0c426f is published. No product/native mutation or counter change.

[Four-path peer preparation](peer-preparation.md) remains read-only with independently checked raw inputs/hashes/scores. Its separate patches retain the A21 finalization dependency and unselected wording/navigation proposals. Source merge and actual input refresh precede TF implementation. Historical preparation below retains its input-specific scope; D07's split and touched-file metadata rule supersede earlier ownership/preservation statements.

## Inputs and coverage

PS native main is `48f4d8a36c8faceee12afac78aaecea0d176125d`, tree `640ee4c0974fb604b2ebf0a1e1e1a328bd213ddc`. TF native main is `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`, tree `dc8f6b82588b8f874d34cd5d0155791aea5793f1`. [owned-paths.json](owned-paths.json) records all 19 A02 paths, Git modes/blobs, sizes, raw SHA-256, and raw clause-level diffs. There are four equal files, fourteen different files, and one TF-only file. The coordinator independently verified all37 existing raw Git objects and modes. Analysis scripts and source snapshots remain local scratch; native Git objects are the authoritative source.

Read STATUS first, then README, LOOP-POLICY, ROUTING-AND-PARALLELISM, A02, DECISION-PROCESS, original contracts 1–9 and the shared governance/catalog contract in 19–40. Apply the accepted [A00 disposition ledger](../A00/dispositions.json), [research PR78 matrix](../A00/research-pr78-matrix.json), and retirement decisions R01–R07. Do not replay their historical lifecycle or treat old review thresholds as current. Research PR78 remains a fixed read-only source. The present supported platform protocols survive in both native agent entry points.

The original metadata preservation boundary remains in force. No docs-policy clause is proposed for deletion. No uncertain or template-derived semantic is weakened. The live docs policies already contain the Tier 1 header exception, published-baseline/finalization synchronization, one ADR lifecycle Status, repository URL safety, and unresolved normative placeholder prohibition. The YAML policies have identical content except Version and Last Updated. Fetching moving template policy is unnecessary for this no-deletion proposal. If later evidence suggests a deletion, complete the original clause-provenance proof first.

## D-A02-01: Preserve already-converged metadata and YAML rules

**Validate.** The docs-policy diff has only language/repository references and historical Version/Last Updated; the YAML diff has only those historical metadata values. All substantive policy clauses compare equal. An arbitrary metadata bump could falsely describe a new policy change and trigger needless validator work. This does not establish current validator behavioral acceptance; that remains required below.

**Stakeholders.** Documentation authors/readers, both maintainers, agent operators, metadata/parser maintainers, security reviewers, history custodians, and cost/schedule owners need truthful policy and preserved controls. No cloud operation, data processing, user translation, or accessibility change occurs; their absence cannot change this no-content-change decision.

**Options.** A: retain the proved equal common clauses and exact repository facts/history. B: overwrite both files to identical bytes. C: remove metadata/ADR/placeholder clauses. D: add a new metadata receipt/validator ownership policy. A later necessary YAML rule is A05, not a reason to alter this finding.

**New rubric.** Rule preservation 40%, factual truth 30%, reader usefulness 20%, maintenance burden 10%. Score 1 is poor; 5 is strong. Hard constraints: no uncertain/template-derived deletion; no false repository URL or language; no fabricated policy update. Scores are judgments, not measured evidence.

| Option | Preservation | Truth | Usefulness | Burden | Total /100 | Uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| A | 5 | 5 | 5 | 5 | 100 | Validator acceptance still needs tests |
| B | 3 | 1 | 3 | 2 | 46 | Incorrect repository facts; fails constraints |
| C | 1 | 2 | 1 | 5 | 34 | Removes useful safeguards; fails constraints |
| D | 5 | 4 | 2 | 1 | 74 | No new consumer demonstrated |

Total = `(40*Preservation + 30*Truth + 20*Usefulness + 10*Burden)/5`.

**Selection.** Use A. Keep all current policy clauses. Keep each repository's real language and URL. Preserve the previous update dates when no policy content changes. Do not change these two protected files for byte alignment. Reopen this decision when A05 changes the YAML contract or another finding proves a policy defect.

## D-A02-02: Correct the generated-artifact authoring contract

**Validate.** PS canonical repository Copilot instructions omit the generated-file warning. TF has the warning but says CI rebuilds files automatically when sources change. Both current build workflows check source/output identity and publish committed outputs; neither commits regenerated output. CONTRIBUTING and README already explain contributor-owned generation. The conflicting canonical instructions can cause an agent to leave stale outputs.

**Stakeholders.** Source authors, generated-file consumers, coding agents and their operators, both maintainers, artifact/CI engineers, security reviewers responsible for read-only publication, new contributors, and reviewers need an accurate action. No license, deployment, recovery, or private-data flow changes.

**Options.** A: leave both texts. B: copy TF's warning verbatim. C: use a common warning with the exact scoped output filename and contributor generation command. D: restore automatic CI writing. C includes a pointer to contributor guidance without creating a new generation mechanism; D is already rejected under R06.

**New rubric.** Operational correctness 45%, source/output integrity 30%, contributor usability 15%, maintenance burden 10%. Hard constraints: preserve the normative/rationale split and no-cross-reference rule; no automatic writer; list each actual generated output.

| Option | Correctness | Integrity | Usability | Burden | Total /100 | Uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 3 | 2 | 5 | 43 | Agents receive contradictory instructions |
| B | 2 | 3 | 3 | 4 | 53 | Stale automatic-regeneration claim |
| C | 5 | 5 | 5 | 4 | 98 | A06 must separately prove generation behavior |
| D | 3 | 2 | 3 | 1 | 50 | Retired writer; no current consumer |

Total = `(45*Correctness + 30*Integrity + 15*Usability + 10*Burden)/5`.

**Selection.** Use C. Do not hand-edit generated files. Run the generator after either source changes. Review and commit changed outputs in the same PR. State that CI checks generation and uploads committed files. Keep the real scoped instruction filename. The proposed protected patch preserves all seven existing authoring rules.

## D-A02-03: Reuse compact execution guidance without reducing authority or platform protocols

**Validate.** TF AGENTS and CLAUDE have useful compact evidence guidance and safer outgoing-range inspection. PS still requires a separate development-branch per-round ledger and public placement receipt. Native Git history, one active pending-request record, authenticated readback, and final validation retain the useful properties. TF's condensed protected-file definition is weaker to read than PS's complete terms. Broad statements that an active task authorizes R1/R2 must remain subordinate to actual task scope and protected-file authority. CLAUDE also says loop placement can qualify a harness branch restriction. Narrow that claim to actual task branch/path scope and preserve higher-priority directions. The current plan requires native request attribution and finite counters; a prohibition on duplicate ledgers must not erase them.

**Stakeholders.** Agent operators, both maintainers, local implementers, remote and independent reviewers, GitHub integration engineers, security/permission owners, incident investigators, new contributors, and cost/schedule owners. Codex and Claude platform maintainers need their different protocols preserved. No unrelated end-user/cloud flow is modified.

**Options.** A: retain drift and duplicate receipts. B: copy all TF text, including unsupported PS toolchain commands. C: selectively reuse TF's compact execution and placement improvements, retain complete explicit protected-file terms and native pending-request evidence, and preserve each platform protocol. D: delete both long platform protocols. A shared cross-repository package is excluded by self-containment. C can copy equal shared clauses without changing platform instructions.

**New rubric.** Scoped authority 35%, protocol/evidence preservation 35%, operational clarity 20%, maintenance burden 10%. Hard constraints: preserve protected-file explicit permission; retain Codex plugin/review protocol and Claude execution/review protocol; no force/bypass; no unimplemented dependency command; keep request attribution and counters.

| Option | Authority | Preservation | Clarity | Burden | Total /100 | Uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| A | 5 | 4 | 2 | 2 | 75 | Duplicated records can contradict one another |
| B | 3 | 4 | 3 | 4 | 69 | PS lacks requirements-dev.txt; fails constraint |
| C | 5 | 5 | 5 | 4 | 98 | Product instruction validation still required |
| D | 2 | 1 | 2 | 5 | 39 | Deletes required protocols; fails constraint |

Total = `(35*Authority + 35*Preservation + 20*Clarity + 10*Burden)/5`.

**Selection.** Use C. Keep one active task record. Retain the native request baselines, input identities, clocks, counters, and terminal results that the active policy requires. Reuse a result only while its inputs remain unchanged. Inspect the outgoing range and exact tree before a non-force push. Read the affected native object back once. Do not require a duplicate public placement receipt. Keep actual scoped authority. Keep every protected-file term. Keep each agent platform's protocol. Do not add PS commands that require A07 files before those files exist.

The proposal uses an identical truthful toolchain summary in both agent entry points. It names the existing common PS7/Python3.12 requirements, exact Node/npm configuration, NpmTools install, module-form pre-commit, Markdown commands, agent tests, active hook list, workflow-policy command, and artifact drift check. It delegates detailed installation and runner pinning to each existing dependency-maintenance document. It never names absent PS requirements-dev.txt. A07 owns convergence of those detailed installation documents and code; it is not an A02 predecessor. Reopen this A02 summary only if A07 changes its referenced commands or requirements.

## D-A02-04: Converge metadata classification with its live consumer

**Validate.** TF's `.github/document-metadata-classification.json` has a live consumer in Test-AgentInstructions.ps1. It classifies every tracked `.md`/`.mdc` outside the known governed catalog, defaults unclassified files to Tier 1, reads bounded strict JSON, rejects unknown/duplicate keys and unsafe/untracked/duplicate paths, and compares active exemptions against a trusted published baseline. A candidate-only authorization does not activate an exemption. PS validates its known document specs but has no equivalent classification/discovery consumer. Deleting the TF file would lose tracked-document coverage. Adding only JSON to PS would create an inert file.

**Stakeholders.** Both maintainers, new documentation authors, metadata/parser/CI engineers, reviewer and security owners of candidate-as-data validation, users of generated outputs, audit custodians, and agent operators. Content-first Tier 1/Tier 2 classification and minimal routine paperwork matter to authors. No personal-data or cloud execution change occurs.

**Options.** A: retain asymmetric coverage. B: copy only the JSON. C: reuse the bounded TF parser/discovery/baseline consumer and its security fixtures in PS, with exact scoped output configuration and no unrelated parser changes. D: remove the sidecar and hardcode only today's paths in both repositories. E: invent a general classification framework. Replacing the trusted-baseline guarantee with a candidate self-exemption fails a hard constraint. Reusing native Git inventory belongs to C.

**New rubric.** Complete coverage 35%, exemption safety 35%, author usability 20%, implementation/maintenance burden 10%. Hard constraints: preserve content classification; never permit candidate self-authorization; bounded data-only parsing; no executable policy from the candidate; no inert copied file.

| Option | Coverage | Safety | Usability | Burden | Total /100 | Uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| A | 2 | 3 | 4 | 5 | 61 | New PS governed paths can escape discovery |
| B | 2 | 2 | 2 | 4 | 44 | No consumer; fails constraint |
| C | 5 | 5 | 4 | 3 | 92 | Narrow port must retain PS caller assumptions |
| D | 2 | 3 | 3 | 4 | 55 | Future tracked paths lose classification coverage |
| E | 5 | 4 | 2 | 1 | 73 | New framework has no demonstrated need |

Total = `(35*Coverage + 35*Safety + 20*Usability + 10*Burden)/5`.

**Selection.** Use C. Read classification as bounded inert data. Inventory tracked Markdown and Cursor Markdown paths. Preserve the known governed catalog. Validate each remaining path unless an exact reviewed classification applies. Reject malformed or unsafe classification data. Compare exemption expansion against the trusted published baseline. A candidate authorization remains inert. Do not port unrelated generator, path, or parser architecture.

The coordinator granted A02 sole narrow ownership of the consumer/schema/fixtures, `arrPlacementProseLiterals`, the effective-ignore guard, the metadata data path in the maintenance classifier and its table-only regression. D-A02-09 separately owns only the two parser-output JSON boundaries and required helper/regression. D-A02-10 owns the bounded newly discovered metadata bootstrap. The narrowly assigned `docs/dependency-maintenance.md` edit inserts Metadata and synchronizes Last Updated; A07 retains its substantive content. This resolves the A02→A06 and A02→A07 cycles. The product's placement literals remain native until protected authority arrives; no `arrSharedProseLiterals` change is implemented.

Exact integration regions: `Get-DocumentMetadataClassificationContext`, `Get-DocumentMetadataClassificationExpansionFailure`, `Get-DiscoveredGovernedMarkdownDocumentPath`; repository-validation manifest path/read; current and trusted-baseline classification acquisition through existing safe Git readers; appending discovered document specs to the existing governed catalog; metadata classification self-test cases. Inspect TF's existing byte limits and acquisition calls before selecting insertion anchors. Do not replace PS's entire validator with TF's file. Keep PS's `.github/copilot-instructions.md` internal `RequiresMetadata = $false` mapping. Keep published-endpoint metadata evaluation and all current parser/security guards.

The proposed manifest substitutes only `powershell.instructions.md` for `terraform.instructions.md`. `authorizedExemptionPaths` remains empty. Both manifests' exact generated filename difference is required by the real outputs. The consumer patch must be prepared and validated before publishing the manifest; the proposal manifest here is not an instruction to land an inert file.

Required focused tests: unknown/missing/duplicate JSON properties; wrong schema/type; excessive JSON depth; absolute/traversal/control-character/backslash paths; missing tracked target; duplicate/unsorted/cross-array path; `.mdc` hidden-path discovery; unknown Tier 1 required header; exact Tier 2/generated classification; candidate-only active exemption rejection; candidate-only authorization stays inert; trusted baseline authorization permits only its exact path; bounded no-manifest bootstrap; unsafe Git modes/paths fail closed; endpoint-final-pass/intermediate-invalid and endpoint-final-fail; one ADR Status; retained template semantic cases. Original4 explicitly names final-pass despite intermediate violations, invalid-final failure, one ADR lifecycle Status and retained template semantics. These remain in the native mutation suite; a test count does not replace their scenario map.

## D-A02-05: Align ordinary shared documentation and harmless conventions

**Validate.** CONTRIBUTING carries equivalent source/output, metadata, generation and publication requirements in two layouts. README differs in harmless headings and separator punctuation in addition to real guide sections/globs/authorship. ISSUE_EVALUATION_PROMPT has identical prompt content but different scope/owner wording. Invoke-MarkdownLint differs only in one diagnostic sentence. These are common bytes that need no repository exception.

**Stakeholders.** New and experienced contributors, readers using links/headings, both maintainers, agents, reviewers, and cost owners need consistent concise instructions. Accessibility readers benefit from plain headings; language guide consumers need real globs and TOC links. Security owners need publication and authority statements retained. No license or provenance fact is changed here.

**Options.** A: call all wording repository-specific. B: copy one whole repository's documents verbatim. C: use common explanatory text and preserve only verified language/output/title/link/authorship facts. D: factor a shared remote documentation package. Combining C with narrow local configuration is allowed only when it reduces rather than adds maintained surfaces.

**New rubric.** Fact/contract correctness 40%, navigation/usability 30%, raw shared-byte convergence 20%, maintenance burden 10%. Hard constraints: no broken guide target/glob; preserve no-cross-reference and publication truth; do not alter authorship/history or legal statements.

| Option | Correctness | Usability | Convergence | Burden | Total /100 | Uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| A | 4 | 3 | 1 | 4 | 62 | Harmless drift remains unexplained |
| B | 2 | 3 | 5 | 4 | 62 | Incorrect language facts; fails constraints |
| C | 5 | 5 | 5 | 4 | 98 | Verify final links against native guide heads |
| D | 4 | 3 | 5 | 1 | 72 | Third source of truth violates self-containment |

Total = `(40*Correctness + 30*Usability + 20*Convergence + 10*Burden)/5`.

**Selection.** Use C. Use common contributor guidance. Explain that root `copilot-instructions.md` is generated and `.github/copilot-instructions.md` is repository guidance. Keep real scoped filenames and document titles. Use plain README section headings and common punctuation. Keep factual guide introductions, actual guide TOCs, actual instruction globs, language-specific goals, acknowledgments, and authorship lines. Make ISSUE_EVALUATION_PROMPT's purpose and no-mutation boundary identical. Use the clearer existing PS lint diagnostic in both helpers. Do not add a new test for a diagnostic-only change; run the affected existing checks.

## D-A02-06: Preserve exact attribution, license notice, and repository identity facts

**Validate.** The LICENSE body is equal after its one copyright line. PS names Frank Lesniak; TF names Frank Lesniak, Blake Cherry, and Danny Stutz. ACKNOWLEDGMENTS records different sources and authorship history, including PS attribution. The editor title names the actual repository. Replacing these values with the peer's facts would make an unsupported statement. This is textual preservation, not a new legal determination about those facts.

**Stakeholders.** Named contributors, attributed source authors, maintainers, downstream redistributors, history custodians, readers, and legal/ownership reviewers. Editor users need correct repository identity. No metadata validator, recovery operator, translation, or telemetry consumer requires these facts to match.

**Options.** A: preserve exact facts and compare common legal text. B: overwrite with one repository's notice/attribution. C: remove attribution and authors. D: create a combined cross-repository attribution without evidence. A substantive correction requires new factual evidence and its own decision.

**New rubric.** Factual fidelity 50%, attribution preservation 30%, reader clarity 15%, maintenance burden 5%. Hard constraints: do not invent copyright holders or source use; do not remove potentially required attribution for byte equality.

| Option | Fidelity | Attribution | Clarity | Burden | Total /100 | Uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| A | 5 | 5 | 5 | 5 | 100 | Source truth is preserved, not independently re-proved |
| B | 1 | 2 | 3 | 4 | 35 | False or lost attribution; fails constraints |
| C | 1 | 1 | 2 | 5 | 27 | Removal can lose obligations; fails constraints |
| D | 2 | 3 | 3 | 2 | 49 | Unsupported combined history |

Total = `(50*Fidelity + 30*Attribution + 15*Clarity + 5*Burden)/5`.

**Selection.** Use A. Preserve the exact copyright line in each repository. Prove all remaining LICENSE bytes equal. Preserve each acknowledgment's factual content. Preserve each editor title. Retain exact README authorship. Scope the ACKNOWLEDGMENTS exception to its documented source/attribution content; it is not an exemption for arbitrary future wording. Reopen when a supported factual correction changes the inputs.

## D-A02-07: Protect nested personal agent memory

**Validate.** PS `.gitignore` anchors `/CLAUDE.local.md` at root; TF uses `CLAUDE.local.md` at any depth. Both call this personal project memory. Nested project memory has the same privacy/nonpublication purpose. The root-only pattern leaves that purpose incomplete and has no language rationale.

**Stakeholders.** Agent users and operators, privacy/data owners, both maintainers, reviewers, and contributors with nested directories. No build, artifact, cloud, or license consumer requires personal local memory to be tracked.

**Options.** A: retain root-only PS pattern. B: use TF's exact filename pattern at all depths. C: ignore every CLAUDE or Markdown file. D: add a custom scanner. B protects this known filename without hiding normative CLAUDE.md.

**New rubric.** Privacy purpose 45%, legitimate tracked content 30%, consistency 15%, simplicity 10%. Hard constraints: do not ignore CLAUDE.md or public docs; do not claim an ignore rule removes an already-tracked secret.

| Option | Privacy | Tracked content | Consistency | Simplicity | Total /100 | Uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| A | 2 | 5 | 2 | 5 | 64 | Nested personal memory is not ignored |
| B | 5 | 5 | 5 | 5 | 100 | Check Git's actual matching behavior |
| C | 5 | 1 | 5 | 4 | 74 | Hides legitimate docs; fails constraint |
| D | 4 | 5 | 4 | 1 | 80 | New scanner unnecessary |

Total = `(45*Privacy + 30*TrackedContent + 15*Consistency + 10*Simplicity)/5`.

**Selection.** Use B. Use `CLAUDE.local.md` in both files. Keep all other ignore rules. Verify root and nested matches. Verify that CLAUDE.md remains visible. Inspect the tracked tree; the rule does not untrack existing files.

## D-A02-08: Replace stale lint documentation with verified current behavior

**Validate.** PS lint implementation docs list old dependency ranges, obsolete file/test locations, fixed historical block counts, and claimed test outcomes. TF has a concise current document but its local-hook descriptions depend on A07's actual implementation. Both nested parsers demonstrably disable MD041 and MD051 for snippets and lint `md`/`markdown` fences recursively. Keep actual useful behavior; remove stale implementation claims, not safeguards.

**Stakeholders.** Contributors, lint maintainers, CI/platform engineers, documentation authors, reviewers, agents, and cost owners need current commands and meaningful error semantics. Windows/Unix users need declared runtime instructions. Security reviewers need independent workflow-policy validation preserved. Historical test custodians need no fabricated new test claim.

**Options.** A: retain PS summary. B: copy all TF prose including A07-dependent details. C: write concise common current behavior with pointers to authoritative hook/workflow/toolchain files and no fixed test-count claim. D: delete the document. Reproducing full hooks or dependency tables in this document adds an unnecessary mirrored surface.

**New rubric.** Current correctness 45%, useful diagnostics/setup 25%, verification traceability 20%, maintenance burden 10%. Hard constraints: preserve recursive lint and source-location diagnostics; do not claim unavailable hook behavior or new test success; do not weaken the workflow-policy job.

| Option | Correctness | Usability | Traceability | Burden | Total /100 | Uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | --- |
| A | 2 | 3 | 2 | 1 | 43 | Stale ranges and historical success count |
| B | 4 | 4 | 4 | 4 | 80 | Requires A07 hooks before true in PS |
| C | 5 | 5 | 5 | 4 | 98 | Recheck pointers when A03/A07 change callers |
| D | 4 | 1 | 1 | 5 | 55 | Removes useful contributor instructions |

Total = `(45*Correctness + 25*Usability + 20*Traceability + 10*Burden)/5`.

**Selection.** Use C. Describe current outer and nested lint behavior. Point to the live configuration, helpers, workflow, hooks, and dependency setup. State each phase's nonzero failure behavior. State MD041 and MD051 snippet exceptions. Do not repeat dependency versions or historical passing counts. A03/A07 must update only invalidated caller descriptions after their changes.

## Path dispositions and narrow exceptions

| Paths | Proposed disposition | Decision / boundary |
| --- | --- | --- |
| `.codex/config.toml`, `.gitattributes`, `ci-toolchain.json`, `npm-risk-exceptions.json` | No change; raw bytes/modes equal | Native evidence; A07 reopens runtime inputs when changed |
| `.github/instructions/docs.instructions.md` | No policy edit | D01; exact language/repository names/URL and factual previous metadata only |
| `.github/instructions/yaml.instructions.md` | No A02 edit | D01; previous metadata only; A05 future substantive contract |
| `.github/copilot-instructions.md` | Repair both | D02; scoped generated filename and repository title only |
| `AGENTS.md`, `CLAUDE.md` | Selective paired repair | D03; real repo/language/local-or-external PS guide reference; common toolchain summary delegates detailed installation to the existing A07-owned document |
| `.github/document-metadata-classification.json` | Coupled PS consumer + manifest port | D04; one actual scoped generated filename |
| `Invoke-MarkdownLint.ps1` | TF diagnostic to PS exact value | D05; no semantic exception |
| `MARKDOWN-LINTING-IMPLEMENTATION.md` | Common verified concise document | D08; no repository exception needed |
| `.gitignore` | PS to exact TF bytes | D07 |
| `.vscode/settings.json` | Retain exact title value | D06; no other byte/mode difference |
| `ACKNOWLEDGMENTS.md` | Preserve factual source/attribution content | D06; whole present factual content, not wildcard future prose |
| `LICENSE` | Preserve only differing copyright line | D06; all other bytes equal |
| `CONTRIBUTING.md` | Common content with exact scoped output filename | D05 |
| `README.md` | Common headings/punctuation; preserve factual scoped regions | D05/D06; actual TOC/globs/language goals/source attribution/authorship |
| `docs/ISSUE_EVALUATION_PROMPT.md` | Common scope/owner/link labels | D05; prompt is already byte equal |

For each exception, use the exact native blobs and commits in owned-paths.json and exact diff hunk in `diffs/`. Verbatim peer adoption fails by naming the wrong repository, missing scoped filename, incorrect language content/target, or unsupported author/source claim. A single common implementation plus small configuration is sufficient for algorithms and prompts; no algorithm fork is selected here. No directory exemption exists. Proposed changes must be compared as raw Git blobs/modes after both PR lifecycles; these preparation comparisons are not final main/main acceptance.

## Exact protected-file authority request

The selected protected set is **AGENTS.md, CLAUDE.md, and .github/copilot-instructions.md in franklesniak/PSStyleGuide and franklesniak/TerraformStyleGuide**. Authorize only D02's generated-artifact warning correction and D03's compact execution/evidence, explicit-authority preservation, generation reminder, and placement-record changes shown in the proposed patches. Include necessary Version/Last Updated synchronization at the actual finalization date. Preserve each platform protocol, complete protected-file authorization rules, all review obligations, and all unrelated content. Include the common toolchain summary that points to existing dependency-maintenance documentation and requires no absent A07 file. Do not add an installation command that names an absent file. No docs.instructions or yaml.instructions edit is requested.

This is an exact content request, not authority to waive protection, settings, review, permissions, credentials, force, or unrelated guide changes. The native protected-file rule requires a direct explicit owner grant; the execution plan alone is insufficient. The coordinator should present the concrete patches and ask once for this selected set. A01 is accepted. Only protected implementation remains gated on this grant.

The frozen protected artifacts are `protected-changes.patch`, `protected-PS.patch`, `protected-TF.patch`, `protected-manifest.json`, and `protected-request.md`. Parent copied and verified their hashes. Do not modify those approval inputs. Earlier full `proposed-*.patch` drafts are design snapshots, not patches to apply over the implemented metadata consumer. The live PS manifest and consumer are implemented atomically in the actual product tree. `implement-nonprotected.py` reproduces the eleven nonprotected edits from the accepted PS pin. [D-A02-09](decision-json-strings.md) and [D-A02-10](decision-metadata-bootstrap.md) record newly reproduced compatibility findings and their complete choices.

## Verification and readiness

Immutable inventory and all nineteen original path comparisons are complete. A00/A01 are accepted. Eleven actual nonprotected PS paths are implemented; no protected edit occurred. The manifest and consumer were committed atomically in PS224. The validation inventory records their earlier pre-commit state; the native commit records the published candidate.

Measured tools: Node24.18.1, npm11.16.0 from the complete immutable A07 runtime; Python3.12.10; PowerShell7.6.5; PSScriptAnalyzer1.24.0; pre-commit4.6.2; markdownlint-cli2 0.23.3/markdownlint0.41.1. No npm audit or installed-graph clean claim is made by A02. No older PowerShell runtime was exercised.

PASS: focused metadata classification/exemption/discovery, JSON type/timestamp precision and offset, finite JSON rejection, exact bootstrap coverage, and effective Git-ignore fixtures; actual classifier 8/8 tests; workflow-policy 72/72 tests and current build/Markdown policy validation; outer Markdown24 files; nested Markdown23 blocks; PSScriptAnalyzer Warning/Error checks for both changed PowerShell files; `git diff --check`; zero protected diff. Focused harness copies actual helper definitions and substitutes only the product PSScriptRoot because it executes from scratch. The full actual content and mutation suite passes exit0. Two required clean full pre-commit passes on the final three-commit fixture bytes passed exit0; exact logs are precommit-final-pass1.log and precommit-final-pass2.log.

The first full test exposed two coupled current-input gaps: JSON timestamp coercion (D09), and previously unvalidated dependency-document header/published baseline (D04/D10). Both selected repairs preserve full current metadata, bounded safe readers, known prior governed checks, template policy and failure truth. No baseline bytes are normalized or rewritten. Full content validation and mutation testing pass after fixing the extracted-test initialization order.

The required parser-manifest file/suite is absent at the accepted native PS pin; A06 owns that absent-path outcome. A02 does not invent a passing parser-manifest result. Existing final-state/ADR/template mutations remain and must pass. A02 requires protected implementation, full validation, independent quality and both remote review gates, paired transfer/merge and raw main/main comparison under LOOP-POLICY. This local implementation does not complete A02.

Sole-writer product ownership is now released to the coordinator. The eleven nonprotected paths are ready for scoped review/publication; A02 remains incomplete. The protected v1 preview is not implementable under PS's per-file32768-byte contract (AGENTS34533/TF34650); do not apply it. A separate smaller v2 is being prepared without cap widening. Parent owns commits/public lifecycle and planning integration. Worker retains scratch-only ownership and awaits a new product writer assignment before any further product edit.

Coordinator integration: verified37 native raw identities/modes and45 weighted score totals; committed candidate has11 paths and a clean worktree. Both final pre-commit logs record native exit0. This report preserves preparation limits and does not accept A02. The frozen v1 protected proposal remains unready and unapplied; a separately named v2 is pending. No result in this report authorizes protected edits.

D16 focused results are terminal: static checks, private hash/disposal controls, Linux intended modes, affected full F2 caller and remaining root mutations passed. The root-focused run omits only its disclosed extracted SelfTest invocation and is not an aggregate pass. A separate real Linux FIFO blocked OpenRead and was terminated with exit143. [D17](review-D-A02-17-decision.md) selects a bounded authoritative Node type inquiry for the private snapshot, with explicit non-atomic limits. Publication and narrow implementation release are pending; no final candidate or aggregate acceptance is claimed.
