# Remediate Markdown lint dependency advisories and add npm update governance

> **Dependency:** Implement this issue only after
> **Make the non-compliant blank-line example visibly distinct** has merged.
> When the issues have been filed, record the GitHub blocked-by relationship
> using the actual P2 issue.

## Summary

The npm package under `.github/workflows` parses and lints Markdown supplied by
pull-request authors. A lockfile-only audit on 2026-07-29 reports seven
vulnerable package nodes: five high and two moderate. The affected graph
includes direct `markdown-it` and `markdownlint-cli2` dependencies plus
transitive `brace-expansion`, `js-yaml`, `linkify-it`, `minimatch`, and
`picomatch`.

The reported advisories primarily concern denial of service, pathological
complexity, regular-expression behavior, or incorrect glob matching. P1's
read-only workflow permissions limit repository mutation but do not remediate
vulnerable parsing code.

Update the Markdown lint dependency tree deliberately, prove the full lint
surface under Node 24, disposition the audit result, and add review-only weekly
npm update proposals. Do not hide a pre-1.0 semver-major migration inside P1's
generator/workflow redesign or P2's documentation change.

## Prerequisites and ordering

Complete P1 and P2 first:

1. P1 establishes deterministic generation, Node 24 workflows, immutable
   action pins, and `.github/dependabot.yml`.
2. P2 commits its source and regenerated-artifact change against that known
   lint baseline.
3. P3 then changes only the package/update-governance surface and revalidates
   the unchanged documentation corpus.

At implementation start, reread the target branch's package manifest, lockfile,
Dependabot configuration, lint configuration/scripts, Node version, and current
audit. Do not assume the 2026-07-29 package versions or advisory set are still
current.

## Affected files

- `.github/workflows/package.json`
- `.github/workflows/package-lock.json`
- `.github/dependabot.yml`

Do not change the Markdown lint configuration, helper scripts, workflows,
style-guide sources, or generated artifacts unless a current dependency release
creates a separately explained compatibility requirement. If that happens,
stop and split the unrelated behavior change into its own issue rather than
silently expanding P3.

## Requested changes

### 1. Capture the current dependency and advisory baseline

Using Node 24 from the repository root:

1. record `node --version` and `npm --version`;
2. run `npm --prefix .github/workflows ls --all`;
3. run
   `npm --prefix .github/workflows audit --package-lock-only --json`;
4. preserve the command exit code, severity totals, affected packages,
   advisory URLs, vulnerable ranges, dependency paths, and npm's proposed
   remediation; and
5. use `npm --prefix .github/workflows explain <package>` for each affected
   transitive package.

The 2026-07-29 comparison baseline is:

| Severity | Count | Reported package nodes |
| --- | ---: | --- |
| Critical | 0 | — |
| High | 5 | `brace-expansion`, `js-yaml`, `linkify-it`, `minimatch`, `picomatch` |
| Moderate | 2 | `markdown-it`, `markdownlint-cli2` |
| Low | 0 | — |

npm proposed `markdownlint-cli2@0.23.2` for the direct chain at review time and
classified that as semver-major relative to the current pre-1.0 range. Treat
that only as a time-stamped candidate, not an instruction to install an
outdated version later.

### 2. Select and review the dependency update deliberately

Review the current upstream releases, changelogs, engine requirements, package
exports, configuration behavior, glob semantics, Markdown parser behavior, and
known breaking changes for every direct dependency that must move.

Then:

1. choose the smallest coherent current direct-dependency set that removes the
   known vulnerable paths and supports Node 24;
2. update explicit `devDependencies` intentionally;
3. regenerate the lockfile through the selected npm version;
4. inspect all direct/transitive additions, removals, version changes,
   integrity values, registry origins, lifecycle scripts, and engine changes;
5. reject unexpected registry hosts, Git dependencies, local paths, or package
   scripts;
