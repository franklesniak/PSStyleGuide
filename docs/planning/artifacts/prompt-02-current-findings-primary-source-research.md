# Primary-source research for current-findings evaluation

Research date: 2026-07-29.

This record supports
`docs/planning/artifacts/current-findings-evaluation.md`. Quotations are
paraphrased so the decisions do not depend on retaining copied source text.

## C-01 — GitHub Actions role and pin validation

### GitHub Actions workflow syntax

Source:
<https://docs.github.com/en/actions/reference/workflows-and-actions/workflow-syntax>

Relevant facts:

- A workflow is YAML and contains jobs; each job contains its own ordered
  steps.
- Step `id` values provide stable identifiers used through the `steps`
  context.
- An action `uses` reference belongs to a particular job step, so a
  workflow-wide repository count cannot establish the role in which it runs.

Decision impact:

- P1 should identify external actions by workflow, job ID, stable step ID, and
  action repository.
- GitHub remains the workflow syntax/execution authority. A local policy
  verifier should fail on workflow forms it cannot classify rather than
  pretending a line-only scan is a complete YAML parse.

### GitHub secure-use reference

Source:
<https://docs.github.com/en/actions/reference/security/secure-use>

Relevant facts:

- Pinning an action to a full-length commit SHA is the only immutable action
  reference form.
- GitHub recommends reviewing action source and using least privilege because a
  compromised action can access repository data, credentials, or workflow
  secrets available to its job.

Decision impact:

- The exact role table must retain P1's full-SHA validation.
- Placement and security-relevant inputs matter in addition to repository/SHA;
  an allowed action in an unintended job is not equivalent to the intended
  role.

## C-02 and I-P3-02 — Node runtime support

### npm `package.json` engines

Source:
<https://docs.npmjs.com/cli/v11/configuring-npm/package-json/#engines>

Relevant facts:

- `engines.node` accepts a semver range, including bounded and disjunctive
  ranges.
- For dependency installation, `engines` is advisory unless npm's
  `engine-strict` configuration is enabled.

Decision impact:

- A successful default `npm ci` does not prove that every dependency declares
  compatibility with the active Node runtime; it may only have emitted
  warnings.
- P3 runtime cells must run clean installation with `engine-strict=true` and
  without `--force`, in addition to executing the actual lint behavior.
- “Highest minimum major” is insufficient for an arbitrary semver range. The
  implementation must inspect the full constraint intersection and prove that
  each named runtime is admitted.

### npm `engine-strict` configuration

Source:
<https://docs.npmjs.com/cli/v11/using-npm/config/#engine-strict>

Relevant facts:

- `engine-strict` defaults to false.
- When true, npm refuses to install a package that declares incompatibility
  with the current Node version.
- `--force` can override this protection.

Decision impact:

- P3 should explicitly set and restore `npm_config_engine_strict=true` around
  each clean install and prohibit `--force`.

### npm clean installation

Source: <https://docs.npmjs.com/cli/v11/commands/npm-ci/>

Relevant facts:

- `npm ci` requires manifest/lockfile agreement.
- It removes an existing `node_modules` before installation.
- It does not rewrite the manifest or lockfile.

Decision impact:

- An independent `npm ci` in each named runtime cell provides a clean,
  lockfile-frozen behavioral test.

### Node.js release status

Sources:

- <https://nodejs.org/en/about/previous-releases>
- <https://nodejs.org/en/about/eol>

Relevant facts on 2026-07-29:

- Node 22 and Node 24 are LTS release lines.
- Node 20 and Node 23 are EOL.
- Node's guidance warns that EOL lines no longer receive security fixes and can
  create toolchain and compliance risks.

Decision impact:

- P3 should validate the selected supported LTS minimum and retained hosted
  Node 24, not describe every integer major between them as supported.
- Synthetic guard rejection can cover a below-minimum value without executing
  EOL Node 20.

## C-03 — Residual approval identity and governance

### npm `explain`

Source: <https://docs.npmjs.com/cli/v11/commands/npm-explain/>

Relevant facts:

- `npm explain <package>` prints the dependency chains that caused matching
  installed packages to be present.
- A package name can match more than one installed instance.
- npm accepts an exact folder under `node_modules` when the reviewer needs to
  explain one duplicated instance.

Decision impact:

- A package-wide explain chain is useful context but is not an audit-native
  advisory identity.
- P3 should not accept any one package-wide explain path as proof that all
  audit-reported installed nodes are dispositioned.

### npm `audit`

Source: <https://docs.npmjs.com/cli/v11/commands/npm-audit/>

Relevant facts:

- npm calculates vulnerability and meta-vulnerability objects from registry
  advisory data and the dependency tree.
- Exit behavior depends on `audit-level`; exit 0 means no vulnerability at the
  configured failure condition.
