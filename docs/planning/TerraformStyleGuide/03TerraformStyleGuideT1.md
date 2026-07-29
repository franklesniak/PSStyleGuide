# Make artifact generation byte-deterministic and standardize repository text checkouts on LF

## Summary

Make the style-guide generator emit identical UTF-8 bytes under Windows
PowerShell 5.1 and PowerShell 7, and establish LF as the repository checkout
policy. Move the Markdown workflow to hosted Node 24, pin every currently used
external action to a reviewed full commit SHA, and add review-only GitHub
Actions dependency updates.

This issue establishes foundations only. It does not add the candidate ZIP
validator or activate the new artifact-promotion writer.

## Execution order

This is the first issue in the TerraformStyleGuide slate.

After it merges:

1. implement **Add a fail-closed cross-platform style-guide candidate
   validator** against this exact merge commit; then
2. implement **Promote generated style-guide artifacts through a
   least-privileged verified writer** against both exact prerequisite commits.

Record real GitHub blocked-by relationships when the issues are filed.

## Affected files

Exactly these five implementation files may change:

- `.gitattributes` — add;
- `.github/dependabot.yml` — add;
- `.github/workflows/Generate-StyleGuideArtifacts.ps1`;
- `.github/workflows/build.yml`; and
- `.github/workflows/markdownlint.yml`.

The generator must regenerate these four artifacts during validation, but their
final bytes must remain unchanged:

- `copilot-instructions.md`;
- `terraform.instructions.md`;
- `STYLE_GUIDE_CHAT.md`; and
- `STYLE_GUIDE_FULL.md`.

Do not hand-edit generated artifacts.

## Requested changes

### 1. Normalize each complete payload at the serialization boundary

The complete payloads are:

| Function | Complete final payload |
| --- | --- |
| `New-StyleGuideCopilotVersion` | `$strContent` |
| `New-StyleGuideTerraformInstructionsVersion` | `$strFullContent` |
| `New-StyleGuideChatVersion` | `$strWrappedContent` |
| `New-StyleGuideFullVersion` | `$strOutput` |

Immediately before encoding each payload, use the applicable value in:

```powershell
$strNormalizedContent = <complete-final-payload> -replace "`r`n?", "`n"
```

Requirements:

- normalize after every transformation and concatenation;
- convert CRLF to one LF;
- convert lone CR to one LF;
- preserve existing LF;
- preserve `New-StyleGuideFullVersion`'s existing split/join semantics;
- do not normalize after writing; and
- do not claim semantic support for CR-only source documents.

### 2. Replace edition-dependent writes

At each of the four final write sites:

1. obtain one unambiguous filesystem path with
   `GetUnresolvedProviderPathFromPSPath`;
2. reject wildcard, non-filesystem-provider, and multiple-resolution inputs;
3. create `System.Text.UTF8Encoding($false)` explicitly;
4. write the complete normalized string with a .NET API;
5. do not append an implicit final newline; and
6. capture and report the destination on failure.

The implementation may use `File.WriteAllText` after path validation. Do not
use `Set-Content`, `Out-File`, or a host-dependent default encoding for final
artifacts.

Record one updated generator version using the repository's UTC version
convention. Retain `#Requires -Version 5.1`.

### 3. Establish the LF checkout policy

Create root `.gitattributes` containing exactly:

```gitattributes
* text=auto eol=lf
```

Do not add language-specific exceptions in this issue.

Use `git add --renormalize .` only in the controlled validation worktree.
Before staging, record current Git attributes and path sets. After staging,
prove the cached path set is exactly the five affected files and that no
generated artifact changed.

### 4. Use exact hosted Node 24

In `.github/workflows/markdownlint.yml`:

- use the reviewed setup-node action commit from the action table below;
- configure:

  ```yaml
  with:
    node-version: '24'
    package-manager-cache: false
  ```

- resolve the actual Node process before installation;
- require exact major 24 and log the full Node and npm versions;
- run a clean `npm ci`;
- run the unchanged outer Markdown lint command;
- run the unchanged nested-Markdown lint command; and
- classify the native exit of each phase.

Do not change:

- `.github/workflows/package.json`;
- `.github/workflows/package-lock.json`;
- `.husky/pre-commit`;
- lint configuration;
- lint script names; or
- repository contributor/runtime-floor policy.

The final package versions, `engines.node`, hook runtime guard, advisory
disposition, npm update policy, and contributor minimum belong to
**Remediate Markdown lint dependency advisories and add npm update
governance**.

If repository policy prohibits carrying the current high-severity advisories,
execute that npm issue first and rebaseline this issue to its exact merge
commit.

### 5. Pin and allowlist the current external actions

Immediately before implementation, resolve these release tags from their
official repositories and retain the output in the pull request. If a tag no
longer resolves to the listed commit, stop and review the upstream change
instead of silently substituting another commit.

| Action | Required full commit SHA | Reviewed release |
| --- | --- | --- |
| `actions/checkout` | `3d3c42e5aac5ba805825da76410c181273ba90b1` | `v7.0.1` |
| `actions/setup-node` | `820762786026740c76f36085b0efc47a31fe5020` | `v7.0.0` |
| `actions/upload-artifact` | `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a` | `v7.0.1` |

Every `uses:` line must contain the exact full SHA plus the matching release
annotation. Tags, branches, abbreviated hashes, dynamic `uses:`, remote
reusable workflows, unreviewed Docker actions, and other external repositories
are prohibited.

The implementation-time verifier must parse all tracked workflow YAML and
require exact multiset equality for the current workflow roles:

| Workflow | Role | Action | Expected count |
| --- | --- | --- | ---: |
| `build.yml` | read-only verification checkout | `actions/checkout` | 1 |
| `build.yml` | current push-only synchronization checkout | `actions/checkout` | 1 |
| `build.yml` | verification artifact upload | `actions/upload-artifact` | 1 |
| `markdownlint.yml` | repository checkout | `actions/checkout` | 1 |
| `markdownlint.yml` | hosted Node setup | `actions/setup-node` | 1 |

Each observed row includes workflow path, job ID, stable step role, repository,
full SHA, release annotation, and count. Reject missing, duplicate, swapped,
and extra uses. The verifier is offline; live upstream resolution belongs to
the reviewed update process.

The later writer-activation issue must replace this exact current-role table
atomically with its final workflow/role/count table.

### 6. Add review-only GitHub Actions updates

Create `.github/dependabot.yml` with normalized exact content equivalent to:

```yaml
version: 2
updates:
  - package-ecosystem: github-actions
    directory: /
    schedule:
      interval: weekly
```

Use the repository's approved weekday/time/timezone fields if maintainers
require them. The final normalized configuration must contain exactly one
`github-actions` entry for `/`, no duplicate update blocks, and no automatic
approval or merge behavior.

Dependabot proposals do not authorize an action upgrade. Each upgrade must
re-establish official repository/release provenance and update the `uses:`
lines, release annotations, exact-role allowlist, and negative fixtures
atomically.

The later npm issue replaces this intermediate one-entry invariant with exactly
two entries by adding npm at `/.github/workflows`.

### 7. Isolate current publication and record its boundary

This issue must not activate a new download action, candidate helper, approval
job, or artifact-promotion writer. Preserve the current build workflow's
functional generation/publication behavior with an explicit temporary
least-privilege split:

- set workflow/top-level permissions to `contents: read`;
- run one verification job on applicable pull requests and pushes;
- let that job check out, generate, compare, and upload current generated
  files without credentials or repository writes;
- put the existing direct commit/push behavior in a separate job that is
  eligible only for a push to `main`;
- give only that push-only job `contents: write`;
- disable persisted checkout credentials everywhere and expose its write
  credential only for the existing exact push step;
- prohibit new secrets or external actions; and
- document that T1B replaces this temporary direct-publication job with the
  final unfiltered artifact, matrix, approval, and exact-lease topology.

The temporary push-only job must still start from the exact triggering SHA,
stage only the four generated artifacts, and stop on any other changed path.
It does not claim the immutable-candidate, four-local identity, or exact-lease
properties that T1B will establish.

The Markdown workflow remains read-only and runs for every pull request
targeting `main`.

## Validation

