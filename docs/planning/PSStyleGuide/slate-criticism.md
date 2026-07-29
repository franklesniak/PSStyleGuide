# Feedback on the PSStyleGuide P1/P2/P3 GitHub issue slate

## Overall assessment

The P1 → P2 → P3 order is coherent under the stated assumption that the issues
will be implemented sequentially. The slate is substantially better than the
earlier versions:

- P1 now has a truthful P1/T1 convergence matrix rather than claiming that only
  names differ.
- P1 uses one held stream for digest verification and ZIP processing, selects
  `FileShare.Read`, validates the full path envelope, creates unique job-owned
  temporary roots, and includes an end-to-end malformed-transport drill.
- P1 uses the current dated full-SHA action baseline and adds review-only GitHub
  Actions update governance.
- P1 has state-specific rejection postconditions rather than the former global
  “candidate absent after every rejection” contradiction.
- P2 remains generic, makes the invisible defect visible without storing
  trailing whitespace, and commits sources plus generated artifacts together.
- P3 is a real, ordered issue for the known npm advisories rather than residual
  prose in P1.

I would not hand off the slate unchanged, however. P1 has fallen behind the
final T1 contract in two security-test details and in local edition validation.
Its convergence matrix also still describes T1's former hash-by-path design,
which T1 no longer uses. P3 has more material problems: its known dependency
candidate raises the package runtime floor above the staged hook's current
guard, it claims negative and staged-lint coverage that its validation does not
execute, and its final-governance assertions conflict with P1's intentionally
superseded intermediate state.

My recommended disposition is:

1. return P1 for the targeted corrections below;
2. update P2's prerequisite snapshot after P1 is final;
3. return P3 for the runtime, test, audit-disposition, and governance-gate
   corrections below; and
4. retain the P1 → P2 → P3 execution order unless repository policy separately
   prohibits carrying known high-severity findings through P1 and P2.

## Current-state anchors

These observations were rechecked on 2026-07-29. The remote `main` ref and local
`main` both identify PSStyleGuide commit
[`4346310e7deebffb4159c75e30d9546263dfd649`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649):

- `.gitattributes` already contains exactly `* text=auto eol=lf`.
- The generator still declares `#Requires -Version 5.1`, has four
  edition-sensitive `Set-Content -Encoding UTF8` writes, and uses a here-string
  for the PowerShell instructions frontmatter.
- The build workflow still has path filters, workflow-level `contents: write`,
  and movable action tags.
- The Markdown workflow still uses Node 20 and movable checkout/setup-node
  tags.
- The two Blank Line Usage examples still encode the same truly empty third
  line, so P2 addresses a real defect.
- The staged Markdown hook and
  `.github/workflows/lint-staged-markdown.mjs` both accept Node 20 or newer.
- The repository contains the two positive nested-Markdown sample files, but
  does not contain the documented
  `samples/test-violations-recursive.md` negative fixture.

A fresh lockfile-only audit still reports seven vulnerable package nodes:

| Severity | Package-node count |
| --- | ---: |
| Critical | 0 |
| High | 5 |
| Moderate | 2 |
| Low | 0 |

The seven nodes remain `brace-expansion`, `js-yaml`, `linkify-it`,
`markdown-it`, `markdownlint-cli2`, `minimatch`, and `picomatch`. P3's dated
count is therefore still accurate.

The known npm remediation candidate named by P3,
`markdownlint-cli2@0.23.2`, declares Node `>=22`; its bundled
`markdownlint@0.41.1` also declares Node `>=22`. The current package and hook
baseline is Node `>=20`. That is a known compatibility boundary, not merely a
future possibility to discover during implementation.

## Required P1 corrections

### 1. Rebaseline the convergence matrix against final T1

The matrix's Archive identity row says P1's same-held-stream behavior is a
stronger P1-only choice and warns not to claim that T1 uses the same sequence.
That was true of an earlier T1 draft, but it is false now.

Final T1 requires the same core sequence:

1. open the selected archive exactly once with `FileMode.Open`,
   `FileAccess.Read`, and `FileShare.Read`;
