# Add a fail-closed cross-platform style-guide candidate validator

## Summary

Add one shared PowerShell archive validator/extractor, one caller-owned
temporary-context lifecycle, one versioned semantic case catalog, and one
permanent adversarial harness. Require equivalent behavior under Windows
PowerShell 5.1 and PowerShell 7 on Windows and Ubuntu.

Treat public values, filesystem claims, ZIP entries, resource declarations,
and cleanup claims as untrusted. Hash and parse one continuously held archive
stream, validate the complete manifest and resource ceilings before candidate
creation, extract only fresh ordinary files, and retain uncertain state rather
than recursively deleting it.

P1A is workflow-inert. P1B consumes these landed interfaces.

## Consumed landed contract

P1 must already be merged and its real GitHub dependency edge to this issue
verified. Before coding, record:

| Identity | Required P1 evidence |
| --- | --- |
| Issue/PR | Permanent URLs |
| Review | Reviewed head/base commits and merge method |
| Landed state | Commit(s), tree, and exact ten-path P1 scope |
| Generator | Version, SHA-256, fixed map, private writer/result schema |
| Script versions | Landed timeless grammar, expected-version binding, progression cases |
| Workflow policy | Validator/parser/contract/case schema versions and hashes |
| Path verifier | Script version/hash and cross-host fixture results |
| Supply/risk | P1 tuple, action/default evidence, current advisory decision |
| Governance | Approved settings-task URL and desired/rollback digests |
| Reciprocal | Completed 16-row P1↔T1 matrix |

Compare landed state with every assumption below. A missing edge, expired or
contradicted advisory decision, identity mismatch, material contract drift, or
unresolved reciprocal blocker stops implementation and requires issue review.
Rerun affected P1 validation rather than treating a reviewed PR head as the
landed implementation.

## Affected files

Exactly these four paths may change:

- `.github/workflows/Expand-StyleGuideCandidateArtifact.ps1` — add;
- `.github/workflows/Manage-StyleGuideCandidateInvocationContext.ps1` — add;
- `.github/workflows/Test-Expand-StyleGuideCandidateArtifact.ps1` — add; and
- `.github/workflows/style-guide-candidate-cases.json` — add.

All three scripts declare `#Requires -Version 5.1`, remain LF/BOM-less, and
receive independently governed first-publication `.NOTES` versions:

`1.0.<implementation UTC YYYYMMDD>.0`

The baseline paths are unversioned, not earlier releases. Consume P1's landed
timeless marker grammar, separately trusted expected-version binding,
`invalid-version|unexpected-version|version-progression` taxonomy, and
merge-base/change-class/final-material-edit progression rule. If a script
changes again on the same UTC date before finalization, increment only that
script's Revision by exactly one. Record all three versions, fixed paths, Git
blobs, and SHA-256 values.

Do not change workflows, generator, guides/artifacts, package/lock, hook/lint,
Dependabot, or P1 policy files.

## Public raw-value boundary

Every public parameter is declared as raw `[object]` under
`[CmdletBinding(PositionalBinding = $false)]`; no public command accepts
pipeline or remaining-argument binding. Before any conversion, provider call,
path access, diagnostic interpolation, or collection unrolling, require
`$Value.GetType() -eq [System.String]`. Reject null, arrays (including
single-element arrays), collections, hashtables, PSCustomObjects, PathInfo,
FileInfo/DirectoryInfo, script blocks, wrapped/deserialized objects, and every
other runtime type as `parameter`.

Required strings reject empty/whitespace without trimming or rewriting.
Optional labels use `$PSBoundParameters`: omission becomes literal diagnostic
`unavailable`; an explicitly bound null, empty, whitespace, non-string, control
character, or over-limit value fails before filesystem calls. Labels never
authorize/select an artifact or form a path.

`Expand-StyleGuideCandidateArtifact.ps1` accepts only these named values:

- required `CheckoutRoot`, `TrustedTemporaryRoot`, `DownloadDirectory`,
  `CandidateDirectory`, and `ExpectedDigest`; and
- optional `ArtifactId`, `RunId`, and `RunAttempt`.

`ExpectedDigest` must be an exact string matching `^[0-9A-Fa-f]{64}$`.

The script defines functions before its entry point. Ordinary dot-sourcing
defines functions and returns without expansion. There is no test switch,
environment backdoor, caller-selected policy, or alternate production entry.

## Trusted harness script interface

