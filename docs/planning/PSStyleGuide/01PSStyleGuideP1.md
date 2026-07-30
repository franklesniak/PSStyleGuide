# Make artifact generation byte-deterministic across PowerShell editions and hosts

## Summary

Make the four generated style-guide artifacts byte-identical under Windows
PowerShell 5.1 and PowerShell 7 on Windows and Ubuntu. Centralize final
destination validation and BOM-less UTF-8 serialization, preserve the existing
LF checkout policy, move hosted Markdown validation to exact Node 24, pin every
current external action to a reviewed full commit SHA, and add review-only
GitHub Actions updates. Establish the tracked structural workflow-policy
validator and raw NUL-safe Git path-set verifier that later issues extend or
consume.

This issue establishes foundations only. It does not add the candidate ZIP
validator or activate the final artifact-promotion writer.

## Execution order

This is P1 and the first issue in the PSStyleGuide slate.

After P1 merges:

1. implement P1A, **Add a fail-closed cross-platform style-guide candidate
   validator**, against P1's exact merge commit;
2. implement P1B, **Promote generated style-guide artifacts through a
   least-privileged verified writer**, against exact P1/P1A merge commits;
3. implement P2 against P1B's final publication boundary; and
4. implement P3 against exact P1/P1A/P1B/P2 commits.

Record real GitHub blocked-by relationships when the issues are filed.

File the slate transactionally in P1, P1A, P1B, P2, P3 order. After filing
each predecessor, copy its canonical PSStyleGuide issue URL into the successor,
create the real GitHub `blocked by` relationship, retrieve both issues, and
verify repository, number, title, and relationship before filing/readying the
successor. Retain the five canonical URLs and four verified edges. Never file
a literal placeholder or fabricated issue number.

## Advisory-risk execution gate

Before editing, obtain one dated accountable decision that permits the current
npm advisory state to remain through P1, P1A, P1B, and P2 until P3. Record in
the filed P1 issue or linked governed evidence:

- approving person/role and authorizing policy;
- canonical UTC decision and expiry times;
- exact Node/npm executable paths and versions;
- exact audit command, native exit, report version, raw-response digest, and
  current package/advisory/severity inventory;
- reason generator/writer hardening precedes dependency remediation;
- compensating controls and prohibited package changes; and
- maximum authorized milestone, which cannot extend beyond P3 completion.

At P1 start rerun the exact audit. Missing, expired, unauthorized, or
materially worsened evidence stops implementation. If governing policy does
not permit the wait, rebaseline the slate with the smallest compatible
dependency-remediation issue before P1; do not improvise package changes in
P1.

## Affected files

Exactly these eight implementation files may change:

- `.github/workflows/Generate-StyleGuideArtifacts.ps1`;
- `.github/workflows/build.yml`;
- `.github/workflows/markdownlint.yml`;
- `.github/workflows/Validate-WorkflowPolicy.mjs` — add;
- `.github/workflows/Test-ExactGitPathSet.ps1` — add;
- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`; and
- `.github/dependabot.yml` — add.

Package/lock changes are limited to one reviewed direct YAML parser required
by `Validate-WorkflowPolicy.mjs`. Do not upgrade, replace, or otherwise change
the existing lint/hook dependency graph; P3 owns that work.

Do not modify `.gitattributes`; verify it remains exactly:

```gitattributes
* text=auto eol=lf
```

The generator must exercise these artifacts during validation, but their final
committed bytes must remain unchanged:

- `copilot-instructions.md`;
- `powershell.instructions.md`;
- `STYLE_GUIDE_CHAT.md`; and
- `STYLE_GUIDE_FULL.md`.

Do not hand-edit generated artifacts.

## Requested changes

### 1. Add one final destination and serialization boundary

Create one private generator helper used by all four final writes. It accepts
one destination string and one complete final payload.

For the destination:

1. capture the original value for diagnostics;
2. reject null/empty/whitespace, wildcard-bearing, relative, and malformed
   provider input without trimming or rewriting it;
3. call the `GetUnresolvedProviderPathFromPSPath` overload that returns
   `ProviderInfo` and `PSDriveInfo`;
4. require exactly the FileSystem provider;
5. require one rooted absolute provider-internal result;
6. normalize it once with `Path.GetFullPath`; and
7. fail with stable phase, captured destination, and underlying exception on
   every inconsistent or failed result.

Do not pass unresolved wildcard characters to .NET. Do not use `Resolve-Path`
in a way that requires a previously existing destination leaf.

For the payload:

```powershell
$strNormalizedContent = $CompleteFinalPayload -replace "`r`n?", "`n"
```

Then:

- construct `System.Text.UTF8Encoding($false)` explicitly;
- call `System.IO.File.WriteAllText` exactly once;
- do not append an implicit final newline;
- perform no later text transformation; and
- do not use `Set-Content`, `Out-File`, or a host-default encoding for final
  artifacts.

The complete final payloads remain:

| Function | Complete final payload |
| --- | --- |
| `New-StyleGuideCopilotVersion` | `$strContent` |
| `New-StyleGuidePowerShellInstructionsVersion` | `$strFullContent` |
| `New-StyleGuideChatVersion` | `$strWrappedContent` |
| `New-StyleGuideFullVersion` | `$strOutput` |

Preserve `New-StyleGuideFullVersion`'s existing split/join semantics. Normalize
after all transformations and concatenations, immediately before encoding.

### 2. Replace the frontmatter here-string

Build the `powershell.instructions.md` YAML frontmatter from an explicit array
of lines joined with ``"`n"``. Preserve its exact keys, values, quoting, two
blank lines after the closing delimiter, and existing generated bytes.

Do not depend on source-file or host newline style.

### 3. Record exact script metadata

Retain `#Requires -Version 5.1`.

Use the PSStyleGuide Function and Script Versioning policy and record the
generator version in the existing parseable `.NOTES` location. Use the
implementation UTC date and exact calculation/bump rule. Validation must parse
that named field; a guide-document version is not a substitute for script
metadata.

P1A and P1B consume the exact P1 script version and merge commit.

### 4. Preserve LF checkout policy

Prove `.gitattributes` has the exact required single line and that all tracked
text index blobs are LF/BOM-less as applicable before implementation.

Run `git add --renormalize .` only in a disposable validation worktree. Stop
and rebaseline rather than silently widening P1 if any unrelated tracked text
path would change. The final working/cached path sets must equal P1's eight
affected files; generated artifacts and `.gitattributes` remain unchanged.

### 5. Use exact hosted Node 24

In `.github/workflows/markdownlint.yml`:

- use the exact setup-node role below;
- set `node-version: '24'`;
- set `package-manager-cache: false`;
- resolve the actual Node process before installation;
- require exact major 24 and log full Node/npm versions;
- save the caller's `CI` environment state;
- set process-scoped `CI=true` only for `npm ci`;
- restore the prior value or absence in `finally`;
- run the unchanged outer Markdown lint command; and
- run the unchanged nested-Markdown lint command.

Except for the one reviewed direct YAML parser and regenerated lockfile
required by this issue, do not change existing package declarations, the hook,
lint configuration, lint scripts, or final contributor runtime policy. P3
owns dependency remediation and runtime-policy changes.

### 6. Pin the current external actions with one normative role table

Immediately before implementation and again immediately before merge,
re-resolve the official release tags and retain timestamped provenance
evidence. Stop for renewed review if a tag target, repository provenance,
release metadata, or pinned manifest/default digest differs.

| Action | Required full commit SHA | Reviewed release |
| --- | --- | --- |
| `actions/checkout` | `3d3c42e5aac5ba805825da76410c181273ba90b1` | `v7.0.1` |
| `actions/setup-node` | `820762786026740c76f36085b0efc47a31fe5020` | `v7.0.0` |
| `actions/upload-artifact` | `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` | `v7.0.1` |