2. hash that exact stream with `Get-FileHash -InputStream`;
3. require exactly one valid SHA-256 result;
4. compare the propagated digest before constructing `ZipArchive`;
5. rewind the same stream;
6. construct the only read-mode `ZipArchive` over that stream;
7. keep both alive through manifest validation and extraction; and
8. dispose the archive before the stream and both before cleanup.

Change this matrix row from a repository-specific difference to a deliberately
shared invariant. Keep the repository-specific manifest names, artifact names,
and diagnostic values separate.

The Permanent fixtures row is also stale. It currently says the common suite
exercises the helper only through the production helper's public interface.
Final T1 has one narrow exception: the deterministic unsafe-cleanup case loads
the exact named production cleanup function through definition-only behavior.
Ordinary archive/path fixtures still use the public expansion interface.

The implementation-start checklist should require rereading the then-current
T1 text and recording any new intentional difference. This does not require a
runtime dependency or hard cross-repository GitHub dependency; it prevents the
second implementation from silently reviving a contract that the first one
already corrected.

### 2. Add a generator-specific convergence contract

P1's current convergence matrix is primarily a helper, artifact-transport, and
workflow matrix. It does not fully address the user's stated objective of
thoughtfully unifying the two generator scripts.

Add a separate generator matrix with at least these rows:

| Generator area | Shared target | Intentional repository-specific difference |
| --- | --- | --- |
| Serialization boundary | Normalize each complete final payload with ``-replace "`r`n?", "`n"`` immediately before encoding; resolve the destination; use `UTF8Encoding($false)` and `WriteAllText`; append no implicit newline. | Payload variable names may differ. |
| Common artifact functions | Preserve equivalent behavior for the Copilot, Chat, and Full artifact functions. | Guide-specific transformation logic inside the Full artifact function may differ. |
| Instructions artifact | Use the same serialization primitive and frontmatter construction principles. | Function name, output filename, `applyTo`, and description are PowerShell- versus Terraform-specific. |
| Frontmatter | Use an LF-joined array with explicitly reviewed spaces and final LF count. | P1 migrates a here-string; T1 already has the LF-joined form. |
| Script versioning | Use the same `.NOTES` version calculation policy and supported `#Requires -Version 5.1` baseline. | The current starting version may differ. |
| Repository text policy | Treat LF checkout policy and producer correctness as complementary. | P1 preserves the existing `.gitattributes`; T1 adds it. |
| Validation | Prove both supported PowerShell editions and LF/CRLF producer equivalence with raw-byte checks. | PSStyleGuide additionally validates its Node 24 Markdown workflow and PowerShell-specific artifact name. |

This matrix should make clear that unification means shared algorithms and
failure semantics, not a cross-repository runtime import or forced
line-for-line identity. If a private serialization helper is introduced, do it
in both issues through a coordinated contract; do not create a P1-only
abstraction while T1 retains four inline copies.

### 3. Make cleanup safety deterministic and test the exact production cleanup

P1 now distinguishes initially absent, preexisting, helper-created, and
unsafe-cleanup outcomes. That resolves the earlier logical contradiction, but
the implementation and oracle are still weaker than final T1.

P1 currently:

- records whether the leaf and ordinary files were created;
- promises nonrecursive cleanup;
- allows a result of “removed, or cleanup failed and reported a retained path”;
  and
- has separate BOM and CR post-extraction cases.

It does not require a deterministic fixture that puts cleanup into an unsafe
state and calls the exact production cleanup algorithm. Without such a fixture,
the “cleanup failed safely” branch may never execute except through a
timing-dependent race or an incidental filesystem error.

Adopt T1's stronger contract:

1. Keep an exact ownership journal containing only the candidate directory and
   ordinary files created by the invocation.
2. Put cleanup in one named function in the production helper.
3. Dispose the archive and held stream before calling cleanup.
4. Before deleting anything, revalidate the complete envelope, exhaustively
   enumerate the candidate's immediate children, require the exact journaled
   set, and validate every expected child as an ordinary non-reparse file.
5. Only after that complete pre-deletion pass may cleanup remove known files
   individually and nonrecursively, then remove the proven-empty ordinary
   directory.
6. If an entry is missing, replaced, extra, unreadable, linked, reparse, or
   otherwise uncertain, stop without traversing or recursively deleting it.
7. Preserve the primary error and add a stable cleanup phase, retained path,
   safely available offending entry, and cleanup exception.