`Test-Expand-StyleGuideCandidateArtifact.ps1` accepts mandatory raw
`HelperPath` and `ContextManagerPath` values plus the separately trusted exact
expected versions stored in fixed harness metadata. It accepts no alternate
repository root. Derive the canonical repository root from the harness's fixed
`$PSScriptRoot` location, never current directory or ambient Git discovery.

Before dot-sourcing either fixed literal repository-relative path, and again
immediately before invoking its functions, prove:

- exactly one ordinary `100644` HEAD tree blob at the fixed path;
- exactly one equal stage-0 index blob and no conflict stages;
- the no-filter working-file object ID equals HEAD and index;
- the object ID has the repository's complete active-object-format grammar;
- the script carries its separately trusted expected version under P1's
  profile; and
- ordinary component/containment/link identity remains unchanged.

Use raw NUL records and literal pathspecs. Do not decode or print hostile Git
path bytes. An untracked path, HEAD/index absence, staged/unstaged replacement,
conflict stage, wrong mode/tree type, filter-transformed identity, malformed
record, abbreviated/wrong-format ID, native status failure, cross-repository
path, or hostile literal-name substitution fails before dot-sourcing.

## Closed context and journal schemas

`Manage-StyleGuideCandidateInvocationContext.ps1` exports exactly:

- `New-StyleGuideCandidateInvocationContext`; and
- `Remove-StyleGuideCandidateInvocationContext`.

Both use `[CmdletBinding(PositionalBinding = $false)]`, accept no pipeline or
remaining arguments, and write no incidental success-stream values.

`New-StyleGuideCandidateInvocationContext` accepts required raw
`-TrustedTemporaryRoot` and optional raw `-DiagnosticLabel`. It applies the
public raw-value boundary, creates exactly one context, and returns that
context. Before the first owned creation, failure throws one bounded stable
diagnostic and returns no context. After any owned creation, it first completes
the journal, invokes the same production cleanup transition synchronously, and
then throws one bounded composite diagnostic containing the creation and
cleanup categories. It returns no context on failure; any retained uncertainty
is identified only by the bounded invocation-root/record sequence evidence in
that diagnostic.

`Remove-StyleGuideCandidateInvocationContext` accepts only required raw
`-Context`. `Expand-StyleGuideCandidateArtifact.ps1`'s
`Remove-StyleGuideCandidateInvocationState` has the same sole public parameter
and handles helper-owned candidate entries before caller-owned context
cleanup. Neither accepts force, recurse, retry, alternate root, path list,
error suppression, or caller-selected policy.

The context has first `PSTypeName`
`PSStyleGuide.CandidateInvocationContext.v1` and exactly these ordered
properties and runtime types:

| Property | Exact type/rule |
| --- | --- |
| `SchemaVersion` | `System.UInt32`, exactly `1` |
| `ContextScriptVersion` | `System.Version`, exact script version |
| `InvocationId` | nonempty `System.Guid` |
| `DiagnosticLabel` | already validated `System.String` |
| `TrustedParentPath` | normalized nonempty `System.String` |
| `InvocationRootPath` | normalized nonempty `System.String` |
| `DownloadDirectoryPath` | normalized nonempty `System.String` |
| `CandidatePath` | normalized nonempty `System.String` naming the initially absent leaf |
| `LifecycleState` | exact `Active`, `CleanupFailed`, or `Disposed` |
| `NextSequence` | `System.UInt32` |
| `OwnershipJournal` | exact one-dimensional `System.Object[]`, including empty without scalar unrolling |

Each journal item has first `PSTypeName`
`PSStyleGuide.CandidateOwnershipRecord.v1` and exactly:

| Property | Exact type/rule |
| --- | --- |
| `SchemaVersion` | `System.UInt32`, exactly `1` |
| `Sequence` | contiguous `System.UInt32` from zero |
| `Kind` | invocation root, download directory/file, candidate directory/file |
| `Path`, `ParentPath`, `LeafName` | exact normalized strings with parent/leaf recomposition |
| `ExpectedEntryType` | exact `File` or `Directory` |
| `CreationPhase` | closed phase enum |
| `EntryState` | `ExpectedAbsent`, `Created`, `Deleted`, or `RetainedUncertain` |
| `ContentLength` | `System.UInt64` or null only for a schema-authorized kind/state |
| `ContentSha256` | lowercase 64-hex string or null under the same rule |

