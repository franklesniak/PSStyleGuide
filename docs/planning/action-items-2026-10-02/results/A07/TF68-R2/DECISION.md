<!-- markdownlint-disable MD013 -->
# TF68-R2: newly surfaced KaTeX dependency advisory

Status: Root displayed all options, this finding-specific rubric, and the checked score table before selecting D under the owner's existing clear-winner approval. Implementation is released at 2026-10-06T01:38:20.858049+00:00. Tests below remain proposed until actual results are recorded. The original read-only proposal and its hash remain in the scratch writer packet.

## 1. Validation and scope

The ordinary two-root audit of committed TF `2de8f4e8b96e09628d3e571294009cbbbd8d3749` exits 1 for one advisory, GHSA-238p-pmpm-9mq7 (CVE-2026-103923, Low). The three package rows are the affected KaTeX package and its two ancestors, not three distinct vulnerabilities. The failing log is `../../R1-current-audit-2de8f4e.log`, SHA256 `b4672d2c5c7ee689311cc58e27d6374ad8785eb06190e9c497a3653bc150e60c`. Root independently captured the advisory API and both repositories' raw locks in `../../TF68-R2/root-validation.json`.

The upstream advisory dates from September 21. GitHub's database published it at `2026-10-05T23:41:05Z` and updated it one second later. This is a newly surfaced current-audit finding, not a demonstrated code regression. Earlier clean audits remain valid dated observations. The R1 focused, aggregate, commit and accepted-base endpoint results remain valid for their recorded inputs; they do not make the new audit clean.

The exact workflow-root graph is markdownlint 0.41.1 -> micromark-extension-math 3.1.0 -> katex 0.16.27. The math package declares `katex: ^0.16.0`. The root package graph does not contain this dependency. The affected range is `>=0.11.0 <0.18.2`; the first fixed release is 0.18.2. A compatible 0.16 lock refresh cannot fix this finding. The official registry currently identifies markdownlint 0.41.1 and math 3.1.0 as their latest releases, so a maintained parent upgrade is not available now. KaTeX's latest release is 0.19.0. Exact registry responses and raw Git inputs are retained beside this record; `evidence.json` binds their hashes, modes, commits and blobs. [Database advisory](https://github.com/advisories/GHSA-238p-pmpm-9mq7), [upstream advisory](https://github.com/KaTeX/KaTeX/security/advisories/GHSA-238p-pmpm-9mq7), [KaTeX registry](https://registry.npmjs.org/katex), [math registry](https://registry.npmjs.org/micromark-extension-math), [markdownlint registry](https://registry.npmjs.org/markdownlint).

The exploit has additional prerequisites: existing prototype pollution, or attacker influence over the options object's prototype. KaTeX does not create that pollution. Inherited settings can change trust and other processing behavior. The documented browser impact additionally requires use of the generated HTML without a separate sanitizer; rendering alone does not execute script. This repository's outer, staged and nested lint callers all reach markdownlint's syntax parser. `lib/micromark-parse.mjs` imports `math` and calls `math()` in its syntax extensions. The math package's index also reexports its HTML module, which imports KaTeX, but the inspected markdownlint implementation never calls `mathHtml` or `renderToString`. No browser HTML-insertion path was demonstrated here. This supports limited present applicability, not a claim that the affected package is absent or that the advisory is false. Broader claims about absence of all prototype pollution were not tested.

Manifest admission was checked against immutable H2. `Validate-WorkflowPolicy.mjs:384` checks lock format, root dependency and engine agreement, registry archives/integrity and package paths. It does not prohibit `overrides`. `NpmTools.mjs` rejects external npm control files, uses exact runtimes, and checks that installation leaves its four manifest/lock inputs unchanged. `Test-AgentInstructions.ps1:429` checks finite package commands and forbids root lint dependencies; it does not prohibit an override in the workflow manifest. No production declaration-policy change or weakening is indicated. npm supports version-qualified parent overrides in each independently installed project root. Here that root is `.github/workflows`, not the repository's separate outer package root. [npm override contract](https://docs.npmjs.com/cli/v11/configuring-npm/package-json/#overrides).

## 2. Affected stakeholders