This is the sole normative temporary action-role inventory:

| Workflow | Job ID | Step ID | Action/release | Condition | Exact explicitly declared inputs |
| --- | --- | --- | --- | --- | --- |
| `build.yml` | `verify_generated_artifacts` | `checkout_repository` | `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1` (`v7.0.1`) | ordinary job step | `ref: ${{ github.sha }}`; `persist-credentials: false` |
| `build.yml` | `verify_generated_artifacts` | `upload_failure_diagnostics` | `actions/upload-artifact@043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` (`v7.0.1`) | `${{ failure() && !cancelled() }}` | collision-free run/attempt name; exact diagnostic-directory output; `if-no-files-found: error`; `retention-days: 7`; `overwrite: false`; `include-hidden-files: false`; `archive: true` |
| `build.yml` | `synchronize_generated_artifacts_temporary` | `checkout_repository` | `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1` (`v7.0.1`) | ordinary job step | `ref: ${{ github.sha }}`; `persist-credentials: false` |
| `markdownlint.yml` | `markdownlint` | `checkout_repository` | `actions/checkout@3d3c42e5aac5ba805825da76410c181273ba90b1` (`v7.0.1`) | ordinary job step | `ref: ${{ github.sha }}`; `persist-credentials: false` |
| `markdownlint.yml` | `markdownlint` | `setup_node` | `actions/setup-node@820762786026740c76f36085b0efc47a31fe5020` (`v7.0.0`) | ordinary job step | `node-version: '24'`; `package-manager-cache: false` |

For `upload_failure_diagnostics`, “collision-free run/attempt name” means
exactly
`style-guide-verification-${{ github.job }}-${{ github.run_id }}-${{ github.run_attempt }}`.
Its path is exactly
`${{ steps.failure_diagnostics.outputs.diagnostic_path }}`. The producer
creates a fresh job-owned directory under `RUNNER_TEMP`, always writes one
bounded redacted BOM-less/LF summary with stable phase/native-exit/
repository-relative-path/size/hash fields, and copies an available generated
destination only after ordinary-file, non-reparse, containment, and reviewed
size checks. It never copies source, environment, token, Git configuration,
remote URL, or arbitrary logs. The producer and upload both use
`continue-on-error: true` so diagnostics cannot hide the primary failure.

For every role, retain a second record titled **Reviewed effective defaults at
pinned manifest**. It identifies the exact full-SHA `action.yml` URL/digest,
every manifest input/default shape, and the effective omitted values affecting
credentials, clean/fetch behavior, caching, selection/extraction, overwrite,
retention, or failure. The role table governs literal YAML `with` keys;
manifest defaults remain real reviewed behavior.

Every `uses:` line must have the exact full SHA and matching release comment.
Parse all tracked workflow YAML structurally and require exact role-set and
explicit-input-set equality. Reject unknown explicit inputs, roles, actions,
and workflows even when an action would ignore the input. A changed
security-relevant test-manifest default must require renewed review.

Negative fixtures cover missing, extra, duplicate, misplaced, mutable,
arbitrary-SHA, wrong-repository, wrong-release-comment, wrong-condition, and
weakened-input rows.

P1B atomically replaces this temporary table with its final role table.

### 7. Add tracked structural workflow-policy validation

Create `.github/workflows/Validate-WorkflowPolicy.mjs` with a versioned
dependency-free policy layer over one reviewed direct YAML parser. Regenerate
the lockfile with the exact selected npm; do not manually edit it. After
`npm ci`, validation is deterministic and offline.

Parser/validator requirements:

- use the reviewed safe/core schema;
- reject duplicate keys, aliases, custom tags, unknown node shapes, merge
  keys, and unbounded/dynamic constructs;
- distinguish exact explicit YAML inputs from reviewed pinned-manifest
  defaults;
