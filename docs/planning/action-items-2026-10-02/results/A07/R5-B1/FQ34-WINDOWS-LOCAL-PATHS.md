<!-- markdownlint-disable MD013 -->
# FQ34 — Windows UNC spellings cross the ordinary-path boundary

Proposal only. Root owns selection and implementation. Reviewed product: the PSStyleGuide product worktree, root-reported clean HEAD `c1ef946fe4585836f27a0a4480bd986899d7c316`. No product code or Git state changed.

## 1. Validate the current flow

Comment 4228859855 is valid. `Initialize-CiToolchain.ps1:92–96`, `Test-CheckoutCredentials.ps1:78–82`, and `Invoke-MarkdownLint.ps1:80–84` require a fully qualified input but reject only the literal leading two backslashes. They normalize next, check aliases, resolve the FileSystem provider, and finally use Get-Item. The initializer applies this helper to RUNNER_TEMP and both runner channels at 1113/1123–1124 and again before publication. Credentials applies it to RUNNER_TEMP/GIT_CONFIG_GLOBAL at 284/315. Lint applies it to the runner, ready record, Node, and npm files from 240 onward.

The bounded lexical probe in this folder completed with native exit 0 (tool receipt `1be192`, 0.719 seconds), PowerShell 7.6.5 and .NET 10.0.11 on Windows. It evaluated 24 authored strings with Path APIs only. `//fq34.invalid/share/item`, `/\fq34.invalid/share/item`, and `\/fq34.invalid/share/item` all pass the current raw predicate and normalize to `\\fq34.invalid\share\item`. Slash device forms also pass the raw predicate and become native device paths. Some device forms would then fail the existing colon/alias check; do not describe every device spelling as a demonstrated full-helper bypass. Provider-qualified, drive-relative, root-relative, and ordinary relative inputs fail the initial fully-qualified predicate. Drive-rooted forward/mixed slash local inputs normalize normally. No target existence, provider, network, or product operation was performed. This proves the lexical admission defect, not a successful remote write.

The prior FQ7 decision in `results/A07/R5-B1/integration-path-rule-review/REPORT.md` added provider identity/equality checks without replacing the native local-path constraints. A UNC FileSystem identity can satisfy equality, so FQ7 does not close this earlier boundary. FQ30 exact token anchors concern declarations; FQ33 owns the remaining version anchors. Neither is a duplicate of this finding.

