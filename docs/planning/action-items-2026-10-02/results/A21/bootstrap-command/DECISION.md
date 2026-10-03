<!-- markdownlint-disable MD013 -->
# D-A21-03: one canonical Python bootstrap command

## 1. Validate

The coupled-setup preparation proposed inserting TF's bare install commands into the PS script index. This is a material documentation and future predicate mismatch. A07 candidate tree `d7c55edd5332a00c10bb98a2094b06a8fe8bb817` already specifies `py -3.12 -m pip --isolated install --require-hashes --only-binary=:all: --index-url https://pypi.org/simple -r requirements-dev.txt` in docs/dependency-maintenance.md:53 and substitutes `python3.12` on Linux. Its script index links that procedure. TF06ad's Get-PreCommitBootstrapContractFailure instead requires the exact bare `py -3.12 -m pip install --requirement requirements-dev.txt` and POSIX equivalent, each once as operative Markdown code. It tests AGENTS, CLAUDE and scripts-README with ordinal equality. TF's script index documents those bare forms. Substituting the A07 command alone would therefore fail that old predicate. Preserving the bare spellings is not required by D-A21-01's useful bootstrap contract.

The proposed paragraph would offer a second install procedure with different pip configuration behavior. The bounded [offline probe](probe.py), using Python3.12.10 and pip25.0.1, invokes pip's install argument parser only. It substitutes one scratch user configuration and empty global/site search lists. It clears inherited PIP variables before injecting synthetic `.invalid` indices. It performs no network operation or installation. [Results](probe-result.json): bare form uses the user index/extra index; injected environment values override those; the A07 form suppresses those settings and selects its explicit PyPI URL with no extra index in this controlled fixture. The requirements-line parser confirms both `--require-hashes` and `--only-binary=:all:` are recognized from the lock preamble. The initial bare command's parser fields are false/empty before requirements processing; those fields are not evidence that the complete install disables the lock's controls.

This is an environment/configuration/index divergence, not a demonstrated package-hash bypass. Both paths retain the requirements file's hash and binary directives. Local primary source is recorded with hashes in probe-result.json: pip/_internal/cli/main.py passes isolated mode to command creation; configuration.py:125 omits environment loading in isolated mode, :344 omits user configuration, but still enumerates global/site and explicit PIP_CONFIG_FILE sources; req/req_file.py registers and applies lock directives. Thus A07's command is not fully hermetic and explicit primary index does not prove all global/site extra-index sources impossible. No stronger guarantee or redesign of A07 is selected. Probe scope is local pip25.0.1; no claim of all-version empirical testing.

The original RESULT.md (`b90cecaacf1804f38052a770fc609bb51b0c3f747d77f7ab92f5a25332295c0f`) and insertion draft (`4d62b464e4a1c3d92fa2832d16199dffe16a7204eda619f871d854f3038565f2`) remain unchanged as history. This record supersedes only their bare install recommendation and corresponding exact-string test plan. No frozen product has been edited.

## 2. Stakeholders

Windows/Linux contributors and agents need one usable setup procedure. Dependency maintainers and supply-chain reviewers need explicit distinction between source selection, hash enforcement and installed-byte attestation. Both repository maintainers need common meaningful checks without preserving an obsolete spelling that rejects the canonical setup. Documentation readers need the script index and dependency guide to agree. The owner and policy reviewers need protected commands to change only with A20 authority. Independent reviewers and CI operators need discriminating exact-command tests and bounded evidence, without restarting A07's aggregate. Cost/schedule stakeholders need this repaired before product activation. No cloud/backend operation, recovery command, personal data, localization or accessibility interface is changed; privacy impact is limited to avoiding ambient pip settings and this probe reads no real user credentials/configuration.

## 3. Options

- N: Retain the original bare paragraph and old exact predicate. Lowest edit cost; preserves the reproduced divergent setup path.
- R: Remove bootstrap command checks entirely and rely on the requirements lock. Keeps hashes, loses interpreter/preflight/run-command/documentation guarantees.
- S: Require only Python3.12 and the lock filename, ignoring install flags and source controls. A smaller control, but permits the actual divergence.
- C: Reuse A07's finite canonical install command. Use only the existing Windows `py -3.12` / POSIX `python3.12` prefixes. Update the nonprotected script index and future common exact predicate/tests together. Keep preflight and run commands. Preserve the protected activation hold.
- H: Add a new hermetic installer wrapper that clears/configures every pip input, and document only that wrapper. A native pip-based stronger control, but a new behavior/file beyond this mismatch and beyond unchanged A07 bytes.
- G: Build a semantic command parser or configurable installation-command framework. Could accept equivalent forms, but substantially enlarges grammar, equivalence and configuration ownership.
- A: Accept both bare and isolated forms as alternatives. Reduces immediate failures, retains two distinct setup paths as permanently acceptable.
- X: Exempt the PS script index or specialize the predicate by repository. Defeats common command convergence and becomes an implicit profile.
- L: Keep only a script-index link to dependency-maintenance and check the link. Small documentation delta; the link alone does not validate the actual command and relocating the full predicate adds a new consumer rather than retaining the selected operative-span surface.
- D: Defer all setup integration until A20. Avoids premature protected text changes but unnecessarily blocks independent nonprotected integration and leaves this proposal unresolved.

Combining the existing lock grammar checks with C is C, not a second option. A temporary protected activation hold is part of C and does not authorize A/X. Native pip is reused by C/H; no additional package/tool is needed. Stronger global/site configuration isolation would require separate evidence/decision and is not an inferred prerequisite for C.

## 4. Fresh rubric and hard constraints