The owner and both repository maintainers need one transferable, auditable fix and no invented language-specific divergence. Security and supply-chain engineers need truthful applicability, fixed registry bytes and unchanged risk authority. CI/platform engineers and incident/recovery operators need deterministic clean installation, ordinary failure propagation and a restorable qualified archive. New contributors, experienced authors and local/remote agent operators need the existing setup and lint commands to continue working on Windows and Linux without manual package repair. QA and independent reviewers need real lint behavior and negative controls, rather than audit-only evidence. Documentation readers and generated-artifact consumers need the same rules and generated bytes. Dependency maintainers need a narrow temporary override that can be removed after an upstream range update. Schedule/cost owners need bounded targeted work before the coordinator's final gates. Privacy and cloud administrators have no newly demonstrated data-processing or deployment surface; browser accessibility/localization rendering is not used by this lint consumer, so it does not justify a renderer migration here.

## 3. Options, listed before scoring

A. Keep the current graph, repeat the audit, or rely on prior clean results. This preserves behavior but cannot resolve a real current advisory. No retry-only or stale-evidence acceptance.

B. Refresh only the lock within the declared `^0.16.0` range. The latest 0.16.47 remains affected. A hand-edited out-of-range lock without a manifest override would misdescribe resolution and is not this option.

C. Wait for a maintained markdownlint/math release with an updated range, then upgrade the parent and test. This is the preferred eventual removal route for a temporary override, but no such current release was found. Deferral alone leaves publication blocked.

D. Add a native npm override scoped to `micromark-extension-math@3.1.0`, selecting exact KaTeX 0.18.2. Refresh only the necessary workflow lock resolution, then verify real installation, imports, lint behavior and the security fix. This crosses the parent's declared range explicitly; it is not claimed semver-compatible. It leaves the current parent algorithms and repository commands intact. One short maintenance paragraph records reason and removal conditions.

