<!-- markdownlint-disable MD013 -->

# Install and check repository dependencies

- **Status:** Active
- **Owner:** Repository maintainer (@franklesniak)
- **Last Updated:** 2026-10-05
- **Scope:** Locked npm and Python tools, the local Markdown hook, and current dependency-risk checks in PSStyleGuide.

Setup and audit require the exact Node and bundled npm versions declared in the root [package.json](../package.json). If either version differs, install or select that Node distribution before retrying. Check `node --version` and `npm --version`. The Linux CI bootstrap verifies its Node archive with `linuxX64Sha256` in [ci-toolchain.json](../.github/workflows/ci-toolchain.json); the exact versions remain in root `package.json` `engines`. From the repository root, run:

```text
node .github/workflows/NpmTools.mjs install
node .github/workflows/Check-NpmAudit.mjs
```

The first command installs both locked package trees with dependency lifecycle scripts disabled. It then runs the Husky installer explicitly, including in CI and production mode. Set `HUSKY=0` to suppress hook installation explicitly. A normal contributor clone gets staged Markdown validation, followed by the outer and nested repository lint checks. The staged check reads Git-index content, including nested Markdown fences, and requires the exact Node version in the root manifest.

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

The current [exception record](../.github/workflows/npm-risk-exceptions.json) is empty; an absent record also means no grants. Other read or parse failures remain errors. The `--ci` command selects hosted authority: PR checks read the trusted event's base commit, and main and scheduled runs read their acquired main commit. Unsupported hosted events remain errors. An already available exact commit needs no repeated fetch. The ordinary command without `--ci` uses the fetched `origin/main` commit and prints its identity, including inside a coding-agent environment that inherits GitHub Actions variables. It cannot discover later remote updates or external revocations while offline. Fetch main before relying on an ordinary result for acceptance. The merge executor must also check known owner revocations.

If a compatible repair is unavailable, prepare one scoped proposal with package root/name, advisory identifiers, node/version bounds, owner, reason, controls and UTC expiry. Existing approved bounds may cover fewer findings, but cannot cover a new advisory, node, version or package root. An unused expired record does not block a clean tree. A candidate cannot approve itself, and expiry never renews itself. New or expanded risk needs an authenticated owner decision and the existing independent review. The current implementation does not provide an exceptional merge route around a failing proposal check; resolve its actual required-check behavior before attempting such an admission. Do not bypass the ordinary check or invent a clean result.

Markdown lint uses the `markdownlint` library for full outer files, exact staged contents and nested snippets. All use the workflow rules file. The root lint commands delegate to the workflow package. The full outer caller runs the existing `--outer` child with a two-minute deadline and a two-MiB output limit. The direct instruction parser and nested extraction stay on patched `markdown-it` 14.3.2. The CLI dependency chains and scoped parser override are removed; no risk exception replaces them.

Run `npm run lint:md`, `npm run lint:md:nested`, and `node --test .github/workflows/lint-markdown.test.mjs` after a lint-tool change. The staged hook checks the index, including nested snippets, even when the worktree differs. Full-file lint discovers hidden `.md`/`.mdc` paths, excludes dependency directories, and validates regular in-repository inputs before the API. An empty discovered set succeeds explicitly. A path whose resolved target escapes the repository or whose leaf is a symlink is a tooling failure.

The supported rules input is `.github/workflows/.markdownlint.jsonc`, with `.markdownlint.json` in that directory as a fallback. JSONC comments are supported. Put rule changes in that file. Alternate or per-directory repository configuration files, CLI2 option files, ignore files and `extends` are refused rather than silently skipped or merged. The API receives explicit parsed rules and named contents; ambient `markdownlint_` environment settings and home/system/ancestor rc selectors are not loaded. Literal filenames are data, including option-shaped or glob-metacharacter names. Introduced patterns cannot enter the removed braces expansion path. This does not provide atomic confinement against a competing filesystem writer.

Lint wrappers return 0 for success, 1 for actual lint findings and 2 for missing tools, invalid inputs or other tooling failures. A full-file child failure reports its native status before normalization; timeout, output-limit and launch failures retain their cause. Correct the reported cause; do not replace an applicable failed check with a different input.

## Install Python hooks

Use Python 3.12 for both installation and pre-commit. On Windows, run:

```powershell
py -3.12 -m pip --isolated install --require-hashes --only-binary=:all: --index-url https://pypi.org/simple -r requirements-dev.txt
py -3.12 -m pre_commit run --all-files
```

On Linux, use a Python 3.12 virtual environment. On Ubuntu 24.04, install its venv support first with `sudo apt-get install python3.12-venv`; see [Ubuntu's Python setup guidance](https://documentation.ubuntu.com/ubuntu-for-developers/howto/python-setup/) for package prerequisites. From the repository root, run these commands in a Bash-compatible shell:

```sh
python3.12 -m venv .venv
. .venv/bin/activate
python3.12 -m pip --isolated install --require-hashes --only-binary=:all: --index-url https://pypi.org/simple -r requirements-dev.txt
python3.12 -m pre_commit run --all-files
```

Keep that virtual environment active when running the Python hooks. The launcher selects its `python3.12` application from `PATH`. The virtual environment supplies pip and keeps installed packages separate from Ubuntu's externally managed system Python.

The hashed [requirements closure](../requirements-dev.txt) supplies the Python hooks. The [launcher](../.github/workflows/Invoke-LockedPythonHook.ps1) selects Python 3.12 and invokes only its listed modules. It uses `-E -P` to ignore Python environment variables and exclude the unsafe current-directory import path; it does not attest installed package bytes or exclude every site-package source. Install the closure into the interpreter that the launcher selects. The remote actionlint hook retains its exact reviewed Git revision and checksummed Go dependencies.
