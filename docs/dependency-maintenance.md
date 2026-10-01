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

The check validates both installed graphs and asks npm for current advisories against both locks. It runs once in the Markdown CI job on PRs and main pushes, and on a weekly schedule. It does not run a network audit on every commit. Each child has a two-minute deadline and a two-MiB output limit. A failed, malformed or incomplete report is an error. A clean registry result is current evidence, not a guarantee that no vulnerability exists.

| Result | Exit | Meaning |
| --- | ---: | --- |
| `CLEAN` | 0 | The current registry reports no affected package summary. |
| `ACCEPTED_RISK` | 0 | Current findings fit valid accepted exceptions; this is not clean. |
| `FINDINGS` | 1 | One or more findings lack applicable accepted authority. |
| `ERROR` | 2 | Tool, input, report, authority-read or cleanup failure. Exceptions cannot waive it. |
| `PROPOSAL` | 3 | The candidate changes exception authority. The ordinary check does not approve that change. |

Prefer a maintained compatible package fix. Use the normal reviewed dependency PR and locked installation. Do not use `npm audit fix --force` to obtain a green result. Run the affected lint, instruction and hook tests; changes to a parser or file-discovery package require behavior checks, not only a zero audit count. Keep raw advisory objects separate from package-level node lists. npm's `via` package references do not establish an individual advisory-to-path mapping.

The current [exception record](../.github/workflows/npm-risk-exceptions.json) is empty. PR checks read authority from the trusted event's base commit. Main and scheduled runs read their acquired main commit. Local runs use the fetched `origin/main` commit and print its identity; they cannot discover later remote updates or external revocations while offline. Fetch main before relying on a local result for acceptance. The merge executor must also check known owner revocations.

If a compatible repair is unavailable, prepare one scoped proposal with package root/name, advisory identifiers, node/version bounds, owner, reason, controls and UTC expiry. Existing approved bounds may cover fewer findings, but cannot cover a new advisory, node, version or package root. An unused expired record does not block a clean tree. A candidate cannot approve itself, and expiry never renews itself. New or expanded risk needs an authenticated owner decision and the existing independent review. The current implementation does not provide an exceptional merge route around a failing proposal check; resolve its actual required-check behavior before attempting such an admission. Do not bypass the ordinary check or invent a clean result.

CLI 0.23.3 declares Markdown 15.0.1, which falls within the publisher's [smartquotes advisory](https://github.com/markdown-it/markdown-it/security/advisories/GHSA-r7fv-28h4-cvq7). The manifests override only that parent's Markdown dependency to patched 15.0.2. Direct parser consumers stay on patched 14.3.2. Remove the scoped override when a reviewed CLI update supplies a patched parser itself. This substitution repairs the dependency; it is not an accepted-risk exception.