Each removal returns exactly one
`PSStyleGuide.CandidateCleanupResult.v1` with ordered properties:
`SchemaVersion` (`UInt32`, `1`), `ContextScriptVersion`
(`System.Version`), `InvocationId` (`Guid`), `PreviousState`, `FinalState`,
`Success` (`Boolean`), `DiagnosticCode` (closed bounded string),
`FilesystemCallCount` (`UInt32`), and `RetainedRecordSequences`
(`UInt32[]`, including empty without scalar unrolling). A valid `Disposed`
repeat returns success with zero calls. `CleanupFailed` repeat and invalid
context return failure with zero calls. The caller owns aggregation of a
primary expansion failure with this cleanup result; cleanup never overwrites
or suppresses the primary failure.

One private validator checks exact first type name, ordered property names,
runtime types without conversion, enum casing, sequence/cardinality, state
transitions, containment, recomposition, and context/journal agreement before
every state transition or filesystem operation. Record validity never proves
live filesystem identity; re-prove that separately.

Creation accepts one raw explicit runner-controlled temporary parent. It
validates an existing ordinary non-reparse FileSystem directory, chooses a
child with `Path.GetRandomFileName()`, proves absence, creates without `-Force`,
and retries a documented finite count only after an exhaustive real collision
proof. Permission/type/attribute/resolution failures fail immediately. It
creates a separate download directory and selects—but does not create—the
candidate leaf.

## Cleanup authority and lifecycle

The archive helper defines exactly
`Remove-StyleGuideCandidateInvocationState`. Normal helper failures and every
cleanup fixture invoke this production function. Caller cleanup never
recursively enumerates ownership and never substitutes its own candidate
deletion.

Use this exact synchronous transition model:

| Current state | Operation/outcome | Next state | Filesystem/native calls |
| --- | --- | --- | ---: |
| `Active` | all exact owned entries proved and removed | `Disposed` success | bounded required calls |
| `Active` | invalid schema/relationship before deletion | `CleanupFailed` | zero deletion calls |
| `Active` | missing, unexpected, unreadable, substituted, reparse, delete, or verification uncertainty | `CleanupFailed` | stop at first uncertainty |
| `Disposed` | same valid context passed again | `Disposed` success | **zero** |
| `CleanupFailed` | same valid context passed again | `CleanupFailed` failure | **zero** |
| any | invalid/tampered context | unchanged failure | **zero** |

Do not add `CleanupInProgress`, retry failed cleanup, or infer disposal from a
missing path. The first `Active` cleanup performs a complete pre-deletion proof,
then removes only exact journaled files and empty directories nonrecursively,
deepest first. Transition to `Disposed` only after those owned deletions prove
the invocation root absent. After a terminal transition, do not inspect those
names again; a new object at a released name is outside the capability.

On uncertainty, preserve the primary failure and cleanup failure, mark affected
records `RetainedUncertain`, stop further deletion, and report only bounded
root/phase/entry/category evidence. Spies must prove repeated terminal calls
make zero provider, path, filesystem, native, sleep, or enumeration calls.

## Archive and extraction contract

### Paths and fixed order

For each already type-validated path, reject wildcard, relative, malformed,
ambiguous, or non-FileSystem syntax. Accept native rooted or
FileSystem-provider-qualified absolute strings. Obtain one deterministic
provider-internal path, normalize once, compare ordinal-ignore-case on Windows
and ordinal elsewhere, and use separator-aware equality/descendant tests.

Require checkout and trusted roots to be existing ordinary directories and
mutually non-overlapping. Download/candidate paths are strict descendants of
the trusted root and outside checkout. Lexically inspect every existing
component from volume/share root through all declared paths and created leaves;
reject links, reparse points, junctions, volume mounts, dangling entries, type
mismatch, or inspection failure without following the entry. Recheck before
archive open, candidate creation, and after extraction.

Use exactly this order:

1. raw type/value/label/digest grammar;
2. roots, components, and root separation;
3. working-path containment/components;
4. exact download content/archive type;
5. candidate-parent safety and leaf absence;
6. one retained archive stream open and SHA-256;
7. rewind the same stream, open ZIP, enforce limits, validate manifest;
8. repeat component/containment/parent/leaf checks;
9. create candidate exactly once and extract; and
10. validate output bytes/filesystem state exhaustively.

No earlier phase creates the candidate leaf. Stable phases are `parameter`,
`root`, `containment`, `download`, `digest`, `archive`, `manifest`,
`destination`, `extraction`, `post-extraction`, and `cleanup`.

### One retained archive

