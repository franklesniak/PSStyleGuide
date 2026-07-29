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

Update the Markdown lint dependency tree deliberately, align the local
staged-hook Node floor with the selected packages, prove the full and staged
lint surfaces, disposition the audit result, and add review-only weekly npm
update proposals. Do not hide a pre-1.0 semver-major migration inside P1's
generator/workflow redesign or P2's documentation change.

## Prerequisites and ordering

Complete P1 and P2 first:

1. P1 establishes deterministic generation, Node 24 workflows, immutable
   action pins, and `.github/dependabot.yml`.
2. P2 commits its source and regenerated-artifact change against that known
   lint baseline.
3. P3 then changes only the package/update-governance surface and revalidates
   the unchanged documentation corpus plus the staged-lint compatibility
   surface required by the selected package engines.

At implementation start, reread the target branch's package manifest, lockfile,
Dependabot configuration, lint configuration/scripts, Node version, and current
audit. Do not assume the 2026-07-29 package versions or advisory set are still
current.

At filing and again at implementation start, confirm the applicable repository
and organization vulnerability policy. The default order remains P1, P2, P3.
If policy forbids carrying the known high findings through P1/P2, perform this
complete dependency/hook remediation first (or file it as their real
prerequisite), then rebaseline every P1/P2 Node, package, path-set, and
validation assumption after it merges. Record the policy source and ordering
decision; do not reorder solely for a hypothetical policy.

## Affected files

- `.github/workflows/package.json`
- `.github/workflows/package-lock.json`
- `.github/dependabot.yml`
- `.husky/pre-commit`
- `.github/workflows/lint-staged-markdown.mjs`
- `.github/workflows/Test-LintStagedMarkdown.ps1` — add.
- `.github/workflows/markdownlint.yml` — add only the tracked staged-lint
  harness invocation after clean installation; retain P1's action pins, exact
  Node 24 setup, cache setting, permissions, triggers, and existing lint
  commands.

Do not change the Markdown lint configuration, nested-lint implementation,
style-guide sources, generated artifacts, generator/build workflow, candidate
helper, or candidate harness. The seven files above are the complete known
compatibility/remediation/governance scope.

## Requested changes

### 1. Capture the current dependency and advisory baseline

Using Node 24 from the repository root:

1. record `node --version` and `npm --version`;
2. run `npm --prefix .github/workflows ls --all`;
3. run
   `npm --prefix .github/workflows audit --package-lock-only --json`;
4. record the Node guards/messages in `.husky/pre-commit` and
   `lint-staged-markdown.mjs`, plus any current `engines.node` declaration;
5. preserve the command exit code, validated JSON shape, severity totals,
   affected package nodes, every object advisory URL/severity/vulnerable range,
   every string-valued `via` dependency link, and npm's proposed remediation;
   and
6. run and preserve
   `npm --prefix .github/workflows explain <package> --json` for every affected
   package, normalizing the complete dependency paths for before/after
   comparison and any residual disposition.

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

At review time, the candidate declares Node `>=22`, its bundled
`markdownlint@0.41.1` also declares Node `>=22`, and the current staged guards
admit Node 20. The 0.23.0 changelog explicitly removes Node 20 support. Treat
that as a known compatibility boundary to resolve, not an unexpected change to
split after package selection.

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

Determine the highest minimum Node major required by the final selected direct
dependency tree. Set that same minimum in:

- `.github/workflows/package.json` as `engines.node`;
- `.husky/pre-commit`; and
- `.github/workflows/lint-staged-markdown.mjs`.

Update both guard messages together. For the review-time candidate, the
selected minimum is Node 22. If implementation-time releases require a higher
minimum, use that higher value and rebaseline the tests. Retain exact Node 24
in `markdownlint.yml` and in full-corpus hosted validation. Prove the staged
integration under both the selected minimum and Node 24; do not claim a lower
supported major without executing it.

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

Run the repository's two existing positive Markdown samples and require them to
pass. The repository has no tracked negative sample. Use the tracked harness
below to create deterministic temporary outer and nested violations, require
their exact rule/file/context diagnostics, and remove them in `finally`. A
tooling import/configuration/startup failure does not count as a successful
negative lint test.

