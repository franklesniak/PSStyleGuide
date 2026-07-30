# Prompt 02 primary-source research record

Research date: 2026-07-29.

This record retains the source identity, operative facts, and design
implications used while evaluating the open PSStyleGuide findings. It
paraphrases rather than quotes the sources so later issue editing does not
depend on retrieving the pages again.

## GitHub issue dependency and merge identities

### GitHub CLI `gh issue create`

- Source: <https://cli.github.com/manual/gh_issue_create>
- Current documented interface: `gh issue create --blocked-by <numbers>` marks
  the newly created issue as blocked by the supplied issue numbers or URLs.
- Implication: a successor can be created with its predecessor dependency in
  the creation operation. The successor URL/number does not exist until that
  operation returns, so retrieval and verification necessarily occur
  afterward.

### GitHub CLI issue retrieval

- Source: <https://cli.github.com/manual/gh_issue_view>
- Current JSON fields include `url`, `blockedBy`, and `blocking`.
- Implication: post-create verification can retrieve the canonical issue URL
  and confirm the dependency relation without scraping rendered HTML.

### GitHub REST issue-dependency API

- Source:
  <https://docs.github.com/en/rest/issues/issue-dependencies?apiVersion=2022-11-28>
- The API exposes list/add/remove operations for an issue's `blocked_by`
  dependencies. Listing requires read access for private repositories; adding
  requires issue write access. The add operation identifies the blocking issue
  by database ID and returns `201` on creation.
- Implication: dependency verification is a distinct, testable postcondition.
  The issue descriptions should not pretend it can be proved before the
  successor exists.

### GitHub pull-request merge methods

- Source: <https://docs.github.com/en/pull-requests/reference/pull-request-merges>
- Merge-commit, squash, and rebase methods produce different base-branch
  histories. Squash creates one new base commit. GitHub rebase updates
  committer information and creates new commit SHAs.
- Implication: a reviewed PR head SHA is not a reliable synonym for the landed
  base-branch commit or commit set. Handoffs must retain both identities, the
  merge method, reachability evidence, and post-merge rerun evidence when the
  landed tree identity was not itself the reviewed head.

## File replacement and durability boundaries

### .NET `File.WriteAllText`

- Source:
  <https://learn.microsoft.com/en-us/dotnet/api/system.io.file.writealltext?view=net-9.0>
- Microsoft documents that an existing target is truncated and overwritten.
- Implication: a write or process failure after truncation can destroy the
  complete old tracked artifact; direct `WriteAllText(destination, ...)` is not
  an acceptable recoverability contract.

### .NET `File.Replace`

- Source:
  <https://learn.microsoft.com/en-us/dotnet/api/system.io.file.replace?view=net-9.0>
- The API replaces one file with another and can create a backup of the
  replaced file. Source and destination must share a volume; a null backup
  explicitly requests no backup.
- Implication: a same-directory prepared file plus a distinct backup improves
  recoverability. The .NET page does not promise that every exceptional return
  leaves the destination at the old bytes.

### Windows `ReplaceFileW`

- Source:
  <https://learn.microsoft.com/en-us/windows/win32/api/winbase/nf-winbase-replacefilew>
- Microsoft documents multiple partial failure states. Without a backup, one
  failure can leave the replaced path absent; another can move the replaced
  file under a different name. Supplying a backup gives the documented old
  file a known name in the latter state. The documented write-through flag is
  unsupported.
- Implication: do not claim universal atomic old-or-new behavior from
  `File.Replace(temp, destination, $null)`. Use a backup, inspect all expected
  paths after any exception, preserve evidence when state is uncertain, and
  document that abrupt host/storage failure remains outside a four-file atomic
  transaction.

### .NET `FileStream.Flush(Boolean)`

- Source:
  <https://learn.microsoft.com/en-us/dotnet/api/system.io.filestream.flush?view=netframework-4.8.1>
- `Flush(true)` clears managed and intermediate file buffers and requests that
  buffered data be written to disk. It can throw an I/O exception.
- Implication: fully write, flush-to-disk, close, reread, and hash the prepared
  same-directory candidate before attempting replacement.

## P1 YAML parser and lockfile producer

### npm registry `yaml@2.9.0`

- Sources: <https://registry.npmjs.org/yaml/2.9.0> and
  <https://registry.npmjs.org/yaml/latest>