Give the harness one documented definition-only way to load that exact
production cleanup function without running the main expansion entry point.
The T1 design—function declarations before main and ordinary PowerShell
dot-source detection—is a reasonable common approach. Do not add a public test
switch, environment backdoor, second extraction API, or copied cleanup
implementation.

Add a mandatory cross-platform cleanup-safety case that:

- creates the journaled ordinary state;
- inserts an unexpected, unjournaled ordinary immediate child;
- invokes the exact production cleanup function;
- proves the candidate and unexpected entry are retained;
- proves no outside sentinel changed;
- requires the primary and cleanup diagnostics; and
- returns nonzero.

That ordinary-entry case avoids dependence on link privileges. Add a
link/reparse substitution variant where supported.

Update P1's lifecycle section, oracle table, controlled synchronization
evidence, and acceptance criteria. Then update P2's prerequisite summary to
name the final behavior.

### 4. Verify local PowerShell identity inside each executing child

P1's local cross-edition validation resolves an executable named `pwsh` or
`powershell`, labels it, and invokes the harness and generator with `-File`.
It never checks `$PSVersionTable` inside either child. The label therefore does
not prove the claimed edition or version if a shim, wrapper, alias-like
application, PATH error, or unusual installation resolves.

Port T1's same-process validation pattern, using PSStyleGuide-specific
environment-variable names:

- pass fixed expected values as data, not interpolated code;
- start each child with a fixed `-Command` prelude;
- assert `PSEdition == 'Desktop'` and version exactly 5.1 before a Windows
  PowerShell target;
- assert `PSEdition == 'Core'` and major version 7 before a PowerShell target;
- invoke the harness or generator in that same child process;
- explicitly return a nonzero child exit for any assertion or target failure;
- inspect `$LASTEXITCODE` immediately in the parent; and
- restore or remove every temporary environment value in `finally`.

Do this separately for the harness and generator. A version probe in one child
followed by the target in another would still be indirect evidence.

Update the local-validation prose and acceptance criteria. P2 may then cite
this final P1 invariant without reimplementing the cross-edition loop.

### 5. Close the link-fixture coverage loophole

P1 permits a named skip when a link-construction primitive is unavailable, but
does not require any real link/reparse fixture to execute on each operating
system family. In the worst case, every link-related row on a platform could be
skipped while the suite remains otherwise green.

Require:

- at least one real component-or-leaf symbolic-link fixture to execute and
  prove rejection on Ubuntu;
- at least one real component-or-leaf link/reparse fixture to execute and prove
  rejection on Windows;
- only a stable, case-level skip for one genuinely unavailable link form; and
- an unexpected setup failure to fail the cell.

A platform-wide link-fixture skip must not count as passing coverage.

### 6. Either align pull-request harness placement or state the difference more explicitly

P1 runs the helper harness in Ubuntu and the two Windows LF cells. T1 runs it in
Ubuntu and every Windows pull-request cell. P1's optimization can be defensible
because helper behavior is independent of source fixture EOL and both
PowerShell editions remain covered.

Choose one of these policies:

1. run the harness in all four Windows pull-request cells for identical T1/P1
   placement; or
2. retain the two-LF-cell optimization and identify it explicitly in the
   convergence matrix as per-edition helper coverage rather than per-edition ×
   EOL helper coverage.

The current matrix says placement “may differ,” but does not explain why this
specific difference is intentional. Keep the existing, stronger rule that all
four started Windows push consumers run both the harness and production helper.

## P2 feedback

P2 has no independent content-design defect. Preserve:

- the warning before the visualization;
- the `text` fence;
- exactly four U+00B7 middle dots on the represented blank line;
- the explicit statement that the dots are annotations and must not be copied;
- one canonical operational snippet in the source and generated artifacts;
- rationale without a duplicate canonical snippet; and
- committing both sources and all four regenerated artifacts together.

Three small updates are warranted after P1 is final.

### 1. Refresh the prerequisite snapshot

Add P1's final:

- same-held-stream shared P1/T1 contract;
- named, directly tested fail-closed cleanup function;
- mandatory cross-platform link coverage; and
- same-child local edition/version assertion.

