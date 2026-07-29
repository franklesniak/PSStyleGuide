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

Those seven values are vulnerability-property counts. The same dated response
contains fourteen object advisory records. Record vulnerability properties,
object advisories, and distinct `(Package, AdvisoryUrl)` disposition keys as
separate units. Treat all three dated values as a comparison baseline, not as
the expected implementation-time final set.

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

Inspect the Node engine constraint for every package in the complete resolved
direct and transitive tree, plus the selected npm CLI. Evaluate the combined
semver constraints rather than looking only at direct dependencies or a simple
numeric floor. Select the lowest supported LTS major that the complete reviewed
tree admits, and require:

```text
selected minimum <= 24
```

Set that same minimum admission floor in:

- `.github/workflows/package.json` as `engines.node`;
- `.husky/pre-commit`; and
- `.github/workflows/lint-staged-markdown.mjs`.

Update both guard messages together. For the review-time candidate, the
selected minimum is Node 22. If implementation-time releases require a higher
minimum no greater than 24, use that higher value and rebaseline the tests. A
candidate whose constraints exclude Node 24 is incompatible with this issue:
select another safe candidate, redesign the hosted runtime in separately
reviewed scope, or disposition an otherwise unavoidable advisory.

Retain exact Node 24 in `markdownlint.yml` and in full-corpus hosted
validation. Treat `engines.node: >=<minimum>` and the two guards as a minimum
admission rule. The executed support evidence names the selected supported LTS
minimum and Node 24; it does not claim that every intervening, EOL, or future
major has been tested.

When the selected minimum is below 24, run two independently clean runtime
cells:

- selected minimum; and
- Node 24.

In each cell, record exact Node/npm versions, set
`npm_config_engine_strict=true`, prohibit `--force`, run fresh `npm ci`,
`npm ls --all`, both production lint commands, and the tracked harness. Restore
the previous environment value afterward. If the selected minimum is 24, one
clean Node 24 cell may satisfy both roles when the evidence says so explicitly.

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
  `.husky/pre-commit`, `lint-nested-markdown.js`, configuration, Node
  executable, npm executable, POSIX shell used for the hook, and repository
  root before changing location;
- use a unique test-owned temporary root and an isolated Git index or
  disposable repository/worktree;
- never stage, unstage, rewrite, or commit through the implementation index;
- use test-owned `node` and npm/npx sentinel shims for synthetic guard cases;
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
| `N-01` | Manifest and both production guards | One exact selected minimum and reviewed stable diagnostics |
| `N-02` | Staged JavaScript guard at selected minimum and synthetic below-minimum major | Minimum accepted; below-minimum rejected with exact diagnostic before npm/npx/lint sentinel |
| `N-03` | Complete `.husky/pre-commit` at selected minimum and synthetic below-minimum major | Minimum reaches the exact staged script; below-minimum rejects before npm/npx/lint sentinel |

The selected rule/fixtures must be stable under the repository's reviewed
configuration and must not depend on a package's default rule set.

Invoke this exact tracked harness from `markdownlint.yml` after `npm ci` under
hosted Node 24. Also run it locally on Windows under the selected minimum Node
major and Node 24. The harness must receive the selected minimum explicitly;
its synthetic guard cases do not require an EOL Node 20 executable. Use Ubuntu
hosted evidence for Node 24; if selected-minimum Ubuntu evidence is not added to
CI, record a separate local/container result without weakening the hosted
Node 24 gate.

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
manifest/guard minimum. This block owns Node 24 audit/disposition evidence and
its clean Node 24 runtime cell. Run the separate complete selected-minimum cell
specified after the block when the minimum is lower than 24.

Keep `$arrApprovedResiduals` and `$arrRecordedAuditNodes` empty for a clean
result. Add one approval per exact `(Package, AdvisoryUrl)` residual key. Add
one package-keyed audit-node record containing the complete exact `nodes` set
for every package that remains vulnerable. These are separate collections;
`npm explain` remains diagnostic context. The validation rejects partial,
duplicate, unexpected, expired, or stale records:

```powershell
$ErrorActionPreference = 'Stop'

$intSelectedMinimumNodeMajor = 22

if (
    $intSelectedMinimumNodeMajor -notin @(22, 24)
) {
    throw 'The selected supported LTS minimum must be Node 22 or Node 24.'
}

$arrApprovedResiduals = @(
    # [pscustomobject]@{
    #     AdvisoryUrl = 'https://github.com/advisories/GHSA-xxxx-xxxx-xxxx'
    #     Package = 'package-name'
    #     Owner = '@named-owner'
    #     ExpiresUtc = '2026-08-31T23:59:59Z'
    #     IssueUrl = (
    #         'https://github.com/franklesniak/PSStyleGuide/issues/123'
    #     )
    #     OwnerAcceptanceEvidence = (
    #         'Where the named owner explicitly accepted this disposition.'
    #     )
    #     Rationale = 'Why no safe fix exists and the bounded mitigation.'
    # }
)

$arrRecordedAuditNodes = @(
    # [pscustomobject]@{
    #     Package = 'package-name'
    #     AuditNodePaths = @(
    #         'node_modules/package-name'
    #     )
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
$blnEngineStrictWasDefined = Test-Path -LiteralPath 'Env:npm_config_engine_strict'
$strPreviousEngineStrict = [string]$env:npm_config_engine_strict

try {
    $env:CI = 'true'
    $env:npm_config_engine_strict = 'true'

    $arrEngineStrictOutput = @(
        & $objNpmCommand.Path config get engine-strict
    )
    $intNpmExitCode = $LASTEXITCODE

    if (
        $intNpmExitCode -ne 0 -or
        $arrEngineStrictOutput.Count -ne 1 -or
        ([string]$arrEngineStrictOutput[0]).Trim() -cne 'true'
    ) {
        throw (
            "Unable to establish engine-strict=true; output/exit were {0}/{1}." -f
            ($arrEngineStrictOutput -join '; '),
            $intNpmExitCode
        )
    }

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

    if ($blnEngineStrictWasDefined) {
        $env:npm_config_engine_strict = $strPreviousEngineStrict
    }
    else {
        Remove-Item `
            -LiteralPath 'Env:npm_config_engine_strict' `
            -ErrorAction SilentlyContinue
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
    $objAudit.PSObject.Properties.Name -notcontains 'auditReportVersion' -or
    [string]$objAudit.auditReportVersion -cne '2' -or
    $objAudit.PSObject.Properties.Name -notcontains 'metadata' -or
    $objAudit.PSObject.Properties.Name -notcontains 'vulnerabilities' -or
    $null -eq $objAudit.metadata -or
    $null -eq $objAudit.vulnerabilities -or
    $objAudit.metadata.PSObject.Properties.Name -notcontains 'vulnerabilities'
) {
    throw (
        'npm audit JSON is not the reviewed report-version-2 ' +
        'metadata/vulnerabilities shape.'
    )
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

$arrRecognizedSeverities = @(
    'info'
    'low'
    'moderate'
    'high'
    'critical'
)
$objDerivedSeverityCounts = [ordered]@{
    info = 0L
    low = 0L
    moderate = 0L
    high = 0L
    critical = 0L
}
$arrVulnerabilityProperties = @(
    $objAudit.vulnerabilities.PSObject.Properties
)
$arrAffectedPackageNames = @(
    $arrVulnerabilityProperties.Name |
        Sort-Object
)
$arrDuplicatePackageNames = @(
    $arrAffectedPackageNames |
        Group-Object -CaseSensitive |
        Where-Object { $_.Count -ne 1 }
)

if (
    $arrDuplicatePackageNames.Count -ne 0 -or
    $arrVulnerabilityProperties.Count -ne $lngReportedTotal
) {
    throw (
        "npm audit property set disagrees with metadata total {0}: {1}" -f
        $lngReportedTotal,
        ($arrAffectedPackageNames -join ', ')
    )
}

$arrAllAdvisoryRecords = @()
$arrAdvisoryRecords = @()
$arrViaDependencyLinks = @()
$arrEffectsLinks = @()
$arrAuditNodeRecords = @()

foreach ($objVulnerabilityProperty in $arrVulnerabilityProperties) {
    $strPackageName = [string]$objVulnerabilityProperty.Name
    $objVulnerability = $objVulnerabilityProperty.Value
    $arrRequiredVulnerabilityFields = @(
        'name'
        'severity'
        'isDirect'
        'via'
        'effects'
        'range'
        'nodes'
        'fixAvailable'
    )

    if (
        [string]::IsNullOrWhiteSpace($strPackageName) -or
        $null -eq $objVulnerability
    ) {
        throw 'npm audit contains an unnamed or null vulnerability property.'
    }

    foreach ($strRequiredField in $arrRequiredVulnerabilityFields) {
        if (
            $objVulnerability.PSObject.Properties.Name -cnotcontains
                $strRequiredField
        ) {
            throw (
                "npm audit vulnerability '{0}' is missing field '{1}'." -f
                $strPackageName,
                $strRequiredField
            )
        }
    }

    if ([string]$objVulnerability.name -cne $strPackageName) {
        throw (
            "npm audit property/name mismatch: {0}/{1}." -f
            $strPackageName,
            $objVulnerability.name
        )
    }

    $strNodeSeverity = [string]$objVulnerability.severity

    if ($arrRecognizedSeverities -cnotcontains $strNodeSeverity) {
        throw (
            "npm audit vulnerability '{0}' has unknown severity '{1}'." -f
            $strPackageName,
            $strNodeSeverity
        )
    }

    $objDerivedSeverityCounts[$strNodeSeverity]++

    if ($objVulnerability.isDirect -isnot [bool]) {
        throw (
            "npm audit vulnerability '{0}' has non-Boolean isDirect." -f
            $strPackageName
        )
    }

    if ([string]::IsNullOrWhiteSpace([string]$objVulnerability.range)) {
        throw (
            "npm audit vulnerability '{0}' has an empty range." -f
            $strPackageName
        )
    }

    foreach ($strArrayField in @('via', 'effects', 'nodes')) {
        if ($objVulnerability.$strArrayField -isnot [System.Array]) {
            throw (
                "npm audit vulnerability '{0}' field '{1}' is not an array." -f
                $strPackageName,
                $strArrayField
            )
        }
    }

    $arrNormalizedNodePaths = @(
        foreach ($objNodePath in @($objVulnerability.nodes)) {
            $strNodePath = [string]$objNodePath
            $strNormalizedNodePath = $strNodePath -replace '\\', '/'

            if (
                [string]::IsNullOrWhiteSpace($strNodePath) -or
                $strNormalizedNodePath -notmatch '^node_modules/' -or
                $strNormalizedNodePath -match '(?:^|/)\.\.?(?:/|$)' -or
                $strNormalizedNodePath -match '//'
            ) {
                throw (
                    "npm audit vulnerability '{0}' has invalid node path '{1}'." -f
                    $strPackageName,
                    $strNodePath
                )
            }

            $strNormalizedNodePath
        }
    )

    if (
        $arrNormalizedNodePaths.Count -eq 0 -or
        @(
            $arrNormalizedNodePaths |
                Group-Object -CaseSensitive |
                Where-Object { $_.Count -ne 1 }
        ).Count -ne 0
    ) {
        throw (
            "npm audit vulnerability '{0}' has empty or duplicate nodes." -f
            $strPackageName
        )
    }

    $arrAuditNodeRecords += [pscustomobject]@{
        Package = $strPackageName
        AuditNodePaths = @($arrNormalizedNodePaths | Sort-Object)
    }

    foreach ($objVia in @($objVulnerability.via)) {
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
            [string]$objVia.url -notmatch (
                '^https://github\.com/advisories/' +
                'GHSA-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}$'
            ) -or
            $arrRecognizedSeverities -cnotcontains [string]$objVia.severity -or
            [string]::IsNullOrWhiteSpace([string]$objVia.range)
        ) {
            throw (
                "npm audit contains an invalid advisory for '{0}'." -f
                $strPackageName
            )
        }

        $objAdvisoryRecord = [pscustomobject]@{
            Package = $strPackageName
            AdvisoryUrl = [string]$objVia.url
            Severity = [string]$objVia.severity
            VulnerableRange = [string]$objVia.range
        }
        $arrAllAdvisoryRecords += $objAdvisoryRecord

        if ($objVia.severity -in @('moderate', 'high', 'critical')) {
            $arrAdvisoryRecords += $objAdvisoryRecord
        }
    }

    foreach ($objEffect in @($objVulnerability.effects)) {
        if ([string]::IsNullOrWhiteSpace([string]$objEffect)) {
            throw (
                "npm audit contains an empty effects link for '{0}'." -f
                $strPackageName
            )
        }

        $arrEffectsLinks += [pscustomobject]@{
            Package = $strPackageName
            Effect = [string]$objEffect
        }
    }

    if ($objVulnerability.fixAvailable -isnot [bool]) {
        $objFix = $objVulnerability.fixAvailable

        if (
            $null -eq $objFix -or
            [string]::IsNullOrWhiteSpace([string]$objFix.name) -or
            [string]$objFix.version -notmatch '^\d+\.\d+\.\d+(?:[-+].+)?$' -or
            $objFix.isSemVerMajor -isnot [bool]
        ) {
            throw (
                "npm audit vulnerability '{0}' has invalid fixAvailable." -f
                $strPackageName
            )
        }
    }
}

foreach ($strSeverity in $arrRecognizedSeverities) {
    if (
        [long]$objDerivedSeverityCounts[$strSeverity] -ne
            [long]$objSeverityCounts[$strSeverity]
    ) {
        throw (
            "npm audit derived/metadata severity mismatch for '{0}': {1}/{2}." -f
            $strSeverity,
            $objDerivedSeverityCounts[$strSeverity],
            $objSeverityCounts[$strSeverity]
        )
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

foreach ($objEffectsLink in $arrEffectsLinks) {
    if ($arrAffectedPackageNames -cnotcontains $objEffectsLink.Effect) {
        throw (
            "npm audit effects link '{0} -> {1}' has no package node." -f
            $objEffectsLink.Package,
            $objEffectsLink.Effect
        )
    }

    $arrReciprocalViaLinks = @(
        $arrViaDependencyLinks |
            Where-Object {
                $_.Package -ceq $objEffectsLink.Effect -and
                $_.Dependency -ceq $objEffectsLink.Package
            }
    )

    if ($arrReciprocalViaLinks.Count -ne 1) {
        throw (
            "npm audit effects/via edge is not reciprocal: {0} -> {1}." -f
            $objEffectsLink.Package,
            $objEffectsLink.Effect
        )
    }
}

$strAuditNodeRecordsJson = ConvertTo-Json `
    -InputObject @($arrAuditNodeRecords) `
    -Depth 5 `
    -Compress
