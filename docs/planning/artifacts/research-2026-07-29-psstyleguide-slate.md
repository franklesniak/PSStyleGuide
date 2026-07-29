# Primary-source research for the PSStyleGuide issue slate

Retrieved 2026-07-29. These notes preserve the facts used by the issue-finding
evaluations so the sources do not need to be rediscovered after context
compaction. They are paraphrases unless an exact field/value is shown.

## GitHub issue dependencies and permanent evidence

Source:
<https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-issue-dependencies>

- GitHub issues can record blocked-by/blocking relationships.
- Use actual filed issue relationships rather than title-only prose when the
  issues exist.

Source:
<https://docs.github.com/en/repositories/working-with-files/using-files/getting-permanent-links-to-files>

- A permanent file link is commit-specific.
- Cross-issue comparisons should retain exact commit links rather than moving
  branch links.

Implication: P1/P1A/P1B/P2/P3 can remain sequential, reviewable units with
mechanical blocked-by relationships and immutable implementation evidence.

## PowerShell unresolved provider paths

Source:
<https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pathintrinsics.getunresolvedproviderpathfrompspath>

- `GetUnresolvedProviderPathFromPSPath` converts a PowerShell path to a
  provider-internal path even when the item does not yet exist.
- The API accepts wildcard-bearing paths but leaves wildcard characters
  unresolved.
- An overload returns `ProviderInfo` and `PSDriveInfo`, allowing the caller to
  prove the selected provider.

Implication: a final artifact destination must reject wildcard/relative/
ambiguous input before the API, use provider metadata to require FileSystem,
and produce one absolute path before `File.WriteAllText`.

## GitHub Actions matrix outputs

Source:
<https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#using-job-outputs-in-a-matrix-job>

- Outputs from matrix children are combined for downstream jobs.
- Matrix execution order is not guaranteed.
- If multiple children use the same output name, the last finishing child can
  overwrite the value.
- GitHub's documented pattern uses distinct output names for distinct matrix
  children.

Source:
<https://docs.github.com/en/actions/reference/workflows-and-actions/contexts#strategy-context>

- `strategy.job-total` exposes the number of jobs expanded from the matrix.

Implication: terminal approval needs four unique stable attestation keys,
exact key-set validation, `job-total == 4`, and rejection fixtures for missing,
extra, malformed, failed, or skipped cells.

## GitHub token and action credential boundaries

Source:
<https://docs.github.com/en/actions/tutorials/authenticate-with-github_token>

- GitHub creates a `GITHUB_TOKEN` for a job.
- An action can access `github.token` even if the workflow did not explicitly
  pass `GITHUB_TOKEN` as an input.

Source:
<https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions>

- Token permissions are configured at workflow or job scope, not step scope.
- A job-specific `permissions` block applies to all actions and run commands in
  that job that use the token.

Source:
<https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml>

- Checkout's `persist-credentials` default is `true`.
- Setting it to `false` prevents the checkout credential from being configured
  for later Git commands; it does not change the job token's lifetime or
  permission scope.

Implication: issue text must distinguish “not persisted/materialized outside
the push” from “the job credential does not exist.” A truly push-step-only
write credential requires a separately governed step-scoped secret while the
job token remains read-only, or the issue must accurately accept a minimal
job-scoped write token.

## Node.js release support and package engine declarations

Source: <https://nodejs.org/en/about/previous-releases>

- On 2026-07-29, Node 22 and Node 24 are LTS lines, Node 23 and Node 25 are
  end-of-life, and Node 26 is Current.
- Node recommends production applications use Active LTS or Maintenance LTS.
- Starting with Node 27, the project is changing to an annual release cycle in
  which every major is intended to progress to LTS after its Current/Alpha
  phases. Therefore “even major” is not a durable synonym for LTS.

Source:
<https://docs.npmjs.com/cli/v11/configuring-npm/package-json/#engines>

- `package.json` `engines` expresses supported Node/npm versions as semver
  ranges.
- Unless `engine-strict` is enabled, npm generally treats an engine mismatch as
  advisory.

Implication: P3 should publish a finite reviewed semver union, use the same
decision in both guards, test rejected intervening/future majors, and enable
strict engine enforcement in validation.

## npm audit report behavior

Source: <https://docs.npmjs.com/cli/v11/commands/npm-audit/>

- `npm audit` submits dependency information to the configured registry and
  returns a vulnerability report.
- Exit status depends on findings and `audit-level`; registry/tool failures
  must remain distinguishable from vulnerability-policy failures.
- The current npm 11 JSON response used by this repository is report version
  2 and contains package-keyed vulnerability properties, object advisory
  records in `via`, dependency links, node paths, metadata counts, and
  `fixAvailable`.

Fresh repository observation on 2026-07-29:

- Runtime: Node 26.5.0/npm 11.7.0, used only for baseline inspection.
- Command: `npm audit --package-lock-only --json`.
- Result: exit 1; report version 2; metadata totals 0 info, 0 low, 2 moderate,
  5 high, 0 critical, 7 total.
- Seven vulnerability properties contain fourteen object advisory records.

Implication: approvals must use audit-native package/advisory identities,
retain exact package-keyed node-path sets, validate all consumed graph shapes,
and preserve the raw response/tool version. A clean result needs no exception
file; a residual requires a tracked, continuously validated record.