Do not import T2's provider state-recovery content. T2 matters only as the
Terraform repository's sequential successor and as part of the coordinated
tooling baseline.

### 2. Assert Node 24 before local npm validation

P2's local validation immediately runs `npm ci` and both lint commands using
whatever `node` happens to be on PATH. P1 explicitly says that a pass under
another Node major is not Node 24 evidence.

Reuse P1's fixed Node-version query and require exactly one version whose major
is 24 before P2's clean install and lint commands. CI still supplies hosted
Node 24 evidence, but the copyable local block should not silently validate a
different runtime.

### 3. Remove the already-stale metadata snapshot

The `2.24.20260728.0` example is safely labeled a drift-only snapshot and the
instructions correctly require recalculation. It is nevertheless already stale
relative to the current date. Removing it would reduce the chance that an
implementer copies it despite the warning. The normative versioning algorithm
is sufficient.

This is editorial, not a blocker.

## Required P3 corrections

### 1. Resolve the known Node-engine and staged-hook mismatch

P3 says to inspect engine requirements and split an unexpected compatibility
change if necessary. The current candidate already makes that situation known:

- installed `markdownlint-cli2@0.20.0` declares Node `>=20`;
- P3's named `markdownlint-cli2@0.23.2` candidate declares Node `>=22`;
- its bundled `markdownlint@0.41.1` declares Node `>=22`;
- the upstream 0.23.0 changelog explicitly removes Node 20 support; but
- `.husky/pre-commit` and `lint-staged-markdown.mjs` both admit Node 20.

If P3 updates the package tree without changing those guards, a contributor can
pass the repository's explicit Node check and then run an unsupported
toolchain. That contradicts P3's promise to preserve staged/Husky behavior.

The simplest coherent correction is to expand P3's affected files to include:

- `.husky/pre-commit`; and
- `.github/workflows/lint-staged-markdown.mjs`.

Update both minimum-version checks and messages to the same deliberate floor.
Node 22 is the current package minimum; Node 24 is also defensible if the
project intentionally wants the local hook to match P1's hosted/local
validation baseline. Pick one policy explicitly rather than deriving different
floors in two files. Add a matching `engines.node` declaration to
`.github/workflows/package.json`.

If the maintainer wants the hook/runtime policy reviewed separately, create a
real prerequisite issue and put it before P3. Do not leave P3's current
three-file scope in place while knowingly installing packages whose engine
contract exceeds the hook's admitted runtime.

The affected-path validation and acceptance criteria must reflect whichever
option is selected.

### 2. Exercise the staged-lint API that the upgrade can break

The standard outer and nested lint commands do not exercise
`lint-staged-markdown.mjs`. That script dynamically imports
`markdownlint-cli2`, calls its programmatic `main` export, and supplies
`nonFileContents` from the Git index.

The current 0.23.2 source still exports `main` and accepts `nonFileContents`,
which is encouraging, but it is not evidence that the exact repository script
works with the final selected dependency set on Windows and Linux.

Add isolated staged-lint tests covering:

1. no staged Markdown → exit 0;
2. compliant staged Markdown → exit 0;
3. noncompliant staged Markdown → lint exit 1 with the expected rule ID and
   file, not startup exit 2;
4. working-tree content different from index content → the staged/index content
   is the content actually linted; and
5. the selected minimum Node version and Node 24 → both follow the documented
   runtime policy.

Use a disposable clone/worktree or another isolated index so validation does
not disturb the implementation index. Check every Git and Node exit code and
remove only the test-owned fixture after assertions.

### 3. Replace the nonexistent “existing negative fixture” claim with executable tests

P3 says to run existing positive and negative Markdown samples, and its
acceptance criteria require existing negative fixtures to fail for the expected
reason. The repository has two positive sample files, but the negative file
named by the implementation documentation,
`samples/test-violations-recursive.md`, is absent.

Choose one explicit approach:

- add a reviewed tracked negative fixture and include it in P3's affected-file
  and expected-failure contract; or
- generate deterministic temporary outer and nested negative fixtures during
  validation, require exact rule/fixture diagnostics, and remove them in
  `finally`.

The temporary-fixture approach keeps the permanent issue scope smaller. Either
way, prove:

- the positive outer and nested corpus passes;
- an outer violation fails for the expected markdownlint rule;
- a nested fenced-Markdown violation fails for the expected nested rule and
  depth/file context; and
- a tooling import/startup failure is not mistaken for a successful negative
  test.

Do not retain the phrase “existing negative fixtures” unless such fixtures
actually exist at implementation time.

### 4. Define how P3 supersedes P1's intermediate governance gates

P1 deliberately requires `.github/dependabot.yml` to contain exactly one
GitHub Actions entry and no npm entry. P3 deliberately adds the npm entry.
P1's exact file-content validation must therefore fail against the completed
P3 state.

P3 also changes a three-file path set that necessarily fails P1's
implementation-time six-file changed/staged-set gate. Consequently, P3's
acceptance statement that “P1 and P2 validation remain green” is not literally
achievable.

Replace it with:

- all nonsuperseded P1/P2 generator, workflow, permission, action-pin,
  helper/harness, artifact, and lint-behavior checks remain green;
- P3 intentionally supersedes P1's exact-one-Dependabot-entry assertion;
- P3's own three- or expanded-file scope replaces P1/P2's
  implementation-time path-set assertions while P3 is being implemented; and
- P2's source/generated-artifact no-drift behavior remains unchanged.

Add an exact normalized-content check for the final two-entry
`.github/dependabot.yml`, analogous to P1's current one-entry check. Require
exactly:

1. weekly review-only `github-actions` updates for `/`; and
2. weekly review-only npm updates for `/.github/workflows`.

Reject extra ecosystems/directories, duplicate entries, malformed schedules,
auto-merge/auto-approval mechanisms in the changed scope, and loss of the P1
entry.

### 5. Make residual-advisory dispositions as structured as the prose claims

P3 says a residual advisory needs an owner, review/expiration date, and
follow-up issue, and says validation rejects stale entries. The copyable
validation represents only an array of URL strings. It can detect an URL no
longer present in the audit, but it cannot validate:

- an owner;
- an expiration date;
- whether that date has passed;
- a follow-up issue;
- duplicate approval records; or
- whether the approval applies to the actual dependency path.

Use structured records, for example with:

- exact advisory URL;
- affected package/dependency path;
- named owner;
- UTC expiration date; and
- real follow-up issue URL.

The validation should:

1. reject duplicate URLs;
2. reject empty owner, path, or issue values;
3. parse the expiration date invariantly and reject an expired approval;
4. derive the approved URL set from those records;
5. require exact set equality with current moderate/high/critical residual
   advisory URLs; and
6. reject an approval that remains after the audit is clean.

Also require the structured table to be recorded in durable issue/PR evidence,
not only typed into an ephemeral local command. If the drafter prefers a manual
approval gate, narrow the claim and clearly separate manual evidence from what
the script mechanically proves.

### 6. Keep the accurate advisory baseline, but treat all URLs as dynamic

P3's seven-node severity table remains accurate. Keep it as a dated comparison
baseline, not a frozen implementation oracle.

At implementation time, record every advisory URL returned for every affected
node, including multiple advisories attached to one package. The current
References section lists representative advisories, not the full set presently
returned by npm. That is acceptable only if the implementation-time evidence
captures the complete result as P3's requested changes already require.

## Cross-slate coordination and execution order

Under the requested sequential assumption, retain:

1. P1 — deterministic generator and secure workflow baseline;
2. P2 — blank-line documentation correction and regeneration; and
3. P3 — dependency remediation and final npm update governance.

That order keeps P1/P2 on one dependency baseline and isolates the pre-1.0
dependency migration. Record real GitHub blocked-by relationships when the
issues are filed.

Coordinate P1 and T1 without making either repository a runtime dependency of
the other:

- whichever implementation starts second must reread the merged/current first
  issue and its helper/generator evidence;
- shared generator serialization and shared helper security behavior should
  remain equivalent;
- repository-specific filenames, transforms, frontmatter values, Node work,
  and current `.gitattributes` state should remain explicit differences; and
- a future shared module/action, if desired, should be a separately versioned,
  immutably consumed, coordinated follow-up rather than being smuggled into P1.

T2's provider state-recovery content should not be copied into P2 or P3. The
analogous cross-repository concern is sequencing: T2 and P2 each build on their
own repository's deterministic generator baseline, while the separate npm work
follows the documentation issue in each planned sequence.

