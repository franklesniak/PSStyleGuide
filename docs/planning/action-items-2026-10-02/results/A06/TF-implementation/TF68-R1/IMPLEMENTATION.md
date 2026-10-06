# TF68-R1 implementation and focused evidence

Status: worker implementation and focused coverage complete. Product and delivery artifacts are frozen. Windows coverage is explicitly attributed to separate author and native-path capacity components; Linux combined focus passed. Root owns final aggregate and whole-PR publication validation. No commit, index/config/ref mutation, review request, CI retry, aggregate run or planning change was performed by this worker.

## Scope and identity

The selected C97 code repair changes only `.github/workflows/Test-AgentInstructions.SelfTest.ps1` over TF68 head `6c0c987799425b60c0e7b76650aa5ec7946811e2`. After all focused runs terminated and the source guard passed, root separately released the existing README Last Updated field from Oct5 to Oct6 under current-date/D07 policy. This second change has no body edit. The final scope is exactly these two mode100644 files:

| File | Raw SHA256 | Git blob |
| --- | --- | --- |
| `.github/workflows/Test-AgentInstructions.SelfTest.ps1` | `2c7aaaeea5efd74c22ea395d93fc3bc1d508f78ae46e4ac1296a41aef905e67d` | `a976b7f224b4e9df0064493e3ec2c5514e9b8046` |
| `.github/workflows/scripts-README.md` | `b98c5c019a08e54ff56d98e283b1c4bb2f495d8332eb1edc39ee22aa34998467` | `de0936d30fe3489261018b281b264fff9b7330c0` |

Before that refresh, all78 other tracked raw files matched H; `pre-refresh-evidence.json` preserves the exact focused source catalog (SHA256 `2bb331b5f071ecd7b702ce520169712810bddd544db09f5b5164623652443fb4`). Final evidence verifies77 unchanged files, including the other11 original A06 port paths, all four generated outputs, the independent TF contract and semantic helper. README differs from H only by the authorized date field. The production validator remains blob `7ee712e048ab512aa751cf77c530d985d458bf7f`, SHA256 `4534cecbed38f559ed617136d796f103773851c8919489ce53b3a97ff9750020`.

Root's real accepted-B/H author-finalization check required the README refresh (failure log SHA256 `77d6e04e5e6a6793be62b9b302475847fb50f004ff9162d2321143096d90cf07`). Previous head P is not a substitute for accepted B. Focused fixtures below ran before this metadata refresh; final aggregate and whole-PR B/H finalization on both changed files remain root-owned. No claim of a complete focused rerun after the date-only change is made.

The SelfTest and its two modified existing private functions use genuine Oct6 version metadata. The sole PS/TF historical provenance-path exception remains `docs/P1-SUPPLY-FREEZE-v1.md` versus `docs/T1-SUPPLY-FREEZE-CURRENT-PROVENANCE-v1.md`.

## Behavior

One private helper pins the actual validator's captured UTC timestamp/date/bound and changed-local-path date with unique exact anchors. It preserves the unchanged-path empty-date branch. Breakpoint hits and completed readbacks are independently counted; a swallowed debugger action error cannot pass as successful clock instrumentation. Unique runspace receipt variables and breakpoints are removed in `finally`. The primary action error remains visible when cleanup or readback also fails. An expected early action refusal is not replaced by an initialization-did-not-fire message.

Current, delayed, proposed, accepted-base worktree, local staged and invalid-mode child calls share the private dispatcher. Their actual checker files, B/H context, arguments, output, native exit and existing negative consumers remain. The accepted-worktree case now uses a private `-Command` wrapper around the actual `.ps1`; it is no longer literal `-File` launch proof. The in-process capacity call receives only a scoped local-date pin from its passed expected date. There is no production clock parameter, environment hook, source rewrite or host-clock change.

