<!-- markdownlint-disable MD013 -->
# A10 read-only preparation

RESULT: preserve the delivered PS148 example and PS151 accidental-operation preflight outcomes. No new behavioral defect was reproduced. No A10-only implementation PR is justified by these sources. Shared-file raw alignment remains with the existing A03/A04 integration scopes. A06/A07 prerequisites and actual candidate acceptance are pending; this is not product completion.

Requested route gpt-6.1-sol/medium; effective settings unknown. No descendants. Only dedicated A10 scratch was written. Transfers0/8. No PR clock, request, review, public comment, product/planning edit, commit, push or settings change.

## Inputs and exact identity

Read STATUS first, A10, relevant original contracts, A00 ledger/native acceptance, A06 design/threat map/probes and A07 result. Full pinned snapshots, including complete normative/rationale sources and all examples, are in PS/ and TF/. Complete-source-inventory.json records the complete source heading/fence/marker locations. Inspection and execution are distinguished below. Illustrative guide snippets were not executed as programs.

Authenticated native ref reads returned PS `48f4d8a36c8faceee12afac78aaecea0d176125d` / tree `640ee4c0974fb604b2ebf0a1e1e1a328bd213ddc`, TF `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c` / tree `dc8f6b82588b8f874d34cd5d0155791aea5793f1`. Source-evidence.json records every extracted tracked blob, mode and raw SHA-256, from native Git objects rather than planning checkouts.

| Role | PS blob | TF blob | Mode |
| --- | --- | --- | --- |
| Test-BlankLineExamples.ps1 | 068c7139a9e6a9276073211f48eca88464204362 | absent | 100644 / absent |
| STYLE_GUIDE.md | 21bbb515429eb5fdac47f14128a95d5fd55122aa | f872e52ee5b7ded737157dcf745cb93013005a2b | 100644 |
| STYLE_GUIDE_RATIONALE.md | afb5ba370810e36a9c1ba103aa8e5691a3131581 | b5efeee6cb8b6ded6099bbee13b6307ea103cc5c | 100644 |
| Initialize-CiToolchain.ps1 | dc0d195c72d8404e45c6eb39cb102898fd22b667 | 906460d818674199b32294185ed6525c143b48bb | 100644 |
| Validate-WorkflowPolicy.mjs | f90f1dd32a8944651de3d5311e84b08043801fd4 | 995b72a7b48dea2636094d81226893a519950797 | 100644 |
| Validate-WorkflowPolicy.test.mjs | 3f0abda0049fdeacb85c8493937b768ddc999c4a | aa1be01df5a3c8b5369bf8e4313089de9c356365 | 100644 |
| Test-CiHelpers.test.mjs | 0773070a6505b1678c5522c16c8a5c32979f6338 | 7855cc0c1be90096abae979168ed1e282d535998 | 100644 |

Example-test raw SHA-256 is `a81575b8103f1ba973ed7858908b2f3b53d7a68fb4522d9f334762cfdbe6bcc7`. Initializer hashes PS `66c8c2ac9a5b0fc610a1f9c1b4b212966b19f7530c8087f873a86d0f7e6ac220`, TF `a4c30c0426afdd1cc1dbec2560117d8243763a7e4fbdf90aacd32af6bbb3e438`. Validator hashes PS `a8f12abf35f250c7f2d0a0ab753a18a42fca7516a36aae9e3dd90eac76805160`, TF `37462f7f29ad09c8b4bf2a535c870fa758a41c2dcd776bfa1f0be9973b27e4b7`. Remaining source/output hashes are in the manifest; no normalization substitutes for raw acceptance.

## Native acceptance reuse

PS222-reuse.json proves all seven relevant PS guide sources, four outputs and example-test blobs are raw-identical between accepted merge `8d9d8e4dc7a82b0ab705b3347adadb8295945044` and current PS main. The most recent example/source change is reviewed head `5f6c847c398187433ac859a24a2bfb7bee9a43c7`. PS223 and TF65 merge commits are the current main pins. Their preflight input bytes have not changed since landing.

Three complete authenticated native acceptance comments were read. Author franklesniak and full-body hashes match A00:

- [PS222 acceptance](https://github.com/franklesniak/PSStyleGuide/pull/222#issuecomment-5939563496), hash `b39923f1a47b918fc91888af6f43ae7a10c42b7d68baa06b11546e80e5c84f5a`.
- [PS223 acceptance](https://github.com/franklesniak/PSStyleGuide/pull/223#issuecomment-5942762335), hash `77450c0b4f8c63c1b15c16bb207ce87fc66eab9d8c8338b1b3082561a930a7ab`.
- [TF65 acceptance](https://github.com/franklesniak/TerraformStyleGuide/pull/65#issuecomment-5943280033), hash `6ed710e98e313615cf569b91fca117923fc7481021eeeb7a22383a78139ffb60`.

Native-acceptance-comments.json retains their complete bodies. These corroborate previously delivered real Linux setup, actual review and service outcomes. They are not new A10 service executions. PS148/151 native issue bodies were also read; both are closed and explicitly narrow the retained outcome. They retain historical superseded obligations without claiming implementation. No old outage substitution grant is used in this preparation.

## Actual example test and current teaching

PS normative lines245–274 preserve the original requirement levels, a truly empty compliant line, a visible U+2420 noncompliant line and a warning that the marker is illustrative and must not be copied. Rationale lines998–1023 explains why invisible spaces disappear. Four current consumer guides retain the marker and warning. The accepted generator result from A06 proves no-change output in the inspected baseline; A10 did not rerun unchanged generator tests.

The actual full pinned Test-BlankLineExamples.ps1 ran once with `pwsh -NoProfile -File PS/.github/workflows/Test-BlankLineExamples.ps1` on Windows PowerShell7.6.5. It printed `Blank-line example semantics passed, including focused mutation checks.` Its separate native exit was not captured in the combined tool call; do not invent that receipt. The script reaches that final message only after every assertion. No test was rerun after that success.

Existing five negative controls reject identical bodies, a literal spaces-only compliant line, a nonbreaking-space-only compliant line, an unclear warning and a warning that directs copying. Positive controls accept doubled markers and harmless heading/caption/warning changes. Assertions require each mutation to change the input and the expected diagnostic to be observed. The baseline checks distinct examples, one unambiguous visible-marker pair, truly empty compliant line, no whitespace-only lines, visible noncompliant marker and non-copyable/non-syntax warning. This is meaningful semantic evidence, not a whole-snippet hash oracle.

Test-StyleGuideArtifacts.ps1 lines523–552 runs this test in the current PowerShell child, checks native exit0 and the single exact success message after the worktree snapshot. Subsequent snapshot comparison detects child effects. Linux CI-helper semantic-failure and semantic-side-effect cases test that wrapper admission. They did not run here. TF's counterpart child checks Terraform state-recovery examples; replacing it with PS teaching would lose an actual supported caller.

## Decision A10-D1: PS example applicability

Validated finding: this teaching demonstrates PowerShell code and PS148's visible-space defect. TF has its own normative blank-line rule, but no matching PowerShell example consumer or Test-BlankLineExamples path. Raw file absence was verified in the TF tree. This is a narrow language applicability decision, not a directory or guide-wide byte exemption.

Stakeholders: PowerShell guide readers/authors, Terraform readers/authors, both maintainers, semantic-test and generator maintainers, review/CI operators, agent consumers and history custodians. Readers need visible, copy-safe examples. Reviewers need test relevance. Cost owners bear gratuitous peer work. No deployment, personal-data flow, security capability, localization or accessibility interface changes; preserving visual distinction benefits rendered/text consumers.

Options before scoring: A retain PS-specific teaching/test and existing TF semantics. B copy the PowerShell example/test into TF. C create a new Terraform example/test merely for symmetry. D remove the delivered PS example/test. A common checker with fixed per-language semantic child selection is already the accepted A06-D3 design; it combines with A without porting the actual teaching. Deferring a new TF feature belongs to A unless a real TF defect appears.

Fresh rubric: applicability correctness45%, teaching clarity25%, useful oracle coverage20%, ongoing burden10%; scores1–5, total `sum(weight*score)/5`. Hard constraints: preserve supported PS148 semantics and TF's state-recovery admission; do not manufacture required peer behavior. Scores are judgments.

| Option | Applicability | Clarity | Coverage | Burden | /100 |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 100 |
| B | 1 | 2 | 2 | 2 | 31 |
| C | 3 | 3 | 3 | 2 | 58 |
| D | 1 | 1 | 1 | 4 | 26 |

Selected solution: Keep the PowerShell examples in PS. Keep Test-BlankLineExamples.ps1 in PS. Keep TF's existing semantic child. Do not create a TF example for symmetry. Reopen this decision if TF gains a concrete corresponding teaching defect or a shared checker changes its semantic role. The exact exception is PS normative245–274/rationale998–1023 and this PS-only test path versus TF's distinct language content/absence. Generated PS sections inherit that language scope; they are not independently hand-edited exceptions.

## Actual preflight characterization

The production initializer is Linux-only and checks this before external work. It launches exact Node with `--permission`, one literal repository-root `--allow-fs-read` argument, and --preflight before script-suppressed locked installations. The Windows preparation did not run or bypass that Linux caller. No Windows5.1 file execution, policy change or workaround occurred. A06's parse-only/Restricted limitation remains.

Actual pinned validator main imports Node built-ins at module scope. --preflight reads accepted contract/parser-lock/root and workflow manifests/locks, checks decoded duplicate JSON member names, then returns without loading third-party yaml. Installed parser payload acquisition/hash/import belongs to the later full-policy path. Existing tests verify built-in preflight before parser installation, failed full validation without parser, five file-level duplicate cases, empty/escaped/nested/array duplicate keys, legitimate case/scope differences, missing/tampered parser failures and strict YAML malformed/alias/tag/duplicate/depth cases. A07 already ran unchanged applicable Node suites; no broad repetition occurred here.

One PS actual validator invocation under the exact Node24.18.1 executable and permission grant printed success with schema PSStyleGuide.WorkflowPreflightResult.v1 and contract hash `ce37af7763fce291631112f22bb4a7044d92ae83e2d9ff0e53ec62ccc27d93dd`; combined command exit0. Probe.py then ran19 distinct scratch cases with captured native exits and JSON results:

- One TF baseline under a spaced repository root returned exit0/success.
- Eight negative input categories per repository returned exit1 and expected fixed categories: duplicate root key, escaped duplicate, nested duplicate, BOM, invalid UTF-8, malformed JSON, forbidden key and wrong lockfile version. All16 assertions passed. No packages were installed.
- Two instrumented copies appended ordinary attempted file-write/child-launch operations to the pinned validator. Both observed WRITE_ERR_ACCESS_DENIED and CHILD_ERR_ACCESS_DENIED; no marker existed. These processes deliberately ended nonzero. Their preceding preflight output is not complete caller success. They characterize flags on Windows; they are not unmodified production/Linux installer tests or hostile dependency confinement.

Probe-results.json retains native exits, outputs and case kinds; probe.py completed exit0. No successful case was rerun without changed inputs. The flags did not grant write/child authority to the Node child. No network isolation, malicious-code confinement, earlier PowerShell parsing protection or later npm protection is claimed. [Official Node24 permission documentation](https://nodejs.org/docs/latest-v24.x/api/permissions.html) expressly limits this model to accidental trusted-code operations. That currently served24.x page is24.21.0; the actual measured executable here was24.18.1. The general limitation is also reflected in the accepted issue scope and service comments.

## Shared bytes and decision A10-D2

Preflight-comparison.json contains exact raw differences. Initializer files104/103 lines differ in one local variable/diagnostic, package-object versus engines-object spelling, related references and a comment. The exact permission preflight launch is identical. Validator577/577 lines differs in three repository schema literals and later workflow/job/step identifiers. Its preflight JSON/lock/duplicate functions are raw-identical. CI-helper test576/511 lines differs in useful retained case inventory and semantic roles. Do not normalize all three whole files and call them equal; no permanent schema/job/diagnostic exception is approved here.

Validated finding: A10 useful behavior exists, but its shared-file raw completion predicate remains unmet. A03 already owns validator/workflow schema and graph convergence. A04 owns the changing initializer/retry surface. A06-D3 owns the semantic artifact-gate role. A07 owns dependencies. A parallel A10 rewrite would overlap those paths and invalidate shared evidence. This is an integration placement decision, not a new security-policy design.

Stakeholders: the single writers for A03/A04/A06/A07, coordinator, both maintainers, reviewers, runtime/CI operators, contributors and cost/schedule owners. They need one authoritative candidate and retained negative oracles. There is no changed cloud/privacy/localization feature.

Options before scoring: A coordinate raw alignment with those existing writers and revalidate A10 after their accepted results. N treat current raw differences as blanket exceptions. B create a separate A10 cosmetic port now. C add a new generic descriptor/runtime framework. A dedicated later repair is part of A only if upstream work leaves an actual unexplained difference. A03's existing graph decision controls schema/job changes; it is not redesigned here.

Fresh rubric: behavior preservation35%, ownership/authority25%, evidence reuse20%, raw convergence15%, cost5%; scores1–5, total `sum(weight*score)/5`. Hard constraints: no overlapping writer, invented byte exception or premature prerequisite success. Scores are judgments.

| Option | Behavior | Ownership | Reuse | Convergence | Cost | /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | 99 |
| N | 5 | 5 | 4 | 1 | 5 | 84 |
| B | 5 | 2 | 3 | 5 | 2 | 74 |
| C | 3 | 2 | 3 | 5 | 1 | 59 |

Selected solution: Keep A10's useful current behavior. Let each existing writer own its shared file. Carry the16 negative input cases and the measured denial limits into validation. Align harmless initializer spelling during the authorized A04 candidate. Let A03 decide its existing schema/job contract atomically with consumers. Preserve the shared preflight grant and built-in ordering. Compare raw files again after those results. Do not create an A10 cosmetic PR now. No new protected text or security change is selected.

## Original dispositions and acceptance limits

Original-dispositions.json preserves all54 rows for261–287 and352–378, including source hashes, owners, prior credits and present A00 unverified dispositions. All54 were RETAIN in that ledger. No row is relabeled complete from this prep.

-261–267: PS148 commencement/implementation/review/quality/merge/handoff remain historical stage requirements. Reuse exact accepted PS222 history and unchanged blobs; do not replay public stages. Current semantic evidence supplies useful behavior, not reconstruction of every original output.
-268–287: useful counterpart/reverse-comparison requirement is fulfilled here only as a bounded PS-language applicability assessment. No automatic TF implementation or closure is implied. Current A06 and final A18/A19 still own their gates.
-352–358: retain the old PS151 Node permission/duplicate-key requirement. Current accepted issue supersedes malicious-code confinement and exact retired parser machinery. Accidental write/child denial and dependency-free duplicate checks are implemented/measured; this is not security confinement. Native PS223 acceptance is reused only for unchanged bytes.
-359–378: counterpart PS151 behavior exists in TF65/current pin and the current negative probes. Original public-stage/fixed-point predicates remain governed by accepted upstream work and final reconciliation. No issue closure or final native service audit was performed by A10.

This result does not amend the A00 ledger or invent new old-contract credit. A19 must retain the explicit original-versus-amended distinction. PS213 bounded ordinary retry duration remains A04. A14 live filesystem residuals remain separate. No product acceptance is inferred from extracted fixtures.

## Smallest remaining plan

1. Accept A06/A07 prerequisites and the coupled A03/A04 source changes first. Do not edit protected guides from this preparation.
2. Refresh both native commits, all A10 affected blobs and current issue/acceptance facts. Invalidate only changed-input evidence.
3. Run the actual PS semantic test once on any changed example/test candidate. Reuse unchanged accepted source evidence. Run generation/drift and relevant outer/nested Markdown/metadata/staged checks for actual changes; preserve all four generated sections.
4. For changed preflight candidates, run actual full affected validator tests with locked reviewed parser. Run the complete Linux initializer/helper negative permission fixture under Node24.18.1 or the then-reviewed exact runtime. Observe normal install sequence and denial before npm. Test source/current graph acquisition separately; flags do not supply those boundaries. Existing unchanged service evidence can be reused with exact identity proof; modified candidates need fresh service validation.
5. Preserve all shared helper test cases during upstream convergence. Obtain raw byte identity or separately justified exact interface differences after paired delivery. Do not call schema/step labels necessary merely because they differ today.
6. If no A10-specific defect remains, record the conditional no-change outcome after prerequisites and upstream raw convergence. No new PR is needed. If a new confirmed defect appears, complete its finding-specific decision before implementation and use the normal PS-first lifecycle.

No local Windows5.1 bypass, Linux runner substitute, new security design or remote reviewer impersonation is proposed. Security/coupled findings require the parent’s higher-route assessment. No candidate host or cross-platform acceptance is claimed. Next action: coordinator carries these bounded probes and applicability decisions to the accepted upstream candidates, then decides A10 completion from current evidence.

Final preparation validation: verify.py returned exit0. All pinned PS/TF scratch source bytes remain equal to their recorded native SHA-256 values. All54 dispositions,19 measured probe records and8 weighted totals were verified. Final authenticated native ref reads still returned the same PS/TF pins. This is artifact verification, not a repeated product test run.

Coordinator verification: all145 recorded native raw source hashes and modes match. The19 probe records contain16 expected structured rejection results. Eight weighted totals checked. Complete heading inventories, source snapshots, scripts and original contract excerpts remain in the named scratch directory. The semantic success message is retained with the worker’s explicit missing separate-exit receipt limitation. No new product test was run by this integration.
