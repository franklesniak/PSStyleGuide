<!-- markdownlint-disable MD013 -->
# TF68-R2 implementation and focused verification

The selected D96.5 repair is complete and frozen over TF parent `2de8f4e8b96e09628d3e571294009cbbbd8d3749`. Root displayed/selected the canonical decision and advanced A07 from 4 to 5 before release. The canonical selected decision is root-owned (SHA256 `a4ac919e835b026e155ce0d6908cf8d631bf2e883d8bba817a2a1298b3f64afa`). This report records implementation, not final repository acceptance.

## Frozen product scope

| Path | SHA256 | Raw Git blob |
| --- | --- | --- |
| `.github/workflows/package.json` | `87e0ca58fb56402808252679f7d8f8721484ddc575a814af077d7b0d23950649` | `670083e767627cfed90a61f788021dba88de1091` |
| `.github/workflows/package-lock.json` | `4923c138c8d03f9de63d0396d910060d4ba6d51a02ee884929051a57834ed176` | `12a755075c87c7ab65a4c8055975c81116c4000c` |
| `docs/dependency-maintenance.md` | `f5bc839ecc06e0783d1ab59dfbdcd43fb8ee817baacab49c12a6730430c0690c` | `d15abb9feaa371b7b7e4963382c83ca95ca8ed4d` |

All three Git modes remain 100644. The manifest selects KaTeX 0.18.2 only below `micromark-extension-math@3.1.0`. npm changed exactly one locked package entry and exactly its version, resolved archive and integrity fields. The documentation adds one paragraph explaining the explicit range crossing and removal criterion; its existing Last Updated field is genuinely 2026-10-06. All other 76 tracked files remain byte-identical to H2, including R1, the independent TF contract and all four generated outputs. Source, index and refs guards passed. The shared index, refs, configuration and installed dependency directories were not changed by this worker.

## Executed checks

Every final command, source/driver hash, native exit and result is recorded in `evidence.json` under `implementation.validation`; full output files are retained and hashed there. Node was the verified 24.18.1 executable and bundled npm 11.16.0. No final aggregate or native review/publication was run.

| Check | Native result | Meaning |
| --- | --- | --- |
| Sanitized private npm lock generation | 0 | Only the three KaTeX lock fields changed; official registry integrity matched captured metadata. |
| Private clean Windows installs and installed-graph checks | Parent 0; both `ci` and both `ls` children 0 | Both package roots installed with lifecycle scripts disabled. All four manifest/lock input hashes remained equal. No hook installer was called. |
| Windows old security/import/math/lint controls | 0 | Old 0.16.27 permits the inherited-trust link; baseline lint behavior captured from the existing qualified old graph. |
| Windows patched security/import/math/lint controls | 0 | 0.18.2 refuses inherited trust; lint rule IDs, line positions and nested results match the old graph. |
| Windows three existing affected test suites, session 72404 | 0; 244 passed, 0 failed, 0 skipped | Actual outer/staged/nested callers, npm input protections and workflow manifest admission remain functional. |
| Offline Linux focused container, session 15681 | 0 | Same security/import/math/lint controls and 244 tests passed; actual installed `npm ls` passed for both roots. |
| Linux terminal guards | Passed | Candidate/dependency bytes equal before and after; host source/index/refs equal. |
| Final diff/identity guard | 0 | Exactly the released three product paths changed; no staged or untracked files. |

The common focused suite command was:

```text
node --test .github/workflows/lint-markdown.test.mjs .github/workflows/NpmTools.test.mjs .github/workflows/Validate-WorkflowPolicy.test.mjs
```

The actual npm child commands were:

```text
npm install --package-lock-only --ignore-scripts --no-audit --fund=false --include=dev --package-lock=true
npm ci --ignore-scripts --no-audit --fund=false --include=dev --package-lock=true
npm ls --all --json --include=dev --package-lock=false
```

The helpers invoke bundled npm through the verified Node executable and existing `withNpmEnvironment`, not an ambient npm command. `refresh-lock.mjs` guards the live four inputs while generating the private candidate lock. `install-and-list.mjs` guards the selected root's four inputs around clean installation and graph checks. Exact absolute commands and working directories are in the machine-readable result set.

