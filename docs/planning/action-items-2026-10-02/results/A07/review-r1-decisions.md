<!-- markdownlint-disable MD013 -->

# A07 PR227 round 1 repair decisions

Input: PS HEAD da2f1179b3764d221e7bac588ce2fb54554ecbc0, tree d7c55edd5332a00c10bb98a2094b06a8fe8bb817. Product is clean before repair. Root owns canonical planning publication and review lifecycle. These decisions preceded their corresponding product edits. This is their canonical planning publication; named evidence files are in scratch `PSStyleGuide-A07-reconcile-20261003/implementation/review-r1`. D-A21-01 is recorded in [the selected whole-base decision](../A21/selection-20261003/DECISION.md).

## Finding 4172644649: classifier admission gap

Confirmed: the actual classifier returns ordinary for launcher-only and requirements-only changes (p1-original-classification.log). These are executable trust roots, so this is the same material finding and selected design as D-A21-01. Reuse that canonical disposition. The later unmerged A21 candidate cannot close A07's admission gap at A07 merge. Copy the entire reviewed frozen A21 classifier and test pair unchanged. Source SHA256 values are 99327c4c73610ba42057b6cfa94c5d2178d991b1741e194733ccfcbac8524fb7 and 980257c408ee4dee430d7fb6e144ff7cb9d8c1dc90565071d99054479304d311. p1-inputs.json verifies hashes, preserved accepted algorithm suffix, and preserved PR226 test prefix. The conservative six-selector closure includes the two new Python paths. This requires no new policy, algorithm, validator-base choice or exception. Focused tests will run after copying.

## Finding 4172644651: Ubuntu installation instructions

### 1. Validate

On Ubuntu24.04 with python3.12 installed, the current Linux install command fails with `No module named pip` (exit1). Installing python3-pip changes the failure to `externally-managed-environment` (exit1). Logs preserve both original failures. Installing python3.12-venv, creating and activating a Python3.12 .venv, and running the unchanged canonical pip body succeeds. pipcheck reports no broken requirements. The actual unchanged launcher succeeds on good JSON (0) and preserves a bad JSON failure (1). The activated .venv/bin/python3.12 is selected; system modules do not provide this installed closure. This is a supported setup defect, not a reason to bypass the system marker. The tested image is Ubuntu24.04 with Python3.12.3 and PowerShell7.5.0. Windows' existing py -3.12 path uses its selected global installation; this finding does not establish Windows active-venv selection.

### 2. Stakeholders

New Linux contributors and agents need runnable setup. Experienced contributors and Windows users need stable existing commands. Both repository maintainers, documentation authors, CI/platform engineers and independent reviewers need one finite setup contract. Python/pip/Ubuntu maintainers require preserving OS package ownership. Supply-chain/security owners require hash/binary enforcement without bypassing EXTERNALLY-MANAGED. Recovery operators need an actionable failure correction. Cost/schedule owners benefit from bounded checks. Generated-artifact, application/cloud/data/privacy/accessibility/localization consumers have no changed runtime, data handling or presentation interface; their needs do not alter this selection.

### 3. Options before scoring

N: Keep the current instructions. R: Remove Linux setup instructions. S: Add only a warning/link to Ubuntu documentation. V: Document the Linux3.12 venv prerequisite, creation and activation; preserve the canonical install body and unchanged launcher. U: Unify both platforms around venv commands and alter Windows launcher selection. B: Install pip in system Python or pass --break-system-packages. G: Introduce a configurable environment/bootstrap framework. D: Defer Linux repair to A21/A20. Native venv plus existing pip is V; a link plus operative steps is also V. Global marker removal is B. A targeted unsupported-Linux exception is R/S and leaves supported users without a runnable path.