- Retrieved 2026-07-29. Both the requested record and `latest` identify
  `2.9.0`. Declared Node engine: `>= 14.6`. Distribution integrity:
  `sha512-2AvhNX3mb8zd6Zy7INTtSpl1F15HW6Wnqj0srWlkKLcpYl/gMIMJiyuGq2KeI2YFxUPjdlB+3Lc10seMLtL4cA==`.
  Tarball:
  `https://registry.npmjs.org/yaml/-/yaml-2.9.0.tgz`.
- Implication: P1 can name and lock this reviewed parser exactly, then
  re-resolve `latest`, metadata, tarball, and integrity at its two freeze gates.

### Official Node distribution index

- Source: <https://nodejs.org/dist/index.json>
- Retrieved 2026-07-29. The newest Node 24 record is `v24.18.1`, dated
  2026-07-28, LTS codename `Krypton`, marked as a security release, and bundled
  with npm `11.16.0`.
- Implication: P1's proposed workflow/runtime and one lockfile producer can be
  frozen as exact Node `24.18.1` plus npm `11.16.0`, subject to re-resolution.
  P3 later owns the intentional transition to npm 12 and the long-term finite
  Node policy.

### npm registry `npm@11.16.0`

- Source: <https://registry.npmjs.org/npm/11.16.0>
- Retrieved 2026-07-29. Version `11.16.0`; Node engine
  `^20.17.0 || >=22.9.0`; distribution integrity
  `sha512-A74XL8OxmcegZDMWPkWb5bEQppg8HdYwW3rBD2sPoS4UQHVajfaxBkqyzLeJ3wR0kZ+5xoTjItxXaF7eIXUsyw==`;
  tarball `https://registry.npmjs.org/npm/-/npm-11.16.0.tgz`.
- Implication: the exact bundled npm is compatible with Node `24.18.1` and can
  be recorded as P1's lock producer without prematurely importing P3's npm 12
  governance change.

## P1 pinned action manifests

### `actions/checkout`

- Source:
  <https://raw.githubusercontent.com/actions/checkout/3d3c42e5aac5ba805825da76410c181273ba90b1/action.yml>
- Retrieved raw bytes 2026-07-29: 5,144 bytes; SHA-256
  `d59219cb79590abdb877deaa14e3b65a00c05318bf5a6f3b989b9162b5d08c35`.
- Consequential defaults include repository = `github.repository`, token =
  `github.token`, SSH strict checking = true, SSH user = `git`,
  persisted credentials = true, clean = true, fetch depth = 1, fetch tags =
  false, progress = true, LFS = false, submodules = false, safe-directory
  mutation = true, and unsafe PR checkout = false. Filter and sparse checkout
  default to null.
- Implication: pinning the action without authoring `persist-credentials` and
  code-selection/subresource controls is insufficient. A closed disposition
  record must also acknowledge the token and global safe-directory defaults.

### `actions/setup-node`

- Source:
  <https://raw.githubusercontent.com/actions/setup-node/820762786026740c76f36085b0efc47a31fe5020/action.yml>
- Retrieved raw bytes 2026-07-29: 2,991 bytes; SHA-256
  `5d765941ab5d8bef27f08e81b0b041cdb2df2050ea0261dc925d157a2bafbd2b`.
- Defaults include `check-latest: false`, a conditional `github.token`, and
  `package-manager-cache: true`. Node version/file, architecture, registry,
  scope, cache, cache dependency path, mirror, and mirror token have no
  manifest default.
- Implication: P1 must explicitly name the exact Node patch, disable automatic
  package-manager caching, and either author or consciously classify token,
  architecture, registry, cache, and mirror behavior.

## PowerShell raw parameter boundaries

### PowerShell type conversion

- Source:
  <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_type_conversion?view=powershell-7.6>
- PowerShell variables are not type-constrained by default. Parameter binding
  attempts conversion when a parameter declares a type; an untyped or
  `[object]` parameter accepts the supplied value type. Arrays can be converted
  to strings, including joining elements with the output-field separator in
  applicable binding/cast contexts. Advanced functions reject some array-to-
  scalar bindings, but relying on version/context-specific binding rejection is
  not a closed untrusted-input classifier.
- Implication: P1A's public adversarial boundary must receive raw objects,
  classify null/scalar/collection/type before any `[string]`, numeric, boolean,
  path, or enum conversion, and only then construct private strongly typed
  values.

### Advanced parameter binding

- Source:
  <https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_functions_advanced_parameters?view=powershell-7.6>
- Microsoft documents implicit conversion of supplied values to declared
  parameter types and notes that `[object]`/scriptblock parameters behave
  differently from typed delay-bound pipeline input.