6. do not use `npm audit fix --force` as a substitute for release review; and
7. do not suppress or lower the audit threshold merely to obtain a passing
   command.

If no safe current upgrade removes an advisory, record:

- the exact advisory and dependency path;
- whether pull-request Markdown can reach the vulnerable code;
- available mitigations and their limitations;
- a named owner;
- a review/expiration date; and
- the follow-up issue.

Current high/moderate findings with available fixes must not be deferred solely
to minimize lockfile churn.

### 3. Preserve the lint contract

The updated package must continue to expose and pass:

```text
npm --prefix .github/workflows run lint:md
npm --prefix .github/workflows run lint:md:nested
```

Keep:

- `.github/workflows/.markdownlint.jsonc` behavior;
- repository-root outer Markdown discovery and exclusions;
- nested-fence discovery and diagnostics;
- staged/Husky behavior established by issue #137;
- Node 24 compatibility;
- fail-closed nonzero results for actual lint errors; and
- repository-relative actionable diagnostics.

Run the repository's existing positive and negative Markdown samples. A command
that fails because tooling cannot load does not count as a successful negative
lint test; prove the expected rule/fixture diagnostic.

### 4. Add review-only weekly npm update governance

Extend the P1-created `.github/dependabot.yml` to exactly:

```yaml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
  - package-ecosystem: npm
    directory: /.github/workflows
    schedule:
      interval: weekly
```

Keep both ecosystems review-only. Do not add auto-merge or auto-approval.
Review every npm proposal's release notes, dependency/lockfile diff, engines,
install scripts, audit result, and full outer/nested lint evidence before
merging.

## Validation

Run from the repository root under PowerShell 7 or Windows PowerShell 5.1 with
Node major 24 active. Keep
`$arrApprovedResidualAdvisoryUrls` empty for a clean result. Populate it only
with the exact GitHub Advisory Database URLs from a separately approved,
owner-assigned, time-bounded disposition; the validation rejects missing,
unexpected, and stale entries:

```powershell
$ErrorActionPreference = 'Stop'

$arrApprovedResidualAdvisoryUrls = @(
    # 'https://github.com/advisories/GHSA-xxxx-xxxx-xxxx'
)

$objNodeCommand = Get-Command `
    -Name 'node' `
    -CommandType Application `
    -ErrorAction Stop |
    Select-Object -First 1

$objNpmCommand = Get-Command `
    -Name 'npm' `
    -CommandType Application `
    -ErrorAction Stop |
    Select-Object -First 1

$arrNodeVersionOutput = @(
    & $objNodeCommand.Path -p 'process.versions.node'
)
$intNodeExitCode = $LASTEXITCODE

if (
    $intNodeExitCode -ne 0 -or
    $arrNodeVersionOutput.Count -ne 1 -or
    ([string]$arrNodeVersionOutput[0]).Trim() -notmatch '^24\.'
) {
    throw (
        "P3 validation requires Node.js major 24; output/exit were {0}/{1}." -f
        ($arrNodeVersionOutput -join '; '),
        $intNodeExitCode
    )
}

$blnCiWasDefined = Test-Path -LiteralPath 'Env:CI'
$strPreviousCi = [string]$env:CI

try {
    $env:CI = 'true'

    & $objNpmCommand.Path --prefix .github/workflows ci
    $intNpmExitCode = $LASTEXITCODE

    if ($intNpmExitCode -ne 0) {
        throw ("npm ci failed with exit code {0}." -f $intNpmExitCode)
    }
}
finally {
    if ($blnCiWasDefined) {
        $env:CI = $strPreviousCi
    }
    else {
        Remove-Item -LiteralPath 'Env:CI' -ErrorAction SilentlyContinue
    }
}

& $objNpmCommand.Path --prefix .github/workflows ls --all
$intNpmExitCode = $LASTEXITCODE

if ($intNpmExitCode -ne 0) {
    throw ("npm ls failed with exit code {0}." -f $intNpmExitCode)
}

$arrAuditOutput = @(
    & $objNpmCommand.Path `
        --prefix .github/workflows `
        audit `
        --package-lock-only `
        --audit-level=moderate `
        --json
)
$intAuditExitCode = $LASTEXITCODE
$strAuditJson = $arrAuditOutput -join "`n"
$objAudit = $strAuditJson | ConvertFrom-Json

