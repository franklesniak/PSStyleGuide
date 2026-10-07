<!-- markdownlint-disable MD013 -->
# Bound TF PS235 endpoint draft; execution not authorized

The five qualified endpoint files are byte-identical to the private packet. Only data bindings were supplied. The draft keeps `prepared=false`, `execution_authorized=false`, both root confirmation flags false, and known-revocation confirmation false/null. No authorized manifest, execution directory, or short TEMP directory exists.

The candidate is clean `codex/ps235-validator-followup` at `5e2424768c5d7d78a7f8ea852d4239e62069d0fe`, tree `c19b92d54746aa4cdea4b6eee055b07de724b31a`, with sole parent accepted `a840f21b03f0dcac0815e2f7f044928667402b42`, tree `e71b81232ba0f197acf5f126e4b14f1e90ee7da2`. The accepted fixture is clean and detached at B, with actual H reachable at `refs/heads/codex/ps235-candidate`; both local `origin/main` refs equal B. Current local refs and complete pre/post guards are in evidence.json. No native main was read by this worker.

Each source catalog covers all 80 actual raw Git blobs, modes, lengths, and SHA-256 values, compared with its physical checkout and stage-zero index. Each dependency catalog covers exactly 1914 ordinary files across the two installed roots; complete path sets, lengths and hashes were verified in both repositories before and after binding. Nine named runtimes and all 54 runtime rows come from the current TF qualification manifest and were rehashed. The exact native CLI was rehashed; its older manifest supplies file identity only, never authorization or classifier results.

The guard is precisely the qualified driver's shape: head/tree, complete stage-zero index byte hash, full refs hash, effective config-with-origin hash, physical HEAD/index/config/config.worktree hashes, branch, origin/main, origin URL and cleanliness. Raw source/dependency files, absent grafts/alternates/replacement refs/promisor configuration, non-shallow state, zero audit exceptions and runtime bytes were also verified. Read-only pre/post guards are equal, and execution-state.json is byte-unchanged. Git optional locks and lazy fetching were disabled. No product or driver was imported or executed.

`binding-differences.json` records every changed top-level field, with full private and bound values. The limits, prepared-file hashes, role/task identity, three-path allowlist, one execution, no-repeat rule and command mode order are unchanged. Five actual-H modes plus CurrentAudit use the driver's exact command arrays. The preserved runner performs three scoped TF native-main reads; direct native and wrapper exits, owned Windows job settlement, current two-root audit authority, full guards and strict owned TEMP cleanup remain required. Limits remain 600 seconds per product command, 60 seconds per native read, 3900 seconds overall, 30 seconds cleanup reserve, 8 MiB per stream and 64 MiB total. No product test, container, install, native request, Git mutation or planning/state write occurred.

Finite exceptions remain exactly the master's accepted postimages: the one TF scope sentence in docs/dependency-maintenance.md and the one retained T1 provenance fixture path in the SelfTest. The validator has no substitution. The accepted peer-rebind receipt and full postimage rows are bound in evidence; no new exception or broad exemption was introduced. Accepted PS source remains `58a1345896da1a1e8794078e588e88e58a78e2eb` / `821a952c9d4be1395cab3b2af8da7a679987e4a6`, with its exact acceptance receipt hash. Dedicated-service and paired acceptance remain unfinished.

Root completion before execution:

1. Independently inspect this packet and exact differences; verify all evidence/catalog/runtime/file hashes and both guards again. Confirm unchanged H/B/trees/scope and finite exceptions. Set `root_confirmed_bindings_complete=true` and `root_confirmed_finite_exceptions=true` only after that inspection.
2. Perform fresh native PS and TF main reads and verify the accepted source/base identities. Check known revocations/current audit authority and set `root_known_revocations_checked=true` with the actual same-UTC-day `root_known_revocations_checked_utc` timestamp. This worker made no such attestation.
3. Confirm the selected short TEMP root remains absent, no run is pending, and the actual current UTC date equals both release/finalization dates. A date or input change requires rebinding; do not relabel stale evidence.
4. Create a separate `manifest.authorized.json` with `prepared=true` and `execution_authorized=true`, retain `authorizing_coordinator=root`, freeze its SHA-256, then run the one-shot command below once. Do not rename or edit the bound draft. Read completed results with the existing bound-inputs/read-results.py, preserving any failed run/residue and reconciling before any further action.

The exact root one-shot PowerShell command (computes the digest of the newly authorized file immediately before the call) is:

```powershell
& 'C:\Users\flesniak\AppData\Local\Temp\PSStyleGuide-A07-design-20261002\python-venv\Scripts\python.exe' -I 'C:\Users\flesniak\AppData\Local\Temp\TerraformStyleGuide-PS235-followup-20261007\bound-inputs\endpoints\runner.py' --run-once ((Get-FileHash -Algorithm SHA256 -LiteralPath 'C:\Users\flesniak\AppData\Local\Temp\TerraformStyleGuide-PS235-followup-20261007\bound-inputs\endpoints\manifest.authorized.json').Hash.ToLowerInvariant())
```

Selected absent TEMP: `C:\Users\flesniak\AppData\Local\Temp\tf-ps235-e1` (48 characters); not created. Binding UTC date: 2026-10-07.

Transfers A06/A03/A21/A07 remain 3/4/7/7; TF remains 7/80 with original deadline 2026-10-13T23:47:31Z. No PR, push or review request was created. Next action belongs to root: inspect, finish the root attestations, release once and collect the actual results. This worker stops writing at handoff.