### 4. Add one tracked staged/full-lint regression harness

Create:

```text
.github/workflows/Test-LintStagedMarkdown.ps1
```

The harness must:

- record a `.NOTES` script version using the repository versioning policy;
- declare the PowerShell version it actually supports and run on Windows and
  Ubuntu;
- resolve the exact tracked `lint-staged-markdown.mjs`,
  `lint-nested-markdown.js`, configuration, Node executable, npm executable,
  and repository root before changing location;
- use a unique test-owned temporary root and an isolated Git index or
  disposable repository/worktree;
- never stage, unstage, rewrite, or commit through the implementation index;
- check every Git, Node, and npm exit immediately;
- distinguish staged lint exit 1 from tooling/startup exit 2; and
- remove only test-owned paths in `finally`, preserving the primary failure and
  reporting cleanup failure separately.

Implement these stable cases:

| ID | Surface | Expected evidence |
| --- | --- | --- |
| `S-01` | Exact production staged script; no staged Markdown | Exit 0; no lint invocation error |
| `S-02` | Exact production staged script; compliant staged Markdown | Exit 0; exact staged path processed |
| `S-03` | Exact production staged script; noncompliant staged Markdown | Exit 1 with expected enabled rule and staged path; never exit 2 |
| `S-04` | Exact production staged script; index bytes compliant and working-tree bytes noncompliant, then the reverse | Result follows index bytes in both directions and proves `nonFileContents` behavior |
| `F-01` | Existing positive outer and nested sample corpus | Both production npm commands pass |
| `F-02` | Deterministic temporary outer violation | Outer command fails with exact rule and fixture path; tooling startup is not accepted |
| `F-03` | Deterministic temporary fenced/nested violation | Nested command fails with exact rule, fixture path, and nested depth/context; tooling startup is not accepted |

The selected rule/fixtures must be stable under the repository's reviewed
configuration and must not depend on a package's default rule set.

Invoke this exact tracked harness from `markdownlint.yml` after `npm ci` under
hosted Node 24. Also run it locally on Windows under the selected minimum Node
major and Node 24. Use Ubuntu hosted evidence for Node 24; if selected-minimum
Ubuntu evidence is not added to CI, record a separate local/container result
without weakening the hosted Node 24 gate.

### 5. Add review-only weekly npm update governance

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
Node major 24 active. Set `$intSelectedMinimumNodeMajor` to the reviewed
manifest/guard minimum. Keep `$arrApprovedResiduals` empty for a clean result.
Add an object only for a separately approved residual disposition. Each object
must identify one exact advisory/package/path combination, owner, unexpired UTC
deadline, public follow-up issue, and rationale. The validation rejects partial,
duplicate, unexpected, expired, or stale records:

```powershell
$ErrorActionPreference = 'Stop'

$intSelectedMinimumNodeMajor = 22

$arrApprovedResiduals = @(
    # [pscustomobject]@{
    #     AdvisoryUrl = 'https://github.com/advisories/GHSA-xxxx-xxxx-xxxx'
    #     Package = 'package-name'
    #     DependencyPath = (
    #         '.github/workflows > parent@1.2.3 > package-name@4.5.6'
    #     )
    #     Owner = '@named-owner'
    #     ExpiresUtc = '2026-08-31T23:59:59Z'
    #     IssueUrl = (
    #         'https://github.com/franklesniak/PSStyleGuide/issues/123'
    #     )
    #     Rationale = 'Why no safe fix exists and the bounded mitigation.'
    # }
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

$arrNpmVersionOutput = @(
    & $objNpmCommand.Path --version
)
$intNpmExitCode = $LASTEXITCODE

if (
    $intNpmExitCode -ne 0 -or
    $arrNpmVersionOutput.Count -ne 1 -or
    ([string]$arrNpmVersionOutput[0]).Trim() -notmatch '^\d+\.\d+\.\d+'
) {
    throw (
        "Unable to establish one npm version; output/exit were {0}/{1}." -f
        ($arrNpmVersionOutput -join '; '),
        $intNpmExitCode
    )
}

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

$objPackage = Get-Content `
    -LiteralPath '.github/workflows/package.json' `
    -Raw |
    ConvertFrom-Json
$strExpectedNodeEngine = '>={0}' -f $intSelectedMinimumNodeMajor

if (
    $null -eq $objPackage.engines -or
    [string]$objPackage.engines.node -cne $strExpectedNodeEngine
) {
    throw (
        "package.json engines.node must be exactly '{0}'." -f
        $strExpectedNodeEngine
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

if ($intAuditExitCode -notin @(0, 1)) {
    throw (
        "npm audit failed as a tool/registry command with exit code {0}." -f
        $intAuditExitCode
    )
}

if ([string]::IsNullOrWhiteSpace($strAuditJson)) {
    throw 'npm audit returned empty JSON output.'
}

try {
    $objAudit = $strAuditJson | ConvertFrom-Json
}
catch {
    throw ("npm audit returned invalid JSON: {0}" -f $_.Exception.Message)
}

if (
    $null -eq $objAudit -or
    $objAudit.PSObject.Properties.Name -notcontains 'metadata' -or
    $objAudit.PSObject.Properties.Name -notcontains 'vulnerabilities' -or
    $null -eq $objAudit.metadata -or
    $null -eq $objAudit.vulnerabilities -or
    $objAudit.metadata.PSObject.Properties.Name -notcontains 'vulnerabilities'
) {
    throw 'npm audit JSON is missing metadata.vulnerabilities or vulnerabilities.'
}

$objSeverityCounts = [ordered]@{}
$lngSeveritySum = 0

foreach ($strSeverity in @('info', 'low', 'moderate', 'high', 'critical')) {
    if (
        $objAudit.metadata.vulnerabilities.PSObject.Properties.Name -notcontains
            $strSeverity
    ) {
        throw ("npm audit JSON is missing severity '{0}'." -f $strSeverity)
    }

    $lngSeverityCount = 0
    if (
        -not [long]::TryParse(
            [string]$objAudit.metadata.vulnerabilities.$strSeverity,
            [ref]$lngSeverityCount
        ) -or
        $lngSeverityCount -lt 0
    ) {
        throw (
            "npm audit severity '{0}' is not a nonnegative integer." -f
            $strSeverity
        )
    }

    $objSeverityCounts[$strSeverity] = $lngSeverityCount
    $lngSeveritySum += $lngSeverityCount
}

$lngReportedTotal = 0
if (
    $objAudit.metadata.vulnerabilities.PSObject.Properties.Name -notcontains
        'total' -or
    -not [long]::TryParse(
        [string]$objAudit.metadata.vulnerabilities.total,
        [ref]$lngReportedTotal
    ) -or
    $lngReportedTotal -lt 0 -or
    $lngReportedTotal -ne $lngSeveritySum
) {
    throw 'npm audit severity counts are invalid or do not sum to total.'
}

$arrAffectedPackageNames = @(
    $objAudit.vulnerabilities.PSObject.Properties.Name |
        Sort-Object -Unique
)
$arrAdvisoryRecords = @()
$arrViaDependencyLinks = @()

foreach (
    $objVulnerabilityProperty in
    $objAudit.vulnerabilities.PSObject.Properties
) {
    $strPackageName = [string]$objVulnerabilityProperty.Name

    if ([string]::IsNullOrWhiteSpace($strPackageName)) {
        throw 'npm audit contains an unnamed vulnerable package node.'
    }

    foreach ($objVia in @($objVulnerabilityProperty.Value.via)) {
        if ($objVia -is [string]) {
            if ([string]::IsNullOrWhiteSpace([string]$objVia)) {
                throw (
                    "npm audit contains an empty via link for '{0}'." -f
                    $strPackageName
                )
            }

            $arrViaDependencyLinks += [pscustomobject]@{
                Package = $strPackageName
                Dependency = [string]$objVia
            }
            continue
        }

        if (
            $null -eq $objVia -or
            [string]::IsNullOrWhiteSpace([string]$objVia.url) -or
            [string]::IsNullOrWhiteSpace([string]$objVia.severity) -or
            [string]::IsNullOrWhiteSpace([string]$objVia.range)
        ) {
            throw (
                "npm audit contains an incomplete advisory for '{0}'." -f
                $strPackageName
            )
        }

        if ($objVia.severity -in @('moderate', 'high', 'critical')) {
            $arrAdvisoryRecords += [pscustomobject]@{
                Package = $strPackageName
                AdvisoryUrl = [string]$objVia.url
                Severity = [string]$objVia.severity
                VulnerableRange = [string]$objVia.range
            }
        }
    }
}

foreach ($objViaLink in $arrViaDependencyLinks) {
    if ($arrAffectedPackageNames -cnotcontains $objViaLink.Dependency) {
        throw (
            "npm audit via link '{0} -> {1}' has no package node." -f
            $objViaLink.Package,
            $objViaLink.Dependency
        )
    }
}

function Get-NormalizedExplainPaths {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]$Node
    )

    $strNodeName = [string]$Node.name
    $strNodeVersion = [string]$Node.version

    if (
        [string]::IsNullOrWhiteSpace($strNodeName) -or
        [string]::IsNullOrWhiteSpace($strNodeVersion)
    ) {
        throw 'npm explain JSON contains a package without name/version.'
    }

    $strNodeLabel = '{0}@{1}' -f $strNodeName, $strNodeVersion
    $arrDependents = @($Node.dependents)

    if ($arrDependents.Count -eq 0) {
        return @($strNodeLabel)
    }

    $arrPaths = @()

    foreach ($objDependent in $arrDependents) {
        if ($null -eq $objDependent.from) {
            throw ("npm explain node '{0}' has no from object." -f $strNodeLabel)
        }

        if ([string]::IsNullOrWhiteSpace([string]$objDependent.from.name)) {
            $arrPaths += '.github/workflows > {0}' -f $strNodeLabel
            continue
        }

        foreach (
            $strParentPath in
            @(Get-NormalizedExplainPaths -Node $objDependent.from)
        ) {
            $arrPaths += '{0} > {1}' -f $strParentPath, $strNodeLabel
        }
    }

    return @($arrPaths | Sort-Object -Unique)
}

$objExplainPathsByPackage = @{}

foreach ($strAffectedPackageName in $arrAffectedPackageNames) {
    $arrExplainOutput = @(
        & $objNpmCommand.Path `
            --prefix .github/workflows `
            explain `
            $strAffectedPackageName `
            --json
    )
    $intNpmExitCode = $LASTEXITCODE

    if ($intNpmExitCode -ne 0) {
        throw (
            "npm explain failed for '{0}' with exit code {1}." -f
            $strAffectedPackageName,
            $intNpmExitCode
        )
    }

    try {
        $arrExplainNodes = @(($arrExplainOutput -join "`n") | ConvertFrom-Json)
    }
    catch {
        throw (
            "npm explain returned invalid JSON for '{0}': {1}" -f
            $strAffectedPackageName,
            $_.Exception.Message
        )
    }

    if ($arrExplainNodes.Count -eq 0) {
        throw ("npm explain returned no path for '{0}'." -f $strAffectedPackageName)
    }

    $arrNormalizedPaths = @(
        $arrExplainNodes |
            ForEach-Object {
                Get-NormalizedExplainPaths -Node $_
            } |
            Sort-Object -Unique
    )

    if ($arrNormalizedPaths.Count -eq 0) {
        throw ("npm explain normalized no path for '{0}'." -f $strAffectedPackageName)
    }

    $objExplainPathsByPackage[$strAffectedPackageName] = $arrNormalizedPaths
}