Microsoft describes Windows separator normalization, UNC/device syntax, and drive-relative semantics in [file path formats](https://learn.microsoft.com/en-us/dotnet/standard/io/file-path-formats). The [runtime PathHelper implementation](https://github.com/dotnet/runtime/blob/v10.0.0/src/libraries/System.Private.CoreLib/src/System/IO/PathHelper.Windows.cs#L23-L36) also attempts long-name expansion when the normalized text contains `~`. Therefore a normalized-only network rejection can be too late: a short-name network input may cause lookup during GetFullPath. The probe deliberately excluded tilde. [GetFullPathName](https://learn.microsoft.com/en-us/windows/win32/api/fileapi/nf-fileapi-getfullpathnamew) alone does not verify target existence; this is why the finite non-tilde probe was safe.

## 2. Stakeholders and limits

Windows contributors and CI operators need local slash-form paths, spaces, and Unicode to remain usable. Linux contributors must retain POSIX path handling. Maintainers and reviewers need the same guard in all three copies. Security and privacy owners need refusal before potential network access. QA and incident reviewers need a causal witness that cannot itself contact a server. Recovery operators need the existing ownership/provider/ACL checks intact. Documentation readers need no new setup steps. Terraform and generated-artifact consumers have no changed interface here. Accessibility/localization needs are limited to preserving valid path names and clear existing diagnostics.

Mapped drive letters can name remote storage. Neither a prefix rule nor the existing provider equality proves physical locality. Detecting mapped drives, SUBST volumes, filesystem mounts, or every NT namespace would require a separate storage contract and platform evidence. This proposal closes the demonstrated UNC representation gap; it does not claim that broader guarantee.

## 3. Relevant options

- A: Keep the current guard, or defer until a remote failure occurs.
- B: Remove Windows support or forbid all slash characters.
- C: Extend only the raw Windows two-separator check by mapping `/` to `\` before checking its prefix.
- D: Add only a normalized UNC/device prefix rejection.
- E: Keep the current guard, add C before GetFullPath, then require a normalized Windows drive-root prefix before the alias/provider checks.
- F: Put E in a shared configurable resolver imported by all three helpers.
- G: Add DriveInfo/native mapped-drive discovery to E, or permit explicitly approved network shares.

The network exception changes the accepted local-path contract and cannot repair it. Deferral collapses into A. A normalized-only drive-root rule has the same pre-normalization short-name limitation as D. Native Path APIs remain the normalization mechanism in C–F; no alternative path parser is needed.

## 4. Rubric before scoring

Scores range from 0 (fails the criterion) to 5 (fully meets it). Weighted total is sum(weight × score / 5). This is engineering judgment, not measured probability. Hard constraints: reject UNC representations before potentially remote normalization/provider/file operations; preserve valid local Windows and Linux inputs; retain provider equality, type, ancestor, and ownership controls; do not claim mapped-drive protection without evidence.

| Criterion | Weight | Meaning |
| --- | ---: | --- |
| Boundary correctness C | 29 | Cover raw and normalized supported path forms |
| Early refusal S | 33 | Prevent network work before path refusal |
| Legitimate compatibility U | 21 | Preserve supported local syntax and platform behavior |
| Review and causal testing V | 12 | Small observable guard with safe negative controls |
| Maintenance cost M | 5 | Avoid new modules and platform discovery |

## 5. Scores before selection

| Option | C | S | U | V | M | Total /100 | Constraint or uncertainty |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 0 | 0 | 5 | 1 | 5 | 28.4 | Known bypass remains |
| B | 3 | 5 | 0 | 4 | 4 | 64.0 | Breaks supported local inputs |
| C | 4 | 5 | 5 | 5 | 5 | 94.2 | Sound ordinary prefix repair; less explicit normalized invariant |
| D | 4 | 2 | 5 | 4 | 5 | 72.0 | Too late for tilde expansion |
| E | 5 | 5 | 5 | 5 | 4 | 99.0 | Selected; lexical locality only |
| F | 5 | 5 | 4 | 3 | 2 | 88.0 | New bootstrap/import dependency |
| G | 3 | 3 | 2 | 2 | 1 | 51.4 | New scope and storage assumptions |

## 6. Selected proposal E

Apply the same change to each Assert-OrdinaryPath copy. Keep the existing raw checks. Add a Windows-only raw check before GetFullPath. Replace forward slashes in a temporary string. Reject the input if that string starts with two backslashes. Use the existing absolute-local-path diagnostic. Do not resolve that temporary string through a provider.

After GetFullPath, require the Windows normalized path to start with one ASCII drive letter, a colon, and a backslash. Use `\A[A-Za-z]:\\` as the prefix pattern. Reject all other Windows roots. Keep the existing alias checks after this condition. Keep all later checks unchanged. Apply no new root rule on Linux. Do not add mapped-drive probes.

Exact proposed predicate additions:

```powershell
# Add to the existing raw refusal condition:
-or ($IsWindows -and $Path.Replace('/', '\').StartsWith('\\'))

# Add immediately after GetFullPath:
if ($IsWindows -and $strFullPath -cnotmatch '\A[A-Za-z]:\\') {
    throw 'toolchain: an absolute local single-line path is required'
}
```

These short instructions use consistent names and explicit conditions. No formal ASD dictionary certification is claimed.

## 7. Implementation and verification plan — not executed

Reuse the exact-function extraction pattern at Test-CiHelpers.test.mjs:2877 and the bounded Windows child pattern at 3634–3653. Add one Windows registration covering all three helpers. Use real ordinary files/directories under the private fixture root for backslash, forward-slash, mixed-slash, spaces, and Unicode positives. Retain FQ7 provider-mismatch controls and F10 link/channel controls.

For negative UNC/device cases, do not run the full helper on network-looking inputs. Extract the real lexical prefix through the point immediately before provider resolution, and append a fixed boundary-reached marker. For tilde-containing network inputs, replace the single GetFullPath call in this disposable copy with a fixed throw sentinel. Require the local-path error before that sentinel. For the old/raw-guard mutant require the sentinel, which proves the rejection occurs before normalization without contacting a target. For other slash forms, use the real non-tilde Path normalization and stop before provider resolution. Remove only the new raw condition and only the normalized condition in separate disposable mutants; use a deterministic normalized-output replacement for the latter if no native input isolates it. Label that as a boundary test, not a discovered native bypass.

Cover each two-separator permutation, native/slash/mixed `?` and `.` device prefixes, device UNC, provider-qualified paths, drive-relative/root-relative paths, CR/LF, and existing ADS refusal. Cap the finite table at 40 inputs per helper, each ≤256 characters; one child per helper, timeout 15 seconds and maxBuffer 256 KiB; registration timeout 60 seconds. Linux regression uses real private absolute paths, including a double-leading-slash spelling, and keeps current provider equality behavior. No UNC existence probes or network permissions are allowed.

Root should run the selected FQ34 registration under the maintained Windows transport, then the affected existing path/credential/lint tests. Use the maintained Linux transport for the Linux regression. Exact source catalog and acceptance must be refreshed after all round2 edits. This proposal and the lexical witness are not product-test acceptance.

## Root selection and current status

Root verified the frozen analysis assets and all score arithmetic. The complete options, unique rubric, scores and selected instructions were displayed to the owner before implementation. Root selects option E under the standing clear-winner instruction. The earlier proposal wording records its original analysis stage. Product implementation and required tests follow; no test result in the proposal is promoted to executed evidence. Original PR239 round2/80, deadline2026-10-16T22:53:27.970214Z and A07transfer9/12 remain unchanged.

## Local implementation at source freeze

All three actual Assert-OrdinaryPath copies now have both selected Windows guards. The maintained tests use three separate Windows registrations and three separate Linux registrations, one per actual helper. This refines the proposed single combined registration without changing the tested boundary. Each Windows child returns41 rows across six stages, including repeated inputs for causal mutants; there are at most40 distinct input strings. The explicit caps are41 result rows,40 unique inputs,256 characters per input,15 seconds and256 KiB per child, and30 seconds per registration. No authored case was removed when root tightened the frozen preparer snippet caps. Each Linux child checks four real ordinary/double-slash file/directory cases. All newly added native cases remain unexecuted. No network-looking input reaches a provider or filesystem lookup.

The [frozen source record](current-main-validation/pr239-round2-source-freeze.json) identifies the complete local repair input. Root syntax and whitespace checks passeda48f78. Independent source quality, affected native validation, full Windows aggregate, all11 hooks and new published-input review/CI remain gates. No product commit, review reply or new review request is claimed here.

## Unicode result-transport fixture correction

Windows aggregate a1 failed only three FQ34 Unicode echo checks; the failed run remains unaccepted.
The fixture JSON output corrupted the echoed input before helper-result assertions; the exact output code page was not recorded.
Add `-EscapeHandling EscapeNonAscii` to the one FQ34 serializer; retain real Unicode inputs and every assertion, cap, mutant and cleanup rule.
Run fresh whole-driver and six-form syntax, Linux path3, full Windows786 and all11 hooks; readmit unchanged108 Linux cases only with explicit prior-source attribution.
Evidence: [failed aggregate](current-main-validation/pr239-round2-windows-aggregate-failed-a1.json); serializer behavior is documented by [PowerShell](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-json?view=powershell-7.6#-escapehandling).

## Current verification

The three actual helpers passed all three fresh Windows boundary registrations and all three fresh Linux path registrations. The full Windows aggregate passed352 tests with434 platform skips and no failures. [Current candidate and validation](current-main-validation/pr239-round2-validation.md) supersedes the pending-test statements above. It retains the failed first run and identifies the fresh serializer, syntax and runtime evidence without relaxing any assertion or cleanup rule.
