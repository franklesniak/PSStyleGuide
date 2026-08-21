---
applyTo: "**/*.yml,**/*.yaml"
description: "YAML authoring standards: explicit, conservative, schema-backed, and safe."
---

<!-- markdownlint-disable MD013 -->

# YAML Writing Style

**Version:** 1.6.20260821.5

## Metadata

- **Status:** Active
- **Owner:** Repository Maintainers
- **Last Updated:** 2026-08-21
- **Scope:** Defines authoring standards for all YAML files in this repository, including GitHub Actions workflows, Azure Pipelines YAML, pre-commit configuration, linter configuration, and any other human-authored YAML configuration. Does not cover JSON files (covered by the companion JSON guide, if present) or generated YAML artifacts that are owned by another tool's serializer.
- **Related:** [Repository Copilot Instructions](../copilot-instructions.md), [`.gitattributes` Rules](./gitattributes.instructions.md)

## Purpose and Scope

YAML in this repository is the preferred format for **human-authored configuration** that benefits from comments, multi-line strings, and a forgiving syntax for editors (workflow files, pre-commit configs, linter configs, application config files committed to source control). JSON is preferred for **strict machine interchange** and for **generated artifacts** (lock files, schema documents, tool outputs, structured data exchanged between systems).

To keep YAML safe to edit, easy to diff, and portable across parsers, this repository adopts a **conservative, tool-friendly subset** of YAML 1.2. Authors **MUST** prefer explicit, unambiguous constructs over clever or compact YAML features that vary by parser.

