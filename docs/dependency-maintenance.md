<!-- markdownlint-disable MD013 -->

# Install and check repository dependencies

- **Status:** Active
- **Owner:** Repository maintainer (@franklesniak)
- **Last Updated:** 2026-10-01
- **Scope:** Locked npm tools, the local Markdown hook, and current dependency-risk checks in PSStyleGuide.

Use the Node and bundled npm versions declared in the root [package.json](../package.json). From the repository root, run:

```text
node .github/workflows/NpmTools.mjs install
node .github/workflows/Check-NpmAudit.mjs
```

The first command installs both locked package trees with dependency lifecycle scripts disabled. It then runs the existing Husky installer explicitly. CI, `HUSKY=0` and production mode retain their hook-installation suppression. A normal contributor clone gets the staged Markdown hook. The hook needs Node 22 or later; use the declared development runtime for reproducible installation and validation.

The Node entry removes inherited npm configuration before invoking npm. It uses separate empty user/global configuration files and the public registry, and rejects repository `.npmrc` or shrinkwrap selectors. The existing `npm run bootstrap:agent-instructions` name remains a convenience alias. That outer npm process has already read configuration, so use the direct Node command when configuration isolation is required. No persistent npm setting is changed.

Local audits validate both installed graphs and ask npm for current advisories against both locks. Hosted audits check both locks and the installed nested graph; the Markdown job does not install an unused root tree. Results name the graph roots checked. Audits run on main pushes, on a weekly schedule, and for PR changes that can affect tooling. The CI command adds `--ci`: it skips only the live audit when the complete change contains ordinary, non-executable Markdown outside hidden directories and agent-instruction files. Lint still runs. A skip reports `NOT_APPLICABLE`; it does not claim the dependencies are safe. New advisories on unchanged dependencies remain visible in main and weekly results. Explicit local audits always run. GitHub can delay schedules or disable them after repository inactivity; use the local command for a current result.

Each audit child has a two-minute deadline and a two-MiB output limit. A recognized transient HTTP failure gets one retry after two seconds. Findings, malformed reports and ambiguous errors do not trigger retries. A final failed, malformed or incomplete report is an error. A clean registry result is current evidence, not a guarantee that no vulnerability exists. Locked installation has a separate ten-minute deadline per root, with npm's normal download retries inside that deadline. If installation fails, setup is incomplete; correct the reported cause, then run the bootstrap again to rebuild the installed trees. Source archives without `.git` install the tools but report that no Git hook was installed.

| Result | Exit | Meaning |
| --- | ---: | --- |
| `CLEAN` | 0 | The current registry reports no affected package summary. |
| `NOT_APPLICABLE` | 0 | A complete CI comparison proves an ordinary Markdown-only PR; no live audit ran. |
| `ACCEPTED_RISK` | 0 | Current findings fit valid accepted exceptions; this is not clean. |
| `FINDINGS` | 1 | One or more findings lack applicable accepted authority. |
| `ERROR` | 2 | Tool, input, report, authority-read or cleanup failure. Exceptions cannot waive it. |
| `PROPOSAL` | 3 | The candidate changes exception authority. The ordinary check does not approve that change. |

Prefer a maintained compatible package fix. Use the normal reviewed dependency PR and locked installation. Do not use `npm audit fix --force` to obtain a green result. Run the affected lint, instruction and hook tests; changes to a parser or file-discovery package require behavior checks, not only a zero audit count. Keep raw advisory objects separate from package-level node lists. npm's `via` package references do not establish an individual advisory-to-path mapping.

The current [exception record](../.github/workflows/npm-risk-exceptions.json) is empty; an absent record also means no grants. Other read or parse failures remain errors. PR checks read authority from the trusted event's base commit. Main and scheduled runs read their acquired main commit. An already available exact commit needs no repeated fetch. Local runs use the fetched `origin/main` commit and print its identity; they cannot discover later remote updates or external revocations while offline. Fetch main before relying on a local result for acceptance. The merge executor must also check known owner revocations.

If a compatible repair is unavailable, prepare one scoped proposal with package root/name, advisory identifiers, node/version bounds, owner, reason, controls and UTC expiry. Existing approved bounds may cover fewer findings, but cannot cover a new advisory, node, version or package root. An unused expired record does not block a clean tree. A candidate cannot approve itself, and expiry never renews itself. New or expanded risk needs an authenticated owner decision and the existing independent review. The current implementation does not provide an exceptional merge route around a failing proposal check; resolve its actual required-check behavior before attempting such an admission. Do not bypass the ordinary check or invent a clean result.

CLI 0.23.3 declares Markdown 15.0.1, which falls within the publisher's [smartquotes advisory](https://github.com/markdown-it/markdown-it/security/advisories/GHSA-r7fv-28h4-cvq7). The manifests override only that parent's Markdown dependency to patched 15.0.2. Direct parser consumers stay on patched 14.3.2. Remove the scoped override when a reviewed CLI update supplies a patched parser itself. This substitution repairs the dependency; it is not an accepted-risk exception.
