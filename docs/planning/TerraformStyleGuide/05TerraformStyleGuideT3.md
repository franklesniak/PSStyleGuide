<!-- markdownlint-disable MD013 -->

# Remediate Markdown lint dependency advisories and add npm update governance

## Summary

Upgrade the repository's Markdown tooling to maintained compatible releases, declare and enforce a supported local Node policy, prove the actual installed TerraformStyleGuide Husky hook, resolve or explicitly govern every npm audit finding, and add review-only npm dependency updates.

This issue owns the final npm/runtime/hook/Dependabot state. It does not infer a local support policy from a GitHub Action's internal runtime.

## Execution order and policy gate

Implement only as the fifth node in the authorized **T1 → T1A → T1B → T2 → T3 → T4** graph, after **Make state-version discovery and recovery examples copy-safe with guarded identifiers**, against exact ruleset-protected landed T1/T1A/T1B/T2 commits.

T1's dated advisory decision is a go/no-go gate for that graph. If repository policy no longer permits the residuals through T2, stop the slate; do not run T3 out of order. After remediation, reissue/rebaseline every affected draft from the new protected `main` commit and begin again at T1. Record the real GitHub blocked-by relationship to T2.

## Dated baseline, not acceptance

On 2026-07-29, `corepack npm audit --package-lock-only --json` under Node 26.5.0/npm 11.7.0 reported seven vulnerability **properties** (five high and two moderate), 14 advisory objects in `via`, two package-name string edges in `via`, and seven installed audit node paths. The seven property keys were:

- `brace-expansion`;
- `js-yaml`;
- `linkify-it`;
- `markdown-it`;
- `markdownlint-cli2`;
- `minimatch`; and
- `picomatch`.

This count is not approval and must not be copied into final acceptance. Recompute from the implementation-time registry/lockfile. The durable finding identity is exact `(Package, AdvisoryUrl)`; installed topology is a separate exact package-keyed set of audit node paths. Do not invent an advisory-to-node-path edge that npm's report does not supply.

## Affected files

Required files:

- `.github/workflows/build.yml`;
- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`;
- `.husky/pre-commit`;
- `.github/dependabot.yml`;
- `.github/workflows/markdownlint.yml`;
- `.github/workflows/Test-MarkdownToolingIntegration.ps1` — add;
- `.github/workflows/Check-NodePolicy.mjs` — add;
- `.github/workflows/Install-Husky.mjs` — add;
- `.github/workflows/husky-install-contract.json` — add;
- `.github/workflows/node-policy-cases.json` — add;
- `.github/workflows/npm-audit-cases.json` — add;
- `.github/workflows/Validate-NpmAudit.mjs` — add;
- `.github/workflows/Capture-NpmAuditFollowUpEvidence.mjs` — add; and
- `.github/workflows/Validate-WorkflowPolicy.mjs`.

Conditionally affected only when the selected package/API/config change requires a reviewed compatibility edit:

- `.github/workflows/lint-nested-markdown.js`;
- `.github/workflows/.markdownlint.jsonc`.

Conditionally add one structured audit-exception file only if a residual advisory is explicitly approved:

- `.github/workflows/npm-audit-exceptions.json`.

Determine the complete exact file set after package selection and before editing. Use that set for working/staged gates. Do not preserve an earlier issue's file count.

No source guide or generated guide artifact should change.

## Requested changes

### 1. Recompute the package and advisory inventory

From a clean clone and exact prerequisite commit, record:

- Node/npm executable paths and full versions;
- `package.json`;
- lockfile version and root dependency declarations;
- `corepack npm ls --all --json`;
- `corepack npm outdated --json`;
- `corepack npm audit --package-lock-only --json`;
- direct package release/engine requirements and changelogs;
- existing lint scripts/config/nested-lint imports;
- exact `.husky/pre-commit` behavior; and
- exact final T1B/T2 workflow roles/action allowlist.

Normalize the audit report into two sorted observed sets.

`ObservedFindings` contains one unique row per exact `(Package, AdvisoryUrl)` and only report/tree/lock/native facts:

- package and advisory URL/source ID;
- severity;
- vulnerable range;
- direct parent(s);
- fix availability;
- evidence date/tool version; and
- the exact report and lock identities.

`AuditNodePaths` contains one unique package key and a sorted unique array of every installed npm node/dependency path for that package. Do not deduplicate distinct paths under one package name, form a Cartesian product between advisories and paths, or treat an aggregate package count as a complete advisory set.

### 2. Select maintained compatible versions deliberately

For every direct dependency:

- identify the latest maintained release compatible with the repository's lint behavior;
- review every intervening major release;
- verify license/provenance and published package contents;
- verify `engines.node`;
- document required config/API changes; and
- justify retaining, upgrading, replacing, or removing the dependency.

Upgrade through explicit `package.json` edits and npm exactly `12.0.2`, selected through the hashed Corepack project identity:

```json
"packageManager": "npm@12.0.2+sha512.b885e890b9418fa1693544d05f53e64f9a73ec194837d4258b15fecdd692347b1dd2a517b1b0cbaf9d31cd8e92c3b70956bd2ecc72833a57b4b3098f5bfa7943"
```

Every package operation is `corepack npm ...`; never invoke ambient `npm` or `npx`, install npm globally, or add npm as a devDependency. Enable Corepack's strict project/integrity behavior, assert exact `corepack npm --version` `12.0.2`, hydrate in the job-local trusted install phase, then prove a second clean install with network disabled/offline cache only. Re-resolve the dated npm release/integrity immediately before implementation; drift requires an explicit reviewed issue update, not an automatic “latest.”

`T3-NPM-OPERATIONS-v1` is the sole package-operation authority. In the canonical LF-terminated payload below, `<corepack-entry>`, `<empty-user-npmrc>`, `<empty-global-npmrc>`, and `<operation-cache>` are internally derived, validated ordinary paths under the current verified Node distribution or a job-owned protected temporary root; they are never caller values.

```text
T3-NPM-OPERATIONS-v1
ci:
<corepack-entry> npm ci --ignore-scripts --include=prod --include=dev
--include=optional --include=peer --workspaces=false --install-links=false
--strict-peer-deps=true --registry=https://registry.npmjs.org
--userconfig=<empty-user-npmrc> --globalconfig=<empty-global-npmrc>
--cache=<operation-cache> --prefer-online --no-audit --no-fund
--no-update-notifier --no-progress --color=false
audit:
<corepack-entry> npm audit --package-lock-only --json
--include=prod --include=dev --include=optional --include=peer
--workspaces=false --install-links=false --strict-peer-deps=true
--registry=https://registry.npmjs.org --userconfig=<empty-user-npmrc>
--globalconfig=<empty-global-npmrc> --cache=<operation-cache> --prefer-online
--no-fund --no-update-notifier --no-progress --color=false
lock-noop:
<corepack-entry> npm install --package-lock-only --ignore-scripts
--include=prod --include=dev --include=optional --include=peer
--workspaces=false --install-links=false --strict-peer-deps=true
--registry=https://registry.npmjs.org --userconfig=<empty-user-npmrc>
--globalconfig=<empty-global-npmrc> --cache=<operation-cache> --offline
--no-audit --no-fund --no-update-notifier --no-progress --color=false
run-lint-outer:
<corepack-entry> npm run --ignore-scripts --workspaces=false
--userconfig=<empty-user-npmrc> --globalconfig=<empty-global-npmrc>
--cache=<operation-cache> --offline --no-fund --no-update-notifier
--no-progress --color=false lint:md
run-lint-nested:
<corepack-entry> npm run --ignore-scripts --workspaces=false
--userconfig=<empty-user-npmrc> --globalconfig=<empty-global-npmrc>
--cache=<operation-cache> --offline --no-fund --no-update-notifier
--no-progress --color=false lint:md:nested
```

The SHA-256 of those exact payload bytes, including the final LF and excluding the fences, is `76eb77bc407b9cf6792bb05bb4cb297520752b91436c111b81c6749365b114fb`. The issue, workflow-policy validator, hook, installer, audit driver, and integration harness require that literal digest and the exact selected operation; no caller executable, argv, root, registry, config, cache, script, workspace, timeout, environment, or policy override exists.

Every row invokes the current verified `process.execPath` plus the validated ordinary bundled Corepack entry directly with `shell: false`, closed stdin, hidden Windows console, and no inherited descriptors. The working directory is the fixed `.github/workflows` package root. The environment starts empty and adds only fixed `CI=true`, Corepack strict/project/integrity controls, the operation's protected Corepack/cache/config paths, registry/network controls, and required platform process variables by exact allowlist. `ci` and `audit` use a fresh network-enabled cache; `lock-noop` and both lint rows use a fresh network-disabled cache seeded only from the verified `ci` cache.

`ci`, `lock-noop`, and each lint vector have a 300,000-ms timeout, concurrent 4-MiB stdout/stderr limits, and accept only exit `0`; nested lint runs only after outer lint succeeds. `audit` has a 120,000-ms timeout, the separate 8-MiB stdout and 1-MiB stderr contracts below, and accepts native `0` or `1` only for strict report validation. Start failure, signal, timeout, overflow, or any other exit is a tool failure. Only `ci` may create `node_modules`; only `lock-noop` may propose lock bytes and must prove a no-op; lint has no tracked side effect; audit is read-only. Package/hook lifecycle installation occurs only through the separately hash-bound installer, never an implicit npm lifecycle side effect.

Regenerate lockfile version 3 from a clean dependency state. Never use `npm audit fix --force`, `--force`, `--legacy-peer-deps`, ignored engines, or manual lockfile edits.

After selection, require:

- clean `corepack npm ci`;
- `corepack npm ls --all` with no invalid/extraneous/missing dependency;
- exact lockfile/root declaration agreement;
- unchanged script intent for outer/nested lint; and
- reproducible second clean install.

### 3. Declare the final Node policy

The finite reviewed policy is exactly:

| Line | Admitted interval | Floor evidence | Dated current evidence |
| --- | --- | --- | --- |
| Node 22 | `>=22.22.2 <23` | `22.22.2` | `22.23.2` on 2026-07-29 |
| Node 24 | `>=24.15.0 <25` | `24.15.0` | `24.18.1` on 2026-07-29 |

Set `engines.node` exactly to `>=22.22.2 <23 || >=24.15.0 <25`. Node 20 is EOL; 21/23/25 are unreviewed/non-LTS lines; Node 26 is current but not yet an admitted LTS line; Node 27 and later are not silently accepted. There is no general even-major rule.

Add `.github/workflows/Check-NodePolicy.mjs` as the dependency-free policy implementation. It exports a pure version predicate for tests and provides a CLI that always checks `process.versions.node`; the production CLI has no version-override argument. Implement an explicit two-row major/floor/ceiling table and accept canonical ASCII `x.y.z` only. Reject prefixes, signs, leading zeros, missing/extra components, prerelease/build text, Unicode digits, overflow, every below-floor patch, majors 20/21/23/25/26/27+, and any unreviewed line.

`engines.node`, workflow setup-node cells, hook diagnostic, and the policy module must encode the same admitted set. The structural workflow-policy validator checks that equality.

In `.github/workflows/markdownlint.yml`:

- retain the preferred Node 24 job and disabled automatic setup-node cache;
- add/retain validation at the exact selected minimum;
- query the actual Node process in every job;
- use the selected npm consistently;
- run clean install, outer lint, nested lint, the helper harness, and T2 shell harness on the preferred line;
- run package install plus package/hook compatibility evidence on the minimum; and
- update the exact action workflow/role/count allowlist atomically for any matrix/job changes without changing action commits unless separately reviewed.

The T1B `build.yml` remains the sole external event owner. Retain ordinary and Dependabot pull requests to `main`, `main` pushes, and `merge_group` when enabled. Add exactly this read-only UTC schedule and optional input-free manual dispatch:

```yaml
schedule:
  - cron: '23 17 * * 3'