> **Note:** This document uses [RFC 2119](https://www.rfc-editor.org/rfc/rfc2119) keywords (**MUST**, **MUST NOT**, **SHOULD**, **SHOULD NOT**, **MAY**) to indicate requirement levels.

## Quick Reference Checklist

- **[All]** **MUST** use 2-space indentation; **MUST NOT** use tabs.
- **[All]** **MUST** use block style by default; **SHOULD NOT** use flow style for non-trivial structures.
- **[All]** **MUST** use lowercase `true`, `false`, and `null`; **MUST NOT** use `yes`/`no`/`on`/`off` (or capitalized variants) as booleans.
- **[All]** **MUST** quote values that could be misparsed as booleans, nulls, numbers, dates, or YAML 1.1 truthy tokens.
- **[All]** **MUST** quote version pins (for example, `"3.13"`, `"1.0"`) so they cannot be coerced to numbers.
- **[All]** **SHOULD** use double quotes only when escape sequences are needed; **SHOULD** use single quotes for literal regexes and Windows paths.
- **[All]** **SHOULD** use block scalars (`|`, `>`, `|-`, `>-`) for multi-line strings.
- **[All]** **SHOULD NOT** use anchors, aliases, merge keys, custom tags, or multi-document files unless required and supported by the consumer.
- **[All]** **MUST NOT** commit secrets in YAML.
- **[Actions]** **MUST** apply least-privilege `permissions:` on GitHub Actions workflows.
- **[Actions]** A privileged `pull_request_target` workflow **MUST** execute only trusted-revision bytes. Proposed files that select executable bytes **MUST** fail closed as trust-root changes or pass bounded inert-data validation by trusted code.
- **[Actions]** A privileged workflow that fetches a proposed pull-request revision into a persistent local ref **MUST NOT** force-update that ref. It **MUST** verify that the fetched commit equals the expected event commit.
- **[Actions]** A path-scoped `push` workflow **MUST** define branch and tag intent explicitly. GitHub does not evaluate `paths` or `paths-ignore` for tag pushes.
- **[Actions]** `setup-*` actions in workflow files under `.github/workflows/` **MUST** resolve runtimes from checked-in release-line selectors by default and **MUST NOT** use broad floating selectors such as `'3.x'`, `'latest'`, or `'*'`. `actions/setup-node` **MAY** instead use `node-version-file` only when a tracked file supplies one unambiguous exact stable SemVer, no competing `node-version` input exists, and a later step verifies the installed Node.js version against the same source. The full conditions and ecosystem granularity rules are in [GitHub Actions Setup Version Pins](#github-actions-setup-version-pins).
- **[AzurePipelines]** Repositories that use Azure Pipelines language/runtime/SDK tool-installer tasks **MUST** explicitly provide checked-in compliant selectors for in-scope `version` or `versionSpec` inputs and **MUST NOT** rely on broad task defaults, queue-time-only values, `"latest"`, bare `"*"`, comparator/operator ranges, or composite ranges.
- **[AzurePipelines]** Azure Pipelines YAML **MUST** pass retained host-neutral local YAML hooks, and pipeline schema/branch-policy validation **MUST** be treated as Azure DevOps Services-backed validation rather than `actionlint`.
- **[Actions]** Documentation/navigation comments above `uses:` lines **MUST** use versionless upstream URLs; the `uses:` line remains the authoritative action version.
- **[Actions]** Comments documenting where a GitHub Actions `with:` tool-version input is pinned, or that such a value must stay aligned across files, **SHOULD** describe the membership criterion instead of a hardcoded workflow-file list; if a concrete file list is included for convenience, it **SHOULD** be labeled as a non-authoritative snapshot.
- **[Actions]** Optional `workflow_dispatch` string inputs that also need defaults on non-dispatch triggers **SHOULD** derive the effective value from a single source, using a fallback only in keys where the needed contexts are available, rather than duplicating an unmarked input `default:` and `env:` literal.
- **[Schemas]** Schema-backed YAML **MUST** pass any schema validator wired into pre-commit or CI; where no validator is wired up for a particular file family, authors **SHOULD** run the appropriate validator locally before committing.
- **[Naming]** YAML filenames **SHOULD** be lowercase kebab-case; GitHub Actions workflows **MUST** use the `.yml` extension; project-owned YAML **MUST** choose `.yml` or `.yaml` and use it consistently.
- **[IssueForms]** In `.github/ISSUE_TEMPLATE/*.yml`, repo-internal targets in both issue-form `value:` Markdown links (e.g., `bug_report.yml`) and `config.yml` `contact_links` `url:` fields **MUST** use absolute GitHub URLs. An unresolved live adopter-substitution URL in this repository **MUST** use the literal `OWNER/REPO` convention, such as `https://github.com/OWNER/REPO/blob/HEAD/<path>` for a file link; `<owner>/<repo>`, `<OWNER>/<REPO>`, and `your-org/your-repo` **MUST NOT** be used for that live role. A schematic URL after substitution MAY use `<owner>/<repo>` metasyntactically, but the final rendered URL still needs the real host, owner, and repository. Relative paths **MUST NOT** be used. The two file types fail for different reasons: `value:` Markdown blocks render at `/{owner}/{repo}/issues/new?...` so relative paths resolve against that URL and 404, while `contact_links` `url:` fields are not Markdown at all — GitHub validates them as absolute URLs at form-load time and rejects relative values outright.

## Dialect and Consumer Policy

- Authors **SHOULD** target **YAML 1.2-compatible** values and avoid relying on parser-specific extensions.
- Authors **MUST** avoid the YAML 1.1 *non-lowercase-`true`/`false`* truthy tokens that this guide does not permit as booleans (`y`, `Y`, `yes`, `Yes`, `YES`, `n`, `N`, `no`, `No`, `NO`, `on`, `On`, `ON`, `off`, `Off`, `OFF`, `True`, `TRUE`, `False`, `FALSE`); only lowercase `true` and `false` are allowed as booleans (see "Booleans, Nulls, and Numbers"). Many widely-deployed parsers (including those used by GitHub Actions, `js-yaml` defaults, and some legacy PyYAML configurations) still resolve some or all of these YAML 1.1 tokens as booleans, so any string value that would otherwise match one of them **MUST** be quoted.
- Ecosystem-specific validators (for example, Kubernetes manifest validators, OpenAPI validators, Helm validators, Ansible validators) **SHOULD** be adopted only when the repository actually uses those ecosystems. Generic YAML guidance **MUST NOT** require validators that are irrelevant to the repository's stack. The repository's pre-commit configuration and CI definitions are the authoritative inventory of active YAML validators.

## Formatting Rules

- Indentation **MUST** be exactly **2 spaces** per level. Tabs **MUST NOT** appear in YAML files.
- Block style **MUST** be the default for mappings and sequences. Flow style (`{key: value}`, `[a, b, c]`) **MAY** be used only for short, obviously-bounded inline values where block style would be visually disruptive.
- Document separators (`---`, `...`) **SHOULD NOT** appear in single-document files. Multi-document YAML files **MAY** use `---` separators when the consumer requires multi-document input (for example, Kubernetes manifest bundles) or when the file format mandates a leading `---`.
- Files **SHOULD NOT** contain trailing whitespace and **SHOULD** end with a single newline. Line-ending, BOM, EOF newline, and trailing-whitespace policy at the Git layer is owned by [`.gitattributes` Rules](./gitattributes.instructions.md); this guide does not duplicate or contradict it.

## Quoting Rules

Authors **MUST** quote any scalar that a YAML 1.2 (or YAML 1.1) parser could resolve as a non-string type when a string is intended. In particular:

- Values that match boolean, null, integer, float, hex, octal, binary, or sexagesimal patterns when a string is intended.
- Values that match RFC 3339 / ISO 8601 timestamp patterns when intended as strings, **unless** the specific parser's behavior is known and tested for that value.
- Values that match any YAML 1.1 truthy token (see "Dialect and Consumer Policy" above) when a string is intended.
- Values that begin with YAML special syntax characters (`&`, `*`, `!`, `|`, `>`, `%`, `@`, the backtick character, `#`, `,`, `[`, `]`, `{`, `}`, `?`, `:` followed by space) where the parser would otherwise interpret them.

Version pins **MUST** be quoted. Common examples:

```yaml
python-version: "3.13"
api-version: "1.0"
node-version: "24"
```

Without quotes, `3.13` is parsed as the float `3.13` (which compares equal to `3.130`), `1.0` is parsed as the float `1.0` (which loses the trailing zero), and `24` is parsed as the integer `24`.

Quote style guidance:

- Use **double quotes** when escape sequences are required (for example, `"line1\nline2"`, `"tab\there"`).
- Use **single quotes** for literal regular expressions, Windows paths, and other strings that contain backslashes intended literally (for example, `'C:\Users\runner'`, `'^v\d+\.\d+\.\d+$'`).
- Use **block scalars** (`|`, `>`, `|-`, `>-`) for multi-line strings instead of long quoted scalars with embedded `\n` sequences.

## Booleans, Nulls, and Numbers

- The only booleans that **MUST** appear in YAML are lowercase `true` and `false`.
- The only null literal that **MUST** appear is lowercase `null`. Authors **MAY** omit a value entirely when the consumer treats absent and null identically; otherwise, write `null` explicitly.
- Authors **MUST NOT** use `yes`, `no`, `on`, `off`, `True`, `False`, `TRUE`, or `FALSE` as booleans.
- Numbers intended as numbers **SHOULD** be written without quotes. Numbers intended as **strings** (version pins, ZIP codes, account IDs, leading-zero identifiers) **MUST** be quoted.

## GitHub Actions `on:` Key

The GitHub Actions workflow trigger key `on:` is a well-known YAML 1.1 truthy hazard. Under YAML 1.1 resolution rules, the unquoted bare key `on` is parsed as the boolean `true`. GitHub Actions itself parses workflows correctly because it does not rely on YAML 1.1 truthy resolution for keys, but **lint tooling** that is YAML 1.1-aware (notably `yamllint`'s `truthy` rule) will flag the `on:` key as a truthy violation by default.

Repositories that lint GitHub Actions workflow YAML with `yamllint` SHOULD configure the `truthy` rule so key names are not treated as booleans. In `yamllint`, that means setting `truthy.check-keys: false`:

```yaml
rules:
  truthy:
    check-keys: false
```

This configuration preserves the idiomatic GitHub Actions `on:` key while still flagging YAML 1.1 truthy hazards in **values**. Authors **MAY** alternatively quote the key as `"on":` to satisfy a stricter `truthy.check-keys: true` configuration, but this form is **non-idiomatic** in the GitHub Actions ecosystem and **SHOULD NOT** be adopted unless a repository policy requires it.

## GitHub Actions Push Ref and Path Scope

GitHub does not evaluate `on.push.paths` or `on.push.paths-ignore` for tag pushes. A `push` workflow that uses a path filter **MUST** define its branch and tag intent explicitly. Do not assume that a path filter restricts tag events. See [GitHub's workflow syntax for path filters](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#onpushpull_requestpull_request_targetpathspaths-ignore).

For a branch-only workflow that must cover all branches, define only the positive branch filter and keep the path filter:

```yaml
on:
  push:
    branches:
      - "**"
    paths:
      - .github/workflows/example.yml
```

When a workflow defines only `branches` or `branches-ignore`, GitHub does not run it for tag pushes. GitHub applies branch and path filters together, so both filters must accept a branch push before the workflow runs. See [GitHub's branch and tag filter syntax](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#onpushbranchestagsbranches-ignoretags-ignore).

If a workflow must run for tags, define `tags` or `tags-ignore` deliberately and design the tag behavior as a separate event contract. A tag-enabled workflow **MUST NOT** rely on `paths` or `paths-ignore` to select tag events.

## GitHub Actions Privileged-Workflow Trust Roots

GitHub runs `pull_request_target` in the base repository's default-branch context. This context can have privileges that an ordinary pull-request workflow does not have. A `pull_request_target` workflow **MUST NOT** check out or execute untrusted pull-request code. See [GitHub's event reference](https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#pull_request_target) and [secure-use reference](https://docs.github.com/en/actions/reference/security/secure-use#mitigating-the-risks-of-untrusted-code-checkout).

The executable trust root includes all checked-in files that can select or alter executable bytes in the privileged job. The inventory **MUST** include applicable files from these categories:

- Workflow YAML and local actions.
- Scripts, helpers, interpreters, and runtime selectors.
- Package manifests, lockfiles, and shrinkwrap files.
- Project package-manager configuration.
- Container files, build inputs, and generated executable tools.

Path filters **MUST** cover every supported file in this inventory. A proposed change **MUST NOT** bypass the validation job because the changed selector is absent from `on.pull_request_target.paths`.

A proposed trust-root change **MUST** use one of these controls:

1. Reject the change in the privileged job. Update the trusted revision through the repository's authorized trust-root process.
2. Validate the proposed file as inert data with trusted code. Do not execute the proposed file.

Inert-data validation **MUST** read the exact proposed Git object without replacing trusted workspace files. It **MUST** validate the object type, byte limit, encoding, syntax, required semantic identity, and every error or indeterminate state. Store proposed revision values in environment variables or pass them as action inputs. Do not interpolate untrusted values into generated shell source.

When a privileged job fetches a proposed pull-request revision into a persistent local ref, the fetch **MUST NOT** use a leading `+` refspec or `--force`. An unexpected non-fast-forward destination state **MUST** stop the job. After the fetch, the workflow **MUST** resolve the fetched commit and compare it with the expected event commit before it reads proposed objects. A fetch that writes only `FETCH_HEAD` does not update a persistent local ref, but it still **MUST** perform the same exact-commit comparison.

A privileged job **MUST NOT** install, import, source, or execute proposed dependency bytes. Options such as npm's `--ignore-scripts` stop lifecycle scripts, but they do not make proposed package code trusted.

When a trusted parser validates proposed documents, the proposed post-merge package state **MUST** preserve the exact parser identity and its resolved runtime dependency closure. Otherwise, the privileged job **MUST** reject the proposal as a trust-root change. The validation **SHOULD** compare the manifest declaration, root lock declaration, version, resolved artifact, integrity value, dependency paths, and dependency descriptors.

For npm, the effective install input can include `package.json`, `package-lock.json`, `npm-shrinkwrap.json`, and `.npmrc`. `npm-shrinkwrap.json` takes precedence over `package-lock.json` when both files exist. Project configuration can also change install behavior. A workflow **MUST** reject, pin, or validate each applicable surface. See the [npm lockfile format](https://docs.npmjs.com/cli/v11/configuring-npm/package-lock-json/) and [`npm ci` contract](https://docs.npmjs.com/cli/v11/commands/npm-ci/).

Mutation tests **SHOULD** cover dependency deletion, direct-version drift, root-lock drift, artifact-integrity drift, transitive-closure drift, dependency shadowing, malformed or oversized input, non-blob objects, alternate lockfile precedence, and package-manager configuration additions.

An unprivileged `pull_request` install test **MAY** add defense in depth. It does not authorize proposed-code execution in a privileged `pull_request_target` job.

**Compliant pattern:**

```yaml
permissions:
  contents: read

jobs:
  validate:
    runs-on: ubuntu-24.04
    steps:
      - name: Check out the trusted revision
        uses: actions/checkout@v7
        with:
          ref: ${{ github.sha }}
          persist-credentials: false

      - name: Fetch the proposed head as Git objects
        env:
          PR_HEAD_SHA: ${{ github.event.pull_request.head.sha }}
        run: ./trusted-fetch-helper "${PR_HEAD_SHA}"

      - name: Validate proposed manifests as inert data
        env:
          INPUT_REVISION: ${{ github.event.pull_request.head.sha }}
          TRUSTED_REVISION: ${{ github.sha }}
        run: >-
          node ./trusted-manifest-validator.mjs
          --trusted-revision "${TRUSTED_REVISION}"
          --input-revision "${INPUT_REVISION}"

      - name: Install only trusted dependencies
        run: npm ci --ignore-scripts --include=dev
```

The trusted fetch helper in this pattern must validate the revision, use a host-scoped credential, fetch only Git objects, verify the fetched identity, and leave the trusted worktree unchanged. The manifest validator must also come from the trusted checkout.

**Non-compliant patterns:**

```yaml
# Non-compliant: checks out and executes the proposed tree in a privileged job.
- uses: actions/checkout@v7
  with:
    ref: ${{ github.event.pull_request.head.sha }}
- run: npm ci

# Non-compliant: replaces trusted manifests before dependency installation.
- run: |
    git show "${PR_HEAD_SHA}:package.json" > package.json
    git show "${PR_HEAD_SHA}:package-lock.json" > package-lock.json
    npm ci --ignore-scripts
```

## GitHub Actions Setup Version Pins

GitHub Actions workflow files under `.github/workflows/` that use `setup-*` actions **MUST** pass checked-in release-line selectors to `with.*-version:` inputs such as `python-version`, `node-version`, `go-version`, and `dotnet-version`. Broad floating selectors such as `'3.x'`, `'latest'`, and `'*'` **MUST NOT** be used for these inputs. When a setup action input is fed by indirection, such as a checked-in matrix value, every checked-in value that can feed the selector **MUST** satisfy the same rule.

A narrow single-source exception applies only to `actions/setup-node`. A workflow **MAY** use `node-version-file` instead of `node-version` when all of these conditions are true:

- The referenced version file is tracked in the repository and comes from the reviewed revision.
- The pinned setup-node action documents support for the referenced file format.
- The field that setup-node selects contains one exact stable SemVer, such as `24.18.0`. Ranges, wildcards, aliases, release channels, prerelease versions, and external or generated values do not qualify for this exception.
- The source is unambiguous. For `package.json`, account for setup-node's documented precedence: `volta.node`, then the `devEngines.runtime` entry whose `name` is `node`, then `engines.node`, followed by a supported `volta.extends` target. Higher-precedence fields **MUST** be absent or intentionally aligned with the field that the repository declares authoritative.
- The setup-node step **MUST NOT** also supply `node-version`. Setup-node gives `node-version` priority when both inputs exist, which would make the file non-authoritative.
- A later step **MUST** read the same canonical field and verify that `node --version` equals the exact expected version before tool-dependent installation or validation continues.

This exception prevents duplicated exact patch pins while keeping resolution drift visible. It does not weaken the release-line default for other setup actions or for repositories that do not intentionally maintain a patch-exact Node.js contract. See the official [setup-node version-file documentation](https://github.com/actions/setup-node/blob/v7/docs/advanced-usage.md#node-version-file) for supported files and precedence.

Repositories that use Azure Pipelines language/runtime/SDK tool-installer tasks **MUST** explicitly provide checked-in selectors for in-scope `version` and `versionSpec` inputs. This Azure Pipelines rule is construct-conditional: it applies wherever Azure Pipelines YAML is stored when the repository uses those tasks, including repository-root `azure-pipelines.yml`, configured custom pipeline paths, and `.azuredevops/` pipeline layouts. It is not limited to one hardcoded directory name.

The Azure Pipelines selector may be provided by a literal task input, a checked-in parameter default, a checked-in parameter `values:` entry, a checked-in variable or matrix value, or a checked-in repository version file such as `.nvmrc` when the task supports reading the selector from a file. Values supplied only at queue time or from external, non-repository sources do not satisfy this rule. For top-level parameters that feed a selector, the checked-in default **MUST** be compliant; if the parameter can be changed at queue time, constrain `values:` to compliant selectors where practical, or document that static YAML review can guarantee only the checked-in default.

In-scope Azure Pipelines tasks include both `version`- and `versionSpec`-named inputs:

- `UseNode@1` `version`.
- `NodeTool@0` `versionSpec`, for legacy pipelines. When `NodeTool@0` uses `versionSource: fromFile`, the referenced repository file, such as `.nvmrc`, **MUST** contain a compliant, reviewable release-line selector.
- `UsePythonVersion@0` `versionSpec`.
- `GoTool@0` `version`.
- `UseDotNet@2` `version` when `useGlobalJson` is not used.

`UseRubyVersion@0`'s documented default selector `>= 2.4` is non-compliant with this explicit-selector rule and determinism rationale. This guide does not define durable compliant Ruby selector forms or Ruby granularity rules.

The required selector granularity follows each ecosystem's release model. These bullets define the coarsest acceptable selector form, not recommended runtime currency:

- Python **MUST** use major.minor selectors, such as `"3.13"`.
- Node.js **MAY** use a major selector for an LTS line, such as `"24"`, or a major.minor selector, such as `"24.17"`.
- .NET **MAY** use the most specific stable SDK channel selector documented by the setup action or tool-installer task, such as major.minor.x (`"10.0.x"`), or an exact major.minor.patch version. For `UseDotNet@2`, bare major.minor such as `"10.0"` is not a valid `version` form.
- Go **MUST** use major.minor selectors, such as `"1.26"`.
- Other ecosystems **MUST** use the most specific stable release-line selector documented by the setup action or tool-installer task.

Selectors narrower than the coarsest acceptable form are also compliant for ecosystems where exact versions are covered by the task or action behavior, because they are at least as deterministic. For Microsoft-hosted Azure Pipelines agents, tool-cache tasks such as `UseNode@1`, `NodeTool@0`, `UsePythonVersion@0`, and `GoTool@0` resolve the newest installed or available version matching the selector, and an exact patch that is not pre-installed may need to be downloaded or may be unavailable. Prefer the release-line granularity above for those tasks unless an exact pin is specifically required. On self-hosted agents, `UsePythonVersion@0` cannot download missing Python versions, so exact Python pins require the desired version to be present in the agent tool cache. `UseDotNet@2` is less dependent on preinstalled hosted-agent contents because it is designed to acquire the requested SDK or runtime from the internet or local cache.

The distinction between allowed and prohibited selectors is granularity per ecosystem, not `.x` spelling by itself. For Node.js selectors whose task or action uses SemVer X-range rules, `"24"`, `"24.x"`, and `"24.*"` all select the Node.js 24 line. Prefer bare-major `"24"` for readability, but do not classify `"24.x"` as prohibited when a Node major selector is allowed. By contrast, `"3.x"` is prohibited for Python because Python selectors must be at least major.minor.

Range-style Azure Pipelines tasks such as `UseNode@1`, `NodeTool@0`, and `UsePythonVersion@0` **MUST NOT** use bare `"*"`, comparator/operator ranges such as `">=18.0.0"`, `">=20 <21"`, `"^20.0.0"`, or `"~20.18.0"`, or composite/OR ranges such as `"20 || 22"`. These expressions are rejected because they are not direct, reviewable release-line selectors for this guide's CI-determinism rule, even when their breadth appears close to an allowed release line. Channel-syntax tasks such as `UseDotNet@2` **MUST NOT** use a selector broader than the required channel granularity; `"10.x"` is task-valid but guide-noncompliant because this guide requires the narrower `"10.0.x"` channel or an exact SDK/runtime version. `GoTool@0` **MUST NOT** use a selector broader than major.minor. `"latest"` **MUST NOT** be used for any in-scope language/runtime/SDK toolchain selector.

For tasks exposing `checkLatest`, such as `UseNode@1` and `NodeTool@0`, `checkLatest: true` **SHOULD NOT** be used on Microsoft-hosted agents unless re-resolution to the newest matching version is intentional and documented. Because the default is already `false`, an explicit `checkLatest: false` is illustrative, not required. `UsePythonVersion@0`, `UseDotNet@2`, and `GoTool@0` do not expose `checkLatest`; do not add that input to those tasks. For tasks exposing prerelease or preview toggles, such as `UsePythonVersion@0` `allowUnstable` and `UseDotNet@2` `includePreviewVersions`, `true` **SHOULD NOT** be used unless the workflow intentionally tests prerelease versions and documents that intent.

This rule protects CI determinism. Broad floating selectors and hidden task defaults couple workflow results to runner-image refreshes, setup action manifests, task defaults, tool-cache contents, and download resolution behavior. A runner, task, or toolchain refresh can then move CI to a different interpreter, runtime, or SDK line and break a previously passing workflow even though the workflow file did not change.

This is a stronger, separate rule from the requirement to quote all version pins. Quoting keeps YAML parsers from coercing version-looking strings to numbers; release-line specificity keeps setup actions and tool-installer tasks from resolving to a different runtime line over time.

Example version numbers in this section reflect supported release lines at authoring time and may be refreshed when they reach end-of-life. The normative rule is the selector form and checked-in provenance, not the specific version number shown.

This section is limited to GitHub Actions setup actions and Azure Pipelines language/runtime/SDK toolchain installers. It does not cover Azure Pipelines CLI installers such as `KubectlInstaller@0`, `HelmInstaller@1`, or `KubeloginInstaller@0`; Azure Pipelines agent image labels such as `vmImage: "ubuntu-latest"`; `JavaToolInstaller@0` or `JavaToolInstaller@1`; `UseDotNet@2` with `useGlobalJson: true`; runtime currency or end-of-life policy for any toolchain; or Terraform and TFLint versions installed through shell commands instead of Azure `Use*` or `*Tool` task selectors.

**Compliant:**

```yaml
- uses: actions/setup-python@v6
  with:
    python-version: "3.13"

- uses: actions/setup-node@v6
  with:
    node-version: "24"

- uses: actions/setup-dotnet@v4
  with:
    dotnet-version: "10.0.x"
```

**Compliant exact Node.js version-file exception:**

The tracked `package.json` contains one exact Node.js source:

```json
{
  "engines": {
    "node": "24.18.0"
  }
}
```

The workflow uses and verifies that same source:

```yaml
- uses: actions/checkout@v7

- uses: actions/setup-node@v7
  with:
    node-version-file: package.json

- name: Verify the exact Node.js runtime
  shell: bash
  run: |
    set -euo pipefail
    expected_node="$(node -p 'require("./package.json").engines.node')"
    test "$(node --version)" = "v${expected_node}"
```

**Compliant Azure Pipelines:**

```yaml
parameters:
  - name: nodeVersion
    type: string
    default: "24"
    values:
      - "24"
      - "22"
  - name: pythonVersion
    type: string
    default: "3.13"
    values:
      - "3.13"
      - "3.14"

steps:
  - task: UseNode@1
    inputs:
      version: ${{ parameters.nodeVersion }}
      # checkLatest defaults to false; shown for emphasis only.
      checkLatest: false

  - task: UsePythonVersion@0
    inputs:
      versionSpec: ${{ parameters.pythonVersion }}

  - task: UseDotNet@2
    inputs:
      version: "10.0.x"

  - task: GoTool@0
    inputs:
      version: "1.26"
```

**Non-compliant:**

```yaml
- uses: actions/setup-python@v6
  with:
    python-version: '3.x'

- uses: actions/setup-python@v6
  with:
    python-version: 'latest'

- uses: actions/setup-dotnet@v4
  with:
    dotnet-version: '10.x'
```

These setup-node forms are also non-compliant:

```yaml
# Non-compliant: node-version overrides node-version-file, so package.json
# is not the effective source.
- uses: actions/setup-node@v7
  with:
    node-version: "24.18"
    node-version-file: package.json

# Non-compliant under the exact-version-file exception: no later step
# verifies the installed runtime against the same exact source.
- uses: actions/setup-node@v7
  with:
    node-version-file: package.json
```

A `package.json` is also non-compliant when a higher-precedence setup-node field conflicts with the field that the repository claims is authoritative. For example, `devEngines.runtime` selecting `24.18.1` conflicts with a claimed `engines.node` lock of `24.18.0`.

**Non-compliant Azure Pipelines:**

```yaml
steps:
  - task: UseNode@1
    # Non-compliant: relies on the task's default selector.

  - task: UsePythonVersion@0
    inputs:
      versionSpec: "3.x"
      allowUnstable: true

  - task: UseDotNet@2
    inputs:
      version: "10.x"
      includePreviewVersions: true

  - task: NodeTool@0
    inputs:
      versionSpec: ">=18.0.0"
      checkLatest: true

  - task: UseRubyVersion@0
    # Non-compliant: relies on the task's documented broad default selector.
```

## GitHub Actions Documentation Comment URLs

Comments of the form `# see: https://github.com/<owner>/<repo>/...` (or equivalent navigation-aid comments) placed above a `uses:` line in any GitHub Actions workflow file under `.github/workflows/` **MUST** use a versionless URL. Prefer `https://github.com/<owner>/<repo>/releases/latest` when the action publishes GitHub Releases; otherwise use another versionless upstream project, documentation, or changelog URL, such as the action's README on the default branch (`https://github.com/<owner>/<repo>#readme`) or the upstream project's documentation site.

These comment URLs **MUST NOT** embed a specific tag, version branch, or version such as `/releases/tag/v6.0.2`, `/tree/v3`, or `/blob/v1.2.3/...`, unless the comment is intentionally documenting a specific historical release.

The authoritative action version is the `uses: <owner>/<repo>@<ref>` line itself and, where applicable, the SHA pin. Documentation URLs in comments are navigation aids and **SHOULD** point readers to current upstream release or project information.

If a comment must reference a specific historical release, for example a changelog note documenting a breaking change, the comment **MUST** state that intent explicitly so it is obvious the URL is intentionally pinned and should not be auto-updated.

This rule applies to all workflow files under `.github/workflows/` and to any other YAML location where `# see:` comments document an action version.

This rule applies only to documentation/navigation comments. It **MUST NOT** affect the `uses:` line itself, action input values, SHA pins, version pins, or any other intentionally pinned executable configuration.

The `<owner>/<repo>` placeholder used throughout this section is **metasyntactic** — it stands for any upstream GitHub Actions repository (for example, `actions/checkout`, `peter-evans/create-pull-request`). It is **not** a template-adopter substitution placeholder for the current repository. Authors **MUST NOT** rewrite metasyntactic `<owner>/<repo>` references in workflow comments to a repository-specific placeholder, and adopters **MUST NOT** substitute their repository name into these metasyntactic references.

Pinned documentation URLs go stale because Dependabot updates `uses:` references but does not rewrite arbitrary adjacent comment text.

**Compliant:**

```yaml
# See: https://github.com/actions/checkout/releases/latest
- uses: actions/checkout@v6

# Documentation: https://github.com/actions/setup-python#readme
- uses: actions/setup-python@v6
```

**Non-compliant:**

```yaml
# See: https://github.com/actions/checkout/releases/tag/v6.0.2
- uses: actions/checkout@v6

# Documentation: https://github.com/actions/setup-python/tree/v6
- uses: actions/setup-python@v6
```

<!-- RATIONALE: github-actions-documentation-comment-urls -->

## GitHub Actions Tool-Version Alignment Comments

Prefer a single source of truth for repeated tool-version values where GitHub Actions supports one, such as a workflow-level `env:` value for versions used by multiple steps in one workflow. This guidance covers the residual cross-file case where a GitHub Actions `with:` tool-version input is still pinned in more than one place; it does not endorse duplicating tool versions unnecessarily.

Comments in workflow files under `.github/workflows/` that document where a GitHub Actions `with:` tool-version input is pinned, or state that such a value must be kept in sync across the repository, **SHOULD** describe the membership criterion rather than enumerate a hardcoded list of filenames that nothing keeps in sync. For example, prefer "every `tflint_version:` input passed to `terraform-linters/setup-tflint` under `.github/workflows/`" over a fixed list of workflow filenames.

The criterion **SHOULD NOT** embed the setup action's version (for example, `@v6`), because that action version is a separate Dependabot-managed `uses:` pin and can itself go stale inside comment text. This differs from pinned documentation URLs: tool-version inputs such as `terraform_version` and `tflint_version` are manually maintained CLI/tool versions, so their comment drift comes from unsynchronized manual edits that move, add, or remove pins.

If a concrete file list is included for convenience, it **SHOULD** be marked as a non-authoritative snapshot, for example by prefixing it with "currently," so a stale list does not mislead. This mirrors the repository-wide documentation principle that every list of "things" should be complete or explicitly labeled as partial, and the general YAML comment guidance that comments should explain durable context rather than restate fragile details.

This guidance applies to comments in workflow files under `.github/workflows/` and, advisorily, to comments in any other file that references these workflow pins, such as a script that hardcodes the same tool version. For non-YAML files this is advisory only because this guide's `applyTo` scope is YAML.

**Compliant:**

```yaml
# Keep this tflint_version aligned with every other tflint_version input
# passed to terraform-linters/setup-tflint under .github/workflows/.
- uses: terraform-linters/setup-tflint@v6
  with:
    tflint_version: "v0.51.1"
```

**Non-compliant:**

```yaml
# This tflint_version must match terraform-ci.yml and auto-fix-precommit.yml.
- uses: terraform-linters/setup-tflint@v6
  with:
    tflint_version: "v0.51.1"
```

## GitHub Actions Input Default Single Source of Truth

The single-source-of-truth principle above also applies when a GitHub Actions workflow exposes an optional `workflow_dispatch` string input whose blank value should fall back to a default used by non-dispatch triggers. A `workflow_dispatch` input `default:` pre-fills or supplies the manual-dispatch input path; it is not a workflow-wide default for `push`, `pull_request`, `schedule`, or other non-dispatch events.

When an optional `workflow_dispatch` string input needs the same default on manual and non-dispatch triggers, authors **SHOULD** define that default in one place and derive the effective value from the input. They **SHOULD NOT** duplicate an unmarked literal in both the input `default:` and a workflow- or job-level `env:` value that nothing keeps in sync.

Use a workflow- or job-level `env:` value as the single source when more than one step consumes the default. For a single consumer, an inline literal fallback such as `${{ inputs.<name> || 'literal' }}` is acceptable. A `vars` value is also acceptable when the durable source of truth intentionally lives in repository, organization, or environment settings rather than in the workflow file.

Prefer expression fallback only in workflow keys where GitHub's context-availability rules permit both `inputs` and the chosen default context. Step-level `env:` and step `with:` are common safe locations for `${{ inputs.<name> || env.<NAME> }}`. Do not present that expression as valid in every workflow key: for example, the `env` context is not available at `jobs.<job_id>.env`, even though `inputs` is available there.

Do not make direct expression interpolation inside `run:` the preferred shell pattern. For inline scripts, map the expression into a step `env:` variable and reference the quoted shell variable in `run:`. This follows GitHub's intermediate-environment-variable pattern for handling untrusted input and avoids shell word splitting.

Treat free-form manual string inputs conservatively as user-supplied. A shell fallback such as quoted `[ -z "$x" ]` is acceptable only as a shell-step-scoped alternative, and it SHOULD read from mapped step environment variables rather than interpolating `${{ ... }}` directly into the script. The `-z` test checks string length and is portable across ordinary POSIX `sh` and Bash use in the quoted `[ -z "$x" ]` form.

When omitting the input `default:` means blank should use the configured default, the input `description:` **SHOULD** state the fallback behavior, such as "Blank uses the `REPORT_FORMAT` env value." Dropping `default:` may mean the manual-dispatch form no longer pre-fills that field. Authors who intentionally want the manual-dispatch form to show the default **MAY** keep the input `default:`, but they **SHOULD** mark it as an aligned duplicate of the single source, for example: `# Keep this default aligned with env.REPORT_FORMAT; it exists only to prefill the manual-dispatch form.`

The `||` fallback returns the right-hand value whenever the left-hand value is falsy. GitHub documents falsy values as `false`, `0`, `-0`, an empty string (`""` or `''`), and `null`, and the runner implementation returns the first truthy operand value, or the last evaluated operand value when none are truthy. Because of that behavior, the positive recommendation here is limited to optional string inputs where blank is the only fallback trigger. For Boolean inputs, number inputs, and string inputs where an explicit empty string is meaningful, authors **MUST** use explicit comparison or type-specific handling instead.

Use the `inputs` context rather than `github.event.inputs` for this pattern. GitHub documents that `inputs` preserves Boolean values as Booleans while `github.event.inputs` converts them to strings; authors **MUST NOT** use `github.event.inputs` to work around Boolean falsiness. Avoid the `||` fallback pattern for Booleans instead.

When the needed context is not available at a particular workflow key, a prior step can normalize the effective value and expose it through step outputs or job outputs for downstream consumption. Prior-step outputs can feed later steps in the same job, and job outputs can feed dependent jobs through `needs.<job_id>.outputs`, but a step cannot retroactively provide values to same-job keys evaluated before that step runs.

**Compliant:**

```yaml
name: Report

on:
  push:
  workflow_dispatch:
    inputs:
      report_format:
        description: "Optional. Blank uses the REPORT_FORMAT env value."
        required: false
        type: string

permissions: {}

env:
  REPORT_FORMAT: "sarif"

jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - name: Show effective format
        env:
          EFFECTIVE_REPORT_FORMAT: ${{ inputs.report_format || env.REPORT_FORMAT }}
        run: printf 'Using report format: %s\n' "$EFFECTIVE_REPORT_FORMAT"
```

**Non-compliant:**

```yaml
name: Report

on:
  push:
  workflow_dispatch:
    inputs:
      report_format:
        description: "Report format."
        required: false
        # Non-compliant: an independent, unmarked duplicate of REPORT_FORMAT
        # that nothing keeps in sync, so the two defaults can drift apart.
        default: "sarif"
        type: string

permissions: {}

env:
  REPORT_FORMAT: "sarif"

jobs:
  report:
    runs-on: ubuntu-latest
    steps:
      - name: Show effective format
        env:
          EFFECTIVE_REPORT_FORMAT: ${{ inputs.report_format || env.REPORT_FORMAT }}
        run: printf 'Using report format: %s\n' "$EFFECTIVE_REPORT_FORMAT"
```

The non-compliant example is non-compliant because the two defaults are independent and unmarked, not because an input `default:` is always forbidden; keeping a `default:` is acceptable when it is intentionally retained for manual-dispatch UI prefill and explicitly marked as aligned with the single source.

## Issue-form Markdown Links in `.github/ISSUE_TEMPLATE/*.yml`

GitHub issue forms render their `value:` Markdown blocks at the URL `/{owner}/{repo}/issues/new?...`, **not** at the source-file path. As a result, relative links inside those blocks resolve against the rendering URL and frequently produce 404s. For example, `[SECURITY.md](blob/HEAD/SECURITY.md)` resolves to `/{owner}/{repo}/issues/blob/HEAD/SECURITY.md` (404), and `[Security tab](security)` resolves to `/{owner}/{repo}/issues/security` (404). The same hazard applies to `contact_links` URLs in `.github/ISSUE_TEMPLATE/config.yml`, which GitHub itself rejects when given a relative path.

To make these links robust across non-GitHub.com renderers, GitHub Mobile, email notifications, and copied/quoted content, the following rules apply to all files matching `.github/ISSUE_TEMPLATE/*.yml` (including `config.yml`):

- Markdown links to repo-internal files (for example, `SECURITY.md`, `CONTRIBUTING.md`, `CODE_OF_CONDUCT.md`, `README.md`) **MUST** use full absolute URLs of the form `https://github.com/<owner>/<repo>/blob/HEAD/<path>` after any template placeholders are substituted.
- Repo-internal references that are not file paths (for example, the GitHub Security tab) **MUST** likewise use absolute URLs, such as `https://github.com/<owner>/<repo>/security`.
- Relative paths such as `../blob/HEAD/<file>`, `blob/HEAD/<file>`, `./<file>`, or bare relative refs such as `(security)` **MUST NOT** be used in issue-form `value:` Markdown blocks or in `contact_links` URLs.
- Use `blob/HEAD` rather than `blob/main` so file URLs work regardless of the repository's default branch name.
- Repositories hosted on GitHub Enterprise Server **MUST** use their own host instead of `github.com` (for example, `https://github.company.com/<owner>/<repo>/blob/HEAD/<path>`).
- Template repositories that intentionally ship unresolved URL placeholders **MUST** document and consistently use their repository-local placeholder convention and substitution process. In this repository, unresolved live adopter-substitution URLs **MUST** use literal `OWNER/REPO`; `<owner>/<repo>`, `<OWNER>/<REPO>`, and `your-org/your-repo` **MUST NOT** be used for that live role. Angle-bracket owner/repository text elsewhere in this guide is permitted only when the text is explicitly metasyntactic or describes a schematic URL after substitution. Placeholder validation, if any, is a repository-specific safety net; authors and adopters MUST still review the final rendered URLs.

If the repository also keeps Markdown documentation rules for issue templates or pull request templates, those rules SHOULD restate this behavior in their own scope so YAML and Markdown guidance remain independently understandable.

## Conservative YAML Subset

To maximize portability across parsers and to keep diffs reviewable, authors **SHOULD NOT** use the following YAML features unless the consumer documents support for them and a reviewer has confirmed the construct is necessary:

- Anchors (`&name`) and aliases (`*name`)
- Merge keys (`<<: *name`)
- Custom or explicit tags (`!!str`, `!CustomTag`, `!!python/object`)
- Flow style for non-trivial mappings or sequences
- Multi-document files with multiple `---` separators
- Directives other than the implicit `%YAML 1.2`

When these features are necessary (for example, a tool's configuration format genuinely requires anchors), the YAML file **SHOULD** include a brief comment explaining why the feature is used.

## Multi-line Strings

For multi-line string values, authors **SHOULD** use YAML block scalars rather than embedding `\n` in quoted strings:

- `|` — literal block scalar; preserves newlines, keeps a single trailing newline.
- `>` — folded block scalar; folds line breaks within paragraphs into spaces, keeps a single trailing newline.
- `|-` — literal block scalar with strip chomping; preserves newlines, removes the trailing newline.
- `>-` — folded block scalar with strip chomping; folds and strips the trailing newline.

Choose the indicator that matches the consumer's expectations. When passing a multi-line string to a shell (for example, a workflow `run:` step), `|` is almost always the correct choice.

## Naming Conventions

- YAML filenames **SHOULD** use **lowercase kebab-case** (for example, `release-please.yml`, `pre-commit-config.yaml`).
- GitHub Actions workflow files in `.github/workflows/` **MUST** use the `.yml` extension. GitHub Actions accepts both `.yml` and `.yaml`, but this repository standardizes on `.yml` for workflows for consistency with the existing tree.
- Project-owned YAML files outside `.github/workflows/` **MUST** pick **one** of `.yml` or `.yaml` and use it consistently within a project. Tool-owned configuration files **MUST** use whatever extension the tool requires (for example, `.pre-commit-config.yaml`).

## Comments

- YAML comments (lines beginning with `#` after optional whitespace) are **allowed and encouraged** for non-obvious configuration choices.
- Comments **SHOULD** explain **why** a value is set the way it is, not **what** the value is. Restating the literal value adds noise without information.
- Comments **MUST NOT** be the only place where behavior is described. If a configuration value's correctness depends on context, that context **MUST** also be captured somewhere a reader will see (in linked documentation, in the surrounding configuration block, or in the consuming code).

## Schema-backed YAML

YAML files that have a published schema **SHOULD** be validated against that schema. Files covered by schema or ecosystem validators in the repository's pre-commit hooks or CI **MUST** pass those validators. For file families that do not yet have a configured validator, authors **SHOULD** run the appropriate validator locally before committing and SHOULD add a file-family-scoped validator when the contract becomes durable.

Validation tiers:

- **MUST tier**: load-bearing YAML consumed by build, deploy, runtime, release automation, or other automated policy where malformed structure would cause incorrect behavior; GitHub Actions workflows under `.github/workflows/`; Azure Pipelines YAML when the `azure-pipelines` module or an equivalent Azure Pipelines surface is retained; pre-commit configuration; and any YAML file whose schema is published and stable and whose consumer requires structural correctness.
- **SHOULD tier**: durable fixtures, examples, policy documents, configuration contracts, and linter configuration files when a schema is available and a validator is convenient to run.
- **MAY tier**: optional or experimental configuration formats whose schema may change.

Common validator categories:

- **Syntax and style validators** (for example, `check-yaml` and `yamllint`) catch parser errors and repository style drift.
- **Ecosystem validators** (for example, `actionlint` for GitHub Actions workflows) catch consumer-specific structure and behavior errors. `actionlint` is GitHub Actions-specific and **MUST NOT** be treated as validation for Azure Pipelines YAML; validate Azure Pipelines through Azure DevOps Services pipeline creation, queued runs, or Azure Repos branch-policy build validation.
- **Schema validators** (for example, `check-jsonschema`) validate YAML files against project-owned schemas or mature external schemas. Add file-family-scoped hooks for additional schema-backed YAML as durable contracts are introduced.
- **Active hook list.** The repository's pre-commit configuration and CI definitions are the authoritative inventory of active validators. Repository-specific schema inventories, worked examples, removal checklists, and future validation candidates SHOULD live in the repository's schema documentation, if present.

Additional ecosystem-specific validators (for example, `kubeval`/`kubeconform` for Kubernetes, `helm lint` for Helm charts, `ansible-lint` for Ansible) **SHOULD** be adopted **only** when the repository actually uses the ecosystem. Generic YAML guidance **MUST NOT** mandate validators for ecosystems the repository does not use.

## Security

- YAML files **MUST NOT** contain committed secrets (API keys, tokens, passwords, connection strings, private keys). Reference secrets through the consumer's secret-management mechanism (for example, GitHub Actions `secrets.*`, environment variables, external secret stores).
- GitHub Actions workflows **MUST** declare **least-privilege** `permissions:` blocks at the workflow or job level. Workflows **SHOULD** start from `permissions: {}` (or `contents: read`) and grant additional scopes only where required.
- YAML loaded by application code **MUST** use a **safe loader**. In Python, this means `yaml.safe_load` (or `yaml.load(..., Loader=yaml.SafeLoader)`); authors **MUST NOT** call `yaml.load` with `Loader=yaml.FullLoader` or `Loader=yaml.UnsafeLoader` on untrusted input, and **MUST NOT** call `yaml.load` without an explicit safe `Loader=` argument (calling `yaml.load` without `Loader=` raises a warning in modern PyYAML and historically defaulted to the unsafe full loader). Equivalent safe-loading APIs **MUST** be used in other languages.
- Custom or unsafe deserialization tags (for example, `!!python/object`, `!!python/object/apply`, `!ruby/object`) **MUST NOT** appear in YAML files in this repository, and the loaders that read those files **MUST NOT** be configured to honor such tags.

## Definition of Done for YAML Changes

A YAML change is "done" when **all** of the following are true:

- The file follows the formatting rules above (2-space indentation, no tabs, block style by default, no trailing whitespace, single trailing newline).
- All scalars that need quoting per "Quoting Rules" are quoted; all version pins are quoted.
- All booleans are lowercase `true` / `false`; no `yes`/`no`/`on`/`off` as boolean values.
- The conservative subset is respected (no anchors, aliases, merge keys, custom tags, multi-document files, or flow style except where necessary and justified).
- Comments explain **why**, not **what**; behavior is not documented only in comments.
- The repository's configured YAML syntax and style validators pass.
- Any schema or ecosystem validator wired into pre-commit or CI passes for the affected files (for example, `actionlint` for GitHub Actions workflow files, `check-jsonschema` for schema-backed YAML covered by an active hook). When no such validator is wired up for the file family being changed, authors **SHOULD** run the applicable validator locally before committing. For Azure Pipelines YAML, service-backed validation through Azure DevOps Services pipeline creation, queued runs, or Azure Repos branch-policy build validation should be recorded when it cannot be performed in the current task.
- Pre-commit hooks pass locally (`pre-commit run --all-files`) and in the repository's configured CI.
- No secrets are committed; GitHub Actions workflows declare least-privilege `permissions:`.
- Each privileged `pull_request_target` workflow has a complete executable trust-root inventory, covers every selector in its path filters, and has fail-closed mutation tests for proposed trust-root or inert-data changes.
- Each path-scoped `push` workflow defines branch and tag intent explicitly and does not rely on path filters to restrict tag events.