If repository security policy does not allow five known high-severity package
nodes to remain open while P1 and P2 execute, the assumed order itself needs an
explicit exception: perform the dependency/hook remediation first, then
rebaseline P1 and P2 against the merged package and Node-floor state. Do not
quietly violate policy or silently fold the package migration into P1.

## Strengths to preserve

Do not lose these improvements while correcting the remaining findings:

- H1 titles embedded in each issue description and the P1/P2/P3 terminology.
- Repository-generic guidance rather than downstream-specific assumptions.
- Existing `.gitattributes` preserved in PSStyleGuide.
- Complete-payload normalization at the final serialization boundary.
- Resolved paths, `UTF8Encoding($false)`, and `WriteAllText`.
- LF-joined PowerShell frontmatter with exact spacing/final-newline checks.
- Full-SHA current action pins and review-only update governance.
- Explicit Node 24 hosted Markdown validation with automatic caching disabled.
- One immutable artifact ID/digest and fatal native digest handling.
- Same-held-stream independent digest verification and ZIP parsing.
- Explicit, mutually non-overlapping roots and full component validation from
  the filesystem volume/share root.
- One tracked production helper and one tracked permanent harness.
- Stable case IDs, phases, diagnostics, and per-case destination outcomes.
- Four-cell push validation and a single exact-lease writer.
- Controlled digest, malformed-transport, stale-preflight, and lease drills.
- P2's exact, visible, non-copyable blank-line visualization.
- P3's deliberate dependency review, no `npm audit fix --force`, exact
  registry/integrity review, and review-only npm Dependabot intent.

## References

- [PSStyleGuide baseline commit `4346310`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649)
- [PSStyleGuide generator at the baseline](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/Generate-StyleGuideArtifacts.ps1)
- [PSStyleGuide staged Markdown hook at the baseline](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.husky/pre-commit)
- [PSStyleGuide staged Markdown implementation at the baseline](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/lint-staged-markdown.mjs)
- [PSStyleGuide package manifest at the baseline](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/package.json)
- [PSStyleGuide package lockfile at the baseline](https://github.com/franklesniak/PSStyleGuide/blob/4346310e7deebffb4159c75e30d9546263dfd649/.github/workflows/package-lock.json)
- [PSStyleGuide sample directory at the baseline](https://github.com/franklesniak/PSStyleGuide/tree/4346310e7deebffb4159c75e30d9546263dfd649/samples)
- [P1 draft](01PSStyleGuideP1.md)
- [P2 draft](02PSStyleGuideP2.md)
- [P3 draft](03PSStyleGuideP3.md)
- [Final T1 draft](../TerraformStyleGuide/03TerraformStyleGuideT1.md)
- [Final T2 draft](../TerraformStyleGuide/04TerraformStyleGuideT2.md)
- [Microsoft Learn: PowerShell editions](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_powershell_editions)
- [Microsoft Learn: `Get-FileHash -InputStream`](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/get-filehash?view=powershell-5.1)
- [Microsoft Learn: `FileShare`](https://learn.microsoft.com/en-us/dotnet/api/system.io.fileshare)
- [`markdownlint-cli2` 0.23.2 package metadata](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/package.json)
- [`markdownlint-cli2` 0.23.2 programmatic `main` implementation](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/markdownlint-cli2.mjs#L881)
- [`markdownlint-cli2` changelog](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/CHANGELOG.md)
- [npm Docs: `npm audit`](https://docs.npmjs.com/cli/v11/commands/npm-audit/)
- [GitHub Docs: Configure Dependabot version updates](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/configure-version-updates)
- [GitHub Docs: Dependabot options reference](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
- [`actions/checkout` v7.0.1 commit](https://github.com/actions/checkout/commit/3d3c42e5aac5ba805825da76410c181273ba90b1)
- [`actions/setup-node` v7.0.0 commit](https://github.com/actions/setup-node/commit/820762786026740c76f36085b0efc47a31fe5020)
- [`actions/upload-artifact` v7.0.1 commit](https://github.com/actions/upload-artifact/commit/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a)
- [`actions/download-artifact` v8.0.1 commit](https://github.com/actions/download-artifact/commit/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c)
