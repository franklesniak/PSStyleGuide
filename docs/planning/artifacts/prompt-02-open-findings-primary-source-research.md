# Primary-source research for PSStyleGuide open-finding decisions

Research date: 2026-07-29.

This artifact supports
`docs/planning/artifacts/current-findings-evaluation.md`. It preserves the
facts used to select remedies for the open findings in
`docs/planning/artifacts/current-findings.md`. Facts are paraphrased; links
identify the original authority.

## GitHub reusable-workflow topology

Source:
<https://docs.github.com/en/actions/how-tos/reuse-automations/reuse-workflows>

- A reusable workflow declares `on.workflow_call`.
- A caller invokes it at job level with
  `uses: ./.github/workflows/{filename}`.
- The repository-local syntax without an `@ref` uses the same commit as the
  caller.
- The caller can put the call job in the same downstream `needs` graph.

Decision impact:

- `build.yml` should be the only external event owner after P1B.
- `markdownlint.yml` should expose only its reviewed local
  `workflow_call` interface.
- Approval can then require the call job in its exact dependency set.

## Job dependencies and matrix outputs

Source:
<https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax>

- `jobs.<job_id>.needs` names jobs that must complete before the dependent job
  runs.
- Matrix job execution order is not guaranteed.
- Reusing one output name lets the last finishing matrix child overwrite the
  value.
- GitHub's documented safe pattern uses distinct output names.

Decision impact:

- Four canonical matrix cells need four statically named outputs.
- A structural validator should prove the cell-to-output mapping.
- Approval should reject absent/empty output keys, duplicate embedded cell
  identities, and any record that disagrees with preparation.

## Scheduled workflow behavior

Source:
<https://docs.github.com/en/actions/reference/workflows-and-actions/events-that-trigger-workflows#schedule>

- Scheduled workflows run only from the default branch.
- They run the latest default-branch commit.
- Cron schedules are UTC unless a supported timezone is explicitly supplied.

Decision impact:

- P3 needs one read-only UTC schedule so exception expiry is evaluated even
  without repository changes.
- The schedule/manual event subgraph should call only local dependency and
  Markdown validation plus a read-only terminal result.

## GitHub token and checkout behavior

Sources:

- <https://docs.github.com/en/actions/reference/security/secure-use>
- <https://docs.github.com/en/actions/tutorials/authenticate-with-github_token>
- <https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml>

- GitHub recommends minimum token permissions and permits increasing them for
  an individual job.
- Actions can access `github.token` even when workflow YAML does not pass a
  `GITHUB_TOKEN` environment variable.
- The exact pinned checkout manifest defaults `token` to `github.token`.
- The manifest describes configuring that token for fetch and removing it in
  the post-job step.
- `persist-credentials` is a separate input; setting it to false prevents
  retained credential configuration but does not make fetch credential-free.

Decision impact:

- P1 and P1B must acknowledge that the write-capable token exists for the
  complete minimal writer job.
- The pinned checkout may use it transiently for fetch and must remove stored
  state.
- Repository scripts should receive no ordinary token variable.
- Only the exact push child process should receive the masked token-derived
  HTTP header, with cleanup in `finally`.

## Immutable action references and manifest review

Source:
<https://docs.github.com/en/actions/reference/security/secure-use>

- GitHub identifies a full-length action commit SHA as the only immutable
  action reference form.
- Reviewers should verify the SHA belongs to the intended repository and
  inspect how the action handles repository content and credentials.

Decision impact:

- Role tables should distinguish explicit YAML input keys from action defaults
  recorded at the pinned manifest.
- Release tags should be re-resolved before implementation and again before
  merge; a moved tag requires renewed review rather than silent substitution.

## NUL-safe Git pathname handling

Sources:

- <https://git-scm.com/docs/git-status#_pathname_format_notes_and_z>
- <https://git-scm.com/docs/git-diff>

- Without `-z`, unusual pathnames may be C-style quoted.
- With `-z`, pathnames are unquoted and NUL-terminated; rename/copy records
  have two NUL-separated names.
- `git diff --exit-code` returns 0 for equality and 1 for an ordinary
  difference; other nonzero values are command failures.

Decision impact:

- Exact changed/staged path gates must capture raw native stdout and parse NUL
  records, not line-oriented porcelain.
- Using `--no-renames` plus NUL-delimited unstaged, cached, and untracked
  sources makes both sides of a rename visible.
- Because the approved PSStyleGuide paths are ASCII, a verifier can compare
  each raw pathname record to the exact expected ASCII bytes and reject every
  unrecognized byte sequence without lossy decoding.

## GitHub issue dependencies

Source:
<https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-issue-dependencies>

- GitHub supports explicit blocked-by and blocking issue relationships.
- The relationship requires the real filed issues and appropriate repository
  permission.

Decision impact:

- Draft bodies can define an atomic filing protocol but cannot contain a real
  predecessor URL before that predecessor exists.
- Each successor should receive its predecessor URL/dependency at filing and
  its exact predecessor merge commit at implementation start.

## Node and npm policy

Sources:

- <https://nodejs.org/en/about/previous-releases>
- <https://docs.npmjs.com/cli/v11/configuring-npm/package-json/#engines>
- <https://docs.npmjs.com/cli/v11/commands/npm-ci/>

- On the research date, Node 22 and 24 are LTS lines; 23 and 25 are EOL and 26
  is Current.
- Node's future cadence means “even major” is not a durable LTS rule.
- `engines` accepts finite semver unions, but npm normally treats it as
  advisory unless strict engine enforcement is enabled.
- `npm ci` requires manifest/lock agreement and does not rewrite them.

Decision impact:

- P3 should choose a finite reviewed Node union with explicit patch floors.
- One dependency-free policy module should serve the hook, staged linter, and
  fixtures.
- One exact npm CLI should run clean installs, audit, and lints in all cells;
  non-producer cells should prove the lockfile is unchanged.

## npm audit behavior

Source: <https://docs.npmjs.com/cli/v11/commands/npm-audit/>

- Audit reports are derived from registry advisory data and the dependency
  graph.
- Exit behavior depends on findings and policy; registry/tool failures must
  remain distinguishable.
- npm does not publish an immutable complete contract for every JSON response
  field.

Repository observation retained in
`prompt-02-current-findings-primary-source-research.md`:

- npm 11 report version 2 was observed with package-keyed vulnerability
  properties, object and string `via` values, package-keyed `nodes`, metadata
  totals, and Boolean/object `fixAvailable`.

Decision impact:

- A pure validator should validate every consumed field for the selected
  report version, receive an injected UTC instant, and run deterministic
  fixtures without the registry.
- Integration orchestration should separately invoke the exact npm, preserve
  raw evidence, and classify native/tool failures.
- Residual approval identity should be `(Package, AdvisoryUrl)` with exact
  package-keyed node paths, an accountable owner, a real public issue, and
  exclusive expiry no later than 30×24 hours.

## PowerShell unresolved destination paths

Source:
<https://learn.microsoft.com/dotnet/api/system.management.automation.pathintrinsics.getunresolvedproviderpathfrompspath>

- The unresolved-provider-path API can resolve a path even when its leaf does
  not exist.
- Its overload can return `ProviderInfo` and `PSDriveInfo`.

Decision impact:

- The generator's final-write helper should reject wildcard/relative/multiple
  inputs, require FileSystem provider metadata, resolve one absolute
  destination, and use that same value for validation and the final write.