$arrActualResidualAdvisoryUrls = @(
    @(
        $objAudit.vulnerabilities.PSObject.Properties |
            ForEach-Object {
                $_.Value.via |
                    Where-Object {
                        $_ -isnot [string] -and
                        $null -ne $_.url -and
                        $_.severity -in @('moderate', 'high', 'critical')
                    } |
                    ForEach-Object {
                        [string]$_.url
                    }
            }
    ) |
        Sort-Object -Unique
)

$arrResidualAdvisoryDifferences = @(
    Compare-Object `
        -ReferenceObject $arrApprovedResidualAdvisoryUrls `
        -DifferenceObject $arrActualResidualAdvisoryUrls `
        -CaseSensitive
)

if (
    $intAuditExitCode -ne 0 -and
    (
        $arrActualResidualAdvisoryUrls.Count -eq 0 -or
        $arrResidualAdvisoryDifferences.Count -ne 0
    )
) {
    throw (
        ("npm audit has unapproved residual findings. Exit code: {0}; " +
        "critical/high/moderate/total: {1}/{2}/{3}/{4}; approved URLs: " +
        "{5}; actual URLs: {6}.") -f
        $intAuditExitCode,
        $objAudit.metadata.vulnerabilities.critical,
        $objAudit.metadata.vulnerabilities.high,
        $objAudit.metadata.vulnerabilities.moderate,
        $objAudit.metadata.vulnerabilities.total,
        ($arrApprovedResidualAdvisoryUrls -join ', '),
        ($arrActualResidualAdvisoryUrls -join ', ')
    )
}

if (
    $intAuditExitCode -eq 0 -and
    $arrApprovedResidualAdvisoryUrls.Count -ne 0
) {
    throw (
        "npm audit is clean, but the approved residual allowlist is stale: {0}" -f
        ($arrApprovedResidualAdvisoryUrls -join ', ')
    )
}

& $objNpmCommand.Path --prefix .github/workflows run lint:md
$intNpmExitCode = $LASTEXITCODE

if ($intNpmExitCode -ne 0) {
    throw (
        "Outer Markdown lint failed with exit code {0}." -f
        $intNpmExitCode
    )
}

& $objNpmCommand.Path --prefix .github/workflows run lint:md:nested
$intNpmExitCode = $LASTEXITCODE

if ($intNpmExitCode -ne 0) {
    throw (
        "Nested Markdown lint failed with exit code {0}." -f
        $intNpmExitCode
    )
}
```

Then verify exact scope:

```powershell
$ErrorActionPreference = 'Stop'

$arrExpectedPaths = @(
    '.github/dependabot.yml'
    '.github/workflows/package-lock.json'
    '.github/workflows/package.json'
) | Sort-Object

git diff --check
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw ("git diff --check failed with exit code {0}." -f $intGitExitCode)
}

$arrStatusLines = @(
    git status `
        --porcelain=v1 `
        --untracked-files=all `
        --ignore-submodules=none `
        -- .
)
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw (
        "Unable to read working-tree status; git exited with {0}." -f
        $intGitExitCode
    )
}

$arrChangedPaths = @(
    $arrStatusLines |
        ForEach-Object {
            if ($_ -notmatch '^..\s+') {
                throw ("Unexpected porcelain status record: {0}" -f $_)
            }

            $_ -replace '^..\s+', ''
        } |
        Sort-Object -Unique
)

$arrPathDifferences = @(
    Compare-Object `
        -ReferenceObject $arrExpectedPaths `
        -DifferenceObject $arrChangedPaths `
        -CaseSensitive
)