workflow_dispatch:
```

Missing, duplicate, extra, or mutated cron entries fail structural fixtures. Schedule/manual events invoke no publication-capable path. Those two events invoke only the callable Markdown validation plus a read-only terminal result; candidate preparation, artifact upload, Windows candidate matrix, promotion approval, and writer are explicitly gated off. Only a changed push-to-`main` can reach the writer.

### 4. Fail early and clearly in the actual hook

Before testing installed tooling, `.husky/pre-commit` must:

1. preserve the existing staged-Markdown skip behavior;
2. require `node` to resolve as an application;
3. query the actual Node version before package/binary checks;
4. invoke the exact tracked `Check-NodePolicy.mjs` against the actual Node process before checking `node_modules`;
5. reject malformed, unsupported, EOL, and unreviewed future majors;
6. require `corepack` to resolve as an application only after Node policy passes and require its selected npm identity exactly;
7. print one stable diagnostic with observed version, accepted range, and remediation command/guidance;
8. retain GUI Git/version-manager guidance through `~/.config/husky/init.sh`;
9. preserve deliberate `--no-verify` guidance as a bypass disclosure, not a success path; and
10. invoke the unchanged logical outer then nested lint surfaces only through `corepack npm` after runtime/tooling validation.

Preserve exit classification:

- skip/pass is zero;
- lint findings reject the commit;
- tooling/config/runtime failures reject with a distinct stable reason; and
- unexpected npm/hook failures preserve the native status in diagnostics.

Do not replace TerraformStyleGuide's real full-lint hook with PSStyleGuide's different programmatic staged-content API.

### 5. Install Husky through a tracked fail-closed state machine

Add `.github/workflows/Install-Husky.mjs` and set `prepare` exactly to `node Install-Husky.mjs`; remove every `|| true` or equivalent swallowed installation failure. The default state is **required install**. Skip is permitted only under one of:

- `HUSKY_INSTALL_MODE=skip`;
- `HUSKY=0`; or
- `CI=true` with exact recorded reason `read-only-ci-install`.

Add strict JSON `.github/workflows/husky-install-contract.json` with schema `TerraformStyleGuide.HuskyInstallContract.v1`, closed keys, duplicate-key rejection, LF-only/BOM-less bytes, and installer contract `Install-Husky.v1`. It records:

- exact package `husky` version `9.1.7`, lockfile SHA-512 integrity, package relative root and binary mapping `husky: bin.js`, plus reviewed byte lengths and SHA-256 values for `package.json`, `bin.js`, `index.js`, and `husky`;
- tracked hook `.husky/pre-commit`, Git mode `100644`, marker `# terraform-style-guide-hook-schema: 1` exactly once on physical line `2`, and final byte length/SHA-256; and
- generated root `.husky/_`, expected `core.hooksPath` `.husky/_`, and an exact 17-entry array with relative path, role, length, SHA-256, and POSIX executable expectation.

Set the root dependency exactly to `"husky": "9.1.7"`. Its lock entry is version `9.1.7`, tarball `https://registry.npmjs.org/husky/-/husky-9.1.7.tgz`, integrity `sha512-5gs5ytaNjBrh5Ow3zrvdUUY+0VxIuWVL4i9irt6friV+BqdCfmV11CQTWMiBYWHbXhco+J1kHfTOUkePhCDvMA==`, and binary `husky: bin.js`. Reconfirm this release identity at implementation time; any substitution is a reviewed contract change.

`Install-Husky.mjs` resolves its directory from `import.meta.url`, derives the repository root as exactly two parents, and proves it with Git. Required mode:

1. parses the closed contract;
2. proves the package root and executable components are ordinary non-links below `.github/workflows/node_modules/husky`;
3. proves package manifest, root dependency, lock identity, byte lengths, and hashes equal the contract;
4. spawns exactly `process.execPath` with the verified absolute `node_modules/husky/bin.js`, no arguments, repository-root `cwd`, `shell:false`, and bounded stdout/stderr;
5. requires native exit `0`;
6. reads raw local Git config and requires exactly one `core.hooksPath` equal to `.husky/_`; and
7. verifies the separate tracked-hook and generated-file schemas.

There is no PATH-resolved Husky, `npx`, `npm exec`, shell command string, download, `init`, or package API import. The installer never writes the contract or tracked hook. Resolve the hook's final byte length and SHA-256 only after its behavior is complete and commit that value in the contract.

The tracked hook is exactly one stage-0 tracked blob with Git mode `100644`, ordinary non-link working object, LF-only/BOM-less bytes, the schema marker immediately after `#!/bin/sh`, and contract length/hash. The generated schema requires ordinary non-link `.husky` and `.husky/_` directories with exactly these 17 ordinary non-link files and no extra entry:

- support: `.gitignore`, `h`, `husky.sh`;
- shims: `applypatch-msg`, `commit-msg`, `post-applypatch`, `post-checkout`, `post-commit`, `post-merge`, `post-rewrite`, `pre-applypatch`, `pre-auto-gc`, `pre-commit`, `pre-merge-commit`, `pre-push`, `pre-rebase`, `prepare-commit-msg`.