Persistent bounded controls cover fixed dates, changed/unchanged local paths, missing/duplicate/inactive anchors, primary-error preservation, cleanup and ordinary uninstrumented probe behavior. Existing installed-source/mode/identity checks and policy mutants remain intact.

## Focused commands and evidence

All Windows launches used verified PowerShell7.6.5:

```powershell
$env:PATH = 'C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A07-design-20261002/runtime/node-v24.18.1-win-x64;' + $env:PATH
$strPowerShell = 'C:/Users/flesniak/.cache/codex-runtimes/codex-primary-runtime/dependencies/native/powershell/pwsh.exe'
$strWriter = 'C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A06-TF-peer-20261005/writer'
$strRepository = 'C:/Users/flesniak/AppData/Local/Temp/TerraformStyleGuide-A02-peer-docs-20261003'
& $strPowerShell -NoLogo -NoProfile -NonInteractive -File "$strWriter/TF68-R1-focus.ps1" -RepositoryRootPath $strRepository -AnalyzeOnly
& $strPowerShell -NoLogo -NoProfile -NonInteractive -File "$strWriter/TF68-R1-controls.ps1" -RepositoryRootPath $strRepository
& $strPowerShell -NoLogo -NoProfile -NonInteractive -File "$strWriter/TF68-R1-boundary.ps1" -RepositoryRootPath $strRepository -Case Original
& $strPowerShell -NoLogo -NoProfile -NonInteractive -File "$strWriter/TF68-R1-boundary.ps1" -RepositoryRootPath $strRepository -Case WorktreeBypass
& $strPowerShell -NoLogo -NoProfile -NonInteractive -File "$strWriter/TF68-R1-actual-clock.ps1" -RepositoryRootPath $strRepository
& $strPowerShell -NoLogo -NoProfile -NonInteractive -File "$strWriter/TF68-R1-focus.ps1" -RepositoryRootPath $strRepository
& $strPowerShell -NoLogo -NoProfile -NonInteractive -File "$strWriter/TF68-R1-capacity-check.ps1" -RepositoryRootPath $strRepository
& $strPowerShell -NoLogo -NoProfile -NonInteractive -File "$strWriter/TF68-R1-capacity-check.ps1" -RepositoryRootPath 'C:\Users\flesniak\AppData\Local\Temp\TerraformStyleGuide-A02-peer-docs-20261003'
& $strPowerShell -NoLogo -NoProfile -NonInteractive -File "$strWriter/TF68-R1-capacity-native.ps1" -RepositoryRootPath $strRepository
```