The download directory contains exactly one top-level entry, including hidden
and system entries. It is an ordinary non-reparse file; extension is irrelevant.
Open once with `FileMode.Open`, `FileAccess.Read`, `FileShare.Read`; require
readable/seekable; hash the held stream with SHA-256; require one 64-hex result;
and compare ordinal-ignore-case. A mismatch occurs before ZIP construction.
Rewind the same stream, construct one read-only `ZipArchive` with deliberate
`leaveOpen`, keep both open through extraction, then dispose ZIP and stream
before cleanup. Do not hash by path and reopen/copy.

Before candidate creation require exactly these four root-level, ordinal,
nondirectory names:

```text
copilot-instructions.md
powershell.instructions.md
STYLE_GUIDE_CHAT.md
STYLE_GUIDE_FULL.md
```

Reject empty/missing/extra/duplicate/case-colliding names, either separator,
nesting/traversal, leading separator, drive qualification, directory entries,
and file/directory collisions.

Closed inclusive ceilings are four entries; 8 MiB declared and actual bytes
per entry; 32 MiB declared and actual total; and 32 MiB retained archive.
Reject negative, overflowed, inconsistent, or unreadable lengths and count
actual copied bytes independently.

Immediately before candidate creation, reject any ordinary, link/reparse, or
dangling leaf with its name. Create once. For each permitted entry, compute one
immediate-child normalized destination, prove containment, open
`FileMode.CreateNew` with no sharing, journal ownership, copy with limits, and
dispose deterministically. Restore no ZIP attributes, modes, links, or
timestamps. After extraction require exactly four ordinary non-reparse files,
repeat containment/component checks, and reject UTF-8 BOM and every `0x0D`.

## Canonical case catalog

`style-guide-candidate-cases.json` has one closed schema/version and exactly one
mandatory case per physical record. Each record contains:

- immutable `CaseId` matching `^PS-P1A-[A-Z]+-[0-9]{2}$`;
- unique lowercase dot-separated `SemanticCase`;
- exactly one immutable oracle profile, with no alternative profile;
- fixture recipe/raw digest and length where applicable;
- required runtimes, applicability, and primitive-probe rule;
- initial state and expected production result/status/phase/subreason;
- expected pre-cleanup state, final candidate/context state, and ordered cleanup
  sequence;
- expected diagnostic, filesystem/native call count, sentinels, and source
  repository state; and
- optional `SemanticVariant` only for an intentional many-to-one reciprocal
  semantic map.

Unknown/missing properties, duplicate IDs/semantic keys, unused cases,
undeclared skips, expectation forks, slash-list values, “plus,” or unused
profiles fail. Generate test-owned ZIP/path/Git fixtures in fresh contexts;
never track a fixture tree. This is the closed physical ID allocation:

| Case ID | `SemanticCase` | Singular required oracle |
| --- | --- | --- |
| `PS-P1A-V-01` | `archive.valid.exact` | Exact valid four-file archive succeeds |
| `PS-P1A-V-02` | `archive.attributes.linklike-ignored` | Link-like ZIP attributes yield ordinary files |
| `PS-P1A-P-01` | `path.containment.sibling-prefix` | Sibling-prefix escape is rejected |
| `PS-P1A-P-02` | `path.provider.filesystem-qualified` | Valid FileSystem-qualified paths succeed |
| `PS-P1A-D-01` | `digest.mismatch.labels-omitted` | Digest mismatch with omitted labels |
| `PS-P1A-D-02` | `digest.mismatch.labels-present` | Digest mismatch with exact valid labels |
| `PS-P1A-D-03` | `digest.grammar.short` | Short digest rejected as parameter |
| `PS-P1A-D-04` | `digest.grammar.nonhex` | Nonhex digest rejected as parameter |
| `PS-P1A-D-05` | `digest.grammar.prefixed` | Algorithm-prefixed digest rejected |
| `PS-P1A-Z-01` | `archive.zip.truncated` | Matching digest with truncated ZIP rejected |
| `PS-P1A-M-01` | `manifest.entry.missing` | One required entry missing |
| `PS-P1A-M-02` | `manifest.entry.extra` | One extra root entry present |
| `PS-P1A-M-03` | `manifest.entry.duplicate-exact` | Exact duplicate name rejected |
| `PS-P1A-M-04` | `manifest.entry.duplicate-case` | Case-colliding duplicate rejected |
| `PS-P1A-M-05` | `manifest.path.nested-forward` | Forward-slash nested name rejected |
| `PS-P1A-M-06` | `manifest.path.nested-back` | Backslash nested name rejected |
| `PS-P1A-M-07` | `manifest.path.traversal-forward` | Forward-slash traversal rejected |
| `PS-P1A-M-08` | `manifest.path.traversal-back` | Backslash traversal rejected |
| `PS-P1A-M-09` | `manifest.path.leading-forward` | Leading forward slash rejected |
| `PS-P1A-M-10` | `manifest.path.leading-back` | Leading backslash rejected |
| `PS-P1A-M-11` | `manifest.path.drive-qualified` | Drive-qualified name rejected |
| `PS-P1A-M-12` | `manifest.entry.directory` | Directory entry rejected |
| `PS-P1A-M-13` | `manifest.entry.file-directory-collision` | File/directory collision rejected |
| `PS-P1A-M-14` | `manifest.entry.raw-empty-name` | Raw empty ZIP name rejected |
| `PS-P1A-E-01` | `environment.roots.equal` | Checkout and trusted root equality rejected |
| `PS-P1A-E-02` | `environment.roots.trusted-ancestor` | Trusted root ancestor of checkout rejected |
| `PS-P1A-E-03` | `environment.roots.checkout-ancestor` | Checkout ancestor of trusted root rejected |
| `PS-P1A-E-04` | `environment.checkout.relative` | Relative checkout root rejected |
| `PS-P1A-E-05` | `environment.trusted.nonfilesystem-provider` | Non-FileSystem trusted root rejected |
| `PS-P1A-E-06` | `environment.roots.case-alias` | Windows case-alias overlap rejected |
| `PS-P1A-E-07` | `environment.checkout.link-component` | Checkout link component rejected |
| `PS-P1A-E-08` | `environment.trusted.link-component` | Trusted-root link component rejected |
| `PS-P1A-E-09` | `environment.hidden-extra-detected` | Hidden extra entry is included and rejected |
| `PS-P1A-E-10` | `environment.path.wildcard` | Wildcard-bearing path rejected |
| `PS-P1A-E-11` | `environment.checkout.missing` | Missing checkout root rejected |
| `PS-P1A-E-12` | `environment.trusted.wrong-type` | Trusted-root ordinary file rejected |
| `PS-P1A-E-13` | `environment.path.raw-array` | Raw array path fails before provider calls |
| `PS-P1A-E-14` | `environment.path.raw-object` | Raw object path fails before provider calls |
| `PS-P1A-E-15` | `environment.candidate.case-collision` | Candidate case-colliding leaf rejected |
| `PS-P1A-L-01` | `candidate.preexisting.file` | Existing ordinary file leaf rejected |
| `PS-P1A-L-02` | `candidate.preexisting.directory` | Existing directory leaf rejected |
| `PS-P1A-L-03` | `candidate.preexisting.live-link` | Live link leaf rejected |
| `PS-P1A-L-04` | `candidate.preexisting.dangling-link` | Dangling link leaf rejected |
| `PS-P1A-B-01` | `output.bytes.bom` | Extracted UTF-8 BOM rejected |
| `PS-P1A-B-02` | `output.bytes.cr` | Extracted `0x0D` rejected |
| `PS-P1A-K-01` | `helper.cleanup.unjournaled-entry` | Helper unjournaled entry retains uncertainty |
| `PS-P1A-K-02` | `helper.cleanup.link-substitution` | Helper link substitution retains uncertainty |
| `PS-P1A-K-03` | `helper.cleanup.disposed-repeat` | Helper disposed repeat makes zero calls |
| `PS-P1A-K-04` | `helper.cleanup.primary-and-cleanup-failure` | Primary and candidate-cleanup failures both survive |
| `PS-P1A-C-01` | `context.cleanup.normal` | Normal context cleanup reaches Disposed |
| `PS-P1A-C-02` | `context.cleanup.disposed-repeat` | Context disposed repeat makes zero calls |
| `PS-P1A-C-03` | `context.cleanup.unjournaled-entry` | Unjournaled context entry retains uncertainty |
| `PS-P1A-C-04` | `context.cleanup.link-substitution` | Context link substitution retains uncertainty |
| `PS-P1A-C-05` | `context.cleanup.missing-entry` | Missing owned entry retains uncertainty |
| `PS-P1A-C-06` | `context.cleanup.primary-and-cleanup-failure` | Primary and context-cleanup failures both survive |
| `PS-P1A-C-07` | `context.cleanup.partial-journal` | Partial/tampered journal makes zero deletion calls |
| `PS-P1A-C-08` | `context.cleanup.candidate-then-context` | Candidate cleanup precedes context cleanup |
| `PS-P1A-R-01` | `resource.entry.below` | Per-entry bytes immediately below ceiling |
| `PS-P1A-R-02` | `resource.entry.at` | Per-entry bytes exactly at ceiling |
| `PS-P1A-R-03` | `resource.entry.above` | Per-entry declared bytes above ceiling |
| `PS-P1A-R-04` | `resource.total.below` | Total bytes immediately below ceiling |
| `PS-P1A-R-05` | `resource.total.at` | Total bytes exactly at ceiling |
| `PS-P1A-R-06` | `resource.total.above` | Total declared bytes above ceiling |
| `PS-P1A-R-07` | `resource.archive.below` | Archive bytes immediately below ceiling |
| `PS-P1A-R-08` | `resource.archive.at` | Archive bytes exactly at ceiling |
| `PS-P1A-R-09` | `resource.archive.above` | Archive bytes above ceiling |
| `PS-P1A-R-10` | `resource.actual.entry-overrun` | Actual entry bytes exceed declaration/ceiling |
| `PS-P1A-R-11` | `resource.actual.total-overrun` | Actual total bytes exceed declaration/ceiling |
| `PS-P1A-R-12` | `resource.declared.negative-inconsistent` | Negative/inconsistent length rejected |
| `PS-P1A-R-13` | `resource.arithmetic.checked-overflow` | Checked aggregate overflow rejected |
| `PS-P1A-W-01` | `download.entries.empty` | Empty download directory rejected |
| `PS-P1A-W-02` | `download.entries.two-files` | Two top-level entries rejected |
| `PS-P1A-W-03` | `download.entry.directory` | Directory download entry rejected |
| `PS-P1A-W-04` | `download.entry.link` | Link download entry rejected |
| `PS-P1A-W-05` | `download.entry.unreadable` | Unreadable archive rejected |
| `PS-P1A-S-01` | `script.helper.path-missing` | Missing helper path rejected |
| `PS-P1A-S-02` | `script.context.path-missing` | Missing context path rejected |
| `PS-P1A-S-03` | `script.helper.path-wildcard` | Wildcard helper path rejected |
| `PS-P1A-S-04` | `script.context.path-wildcard` | Wildcard context path rejected |
| `PS-P1A-S-05` | `script.helper.nonfilesystem-provider` | Non-FileSystem helper path rejected |
| `PS-P1A-S-06` | `script.helper.raw-array` | Raw helper array fails before Git/filesystem |
| `PS-P1A-S-07` | `script.context.raw-object` | Raw context object fails before Git/filesystem |
| `PS-P1A-S-08` | `script.helper.link` | Helper link/reparse path rejected |
| `PS-P1A-S-09` | `script.context.link` | Context link/reparse path rejected |
| `PS-P1A-S-10` | `script.helper.provider-qualified-valid` | Valid provider-qualified helper succeeds |
| `PS-P1A-S-11` | `script.context.provider-qualified-valid` | Valid provider-qualified context succeeds |
| `PS-P1A-S-12` | `script.helper.untracked` | Untracked helper substitution rejected |
| `PS-P1A-S-13` | `script.context.head-absent` | Context absent from HEAD rejected |
| `PS-P1A-S-14` | `script.helper.index-absent` | Helper absent from index rejected |
| `PS-P1A-S-15` | `script.context.conflict-stage` | Context conflict stages rejected |
| `PS-P1A-S-16` | `script.helper.staged-replacement` | Staged helper replacement rejected |
| `PS-P1A-S-17` | `script.context.unstaged-replacement` | Unstaged context replacement rejected |
| `PS-P1A-S-18` | `script.helper.wrong-mode` | Wrong helper Git mode rejected |
| `PS-P1A-S-19` | `script.context.wrong-tree-type` | Nonblob context tree entry rejected |
| `PS-P1A-S-20` | `script.git.ls-tree-malformed` | Malformed raw tree record rejected |
| `PS-P1A-S-21` | `script.git.ls-files-malformed` | Malformed raw index record rejected |
| `PS-P1A-S-22` | `script.git.object-id-abbreviated` | Abbreviated object ID rejected |
| `PS-P1A-S-23` | `script.git.object-id-wrong-format` | Wrong active-format object ID rejected |
| `PS-P1A-S-24` | `script.git.native-status-failure` | Native Git failure rejected |
| `PS-P1A-S-25` | `script.git.hostile-literal-substitution` | Hostile literal filename cannot substitute |
| `PS-P1A-X-01` | `label.artifact.explicit-null` | Explicit null artifact label rejected |
| `PS-P1A-X-02` | `label.artifact.empty` | Empty artifact label rejected |
| `PS-P1A-X-03` | `label.artifact.whitespace` | Whitespace artifact label rejected |
| `PS-P1A-X-04` | `label.artifact.raw-array` | Array artifact label rejected |
| `PS-P1A-X-05` | `label.runid.raw-object` | Object run ID rejected |
| `PS-P1A-X-06` | `label.runattempt.control` | Control-bearing run attempt rejected |
| `PS-P1A-X-07` | `label.artifact.over-limit` | Over-limit artifact label rejected |
| `PS-P1A-X-08` | `label.artifact.valid` | Exact valid artifact label succeeds |
| `PS-P1A-X-09` | `label.run-identities.valid` | Exact valid run labels succeed |
| `PS-P1A-X-10` | `label.optional.omitted` | All optional labels emit `unavailable` |

