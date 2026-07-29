# Feedback on the PSStyleGuide P1/P2 GitHub issue slate

## Overall assessment

The slate is fundamentally sound, and P1 followed by P2 is the correct execution order.

The current `PSStyleGuide` `main` branch at commit [`4346310`](https://github.com/franklesniak/PSStyleGuide/commit/4346310e7deebffb4159c75e30d9546263dfd649) confirms the important premises:

- `.gitattributes` already contains exactly `* text=auto eol=lf`, so P1 is correct to preserve it rather than recreate or broaden it.
- The generator still declares PowerShell 5.1 support, writes four artifacts through edition-sensitive `Set-Content -Encoding UTF8`, and builds the PowerShell frontmatter with a here-string.
- The build workflow is still path-filtered, grants workflow-level `contents: write`, and uses movable major-version action tags.
- The two stored blank-line examples in `STYLE_GUIDE.md` are byte-equivalent at the supposedly different line, so P2 addresses a real documentation defect.

P1 also gets the most important generator-unification boundary right: both P1 and T1 prescribe final-payload CR canonicalization, resolved destination paths, `UTF8Encoding($false)`, and `WriteAllText`. P2 correctly keeps the blank-line explanation generic to every adopter and commits both sources with all four regenerated artifacts, so its expected post-merge result is no drift and a skipped synchronization writer.

I would make the following corrections before filing the issues.

## 1. Reconcile the claimed P1/T1 helper alignment before filing either issue

This is the largest blocking inconsistency. P1 and T1 each say that the helper's parameter interface and validation behavior are aligned and that the four manifest names are the intentional repository-specific difference. The actual prescriptions are not aligned:

| Contract surface | P1 | T1 |
| --- | --- | --- |
| Mandatory public parameters | `CheckoutRoot`, `TrustedTemporaryRoot`, `DownloadDirectory`, `CandidateDirectory`, and `ExpectedDigest` | Download directory, initially nonexistent candidate directory, and expected digest |
| Diagnostic parameters | Optional `ArtifactId`, `RunId`, and `RunAttempt` | No corresponding public parameters |
| Checkout trust boundary | Supplied by the caller | Derived and verified from the helper's fixed tracked location |
| Temporary-root boundary | Supplied explicitly and enforced by the helper | Protected runner-temporary parent is a caller responsibility; helper validates the supplied paths |
| Fixture-suite ownership | Separate tracked `Test-Expand-StyleGuideCandidateArtifact.ps1` | No separate harness in the affected-file set |
| Windows pull-request execution | Two LF cells | All four edition × EOL cells |

Both descriptions cannot be true simultaneously.

The preferred resolution, given the revised T1 slate, is to revise P1 to the same fixed-location checkout-root model and public interface, then retain only the four manifest filenames and repository-specific artifact names as differences. Deriving the checkout root from the tracked helper also avoids allowing a caller-selected value to define the boundary that the helper is supposed to protect.

If the explicit `TrustedTemporaryRoot` envelope, optional diagnostic parameters, and separate tracked harness are deliberate improvements that should remain, coordinate a matching change to T1 before filing either issue. In that case, document those as shared contract elements. Do not leave each issue claiming exact alignment while prescribing incompatible APIs and file sets.

## 2. Use one canonical writer ref identity from preflight through push

P1 correctly uses PowerShell's environment drive in:

```powershell
git ls-remote --exit-code --refs origin $env:GITHUB_REF
```

However, its later lease and refspec use `$env:TARGET_REF`. That means the writer validates one value and pushes another value.

Adopt the revised T1 contract:

1. Supply `TARGET_REF: ${{ github.ref }}` and `EXPECTED_SHA: ${{ github.sha }}` through workflow `env`.
2. In the writer's one complete PowerShell mutation block, copy those values to local variables.
3. Require the target to be a complete `refs/heads/` ref and require it to equal the immutable `$env:GITHUB_REF`.
4. Resolve `HEAD^{commit}` to one complete repository-native object ID and require it to equal both the expected SHA and `$env:GITHUB_SHA`.
5. Query the remote using that same validated local target ref and require exactly one `<object-id><TAB><ref>` record.
6. Reuse the same local target ref and expected SHA unchanged in the exact lease and `HEAD:<full-ref>` refspec.

This eliminates a security-relevant split source of truth and keeps the controlled temporary-branch drill possible.

## 3. Bind every helper call to an explicit edition-specific process

P1 says that the helper harness runs under the assigned edition, but its topology still permits an edition-neutral `pwsh` step to construct fixtures and invoke the helper in every cell. A generator assertion in another step would not prove which interpreter executed the helper.

Use the same structure as revised T1:

- An Ubuntu pull-request step uses `shell: pwsh`, asserts Core 7, and invokes the exact harness/helper in that same process.
- Every Windows job has two mutually exclusive helper steps:
  - Desktop: `if: ${{ matrix.edition == 'desktop' }}` with `shell: powershell`, asserting Desktop 5.1;
  - Core: `if: ${{ matrix.edition == 'core' }}` with `shell: pwsh`, asserting Core 7.
- An edition-neutral fixture-preparation step may create or inspect inputs, but it must not dot-source, call, or launch the production helper.
- On push, the production helper invocation immediately follows the permanent suite in the same edition-specific step.

For exact P1/T1 parity and the clearest per-cell evidence, run the suite in all four Windows pull-request cells, not only the two LF cells. If the drafter deliberately retains only one cell per edition because the helper fixtures are EOL-independent, the issue must state that as an intentional CI optimization and must not imply that all four pull-request cells exercised the helper. All dependent P2 prerequisite, evidence, and acceptance wording must match the chosen topology.

## 4. Specify exhaustive entry enumeration and final-leaf detection

P1 requires directories to contain “exactly” a certain entry set, but it does not prescribe an enumeration that includes hidden/system entries. It also uses ordinary existence wording for the candidate leaf, which can miss a dangling final link.

Add an implementation contract equivalent to revised T1:

- Convert PowerShell paths to absolute filesystem-provider paths before passing them to .NET.
- Use separator-aware ordinal comparison: ordinal-ignore-case on Windows and ordinal on non-Windows.
- Materialize `Directory.EnumerateFileSystemEntries` for every exact-count or exact-set assertion.
- If `Get-ChildItem` is used for supporting diagnostics, require `-LiteralPath -Force`; do not use it as the normative exact-count primitive.
- Enumerate the existing candidate parent and reject any matching leaf entry, including a file, directory, symlink, reparse point, or dangling link.
- Repeat the parent enumeration immediately before creating the candidate leaf.
- Enumerate the extracted candidate exhaustively and require exactly four ordinary, non-reparse-point files.

Extend the permanent fixtures to cover a hidden extra download entry, an existing candidate file/directory, a reparse/symlink candidate leaf, and a dangling candidate link where the runner permits construction. A reparse component elsewhere in the path does not substitute for testing the final leaf.

## 5. Replace the ambiguous fixture prose with a normative outcome table

P1 lists a normal valid archive and an archive with symlink-like external attributes that must still extract safely, but later says “each invalid fixture” and singular “the valid fixture.” Its path-envelope list also contains cases that should succeed, such as a checkout sibling-prefix classification and a valid filesystem-provider-qualified absolute path.

Give every fixture a stable case identifier and a table containing:

- expected result: success or rejection;
- expected failure phase for every rejection;
- candidate-leaf postcondition;
- required extracted path/type/byte checks for successes;
- required diagnostic context.

At minimum, classify both archive successes explicitly:

1. an exact archive with the correct digest; and
2. an exact archive with symlink-like external attributes that are ignored while ordinary files are created.

Also classify the sibling-prefix, case-variant, filesystem-provider path, root-overlap, hidden-entry, and final-link fixtures explicitly. An exception by itself is not a complete negative-test oracle; the harness should verify that failure occurred in the required phase and that no forbidden path was created or changed.

## 6. Make push-consumer language match the conditional job graph

P1 repeatedly says “every push consumer ... on every run,” then its post-merge evidence requires `has_changes=false` and the synchronization writer to skip. P2's post-merge section correctly explains the no-drift branch, but its prerequisite and acceptance sections retain the broader contradictory wording.

Use these exact execution semantics throughout P1 and P2:

- **Four Windows push cells:** always download the candidate, run the permanent suite, and invoke the production helper.
- **Synchronization writer:** runs the suite and helper only when approval reports `has_changes=true`.
- **No-drift push:** the four Windows cells report `success`; the writer reports `skipped`, and none of its steps ran.
- **Evidence allocation:** P1's controlled `has_changes=true` drill plus static inspection proves the writer path; ordinary P1/P2 no-drift runs prove the four read-only cells and the expected writer skip.

P2's current numbered post-merge checklist and explanatory paragraph are a good model. Carry that precision into its prerequisite and acceptance text and into all corresponding P1 sections.

## 7. Preserve a deliberate generator-unification boundary

Do not attempt line-for-line identity between the complete generator scripts. Their `New-StyleGuideFullVersion` implementations legitimately differ because the two guides have different rationale structures, anchors, standalone sections, headings, and instruction artifacts.

The shared generator surface should remain intentionally identical wherever the semantics are identical:

- `#Requires -Version 5.1`;
- complete-payload normalization immediately before serialization;
- destination resolution;
- BOM-less `UTF8Encoding($false)`;
- `WriteAllText` without an implicit trailing newline;
- native-command/error handling expectations;
- script-version calculation;
- common function ordering and naming where the output role is the same.

The following differences are legitimate and should be documented as intentional:

- PSStyleGuide already has the repository-wide `.gitattributes` rule; TerraformStyleGuide must add it.
- P1 must replace its current frontmatter here-string; T1 must preserve its already-correct LF-joined array.
- `powershell.instructions.md` and `terraform.instructions.md` require different function names, frontmatter, and manifest entries.
- Chat titles, executive-summary handling, rationale anchors, and full-guide merge rules are domain-specific.

Keep both repositories self-contained. Unification should mean reviewed parity of the common algorithm and tests, not a runtime dependency between repositories or cross-repository byte equality.

## 8. Make the P2 validation helper consistent with the guide it validates

P2's validation block declares `Get-OrdinalOccurrenceCount` without comment-based help. The current guide says all functions must include full comment-based help inside the function immediately above `param`.

Either:

- give the validation function compliant comment-based help; or
- avoid declaring a named function in the copy-paste validation block and use a narrowly scoped alternative that retains ordinal, non-overlapping occurrence-count behavior.

This is lower priority than the workflow and helper-contract corrections, but removing the self-inconsistency will make the handoff more credible.

## What should remain unchanged

- Keep the embedded H1 titles; they are clear issue titles, not duplicate prose.
- Keep the P1 → P2 dependency and record it with the actual GitHub blocked-by relationship.
- Do not recreate or edit `.gitattributes` in P1 or P2.
- Keep P2's `text` fence, four U+00B7 middle-dot visualization, pre-block warning, and prohibition on copying the dots into PowerShell.
- Keep the operational example in `STYLE_GUIDE.md` and the generic durability explanation in the existing rationale section.
- Keep P2 generic to unrelated adopters; do not import Terraform provider-recovery guidance from T2.
- Keep both authoritative source files and all four regenerated artifacts in the P2 implementation commit so the expected post-merge writer result remains `skipped`.

With the blocking helper-contract mismatch, writer ref identity, edition binding, exhaustive enumeration, fixture oracle, and conditional-job wording corrected, the P1/P2 slate will be technically coherent with T1/T2 while preserving the PSStyleGuide-specific changes that are actually necessary.
