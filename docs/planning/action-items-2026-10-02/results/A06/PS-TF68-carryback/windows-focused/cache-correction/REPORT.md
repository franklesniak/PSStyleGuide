<!-- markdownlint-disable MD013 -->
# Windows focused cache correction — proposal only

Failure: `run-one` remains FAILED; setup and runtime identity exited 0, but npm left `tmp/node-compile-cache` before any of the six product groups ran.
Cause: pinned npm `lib/cli.js` calls `enableCompileCache()` without a directory; the private runner bound OS temp but supplied no cache location.
Fix: give Node a separate owned absolute `NODE_COMPILE_CACHE`; retain the strict empty-test-temp assertion and preserve all first-run evidence and residue.
Test proposed: one bounded pinned `npm --version` relocation check, then the six outstanding groups; reuse the two successful setup stages after exact input guards.
Classification: scratch-environment correction under [DECISION-PROCESS.md step 1](C:/Users/flesniak/GitHub/PSStyleGuide/docs/planning/action-items-2026-10-02/DECISION-PROCESS.md:9); no production, guide, policy, security, or acceptance change. No new product finding or decision table.

## Evidence

The successful fixture-init job recorded 19 total processes; runtime qualification recorded 10. Each ended with zero active/terminated processes and no job cleanup fault. This supports the actual successful command lifecycle only; it does not establish timeout or fault-path qualification. Runtime identity is Python 3.12.10, PowerShell 7.6.5, Node 24.18.1, npm 11.16.0 and Git 2.55.0.windows.5. The first-run final source/dependency/runtime guards had no failure; the product Git guard matched. This inspection independently rechecked the retained fixture's 78 source and 1,914 dependency hashes without executing a product command.

The pinned npm bootstrap and complete retained cache/file hashes are in `evidence.json`. Node's exact-version [module documentation](https://nodejs.org/download/release/v24.18.1/docs/api/module.html#module-compile-cache) confirms that the environment variable supplies the cache directory; otherwise the API uses OS temp plus `node-compile-cache`. The recorded residue, bootstrap and environment explain this failure. Cache filenames are observations, not a layout contract.

## Concrete controlled continuation

1. Leave the original runner, manifest, `run-one/result.json`, stage evidence, logs and old cache unchanged. Retain FAILED as the original outcome. Do not delete or move its residue.
2. Create one new root-owned continuation runner/result under `windows-focused/continuation-one`. Require this new directory to be absent. Bind the original evidence hashes in this packet. Verify the original packet/runtime hashes, both frozen catalogs, the retained private fixture, and the unchanged staged product Git guard before continuation. Reuse `run-one/fixture`, its initialized private Git repository, existing empty hooks, and isolated home. Do not initialize Git or install dependencies again. The existing fixture remains the owned working area; original result/log/cache evidence stays immutable.
3. Create fresh `continuation-one/tmp`, `output`, and `runtime-cache/node` directories. Reject reparse paths and require containment in that exact owned continuation root. Set `TEMP`, `TMP` and `TMPDIR` to the new tmp. Set `NODE_COMPILE_CACHE` to the new absolute runtime-cache/node path. Preserve all other isolated environment settings. Do not set a cache-disable or security-bypass flag.
4. Keep the existing gated worker/Job Object mechanics. Run only the pinned Node executable with the pinned npm CLI and `--version` as a 60-second relocation check. Require exit 0, npm 11.16.0, an empty owned job, an empty new tmp, and regular cache files confined to the designated cache directory. Record this as a cache-location check, not a repeated runtime qualification. If it fails, stop with its primary failure intact.
5. Continue the six original groups in their existing order and deadlines: analysis/artifact 180s; persistent conversion 180s; setup reader 300s; selected CI helpers 600s; dependency controls 180s; PS blank-line semantics 120s. Preserve every original control, fixture cwd and executable. Change only their output destinations to the continuation output. The exact original argv arrays are retained in evidence for mechanical output-path replacement. Skip fixture-init and full runtime-qualification.
6. Keep the existing per-stage fixture hash checks and strict empty-tmp test. Keep final product source/dependency/runtime/packet/Git guards, native exit fidelity and separate cleanup faults. Recheck the original failed evidence and cache hashes. Record the new cache catalog as an intended runtime artifact; retain it without deleting it. Report successful setup as reused evidence and each previously unexecuted product group as a new result. Never rewrite the failed run as passed.

Root owns any runner implementation and release. This packet changed only REPORT.md and evidence.json. No test, native tool, continuation, runner edit, product edit, Git operation, installation, planning update or state update was performed.