For Husky `9.1.7`, every shim is the exact 39-byte body with SHA-256 `34fe496008be71d8fdd446b2cce81e4bb0406109c130eafc583fbd9fe33244e2`; `.gitignore` is byte `*`; `h` equals package file `husky`, length `551`, SHA-256 `70200b200ca709b0622784f93839a5b2872333a917a09afddefd7dc2d8cdc680`; and `husky.sh` is length `160`, SHA-256 `21122903fca7209a13c991e5be68780636e28f1b8f0ae7ea07ed0065dfe37268`. On POSIX, `h` and all 14 shims have every contract executable bit; on Windows, content/type checks plus real Git Bash execution are authoritative.

Environment parsing is closed and case-sensitive: `HUSKY_INSTALL_MODE` is absent, `required`, or `skip`; `HUSKY` is absent or `0`; `CI` is absent, `false`, or `true`. Exactly one of install-mode `skip`, `HUSKY=0`, or `CI=true` selects `explicit-install-mode`, `husky-disabled`, or `read-only-ci-install`. Unknown values, explicit `required` plus a skip source, or multiple skip sources fail.

Skip mode proves byte/config/filesystem immutability and reports the exact selected skip source/reason; it never reports “installed.” Tests run only in disposable repositories and include real `git commit` pass/reject cases. The installer catalog is this closed physical allocation; each row records one literal fixture, phase, native status, reason, Husky/Git call counts, hooksPath, exact tracked/generated state, side effects, and diagnostic:

| ID | Singular fixture and oracle |
| --- | --- |
| `T3-HUSKY-001` | required install succeeds and exact inventory matches |
| `T3-HUSKY-002` | package identity mismatch rejects before import |
| `T3-HUSKY-003` | package path link/reparse rejects before import |
| `T3-HUSKY-004` | fixed entry import/spawn failure rejects |
| `T3-HUSKY-005` | wrong repository root rejects without mutation |
| `T3-HUSKY-006` | wrong final `core.hooksPath` rejects |
| `T3-HUSKY-007` | tracked hook missing rejects |
| `T3-HUSKY-008` | tracked hook untracked rejects |
| `T3-HUSKY-009` | tracked hook wrong Git mode rejects |
| `T3-HUSKY-010` | tracked hook wrong filesystem type rejects |
| `T3-HUSKY-011` | tracked hook link/reparse rejects |
| `T3-HUSKY-012` | tracked hook marker position/count drift rejects |
| `T3-HUSKY-013` | tracked hook length/hash drift rejects |
| `T3-HUSKY-014` | generated root missing/wrong type rejects |
| `T3-HUSKY-015` | one generated file missing rejects |
| `T3-HUSKY-016` | one extra generated entry rejects |
| `T3-HUSKY-017` | generated entry wrong filesystem type rejects |
| `T3-HUSKY-018` | generated entry link/reparse rejects |
| `T3-HUSKY-019` | generated entry length/hash drift rejects |
| `T3-HUSKY-020` | generated executable-mode drift rejects |
| `T3-HUSKY-021` | exact explicit `HUSKY=0` authorized skip is immutable |
| `T3-HUSKY-022` | exact production read-only CI skip is immutable |
| `T3-HUSKY-023` | unknown environment value rejects |
| `T3-HUSKY-024` | required/skip source conflict rejects |
| `T3-HUSKY-025` | multiple skip sources reject |
| `T3-HUSKY-026` | skip-state filesystem/config mutation rejects |
| `T3-HUSKY-027` | direct-dependency-only false positive rejects |
| `T3-HUSKY-028` | imported function throws/nonzero outcome rejects |
| `T3-HUSKY-029` | real installed hook commit passes |
| `T3-HUSKY-030` | real installed hook violation commit rejects |

No row joins missing/link, shim/hook, pass/reject, or platform/runtime results. Mutation fixtures reject a missing, duplicate, unknown, regrouped, orphaned, unused, skipped, or multiply emitted ID.

### 6. Add a tracked cross-platform integration harness

Create `.github/workflows/Test-MarkdownToolingIntegration.ps1` with `#Requires -Version 5.1`, a recorded version, and an explicit path to the repository under test.

The harness creates disposable repositories/indexes only. It must never mutate the implementer's real index, hooks, config, or working tree.

The four columns below are literal applicability: `U22 = ubuntu-24.04/22.23.2`, `U24 = ubuntu-24.04/24.18.1`, `W22 = windows-2025 Git Bash/22.23.2`, and `W24 = windows-2025 Git Bash/24.18.1`. Every cell is a separate physical case with one fixture, expected package/runtime identity, native outcome, side effect set, diagnostic, and result:

| Behavior and exact oracle | U22 ID | U24 ID | W22 ID | W24 ID |
| --- | --- | --- | --- | --- |
| clean `ci` plus `npm ls --all` succeeds | `T3-NPM-U22-01` | `T3-NPM-U24-01` | `T3-NPM-W22-01` | `T3-NPM-W24-01` |
| outer lint succeeds | `T3-NPM-U22-02` | `T3-NPM-U24-02` | `T3-NPM-W22-02` | `T3-NPM-W24-02` |
| nested lint succeeds | `T3-NPM-U22-03` | `T3-NPM-U24-03` | `T3-NPM-W22-03` | `T3-NPM-W24-03` |
| no staged Markdown; zero npm calls | `T3-HOOK-U22-01` | `T3-HOOK-U24-01` | `T3-HOOK-W22-01` | `T3-HOOK-W24-01` |
| staged valid Markdown passes | `T3-HOOK-U22-02` | `T3-HOOK-U24-02` | `T3-HOOK-W22-02` | `T3-HOOK-W24-02` |
| outer-rule violation rejects exact rule/path | `T3-HOOK-U22-03` | `T3-HOOK-U24-03` | `T3-HOOK-W22-03` | `T3-HOOK-W24-03` |
| nested-fence violation rejects exact rule/depth/path | `T3-HOOK-U22-04` | `T3-HOOK-U24-04` | `T3-HOOK-W22-04` | `T3-HOOK-W24-04` |
| missing Corepack is tooling failure | `T3-HOOK-U22-05` | `T3-HOOK-U24-05` | `T3-HOOK-W22-05` | `T3-HOOK-W24-05` |
| broken lint config differs from lint finding | `T3-HOOK-U22-06` | `T3-HOOK-U24-06` | `T3-HOOK-W22-06` | `T3-HOOK-W24-06` |
| installed hook via real commit passes | `T3-HOOK-U22-08` | `T3-HOOK-U24-08` | `T3-HOOK-W22-08` | `T3-HOOK-W24-08` |
| missing installed lint binary is tooling failure | `T3-HOOK-U22-09` | `T3-HOOK-U24-09` | `T3-HOOK-W22-09` | `T3-HOOK-W24-09` |
| lint startup failure differs from lint finding | `T3-HOOK-U22-10` | `T3-HOOK-U24-10` | `T3-HOOK-W22-10` | `T3-HOOK-W24-10` |
| real commit with test violation rejects | `T3-HOOK-U22-11` | `T3-HOOK-U24-11` | `T3-HOOK-W22-11` | `T3-HOOK-W24-11` |

The runtime-bound installed-hook cases are already allocated one physical result per exact platform/runtime cell:

| ID | Platform | Exact actual Node | Exact result |
| --- | --- | --- | --- |
| `T3-HOOK-07-U-22-BELOW` | Ubuntu | `22.22.1` | reject before Corepack/npm/lint: below floor |
| `T3-HOOK-07-W-22-BELOW` | Windows Git Bash | `22.22.1` | reject before Corepack/npm/lint: below floor |
| `T3-HOOK-07-U-22-FLOOR` | Ubuntu | `22.22.2` | accept; pinned npm and lint run |
| `T3-HOOK-07-W-22-FLOOR` | Windows Git Bash | `22.22.2` | accept; pinned npm and lint run |
| `T3-HOOK-07-U-22-CURRENT` | Ubuntu | `22.23.2` | accept; pinned npm and lint run |
| `T3-HOOK-07-W-22-CURRENT` | Windows Git Bash | `22.23.2` | accept; pinned npm and lint run |
| `T3-HOOK-07-U-23` | Ubuntu | `23.0.0` | reject before Corepack/npm/lint: major unreviewed |
| `T3-HOOK-07-W-23` | Windows Git Bash | `23.0.0` | reject before Corepack/npm/lint: major unreviewed |
| `T3-HOOK-07-U-24-BELOW` | Ubuntu | `24.14.0` | reject before Corepack/npm/lint: below floor |
| `T3-HOOK-07-W-24-BELOW` | Windows Git Bash | `24.14.0` | reject before Corepack/npm/lint: below floor |
| `T3-HOOK-07-U-24-FLOOR` | Ubuntu | `24.15.0` | accept; pinned npm and lint run |
| `T3-HOOK-07-W-24-FLOOR` | Windows Git Bash | `24.15.0` | accept; pinned npm and lint run |
| `T3-HOOK-07-U-24-CURRENT` | Ubuntu | `24.18.1` | accept; pinned npm and lint run |
| `T3-HOOK-07-W-24-CURRENT` | Windows Git Bash | `24.18.1` | accept; pinned npm and lint run |
| `T3-HOOK-07-U-25` | Ubuntu | `25.0.0` | reject before Corepack/npm/lint: major unreviewed |
| `T3-HOOK-07-W-25` | Windows Git Bash | `25.0.0` | reject before Corepack/npm/lint: major unreviewed |
| `T3-HOOK-07-U-26` | Ubuntu | `26.5.1` | reject before Corepack/npm/lint: current major unreviewed |
| `T3-HOOK-07-W-26` | Windows Git Bash | `26.5.1` | reject before Corepack/npm/lint: current major unreviewed |