Version variants within D were checked: 0.18.3/0.18.4 add renderer parsing fixes; 0.18.5 onward changes commander to ^15, and 0.18.11/0.19.0 changes strict warnings/errors. The first fixed 0.18.2 retains commander ^8.3.0 and the same import/export entry contract as the current KaTeX. It contains the exact own-property fix. Additional renderer fixes have no demonstrated benefit to this syntax-only consumer, so 0.18.2 is the bounded target, subject to current audit and compatibility checks. The 0.17 internal function API and 0.18 CSS-class changes still require acknowledging the range crossing; this repository does not call that internal API or style KaTeX output. [0.18.2 changelog](https://raw.githubusercontent.com/KaTeX/KaTeX/v0.18.2/CHANGELOG.md), [current changelog](https://raw.githubusercontent.com/KaTeX/KaTeX/v0.19.0/CHANGELOG.md).

E. Override all KaTeX consumers in the workflow root to 0.18.2. Today it reaches the same node, but it silently governs future unrelated parents. It lacks D's parent-version boundary. An additional outer `markdownlint@0.41.1` wrapper would narrow the already single known parent path further without changing the current resolved node; it is a viable D spelling, but adds a second maintenance coupling without a current safety benefit. D already stops applying when the owning math version changes, requiring ordinary audit/installation review.

F. Use D's narrow scope but select current latest KaTeX 0.19.0 (or the later 0.18 line). This also fixes the advisory but adds commander and renderer behavior changes. Newest is not a demonstrated correctness improvement for this non-rendering caller.

G. Maintain a private backport/fork of KaTeX or the math package. This can fix behavior but adds ownership, integrity/distribution and update obligations. A fork retaining an affected upstream version also complicates truthful audit disposition. Untracked node_modules edits or install-time patch scripts are unacceptable substitutes for locked registry inputs.

H. Remove the unused renderer through an upstream or independently maintained syntax-only math package. This attacks the dependency cause, but the current package's public entry eagerly reexports HTML. Simply deleting KaTeX breaks module loading. No compatible maintained replacement was established. A local fork becomes G; a supported future upstream split becomes C.

I. Replace markdownlint or rewrite its math tokenization integration. This can remove the graph but puts outer, staged and nested lint semantics at risk. Existing parser/file-discovery policy must remain intact. It is disproportionate to the available upstream fixed package.

J. Admit a precisely scoped, expiring risk exception based on the limited call path, combined with upstream deferral. This must retain the advisory's truth, exact roots/nodes/version/identity bounds, owner, controls and expiry. Current policy requires accepted-base authority and independent review; candidate exceptions cannot authorize themselves, and the documented proposal path has no exceptional merge route around its failing check. No such authority or route is supplied here. Applicability analysis alone cannot be relabeled a clean audit.

K. Remove or disable lint/dependency audit coverage. This loses an existing contributor/security contract and fails the hard constraints even if fewer packages are installed.

L. Add runtime prototype clearing, an options wrapper or HTML sanitation without upgrading. There is no demonstrated rendering caller to wrap or sanitize; global prototype mutation can damage other tooling. It does not remove the affected locked package or satisfy the current ordinary audit. If combined with J, it inherits J's unresolved authority; if combined with D, it is unsupported extra scope.

These options cover no change, smaller/native controls, compatible and out-of-range repair, removal/replacement, factoring, exception and deferral. Combinations with D that preserve upstream follow-up and document removal criteria are part of D; they do not create a second audit-exception mechanism.

## 4. Finding-specific rubric and constraints

Score each dimension from 0 to 10: 0 cannot meet the need, 5 requires substantial unresolved controls, 10 has strong bounded support. Totals are weighted scores out of 100. These are comparative engineering judgments before implementation, not test results.

- S, 30%: truthful security resolution. Remove the affected runtime package, preserve audit authority, and do not claim unreachable means uninstalled.
- F, 25%: lint fidelity and testability. Preserve actual outer/staged/nested and math-token behavior with meaningful negative controls; avoid a broad parser replacement.
- R, 20%: reproducible supply and recovery. Native locked registry installation, exact identities, qualified archives and a clear reversal path.
- U, 15%: contributor/operator usability. Existing commands, cross-platform behavior, finite failure diagnostics and a repair available now without manual waivers.
- M, 10%: continuing maintenance cost. Narrow ownership, review burden and removable configuration. Churn is subordinate to the first four dimensions.

Hard constraints: no audit or lint bypass; no candidate self-approval of risk; registry integrity and exact runtime policy remain enforced; no silent lock/manifest mismatch; preserve R1 code/evidence and independent TF contract/generated outputs; only root-released paths and actions may change. Feasible means a route available for implementation now, not that it has already passed tests.

## 5. Scores before selection

| Option | S | F | R | U | M | Total | Current feasibility / key uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A: keep/retry | 1 | 10 | 9 | 2 | 10 | 59.0 | Fails current security gate |
| B: compatible lock refresh | 1 | 9 | 9 | 3 | 9 | 57.0 | No fixed version in range |
| C: wait for parent | 7 | 10 | 9 | 1 | 8 | 73.5 | No released fixed parent today |
| D: exact parent-version override | 10 | 9 | 10 | 10 | 9 | 96.5 | Available; real cross-range compatibility still to prove |
| E: global workflow override | 10 | 8 | 8 | 9 | 9 | 88.5 | Available; affects future unrelated parents |
| F: latest KaTeX override | 10 | 7 | 8 | 9 | 8 | 85.0 | Available; extra dependency/behavior changes |
| G: maintained private fork | 8 | 7 | 5 | 5 | 3 | 62.0 | No qualified fork established |
| H: syntax-only replacement | 9 | 6 | 6 | 5 | 4 | 65.5 | No compatible maintained replacement established |
| I: replace lint engine | 9 | 3 | 7 | 3 | 3 | 56.0 | Semantics replacement not justified/proved |
| J: temporary exception + wait | 5 | 10 | 5 | 3 | 6 | 60.5 | Missing authority and safe admission route |
| K: disable coverage | 5 | 0 | 7 | 1 | 6 | 36.5 | Violates hard constraints |
| L: operational workaround | 3 | 5 | 5 | 3 | 3 | 39.0 | Does not fix package/audit; unsupported caller change |

The totals were independently recomputed by the scratch evidence builder. D leads the next currently implementable option by 8 points. It uses npm's documented mechanism, preserves the existing lint algorithm and does not require weakening a manifest validator. Its selection remains conditional on actual clean installation, behavioral compatibility and current audit results. A failure must return to this record; it cannot be covered by score arithmetic.

## 6. Selected implementation

Use short direct instructions as a controlled-English implementation specification. No formal dictionary compliance is claimed.

1. Preserve the committed H2 and all R1 evidence.
2. Add `"overrides": { "micromark-extension-math@3.1.0": { "katex": "0.18.2" } }` to `.github/workflows/package.json`.
3. Use the exact reviewed Node 24.18.1 and npm 11.16.0 pair.
4. Generate `.github/workflows/package-lock.json` with npm in an isolated scratch candidate. Disable lifecycle scripts and use the official registry. Keep the input manifest fixed during lock generation.
5. Review the complete lock delta. Require only the selected KaTeX node/version/archive/integrity and necessary npm lock metadata to change. Stop if another dependency changes without an explained need.
6. Copy only the reviewed manifest and lock into the released worktree paths. Keep both outer package files unchanged.
7. Add one paragraph to `docs/dependency-maintenance.md`. State the advisory, exact parent/version scope, tested range crossing and removal condition. Remove the override only after a reviewed parent release supplies a fixed KaTeX range and the same validation passes. Use the genuine UTC date for any existing metadata field that policy requires.
8. Do not change production validators, workflow rules, risk exceptions, runtime pins, guide/instruction files or R1 SelfTest bytes.
9. Rebuild and qualify the workflow dependency archive. Preserve the old archive and its evidence.
10. Stop and report new material evidence before expanding the change.

## 7. Post-release verification and paired obligations

Proposed checks below have NOT executed. They use actual installed dependencies in disposable candidates, not the live worktree index or native configuration.

- Run the existing `NpmTools.withNpmEnvironment` helper with `runNpm(['ci','--ignore-scripts','--no-audit','--fund=false','--include=dev','--package-lock=true'], workflowRoot)` in a scratch candidate. Then run actual `npm ls --all --json --include=dev --package-lock=false` through the same sanitized helper. Check native exits, installed and locked version/integrity, exact parent association and no duplicate vulnerable node. Check all four input byte hashes after each operation. This uses existing code but avoids the bootstrap hook-install side effect in a shared checkout.
- Use an isolated scratch-only security probe against saved old 0.16.27 and freshly installed 0.18.2. Give each process a disposable local options prototype with inherited `trust: true`, plus default-untrusted and own `trust: false` controls. Render only a local test string and inspect output; do not execute HTML or contact a remote service. Require old behavior to expose the inherited-trust gadget and patched behavior to refuse that inherited trust. Also preserve an explicit own-trust positive control. This establishes the specific upstream fix, not full absence of all prototype issues.
- Run actual CJS and ESM imports for markdownlint and the math entry, plus inline/display math token cases and ordinary/nested Markdown cases through the existing lint callers. Compare rule IDs/line positions for representative clean and invalid inputs to the old graph. Require clean cases to pass and existing invalid cases to fail. Do not treat HTML styling as a repository consumer.
- Run `node --test .github/workflows/lint-markdown.test.mjs .github/workflows/NpmTools.test.mjs .github/workflows/Validate-WorkflowPolicy.test.mjs` with the qualified Node executable. These cover actual outer/staged/nested caller behavior, install input protection, and manifest/lock admission. Keep raw results and input hashes. Add no production tests merely to mirror an override literal; a newly discovered persistent behavior gap needs separate justification.
- Root runs the ordinary two-root audit using the real accepted-base authority, and later the required aggregate, whole-PR metadata endpoints, clean commit and ordinary hosted gates. No severity suppression, omit-dev or retry-to-hide behavior is permitted. A fresh clean audit is still a dated observation.
- Run the focused imports/lint/security checks on Windows and the retained Linux image after a new dependency archive is qualified. Existing Node/npm/PowerShell runtime pins need no change on current evidence; 0.18.2 declares no new engine requirement and retains commander ^8.3.0. Existing archive/catalog contents do change, so the old 1910-file qualification cannot be claimed for the new graph. Record the new file inventory, hashes, archive digest, installed graph and source-after guards. Root owns final aggregate/review publication.

The source PS M98177628b7bc02c646724bfc8aa0fd73fed0cd24 has the same affected tuple. This is a common dependency repair, not a Terraform language exception. After TF acceptance, the PS obligation includes the same override, corresponding lock resolution and maintenance explanation, preserving its repository descriptors. Root owns A07's prospective TF increment 4->5 and later PS 6, actual release and native acceptance. R1's separate SelfTest reverse port remains required with the exact T1/P1 provenance path exception. Existing 25-row A06 candidate comparisons remain historical valid; this dependency decision does not relabel them as a final accepted-main or full-union comparison.

Remaining authority: root display/selection and explicit implementation release for the proposed three paths and scratch dependency preparation. Remaining proof: every post-release check above, refreshed archive qualification, current audit, final aggregate and ordinary acceptance/reviews. New-harness/A03/A06/A21/R5/recovery/human gates remain owned by root and are not satisfied by this proposal.

Root release: A07 changes destination from accepted PS233 to TF68, so its transfer count advances from4/12 to5/12 before implementation. A06/A03/A21 remain1/3/5of12. TF68 remains round1/80 with deadline2026-10-13T23:47:31Z. Root owns index, commits, native publication, reviews, counters and final validation. The writer owns only the three selected product paths and isolated scratch dependency/test preparation. Preserve every R1 source byte outside the selected paths.