The security controls use a local render string only. No HTML is executed and no external service is contacted. Default options and an explicit own `trust: false` reject the link in both versions. An explicit own `trust: true` permits it in both versions. Only inherited trust changes from permitted in 0.16.27 to refused in 0.18.2. Both platforms also load the public CJS/ESM lint entry, load the math package, observe real inline/display math tokens and run real outer/nested clean and invalid cases. The existing suites exercise staged-content behavior. These checks establish the specific repair, not an assertion that all possible prototype vulnerabilities are absent.

Scratch-only correction: the first old-control attempt exited 1 because the probe expected a public `lint` export from a private markdownlint implementation file. The probe now resolves the public `markdownlint/sync` entry for ESM import. The original log remains as `old-controls-initial-wrong-private-entry.log`; final old and patched invocations passed. No product finding or test failure was hidden.

## Dependency handoff

The retained dependency root is `writer/TF68-R2/candidate`, with BOTH `node_modules` roots. The inventory contains **1,914 regular files / 18,816,897 bytes**. Files and ancestor directories were checked for symlinks/junctions. A fresh regular-file tar uses exact catalog bytes, mode 0644 and mtime 0.

- Catalog: `writer/TF68-R2/dependency-catalog.json`, SHA256 `cffdc5c28e47c05ed65a9518e9d514697f069243b16d761749fa186d0d653dc1`.
- Archive: `writer/TF68-R2/dependencies.tar`, SHA256 `4e11000a7c4612d40224fc91fbd4653dfb6a1bc8604f035a36bb22b5c388c80a`.
- Dependency delta: 97 added, 93 removed, 38 changed files. All changes are inside KaTeX except `.github/workflows/node_modules/.package-lock.json`. The former 1,910-file archive/catalog remains intact and was independently checked for the old Linux control.
- Existing runner compatibility: set `dependency_root`, `dependency_catalog`, `dependency_catalog_sha256` and `dependency_count` to these new values. Its existing safe regular-file manifest shape is retained. The qualified image remains `sha256:8bdc7722fc55e19fd3df48d8fddf4568a75d8792cfc4ee105c8a8173559362f4`.
- Platform transport: npm's Windows `.bin` wrapper bytes are unchanged. The existing Linux-only adaptation marks the exact pinned `husky/bin.js` executable, 0644 to 0755, SHA256 `c6965589a83667d43c4dc22f90dccfa91c133f8ed23629b896ce326f0a6c5cc8`. No package bytes change. No other executable-mode adaptation was required.

Linux ran without network access. It validates the freshly Windows-installed, byte-qualified transport with real imports, security probes, lint tests and installed-graph checks. It does not claim a networked Linux `npm ci`. Windows performed the actual clean locked installations.

Root can refresh the worktree installed graphs with the retained `install-and-list.mjs`, SHA256 `d61df2c4a2c3040e9d7600936b275e00791b095642ab7e2d8ccdbe671304755a`, using the exact Node executable and a new existing output directory:

```text
<verified Node executable> <writer/TF68-R2/install-and-list.mjs> <TF worktree> <new root-owned output directory>
```

That helper performs sanitized `ci` and `ls` for both roots, retains stdout/stderr/native results, and verifies that all four input hashes remain unchanged. It does not invoke bootstrap, hooks, Git or persistent configuration. Root owns this worktree installation and subsequent installed-byte comparison with the new catalog.

## Remaining gates

No new material finding remains. Product and focused evidence are frozen; no more tests or edits are planned by this worker. Root retains ordinary current audit, final aggregate, whole-PR accepted-base metadata endpoints, staging/commit, review/native acceptance and all A03/A06/A21/R5/recovery/human gates. Current advisory truth must be checked again by the ordinary audit. After TF acceptance, PS still needs the common R1 SelfTest repair with the exact T1/P1 provenance exception and this common R2 dependency/documentation repair under root's transfer process. No source PS changes were made here.