Provision every exact runtime; these rows read the actual process version and cannot use an override. Re-resolve dated `CURRENT` versions before implementation; if changed, append new IDs and retire the old rows with a recorded reason rather than changing their meaning.

`node-policy-cases.json` is the one closed manifest for policy-module, policy-CLI, and installed-hook cases. Every row has exact `Id`, `Layer`, `Platform`, `NodeVersionSource`, literal `Input`, `ExpectedExit`, `ExpectedReason`, `ExpectCorepack`, `ExpectNpm`, and `ExpectLint`. IDs are opaque; reject family/range/wildcard rows, duplicate/missing/unknown IDs, or more than one result.

The Node catalog is already allocated as exactly these 48 physical rows. Each row additionally declares its unique semantic key, raw JSON type/value, normalized value/category/exit, requirement key, and exact pure/CLI/hook/lint/ workflow consumers. No implementation-time ID allocation remains:

| ID | Literal fixture | Exact oracle |
| --- | --- | --- |
| `T3-NODE-001` | JSON null | malformed type |
| `T3-NODE-002` | Boolean | malformed type |
| `T3-NODE-003` | number | malformed type |
| `T3-NODE-004` | array | malformed type |
| `T3-NODE-005` | object | malformed type |
| `T3-NODE-006` | empty string | malformed syntax |
| `T3-NODE-007` | ASCII whitespace | malformed syntax |
| `T3-NODE-008` | `v22.23.2` | prefix rejected |
| `T3-NODE-009` | `+22.23.2` | sign rejected |
| `T3-NODE-010` | `-22.23.2` | sign rejected |
| `T3-NODE-011` | `22.23` | missing component |
| `T3-NODE-012` | `22.23.2.0` | extra component |
| `T3-NODE-013` | `022.23.2` | leading-zero major |
| `T3-NODE-014` | `22.023.2` | leading-zero minor |
| `T3-NODE-015` | `22.23.02` | leading-zero patch |
| `T3-NODE-016` | `22.23.2-rc.1` | prerelease rejected |
| `T3-NODE-017` | `22.23.2+build` | build metadata rejected |
| `T3-NODE-018` | `2.2e1.2` | exponent spelling rejected |
| `T3-NODE-019` | `0x16.23.2` | hexadecimal spelling rejected |
| `T3-NODE-020` | Unicode digit component | non-ASCII digit rejected |
| `T3-NODE-021` | component above safe bound | overflow rejected |
| `T3-NODE-022` | embedded NUL | control rejected |
| `T3-NODE-023` | embedded newline | control rejected |
| `T3-NODE-024` | `22.23.2x` | trailing data rejected |
| `T3-NODE-025` | `20.999.999` | unsupported EOL line |
| `T3-NODE-026` | `21.999.999` | unsupported odd line |
| `T3-NODE-027` | `22.22.1` | one below Node 22 floor |
| `T3-NODE-028` | `22.22.2` | exact Node 22 floor passes |
| `T3-NODE-029` | `22.23.2` | selected Node 22 cell passes |
| `T3-NODE-030` | `22.999.999` | admitted Node 22 upper patch passes |
| `T3-NODE-031` | `23.0.0` | unsupported odd line |
| `T3-NODE-032` | `24.14.999` | one range below Node 24 floor |
| `T3-NODE-033` | `24.15.0` | exact Node 24 floor passes |
| `T3-NODE-034` | `24.18.1` | selected Node 24 cell passes |
| `T3-NODE-035` | `24.999.999` | admitted Node 24 upper patch passes |
| `T3-NODE-036` | `25.0.0` | unsupported odd line |
| `T3-NODE-037` | `26.0.0` | unreviewed future line |
| `T3-NODE-038` | `27.0.0` | unreviewed future line |
| `T3-NODE-039` | mutate admitted major | frozen-policy mutation fails |
| `T3-NODE-040` | mutate floor | frozen-policy mutation fails |
| `T3-NODE-041` | mutate ceiling | frozen-policy mutation fails |
| `T3-NODE-042` | pass CLI positional argument | no-argument CLI fails |
| `T3-NODE-043` | environment policy override | override ignored/rejected |
| `T3-NODE-044` | file policy override | override ignored/rejected |
| `T3-NODE-045` | production imports fixture evaluator | structural failure |
| `T3-NODE-046` | second current-version read | structural failure |
| `T3-NODE-047` | real CLI under Node `22.23.2` | actual-process pass |
| `T3-NODE-048` | real CLI under Node `24.18.1` | actual-process pass |

Both synthetic runtime cells consume every pure row. Actual CLI rows use only the named real process. Catalog mutations reject missing, duplicate, unknown, regrouped, skipped, multiply emitted, orphaned, or unused IDs.

Add strict `.github/workflows/npm-audit-cases.json` as the closed append-only manifest for tokenizer, report, exception, production-CLI, and process-driver fixtures. Every physical row has exact `Id`, `Layer`, literal fixture reference, `NativeOutcome`, `ExceptionState`, `ExpectedExit`, `ExpectedReason`, `ExpectedNormalizedFindings`, `ExpectedAuditNodePaths`, `ExpectedParserState`, and `ExpectedProcessCallCount`. Reject range/family/wildcard/multi-result rows.

The same harness owns these append-only audit-validator IDs. Existing IDs `01`–`27` retain one narrowed meaning: `12` is only invalid `createdAt`; `13` one extra exception-root property; `14` one duplicate normalized exception finding; `15` omits only owner; `16` uses the canonical path on the wrong GitHub host; `17` is ASCII `not-json`; `18` is one reversed-order equivalent; `19` is the real CLI; `20` is numeric report version `1`; `21` makes `vulnerabilities` an array; `22` duplicates one approved advisory URL; `23` repeats one raw vulnerability property; `24` duplicates one report node; `25` omits only `followUpEvidenceSha256`; `26` omits only `approvalIdentity`; and `27` removes the last byte from an otherwise valid report.

| ID | Fixture | Exact oracle |
| --- | --- | --- |
| `AUDIT-01` | clean audit, no exception file | pass |
| `AUDIT-02` | clean audit, exception file present | fail stale permission |
| `AUDIT-03` | residual audit, no exception file | fail unapproved findings |
| `AUDIT-04` | exact approved findings/topology | pass |
| `AUDIT-05` | new `(Package, AdvisoryUrl)` | fail with exact addition |
| `AUDIT-06` | removed approved finding | fail with exact stale removal |
| `AUDIT-07` | new package node path | fail with exact topology addition |
| `AUDIT-08` | removed approved node path | fail with exact stale topology |
| `AUDIT-09` | one second before expiration | pass |
| `AUDIT-10` | exactly at expiration | fail expired |
| `AUDIT-11` | one second after expiration | fail expired |
| `AUDIT-12` | malformed timestamp | fail schema |
| `AUDIT-13` | unknown property | fail closed schema |
| `AUDIT-14` | duplicate finding identity | fail duplicate |
| `AUDIT-15` | missing owner | fail governance |
| `AUDIT-16` | invalid follow-up issue URL | fail governance |
| `AUDIT-17` | non-JSON audit report | fail audit input |
| `AUDIT-18` | equivalent input in different order | pass with identical normalization |
| `AUDIT-19` | real report captured after clean `corepack npm ci` | CLI result matches current governed state |
| `AUDIT-20` | wrong schema version | fail schema |
| `AUDIT-21` | wrong property type | fail schema |
| `AUDIT-22` | duplicate canonical advisory URL identity | fail duplicate |
| `AUDIT-23` | duplicate audit package property | fail duplicate |
| `AUDIT-24` | duplicate installed node path | fail duplicate |
| `AUDIT-25` | missing follow-up fields | fail governance |
| `AUDIT-26` | missing approval identity | fail governance |
| `AUDIT-27` | truncated JSON audit report | fail audit input |