- Implication: P1A should disable positional/pipeline/property binding for
  security-sensitive scalar parameters and test direct, splatted, and explicit
  wrapper objects on Windows PowerShell 5.1 and current PowerShell.

## P1B artifact action manifests

### `actions/upload-artifact`

- Source:
  <https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml>
- Retrieved raw bytes 2026-07-29: 3,603 bytes; SHA-256
  `c5979822866a72362e609844b6ebe77d4b7e759af68cc1c2c425dcf51481fab4`.
- Inputs/defaults: name defaults to `artifact`; path is required; missing-file
  behavior defaults to `warn`; retention has no manifest default (`0` means
  repository default according to its description); compression defaults to
  string `6`; overwrite defaults to string `false`; hidden files default to
  string `false`; archive defaults to string `true`. `archive: false` permits
  only one file.
- Implication: the four-file candidate must use `archive: true`. Candidate
  retention and compression must be authored rather than inherited; a one-day
  candidate is enough for same-run consumers, while bounded failure
  diagnostics may retain seven days.

### `actions/download-artifact`

- Source:
  <https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml>
- Retrieved raw bytes 2026-07-29: 2,635 bytes; SHA-256
  `e98559b7a31ba31be4709f20d22102dc2737fa630f69a339eb89981151e505fe`.
- Inputs/defaults: selection by name, IDs, or pattern; path has no manifest
  default but defaults operationally to workspace; `merge-multiple` defaults
  to string `false`; repository defaults to `github.repository`; run ID
  defaults to `github.run_id`; `skip-decompress` defaults to string `false`;
  digest mismatch defaults to string `error`; cross-run/repository API access
  can use `github-token`.
- Implication: same-run consumers should author immutable `artifact-ids`, a
  protected exact path, `skip-decompress: true`, and
  `digest-mismatch: error`; name/pattern/cross-run token/repository/run inputs
  remain absent and explicitly classified.

## GitHub Actions token lifecycle and wording

### `GITHUB_TOKEN`

- Source: <https://docs.github.com/en/actions/concepts/security/github_token>
- GitHub creates a unique installation access token at the start of each job;
  it is also available through `github.token` and expires when the job ends (or
  at its effective lifetime limit).
- Implication: a write-capable writer job possesses a token before the script
  constructs a push header. The honest claim is that credentials are not
  persisted and no derived push credential is projected into Git/process state
  until the exact push—not that no credential exists.

### Job permissions and secret redaction

- Sources:
  <https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax#jobsjob_idpermissions>
  and
  <https://docs.github.com/en/actions/reference/security/secrets>
- Job-level permissions can narrow the installation token; `permissions: {}`
  disables all listed permissions. GitHub automatically redacts several secret
  forms, but transformed values and arbitrary derived data are not universally
  guaranteed to be redacted.
- Implication: P1B should minimize job grants structurally, never print or
  transform the token for evidence, apply explicit masking to any unavoidable
  derived value, and scan only bounded test sentinels—not claim that platform
  redaction proves absence.

## P3 Node, Corepack, and npm identities

### Official Node distribution records

- Source: <https://nodejs.org/dist/index.json>
- Retrieved 2026-07-29. Latest eligible LTS patches are Node `22.23.2`
  (`Jod`, security release, bundled npm `10.9.8`) and Node `24.18.1`
  (`Krypton`, security release, bundled npm `11.16.0`).
- Node tag source records:
  <https://raw.githubusercontent.com/nodejs/node/v22.23.2/deps/corepack/package.json>
  identifies bundled Corepack `0.34.6`; and
  <https://raw.githubusercontent.com/nodejs/node/v24.18.1/deps/corepack/package.json>
  identifies bundled Corepack `0.35.0`.
- Implication: the runtime cells can use the exact Corepack shipped in each
  exact official Node distribution and record both identities. Node
  `24.18.1`/Corepack `0.35.0` is the sole lock producer; Node
  `22.23.2`/Corepack `0.34.6` is a compatibility verifier.

### npm `12.0.2`

- Source: <https://registry.npmjs.org/npm/12.0.2>
- Retrieved 2026-07-29. Exact engine:
  `^22.22.2 || ^24.15.0 || >=26.0.0`; distribution integrity
  `sha512-uIXokLlBj6FpNUTQX1PmT5pz7BlIN9QlixX+zdaSNHsd0qUXsbDLr50xzY6Sw7cJVr0uzHKDOle0swmPW/p5Qw==`;
  tarball `https://registry.npmjs.org/npm/-/npm-12.0.2.tgz`.