- validate exact events, permissions, jobs, stable step IDs, conditions,
  `needs`, action roles, full SHAs/comments, and the sole temporary writer;
- reject a second write-enabled job, remote reusable workflow, cache,
  credential persistence, auto-extraction, mutable action, or unknown role;
- emit stable policy IDs and bounded diagnostics; and
- operate on explicit repository/workflow/manifest paths without ambient
  discovery.

Tracked positive and negative fixtures use test-owned workflow copies.
Independently cover missing, extra, duplicate, swapped, dynamic, mutable,
wrong-repository/SHA/comment/condition/permission/event/input/default, and
writer-predicate mutations. P1B updates this same validator and parser
atomically; P3 retains and extends them.

### 8. Add one NUL-safe exact Git path-set verifier

Create `.github/workflows/Test-ExactGitPathSet.ps1` with
`#Requires -Version 5.1`, exact script version, and a public command accepting:

- explicit repository root;
- explicit expected repository-relative path array;
- closed mode `Working`, `Staged`, or `Both`; and
- optional requirement for an empty working-versus-index set.

Resolve Git as an application and invoke it through
`System.Diagnostics.Process` with argument arrays and redirected raw
stdout/stderr. Capture native exit immediately. Use:

- `git diff --no-renames --name-only -z` for unstaged paths;
- `git diff --cached --no-renames --name-only -z` for staged paths; and
- `git ls-files --others --exclude-standard -z` for untracked paths.

Split only on raw byte `0x00`; reject malformed termination/cardinality and
compare each record to the exact expected ASCII bytes using ordinal identity.
Do not text-decode or print hostile raw path bytes. Emit stable missing,
unexpected, malformed, and native-command categories.

Disposable-repository fixtures cover spaces, tabs, quotes, backslashes,
newline-bearing names, non-ASCII names where supported, deletion, rename,
untracked files, and mixed staged/unstaged state. Run them under Windows
PowerShell 5.1 and PowerShell 7. P1A, P1B, P2, and P3 consume this exact
version unless a separately scoped fix is reviewed.

### 9. Add review-only GitHub Actions updates

Create `.github/dependabot.yml` with normalized exact content equivalent to:

```yaml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

Use approved weekday/time/timezone fields only if repository policy requires
them. Require exactly one `github-actions` entry for `/`, no duplicates, and no
automatic approval/merge. Every proposal requires release/provenance/SHA/
runtime/input review and atomic role-table updates.

P3 replaces this intermediate invariant with exactly two entries by adding npm
at `/.github/workflows`.

### 10. Isolate the temporary publication boundary

P1 must not add the candidate helper, context manager, permanent harness,
download action, matrix approval, or final writer.

In `.github/workflows/build.yml`:

- run pull-request verification for every pull request targeting `main`;
- run push verification for every push to `main`;
- remove workflow-level path filters and skip-commit behavior;
- set workflow/top-level permissions to `contents: read`;
- run a read-only generation/byte verification job from the exact event SHA;
- give `contents: write` only to a separate temporary push-to-`main`
  synchronization job;
- disable persisted credentials on every checkout;
- stage only the four generated artifacts and reject any other path; and
- use explicit remote preflight, destination ref, and exact expected-SHA lease
  for the temporary push.

GitHub creates the write-capable `GITHUB_TOKEN` for the complete temporary
writer job. The exact pinned checkout action may use it transiently for fetch.
`persist-credentials: false` and checkout cleanup remove retained
authentication; immediately afterward prove no credential helper,
`http.*.extraheader`, token-bearing remote URL, or ordinary token environment
variable is available to repository scripts.

Keep xtrace disabled. Only the exact push step receives the masked token and
derives one child-process-scoped environment-backed HTTP authorization header
for the single exact-lease/refspec `git push`. Never place token/header state
in a remote URL, constructed command string, file, artifact, output, or
diagnostic. Restore/remove every temporary environment and Git value in
`finally`, then prove no credential state remains.

Before enabling the push-to-`main` predicate, use exactly
`.github/workflows/evidence-p1-temporary-writer.yml` on one recorded unique
temporary branch. Its writer algorithm/action roles must structurally equal
the proposed production temporary writer except for a literal predicate
authorizing only that exact evidence ref. Run changed/no-change, stale
preflight, lost lease, unrelated ref, unexpected path, and token-sentinel
drills against the real repository origin.

Retain workflow/commit/run/remote identity evidence, then delete the evidence
workflow and branch. Final validation proves the evidence path and every
alternate write predicate are absent from the production commit. Never
hand-edit the production predicate to run this proof.

P1B replaces this temporary job with immutable candidate transport, complete
matrix approval, at-use revalidation, and the final writer.

### 11. Apply one native-command contract

Every complete PowerShell `run:` block:

- selects `powershell` or `pwsh` explicitly;
- starts with `$ErrorActionPreference = 'Stop'`;
- captures `$LASTEXITCODE` immediately after each native command;
- validates output count/shape before use; and
- throws/exits nonzero on every failure.

Classify `git diff --exit-code`/`--no-index --exit-code` as 0 equal, 1 ordinary
difference, and every other value command failure. Treat every nonzero
`git ls-remote --exit-code` as failure and retain the native status.

### 12. Add the reciprocal P1↔T1 comparison

At implementation start and before merge, compare exact PSStyleGuide P1 and
TerraformStyleGuide T1 commits across:

- complete-payload boundaries;
- destination/provider rules;
- encoding/newline/final-newline behavior;
- frontmatter and intentional artifact differences;
- script metadata;
- Node/action foundations;
- native exits;
- generated-byte/idempotence evidence; and
- temporary publication boundaries.

For every row retain PS evidence, Terraform evidence, status (`same`,
`intentional difference`, or `blocker`), and rationale. Unexplained observable
security/failure differences block merge. Keep both repositories
self-contained; do not create a shared runtime package.

## Validation

Use clean disposable clones/worktrees and do not let one edition overwrite
another's evidence.

### Generator matrix

Run:

- Windows PowerShell exactly 5.1 on Windows;
- PowerShell 7 on Windows; and
- PowerShell 7 on Ubuntu.

For every available cell:

1. record executable path, edition, full version, OS, and Git version;
2. start from exact committed source/artifact bytes;
3. run the exact generator;
4. capture all four SHA-256 values;
5. prove no UTF-8 BOM or `0x0D`;
6. prove a second run is byte-idempotent; and
7. compare hashes across cells.

At minimum, Windows PowerShell 5.1 and one PowerShell 7 cell must match.

Use controlled fixtures for ordinary rooted and FileSystem-qualified
destinations; null/empty, relative, wildcard, non-FileSystem, malformed, and
serialization failures; CRLF/lone CR normalization; frontmatter; BOM/CR; and
repeat idempotence. Restore test-owned state in `finally`.

### Node, workflow, and scope

Prove:

- Node 24 clean install and both existing lint surfaces pass;
- existing dependency versions, hook, and lint scripts/config remain unchanged;
- package/lock differences are exactly the reviewed direct YAML parser and its
  reproducible dependency graph;
- `.gitattributes` and tracked text index blobs satisfy LF policy;
- every external action equals the sole temporary role table;
- explicit-input and pinned-manifest-default records are exact;
- all structural workflow-policy positive/negative fixtures pass;
- all exact Git path-set verifier fixtures pass on required runtimes;
- Dependabot has exactly one review-only Actions entry;
- workflow permissions/triggers match this issue;
- no helper/context/harness/download/approval/final writer exists;
- diagnostics are bounded/redacted/failure-only and token-sentinel clean;
- generated artifact blobs remain unchanged;
- working and cached path sets equal the eight affected files through the
  tracked raw NUL-safe verifier; and
- validation from staged content produces no further diff.

Retain pull-request and controlled temporary-branch push evidence. The
temporary writer must prove stale ref, exact lease, no-op, unrelated event, and
token-sentinel failures leave the remote target unchanged. Retain evidence that
the exact temporary evidence workflow/ref was removed and is absent from the
production commit.

## Acceptance criteria

- [ ] One private helper validates every destination and performs every final
      BOM-less UTF-8 write.
- [ ] All complete payloads normalize CRLF/lone CR immediately before
      serialization.
- [ ] Windows PowerShell 5.1 and PowerShell 7 produce identical artifact bytes.
- [ ] Repeated generation is byte-idempotent and committed artifacts remain
      unchanged.
- [ ] Frontmatter bytes/content remain exact.
- [ ] `.gitattributes` remains the exact LF policy.
- [ ] A current accountable advisory-risk decision authorizes the sequence
      through P3 or implementation stops for rebaseline.
- [ ] Hosted Markdown validation uses actual Node major 24 with automatic
      package-manager caching disabled.
- [ ] Existing package/hook/lint semantics remain unchanged; package/lock
      additions are exactly the reviewed YAML parser graph.
- [ ] The tracked workflow-policy validator/parser and every positive/negative
      fixture pass deterministically offline.
- [ ] The tracked raw NUL-safe path-set verifier and hostile-path fixtures pass
      under Windows PowerShell 5.1 and PowerShell 7.
- [ ] Every action equals the sole exact temporary role table.
- [ ] Exact explicit action inputs and reviewed pinned-manifest defaults are
      separately recorded and validated.
- [ ] Failure diagnostics are exact, bounded, redacted, ordinary-failure-only,
      seven-day, and token-sentinel clean.
- [ ] Dependabot has exactly one review-only GitHub Actions entry.
- [ ] Workflows are unfiltered as required and read-only except the temporary
      writer.
- [ ] Every checkout disables persisted credentials.
- [ ] Checkout's transient token use/cleanup and push-only explicit
      materialization match the honest credential contract.
- [ ] Native command and temporary exact-lease/token drills pass through the
      exact evidence workflow.
- [ ] The evidence workflow/ref is removed and no alternate production write
      predicate remains.
- [ ] P1↔T1 has no unexplained blocker.
- [ ] The working/staged path sets contain exactly the eight affected files.

## Handoff

Provide P1A with P1's actual issue URL, final merge commit, advisory-risk
decision, generator/validator/path-verifier versions and hashes, action
provenance/default evidence, generator matrix, temporary-writer runs/removal
evidence, and P1↔T1 matrix. P1A records receipt in its own dependency gate.

## Non-goals

- Candidate ZIP parsing/extraction or resource ceilings.
- Caller temporary-root ownership.
- Permanent helper/context/harness implementation.
- Immutable artifact download/promotion or final writer activation.
- Dependency remediation, lint/hook behavior changes, or final contributor
  Node-policy changes beyond the reviewed direct YAML parser required here.
- Source-guide or generated-artifact content changes.
- A shared cross-repository runtime package.

## References

- [PSStyleGuide Function and Script Versioning](https://github.com/franklesniak/PSStyleGuide/blob/main/STYLE_GUIDE.md#function-and-script-versioning)
- [PowerShell unresolved provider paths](https://learn.microsoft.com/en-us/dotnet/api/system.management.automation.pathintrinsics.getunresolvedproviderpathfrompspath)
- [PowerShell character encoding](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding)
- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [GitHub secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [GitHub workflow permissions](https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#permissions)
- [Pinned checkout action metadata](https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml)
- [Dependabot options](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
- [Git status pathname format and `-z`](https://git-scm.com/docs/git-status#_pathname_format_notes_and_z)
- [Git diff exit codes](https://git-scm.com/docs/git-diff#Documentation/git-diff.txt---exit-code)
- [Git attributes](https://git-scm.com/docs/gitattributes)
- [Git push and leases](https://git-scm.com/docs/git-push)