- Final frozen SelfTest: parser errors0; PSScriptAnalyzer1.24.0 warnings/errors0, exit0.
- Persistent control block: passed. Independent actual-helper mutations for omitted initialization, ineffective local scope and swallowed readback failure were all rejected. Cleanup passed, including a forced breakpoint-removal error that retained the substantive checker error first.
- Original-byte boundary: exit0 after observing the required actual child exit1 and `Now=True Later=False Accept=True` failure. The immutable original SelfTest's only in-memory change was the private fixture anchor, set to Oct5. Actual current validator rejected `docs/finalization-fixture.md` because Last Updated must be Oct6. See `TF68-R1-original-boundary.log`.
- Actual uninstrumented production clock after same-process helper/mutant cleanup: exit0. Ordinary content contract passed. Captured `2026-10-06T00:36:37.4931172Z`, between before `00:36:37.3366366Z` and after `00:37:03.8864601Z`; maximum metadata date `2026-10-06`; no remaining clock breakpoints or receipts. See `TF68-R1-actual-clock-final.log`; the earlier ordinary-clock proof is preserved separately.
- Accepted-worktree bypass control: exit0 after requiring the actual direct-checker refusal. Replacing only that private dispatcher with the original real `-File` call rejected Oct5 fixture metadata with the actual Oct6 Last Updated diagnostic. See `TF68-R1-worktree-bypass.log`.
- Final Windows author component: the complete actual author fixture returned successfully with the explicit Oct5 fixture anchor, including current/delayed/proposed/Unicode/versioned/local staged cases, installed-source guards and existing mutants. The combined scratch driver then failed in its capacity tail because Parser-created AST filenames retained mixed slashes and did not match the Windows debugger. Session13807 is terminal exit1. Its log explicitly records the author success before that diagnostic. This is not a combined native-exit-zero claim.
- Windows capacity: the exact extracted capacity driver failed closed with the mixed path (exit1), then passed with only the repository argument changed to native Windows spelling (session69171, exit0). The native-path wrapper also checked zero remaining breakpoints/receipts and passed (session62887, exit0). Root explicitly accepted this component-attributed coverage; no long author rerun was performed solely for scratch path spelling.
- Actual production entry path: `TF68-R1-entry-path.py` directly invoked unchanged production `-File` with the forward-slash argument. Normal output exited1 for the intended missing-B/H refusal. Serialized runtime `ScriptName` and `PSCommandPath` both contained the canonical native filename. The XML diagnostic mode returned0 while serializing that refusal and is used only to inspect entry identity, never as passing policy proof. Exact commands, native exits and raw streams are preserved in `TF68-R1-entry-path.json` and the entry stdout/stderr files. Thus the path mismatch is specific to the scratch AST loader, not real script entry.
- Linux focus: root reported terminal exit0, source_equal and host_source_equal at 00:38:00Z. All actual prior-day author-finalization, capacity and cleanup assertions passed. `R1-linux-focused/output/result.json` SHA256 `82ea3e49ad3bd596b5bcbfe97b2d2ff2e7a9cd5e0258a88bc33e4732347d91da`; log SHA256 `d29956415ac91d99986558f4b53848ed0f7726d6c1fe568ce1d21f5e279cda48`; private candidate tree `29e7f3f30cb9a1df0686be6a3e77234fe0186f57`. This is focused candidate evidence, not accepted-main proof.

The frozen cross-platform focus driver SHA256 is `e4de65682fa609ba9a5a79b6f441376de21962eea0955c1f3023ce4ff5bc00a5`. It loads source-file-bound actual functions and initialization but excludes aggregate entry work. It replaces exactly one private fixture clock expression in memory with a printed prior-day literal. All production checker bytes and actual fixture consumers remain unchanged. Linux completed its author/capacity/cleanup sequence; Windows coverage is attributed above. The source must have a real Git tracked inventory and the already-qualified Git, PowerShell7, Node24.18.1, Python and locked Markdown dependencies. No new dependency was installed. Complete commands, native exits, source/driver hashes, outcomes and limits are in the consolidated `focused_results` object.

An earlier Windows attempt loaded pre-persistent-control SelfTest SHA256 `a276645a3aaac9fbf99706eb4fc905af710138422d57df37549242a457bf8942` with an unqualified outer debugger anchor. Session5684 is terminal exit1: after the fixture returned, the old driver rejected its missing anchor hit with `Focused prior-day anchor did not fire once.` Its log is retained as `TF68-R1-focus-windows.log`; it is excluded from passing final-byte or deterministic-midnight proof and is not a product finding. The final run uses `TF68-R1-focus-final-windows.log`. Scratch mechanism probes also record the necessary script-versus-local scope distinction and show that debugger action throws alone are insufficient; these were bounded fixture implementation refinements within C97.

## Remaining gates and obligations

Root owns aggregate, current audit, staging/commit, new-head CI/reviews and ordinary acceptance. No TF accepted-main result is claimed. WindowsPowerShell5.1 remains Restricted locally; no bypass was used. The common SelfTest finding adds a reverse PS A21 repair obligation after TF acceptance; the original 25-row A06 comparison remains historical evidence for its original scope. The original round1 deadline `2026-10-13T23:47:31Z` and A06/A03/A21 transfer counters1/3/5 of12 remain unchanged. New-harness, A03/A06/A21, R5/recovery and human gates remain with the root ledger.