The issue and committed manifest allocate one physical row—not a range row—for each remaining case:

| ID | Literal fixture |
| --- | --- |
| `AUDIT-28` | empty raw report |
| `AUDIT-29` | UTF-8 BOM |
| `AUDIT-30` | UTF-16LE BOM |
| `AUDIT-31` | stray UTF-8 continuation |
| `AUDIT-32` | truncated multibyte UTF-8 |
| `AUDIT-33` | exactly 8,388,608-byte valid empty report |
| `AUDIT-34` | raw report byte 8,388,609 |
| `AUDIT-35` | second JSON value |
| `AUDIT-36` | trailing non-whitespace |
| `AUDIT-37` | trailing JSON whitespace |
| `AUDIT-38` | depth 64 |
| `AUDIT-39` | depth 65 |
| `AUDIT-40` | 250,000 values |
| `AUDIT-41` | 250,001 values |
| `AUDIT-42` | 1,048,576-byte string token |
| `AUDIT-43` | 1,048,577-byte string token |
| `AUDIT-44` | 64-byte number token |
| `AUDIT-45` | 65-byte number token |
| `AUDIT-46` | duplicate key in report root |
| `AUDIT-47` | duplicate key in vulnerability object |
| `AUDIT-48` | duplicate key in advisory object |
| `AUDIT-49` | duplicate key in `cvss` |
| `AUDIT-50` | duplicate key in `fixAvailable` |
| `AUDIT-51` | duplicate key in `metadata` |
| `AUDIT-52` | duplicate key in `metadata.vulnerabilities` |
| `AUDIT-53` | duplicate key in `metadata.dependencies` |
| `AUDIT-54` | duplicate key in native-outcome root |
| `AUDIT-55` | duplicate key in exception root |
| `AUDIT-56` | duplicate key in exception finding |
| `AUDIT-57` | duplicate key in exception topology row |
| `AUDIT-58` | outcome BOM |
| `AUDIT-59` | outcome invalid UTF-8 |
| `AUDIT-60` | outcome second value |
| `AUDIT-61` | outcome extra property |
| `AUDIT-62` | outcome non-string `kind` |
| `AUDIT-63` | impossible `exit` combination |
| `AUDIT-64` | impossible `signal` combination |
| `AUDIT-65` | impossible `timeout` combination |
| `AUDIT-66` | impossible `startFailure` combination |
| `AUDIT-67` | stdout length/hash mismatch |
| `AUDIT-68` | missing stdout file |
| `AUDIT-69` | native exit `2` |
| `AUDIT-70` | external `SIGTERM` |
| `AUDIT-71` | timeout ends after TERM |
| `AUDIT-72` | timeout requires KILL |
| `AUDIT-73` | process start failure |
| `AUDIT-74` | stderr exactly 65,536 bytes |
| `AUDIT-75` | stderr byte 65,537 |
| `AUDIT-76` | stdout stream failure |
| `AUDIT-77` | stderr stream failure |
| `AUDIT-78` | termination delivery failure |
| `AUDIT-79` | error then close emits one result |
| `AUDIT-80` | close without prior exit/error |
| `AUDIT-81` | report-root extra property |
| `AUDIT-82` | missing `auditReportVersion` |
| `AUDIT-83` | missing `vulnerabilities` |
| `AUDIT-84` | missing `metadata` |
| `AUDIT-85` | null `vulnerabilities` |
| `AUDIT-86` | array `metadata` |
| `AUDIT-87` | unsafe vulnerability package-property name |
| `AUDIT-88` | vulnerability property-key/name mismatch |
| `AUDIT-89` | vulnerability extra property |
| `AUDIT-90` | vulnerability missing `name` |
| `AUDIT-91` | vulnerability missing `severity` |
| `AUDIT-92` | vulnerability missing `isDirect` |
| `AUDIT-93` | vulnerability missing `via` |
| `AUDIT-94` | vulnerability missing `effects` |
| `AUDIT-95` | vulnerability missing `range` |
| `AUDIT-96` | vulnerability missing `nodes` |
| `AUDIT-97` | vulnerability missing `fixAvailable` |
| `AUDIT-98` | vulnerability wrong `name` |
| `AUDIT-99` | vulnerability wrong `severity` |
| `AUDIT-100` | vulnerability wrong `isDirect` |
| `AUDIT-101` | vulnerability wrong `via` |
| `AUDIT-102` | vulnerability wrong `effects` |
| `AUDIT-103` | vulnerability wrong `range` |
| `AUDIT-104` | vulnerability wrong `nodes` |
| `AUDIT-105` | vulnerability wrong `fixAvailable` |
| `AUDIT-106` | invalid `via` entry type |
| `AUDIT-107` | advisory extra property |
| `AUDIT-108` | advisory missing `source` |
| `AUDIT-109` | advisory missing `name` |
| `AUDIT-110` | advisory missing `dependency` |
| `AUDIT-111` | advisory missing `title` |
| `AUDIT-112` | advisory missing `url` |
| `AUDIT-113` | advisory missing `severity` |
| `AUDIT-114` | advisory missing `cwe` |
| `AUDIT-115` | advisory missing `cvss` |
| `AUDIT-116` | advisory missing `range` |
| `AUDIT-117` | advisory wrong `source` |
| `AUDIT-118` | advisory wrong `name` |
| `AUDIT-119` | advisory wrong `dependency` |
| `AUDIT-120` | advisory wrong `title` |
| `AUDIT-121` | advisory wrong `url` |
| `AUDIT-122` | advisory wrong `severity` |
| `AUDIT-123` | advisory wrong `cwe` |
| `AUDIT-124` | advisory wrong `cvss` |
| `AUDIT-125` | advisory wrong `range` |
| `AUDIT-126` | non-string CWE entry |
| `AUDIT-127` | CVSS extra property |
| `AUDIT-128` | CVSS missing `score` |
| `AUDIT-129` | CVSS missing `vectorString` |
| `AUDIT-130` | out-of-range/nonfinite CVSS score |
| `AUDIT-131` | non-string CVSS vector |
| `AUDIT-132` | package-string `via` target absent |
| `AUDIT-133` | `effects` target absent |
| `AUDIT-134` | via edge lacks reciprocal effect |
| `AUDIT-135` | effect lacks reciprocal via edge |
| `AUDIT-136` | unsorted `nodes` |
| `AUDIT-137` | invalid `fixAvailable: null` |
| `AUDIT-138` | fix object extra property |
| `AUDIT-139` | fix object missing `name` |
| `AUDIT-140` | fix object missing `version` |
| `AUDIT-141` | fix object missing `isSemVerMajor` |
| `AUDIT-142` | fix object wrong `name` |
| `AUDIT-143` | fix object wrong `version` |
| `AUDIT-144` | fix object wrong `isSemVerMajor` |
| `AUDIT-145` | metadata extra property |
| `AUDIT-146` | missing vulnerability count `info` |
| `AUDIT-147` | missing vulnerability count `low` |
| `AUDIT-148` | missing vulnerability count `moderate` |
| `AUDIT-149` | missing vulnerability count `high` |
| `AUDIT-150` | missing vulnerability count `critical` |
| `AUDIT-151` | missing vulnerability count `total` |
| `AUDIT-152` | missing dependency count `prod` |
| `AUDIT-153` | missing dependency count `dev` |
| `AUDIT-154` | missing dependency count `optional` |
| `AUDIT-155` | missing dependency count `peer` |
| `AUDIT-156` | missing dependency count `peerOptional` |
| `AUDIT-157` | missing dependency count `total` |
| `AUDIT-158` | negative metadata count |
| `AUDIT-159` | unsafe-integer metadata count |
| `AUDIT-160` | non-integer metadata count |
| `AUDIT-161` | severity-total arithmetic mismatch |
| `AUDIT-162` | property/severity reconciliation mismatch |
| `AUDIT-163` | dependency-total mismatch |
| `AUDIT-164` | duplicate normalized advisory identity in report |

For deliberately deep/count/long values that cannot satisfy the closed npm schema, `ExpectedParserState` distinguishes acceptance through the tokenizer followed by schema rejection from tokenizer rejection.

Deterministic fixture cases import the pure validator core and inject the UTC instant; the production CLI has no clock override. `AUDIT-19` invokes the exact tracked CLI. Every row asserts exit class, normalized additions/removals, exception-file state, input immutability, and stable diagnostics. The harness fails on a missing, duplicate, unexpected, or multiply emitted applicable ID.

