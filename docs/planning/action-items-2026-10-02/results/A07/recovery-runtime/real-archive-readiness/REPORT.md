<!-- markdownlint-disable MD013 -->

# R5/B1 selected real archive readiness

The three fixed selected vendor archives pass full digest checks, bounded layout inspection, actual extraction, and direct Node/npm version execution. This closes the real-archive identity and extraction-cap headroom question for these bytes. It does not implement or accept R5/B1 or Gate A. No selected pin, cap, scope, owner, counter or prerequisite was changed.

The selected role table is PROPOSAL.md:75-77: preferred Node24 on Linux x64 and Windows x64, plus Node22 recovery compatibility on Linux x64. PROPOSAL.md:122 states: "Accept that switch only on Linux x64." No Windows Node22 role was selected or qualified.

## Inputs and exact headroom

The current official [Node24 checksum list](https://nodejs.org/dist/v24.18.1/SHASUMS256.txt) and [Node22 checksum list](https://nodejs.org/dist/v22.23.3/SHASUMS256.txt) were independently retrieved on 2026-10-05 over verified HTTPS, no redirects, 30-second socket timeout and bounded total transfer/size. Both reproduce the selected exact archive digests. The cached Windows ZIP was reused only after its entire SHA256 matched; both Linux archives were downloaded from their fixed official version directories into this fresh private scratch. HTTPS provenance is proved; detached-signature verification is not claimed. The full source text, acquisition records and hashes are preserved in evidence-catalog.json.

Selected caps are 50,000 entries and 1,073,741,824 expanded bytes per archive. Counts include all directory, file and link archive members; expanded sizes sum declared member sizes and equal actual extracted regular-file totals.

| Selected role/platform | Actual Node / npm | Compressed bytes | Entries | Expanded bytes | Remaining entries / bytes |
| --- | --- | ---: | ---: | ---: | ---: |
| preferred/linux-x64 | 24.18.1 / 11.16.0 | 31,525,884 | 5,774 | 196,033,054 | 44,226 / 877,708,770 |
| preferred/win-x64 | 24.18.1 / 11.16.0 | 37,177,316 | 2,449 | 105,735,176 | 47,551 / 968,006,648 |
| recoveryCompatibility/linux-x64 | 22.23.3 / 10.9.9 | 31,001,304 | 5,866 | 196,362,450 | 44,134 / 877,379,374 |

The largest actual archive uses 11.732% of the entry cap and 18.288% of the byte cap. Each archive has exactly its named `node-vVERSION-PLATFORM` root and the required ordinary Node executable, npm package.json and npm/npx CLI files. The Windows ZIP contains 1,984 files and 465 directories (2,449 actual extracted paths including root), no links/reparse attributes, and no implicit extra-directory discrepancy. All ZIP names are ASCII; no tilde names, reserved Windows devices, drive/UNC/ADS, traversal, trailing-dot/space aliases, duplicate/case collisions or file-directory collisions were detected. The exact extracted Windows path/kind union equals the archive union including parents. The fresh extraction root, its ancestors and resulting tree were checked for links/junctions/reparse points.

Both Linux archives contain exactly three relative symlinks: `bin/npm -> ../lib/node_modules/npm/bin/npm-cli.js`, `bin/npx -> ../lib/node_modules/npm/bin/npx-cli.js`, and `bin/corepack -> ../lib/node_modules/corepack/dist/corepack.js`. Each resolves to a regular member inside its own release root and is preserved by actual extraction. No hardlinks, devices/FIFOs, escaping links, setuid/setgid, or group/other-writable regular executables were found. Regular files/directories use 0644/0755; link attributes are 0777. Extracted Node mode is 0755. Exact Linux extracted path sets and totals match inspected members.

The exact selected clause at PROPOSAL.md:127 is: "Reject absolute/traversing members and links that escape that root." The same paragraph requires the exact root and safe official npm/npx links; it does not specify a two-name allowlist. The selected general in-root-link rule admits the official corepack link as well as npm/npx. The implementation must not turn the proposal's npm/npx examples into an unselected two-name-only ban. This is actual vendor-layout detail, not a new runtime role or authority to execute Corepack. No selected-contract contradiction or new decision is required by these inputs.

## Actual execution and reproducible boundary

Windows: Microsoft Windows10.0.26200, native x64 process, existing PowerShell7.6.5/.NET10.0.11. PowerShell7 .NET ZipFile/ExtractToFile with overwrite=false extracted only into the fresh owned `windows extracted runtime` directory. Direct absolute `node.exe --version` returned `v24.18.1` (exit0); direct absolute Node plus bundled `npm-cli.js --version` returned `11.16.0` (exit0). The package declaration independently matches11.16.0. Terminal28226 completed0.

Linux: existing qualified image `sha256:8bdc7722fc55e19fd3df48d8fddf4568a75d8792cfc4ee105c8a8173559362f4` inspected as linux/amd64; no pull/build/install. Kernel6.6.87.2-WSL2, glibc2.39, Python3.12.3, fixed `/usr/bin/tar` GNU1.35. Execution used UID/GID1000, network=none, all capabilities dropped, no-new-privileges, read-only container root, read-only own archive/script input, own results bind and disposable executable 1GiB tmpfs. GNU tar used `--no-same-owner --no-same-permissions --delay-directory-restore`. Actual extracted Node24 returned `v24.18.1`, bundled npm11.16.0; Node22 returned `v22.23.3`, bundled npm10.9.9. All native commands exited0. Terminal28531 completed0; exact argv/results are in results/linux-command-attempt3.json and results/linux-execution.json.

Before version execution, inherited NODE_OPTIONS/NODE_PATH and all case-insensitive npm_config_ options were removed in the private processes. npm received fresh empty owned user/global configuration files and a private cache location. Only version queries ran; no package install/audit/lint/bootstrap/hook or network request ran from these runtimes. Node22 stayed off PATH. Actual executable, npm CLI/package and GNU tar SHA256 values are cataloged, alongside every archive member/type/mode/link. Static binary headers independently identify both Linux executables as little-endian ELF64 x86_64 and the Windows executable as PE32+ x86_64.

Two earlier Linux harness failures are retained: attempt1 used a Windows separator in its inventory reference and stopped before Node; attempt2's Docker tmpfs had default noexec and refused Node execution. The successful attempt explicitly set `exec` on the private tmpfs. These are bounded harness configuration failures, not vendor failures or production installer results. Future runner storage must actually permit intended executable use; this does not authorize permission changes to an existing host directory.

Exact host invocation: `C:/Users/flesniak/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe -NoLogo -NoProfile -NonInteractive -File <this scratch>/windows-qualify.ps1 -Root <this scratch>`. Linux orchestration: `python <this scratch>/run-linux-v3.py`; that immutable script contains the exact digest-pinned Docker command. Acquisition/inspection: `python <this scratch>/acquire-inspect.py`. These commands are evidence for this scratch execution; rerunning extraction into an existing destination is intentionally refused.

## Remaining acceptance boundaries

Canonical selected SELECTION/PROPOSAL and A03 C98 foundation decision bytes are pinned in the catalog. The anticipated eight-path acquisition and coordinated A03 consumers remain under their existing owners; A04 ordinary transport, A15 required recovery cells, B99, A06/A21 future harness/caller integration and all402 obligations retain their existing boundaries.

Still required for usable R5/B1 foundation acceptance: actual installer implementation; Windows credential resolution and trusted-tool identities; schema2 plus retained historical Copilot admission; verified fresh Windows DACL/POSIX isolation; hostile archive and failure controls; real download retry/digest-before-extraction/no-later-marker tests; full selected caller/test integration; required platform/runner evidence and normal lifecycle. Actual recovery-harness/platform cells and real operator/peer Gate A/B approvals remain later work. This report proves neither Windows5.1 execution nor hosted runners. No product/checkouts/index/ref/config/workflow/dependency-tree changes, broad suites, image changes or system installations were made. Only this fresh scratch and disposable container storage were written.
