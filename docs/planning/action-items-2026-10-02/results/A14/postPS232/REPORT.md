<!-- markdownlint-disable MD013 -->
# A14 reassessment after accepted PS232

**The selected R2 child and R21 manifest boundaries are now delivered on both accepted repositories.** The previously pending PS delivery condition is satisfied. D92/D93 remain conditional-no-trigger for the named generator/verifier and retired-consumer residuals. Keep PS155 open and A14 active for relevant later A06, R5/runtime, recovery and final accepted-pair changes. This is not a finding that all filesystem races are fixed or that A03/A07/A21 or the whole plan is complete.

Accepted PS is `f0684acd81a1a6e53d87e43881c1ec4f1310b17c`, tree `2cf6900441e7a64d2248769e6b9159caa48cc313`; predecessor is `f168f83b89f64b6bca9d520ddec4b58969060fb6`. Accepted TF remains `56cb0418dcdcf71be94acc78d8963ea580b8a9e9`, tree `377d9980fdd4008e806366ca90b1ce2811c2f519`. Fresh authenticated native refs matched at the initial capture and final readback at 2026-10-05T14:01:27Z. Product inputs came only from named raw Git objects using replacement-disabled Git; current PS/TF working files and indices were not treated as accepted inputs.

The PS receipt records actual acceptance at `2026-10-05T13:42:41.234151+00:00`, all five actual merged push workflows successful, 507 Node passes/0 fail/0 skip, content/mutation checks, 11 hooks and the final immutable-input guard. Its SHA256 is `2005c051fbc11017c416f919a0467fd704c73efc850a27912216261a6483d783`. The unchanged accepted TF receipt SHA256 is `0003dd7f852bf1854d29a8bb5dc4625af481b7142b627b1b21b799be79d68f36`, with 515 passes/0 fail/0 skip and five successful landed workflows. All 23 referenced native/pair/log/job supporting file hashes matched their receipts. [Native acceptance comment5995838012](https://github.com/franklesniak/PSStyleGuide/pull/232#issuecomment-5995838012) independently records the same scope and pending A07/A21 follow-up. Historical canceled reviews remain canceled.

## Delivered checks and relevant exact identities

The PS adapter checks a non-symlink regular manifest leaf, its one-MiB static size limit and canonical containment before reading the canonical path. It then preserves the exact Node version gate. Before execution it checks a non-symlink regular child leaf and component-aware canonical containment, and supplies the canonical child pathname to the existing bounded runner with `--outer`, selected cwd, two-minute timeout and two-MiB output limit. Regular children, contained ancestor aliases and root aliases remain supported.

| Role | PS predecessor blob | Accepted PS blob | Accepted TF blob |
| --- | --- | --- | --- |
| `lint-markdown.mjs` | `9b0abb08d1a17ed4306ef771822d980aabff86b5` | `111664ff4fdc416d4599d80f3657d29c9e7dba15` | `8efcf8686a55835ba87af43dbe357011b856c1dd` |
| `lint-markdown.test.mjs` | `2d79be38b1caeeb871de4ed2c8222b950c4a6ae7` | `e3d5bb84e389d1b6ffe0033aafb1b821eb792a58` | same |
| `NpmTools.mjs` | `6f1739b6dfd0108f813506f86f95ec4f2a75bd7e` | `63ef521a77b4c515d17b3152e92d2666f9d4a6d8` | same |
| `lint-nested-markdown.js` | `0c7633c0793be84ce6768698387052807a149329` | `3284f63d128288ce511391b693b1ba350b918f2c` | same |
| `lint-staged-markdown.mjs` | `21063b3c86ffcee7c928b149d390065b8bcc1840` | `24f0ea7d1f94752547b7e363eaf92595f6b07b11` | same |

These paths are under `.github/workflows`; all are regular mode100644 blobs. Evidence contains full mode/type/size/blob/raw-SHA256 identities for the 23 relevant paths across PS-before/PS/TF, including absent paths. All 40 prior inventory identities, including the absent TF historical decision path, match the previous A14 evidence.

The whole lint-test blob is equal, including nine real-child execution-marker cases and eleven real-manifest/CLI cases. The existing landed PS instruction log for run37315027168 and TF log for run37266076803 each explicitly report success for all 20 cases. Their SHA256 values are respectively `c701fc00f7e3336bc37a7002152ac9590c4722680c95ab7dc0cb144f888b2fad` and `a7dc1a42c5bab4faa25243626d94ff29dc767c380efd08b502947c4d57f12c9f`. This verifies delivery and meaningful selected test execution without rerunning anything. Historical Windows/Linux negative controls remain scoped to their recorded bytes; no new Windows full-suite, hardlink, UNC, different-drive or race test is claimed.

The adapter's only whole-file PS/TF difference is PS's explicit string/exact-version validation and separate diagnostic before mismatch comparison. R2/R21 checks otherwise agree. This known follow-up belongs to A07/A21; the difference is neither hidden nor accepted here as a necessary exception. Root-package delegation, workflow-package outer command, Husky outer phase and Invoke-MarkdownLint outer phase remain actual callers. Staged lint still imports its trusted relative module separately; R2 does not turn every import into a confined loader.

## Unchanged engines and changed callers

The six engine objects remain identical to prior A14 and the original engine inventory:

| Source under `.github/workflows` | PS blob, unchanged | TF blob, unchanged |
| --- | --- | --- |
| `Generate-StyleGuideArtifacts.ps1` | `a23d38c42770d7463920704e108ccd63240dc90b` | `a3e7e664e441d2e51f0b6f5709b8a010d6877e82` |
| `Test-ExactGitPathSet.ps1` | `b6ddf4f05a7f147d8e239b223dc7d5dae6bf4114` | `0a9f312d62ca753689abe05d3519cf0e64e74ea0` |
| `Test-StyleGuideArtifacts.ps1` | `18b8048aac58ed7b1d28a532a2aa413890483042` | `01b8fbd9f5dd9e34a4f0a3708f74eb8fd9336a5e` |

PS build, Markdown workflow, devcontainer workflow, CONTRIBUTING, manifests, Husky and Invoke-MarkdownLint are unchanged from f168. The changed setup workflow only removes redundant event path entries; its execution/copy/cleanup body is unchanged. The changed instruction workflow adds the actual local-validation and lint Node suites. Neither changes runner authority. Lint changes add native entry detection, static checks, bounded diagnostics and reuse one validated configuration within staged invocation; they add no privileged publisher or new concurrent writer contract.

Both inspected workflow sets use Ubuntu24.04, empty validation permissions and a separate contents:read publisher of committed artifacts. No `workflow_run` or contents:write appears in the scanned workflow sources. Setup still runs ordinary fixers in a checked disposable copy with GITHUB_WORKSPACE rebound, followed by original-input checks. That protects the original from ordinary fixer effects; it does not confine malicious same-user code. Link inspection, temporary-copy removal and verifier neutral-directory removal still operate by pathname.

Generator CreateNew retains its write/flush handle, but later reads, Replace/Move publication and cleanup select paths. Existing Windows file identity is not a newly delivered handle-bound create/rename/delete primitive. Before/after observations do not prove absence of transient substitution. R2/R21 similarly retain separate check, canonicalization, read and spawn operations; canonical names are reopened, not retained executable descriptors or immutable snapshots. The manifest cap is a static pre-read bound, not a concurrent-writer guarantee. Hardlink identity, universal Windows alias safety, arbitrary same-user/module confinement and pathname cleanup remain explicit residuals.

## Conditional decisions and triggers

Fresh complete issue/comment reads show PS155 open with four comments and PS156 closed `not_planned` with one. [Canonical D92/D93](https://github.com/franklesniak/PSStyleGuide/issues/155#issuecomment-5943334454) still hashes to `2c9e63ed939ba54d72b4b66602c20138c5bd78f64a8194ec3af61b505bca5fec`. All four retired extractor/context/harness/catalog paths remain absent from both accepted trees. A raw scan of 33 executable `.github` paths per repository found no old helper/E05/proof-wiring reference. Both complete current repository self-hosted runner inventories are empty; this says nothing about every external service.

| Predicate | Current disposition | Reopen on |
| --- | --- | --- |
| Supported failure in retained generator/verifier | No new material supported defect established; D92 B96 retained. | Exact supported failure or relevant A06 create/read/identity/publication/cleanup change. |
| Admitted concurrent writer or different authority | No such change in inspected accepted callers. | Explicit hostile/shared-parent requirement, new credentials/privilege/writer/promotion or materially different consumer. |
| Useful concrete primitive | No newly adopted relevant primitive in these changed inputs. | Qualified portable API/host/runtime implementation that addresses a named operation; R5/B1 date/version alone is insufficient. |
| R2/R21 static boundary | Selected repair delivered on both; pending PS delivery predicate satisfied. | Supported bypass, changed root/manifest/child/cwd/import contract, atomicity requirement, or relevant accepted carryback delta. |
| Retired-consumer coverage | D93 B100 retained, with honest historical limits. | Actual A16/A17 recovery/extraction/context consumer needs a property, current failure, or specific runner plus live branch supplies useful new evidence. |

No new material repair finding is established, so do not recreate options/rubrics or recommend a new product fix. Preserve the existing selected decisions and their limits. Do not reactivate deleted helpers to satisfy old counts. PS156's decoyable call count, missing direct journal-cap test, unmeasured ACL/domain/non-GNU/non-Linux branches and E05 data-flow limit remain historical limitations, not passed coverage.

Original379 remains superseded through D92/D93; original380-388 remain conditional-no-trigger with A14 ownership. Original389/390 remain pending with A18 primary ownership and A06/A19 collaboration. Historical credit and source hashes are preserved. This assessment changes none of the 22 outcomes or 402 original contracts, starts no PR/review clock and consumes no transfer (A14 remains0/8).

## Next action and evidence limits

Root should verify and integrate this report, replace the stale pending-PS-delivery statement, and retain A14 active/PS155 open. Reassess relevant actually accepted TF carryback changes, then A06 operation changes, qualified R5/B1 runtime inputs and A16/A17 recovery consumers. A18/A19 must refresh the final accepted pair and triggers. Current dirty TF carryback files were not inspected or credited.

Only REPORT.md and evidence.json in this private output directory were written. No tests, installs, containers, behavioral/race/alias/ACL probes, native writes, source/planning/index/ref changes, permissions changes or descendants occurred. Existing logs were read and hash-checked. Prior postTF66 evidence SHA256 remains `02a0b3180acfb14895e66a3fb3ada3360c63d017c6aafe4ef633f069c406d0a2`; prior report SHA256 is `88bbc31f24aa04b55078bbfd322cd4713a0fa1ee47b2d6fe88795d9366139d2a`.

Current evidence.json SHA256: `354abe8d7cfbd7fe9e6957db1bd34017e811d24cfc357580eb193967a462ab37`.