if ($arrPathDifferences.Count -ne 0) {
    throw (
        "The changed path set is not exactly the three P3 files: {0}" -f
        ($arrStatusLines -join '; ')
    )
}

git add -- $arrExpectedPaths
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw ("git add failed with exit code {0}." -f $intGitExitCode)
}

git diff --cached --check
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw (
        "git diff --cached --check failed with exit code {0}." -f
        $intGitExitCode
    )
}

$arrStagedPaths = @(git diff --cached --name-only | Sort-Object)
$intGitExitCode = $LASTEXITCODE

if ($intGitExitCode -ne 0) {
    throw (
        "Unable to list staged paths; git exited with {0}." -f
        $intGitExitCode
    )
}

$arrStagedDifferences = @(
    Compare-Object `
        -ReferenceObject $arrExpectedPaths `
        -DifferenceObject $arrStagedPaths `
        -CaseSensitive
)

if ($arrStagedDifferences.Count -ne 0) {
    throw (
        "Unexpected staged path set: {0}" -f
        ($arrStagedPaths -join ', ')
    )
}
```

In the pull request, confirm the pinned Node 24 Markdown workflow completes its
clean install and both lint commands against the updated lockfile. Confirm the
P1 generator/build workflow remains green and no generated artifact changes.

## Acceptance criteria

- The issue records the implementation-time before/after Node, npm, direct
  dependency, transitive dependency, and audit state.
- Every 2026-07-29 direct/transitive advisory path is absent from the final
  lockfile or has a current explicit disposition meeting this issue's
  owner/deadline requirements.
- `npm audit --package-lock-only --audit-level=moderate --json` exits 0 unless a
  newly published/unfixed advisory has a separately approved disposition whose
  exact URL is in the validation allowlist; missing, unexpected, and stale
  allowlist entries fail.
- Node major 24 and `npm ci` pass from a clean dependency state.
- `npm ls --all` exits 0 without invalid/extraneous dependencies.
- The existing outer and nested lint commands pass.
- Existing negative lint fixtures fail for their expected lint reason, not a
  tooling startup error.
- Manifest and lockfile diffs contain only deliberate registry packages and no
  unexpected scripts, Git/local dependencies, registry hosts, or engine drift.
- `.github/dependabot.yml` preserves P1's weekly `github-actions` entry and adds
  only the weekly npm entry for `/.github/workflows`.
- Dependabot remains review-only; no auto-merge or auto-approval is added.
- The complete changed and staged path sets are exactly the three affected
  files.
- No workflow, lint configuration/helper, style-guide source, or generated
  artifact changes.
- P1 and P2 validation remain green.

## References

- [npm: `npm audit`](https://docs.npmjs.com/cli/commands/npm-audit)
- [npm: `package-lock.json`](https://docs.npmjs.com/cli/configuring-npm/package-lock-json)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [GitHub Docs: Configure Dependabot version updates](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/configuring-dependabot-version-updates)
- [GitHub Docs: Dependabot options reference](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
- [GitHub Advisory Database: `brace-expansion` denial of service](https://github.com/advisories/GHSA-3jxr-9vmj-r5cp)
- [GitHub Advisory Database: `js-yaml` quadratic CPU consumption](https://github.com/advisories/GHSA-52cp-r559-cp3m)
- [GitHub Advisory Database: `linkify-it` quadratic denial of service](https://github.com/advisories/GHSA-v245-v573-v5vm)
- [GitHub Advisory Database: `markdown-it` quadratic denial of service](https://github.com/advisories/GHSA-6v5v-wf23-fmfq)
- [GitHub Advisory Database: `minimatch` regular-expression denial of service](https://github.com/advisories/GHSA-7r86-cg39-jmmj)
- [GitHub Advisory Database: `picomatch` regular-expression denial of service](https://github.com/advisories/GHSA-c2c7-rcm5-vvqj)
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