Primary facts: [Ubuntu Python setup](https://documentation.ubuntu.com/ubuntu-for-developers/howto/python-setup/), [Ubuntu Python tutorial](https://documentation.ubuntu.com/ubuntu-for-developers/tutorials/python-use/), [Python3.12 venv](https://docs.python.org/3.12/library/venv.html), [Python Windows launcher](https://docs.python.org/3.12/using/windows.html), [externally managed environments](https://packaging.python.org/en/latest/specifications/externally-managed-environments/), [pip isolated mode](https://pip.pypa.io/en/stable/cli/pip/). Activation prepends the venv executable directory to PATH. venv includes pip through ensurepip by default. Explicit py version selection does not select an activated Windows venv. pip --isolated ignores environment variables/user configuration; it is not a claim of complete hermetic configuration.

### 4. Fresh rubric and constraints

Scores0–5:0 absent,1 weak,2 material gaps,3 workable with limits,4 strong bounded limits,5 meets directly. Weights: executable setup correctness35; OS/package safety25; actual caller and cross-platform consistency20; maintainability10; churn/cost10. Totals=sum(weight*score)/5, engineering judgments rather than measurements. Hard constraints: preserve Python3.12, hashes/binary-only/public-index finite install body, actual launcher isolation and allowlist, existing Windows setup, no system-marker bypass, protected/workflow changes or new dependency framework. No score waives these constraints.

### 5. Scores before selection

| Option | Correct35 | Safety25 | Caller20 | Maintain10 | Cost10 | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 0 | 3 | 1 | 3 | 5 | 35 | Reproduced failure remains |
| R | 1 | 4 | 1 | 3 | 4 | 45 | Removes useful supported setup |
| S | 2 | 5 | 2 | 4 | 5 | 65 | Reader must infer operative commands |
| V | 5 | 5 | 5 | 5 | 5 | 100 | Ubuntu prerequisite differs by distro |
| U | 5 | 5 | 4 | 3 | 2 | 86 | Unnecessary Windows contract changes |
| B | 3 | 0 | 2 | 2 | 4 | 41 | Violates OS safety constraint |
| G | 4 | 4 | 4 | 2 | 1 | 70 | Unneeded architecture and validation |
| D | 0 | 3 | 1 | 2 | 3 | 29 | Leaves supported current setup broken |

### 6. Selected solution

Select V. On Ubuntu24.04, install python3.12-venv. Create .venv with python3.12. Activate .venv in the current Linux shell. Run the unchanged canonical install body with python3.12. Run pre-commit with python3.12 in that shell. State that the launcher selects the activated Python3.12 interpreter. Retain Windows commands. Link the prerequisite to Ubuntu's official setup guidance. Keep D-A21-03's finite installation body. Tell root/A21 about the added setup facts. Do not change the launcher.

### 7. Implementation and verification

Caller completeness reassessment before the ignore edit: actual Ubuntu3.12.3 creates no .venv/.gitignore. With the current tracked ignore file, git check-ignore returns1 and ordinary status exposes .venv/. This includes installed dependency files that ordinary git add can select. V now includes exactly the common `.venv/` exclusion; all prior entries remain. Root released this one-line A02-owned shared path to A07. The existing option/rubric stays applicable. Compare V-in-repo+exclusion scores5/5/5/5/5=100 against external-venv V-outside scores5/5/4/4/4=92: outside setup is safe but requires a named per-repository external location, changes activation paths and increases setup/recovery coordination. These are judgments, not performance evidence. V-in-repo keeps the already-tested commands and a narrowly scoped native Git exclusion. No global ignore or broad generated-file pattern is used. The original no-change baseline remains preserved for A02's final paired obligation.

Docs now contain the selected operative setup. Original failures and selected actual Ubuntu install/launcher evidence are preserved. Exact ignore/status/add controls pass with global excludes disabled: generated .venv content is omitted; modified tracked.txt and untracked authored.py remain visible and are selected by add --all. The ordinary outer/nested Markdown checks both return0. Final five-path/all75-tracked raw hashes are frozen in frozen-inputs.json. GUIDE-IMPACT.md records the complete normative guides and no needed portable-guide change. This decision does not authorize a full aggregate or acceptance.

## Finding 4172655089: committed launcher behavior coverage

### 1. Validate

The new launcher has scratch five-control evidence but no repository behavioral tests. The existing candidate-tests Node caller includes Test-CiHelpers.test.mjs on every run. Its harness already tests actual PowerShell helper bodies with fixed external-tool replacements. A retained launcher regression suite is useful: allowlist, exact3.12, missing interpreter, flags and native status affect admission and local execution. Scratch-only tests do not protect future edits. No production defect is asserted beyond the missing maintained coverage.

### 2. Stakeholders

Both maintainers, contributors and agents need stable launcher failures. Security/supply-chain owners need regression detection at this interpreter boundary. Reviewers need tests that distinguish unsafe mutations. CI/platform engineers need portable bounded tests through the existing caller, without an extra interpreter/package installation. Python package maintainers need truthful claims distinguishing dispatch controls from actual Python isolation. Recovery/cost owners need native statuses and short deterministic tests. Other application/cloud/data/privacy/generated-artifact/localization roles receive no new product behavior or data flow and do not change this test choice.

### 3. Options before scoring

N: Keep scratch evidence only. R: Remove the launcher and its protection. S: Add source-text/smoke assertions. T: Add actual untouched launcher invocations in existing Test-CiHelpers.test.mjs using a fixed interpreter discovery/probe replacement that dispatches a real bounded Node child. Cover adversarial version outputs, missing discovery/module, unsupported module, native module failure, arguments and each -E-P dispatch. P: Add Python3.12/venv integration tests in that surface, requiring installation/caller changes. M: Put the same tests in NpmTools.test.mjs. G: Create a new suite/framework/caller. D: Defer tests to A21. T plus existing separate actual Python isolation checks is T; these tests make no installed-package attestation or full Python-isolation claim. No tests alter the production launcher or assert its source strings.

### 4. Fresh rubric and constraints

Scores use the same0–5 meaning, with fresh weights: behavioral discrimination35; security coverage30; actual caller/platform reliability20; maintainability10; churn/cost5. Hard constraints: one existing released test surface, untouched production launcher, existing CI caller, Windows/Linux execution without skips, no new framework/dependency, bounded children, preserve unrelated tests. Discovery replacement must be explicit and external-child behavior must remain real. Tests may not claim true Python isolation effects from a mock interpreter.

### 5. Scores before selection

| Option | Behavior35 | Security30 | Caller20 | Maintain10 | Cost5 | Total | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| N | 1 | 1 | 1 | 2 | 5 | 26 | No retained regression coverage |
| R | 0 | 0 | 2 | 1 | 3 | 13 | Removes selected protection |
| S | 1 | 1 | 5 | 2 | 5 | 42 | Can pass unsafe behavioral edits |
| T | 5 | 4 | 5 | 5 | 4 | 93 | Dispatch guarantees; Python effects separate |
| P | 5 | 5 | 2 | 3 | 1 | 80 | New runtime/setup contract outside scope |
| M | 5 | 4 | 5 | 3 | 4 | 89 | Less coherent ownership than CI helper suite |
| G | 5 | 4 | 3 | 2 | 1 | 76 | Unnecessary suite/caller/framework |
| D | 1 | 1 | 1 | 2 | 3 | 24 | No retained coverage at A07 merge |

### 6. Selected solution

Select T. Invoke the actual repository launcher in PowerShell child processes. Replace only application discovery with a deterministic interpreter probe. Dispatch probe commands to an actual Node child. Record argument arrays. Refuse missing -E or -P at every probe/module dispatch. Exercise unsupported Module before discovery, absent interpreter exit2, wrong/minor/patch/multiline/native-failed version outputs, module unavailable, successful argument forwarding, and native module exit7. Keep all existing tests. Run the new tests on Windows and Linux through the current Node caller. Test intended unsafe mutants separately. Retain existing actual Python evidence without labeling probe tests as installed-package or interpreter-isolation tests.

### 7. Implementation and verification

The one-test-surface edit is complete. Windows runs all102 classifier/CI-helper tests:16 pass and86 existing Linux-only tests skip; the four new launcher tests all run and pass. Linux runs the same102 tests with102 pass, no skip. All six intended unsafe mutants are killed on each platform: removed allowlist, disabled exact-version comparison, missing-interpreter exit0, removed -E, removed -P, and replaced native module exit with0. mutants/ stores each original failure and results. The full affected suite preserves the existing missing-runner-variable nonzero/zero-external-work checks after mechanical D-A02-05 diagnostic consumer reconciliation. Actual Linux Python install/isolation facts remain separate from the committed dispatch-probe guarantees. The production launcher hash remains9bc31918ba4407bf86a4d0d8e568962d05c157752a9df13e9bae2f081aa80e96. GUIDE-IMPACT.md records the complete normative guide assessment. No full aggregate or lifecycle acceptance is claimed.
