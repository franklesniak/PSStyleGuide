# Make the non-compliant blank-line example visibly distinct

## Summary

In `STYLE_GUIDE.md`, the Compliant and Non-Compliant blank-line examples are
intended to contrast an empty line with one containing spaces, but both stored
examples currently contain an empty third line. Replace the invisible defect
with a durable visible representation. Keep concise operational interpretation
in `STYLE_GUIDE.md` and the durability rationale in
`STYLE_GUIDE_RATIONALE.md`.

The guidance remains self-contained and useful to every adopter; it must not
refer to a downstream repository. The discovery originated in
[franklesniak/copilot-repo-template#851](https://github.com/franklesniak/copilot-repo-template/issues/851)
and
[franklesniak/copilot-repo-template#852](https://github.com/franklesniak/copilot-repo-template/pull/852).

## Consumed landed contracts

P1B, **Promote generated style-guide artifacts through a least-privileged
verified writer**, is P2's only direct prerequisite and must be represented by
a real verified GitHub blocked-by edge. P1B already binds P1 and P1A.

Before coding, record:

| Contract | Required landed evidence |
| --- | --- |
| P1/P1A/P1B | Permanent issue/PR URLs; reviewed heads/bases; merge methods; landed commits/trees |
| Generator | Version/hash and no-argument fixed-map interface |
| Candidate suite | Helper/context/harness/catalog versions, hashes, and schemas |
| Workflow policy | Validator/contract/case versions and hashes |
| Scope verifier | Exact script version/hash and invocation contract |
| Publication | Final graph/action/default contract; candidate/attestation/approval/writer evidence |
| Credentials/evidence | Honest token-state proof and isolated evidence-ref deletion |
| Reciprocal | P1↔T1, P1A↔T1A, and P1B↔T1B without blockers |
| Updates | Exact one-entry review-only Actions Dependabot policy |

Compare these landed values with this issue. Any material difference stops for
issue review and reruns affected predecessor validation; do not restate or
silently modify predecessor algorithms here.

P3, **Remediate Markdown lint dependency advisories and add npm update
governance**, follows P2. This title-only forward reference is intentionally
permanent because P3 need not exist when P2 is filed. P3 records P2's real URL
and dependency after its own filing. P3 package work never enters P2.

## Affected files

Exactly these six paths:

- `STYLE_GUIDE.md`;
- `STYLE_GUIDE_RATIONALE.md`;
- `copilot-instructions.md`;
- `powershell.instructions.md`;
- `STYLE_GUIDE_CHAT.md`; and
- `STYLE_GUIDE_FULL.md`.

The first two are authoritative sources. Change the four generated artifacts
only by running P1's exact landed generator. Commit all six together.

## Requested content

### Preserve the Compliant example

Keep this complete heading/block ordinally byte-identical and copy-ready:

````text
**Compliant (blank line is truly empty):**

```powershell
{
    Invoke-SomeCmdlet

    Invoke-AnotherCmdlet
}
```
````

Before editing, record the prerequisite commit and SHA-256 of this exact
LF-joined snippet. Require exactly one ordinal occurrence in
`STYLE_GUIDE.md` before and after editing and exactly one in each generated
artifact after regeneration. Do not trim or normalize for comparison.
Self-tests that alter the empty line, fence language, command text, heading, or
duplicate the block must fail.

### Replace the Non-Compliant example

Use exactly this content:

````text
**Non-Compliant (blank line contains spaces; visualization only):**

Each `·` on line 3 below is an explanatory substitute for one literal U+0020 SPACE on the otherwise blank line. The dots **MUST NOT** be copied into PowerShell code.

```text
{
    Invoke-SomeCmdlet
····
    Invoke-AnotherCmdlet
}
```

The four represented spaces are not allowed. A compliant blank line contains no characters.
````

The fence is `text`. Its third content line contains exactly four U+00B7
MIDDLE DOT characters and no other byte. The warning precedes the block,
identifies each dot as one literal space, and says the dots must not be copied.
The heading names the violation and calls it a visualization. Preserve the
existing rule/requirement levels. Store no literal trailing whitespace and add
no downstream-specific guidance.

Require the full canonical Non-Compliant snippet and its heading marker exactly
once in `STYLE_GUIDE.md` and exactly once in each generated artifact.

### Extend the existing rationale section

Extend the one existing `### Blank Line Usage` section beneath
`## Content Relocated from STYLE_GUIDE.md`; do not create another section.
Explain generically:

- literal spaces on an otherwise blank line are invisible;
- editors, formatters, and whitespace cleanup can remove them;
- the two examples can therefore drift into byte identity;
- visible substitutes preserve the intended defect without storing trailing
  whitespace; and
- middle dots are documentation annotations, not PowerShell syntax.

Do not duplicate the operational Non-Compliant heading or canonical fenced
snippet in the rationale.

### Advance guide metadata

At finalization, reread `Version` and `Last Updated` from the target branch:

1. increment Minor because the change introduces a durable documentation
   convention and repairs semantics;
2. use the current UTC date for Build and `Last Updated`;
3. set Revision to `0` when `Major.Minor.Build` changes;
4. if that value already exists at Revision `N`, use `N + 1`; and
5. recompute after a target-branch or UTC-date change.

Commit metadata with the source change.

## Regeneration and predecessor interfaces

From a clean working tree at the recorded P1B landed commit:

1. edit only the two authoritative sources;
2. invoke the exact landed no-argument
   `.github/workflows/Generate-StyleGuideArtifacts.ps1` with `pwsh`;
3. capture the native exit immediately and require zero;
4. require the resulting complete changed set to equal the six affected paths;
5. run content, byte, lint, candidate, and workflow validation;
6. stage exactly those six paths with literal pathspecs;
7. use landed `Test-ExactGitPathSet.ps1` in `Working`, `Staged`, then `Both`
   modes to prove exact sets and an empty unstaged/untracked set; and
8. rerun generation and all staged-content checks, requiring no further diff.

Every PowerShell validation block starts with
`$ErrorActionPreference = 'Stop'`. Resolve each native application explicitly,
use argument arrays, capture `$LASTEXITCODE` immediately, and validate output
shape. For `git diff --exit-code`, classify 0 equal, 1 ordinary difference,
and every other status as command failure.

Do not copy predecessor path-security, candidate, matrix, approval, credential,
or writer scripts into this issue. Invoke the exact landed paths/interfaces and
retain their reported schema/version identities.

## Content and byte validation

A single local ordinal validator must target the exact `### Blank Line Usage`
section rather than accept an unrelated four-dot line. It proves:

- baseline Compliant snippet/digest unchanged and exactly once per
  guide-bearing file;
- exact Non-Compliant heading/snippet exactly once per guide-bearing file;
- the examples visibly and ordinally differ;
- exact `text` fence, warning order, four-dot third line, and concluding rule;
- `STYLE_GUIDE_RATIONALE.md` has exactly one ordinal
  `### Blank Line Usage` line and contains neither operational heading nor
  canonical Non-Compliant snippet;
- rationale includes all five generic durability claims;
- no downstream repository language;
- metadata matches finalized target/date calculation;
- all six files are BOM-less UTF-8/LF, contain no `0x0D`, and have no trailing
  space/tab; and
- generated files are exactly what the landed generator derives from sources.

Run mutation self-tests independently for wrong section, heading, fence,
warning order, dot count/code point, extra dot-line elsewhere, duplicated
snippet, altered Compliant blank line/command, duplicated rationale heading,
literal trailing spaces, BOM, CR, and stale metadata. Every mutation must fail
with one stable category.

The validator block itself must parse and run under Windows PowerShell 5.1 and
PowerShell 7. It may be an issue-local validation command; do not invent an
undocumented repository function.

## Pull-request and post-merge evidence

While the pull request is open, require the landed P1B graph to prove:

1. unfiltered PR execution;
2. immutable four-file candidate ID/digest/four hashes;
3. same-commit read-only Markdown/Ubuntu validation;
4. all four Windows edition/EOL cells using landed candidate contracts;
5. four unique hash-bound attestations and terminal approval; and
6. writer skipped at job level, with no PR write permission.

After merge to `main`, require the same read-only graph and
`has_changes=false`, because source and generated artifacts landed together.
The writer must skip at job level, no writer step may run, and no bot recovery
commit may appear. A changed candidate is a source/artifact synchronization
failure; do not accept a recovery commit as P2 success. P1B's retained isolated
changed-writer evidence remains authority for writer internals.

## Acceptance criteria

- [ ] P1B's real dependency and complete landed-contract record are verified.
- [ ] Exactly the six affected paths change.
- [ ] The Compliant snippet/digest is ordinally unchanged and unique in all
      five guide-bearing files; all mutations fail.
- [ ] The exact Non-Compliant visualization is unique in those files, uses one
      `text` fence and exactly four middle dots, and contains no trailing space.
- [ ] The warning and final interpretation are exact, generic, and portable.
- [ ] The rationale has exactly one Blank Line Usage section, all required
      reasoning, and no duplicated operational snippet/heading.
- [ ] Metadata is recalculated at finalization with a Minor increment.
- [ ] The landed generator produces and idempotently reproduces all four
      artifacts; all six are committed together.
- [ ] BOM/CR/trailing-whitespace, lint, mutation, candidate, and staged-content
      checks pass under the required hosts.
- [ ] P1's landed raw path verifier proves exact working/staged sets before and
      after rerun.
- [ ] Pull-request preparation, Ubuntu, four Windows cells, four attestations,
      and read-only approval pass; writer skips.
- [ ] Post-merge preparation reports no change, writer skips entirely, and no
      recovery commit exists.
- [ ] No package/workflow/tool or downstream-specific change enters scope.

## Scope and non-goals

Do not change:

- rule requirement levels or the Compliant example;
- `.gitattributes`, contributor files, generator, candidate scripts/catalog,
  workflow policy files, path verifier, workflows, Dependabot, package/lock,
  hook, or lint configuration;
- P1/P1A/P1B implementation algorithms; or
- version format.

Do not store literal trailing spaces, hand-edit generated artifacts, or fold in
P3 dependency work.

## Handoff

After filing, P3 records P2's permanent issue URL and blocked-by edge. Give P3
the P2 issue/PR URLs, reviewed head/base, merge method, landed commit/tree,
final guide version/date, exact six-path scope, source/artifact hashes,
generator-idempotence and content-mutation results, pull-request/post-merge
run evidence, and confirmation that no dependency/workflow contract changed.

## References

- [Unicode Latin-1 Supplement](https://www.unicode.org/charts/PDF/U0080.pdf)
- [GitHub code blocks](https://docs.github.com/get-started/writing-on-github/working-with-advanced-formatting/creating-and-highlighting-code-blocks)
- [EditorConfig `trim_trailing_whitespace`](https://spec.editorconfig.org/#supported-pairs)
- [System.Version](https://learn.microsoft.com/dotnet/api/system.version)
- [Git diff](https://git-scm.com/docs/git-diff)
- [Git status pathname format](https://git-scm.com/docs/git-status#_pathname_format_notes_and_z)
