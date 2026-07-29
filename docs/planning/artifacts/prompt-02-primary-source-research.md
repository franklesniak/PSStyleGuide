# Prompt-02 primary-source research record

## Research date and repository baseline

- Research date: 2026-07-29.
- Live repository: `franklesniak/PSStyleGuide`.
- Default branch: `main`.
- Live ref verified with the GitHub connector and `git ls-remote`:
  `4346310e7deebffb4159c75e30d9546263dfd649`.
- Commit:
  <https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649>

This record preserves facts used to choose prompt-02 options. Versions and
advisories remain implementation-time recheck inputs, not frozen future
oracles.

## GitHub action metadata

The exact P1 SHAs resolve in the official repositories:

| Action | Selected release/SHA | Verified metadata |
| --- | --- | --- |
| `actions/checkout` | v7.0.1, `3d3c42e5aac5ba805825da76410c181273ba90b1` | `runs.using: node24`; persisted authenticated Git behavior and post action exist. |
| `actions/setup-node` | v7.0.0, `820762786026740c76f36085b0efc47a31fe5020` | `runs.using: node24`; `node-version` and `package-manager-cache` inputs exist. |
| `actions/upload-artifact` | v7.0.1, `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` | `runs.using: node24`; `archive`, `overwrite`, `artifact-id`, and `artifact-digest` exist; direct upload supports one file and ignores `name`. |
| `actions/download-artifact` | v8.0.1, `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c` | `runs.using: node24`; `artifact-ids`, `skip-decompress`, and fail-closed `digest-mismatch` exist. |

Primary files:

- <https://github.com/actions/checkout/blob/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml>
- <https://github.com/actions/setup-node/blob/820762786026740c76f36085b0efc47a31fe5020/action.yml>
- <https://github.com/actions/upload-artifact/blob/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml>
- <https://github.com/actions/download-artifact/blob/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml>

## Node and Markdown dependency compatibility

Current installed baseline:

| Package/surface | Version | Node contract |
| --- | --- | --- |
| `markdownlint-cli2` | 0.20.0 | `>=20` |
| `markdownlint` | 0.40.0 | `>=20` |
| `.husky/pre-commit` | live baseline | admits major 20 or newer |
| `lint-staged-markdown.mjs` | live baseline | admits major 20 or newer |

Known remediation candidate:

| Package/surface | Version | Verified fact |
| --- | --- | --- |
| `markdownlint-cli2` | 0.23.2 | `engines.node: >=22`; exports `main`; `main` accepts `nonFileContents`. |
| bundled `markdownlint` | 0.41.1 | `engines.node: >=22`. |
| 0.23.0 changelog | — | Explicitly removes support for end-of-life Node 20. |

Primary files:

- <https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/package.json>
- <https://github.com/DavidAnson/markdownlint/blob/v0.41.1/package.json>
- <https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/markdownlint-cli2.mjs#L881>
- <https://github.com/DavidAnson/markdownlint-cli2/blob/v0.23.2/CHANGELOG.md>
- <https://nodejs.org/en/about/previous-releases>

Interpretation:

- Static API presence is encouraging but does not prove the repository's
  staged-index integration.
- Node `>=22` is the minimum supported by the known candidate.
- P1's hosted/local full-corpus validation deliberately uses exact Node 24.
- A coherent P3 can admit supported contributor Node 22+ while retaining
  hosted Node 24, but it must test the selected minimum and Node 24 and align
  both local guards plus `package.json`.

## Current npm audit

Command:

```text
npm --prefix .github/workflows audit --package-lock-only --audit-level=moderate --json
```

Observed with the unchanged live-baseline manifest/lockfile:

| Severity | Package-node count |
| --- | ---: |
| Critical | 0 |
| High | 5 |
| Moderate | 2 |
| Low | 0 |
| Total | 7 |

Affected package nodes:

- `brace-expansion`;
- `js-yaml`;
- `linkify-it`;
- `markdown-it`;
- `markdownlint-cli2`;
- `minimatch`; and
- `picomatch`.

The object-valued `via` records currently expose 14 distinct advisory URLs:

- <https://github.com/advisories/GHSA-3jxr-9vmj-r5cp>
- <https://github.com/advisories/GHSA-f886-m6hf-6m8v>
- <https://github.com/advisories/GHSA-mh99-v99m-4gvg>
- <https://github.com/advisories/GHSA-52cp-r559-cp3m>
- <https://github.com/advisories/GHSA-h67p-54hq-rp68>
- <https://github.com/advisories/GHSA-22p9-wv53-3rq4>
- <https://github.com/advisories/GHSA-v245-v573-v5vm>
- <https://github.com/advisories/GHSA-38c4-r59v-3vqw>
- <https://github.com/advisories/GHSA-6v5v-wf23-fmfq>
- <https://github.com/advisories/GHSA-23c5-xmqv-rm74>
- <https://github.com/advisories/GHSA-3ppc-4f35-3m26>
- <https://github.com/advisories/GHSA-7r86-cg39-jmmj>
- <https://github.com/advisories/GHSA-3v7f-55p6-f55p>
- <https://github.com/advisories/GHSA-c2c7-rcm5-vvqj>

Recompute from the captured audit JSON at implementation time and treat
package-node counts, advisory counts, and dependency paths as different
measures.

Primary command semantics:

- <https://docs.npmjs.com/cli/v11/commands/npm-audit>

Required verifier implications:

- Record Node and npm versions explicitly.
- Distinguish a clean audit exit from the documented vulnerability exit and
  every other command error.
- Validate JSON schema members and nonnegative integral totals before use.
- Traverse object advisories and string-valued dependency links to recover the
  complete advisory/dependency-path graph.
- Treat the dated package-node baseline as comparison evidence only.

## Dependabot final state

P1 intentionally creates one review-only weekly `github-actions` entry for
`/`. P3 intentionally adds one review-only weekly npm entry for
`/.github/workflows`.

Primary option reference:

- <https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference>

The final P3 validator must compare normalized content with exactly those two
entries and reject duplicates, other ecosystems/directories, schedule drift,
or auto-merge/auto-approval mechanisms in the changed scope.
