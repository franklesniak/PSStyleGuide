<!-- markdownlint-disable MD013 -->
# R21 selected repair: validate the selected root manifest before reading

Status: selected by root on 2026-10-05 after the full ordered process; private implementation released. Product integration and acceptance remain pending. Owner A07. Exact source H `db54d687b105e548117c1e8a60ba155fab1a376f`, tree `5fbf0601b7da43ae6872fa23a89e60cc5cd01197`, actual accepted B `06ad4f7c9b6847028cafdacf1ae55128d0f2d56c`. Raw source blobs/SHA256 are in `source-identities.json`. The observations below precede solution edits; the author now owns the released private repair.

## Validation and existing authority

[Authenticated Codex comment4180361504](https://github.com/franklesniak/TerraformStyleGuide/pull/66#discussion_r4180361504) is valid. `lintMarkdownFiles` reads root `package.json` at line11 before it establishes file type or canonical containment. A real escaping manifest symlink supplies the external `engines.node` value. The existing child guard subsequently succeeds and the actual bounded native child runs. This is static input-boundary failure, without a competing writer. It does not demonstrate execution of an external child: that separate R2 boundary remains active.

`probe-manifest.mjs` imports exact unchanged adapter/NpmTools blobs. Every child only prints a private marker and exits0. Eight native cases ran on Windows Node24.18.1 and the existing network-disabled Linux image8bdc/Node24.18.1. Ordinary manifest, escaping leaf, contained leaf and ordinary manifest through an aliased root each returned0 and executed the benign child. Broken link and directory errored; ordinary wrong-version and external wrong-version manifests retained the version mismatch error. Thus the external manifest really influences the gate; rejection is not missing for every malformed input. `manifest-win32.json`, `manifest-linux-command.json` and Linux log record the actual paths/outcomes. Four marker executions appeared on each platform. The Windows command used the existing pinned node.exe and the private script/output paths; Linux's exact Docker command is in its receipt. No skip occurred.

`probe-large-manifest.mjs` separately supplied valid JSON padded to 1,048,577 bytes. The current Windows adapter ran its benign child and returned0. This proves absence of a one-MiB adapter ceiling, not memory exhaustion. Existing `NpmTools.mjs:40–45` uses a one-MiB ordinary-file default for package inputs. That convention supports a finite static manifest bound without inventing a new arbitrary cap.

[R2 B97.6](TF66-R2-child-boundary.md) establishes the useful child leaf/type/canonical pattern and retained limits; it did not implement the manifest boundary. [A14](../A14/RESULT.md) concerns other generator/verifier consumers and hostile-writer residuals. Neither is a duplicate disposition of this current unchecked read. Preserve hardlink, path-substitution, same-user code and TOCTOU limits. A path precheck is not a security sandbox or a universal identity guarantee.

Current consumers remain workflow-package `lint:md`, root delegation, Husky's outer phase and Invoke-MarkdownLint's outer phase. The exported adapter accepts an explicit filesystem root; replacing this with a Git-index-only API would change that supported behavior. The current module still imports its own trusted NpmTools dependency; this proposal is not a general import loader.

## Stakeholders and options

Documentation contributors and agent operators need the declared runtime to come from their selected repository and ordinary linked workspaces to keep working. Security and privacy owners need static external-input refusal with truthful residuals. Windows junction users and Linux CI users need native path semantics. Dependency maintainers need the exact version gate and existing finite-file convention. QA/independent reviewers need real native-child discrimination rather than a success stub. Incident/UX owners need recognizable tooling errors and a repairable local path. CI/cost owners need bounded reads and unchanged child limits. There is no new publication, cloud, credential, accessibility interface or Terraform-state operation; those roles do not gain authority or a new workflow.

Options were sent before the rubric; each can retain current output/exit behavior unless its description says otherwise.

| ID | Option and material tradeoff |
| --- | --- |
| N | Keep the read and document trusted-root assumptions; lowest change, leaves the demonstrated static boundary failure. |
| L | Reject symbolic/nonregular manifest leaves only; closes current leaf witness, omits explicit canonical boundary and finite read. |
| C | Resolve canonical containment only; allows contained symbolic manifest leaves and changes the ordinary-file policy interpretation. |
| B | Combine non-symlink regular leaf and canonical containment, retaining current unlimited regular-file size. |
| E | B plus the existing one-MiB package-reader convention before reading; consume canonical manifest path. |
| H | Factor a shared contained, bounded reader and use it here; useful reuse but expands helper/API consumers and test obligations beyond this adapter. |
| F | Open a descriptor with no-follow/fstat and canonical checks; can reduce a leaf substitution window but adds platform/runtime handling and does not supply handle-relative ancestor confinement. |
| G | Read tracked Git manifest bytes instead of selected working-file bytes; changes API semantics and adds Git/index dependencies. |
| X | Remove/defer the runtime gate and rely on downstream checks; eliminates this read but loses its independent exact declaration check. |

E is the meaningful B+bound combination. H can include E's checks and is scored that way. F also includes a finite bound; it is not penalized merely for more lines. Adding documentation to N does not close the failure. A broader filesystem redesign combines independent residual work and is deferred unless its supported threat model changes.

## Rubric, scores and recommendation

Scores are reasoned comparisons, not empirical security measurements. Each criterion uses 0–5: 0 defeats the objective; 3 gives partial or conditional support with a material limitation; 5 fully addresses this scoped criterion with clear limits. Intermediate values distinguish genuine tradeoffs.

| Criterion | Weight | Finding-specific assessment |
| --- | ---: | --- |
| T | 34 | Manifest trust, ordinary leaf/type and finite static input refusal before consumption. |
| R | 20 | Preserve exact declared runtime, bounded child invocation and 0/1/2 error contract. |
| U | 18 | Preserve ordinary Windows/Linux files and legitimate canonical root aliases. |
| D | 14 | Actionable refusal and recovery without silently trusting external bytes. |
| V | 9 | Meaningful native negative/positive discrimination and bounded testability. |
| M | 5 | Maintenance and implementation burden, weighted below correctness/usability. |

Hard constraints: refuse static escaping/nonregular symbolic leaf inputs; retain the exact version gate and child/output contract; retain ordinary-root and alias use; no platform-only bypass or confinement overclaim. N, C and X cannot win while violating those constraints. A finite bound is a scored improvement rather than a retroactive claim that this adapter already enforced it.

| Option | T | R | U | D | V | M | Weighted /100 |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 0.5 | 5 | 4 | 2 | 2 | 5 | 52 |
| L | 3.5 | 5 | 5 | 4 | 4 | 5 | 85.2 |
| C | 3 | 5 | 4.5 | 4 | 4 | 5 | 80 |
| B | 4.3 | 5 | 5 | 5 | 4.5 | 5 | 94.34 |
| E | 5 | 5 | 5 | 5 | 4.5 | 4.5 | 98.6 |
| H | 5 | 5 | 5 | 5 | 4 | 3.5 | 96.7 |
| F | 4.7 | 5 | 3.5 | 4 | 3.5 | 2.5 | 84.56 |
| G | 4 | 3 | 2.5 | 3 | 3 | 2.5 | 64.5 |
| X | 1 | 0 | 3 | 2 | 2 | 5 | 31.8 |

Arithmetic is `sum(score * weight / 5)` and checked in `scores.json`. Root selects **E98.6**. B fixes the specific static escape but leaves an unnecessary unbounded regular input. H offers equivalent safety, but its additional consumers/interface require more independent regression work without a demonstrated second unmet contained-reader consumer. F's narrow race benefit does not remove ancestor races, and its portable failure behavior remains additional work. These uncertainties affect assurance/usability, not just churn.

Selected controlled-English steps (not a claim of formal ASD-STE100 dictionary certification):

1. Resolve the selected repository root to its canonical path.
2. Inspect the manifest leaf before you read it.
3. Reject a symbolic link or a nonregular file.
4. Reject a manifest larger than 1,048,576 bytes.
5. Resolve the manifest to its canonical path.
6. Reject a canonical path outside the canonical repository root.
7. Read the canonical manifest path.
8. Keep the exact Node version check.
9. Keep the child path checks, limits, output and status rules.
10. Report a refused manifest as a tooling failure through the existing CLI boundary.

Proposed surface: `.github/workflows/lint-markdown.mjs` and its existing `.test.mjs` only. Reuse canonicalRoot for the child guard. No guide, protected file, dependency or helper export change is required. Neither file has governed document metadata. Root still owns actual finalization consequences for the whole candidate and later PS reverse convergence.

Meaningful verification after selection: real escaping/contained leaf links and a directory never execute the child; ordinary and aliased roots execute it; missing/broken/malformed/wrong-version manifests retain useful tooling failures; exact one-MiB and plus-one inputs distinguish the size guard; native CLI exits2 on refusal. Retain existing child-escape and native-output/limit tests, without replaying unrelated suites. Windows/Linux native controls must name their actual runtime; do not infer race closure or unread-file telemetry merely from no child execution.

Primary references: [Node24.18.1 lstatSync](https://nodejs.org/download/release/v24.18.1/docs/api/fs.html#fslstatsyncpath-options), [realpathSync](https://nodejs.org/download/release/v24.18.1/docs/api/fs.html#fsrealpathsyncpath-options), [readFileSync](https://nodejs.org/download/release/v24.18.1/docs/api/fs.html#fsreadfilesyncpath-options), and [file-open constants](https://nodejs.org/download/release/v24.18.1/docs/api/fs.html#file-open-constants). lstat inspects the link itself; realpath resolves links and lexical components. A canonical pathname is not proof that two names cannot designate the same file. No full suite/aggregate ran for this proposal.

## Root selection and evidence boundary

Root read the complete proposal and current production consumers, checked all17 score totals, sampled source and failure-log hashes, and checked the linked primary documentation. The ordered validation, options, distinct rubric, complete score table and controlled-English selection were displayed before implementation release. Private proposal SHA256 fdee22f085ad1416d1bab6eec8d71ab3d037a3989c96397b2276c0551526286d. Evidence remains in `PSStyleGuide-TF-coherent-20261004/implementation/round6-review-findings` under the STATUS scratch prefix. The author may change only the selected three-file union in a new private repair. Product, index, dependencies, native state and counters stay unchanged until root integration. Focused tests, independent repair quality, one final-byte aggregate, actual endpoint checks and a fresh native review round remain required. No additional user permission is needed for this scoped repair.

## Implemented private repair and focused verification

The selected three-file union is frozen against Hdb54. Source catalog95ff2043d5fd9a8d6b4be85f5eb29200710d772d6432ec7236c9410f8dfa42c9 and patch03bb7cb408d830b90f78c30b6894dbc0bf508fea811b0f838238ecd5378c0c95 bind the exact postimages. Both platforms pass23 selected native Node tests with zero skips; original code fails the three new link/size refusal controls. The complete affected lifecycle body passes on repaired helpers on both platforms and rejects original helpers at the demonstrated extra-field gap. Actual Windows validator CLI accepts headed/direct forms and rejects a second lifecycle field with the intended error. One private negative-case collector assertion failed on wrapped presentation; its log is retained and only that negative reran after normalization. Both changed helpers have zero analyzer Error/Warning diagnostics. No full aggregate ran.

Independent bounded repair quality passed at2026-10-05T03:33:18Z; report SHA256eb6004f9106fbdb67988fea0d9f4c8b2b4ddb621ab6a3c6ebdab0ca7d7164d3d, evidenceab6247b156d1bfc1673737574eb805f3ec533a7e751c3467926cf9c254f1dba8. Root read the complete final report and source diff and sampled actual result hashes. All78 published product files and1910 dependencies remain unchanged. Whole-candidate aggregate, actual commit/endpoints, fresh native reviews and paired acceptance remain required; the [canonical peer record](../A02/coherent-peer-candidate.json) owns their subsequent state.