- The public command documentation does not define a permanent complete JSON
  response schema.

Decision impact:

- The raw response and exact npm version must be preserved.
- Approval identity should use fields directly present together in the
  reviewed response: package property plus object advisory URL.
- Node paths and explain chains should remain separately described evidence.

### GitHub REST issue endpoint

Source:
<https://docs.github.com/en/rest/issues/issues#get-an-issue>

Relevant facts:

- Public issue resources can be queried without authentication.
- GitHub's Issues API can also return pull requests; the `pull_request` key
  distinguishes them.

Decision impact:

- A follow-up URL regex proves syntax only.
- Automated or manual evidence must establish the exact PSStyleGuide
  repository, successful public retrieval, and absence of the `pull_request`
  marker.
- Owner acceptance remains a human governance fact rather than something a
  nonempty string or issue lookup proves.

### .NET exact date parsing

Source:
<https://learn.microsoft.com/dotnet/api/system.datetimeoffset.tryparseexact>

Relevant facts:

- `DateTimeOffset.TryParseExact` accepts an explicit format, culture, and
  `DateTimeStyles`.
- It returns failure rather than throwing for a nonmatching value.

Decision impact:

- Residual expiry should use one invariant UTC format and explicit styles,
  instead of culture-sensitive `TryParse` plus a trailing-`Z` check.

## C-04 and I-P3-01 — Audit metadata and graph consistency

### Live npm audit schema observation

Command run on 2026-07-29:

```text
npm --prefix .github/workflows audit --package-lock-only --json
```

Observation environment:

- Node 26.5.0;
- npm 11.7.0; and
- audit exit 1.

Observed response:

- `auditReportVersion` is 2.
- There are seven `vulnerabilities` properties and metadata total is seven.
- Property severity counts are five high and two moderate.
- The seven properties contain fourteen object advisories.
- Two string `via` links are present.
- Seven audit node paths are present.
- `fixAvailable` occurs as both Boolean and object forms.
- `js-yaml -> markdownlint-cli2` and
  `markdown-it -> markdownlint-cli2` `effects` edges each have the reciprocal
  string `via` link in this response.

Validator replay:

- The copyable P3 graph-validation segment was run read-only against this live
  response after drafting.
- It reconciled seven vulnerability properties, fourteen object advisories,
  fourteen moderate/high/critical advisory records, two string `via` links,
  two `effects` links, seven audit-node records, seven lockfile-resolved nodes,
  and explain context for all seven affected packages.
- A separate synthetic clean report-version-2 response with zero counts and an
  empty vulnerability object also passed the graph and empty-set paths.
- The first replay exposed npm's finite cycle representation: a nested
  `npm explain --json` node can omit `dependents`. The draft validator now
  treats an absent/null `dependents` property as a leaf, requires an array when
  the property is present, and rejects a malformed dependent/root object.

Decision impact:

- Vulnerability-property counts and object-advisory counts are different units.
- P3 can validate reciprocity for the selected, recorded schema, but should
  identify a changed schema rather than assume that relationship forever.
- The schema observation under Node 26 is not P3 runtime evidence. P3 must
  repeat and preserve its final raw response under the selected Node/npm
  environment.

### npm audit documentation boundary

Source: <https://docs.npmjs.com/cli/v11/commands/npm-audit/>

Relevant facts:

- npm documents audit calculation, exit behavior, and registry endpoints.
- It does not publish a complete immutable contract for every field in the
  human-facing JSON response.

Decision impact:

- P3 should validate every field it consumes and the recorded report version.
- Additive unknown fields can be retained in raw evidence; missing or changed
  consumed shapes must fail with a schema diagnostic.

## C-05 — Durable issue relationships and evidence

### GitHub issue dependencies

Source:
<https://docs.github.com/en/issues/tracking-your-work-with-issues/using-issues/creating-issue-dependencies>

Relevant facts:

- GitHub supports explicit “blocked by” and “blocking” issue relationships.
- A user needs at least triage permission to create the relationship.
- GitHub CLI can create or edit dependencies using issue numbers or URLs.

Decision impact:

- P2 should be recorded as blocked by P1 and P3 as blocked by P2 after the
  actual issues exist.
- Plain body prose is useful context but does not replace the GitHub
  relationship.

### GitHub permanent file links

Source:
<https://docs.github.com/en/repositories/working-with-files/using-files/getting-permanent-links-to-files>

Relevant facts:

- A branch URL shows mutable branch-head content.
- Replacing the branch component with an exact commit ID permanently identifies
  the viewed file version.

Decision impact:

- Historical research evidence should use a commit permalink, not a mutable
  branch or a planning-file-relative link.
- Direct primary-source links can replace a planning artifact when retaining
  the artifact adds no review value.