Negative fixtures are created temporarily in the disposable repository and removed in `finally`; do not add repository-wide lint violations as tracked files.

At least one case must:

1. run clean install so Husky installs its real hook integration;
2. stage test-owned Markdown;
3. invoke `git commit` without directly calling `.husky/pre-commit`;
4. prove Git invokes the installed hook;
5. prove pass or rejection and expected index/commit state; and
6. prove cleanup leaves the source repository untouched.

Run the harness on:

- Ubuntu with selected minimum Node;
- Ubuntu with preferred Node 24;
- Windows/Git Bash with selected minimum Node; and
- Windows/Git Bash with preferred Node 24.

Windows PowerShell 5.1 may orchestrate the harness, but the actual hook executes through the Git/Husky shell environment. Record exact shell, Git, Node, npm, package, and harness versions.

### 7. Resolve or govern every advisory

Run after clean installation:

```text
corepack npm audit --package-lock-only --json
```

The preferred final result is zero vulnerabilities at all severities. Also run the repository-approved human-readable audit and capture native exit codes.

Create `.github/workflows/Validate-NpmAudit.mjs`. It exports the strict raw tokenizer plus closed report/exception/policy cores; fixtures pass exact raw bytes, structured outcome, exception bytes/state, and an injected UTC instant. Its production CLI accepts exact protected report, stderr, structured outcome, and optional exception paths, always obtains actual current UTC, and has no clock-bypass argument. It emits one canonical summary and stable exit classes for:

- CLI/input/schema failure;
- unapproved or topology-mismatched residuals; and
- expired/stale governance.

The callable workflow uses the closed process driver to capture `corepack npm audit --package-lock-only --json` into protected report, stderr, and structured-outcome files, then invokes this exact validator. Non-JSON/ truncated/network/tool failure is an input/process failure, not an approved residual. Never hide risk with `--audit-level`.

If a residual finding cannot be removed without a disproportionate or incompatible change, the optional exception file uses one versioned closed schema and contains exactly:

- `schemaVersion: 1`;
- `observedFindings`, sorted and unique by `(package, advisoryUrl)`, containing only the captured package, canonical advisory URL/source ID, severity, vulnerable range, CVSS when supplied, fix availability/type, direct parents, affected dependency types, and report/lock identities;
- `approvals`, separately sorted and unique by the same exact key, each with:
  - package and canonical advisory URL;
  - copied source ID, severity, vulnerable range, CVSS, fix availability/type, direct parents, affected dependency types, and report/lock identities that must equal its observed row;
  - repository-specific exploitability analysis;
  - explicit compensating controls;
  - accountable owner;
  - canonical whole-second RFC 3339 UTC `createdAt`, `approvedAt`, and `expiresAt` values ending in `Z`;
  - canonical follow-up issue URL/number, current scope hash, verification time, and retained filing-evidence hash under the exact fields below;
  - explicit approval identity; and
  - evidence that no fixed compatible package tree exists; and
- `auditNodePaths`, sorted and unique by package, each containing the exact sorted unique installed paths for that package.

Do not create advisory/path pairs or copy human approval fields into `ObservedFindings`. The validator requires exact key equality between current normalized `ObservedFindings`, exception `observedFindings`, and `approvals`; exact equality of every copied report/tree/lock/native field; exact equality between current and exception package-keyed node-path sets; and separate approval-governance validity. Any observed field, topology, key scope, or expiry drift fails rather than preserving an old approval.

Approval time is bounded:

- `createdAt` and `approvedAt` must represent the same reviewed approval instant;
- `expiresAt` must be later than that instant and no later than exactly 30 × 24 hours afterward;
- expiration is exclusive and the record fails when `now >= expiresAt`; and
- renewal requires new clean-install/audit/fix-availability evidence, updated analysis/controls/follow-up status, and a new accountable approval. Changing only timestamps is forbidden.

#### Closed audit report-v2 and structured process-outcome contract

The orchestration invokes exactly `corepack npm audit --package-lock-only --json` with no `--audit-level`. Capture stdout and stderr separately into protected bounded streams, preserve the process outcome as one of `exit`, `signal`, `timeout`, or `startFailure`, and pass the exact structured outcome plus both stream files to the validator. Do not merge streams, parse console prose, or let shell strict mode erase the native outcome.

The process driver writes strict `TerraformStyleGuide.NpmAuditNativeOutcome.v1` JSON with exactly these properties:

```text
schemaVersion
commandContract
kind
exitCode
signal
termination
timeoutMilliseconds
terminationGraceMilliseconds
stdoutRetainedBytes
stdoutOverflow
stdoutSha256
stderrRetainedBytes
stderrOverflow
stderrSha256
```

`schemaVersion` is `1`; `commandContract` is `corepack-npm-audit-package-lock-v1`; timeout values are `120000` and `5000`. Lengths are safe integers bounded by `8,388,608` and `65,536`; hashes are lowercase SHA-256. Valid discriminants are:

| Kind | `exitCode` | `signal` | `termination` |
| --- | --- | --- | --- |
| `exit` | integer `0`–`255` | `null` | `none` |
| `signal` | `null` | canonical supported `SIG*` name | `external-signal` |
| `timeout` | `null` | `null` | `sigterm` or `sigkill` |
| `startFailure` | `null` | `null` | `not-started` |

Every other combination is `20 PROCESS_TOOL`. The outcome contains no command path, output path, native error text, stdout, or stderr. CLI syntax is exactly:

```text
node Validate-NpmAudit.mjs --report REPORT --stderr STDERR --outcome OUTCOME
[--exceptions EXCEPTIONS]
```

Options are ordered, single-use, nonempty separate values without aliases. The validator opens ordinary non-link protected inputs and recomputes both stream lengths/hashes. It never prints input bytes or native exception text.

Production orchestration spawns only the resolved Corepack executable with arguments `npm`, `audit`, `--package-lock-only`, `--json`, `shell:false`, at the package root. It concurrently drains raw Buffer streams, retains bounded prefixes while continuing to drain overflow, waits for `close`, and reconciles an earlier `error` exactly once. It writes report, stderr, and outcome as new mode-`0600` files. At 120,000 ms on hosted Ubuntu it signals the detached process group with `SIGTERM`, waits 5,000 ms, and sends `SIGKILL` if still open. Delivery or close failure is `PROCESS_TOOL`. Windows exercises all pure outcome/validator fixtures but does not claim process-tree termination parity.

`stdoutOverflow` is class `21`; `stderrOverflow` is class `20`. Stderr is never decoded. In `finally`, remove all three protected files; cleanup failure fails the job without replacing the validator's recorded class.

Before `JSON.parse`, enforce an 8,388,608-byte raw stdout maximum, BOM-less strict UTF-8, one complete JSON value/trailing-whitespace only, depth/count/string/number ceilings, and duplicate-key detection with a reviewed JSON tokenizer. The closed valid report has `auditReportVersion: 2`, `vulnerabilities`, and `metadata` only. Every vulnerability property has exact keys/types for `name`, `severity`, `isDirect`, `via`, `effects`, `range`, `nodes`, and `fixAvailable`; its property key equals `name`.

`via` contains only:

- an advisory object with closed `source`, `name`, `dependency`, `title`, `url`, `severity`, `cwe`, `cvss { score, vectorString }`, and `range`; or
- a package-name string that is a real edge to another vulnerability property.

`effects` and package-string `via` edges are reciprocal; referenced packages exist. `nodes` is a sorted unique installed-path set. `fixAvailable` is exactly `false`, `true`, or closed `{name,version,isSemVerMajor}`. Metadata has closed nonnegative safe-integer severity counts `info|low|moderate|high|critical|total` and dependency counts `prod|dev|optional|peer|peerOptional|total`; reconcile totals/severity properties without inventing advisory-to-node Cartesian edges.

The decision table is exact:

| Native outcome | Parsed graph | Decision |
| --- | --- | --- |
| exit `0` | valid and empty | continue; exception file must be absent |
| exit `0` | nonempty | status/report mismatch |
| exit `1` | valid and nonempty | evaluate exact exception policy |
| exit `1` | empty or malformed | status/report/schema failure |
| other exit, signal, timeout, start failure | any | process/tool failure; never governed residual |

Validator exit classes are: `0 PASS`, `20 PROCESS_TOOL`, `21 AUDIT_INPUT_JSON`, `22 AUDIT_REPORT_SCHEMA`, `23 AUDIT_STATUS_MISMATCH`, `24 AUDIT_POLICY_MISMATCH`, and `25 AUDIT_GOVERNANCE`. Each fixture expects one exact class, normalized Finding set, package-keyed AuditNodePaths set, exception state, and safe diagnostic.