- Independently downloaded tarball: 3,045,132 bytes; SHA-224
  `4c4977784242293bf5a4f80d28aab2d001ba8a7a4532285591a158aa`; SHA-512
  `b885e890b9418fa1693544d05f53e64f9a73ec194837d4258b15fecdd692347b1dd2a517b1b0cbaf9d31cd8e92c3b70956bd2ecc72833a57b4b3098f5bfa7943`.
- Implication: set `packageManager` to
  `npm@12.0.2+sha224.4c4977784242293bf5a4f80d28aab2d001ba8a7a4532285591a158aa`
  and use only explicit `corepack npm` invocations.

### Corepack descriptor/integrity behavior

- Source: <https://github.com/nodejs/corepack>
- Corepack documents exact `packageManager@version+sha224.hash` descriptors and
  recommends the hash; explicit `corepack npm` honors project manager checks.
  Its environment controls can disable project-spec or integrity enforcement.
- Registry source for current Corepack:
  <https://registry.npmjs.org/corepack/0.35.0>. Retrieved integrity
  `sha512-9BuIGHDFE7Zieor1CeRsvt7X7AJFEuJ6OnbSbsVprq83ChDFoBh1wP98NeUS9FT3ZwlzFllPElXcz/OiDf0YGw==`;
  tarball SHA-224
  `e4ca373e0092222e8d39d8b20dacd13b4ccc38d4523bd73a0f516d6f`.
- Implication: P3 must record the Node-bundled Corepack version/source for each
  cell, enforce strict project-spec/integrity settings, and reject weakening
  ambient variables.

## Husky installation and npm lifecycle behavior

### Husky installation controls

- Source: <https://typicode.github.io/husky/how-to.html>
- Husky's official guidance uses the npm `prepare` lifecycle for installation,
  documents `HUSKY=0` as the explicit way to disable installation in CI/Docker,
  and shows a production-install helper that skips when
  `NODE_ENV=production` or `CI=true`.
- The same guidance shows that a repository whose package is in a subdirectory
  must deliberately change to the repository root before invoking Husky.
- Implication: the P3 installer must make skip reasons observable, distinguish
  an explicit `HUSKY=0` policy from an accidentally ambient CI value, derive
  its repository root from its own location, and never accept a caller-selected
  root.

### npm `prepare`

- Source: <https://docs.npmjs.com/cli/using-npm/scripts/>
- npm runs `prepare` during local install/CI lifecycle sequences and before
  package packing. Lifecycle scripts run from the package root, but their
  environment and current-directory assumptions still need an explicit
  project contract.
- Implication: P3 must test the direct installer and the real `prepare`
  lifecycle, specify how clean CI/production installs opt out, and avoid an
  error-swallowing `prepare` command that could report success without a
  usable hook installation.

## Raw npm-audit process and JSON boundary

### Native process outcome and byte limits

- Source: <https://nodejs.org/api/child_process.html>
- Node's child-process API distinguishes start errors, exit codes, signals,
  timeouts, and stream-close completion. It supports a fixed `cwd`, a supplied
  environment, `shell: false`, hidden Windows windows, timeouts, and byte
  buffers; exceeding `maxBuffer` terminates the process and can truncate
  output.
- Implication: the P3 audit boundary must own process launch, classify every
  native outcome before interpreting the report, and enforce independent raw
  byte limits for stdout/stderr rather than accept a shell-decoded object.

### UTF-8 and JSON duplicate-member behavior

- Sources: <https://nodejs.org/api/util.html>,
  <https://datatracker.ietf.org/doc/rfc8259/>, and
  <https://tc39.es/ecma262/multipage/structured-data.html>
- Node's WHATWG `TextDecoder` supports fatal UTF-8 decoding. RFC 8259 requires
  UTF-8 for interoperable JSON and says generators must not add a BOM.
  ECMAScript `JSON.parse` accepts duplicate object names and overwrites earlier
  values.
- Implication: P3 should reject a BOM, malformed UTF-8, duplicate member names,
  non-object roots, trailing/additional JSON values, and resource-limit
  breaches before schema validation. `JSON.parse` alone cannot prove duplicate
  name absence, so a small dependency-free lexical scanner must retain each
  object's decoded member-name set before the final parse.

### `npm audit` report and exit semantics