Every row—not a range heading—is the executable oracle. The catalog contains
exactly 110 unique physical case rows. The catalog itself repeats or resolves
the complete singular fields above; this prose table is not permission to
invent values later. If group counts do not total 110, implementation stops.
Every runtime emits exactly one result for every applicable ID, including
fixed/conditional skip records.

`All` cases run on Windows PowerShell 5.1, PowerShell 7/Windows, and PowerShell
7/Ubuntu. Windows/Linux comparison cases have fixed opposite-platform skip
codes. Per-OS link cases may skip only after the exact primitive-creation probe,
with ID/runtime/probe/reason recorded. At least one real root link, below-root
link, candidate substitution, and context substitution must execute per OS
family or that runtime fails.

Catalog-integrity fixtures independently reject missing, duplicate, unknown,
renamed, regrouped, multiply emitted, skipped-without-authority, orphaned, and
unused-profile IDs.

## Result and evidence schema

Every in-memory result has first `PSTypeName`
`PSStyleGuide.CandidateCaseResult.v1` and exactly:

- `SchemaVersion` (`UInt32`, `1`);
- exact strings `CaseId`, `SemanticCase`, and nullable `SemanticVariant`;
- closed `OperatingSystem`/`PowerShellEdition` strings and exact
  `PowerShellVersion` (`System.Version`);