$arrApprovalUrls = @(
    $arrApprovedResiduals |
        ForEach-Object {
            [string]$_.AdvisoryUrl
        }
)

if (@($arrApprovalUrls | Sort-Object -Unique).Count -ne $arrApprovalUrls.Count) {
    throw 'Approved residual dispositions contain a duplicate advisory URL.'
}

foreach ($objApproval in $arrApprovedResiduals) {
    foreach (
        $strRequiredField in
        @(
            'AdvisoryUrl'
            'Package'
            'DependencyPath'
            'Owner'
            'ExpiresUtc'
            'IssueUrl'
            'Rationale'
        )
    ) {
        if (
            $objApproval.PSObject.Properties.Name -notcontains
                $strRequiredField -or
            [string]::IsNullOrWhiteSpace(
                [string]$objApproval.$strRequiredField
            )
        ) {
            throw (
                "Approved residual is missing field '{0}'." -f
                $strRequiredField
            )
        }
    }

    if (
        [string]$objApproval.AdvisoryUrl -notmatch
            '^https://github\.com/advisories/GHSA-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}$'
    ) {
        throw (
            "Residual advisory URL is not canonical: {0}" -f
            $objApproval.AdvisoryUrl
        )
    }

    if (
        [string]$objApproval.IssueUrl -notmatch
            '^https://github\.com/[^/]+/[^/]+/issues/[1-9][0-9]*$'
    ) {
        throw ("Residual issue URL is invalid: {0}" -f $objApproval.IssueUrl)
    }

    $dtoExpiry = [datetimeoffset]::MinValue
    if (
        [string]$objApproval.ExpiresUtc -notmatch 'Z$' -or
        -not [datetimeoffset]::TryParse(
            [string]$objApproval.ExpiresUtc,
            [ref]$dtoExpiry
        ) -or
        $dtoExpiry -le [datetimeoffset]::UtcNow
    ) {
        throw (
            "Residual expiry must be a future UTC instant: {0}" -f
            $objApproval.ExpiresUtc
        )
    }

    $arrMatchingAdvisories = @(
        $arrAdvisoryRecords |
            Where-Object {
                $_.Package -ceq [string]$objApproval.Package -and
                $_.AdvisoryUrl -ceq [string]$objApproval.AdvisoryUrl
            }
    )

    if ($arrMatchingAdvisories.Count -ne 1) {
        throw (
            "Residual package/advisory does not match the audit graph: {0}/{1}" -f
            $objApproval.Package,
            $objApproval.AdvisoryUrl
        )
    }

    if (
        -not $objExplainPathsByPackage.ContainsKey(
            [string]$objApproval.Package
        ) -or
        $objExplainPathsByPackage[[string]$objApproval.Package] -cnotcontains
            [string]$objApproval.DependencyPath
    ) {
        throw (
            "Residual dependency path is not an npm explain path: {0}" -f
            $objApproval.DependencyPath
        )
    }
}

