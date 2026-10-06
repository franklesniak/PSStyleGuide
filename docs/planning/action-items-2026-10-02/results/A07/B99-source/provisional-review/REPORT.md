<!-- markdownlint-disable MD013 -->
# B99 provisional source review

**Two material concerns require root disposition before final integration.** This is an early read-only review of the untested four-path delta on B981, not final quality or acceptance. No candidate, parser, analyzer, dependency module, test or native profile was executed.

## Findings

**P2 â€” The finite check does not prove that the exact B99 text defines an active hook.** In frozen `Test-AgentInstructions.ps1:686â€“701`, the regex scans all configuration text for a six-space `- id` line and compares that span with an exact block. It does not bind the span to a repository's parsed `hooks` sequence. A concrete counterexample is to insert `description: |` with four leading spaces immediately before the new B99 block at `.pre-commit-config.yaml:166`, leaving the block unchanged. YAML then makes the block scalar content of an unknown repository key. The preceding eleven hooks remain the actual hook list.

The precise proposed counterexample is a single inserted line; the existing final local group and its eleven actual hooks are otherwise unchanged. Its tail becomes:

```yaml
        language: system
        pass_filenames: false
        always_run: true
    description: |
      - id: no-tracked-compiled-python
        name: reject tracked compiled Python artifacts
        language: fail
        entry: >-
          Compiled Python artifacts must not be committed: bytecode (.pyc, .pyo,
          __pycache__) or extension modules (.pyd) are interpreter- and
          platform-specific. Remove the tracked artifact; .gitignore does not
          untrack files.
        files: '(?i)(^|/)__pycache__/|\.py[cod]$'
```

Source tracing shows why this evades the new admission: the root-mapping check at608â€“610 permits the indented line; the three repository rows remain; the preceding `agent-instruction-contract` body gains a line but its required-line checks at672â€“684 still hold; and the B99 exact-text match remains unchanged. The installed pinned pre-commit4.6.2 primary source, `clientlib.py:465â€“489`, recursively validates only `hooks` and uses `WarnAdditionalKeys` for extra repository keys. Its warning function at366â€“373 logs the unknown key. Thus the engine does not turn the scalar into a hook. This is a source-derived counterexample, not an executed native reproduction.

The added mutation tests inspect the same raw-text contract and do not contain this structural hiding case. Later D98's exact twelve-row check should catch a missing hook during the private final aggregate; it does not repair the product admission check. Root should resolve the new obligation to prove one actual B99 hook in the admitted local-group structure, with a targeted scalar-hiding mutation. A general YAML framework is not justified by this report. The selected native fail mechanism need not change for this finding.

**P2 â€” Selected filename-wide coverage exceeds the hook's default type applicability.** The exact selected hook at `.pre-commit-config.yaml:166â€“174` omits `types`. Pinned primary source sets its default to `['file']` (`clientlib.py:248`). `run.py:81â€“109` requires the identified tags to include every required type; `identify.py:40â€“50` returns only `{'symlink'}` for a symlink and `{'directory'}` for a directory. `run.py:168â€“180` returns a zero-status no-files skip when the resulting list is empty. Therefore, when present on a native filesystem, a tracked symlink named `module.pyc` or `pkg/__pycache__/entry` matches the filename regex but does not reach the fail hook. An existing gitlink checkout directory with a matching `.pyc` name has the same type-filter limitation. The hook uses filesystem applicability; no Git-mode-wide assurance follows from its regex alone.

This is inherited from the selected template, not an unauthorized implementation change. The canonical `results/A07/research-hook-applicability.md:30` defines Enforcement25 as “rejects force-added tracked matches”; line48 selects “case-insensitive filename rejection”; line50 says to reject `.pyc`, `.pyo`, `.pyd`, and files inside `__pycache__` directories. Lines78 and86 describe matching staged-file rejection and the finite hook contract. None states a regular-file-only exception. The bounded regular-file requirement at86 concerns reading `.gitignore` as policy data, not the scope of names rejected by B99. D98 `profile-preparation/README.md:7` separately requires an unfiltered tracked-name inventory and applies the pattern to every name, with zero matches for N/A. Those statements support a name-based contract, while the reused29 cases on each platform all have mode100644 and cannot establish nonregular coverage. A symlink is not itself compiled bytecode, so a deliberate regular-artifact-only scope would be a materially narrower contract decision, not an already proved exception.

Root should revisit this applicability point in the same B99/D98 decision before claiming full filename coverage. Either preserve the intended name-wide guarantee through an explicitly qualified activation choice or explicitly resolve the narrower scope and its evidence implications. Do not silently add broad type settings, assume that one config change covers absent checkout paths, or claim symlink/gitlink native controls have passed. This inspection proves the source-level filter mismatch; it does not establish a current repository incident, an end-to-end CI bypass or a native platform result. D98's current all-name inventory would refuse N/A for these matching names, so its private aggregate would not falsely accept them.

## Other inspected properties

The frozen four files equal the stopped worktree and the handoff's candidate hashes. Their B981 base hashes match actual Git blobs. The original hook/config and ignore bytes remain exact prefixes, preserving all eleven existing definitions and pins. The new hook and ignore append match the selected proposal. The required `.gitignore`65536-byte row reuses the existing local, staged and immutable readers without changing their bodies; it does not become executable authority or require a new classifier edit.

The added tests have relevant purposes: each contract mutation must change its input and match the expected diagnostic; the dynamic input loop now covers `.gitignore`; missing local/immutable input and65536/65537-byte boundaries are explicit. Source inspection found no separate definite fixture error in those additions. This is not a syntax, PSScriptAnalyzer or executed-test pass. Required regular-file reader behavior is distinct from the fail hook's filename applicability.

The patch, handoff and evidence hashes supplied by root match. The original mutable release-state reference binds through archived `implementation/source-release-state.json` with SHA2562a88421074ee02aeb579857cb9c71f623cb9669c296c7a5fc68aa731ebde5a57. HEAD remains98177628b7bc02c646724bfc8aa0fd73fed0cd24; the saved index hash is unchanged; status shows exactly four unstaged modified files. Root's completed77-file/73-bystander census is reused rather than repeated. Local primary-source files were read as text only; metadata identifies pre-commit4.6.2, but this report makes no fresh installed-package attestation.

## Limits and next boundary

Root owns each finding's material decision and any future repair release. No product edit is proposed as already selected here. Genuine PS235 acceptance, integration onto actual accepted main, preservation of optional-input/security/parser/metadata changes, final-date metadata, final B/H/source/index/dependency binding, meaningful native integration, assembled D98 qualification, actual admission/audit, independent final quality, reviews and all current CI gates remain held. The stopped author's local B99 delta cannot alter PS235's CI HOLD or establish source/paired/service acceptance. No counter or deadline changed.

Only this REPORT and evidence.json were written. No tests, installs, candidate imports, network, native operations, Git mutations, process polling or descendants occurred.