$blnAuditNodesEnvWasDefined = Test-Path `
    -LiteralPath 'Env:P3_AUDIT_NODE_RECORDS_JSON'
$strPreviousAuditNodesEnv = [string]$env:P3_AUDIT_NODE_RECORDS_JSON

try {
    $env:P3_AUDIT_NODE_RECORDS_JSON = $strAuditNodeRecordsJson
    $arrLockResolutionOutput = @(
        & $objNodeCommand.Path -e @'
const fs = require("fs");
const lock = JSON.parse(
  fs.readFileSync(".github/workflows/package-lock.json", "utf8")
);
const records = JSON.parse(process.env.P3_AUDIT_NODE_RECORDS_JSON);
const resolved = [];
for (const record of records) {
  for (const nodePath of record.AuditNodePaths) {
    const entry = lock.packages && lock.packages[nodePath];
    if (!entry || typeof entry.version !== "string" || !entry.version) {
      throw new Error(`Audit node does not resolve in lockfile: ${nodePath}`);
    }
    const marker = "/node_modules/";
    const markerIndex = nodePath.lastIndexOf(marker);
    const leaf = markerIndex >= 0
      ? nodePath.slice(markerIndex + marker.length)
      : nodePath.slice("node_modules/".length);
    if (leaf !== record.Package) {
      throw new Error(
        `Audit node/package mismatch: ${record.Package}/${nodePath}`
      );
    }
    resolved.push({
      package: record.Package,
      nodePath,
      version: entry.version
    });
  }
}
process.stdout.write(JSON.stringify(resolved));
'@
    )
    $intNodeExitCode = $LASTEXITCODE

    if ($intNodeExitCode -ne 0 -or $arrLockResolutionOutput.Count -ne 1) {
        throw (
            "Unable to resolve audit nodes in package-lock.json; exit: {0}." -f
            $intNodeExitCode
        )
    }

    try {
        $arrResolvedAuditNodes = @(
            ($arrLockResolutionOutput -join "`n") |
                ConvertFrom-Json
        )
    }
    catch {
        throw (
            "Audit-node lockfile resolution returned invalid JSON: {0}" -f
            $_.Exception.Message
        )
    }
}
finally {
    if ($blnAuditNodesEnvWasDefined) {
        $env:P3_AUDIT_NODE_RECORDS_JSON = $strPreviousAuditNodesEnv
    }
    else {
        Remove-Item `
            -LiteralPath 'Env:P3_AUDIT_NODE_RECORDS_JSON' `
            -ErrorAction SilentlyContinue
    }
}