$arrActualResidualAdvisoryUrls = @(
    $arrAdvisoryRecords.AdvisoryUrl |
        Sort-Object -Unique
)
$arrResidualAdvisoryDifferences = @(
    Compare-Object `
        -ReferenceObject @($arrApprovalUrls | Sort-Object -Unique) `
        -DifferenceObject $arrActualResidualAdvisoryUrls `
        -CaseSensitive
)
$lngActionableCount = (
    $objSeverityCounts.moderate +
    $objSeverityCounts.high +
    $objSeverityCounts.critical
)

if (
    ($intAuditExitCode -eq 0 -and $lngActionableCount -ne 0) -or
    ($intAuditExitCode -eq 1 -and $lngActionableCount -eq 0)
) {
    throw (
        "npm audit exit {0} disagrees with actionable count {1}." -f
        $intAuditExitCode,
        $lngActionableCount
    )
}

if (
    $arrResidualAdvisoryDifferences.Count -ne 0 -or
    (
        $intAuditExitCode -eq 1 -and
        $arrActualResidualAdvisoryUrls.Count -eq 0
    )
) {
    throw (
        ("npm audit residual set is not exactly approved. Exit: {0}; " +
        "critical/high/moderate/total: {1}/{2}/{3}/{4}; approved: {5}; " +
        "actual: {6}.") -f
        $intAuditExitCode,
        $objSeverityCounts.critical,
        $objSeverityCounts.high,
        $objSeverityCounts.moderate,
        $lngReportedTotal,
        ($arrApprovalUrls -join ', '),
        ($arrActualResidualAdvisoryUrls -join ', ')
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

& '.github/workflows/Test-LintStagedMarkdown.ps1'
```

Run that tracked harness again on Windows under the selected minimum Node major.
Its hosted workflow execution supplies the Ubuntu/Node 24 result.

Then verify the exact final Dependabot content and implementation scope:

```powershell
$ErrorActionPreference = 'Stop'

$strExpectedDependabot = @'
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
'@
$strActualDependabot = (
    Get-Content -LiteralPath '.github/dependabot.yml' -Raw
) -replace "`r`n", "`n" -replace "`r", "`n"

if (
    $strActualDependabot.TrimEnd([char[]]"`n") -cne
        $strExpectedDependabot.TrimEnd([char[]]"`n")
) {
    throw (
        '.github/dependabot.yml must contain exactly the two approved ' +
        'review-only weekly entries.'
    )
}

$arrExpectedPaths = @(
    '.github/dependabot.yml'
    '.github/workflows/Test-LintStagedMarkdown.ps1'
    '.github/workflows/lint-staged-markdown.mjs'
    '.github/workflows/markdownlint.yml'
    '.github/workflows/package-lock.json'
    '.github/workflows/package.json'
    '.husky/pre-commit'
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
        "The changed path set is not exactly the seven P3 files: {0}" -f
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

In the pull request, preserve the implementation-time Node/npm versions,
before/after audit JSON summaries, object advisory records, string `via` links,
normalized `npm explain` paths, and any residual disposition. Confirm the
pinned Node 24 Markdown workflow completes clean installation, both production
lint commands, and the tracked harness on Windows and Ubuntu. Confirm the P1
generator/build workflow remains green and no generated artifact changes.

P3 intentionally supersedes only P1's one-entry Dependabot final-state check,
P1's restriction on additional `markdownlint.yml` steps, and the P1/P2
commit-specific changed-path checks. It also supersedes P2's prohibition on
package, hook, staged-lint, Dependabot, and Markdown-workflow edits for this
later commit. All other P1/P2 behavioral, security, generator, artifact, and
documentation-content acceptance criteria remain applicable.

## Acceptance criteria

- The issue records the implementation-time before/after Node, npm, direct
  dependency, transitive dependency, audit, object-advisory, string-`via`, and
  normalized dependency-path graph.
- Every implementation-time moderate/high/critical advisory path is absent
  from the final lockfile or has one exact, nonduplicate structured disposition
  with a matching package/path, named owner, future UTC expiry, public follow-up
  issue, and rationale.
- Audit validation accepts only exit 0 or vulnerability exit 1, validates the
  required JSON objects and nonnegative severity totals, and rejects graph,
  approval, expiry, clean-result, and exit/count inconsistencies.
- The selected dependency tree supports Node 24; `engines.node` and both local
  guards use the highest selected minimum Node major. The staged integration is
  executed under that minimum and Node 24.
- Node major 24, the recorded npm version, `npm ci`, and `npm ls --all` succeed
  from a clean dependency state.
- Both production full-lint commands pass the existing positive outer and
  nested samples.
- The tracked harness passes `S-01` through `S-04` and `F-01` through `F-03`.
  Its temporary negative fixtures fail for the exact expected lint rule and
  context, never merely because tooling failed to start.
- Manifest and lockfile diffs contain only deliberately reviewed registry
  packages and no unexpected scripts, Git/local dependencies, registry hosts,
  integrity changes, or engine drift.
- `.github/dependabot.yml` normalizes to exactly the weekly review-only
  `github-actions` entry for `/` followed by the weekly review-only npm entry
  for `/.github/workflows`; no duplicate, extra, auto-merge, or auto-approval
  configuration exists.
- The complete changed and staged path sets are exactly the seven affected
  files.
- The Markdown lint configuration, nested-lint implementation, style-guide
  sources, generated artifacts, generator/build workflow, candidate helper,
  and candidate harness do not change.
- The nonsuperseded P1/P2 validation and acceptance criteria remain green.

## References

- [Prompt-02 primary-source research record](../artifacts/prompt-02-primary-source-research.md)
- [npm: `npm audit`](https://docs.npmjs.com/cli/commands/npm-audit)
- [npm: `npm explain`](https://docs.npmjs.com/cli/commands/npm-explain)
- [npm: `package-lock.json`](https://docs.npmjs.com/cli/configuring-npm/package-lock-json)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [GitHub Docs: Configure Dependabot version updates](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/configuring-dependabot-version-updates)
- [GitHub Docs: Dependabot options reference](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
- [markdownlint-cli2 package manifest at v0.23.2](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/package.json)
- [markdownlint-cli2 changelog](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/CHANGELOG.md)
- [markdownlint-cli2 staged-content API](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/markdownlint-cli2.mjs#L881)