Scores are engineering judgments, not measured probabilities or benchmark results. Scale0â€“5: 0 absent;1 weak;2 material gaps;3 workable with significant limits;4 strong with bounded limits;5 directly meets the criterion. Weighted total=sum(weight*score)/5.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Configuration correctness | 30 | Eliminate the demonstrated divergent recommendation and describe hash/config limits truthfully. |
| Actual caller and user consistency | 25 | Match the documented A07 setup and both platform entrypoints without ambiguous paths. |
| Discriminating verification | 20 | Keep finite meaningful near-miss and operative-document controls without claiming unrun installation tests. |
| Authority and maintainability | 15 | Keep one common design and explicit protected holds without new profiles or concealed exceptions. |
| Churn and validation cost | 10 | Keep changes small and avoid disturbing A07, new tools, parsers or expensive suites. |

Hard constraints: retain complete PS base and D-A21-02 context/loader; preserve locked hash/binary requirements, Python3.12, PowerShell7 and pre-commit checks; no product edits in this scratch assignment; no protected text/check weakening, TF writes, A03 choice, policy grant, package install, global config write or A07 aggregate change. Common algorithm/test equality remains the final target. Scores cannot waive these constraints.

## 5. Scores before selection

| Option | Correctness30 | Callers25 | Verification20 | Authority15 | Cost10 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 2 | 1 | 2 | 3 | 5 | 44 |
| R | 2 | 2 | 1 | 4 | 5 | 48 |
| S | 3 | 2 | 2 | 4 | 4 | 56 |
| C | 5 | 5 | 4 | 5 | 4 | 94 |
| H | 5 | 4 | 4 | 4 | 1 | 80 |
| G | 4 | 4 | 3 | 3 | 1 | 67 |
| A | 3 | 3 | 3 | 3 | 4 | 62 |
| X | 2 | 2 | 2 | 2 | 4 | 44 |
| L | 4 | 3 | 2 | 4 | 4 | 67 |
| D | 2 | 2 | 2 | 5 | 3 | 51 |

[Arithmetic check](score-check.json) computes every product and total. C=(150+125+80+75+40)/5=94. H=(150+100+80+60+10)/5=80. C's verification score is4 because implementation and actual loader tests are still pending; no score certifies unrun tests. R/S sacrifice useful contract checks. A/X retain divergent behavior and fail common-design constraints. H/G add unneeded behavior/architecture. N leaves the validated mismatch. L is a reasonable smaller documentation approach but lacks the finite command guarantee. D mistakes a protected hold for a dependency of all nonprotected work.

## 6. Selected solution

Select C. Use A07's install command as the single canonical command body. Keep its exact argument order. Use `py -3.12` on Windows. Use `python3.12` on Linux. Keep the PowerShell7 preflight and both pre-commit run commands. Insert one operative span for each command in the nonprotected script index. Link to the existing dependency procedure without recommending a second installation path.

Adapt the future common bootstrap predicate to these finite literals. Do not parse arbitrary shell commands. Do not accept the bare form as an alternative. Do not add repository profiles. Test the positive script index with the real operative Markdown parser. Test removal of isolated mode, replacement of the index URL, interpreter downgrade, removed explicit binary/hash flags, wrong requirements path, duplicate spans, hidden spans and changed run/preflight commands. Exact-command rejection of a missing explicit hash flag is a documented command-contract check; requirements-level hash enforcement remains separately tested and must not be mislabeled as broken by that near miss.

Activate only the nonprotected script-index check in the released PS setup slice. Keep the accepted PS protected checks intact. Do not demand new command wording in PS AGENTS/CLAUDE yet. Do not remove the old accepted TF protected command checks during peer work without A20 disposition. Protected bootstrap wording and its common predicate activation must converge atomically under that actual authority. This is the existing explicit convergence hold, not a silent skip or accepted permanent difference. D-A21-01 remains selected once; A03, exact initializer, staged/data-only/B-H/provenance and source-order boundaries are unchanged.

## 7. Implementation and verification

Decision and all ten score totals are completed before changing the scratch proposal. Product implementation remains unreleased. Next, publish a corrected scratch insertion and concise reconciliation note that link to this record. Preserve the original preparation and draft. Verify the corrected draft has exactly five intended operative spans, matches the A07 install command body, contains no bare install recommendation, and does not change any frozen product identity. Root will review this scope before candidate-ready coordinated release. A07 full native completion is not an implementation prerequisite: after its sole aggregate, normal commit/B-H and independent local quality pass, root may integrate that exact reviewed candidate locally and release the atomic four-path slice while remote review/CI run. Candidate provenance remains explicit and grants no accepted-policy or merge authority. Final A21 freeze/aggregate/endpoints/native gates follow actual accepted A07 main integration and changed-input reassessment. Future product tests must use actual selected PS predicates and loader; this scratch probe is not their substitute.

Scratch correction is now published as scripts-README-insertion-corrected.md. Readback verifies exactly the five intended spans; the Windows install literal exactly matches A07 dependency-maintenance and the POSIX literal changes only the interpreter prefix. No bare recommendation remains. Original note/draft hashes and all five frozen product hashes are unchanged. The bounded parser probe passed all assertions and is saved with source hashes. No product, index, ref, protected text, peer file, package installation or network state changed. Candidate-ready implementation release and final accepted-source verification are separate gates; current products remain frozen pending explicit root release.

The corrected preparation also applies the existing A02 metadata finalization rules to the later substantive scripts-README edit. Do not preserve metadata solely because its date is already October 3. Reconcile the actual accepted A07 baseline and final UTC date through B/H validation, with a same-day revision increment where applicable. This is mechanical reuse of accepted policy, not another finding or guide audit.