Run validation from a clean disposable clone or worktree. Do not let one
edition overwrite the evidence produced by another.

### Generator byte matrix

For each available supported edition:

- Windows PowerShell exactly 5.1;
- PowerShell Core major 7 on Windows; and
- PowerShell Core major 7 on Ubuntu;

perform:

1. record executable path, edition, full version, OS, and Git version;
2. start from exact committed source and artifact bytes;
3. run the exact generator;
4. capture all four output SHA-256 values;
5. prove no UTF-8 BOM and no `0x0D` byte;
6. prove a second run is byte-for-byte idempotent; and
7. compare hashes across every executed edition.

At minimum, Windows PowerShell 5.1 and one PowerShell 7 run must produce
identical hashes before merge.

Add controlled temporary fixtures proving CRLF and lone CR are converted to LF
at each complete-payload boundary. Restore test-owned state in `finally`.

### Node and lint

From `.github/workflows`:

1. resolve and record one Node/npm application pair;
2. require the observed Node major to be 24;
3. save the caller's `CI` environment state;
4. set process-scoped `CI=true` only for `npm ci`;
5. restore the prior `CI` value or absence in `finally`;
6. run both existing lint scripts with the same npm application; and
7. prove package, lockfile, hook, and lint configuration are unchanged.

### Git and workflow policy

Prove:

- `.gitattributes` has exact required content;
- tracked text blobs and the five staged files contain no CR byte;
- all external actions equal the exact role allowlist;
- negative fixtures reject a mutable tag, arbitrary 40-hex SHA, wrong
  repository, duplicate use, extra workflow, and swapped role;
- Dependabot has exactly one permitted entry;
- workflow permissions did not broaden; and
- generated artifact blobs are unchanged.

### Exact scope gate

Before staging, require the complete changed/untracked path set to equal the
five affected files. After `git add --renormalize .`, require the cached path
set to equal the same five paths. Fail on every additional path, including a
generated artifact.

After all validation, run the generator and lint once more from the exact
staged content and require an empty worktree/index delta beyond those five
intentional paths.

## Acceptance criteria

- [ ] All four complete payloads normalize CRLF and lone CR immediately before
      explicit BOM-less UTF-8 serialization.
- [ ] Windows PowerShell 5.1 and PowerShell 7 produce identical artifact bytes.
- [ ] Repeated generation is byte-idempotent and the four committed generated
      artifacts remain unchanged.
- [ ] `.gitattributes` contains exactly `* text=auto eol=lf`.
- [ ] Hosted Markdown validation runs on actual Node major 24 with automatic
      setup-node package-manager caching disabled.
- [ ] Clean installation and both unchanged lint surfaces pass.
- [ ] The package manifest, lockfile, hook, and lint policy do not change.
- [ ] Every current external action equals its exact official
      repository/SHA/workflow-role/count allowlist row.
- [ ] Mutable, arbitrary, swapped, duplicate, missing, and extra action
      fixtures fail offline.
- [ ] Dependabot has exactly one review-only GitHub Actions entry for `/`.
- [ ] No new writer, candidate download, helper, approval job, secret, or
      external action is activated.
- [ ] The exact working/staged path gates contain only the five affected files.
- [ ] The pull request records the exact merge commit consumed by T1A.

## Non-goals

- Candidate ZIP parsing or extraction.
- Caller temporary-root ownership.
- Permanent helper harness implementation.
- Artifact download/promotion or writer redesign.
- Package or lockfile upgrades.
- Declaring the final contributor Node minimum.
- Changing hook or lint semantics.
- Hand-editing generated outputs.

## References

- [Node.js release status](https://nodejs.org/en/about/previous-releases)
- [setup-node](https://github.com/actions/setup-node)
- [GitHub secure use reference](https://docs.github.com/en/actions/reference/security/secure-use)
- [Git attributes](https://git-scm.com/docs/gitattributes)
- [git add](https://git-scm.com/docs/git-add)
- [PowerShell about character encoding](https://learn.microsoft.com/powershell/module/microsoft.powershell.core/about/about_character_encoding)
- [Dependabot options](https://docs.github.com/en/code-security/reference/supply-chain-security/dependabot-options-reference)