Record the dated baseline as four separate observations: seven vulnerability properties (the seven package keys listed above), 14 advisory objects, two package-string graph edges, and seven installed node paths. Store Node/npm/ Corepack versions, exact argv/native outcome, report SHA-256, and the exact four sets. These numbers describe the 2026-07-29 input only and are prohibited as acceptance constants.

Classification precedence is process envelope `20`, raw report `21`, report schema/graph `22`, exit/report agreement `23`, residual equality `24`, then exception governance `25`. Only ordinary exit `0` or `1` reaches parsing. Parser limits are depth `64`, value tokens `250,000`, string-token bytes `1,048,576`, and number-token bytes `64`; reject the first over-limit value, all raw duplicate keys, BOM/invalid UTF-8, a second value, and non-whitespace suffix before object construction.

#### Embedded canonical follow-up reference and filing evidence

A residual exception's finding adds exact closed fields: `followUpIssueUrl`, `followUpIssueNumber`, `followUpScopeSha256`, `followUpVerifiedAt`, and `followUpEvidenceSha256`. Parse the URL and require serialized equality to `https://github.com/franklesniak/TerraformStyleGuide/issues/<number>`: lowercase canonical HTTPS host, exact owner/repository/path case, no credentials/port/query/fragment/trailing slash/encoding/dot segment. Number is a JSON safe integer whose canonical decimal matches `[1-9][0-9]*` and the URL exactly; reject `/pull/` and every alternate repository/form.

`followUpScopeSha256` hashes a versioned canonical JSON array of the exact sorted current `(Package, AdvisoryUrl)` identities assigned to that issue. Every finding is covered exactly once (or by one explicitly shared issue scope) with no missing/extra/stale identity. The issue body contains reviewed marker `npm-audit-findings-sha256: <same-lowercase-64-hex>` plus owner, remediation objective, and target date.

The exception root has exactly `schemaVersion`, `observedFindings`, `approvals`, `auditNodePaths`, and `followUpEvidence`. `followUpEvidence` is a sorted unique array with one record per distinct referenced issue and no unreferenced record. Approvals may share a record only when their exact sorted identities yield that record's one scope hash. Every approval's number/URL, scope hash, verification time, and evidence hash equals its record.

Each record has these properties in this canonical order:

```text
evidenceSchema
verificationMethod
apiVersion
verifiedAt
verificationActor
repository
issueUrl
issueNumber
issueDatabaseId
issueNodeId
state
isPullRequest
createdAt
updatedAt
author
assignees
responsibleOwner
targetDate
scopeMarker
scopeSha256
titleSha256
bodySha256
```

`evidenceSchema` is `TerraformStyleGuide.NpmAuditFollowUpEvidence.v1`; `verificationMethod` is `github-rest-user-and-issue-v1`; and `apiVersion` is the exact REST version used for capture. Whole-second UTC timestamps satisfy `createdAt <= updatedAt <= verifiedAt`. Verifier, author, and assignees are closed `{login,databaseId,nodeId}` objects; assignees sort uniquely. Repository is exactly `{owner:"franklesniak",name:"TerraformStyleGuide"}`. The issue database ID is a positive safe integer and node ID is 1–128 safe ASCII bytes. State is `open`; `isPullRequest` is false. `responsibleOwner` equals each referencing finding owner and appears exactly once in assignees. The canonical target date is present in the issue marker set and is no later than exception expiry. Scope marker/hash and title/body hashes bind the reviewed live issue.

Canonicalization constructs new null-prototype objects in the stated order, sorts arrays by their defined keys, rejects lone surrogates, and uses native `JSON.stringify`. SHA-256 covers that exact BOM-less UTF-8 serialization with no whitespace/final newline; the digest is not in the record.

Add `.github/workflows/Capture-NpmAuditFollowUpEvidence.mjs`. Initial approval and every renewal give it exact issue number, expected scope hash, responsible owner, and a new protected output path. A non-logged environment variable supplies its token. It performs authenticated no-redirect `GET /user` and `GET /repos/franklesniak/TerraformStyleGuide/issues/<number>`, bounds each response at 1 MiB, and rejects non-200, malformed/extra required shape, identity mismatch, pull request, non-open state, missing responsible assignee, or missing/duplicate/wrong markers. It writes only the canonical minimized record create-new mode `0600`; never token, headers, raw response, title, body, or email. The approver embeds that exact object and deletes the scratch record in the same reviewed change.

The capture client sends exact `Accept: application/vnd.github+json`, `X-GitHub-Api-Version: 2022-11-28`, and fixed `User-Agent: TerraformStyleGuide-audit-governance/1`; it accepts no redirect, proxy/auth ambient configuration, compressed body, or cached/offline substitution. Each logical GET permits at most three total attempts and each body is bounded at 1 MiB before decoding. Only HTTP `429`, `502`, `503`, and `504` are retryable. Authentication/network/TLS failure, every other status, redirect, malformed header/body, exhausted attempts, or a required wait over 30 seconds fails closed.

For a retryable response, a present `Retry-After` must be one canonical ASCII integer seconds value `0`–`30`; malformed, duplicate, date-form, signed, whitespace-padded, or over-cap values fail. Without `Retry-After`, a canonical single `x-ratelimit-reset` may be used only with `429`; parse it as unsigned decimal epoch seconds against the client's one captured system instant and require a ceiling delay of `0`–`30`. A past reset means zero. Missing reset on `429` uses the fixed fallback only when `x-ratelimit-remaining` is not canonical `0`; remaining `0` without a usable bounded reset fails. All other retryable responses without an authoritative delay wait exactly one second before attempt two and two seconds before attempt three. Record only endpoint, attempt, status/native class, selected delay source, and delay—not headers or body.

Require `verificationActor.login == approvalIdentity` and:

```text
verifiedAt <= createdAt == approvedAt <= verifiedAt + 3600 seconds
```

Renewal repeats live reads, current fix-availability analysis, scope/body/ assignee review, and approval. Reusing an old record or changing only timestamps fails.

The pure validator reconstructs every embedded evidence preimage and digest, then checks URL/number grammar, exact record coverage, scope, timestamp, identity, and exception policy. It performs no network access or issues permission and says only `offline-follow-up-evidence-valid`, never that the issue is currently open. The record proves live state observed at `verifiedAt`; the 30-day approval bound is its maximum offline staleness.

When all residuals disappear, delete the exception file; reviewed Git history retains the record. Removing one scope removes its findings and now-unreferenced record atomically. Missing, duplicate, unreferenced, changed-hash, or incompletely removed records fail governance.

Reject unknown/missing properties, wrong types, noncanonical/duplicate URLs or paths, duplicate finding/package identities, malformed timestamps, empty owner/follow-up/approval, invalid issue URLs, missing or extra findings, missing or extra node paths, expired entries, and any exception file when the normalized audit is empty. The file is absent when no residual exists; never create a blank mechanism “for later.”

The audit manifest appends these physical rows:

| ID | Literal fixture |
| --- | --- |
| `AUDIT-165` | missing evidence array |
| `AUDIT-166` | missing referenced record |
| `AUDIT-167` | extra unreferenced record |
| `AUDIT-168` | duplicate issue record |
| `AUDIT-169` | evidence hash mismatch |
| `AUDIT-170` | verified-time mismatch |
| `AUDIT-171` | verifier/approval mismatch |
| `AUDIT-172` | closed issue record |
| `AUDIT-173` | pull-request record |
| `AUDIT-174` | wrong repository |
| `AUDIT-175` | URL/number mismatch |
| `AUDIT-176` | invalid database/node identity |
| `AUDIT-177` | responsible owner absent from assignees |
| `AUDIT-178` | scope marker/hash mismatch |
| `AUDIT-179` | invalid title hash |
| `AUDIT-180` | invalid body hash |
| `AUDIT-181` | timestamp/order failure |
| `AUDIT-182` | approval session exceeds 3,600 seconds |
| `AUDIT-183` | valid single-issue record |
| `AUDIT-184` | valid shared-issue scope |

The capture-helper catalog has these immutable physical rows; each is Ubuntu/Node 24 only and declares one exact response/header fixture, call count, terminal class, output-file state, and safe diagnostic:

| ID | Literal fixture | Exact oracle |
| --- | --- | --- |
| `T3-CAPTURE-001` | issue `404` | fail; one issue attempt; no output |
| `T3-CAPTURE-002` | redirect | fail; no redirect follow; no output |
| `T3-CAPTURE-003` | nonretryable API `403` | fail once; no output |
| `T3-CAPTURE-004` | issue object contains pull-request marker | fail; no output |
| `T3-CAPTURE-005` | closed issue | fail; no output |
| `T3-CAPTURE-006` | wrong repository or database/node identity | fail; no output |
| `T3-CAPTURE-007` | responsible assignee missing | fail; no output |
| `T3-CAPTURE-008` | scope/body marker changed | fail; no output |
| `T3-CAPTURE-009` | response exceeds 1 MiB | fail at byte limit; no output |
| `T3-CAPTURE-010` | `429`, `Retry-After: 31` | fail without retry |
| `T3-CAPTURE-011` | `429`, bounded canonical reset | one bounded wait; next attempt succeeds |
| `T3-CAPTURE-012` | `503`, no retry headers | waits 1 then 2 seconds; third failure is terminal |
| `T3-CAPTURE-013` | malformed/duplicate retry header | fail without sleep |
| `T3-CAPTURE-014` | valid open issue and actor | canonical create-new output succeeds |
| `T3-CAPTURE-015` | live state drifts from embedded evidence | verification fails; cached state forbidden |

Run this same validator:

- for every ordinary and Dependabot pull request to `main`;
- for merge queue when enabled;
- for every push to `main` before writer authorization;
- on the read-only UTC schedule; and
- on optional read-only manual dispatch.

The schedule/manual path invokes no candidate, artifact, approval, or writer job. Scheduled failure creates visible evidence and requires a normal issue/pull-request fix; it never auto-edits, auto-approves, or auto-merges.

### 8. Establish final npm Dependabot governance

Change `.github/dependabot.yml` to normalized exact content with two and only two update entries:

1. `github-actions` at `/`; and
2. `npm` at `/.github/workflows`.

Both use the approved review-only schedule. Reject duplicate/extra ecosystems, wrong directories, ignored security updates without approval, and every automatic approval/merge behavior.

Dependabot proposals require normal CI, package/changelog/engine review, lockfile review, actual-hook integration evidence, and audit normalization. They do not bypass the action SHA allowlist or residual-risk process.

This two-entry state replaces T1's intermediate one-entry assertion.

### 9. Revalidate and classify inherited controls

Classify prior controls:

Enduring behavior that must remain green:

- deterministic generator and LF/BOM policy;
- helper/context/harness stable IDs and cleanup behavior;
- immutable artifact ID/digest transport;
- action pins/permissions/events;
- full Windows matrices and exact-lease writer;
- T2 exact-block state-recovery harness;
- outer/nested lint semantics; and
- generated artifact bytes unless a reviewed lint fix is separately required.

Final-state assertions owned by this issue:

- Node/package/contributor floor;
- package and lockfile content;
- hook runtime guard;
- Markdown job runtime matrix; and
- exactly two Dependabot entries.

Historical one-time gates that are not inherited:

- earlier issue-specific affected-file counts; and
- T1's one-entry Dependabot path gate.

All enduring security behavior remains mandatory.

## Validation

From fresh clones and clean dependency state:

1. run selected minimum and preferred Node versions;
2. record actual Node path/version, Corepack path/version, exact selected `npm@12.0.2` version, and verified package-manager descriptor/integrity;
3. scope/restore `CI=true` around `corepack npm ci`;
4. hydrate once in the job-local trusted phase, then run a second `corepack npm ci` from clean `node_modules` with network disabled;
5. run `corepack npm ls --all`;
6. run both lint scripts;
7. run every physical `T3-NODE-*`, `T3-NPM-*`, `T3-HOOK-*`, `T3-HUSKY-*`, `T3-CAPTURE-*`, and `AUDIT-*` ID;
8. perform at least one real installed Husky `git commit` on each OS family;
9. capture the structured native outcome plus bounded stdout/stderr identities and the human-readable audit;
10. invoke the exact tracked audit validator and validate exceptions, if any;
11. validate exact two-entry Dependabot content;
12. run the structural workflow validator, including schedule/manual no-writer fixtures and Node-policy equality;
13. run T1/T1A/T1B/T2 complete evidence;
14. regenerate and require unchanged four output blobs;
15. require exact changed/staged path equality to the final computed T3 set; and
16. rerun from staged content with no additional diff.

Capture pull-request evidence for every required job/cell and a post-merge push showing the artifact pipeline remains correct.

## Acceptance criteria

- [ ] Final direct packages are maintained, justified, and installed reproducibly without force flags.
- [ ] `packageManager` equals the exact hashed `npm@12.0.2` descriptor; every package command uses Corepack and the second install is offline.
- [ ] Every package operation consumes literal `T3-NPM-OPERATIONS-v1` and SHA-256 `76eb77bc407b9cf6792bb05bb4cb297520752b91436c111b81c6749365b114fb`; no ambient executable/argv/config/network/cache/policy input can weaken it.
- [ ] Lockfile version/tree exactly matches `package.json`; `corepack npm ls --all` passes.
- [ ] `engines.node` is exactly `>=22.22.2 <23 || >=24.15.0 <25`; policy module, CLI, workflow, and hook enforce the same finite table.
- [ ] No ordinary validation relies on EOL Node 20.
- [ ] Malformed, below-minimum, odd/intervening, admitted 22/24 boundaries, and the first unreviewed future even major have explicit passing or rejecting oracles.
- [ ] The exact outer and nested lint behaviors remain correct.
- [ ] Every tracked integration ID passes on minimum/Node 24 and both OS families.
- [ ] At least one real clean-installed Husky hook is invoked by `git commit`.
- [ ] The tracked fail-closed installer is the exact `prepare` command; required installation invokes only verified local Husky `9.1.7`, proves the independent tracked-hook schema and exact 17 generated files against `husky-install-contract.json`, and only the three closed skip states may avoid installation without mutation.
- [ ] Temporary outer/nested violations and tooling/runtime failures reject for the intended reason.
- [ ] One tracked validator governs every local/hosted audit invocation with stable input/schema, mismatch, and expiry exit classes.
- [ ] Audit orchestration applies the exact 8-MiB/strict-UTF-8/duplicate-key/ closed-report-v2 graph schema, the structured process envelope and bounded stderr, and the explicit `0`/`1`/other/signal/timeout/start-failure decision table.
- [ ] The audit is zero with no exception file, or current `ObservedFindings` and package-keyed node paths exactly equal the exception's observed facts while a separately keyed `Approvals` collection is valid, scope-exact, and unexpired at no more than 30 days.
- [ ] Every `AUDIT-*` clean, residual, topology, schema, duplicate, and before/at/after-expiry oracle through `AUDIT-184` appears as one physical `npm-audit-cases.json` row and passes with its one exact result.
- [ ] Offline follow-up URL/scope/evidence validation is distinguished from current live state; every minimized capture record is embedded in the exception, independently rehashable, exactly referenced, and bound to the approval session.
- [ ] The catalogs contain exactly 48 `T3-NODE`, 12 `T3-NPM`, 58 `T3-HOOK`, 30 `T3-HUSKY`, 15 `T3-CAPTURE`, and 184 `AUDIT` physical IDs; each has one literal applicability/input/oracle and one reconciled result, with no family/range allocation left to implementation.
- [ ] Ordinary/Dependabot PR, merge-group, `main` push, schedule, and manual event fixtures all invoke the same validator; schedule is exactly `'23 17 * * 3'` and schedule/manual cannot reach publication.
- [ ] Dependabot contains exactly GitHub Actions `/` and npm `/.github/workflows`, review-only.
- [ ] Exact action pins/roles, permissions, triggers, helper, artifact, matrices, writer, and T2 shell evidence remain green.
- [ ] Generated artifacts remain byte-stable unless separately reviewed.
- [ ] The final affected-file gate is recomputed and exact.

## Non-goals

- Upgrading external GitHub Actions without a separate provenance review.
- Changing state-recovery or destructive-state guidance.
- Replacing the full-lint Terraform hook with a staged-content API.
- Automatically approving/merging dependency updates.
- Accepting permanent or ownerless advisory exceptions.
- Forming unproved advisory-to-node-path pairs.
- Using `--force`, `npm audit fix --force`, or engine bypasses.

## References

- [npm audit](https://docs.npmjs.com/cli/commands/npm-audit/)
- [npm package.json engines](https://docs.npmjs.com/cli/configuring-npm/package-json#engines)
- [Git hooks](https://git-scm.com/docs/githooks)
- [Husky](https://typicode.github.io/husky/)
- [markdownlint-cli2](https://github.com/DavidAnson/markdownlint-cli2)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [Dependabot options](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
