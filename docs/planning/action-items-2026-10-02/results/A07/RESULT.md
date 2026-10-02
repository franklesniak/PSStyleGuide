<!-- markdownlint-disable MD013 -->
# A07 read-only preparation result

Date: 2026-10-02 UTC. Requested route: gpt-6.1-sol/high. Effective settings metadata is unavailable. No descendant agent was used. Implementation prerequisite A02 is not accepted. Transfer counter remains 0/12. There is no A07 PR, review clock, public mutation or completed product outcome.

The worker wrote only `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A07-design-20261002`. Raw scratch logs and execution files named below remain there; this integrated result retains the native scope/history summaries, current raw audit reports, meaningful hook outputs and one validation summary. Native Git objects were read from PS main `48f4d8a36c8faceee12afac78aaecea0d176125d`, tree `640ee4c0974fb604b2ebf0a1e1e1a328bd213ddc`, and TF main `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`, tree `dc8f6b82588b8f874d34cd5d0155791aea5793f1`. Scratch archives and separate scratch Git repositories retain those inputs. `native-scope.json` identifies all assessed paths, exact blobs, modes, SHA-256 and byte counts. Checkout normalization is not the comparison method.

## Evidence and findings

Both native locked npm installations passed. Both outer and nested lint commands passed. Both manifest/lock pairs remained unchanged. The supplied runtime had the correct version labels but lacked npm `ls` and `config` command modules. Initial audit errors and npm test failures remain in `execution.json` and original logs; they are tool failures. They are not vulnerability findings or product failures. This is the same defect and selected recovery as PS219 D01, whose native record was re-read.