- closed `ExpectedResult`/`ActualResult`,
  `ExpectedStatus`/`ActualStatus`, and `ExpectedPhase`/`ActualPhase`;
- closed `ExpectedDiagnosticCode` and `ActualDiagnosticCode`;
- expected/actual pre-cleanup oracle, cleanup sequence, and final candidate/
  context state;
- `FixtureLength` (`UInt64`) and lowercase `FixtureSha256`;
- nonempty `InvocationId` (`Guid`);
- `HarnessVerdict` (`pass`, `fail`, or `skip`);
- nullable closed `HarnessDiagnosticCode`, used only for fixture/catalog/
  orchestration failure or an authorized applicability skip; and
- `FilesystemCallCount` (`UInt32`).

Unknown fields/types/enums or inconsistent relationships fail. A correctly
observed production rejection has `ExpectedResult: rejection`, equal actual
failure fields including its non-`None` diagnostic, and
`HarnessVerdict: pass`. A production success similarly requires exact oracle
equality. An applicability skip is `skip`, never `pass`. `HarnessDiagnosticCode`
is `None` for ordinary matched production success/rejection and never replaces
the actual production diagnostic. Suite success requires exact multiset
equality with the catalog's case×runtime expansion.

Emit a canonical JSONL projection with fixed property order/invariant strings,
BOM-less UTF-8, LF, and one object per result. It contains no absolute paths,
exception stack, environment, archive contents, or secrets. A separate bounded
run envelope may record UTC start/end and tool/catalog hashes without changing
per-case equality.

## Reciprocal P1A↔T1A comparison

At implementation start and before merge compare exact landed PSStyleGuide and
TerraformStyleGuide P1A/T1A contracts across raw binding, omission/null rules,
schemas/types, trusted helper/context Git identity and public functions,
archive/digest order, path/link safety, manifest/limits, extraction, both
cleanup lifecycles, zero-call terminal behavior, physical case/oracle semantic
keys, runtime applicability/skips, expected/actual production outcomes,
harness verdicts, result/evidence schemas, and diagnostics.