$intExpectedResolvedNodeCount = @(
    $arrAuditNodeRecords |
        ForEach-Object {
            @($_.AuditNodePaths)
        }
).Count

if ($arrResolvedAuditNodes.Count -ne $intExpectedResolvedNodeCount) {
    throw 'Audit-node lockfile resolution count is incomplete.'
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

    if (
        $Node.PSObject.Properties.Name -notcontains 'dependents' -or
        $null -eq $Node.dependents
    ) {
        return @($strNodeLabel)
    }

    if ($Node.dependents -isnot [System.Array]) {
        throw (
            "npm explain node '{0}' has non-array dependents." -f
            $strNodeLabel
        )
    }

    $arrDependents = @($Node.dependents)

    if ($arrDependents.Count -eq 0) {
        return @($strNodeLabel)
    }

    $arrPaths = @()

    foreach ($objDependent in $arrDependents) {
        if (
            $null -eq $objDependent -or
            $objDependent.PSObject.Properties.Name -notcontains 'from' -or
            $null -eq $objDependent.from
        ) {
            throw ("npm explain node '{0}' has no from object." -f $strNodeLabel)
        }

        if ([string]::IsNullOrWhiteSpace([string]$objDependent.from.name)) {
            if (
                [string]::IsNullOrWhiteSpace(
                    [string]$objDependent.from.location
                )
            ) {
                throw (
                    "npm explain node '{0}' has an invalid root object." -f
                    $strNodeLabel
                )
            }

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

function Get-ResidualApprovalKey {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [object]$Record
    )

    return '{0}|{1}' -f $Record.Package, $Record.AdvisoryUrl
}

$arrActualResidualKeys = @(
    $arrAdvisoryRecords |
        ForEach-Object {
            Get-ResidualApprovalKey -Record $_
        } |
        Sort-Object
)
$arrDuplicateActualResidualKeys = @(
    $arrActualResidualKeys |
        Group-Object -CaseSensitive |
        Where-Object { $_.Count -ne 1 }
)

if ($arrDuplicateActualResidualKeys.Count -ne 0) {
    throw (
        "npm audit contains duplicate package/advisory keys: {0}" -f
        ($arrDuplicateActualResidualKeys.Name -join ', ')
    )
}

$arrApprovalKeys = @()

foreach ($objApproval in $arrApprovedResiduals) {
    foreach (
        $strRequiredField in
        @(
            'AdvisoryUrl'
            'Package'
            'Owner'
            'ExpiresUtc'
            'IssueUrl'
            'OwnerAcceptanceEvidence'
            'Rationale'
        )
    ) {
        if (
            $objApproval.PSObject.Properties.Name -cnotcontains
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
        [string]$objApproval.AdvisoryUrl -notmatch (
            '^https://github\.com/advisories/' +
            'GHSA-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}$'
        )
    ) {
        throw (
            "Residual advisory URL is not canonical: {0}" -f
            $objApproval.AdvisoryUrl
        )
    }

    if (
        [string]$objApproval.IssueUrl -notmatch (
            '^https://github\.com/franklesniak/' +
            'PSStyleGuide/issues/(?<IssueNumber>[1-9][0-9]*)$'
        )
    ) {
        throw (
            "Residual issue URL is not a PSStyleGuide issue URL: {0}" -f
            $objApproval.IssueUrl
        )
    }

    $strIssueNumber = $Matches.IssueNumber
    $dtoExpiry = [datetimeoffset]::MinValue
    $objInvariantCulture = [Globalization.CultureInfo]::InvariantCulture
    $objDateStyles = (
        [Globalization.DateTimeStyles]::AssumeUniversal -bor
        [Globalization.DateTimeStyles]::AdjustToUniversal
    )

    if (
        -not [datetimeoffset]::TryParseExact(
            [string]$objApproval.ExpiresUtc,
            'yyyy-MM-dd''T''HH:mm:ss''Z''',
            $objInvariantCulture,
            $objDateStyles,
            [ref]$dtoExpiry
        ) -or
        $dtoExpiry -le [datetimeoffset]::UtcNow
    ) {
        throw (
            "Residual expiry must be one future invariant UTC instant: {0}" -f
            $objApproval.ExpiresUtc
        )
    }

    $objIssue = $null

    try {
        $objIssue = Invoke-RestMethod `
            -Method Get `
            -Uri (
                'https://api.github.com/repos/franklesniak/' +
                'PSStyleGuide/issues/{0}' -f $strIssueNumber
            ) `
            -Headers @{
                Accept = 'application/vnd.github+json'
                'X-GitHub-Api-Version' = '2026-03-10'
            }
    }
    catch {
        throw (
            "Residual issue is not publicly retrievable: {0}: {1}" -f
            $objApproval.IssueUrl,
            $_.Exception.Message
        )
    }

    if (
        [string]$objIssue.html_url -cne [string]$objApproval.IssueUrl -or
        $objIssue.PSObject.Properties.Name -contains 'pull_request'
    ) {
        throw (
            "Residual follow-up is missing, mismatched, or a pull request: {0}" -f
            $objApproval.IssueUrl
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
        )
    ) {
        throw (
            "Residual package has no npm explain context: {0}" -f
            $objApproval.Package
        )
    }

    $arrApprovalKeys += Get-ResidualApprovalKey -Record $objApproval
}

$arrDuplicateApprovalKeys = @(
    $arrApprovalKeys |
        Group-Object -CaseSensitive |
        Where-Object { $_.Count -ne 1 }
)

if ($arrDuplicateApprovalKeys.Count -ne 0) {
    throw (
        "Approved residuals contain duplicate composite keys: {0}" -f
        ($arrDuplicateApprovalKeys.Name -join ', ')
    )
}

$arrResidualAdvisoryDifferences = @(
    Compare-Object `
        -ReferenceObject @($arrApprovalKeys | Sort-Object) `
        -DifferenceObject $arrActualResidualKeys `
        -CaseSensitive
)

$arrRecordedNodePackageNames = @(
    $arrRecordedAuditNodes |
        ForEach-Object {
            [string]$_.Package
        }
)
$arrDuplicateRecordedNodePackages = @(
    $arrRecordedNodePackageNames |
        Group-Object -CaseSensitive |
        Where-Object { $_.Count -ne 1 }
)
$arrNodePackageDifferences = @(
    Compare-Object `
        -ReferenceObject @($arrAffectedPackageNames | Sort-Object) `
        -DifferenceObject @($arrRecordedNodePackageNames | Sort-Object) `
        -CaseSensitive
)

if (
    $arrDuplicateRecordedNodePackages.Count -ne 0 -or
    $arrNodePackageDifferences.Count -ne 0
) {
    throw 'Recorded audit-node package set is not exact.'
}

foreach ($objActualNodeRecord in $arrAuditNodeRecords) {
    $arrMatchingRecordedNodes = @(
        $arrRecordedAuditNodes |
            Where-Object {
                [string]$_.Package -ceq $objActualNodeRecord.Package
            }
    )

    if (
        $arrMatchingRecordedNodes.Count -ne 1 -or
        $arrMatchingRecordedNodes[0].PSObject.Properties.Name -cnotcontains
            'AuditNodePaths' -or
        $arrMatchingRecordedNodes[0].AuditNodePaths -isnot [System.Array]
    ) {
        throw (
            "Recorded audit nodes are malformed for '{0}'." -f
            $objActualNodeRecord.Package
        )
    }

    $arrRecordedNodePaths = @(
        $arrMatchingRecordedNodes[0].AuditNodePaths |
            ForEach-Object {
                ([string]$_) -replace '\\', '/'
            }
    )
    $arrDuplicateRecordedNodePaths = @(
        $arrRecordedNodePaths |
            Group-Object -CaseSensitive |
            Where-Object { $_.Count -ne 1 }
    )
    $arrNodePathDifferences = @(
        Compare-Object `
            -ReferenceObject @(
                $objActualNodeRecord.AuditNodePaths |
                    Sort-Object
            ) `
            -DifferenceObject @($arrRecordedNodePaths | Sort-Object) `
            -CaseSensitive
    )

    if (
        $arrDuplicateRecordedNodePaths.Count -ne 0 -or
        $arrNodePathDifferences.Count -ne 0
    ) {
        throw (
            "Recorded audit node-path set is not exact for '{0}'." -f
            $objActualNodeRecord.Package
        )
    }
}

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
        $arrActualResidualKeys.Count -eq 0
    )
) {
    throw (
        ("npm audit residual set is not exactly approved. Exit: {0}; " +
        "critical/high/moderate/property-total/object-advisories: " +
        "{1}/{2}/{3}/{4}/{5}; approved keys: {6}; actual keys: {7}.") -f
        $intAuditExitCode,
        $objSeverityCounts.critical,
        $objSeverityCounts.high,
        $objSeverityCounts.moderate,
        $lngReportedTotal,
        $arrAllAdvisoryRecords.Count,
        ($arrApprovalKeys -join ', '),
        ($arrActualResidualKeys -join ', ')
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

& '.github/workflows/Test-LintStagedMarkdown.ps1' `
    -SelectedMinimumNodeMajor $intSelectedMinimumNodeMajor
```

If `$intSelectedMinimumNodeMajor` is lower than 24, activate that exact major in
a fresh shell and run this complete second cell from the repository root:

```powershell
$ErrorActionPreference = 'Stop'

$intSelectedMinimumNodeMajor = 22

if ($intSelectedMinimumNodeMajor -notin @(22, 24)) {
    throw 'The selected supported LTS minimum must be Node 22 or Node 24.'
}

$objNodeCommand = Get-Command node -CommandType Application -ErrorAction Stop |
    Select-Object -First 1
$objNpmCommand = Get-Command npm -CommandType Application -ErrorAction Stop |
    Select-Object -First 1
$strNodeVersion = [string](
    & $objNodeCommand.Path -p 'process.versions.node'
)
$intNodeExitCode = $LASTEXITCODE

if (
    $intNodeExitCode -ne 0 -or
    $strNodeVersion -notmatch (
        '^{0}\.' -f $intSelectedMinimumNodeMajor
    )
) {
    throw (
        "Selected-minimum cell has the wrong Node version: {0}/{1}." -f
        $strNodeVersion,
        $intNodeExitCode
    )
}

$blnCiWasDefined = Test-Path -LiteralPath 'Env:CI'
$strPreviousCi = [string]$env:CI
$blnEngineStrictWasDefined = Test-Path `
    -LiteralPath 'Env:npm_config_engine_strict'
$strPreviousEngineStrict = [string]$env:npm_config_engine_strict

try {
    $env:CI = 'true'
    $env:npm_config_engine_strict = 'true'

    $arrEngineStrictOutput = @(
        & $objNpmCommand.Path config get engine-strict
    )
    $intNpmExitCode = $LASTEXITCODE

    if (
        $intNpmExitCode -ne 0 -or
        $arrEngineStrictOutput.Count -ne 1 -or
        ([string]$arrEngineStrictOutput[0]).Trim() -cne 'true'
    ) {
        throw 'Selected-minimum cell did not establish engine-strict=true.'
    }

    & $objNpmCommand.Path --prefix .github/workflows ci
    $intNpmExitCode = $LASTEXITCODE

    if ($intNpmExitCode -ne 0) {
        throw (
            "Selected-minimum npm ci failed with exit {0}." -f
            $intNpmExitCode
        )
    }
}
finally {
    if ($blnCiWasDefined) {
        $env:CI = $strPreviousCi
    }
    else {
        Remove-Item -LiteralPath 'Env:CI' -ErrorAction SilentlyContinue
    }

    if ($blnEngineStrictWasDefined) {
        $env:npm_config_engine_strict = $strPreviousEngineStrict
    }
    else {
        Remove-Item `
            -LiteralPath 'Env:npm_config_engine_strict' `
            -ErrorAction SilentlyContinue
    }
}

$arrNpmCommandArguments = @(
    ,@('--prefix', '.github/workflows', 'ls', '--all')
    ,@('--prefix', '.github/workflows', 'run', 'lint:md')
    ,@('--prefix', '.github/workflows', 'run', 'lint:md:nested')
)

foreach ($arrNpmArguments in $arrNpmCommandArguments) {
    & $objNpmCommand.Path @arrNpmArguments
    $intNpmExitCode = $LASTEXITCODE

    if ($intNpmExitCode -ne 0) {
        throw (
            "Selected-minimum npm command failed with exit {0}: {1}" -f
            $intNpmExitCode,
            ($arrNpmArguments -join ' ')
        )
    }
}

& '.github/workflows/Test-LintStagedMarkdown.ps1' `
    -SelectedMinimumNodeMajor $intSelectedMinimumNodeMajor
```

If the selected minimum is 24, do not run a duplicate cell; record that the
Node 24 audit/runtime block satisfied both roles. Preserve the exact resolved
engine constraints and both runtime cells' Node/npm versions in pull-request
evidence. The hosted workflow supplies the mandatory Ubuntu/Node 24 result;
record selected-minimum Windows evidence and an Ubuntu/container result if that
minimum is not a hosted cell.

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
before/after raw audit JSON and report version, vulnerability-property severity
counts, object advisory records/count, string `via` and `effects` links,
audit-node paths and resolved lockfile versions, `fixAvailable` shapes,
normalized `npm explain` context, and any residual disposition. Preserve owner
acceptance evidence separately from the syntactic owner field. Confirm the
pinned Node 24 Markdown workflow completes strict clean installation, both
production lint commands, and the tracked harness on Windows and Ubuntu.
Confirm the selected-minimum clean cell when distinct. Confirm the P1
generator/build workflow remains green and no generated artifact changes.

P3 intentionally supersedes only P1's one-entry Dependabot final-state check,
P1's restriction on additional `markdownlint.yml` steps, and the P1/P2
commit-specific changed-path checks. It also supersedes P2's prohibition on
package, hook, staged-lint, Dependabot, and Markdown-workflow edits for this
later commit. All other P1/P2 behavioral, security, generator, artifact, and
documentation-content acceptance criteria remain applicable.

## Acceptance criteria

- The issue records the implementation-time before/after Node, npm, direct
  dependency, transitive dependency, raw audit, report-version,
  vulnerability-property, object-advisory, `via`/`effects`, audit-node,
  lockfile-version, `fixAvailable`, and normalized explain graph.
- Vulnerability-property counts, object-advisory counts, and distinct
  `(Package, AdvisoryUrl)` disposition-key counts are reported separately and
  reconciled only with their matching units.
- Every implementation-time moderate/high/critical package/advisory key is
  absent from the final lockfile or has one exact, nonduplicate structured
  disposition with a matching package/URL, named owner, separately recorded
  owner acceptance, exact future UTC expiry, publicly retrievable PSStyleGuide
  issue that is not a pull request, and rationale.
- Every remaining vulnerable package has one exact, nonempty, duplicate-free
  recorded `AuditNodePaths` set equal to the audit property; each path resolves
  to the matching package/version lockfile entry. Explain chains remain
  diagnostic context and are not residual identity.
- Audit validation accepts only exit 0 or vulnerability exit 1, validates the
  reviewed report-version-2 shapes, derives metadata counts from vulnerability
  properties, validates all advisory severities/ranges, nodes, edges, and
  remediation shapes, and rejects graph, approval, expiry, clean-result, and
  exit/count inconsistencies.
- The complete selected direct/transitive tree and npm CLI admit both the
  selected supported LTS minimum and Node 24. `engines.node` and both local
  guards use one exact minimum admission floor without claiming unexecuted
  future/intervening runtime coverage.
- Every distinct runtime role performs fresh `npm ci` with
  `engine-strict=true` and no `--force`, `npm ls --all`, both production lint
  commands, and the tracked harness. Hosted Node 24 remains mandatory.
- Both production full-lint commands pass the existing positive outer and
  nested samples.
- The tracked harness passes `S-01` through `S-04`, `F-01` through `F-03`, and
  `N-01` through `N-03`. Its temporary lint violations fail for the expected
  rule/context, both production guards agree, and synthetic below-minimum cases
  reject before npm/npx/lint tooling can run.
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

- [Prompt-02 primary-source research record](https://github.com/franklesniak/PSStyleGuide/blob/c3f17cc98e4901928d707c83b48e25a0d9a09a3d/docs/planning/artifacts/prompt-02-primary-source-research.md)
- [npm: `npm audit`](https://docs.npmjs.com/cli/commands/npm-audit)
- [npm: `npm explain`](https://docs.npmjs.com/cli/commands/npm-explain)
- [npm: `engine-strict`](https://docs.npmjs.com/cli/v11/using-npm/config/#engine-strict)
- [npm: `package-lock.json`](https://docs.npmjs.com/cli/configuring-npm/package-lock-json)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [GitHub Docs: Get an issue](https://docs.github.com/en/rest/issues/issues#get-an-issue)
- [Microsoft Learn: `DateTimeOffset.TryParseExact`](https://learn.microsoft.com/dotnet/api/system.datetimeoffset.tryparseexact)
- [GitHub Docs: Configure Dependabot version updates](https://docs.github.com/en/code-security/how-tos/secure-your-supply-chain/secure-your-dependencies/configuring-dependabot-version-updates)
- [GitHub Docs: Dependabot options reference](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
- [markdownlint-cli2 package manifest at v0.23.2](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/package.json)
- [markdownlint-cli2 changelog](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/CHANGELOG.md)
- [markdownlint-cli2 staged-content API](https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/markdownlint-cli2.mjs#L881)