The complete official archive was downloaded into this scratch. Its SHA-256 `ec56b84a7551893ab2324ebdfdc4ab974a63b4781162600b68a1293cc3e53765` matched the fresh [Node checksum list](https://nodejs.org/dist/v24.18.1/SHASUMS256.txt). The complete executable is `C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A07-design-20261002/runtime/node-v24.18.1-win-x64/node.exe`. It reports Node24.18.1 and bundled npm11.16.0. No shared runtime was repaired. Only invalidated audits/tests were repeated. PS passed26/26 and TF27/27 npm/helper tests, with zero skips or failures. Both actual ordinary audit helpers returned CLEAN, checked both installed roots and named the pinned native authority. All four raw current npm report-version2 responses have zero package vulnerability summaries at every severity. Reports and timestamps are in `recovered-execution.json` and `*-raw-audit.log`. This registry result does not establish absence of undisclosed vulnerabilities.

The current publisher [smartquotes advisory](https://github.com/markdown-it/markdown-it/security/advisories/GHSA-r7fv-28h4-cvq7), checked today, affects `<14.3.2` and `>=15.0.0,<15.0.2`; it names patched14.3.2 and15.0.2. Both locks keep direct14.3.2 and the scoped CLI0.23.3 override to15.0.2. Both exception records are empty. There is no active accepted vulnerability grant. Do not extend the original historical `2026-10-29T23:59:59Z` expiry. Original311 and native P1 documentation retain it as historical authority, not renewed permission. The current check is dated October2; no August checkpoint was backdated.

Native PS219 merged at `44eb21d9957cdb905fc0db599b1fb77e16fa583f`. Its first actual Copilot service found the ordinary-audit ambient dynamic-event defect, recorded in [D40](https://github.com/franklesniak/PSStyleGuide/pull/219#issuecomment-5925007350). PS220 repaired command-intent selection and merged at `4c2eee95119531d2faa0683d689c3057911a8ee1`. [Its final record](https://github.com/franklesniak/PSStyleGuide/pull/220#issuecomment-5925430840) preserves failed/unavailable Codex separately from the actual Claude substitute and observed Balanced Copilot. TF62 merged at `83cc3bdc55905c7349cafb4fe02e291d0c99a983`; [landed acceptance/D56](https://github.com/franklesniak/TerraformStyleGuide/pull/62#issuecomment-5934618037) retains distinct unavailable Codex, actual Claude and Balanced Copilot, actual service validation and transparent platform forwarding limits. Those historical grants are not current reviewer substitutions. Full native readbacks are `ps-pr219.json`, `ps-pr220.json`, `tf-pr62.json`; extracted text aids inspection. PS145/146/148/149 and TF24 are currently closed; closure does not prove A07 convergence.

TF's hashed Python closure installed with binary-only/hash checking into a fresh disposable Python3.12.10 environment; pip check passed. The disposable environment establishes wheel/install feasibility only. Native launcher tests used the installed system interpreter, whose four direct tool versions match the lock: pre-commit4.6.2, pre-commit-hooks6.0.0, yamllint1.38.0, check-jsonschema0.37.4. Its actual JSON module exits0 for valid JSON and1 for malformed JSON. The native launcher uses `-E -P`, which ignores PYTHON variables and removes the unsafe current-directory path. It does not attest installed bytes or exclude every system/user-site source. No stronger confinement claim is made. See [Python flags](https://docs.python.org/3.12/using/cmdline.html) and [pip secure installs](https://pip.pypa.io/en/stable/topics/secure-installs/).

The full native TF pre-commit run completed successfully from a fresh private PRE_COMMIT_HOME. All11 actual hooks passed, including cold installation and execution of the exact actionlint commit, both schema checks, staged Markdown, workflow policy and instruction mutation checks. See `tf-precommit-all.log` and `hook-execution.json`. The native Python module launcher used its matching system3.12 tool closure as described above; the pre-commit orchestrator ran from the disposable locked environment. This mixed invocation is explicit. Neither tracked scratch tree changed: final `git diff --exit-code HEAD --` returned0 in each. Actual remote Python hook resolution on PS was not repeated; it is precisely the differing mechanism selected for replacement, and no equivalent baseline execution is claimed.

Real Git Bash hook calls use native files and the exact declared Node runtime. A staged Markdown fixture contained invalid heading spacing inside a Markdown fence. The worktree copy was clean. PS's actual hook returned0; TF's hook returned1 with MD022 from Git-index nested content. This confirms PS's missing staged nested validation, independently of any byte count. `ps-real-hook.log` and `tf-real-hook.log` retain results. Initial direct Python subprocess calls resolved the host's Node26.10.0 because Windows executable search differs from child environment PATH; TF correctly rejected it with exit2. Those calls are wrong-runtime evidence, not exact-runtime staged tests. The Git Bash calls used24.18.1 and reproduced the meaningful behavior.

Absolute-executable repetitions of the no-staged-Markdown case passed in both repositories with Node24.18.1. These are `ps-exact-empty-stage.log` and `tf-exact-empty-stage.log`. There was no runtime defect in that case. The result tables'29 option rows were independently recomputed by `verify-decision-tables.py`; `decision-table-validation.json` retains the arithmetic.

## Decisions before proposed implementation

All scores below use0 (fails) through5 (fully meets criterion), with total `sum(weight*score)/5`. Scores are engineering judgments. They are not observed defect probabilities. The rubric is specific to each finding. The chosen instructions use short controlled-English wording; formal ASD-STE100 dictionary compliance is not claimed. These are proposed solutions. No product implementation occurred.

### D07-1: Keep the actual patched remediation and current audit

Validated problem: stale historical risk wording could incorrectly renew an exception or prompt unnecessary upgrades. Current native graphs are patched and all current reports are clean; published advisory verification catches a historical registry coverage gap. Stakeholders: owner/security risk authority, dependency and CI maintainers, contributors, upstream package maintainers, guide-parser users, reviewers and history auditors. Cloud recovery, privacy and localization are not affected by this scoped package decision.

Options: A keep patched locks/override and ordinary current audit; B upgrade all packages to newest available releases; C remove the override now; D replace patched versions with a new exception; E reinstate the deep historical freeze as the normal admission gate. B may be revisited for a real advisory/compatibility need. It does not combine usefully with C or D. Hard constraints: do not install known affected versions when the compatible fix is present; do not label a failed tool clean; do not renew risk without actual authority.

Rubric: current risk coverage45, consumer correctness25, maintenance clarity20, low churn10.

| Option | Coverage45 | Correctness25 | Clarity20 | Churn10 | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 100 |
| B | 4 | 3 | 3 | 2 | 67 |
| C | 1 | 2 | 4 | 4 | 43; ineligible |
| D | 2 | 3 | 2 | 4 | 49; ineligible |
| E | 4 | 4 | 1 | 1 | 62 |

Select A. Keep the patched direct parser. Keep the version-scoped CLI override. Remove the override only after a reviewed parent update supplies its patched parser. Keep the exception record empty. Refresh the audit for the actual final candidate. Keep failed historical service results. Do not renew October29 authority. Implementation: no vulnerability remediation PR is justified by these current inputs; the behavior-convergence findings below do justify an A07 PR after A02.

### D07-2: Remove the redundant PS root CLI graph

Validated problem: PS root installs91 packages; TF root installs7. Both direct instruction consumers use root markdown-it. PS alone owns a direct root CLI command; TF's documented root command delegates to the installed workflow graph. No PS instruction-validator direct CLI import exists. TF's native validator explicitly prohibits this duplicate root lint graph. Stakeholders: both maintainers, package suppliers, Windows/Linux contributors, instruction/lint authors, CI operators, reviewers, supply-chain security and schedule/cost owners. No deployment or data-storage interface is affected.

Options: A retain the differing graphs; B use TF's delegation in both roots and remove only PS root CLI/now-unused override; C add PS's redundant root CLI to TF; D remove all root packages and relocate the instruction parser. Hard constraint: keep the root parser consumer working; preserve both lint phases. D requires unsupported new integration and is ineligible here.

Rubric: consumer correctness40, dependency reduction25, shared behavior20, maintenance10, effort5.

| Option | Correctness40 | Reduction25 | Shared20 | Maintenance10 | Effort5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 3 | 2 | 2 | 5 | 72 |
| B | 5 | 5 | 5 | 5 | 4 | 99 |
| C | 5 | 2 | 5 | 2 | 4 | 78 |
| D | 2 | 5 | 5 | 3 | 1 | 68; ineligible |

Select B. Delegate root lint commands to the workflow package. Keep root markdown-it14.3.2. Remove PS root markdownlint-cli2. Regenerate only its affected lock with npm11.16.0. Keep the workflow CLI override. Use common script/dependency/version fields. Keep only necessary actual repository URLs, meaningful package identities and factual author attribution as narrow exceptions. Remove arbitrary description wording differences. For each retained identity field, show its diagnostic or metadata use in final comparison; private package status alone does not require a fork. Tests: locked clean install, installed graph, instruction parser and both real lint commands. Native TF baseline establishes the existing consumer arrangement, not acceptance of a proposed PS edit.

### D07-3: Use the stronger common staged and repository lint behavior

Validated problem: the actual staged nested fixture passes PS and fails TF correctly. TF also validates exact declared runtime and normalizes tooling failures to2, while PS accepts Node22+ and passes unexpected statuses through. Both repositories contain nested Markdown examples. TF's outer wrapper validates paths before supplying in-memory contents. Stakeholders: authors with partial staging, new contributors and GUI Git users, both lint/CI maintainers, generated-artifact consumers, reviewers and Windows/Linux operators. Accessibility/localization has no new user interface; readable diagnostics remain relevant.

Options: A keep forks; B reuse TF's index-content API/runtime/exit contract and three-phase hook in both; C reduce both to PS staged outer-only behavior; D remove local Markdown hooks and rely on CI; E create a new hook framework. Smaller combinations that add nested index handling without wrapper/exit consistency remain partial variants of B and fail convergence. Hard constraints: retain TF's supported outer/nested phases, inspect staged bytes, preserve failure and path-boundary behavior.

Rubric: supported behavior40, staged reliability25, contributor usability20, common code10, cost5.

| Option | Behavior40 | Reliability25 | Usability20 | Common10 | Cost5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 3 | 4 | 3 | 1 | 5 | 63 |
| B | 5 | 5 | 4 | 5 | 3 | 94 |
| C | 2 | 3 | 5 | 5 | 4 | 65; ineligible |
| D | 1 | 1 | 2 | 5 | 5 | 36; ineligible |
| E | 3 | 3 | 2 | 5 | 1 | 58 |

Select B. Reuse TF's staged-content and outer-content APIs. Keep nested lint's existing safety self-test. Require the exact declared Node runtime. Return0 for success. Return1 for lint findings. Return2 for tooling errors. Select ACMR `.md` and `.mdc` staged paths. Run the existing repository outer and nested phases after the staged phase succeeds. Do not add a new framework. Tests must cover no staged Markdown, partial staging, nested fences, hidden paths, Unicode/spaces, rename/delete selection, parser/tool launch failure and nonzero status propagation. Preserve tests that run actual native processes; do not replace them with text assertions. A06 owns artifact-generator semantics; A07 owns only lint helpers.

### D07-4: Reuse the hashed Python hook closure

Validated problem: PS's remote Python hook environments resolve separate transitive installations; TF supplies a complete hashed binary-only requirements closure and a system3.12 module launcher. TF selectors cover all YAML, `.js` lint helpers and metadata-classification JSON; PS is narrower. Both repositories need these validations. The clean lock install passed on Windows3.12.10. Stakeholders: Python tool maintainers, contributors, dependency/security engineers, agents operating before commit, CI maintainers, reviewers and maintenance/cost owners. Application/cloud recovery and private-data custody are unaffected.

Options: A keep the split; B reuse TF lock/launcher/local hook topology and complete selectors; C move TF back to remote Python hooks; D remove Python hooks; E create a new venv bootstrap/runtime selector framework. E can be valid under a separately demonstrated interpreter defect, but no such supported defect was established. Hard constraints: retain all useful JSON/YAML/whitespace/schema/metadata/instruction checks; do not describe available modules as verified installed bytes; do not erase TF's staged-input guard.

Rubric: installation integrity35, validation behavior30, setup usability20, common closure10, effort5.

| Option | Integrity35 | Behavior30 | Usability20 | Common10 | Effort5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 5 | 3 | 1 | 5 | 63 |
| B | 5 | 5 | 4 | 5 | 4 | 95 |
| C | 2 | 4 | 3 | 5 | 4 | 64 |
| D | 1 | 1 | 4 | 5 | 5 | 44; ineligible |
| E | 5 | 3 | 2 | 5 | 1 | 72 |

Select B. Reuse requirements-dev.txt and Invoke-LockedPythonHook.ps1. Keep the same system-Python3.12 selection contract. Install with the same interpreter used to run pre-commit. Keep hash checking and binary-only wheels. Keep actionlint's reviewed exact commit and Go closure. Add missing `.js`, all-YAML and metadata input selectors. Port only the coupled staged-input validator functions and fixtures after A02 accepts its changes. Adapt bootstrap validation to A02's accepted dependency-document reference; do not restore duplicate protected inline setup text. Run each actual hook on both platforms. Do not assume the cold-cache full-hook result from another platform. The disposable venv is assessment tooling, not a proposed product requirement.

### D07-5: Use explicit hook suppression consistently

Validated problem: native PS installer skips CI and production; TF intentionally installs there because its Copilot setup validates active hook installation. Those are shared contributor-tool algorithms. Native TF real installer tests cover normal/CI/production/both/HUSKY=0. Stakeholders: CI and platform operators, agent users, new/experienced contributors, hook maintainers, reviewers, owner and incident operators diagnosing setup. No settings or platform wrapper modification is needed.

Options: A use TF's HUSKY=0-only suppression in both; B use PS automatic suppression in both; C add per-caller policy configuration; D retain forks; E remove installers. Hard constraint: preserve TF's actual CI hook requirement and explicit opt-out; preserve source-archive reporting and nonzero installation failure. Native platform forwarding is not a defect.

Rubric: caller correctness40, side-effect control25, common behavior15, usability10, effort10.

| Option | Correctness40 | Control25 | Common15 | Usability10 | Effort10 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 4 | 5 | 4 | 5 | 93 |
| B | 4 | 5 | 5 | 4 | 4 | 88; ineligible |
| C | 5 | 5 | 4 | 3 | 2 | 87 |
| D | 5 | 4 | 1 | 3 | 5 | 79 |
| E | 0 | 5 | 5 | 2 | 5 | 54; ineligible |

Select A. Install the hook after locked setup unless HUSKY=0. Report an archive without `.git` as an applicable skip. Expose installer failure. Preserve GitHub's transparent forwarding wrapper. Add no cloud wrapper repair or special-path regression. A03 must explicitly use HUSKY=0 only in jobs where no hook is needed; it must preserve installed hooks in Copilot setup. Tests: actual installer matrix, actual valid/invalid scratch commits, and native changed-service setup after merge.

### D07-6: Factor audit identity without weakening hosted authority

Validated problem: Check-NpmAudit algorithms are identical except two exact expected-repository/fetch URL literals; tests differ by repository fixtures. Ordinary versus hosted intent is already repaired. Identity is security-relevant; accepting candidate-manifest or ambient expected identity could weaken native authority selection. Stakeholders: risk owner, audit/CI maintainers, fork contributors, security reviewers, platform operators and history custodians. No current grant or privileged operation is added.

Options: A retain two hard-coded source identity occurrences and all test fixture forks; B use one exported reviewed expected-repository constant, derive fetch URL and test fixtures from it; C read identity from proposed package metadata; D accept ambient GITHUB_REPOSITORY as expected identity; E create a separate policy/configuration framework. Hard constraint: expected identity must be part of the reviewed trusted input, and hosted base/main restrictions and unsupported-event refusals must remain. A06/A03 security contracts cannot be weakened for equality.

Rubric: authority correctness45, failure preservation25, common algorithm/tests20, effort10.

| Option | Authority45 | Failure25 | Common20 | Effort10 | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 3 | 5 | 92 |
| B | 5 | 5 | 5 | 4 | 98 |
| C | 3 | 5 | 5 | 4 | 80; ineligible |
| D | 2 | 3 | 5 | 5 | 63; ineligible |
| E | 5 | 4 | 5 | 1 | 87 |

Select B. Declare one expected repository constant in the reviewed helper. Use it for hosted identity rejection and immutable fetch URL. Import it in common tests. Keep the exact one-line identity difference as a necessary exception. Keep ordinary audit local authority even under dynamic agent variables. Keep --ci hosted authority. Keep graph/schema/expiry/scope/tool/cleanup failures. Keep existing time/output limits and retry count. No risk authority is renewed.

## Proposed minimal path scope and sequential integration

Implementation starts PS-first after actual A02 acceptance. One writer owns A07. Likely actual paths: `package.json`, `package-lock.json`, `.github/workflows/package.json`, `.github/workflows/package-lock.json`, `.github/workflows/install-husky.mjs`, `.github/workflows/NpmTools.test.mjs`, `.github/workflows/Check-NpmAudit.mjs`, `.github/workflows/Check-NpmAudit.test.mjs`, `.github/workflows/lint-staged-markdown.mjs`, `.github/workflows/lint-nested-markdown.js`, `.github/workflows/Invoke-LockedPythonHook.ps1`, `requirements-dev.txt`, `.pre-commit-config.yaml`, `.husky/pre-commit`, `docs/dependency-maintenance.md`, affected sections of `.github/workflows/scripts-README.md` and `MARKDOWN-LINTING-IMPLEMENTATION.md`, one common harmless diagnostic in `Invoke-MarkdownLint.ps1`, and only coupled portions of Test-AgentInstructions.ps1/SelfTest. Do not change identical NpmTools.mjs, runtime pins, .markdownlint config or empty exception state merely to show activity. Workflow files/cross-workflow helper tests require serialized A03 integration ownership, not a second A07 writer.

Exact TF validator reference regions at the pinned baseline: RequireStagedInputMatch parameter/docs/guard lines14,52,80; Get-StagedInputMatchFailure555; Read-RepositoryInputData701 (only its index-matching contract); Get-HuskySetupContractFailure1432; Get-PreCommitBootstrapContractFailure1739; input-spec additions around5744; staged path acquisition5832; RequireIndexContentMatch call sites5877/6132/6152/6172/6192/6219/6256; setup requirements consumption6311/6363/6651; relevant mutation fixtures6898–7110. Use these as integration anchors, not wholesale copy ranges. Preserve PS-only operative instruction/example behavior and A02 metadata classification/ignore/placement changes. TF keeps its substantive library contracts. New validator fixtures belong in the accepted dedicated SelfTest layout. Full affected SelfTest is mandatory after the sequential integration. Do not alter unrelated A06 generator regions. No A02→A07→A02 cycle is needed.

A03 must include the actual changed closure in trigger/admission paths: requirements-dev.txt, Invoke-LockedPythonHook.ps1, install-husky.mjs, lint-staged-markdown.mjs, lint-nested-markdown.js, both package/lock pairs, .pre-commit-config.yaml, .husky/pre-commit, dependency docs and affected validator inputs. Retain trusted credential/config normalization and exact Node/npm/Python setup. A02 supplies existing shared setup documentation; A07 supplies the actual toolchain fact changes after it lands. If accepted protected instructions do not already permit linked common setup, prepare the exact minimal wording for parent's authority assessment; no blanket protected edit is authorized by this worker.

A04 retains ordinary Node-download retry ownership. NpmTools already shares npm normal download retries within a600-second per-root deadline and120-second/2MiB audit child limits. A07 does not change those constants. Initialize-CiToolchain and workflow-policy edits stay with their assigned owner. A04 must retain the install-versus-audit command-intent distinction.

Final acceptance still needs actual proposed-candidate clean install/audit, both-platform real hooks/native-failure/environment-isolation tests, affected full instruction SelfTest, A03 CI callers and changed-service behavior, both required named reviews, independent quality, source/peer PR lifecycles, raw reverse comparison and justified exact identity exceptions. Linux was not executed by this Windows assessment. Native service acceptance is historical evidence only. No product test is fabricated from the read-only design or existing closed issues.

## Coordinator review

The parent rechecked all 38 recorded raw source blobs and all 29 weighted totals. It read both npm test summaries, the actual staged-hook contrast and all 11 cold-cache hook results. See [validation.json](validation.json) and [current-audit-reports.json](current-audit-reports.json). This accepts the read-only preparation, not A07 implementation or final convergence. A02 now also owns a metadata-heading repair in dependency-maintenance.md; A07 must preserve that accepted structural change while later converging its substantive instructions.