Join on `SemanticCase` plus optional variant; classify PS-only/T-only cases.
Record exact evidence and `same`, `intentional difference`, or `blocker`.
Manifest filenames may differ intentionally; unexplained security/failure
differences block merge.

## Validation

Run exact tracked scripts/catalog in clean disposable worktrees under Windows
PowerShell 5.1, PowerShell 7 on Windows, and PowerShell 7 on Ubuntu. Record
script/catalog versions and hashes, executable/edition/OS/Git, exact
pass/fail/skip totals, and duration.

Static and dynamic checks prove:

- public raw non-string values fail before any filesystem/provider call;
- no recursive/wildcard deletion, automatic ZIP extraction, ambient root,
  alternate cleanup, or production test switch exists;
- context/journal/result ordered schemas and every mutation are rejected;
- terminal repeats perform zero filesystem/native calls;
- one held archive stream and exact validation/extraction order are observed;
- every catalog case executes once on its declared runtime set;
- expected production rejections with matching actual diagnostics count as
  harness pass, while missing/duplicate/unexpected/status/diagnostic/skip/total
  mismatch fails the suite;
- helper/context fixed-path HEAD/index/no-filter identity and expected version
  are proved both before load and immediately before invocation;
- sentinels and source repository remain byte-identical;
- P1's exact path verifier proves only the four affected paths changed/staged
  before and after rerun; and
- generator, workflows, artifacts, package/update policy remain unchanged.

Any temporary hosted-evidence workflow is test-owned, absent from the final
commit, and not required by the production harness.

## Acceptance criteria

- [ ] Four affected files are versioned/hashed as required and LF/BOM-less.
- [ ] Every public value crosses the raw exact-type boundary before conversion
      or filesystem work.
- [ ] Context, journal, lifecycle, and result schemas are exact and mutation
      tested.
- [ ] Cleanup is nonrecursive/journal-based; uncertainty is retained; terminal
      repeats make zero calls.
- [ ] One archive stream is opened, hashed, rewound, parsed, and disposed in
      order; digest mismatch precedes ZIP construction.
- [ ] Component, containment, root-separation, link, download, manifest, and
      declared/actual limit cases pass on both OS families.
- [ ] Extraction creates only four fresh ordinary BOM-less/LF files and
      restores no ZIP metadata.
- [ ] The authoritative catalog contains exactly 110 unique physical namespaced
      rows/profiles and
      semantic keys, with exact case×runtime results and honest skips.
- [ ] Expected/actual production outcomes and diagnostics are distinct from
      harness pass/fail/skip judgment.
- [ ] Supplied helper/context scripts are fixed trusted HEAD/index/no-filter
      blobs at their expected versions before load and use.
- [ ] JSONL evidence is canonical, bounded, and path/content/secret minimizing.
- [ ] Real link/reparse rejection executes on both OS families.
- [ ] P1A↔T1A has no unexplained blocker.
- [ ] P1's landed verifier proves final path sets equal the four affected files.
- [ ] No production workflow consumes the scripts.

## Handoff

Give P1B permanent P1A issue/PR URLs, reviewed head/base, merge method, landed
commit/tree, all three script versions/hashes, catalog schema/version/hash,
exact public function/result schemas, trusted-script Git identity proof,
per-runtime JSONL/run evidence, primitive probes, cleanup/zero-call proof,
final path-set proof, and P1A↔T1A matrix. P1B compares these landed identities
with its assumptions before activating anything.

## Non-goals

- Workflow trigger/permission/job/action or artifact-transport changes.
- Downloading/uploading a real Actions artifact.
- Committing generated output.
- An OS-native adversarial filesystem sandbox or competing untrusted writer.
- A shared cross-repository runtime module.

## References

- [PowerShell parameter binding](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_parameter_binding)
- [Path.GetRandomFileName](https://learn.microsoft.com/dotnet/api/system.io.path.getrandomfilename)
- [FileStream](https://learn.microsoft.com/dotnet/api/system.io.filestream)
- [Get-FileHash](https://learn.microsoft.com/powershell/module/microsoft.powershell.utility/get-filehash)
- [ZipArchive](https://learn.microsoft.com/dotnet/api/system.io.compression.ziparchive)
- [File attributes](https://learn.microsoft.com/dotnet/api/system.io.fileattributes)