- Sources: <https://docs.npmjs.com/cli/v12/commands/npm-audit/> and
  <https://docs.npmjs.com/cli/v12/using-npm/config/>
- `npm audit --json` requests a JSON report; `--package-lock-only` bases the
  operation on the lockfile. Exit zero means no vulnerabilities at the
  configured threshold, while a vulnerability result may exit nonzero. The
  configured `audit-level` changes only the failure threshold, not which
  findings appear in the report.
- Implication: the P3 validator must cross-check a closed exit-code/report
  matrix rather than treat every nonzero result as tool failure or trust exit
  code in place of schema and policy evaluation.

## Live GitHub issue evidence for vulnerability exceptions

### Issue identity and state

- Source: <https://docs.github.com/en/rest/issues/issues>
- The `GET /repos/{owner}/{repo}/issues/{number}` representation includes
  immutable numeric/node identity, repository URLs, issue number, state,
  labels, assignees, and timestamps. The Issues API can also return pull
  requests, which are distinguishable by a `pull_request` member.
- Implication: an exception reference is not validated merely because its URL
  parses. The live checker must bind the expected repository/number/node ID,
  require an open non-PR issue, and verify the required ownership and policy
  label from an allowlisted response projection.

### Authentication, rate limiting, and scheduled reads

- Sources:
  <https://docs.github.com/en/actions/concepts/security/github_token>,
  <https://docs.github.com/en/rest/using-the-rest-api/rate-limits-for-the-rest-api>,
  and
  <https://docs.github.com/en/rest/using-the-rest-api/best-practices-for-using-the-rest-api>
- GitHub provides a per-job installation token; authenticated REST requests
  have explicit repository-scoped rate limits. GitHub recommends conditional
  requests for polling and exposes rate-limit/retry response headers.
- Implication: P3 should separate deterministic offline exception-record
  checks from an `issues: read` scheduled/manual live verifier, use a bounded
  request/retry policy, and fail closed on unavailable/stale live evidence
  rather than make every untrusted pull request depend on external API state.

## Ambient Corepack/npm configuration

### Corepack environment controls

- Source: <https://github.com/nodejs/corepack/blob/main/README.md>
- Corepack documents environment controls for strict project-manager checking,
  project-spec enforcement, environment-file loading, default-to-latest
  lookups, network access, cache home, npm registry, credentials, custom URLs,
  and integrity keys. In particular, `COREPACK_ENABLE_STRICT=0`,
  `COREPACK_ENABLE_PROJECT_SPEC=0`, or empty/zero `COREPACK_INTEGRITY_KEYS`
  weaken the selected descriptor/integrity boundary.
- Implication: P3 must not inherit arbitrary `COREPACK_*` controls. Its wrapper
  builds a closed child environment, enables project-spec/strict behavior,
  disables `.corepack.env` and default-to-latest/unsafe URL behavior, uses a
  job-owned cache, and rejects credential-bearing Corepack variables.

### npm configuration precedence and clean install

- Sources: <https://docs.npmjs.com/cli/v12/using-npm/config/>,
  <https://docs.npmjs.com/cli/v12/configuring-npm/npmrc/>, and
  <https://docs.npmjs.com/cli/v12/commands/npm-ci/>
- npm accepts case-insensitive `npm_config_*` environment variables and reads
  built-in, global, user, and project configuration with defined precedence.
  `npm ci` is lockfile-frozen, but dependency-tree-affecting flags must match
  lock creation; `--ignore-scripts` suppresses package lifecycle scripts, and
  explicit include/omit/workspace controls change the installed surface.
- Implication: P3 should clear inherited `npm_config_*`, redirect user/global
  configuration to fixed empty job-owned files, validate the tracked project
  `.npmrc`, and put all tree/audit/security-relevant settings explicitly in
  the wrapper's fixed argument vector. Proxy/CA transport can be separately
  allowlisted without allowing registry credentials or policy overrides.

## Current GitHub-hosted runner labels

- Source: <https://github.com/actions/runner-images>
- Retrieved 2026-07-29. The official available-image table lists
  `ubuntu-24.04` and `windows-2025` as x64 GitHub Actions labels; it also
  explains that version-specific labels avoid an automatic `*-latest`
  migration but are eventually deprecated.
- Implication: the proposed P3 OS×Node dependency matrix can use those two
  explicit labels now, while both freeze gates must verify continued
  availability and record the actual image version. A future retirement
  requires a reviewed matrix change rather than an implicit latest-image
  transition.
