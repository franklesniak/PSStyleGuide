# Evaluation of unresolved PSStyleGuide issue-slate findings

## Scope and method

This working decision record covers every unresolved PSStyleGuide finding in
`docs/planning/artifacts/current-findings.md`. It includes findings marked
**Valid, open** or **Valid, partially addressed** and each explicitly recorded
independent concern. `C-CROSS-09` is excluded because the exact five H1 titles
are already proved and require no remedy.

Primary-source facts are retained in
[prompt-02-open-findings-primary-source-research.md](prompt-02-open-findings-primary-source-research.md).
The TerraformStyleGuide issue bodies are used as semantic convergence
references, not as a second revision target.

Each finding is completed before the next begins:

1. enumerate materially distinct options and useful permutations;
2. define a finding-specific weighted rubric;
3. score each option from 1 (poor) to 5 (excellent);
4. calculate the weighted result out of 100; and
5. select an implementation-ready remedy.

Technical correctness, security, fail-closed behavior, and contributor
usability receive the dominant weights. Churn, implementation effort, and
preservation of an earlier draft boundary are considered but deliberately
receive less weight, as required by the prompt.

## Evaluation order

1. `C-SLATE-01` — authorize the npm-advisory execution order.
2. `C-P1-01` — correct the failure-upload path.
3. `C-P1-02` — make the checkout credential statement true.
4. `C-P1-03` — define structural workflow validation available in P1.
5. `C-P1-04` — add the advisory-order decision consumed by P1.
6. `C-P1-05` — remove successor-only facts from P1 acceptance.
7. `C-P1-06` — separate explicit action inputs from reviewed defaults.
8. `I-P1-01` — specify P1's temporary-branch writer proof.
9. `C-P1A-01` — replace grouped ranges with one row per stable ID.
10. `C-P1A-02` — give every stable ID an exact oracle.
11. `C-P1A-03` — define the context schema and disposed state.
12. `C-P1A-04` — close the skip/applicability contract.
13. `I-P1A-01` — remove successor work from P1A acceptance.
14. `C-P1B-01` — put Markdown validation in the same job graph.
15. `C-P1B-02` — export four path-bound preparation hashes.
16. `C-P1B-03` — add permanent structural workflow-policy enforcement.
17. `C-P1B-04` — correct P1B's checkout/push credential boundary.
18. `C-P1B-05` — specify P1B's temporary-branch proof mechanism.
19. `C-P1B-06` — mechanically validate unique matrix-output mapping.
20. `I-P1B-01` — remove successor work from P1B acceptance.
21. `C-P2-01` — update stale P1B pull-request expectations.
22. `C-P2-02` — use NUL-delimited Git path-set checks.
23. `C-P2-03` — classify `git diff --exit-code`.
24. `C-P2-04` — machine-check the unchanged Compliant example.
25. `C-P2-05` — consume rather than restate P1B.
26. `I-P2-01` — use one pathname encoding for every P2 proof.
27. `C-P3-01` — add continuous read-only audit execution.
28. `C-P3-02` — define an exact exception lifetime.
29. `C-P3-03` — add deterministic audit-policy oracles.
30. `C-P3-04` — separate the pure audit validator from orchestration.
31. `C-P3-05` — use one tracked Node-policy decision.
32. `C-P3-06` — consume the P1B workflow validator/parser.
33. `C-P3-07` — reconcile package order with current advisories.
34. `I-P3-01` — specify exact NUL-safe P3 path validation.
35. `C-CROSS-01` — instantiate URLs/dependencies during filing.
36. `C-CROSS-02` — keep predecessor evidence in successors.
37. `C-CROSS-03` — give counterpart stable IDs one meaning.
38. `C-CROSS-04` — retain one external event owner.
39. `C-CROSS-05` — retain one workflow-policy validator.
40. `C-CROSS-06` — use explicit-key/default terminology consistently.
41. `C-CROSS-07` — re-resolve action tags twice.
42. `C-CROSS-08` — reuse one NUL-safe affected-file gate.

## `C-SLATE-01` — Authorize the npm-advisory execution order

### Options

**Option A — Preserve the sequence without a formal decision.** Work
P1→P1A→P1B→P2→P3 and treat P3's dated audit paragraph as sufficient notice.
This is simple but leaves the owner, permissible waiting period, and authority
to accept five high findings undefined.

**Option B — Move P3 before all generator work.** Remediate packages first,
then rebaseline every later issue. This minimizes advisory dwell time but
invalidates the user-required sequence and forces P1/P1B policy work to target
a package/workflow baseline that has not yet been designed.

**Option C — Add a dated, accountable P1 start gate with a fail-closed
rebaseline branch.** Before P1 editing, record the exact audit command, Node
and npm versions, raw evidence location, severities, decision owner,
authorizing policy, decision time, maximum waiting period through P3, and
compensating controls. If the owner or policy does not permit the wait, stop
and regenerate the slate with dependency remediation moved earlier.

**Option D — Add a minimal emergency advisory issue before P1, then keep full
P3 later.** This hybrid reduces exposure while reserving policy design for P3,
but creates two package migrations, two lockfile baselines, and a new issue
outside the mandated order. It is appropriate only if the risk gate refuses
Option C and a compatible narrow fix is independently proved.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Accountable risk governance | 30 | A security wait must be owned, time-bounded, and policy-authorized. |
| Vulnerability exposure control | 30 | The choice must either remediate or explicitly constrain the exposure window. |
| Sequential-plan integrity | 20 | Downstream issues assume the specified P1→P3 baseline order. |
| Cold-start implementer clarity | 15 | A new implementer must know whether to proceed or stop without improvising policy. |
| Planning churn | 5 | Rebaselining has real cost, but cost cannot outweigh security governance. |

Scores use 1–5; weighted totals are out of 100.

| Option | Governance | Exposure | Sequence | Clarity | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 1 | 5 | 2 | 5 | 43 |
| B | 3 | 5 | 1 | 3 | 2 | 63 |
| C | 5 | 4 | 5 | 5 | 4 | **93** |
| D | 4 | 5 | 2 | 4 | 2 | 76 |

### Selected option

Select **Option C**, with Option D retained only as the explicit failure branch.
P1 must begin with a section titled `Advisory-risk execution gate`. It must
require a repository owner or named policy authority to sign a dated record
containing the exact audit invocation/runtime, raw result identity, current
severity/package inventory, reason P1–P2 may proceed, compensating controls,
and a deadline no later than completion of P3. P3 must consume that record and
rerun the audit rather than copying its old counts.

If the record is absent, expired, materially contradicted by a new audit, or
not authorized by governing policy, implementation stops. The implementer
must then rebaseline the issue graph—normally by introducing the smallest
compatible package-remediation issue before P1—rather than silently updating
packages or accepting risk personally.

## `C-P1-01` — Correct the failure-upload path

### Options

**Option A — Upload the four generated destinations directly.** Replace the
incorrect “Affected files” reference with the four generated filenames. This
is precise when all outputs exist, but the most useful failure modes may occur
before one or more files are written.

**Option B — Upload one generated diagnostic summary only.** A failure step
creates a bounded, redacted text/JSON summary under `RUNNER_TEMP`; the upload
role names only that exact file. It is reliable and safe but omits candidate
bytes that can distinguish serialization defects.

**Option C — Remove artifact upload and rely on workflow logs.** This has the
least code and storage cost, but logs are less structured, may be truncated,
and do not preserve byte-level evidence for offline comparison.

**Option D — Upload one exact diagnostic directory containing a mandatory
summary plus bounded copies of safe candidate outputs.** On ordinary failure,
a `failure_diagnostics` step creates a fresh exact directory under
`RUNNER_TEMP`, writes a redacted manifest with phase/native exits/path-relative
names/sizes/hashes, and copies each generated output only if it is an ordinary
non-reparse file under the reviewed size ceiling. It never copies source,
environment, Git config, tokens, or arbitrary logs. Upload names the directory
through the step's static output.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Diagnostic value for byte-generation failures | 30 | Evidence should explain content and serialization defects, not merely report failure. |
| Secret/path safety and boundedness | 25 | Failure handling must not become an exfiltration or storage channel. |
| Exact action-role enforceability | 20 | The role validator needs one unambiguous producer and path contract. |
| Reliability when generation stops early | 15 | Diagnostics must still exist when outputs are partial or absent. |
| Implementation and maintenance burden | 10 | Simpler failure code is preferable once correctness and safety are satisfied. |

| Option | Value | Safety | Enforceability | Early failure | Burden | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 3 | 4 | 5 | 2 | 5 | 74 |
| B | 4 | 5 | 5 | 5 | 3 | 90 |
| C | 2 | 4 | 5 | 3 | 5 | 71 |
| D | 5 | 5 | 5 | 5 | 3 | **96** |

### Selected option

Select **Option D**. P1 must define the diagnostic producer before the upload
role table:

- create a collision-free, job-owned directory under `RUNNER_TEMP`;
- always create one UTF-8, BOM-less, LF-only summary on ordinary failure;
- include only stable phase names, captured exit codes, repository-relative
  approved paths, sizes, and SHA-256 values;
- copy any available generated destination only after ordinary-file,
  non-reparse, containment, and size checks;
- cap each copy and the total diagnostic directory;
- reject or record, rather than follow, links and unexpected paths;
- emit the exact directory through
  `steps.failure_diagnostics.outputs.diagnostic_path`; and
- upload that path with a collision-free run/attempt name, seven-day
  retention, `if-no-files-found: error`, and `continue-on-error: true`.

The action table must no longer derive upload paths from `Affected files`.
Negative evidence must cover a missing candidate, an oversized candidate, a
link substitution, a primary-plus-diagnostic failure, and a token sentinel
that appears nowhere in the directory or uploaded archive.

## `C-P1-02` — Make the checkout credential statement true

### Options

**Option A — State and test the pinned checkout's transient authentication.**
Accept that GitHub creates a write-capable token for the complete minimal
writer job and that pinned checkout may use it for fetch. Require
`persist-credentials: false`, prove no credential/helper/header state remains
after checkout, expose no ordinary token variable to repository scripts, and
materialize a masked derived header only in the exact push child process.

**Option B — Acquire repository bytes without checkout authentication.** Use a
reviewed anonymous `git fetch` or archive download for the public repository,
verify the expected commit, and reserve the token entirely for push. This can
make “push-only materialization” literally true but creates a bespoke
acquisition path and may not reproduce checkout behavior, submodule/LFS
defaults, or future repository privacy.

**Option C — Keep the job token read-only and add a separate write credential
for push.** A GitHub App installation token or tightly scoped secret is
released only to the push step. This provides a stronger capability boundary
but adds credential issuance, rotation, availability, and governance that the
repository does not otherwise need.

**Option D — Keep the existing wording and infer safety from
`persist-credentials: false`.** This is minimal but factually contradicts the
pinned manifest's token default and fetch behavior.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Truthfulness against the pinned action | 30 | A security invariant must describe what actually happens. |
| Least-privilege exposure | 25 | The writer credential should be usable in as little workflow code as practical. |
| Checkout/publication reliability | 20 | The mechanism must work predictably on protected main pushes. |
| New secret and governance burden | 15 | Additional long-lived or minted credentials expand operational risk. |
| Strength of negative verification | 10 | The boundary must be demonstrable in logs, Git state, files, and process arguments. |

| Option | Truth | Least privilege | Reliability | Secret burden | Verification | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 4 | 5 | 5 | 5 | **95** |
| B | 5 | 5 | 3 | 5 | 3 | 88 |
| C | 5 | 5 | 4 | 2 | 4 | 85 |
| D | 1 | 2 | 5 | 5 | 1 | 53 |

### Selected option

Select **Option A**. P1 must use this exact conceptual boundary:

1. GitHub creates the write-capable job token for the complete temporary
   writer job.
2. The exact pinned checkout action may transiently configure that token to
   fetch the expected commit.
3. `persist-credentials: false` and checkout cleanup remove retained
   authentication; an explicit post-checkout inspection proves no credential
   helper, `http.*.extraheader`, token-bearing remote URL, or token variable is
   available to later repository code.
4. Generator, validator, and Git identity/preflight code receive no ordinary
   token environment variable.
5. The exact push step masks the token, keeps xtrace off, constructs one
   process-scoped environment-backed HTTP header, passes it only to the one
   full-lease/refspec `git push`, and removes every temporary value in
   `finally`.

The issue must stop saying the token is never materialized before push.
Negative drills should use a sentinel credential in a test-owned workflow copy
and prove its absence from logs, artifacts, files, remotes, persistent Git
configuration, and captured command records.

## `C-P1-03` — Define structural workflow validation available in P1

### Options

**Option A — Use an untracked one-off parser during review.** Name an exact
parser/version and retain command output plus fixtures in PR evidence. P1B
would later add the permanent validator. This preserves P1's file boundary but
leaves main without enforcement and makes reproduction depend on ephemeral
review tooling.

**Option B — Add the tracked validator and locked parser in P1, then extend it
in P1B.** P1 introduces `Validate-WorkflowPolicy.mjs`, a reviewed direct YAML
dependency, and lockfile changes. It enforces P1's temporary topology and role
table; P1B atomically updates the same validator to the final graph.

**Option C — Remove P1's structural claims and defer them to P1B.** P1 would
use YAML parse smoke tests and manual review only. This avoids new package
scope but permits role, input, permission, or condition drift in the temporary
writer.

**Option D — Implement a dependency-free custom YAML subset parser.** A small
parser could avoid package changes, but YAML anchors, duplicate keys, tags,
implicit types, and expression-bearing scalars make a security-quality custom
parser more difficult to validate than a locked reviewed dependency.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Structural policy correctness | 30 | P1 changes a write-capable workflow and needs semantic, not textual, enforcement. |
| Deterministic offline reproducibility | 25 | Merge protection must not depend on registry/network state or an individual's setup. |
| Enforcement continuity into P1B/P3 | 20 | One evolving validator prevents gaps and conflicting policy implementations. |
| Reviewer comprehensibility and fixtures | 15 | Contributors need clear failures and testable positive/negative policy examples. |
| Added scope and dependency churn | 10 | New files/packages matter, but are subordinate to correct writer enforcement. |

| Option | Correctness | Offline | Continuity | Reviewability | Scope | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 3 | 2 | 2 | 3 | 5 | 55 |
| B | 5 | 5 | 5 | 5 | 2 | **94** |
| C | 1 | 5 | 2 | 2 | 5 | 55 |
| D | 3 | 5 | 4 | 2 | 3 | 71 |

### Selected option

Select **Option B** despite its larger P1 scope. P1 must add:

- `.github/workflows/Validate-WorkflowPolicy.mjs`;
- a reviewed direct YAML parser declaration in
  `.github/workflows/package.json`; and
- the regenerated `.github/workflows/package-lock.json`.

The validator must be deterministic and offline after `npm ci`, use a
reviewed safe/core schema, reject duplicate keys, aliases, custom tags,
unrecognized node shapes, and dynamic external action references, and report
stable policy IDs. P1 fixtures must prove exact events, permissions, job/step
IDs, conditions, explicit action input keys, reviewed defaults metadata, sole
writer, and the temporary writer predicate. Negative fixtures operate on
test-owned YAML copies.

P1B must update this same file and dependency—not introduce another
validator—to enforce the local callable workflow, preparation hashes, matrix
mapping, approval, and final writer. P3 must retain and rerun it while changing
the package graph. P1's advisory-risk gate must explicitly authorize adding
the reviewed parser to the pre-P3 package baseline.

## `C-P1-04` — Add the advisory-order decision consumed by P1

### Options

**Option A — Refer only to the slate-level decision.** P1 says the order was
approved elsewhere. This avoids duplication but gives an implementer no
immutable evidence or freshness check at P1 start.

**Option B — Make the slate decision an explicit P1 dependency and start
gate.** P1 records the decision identity, owner, timestamps, exact audit
evidence, maximum lifetime, and a same-day recheck. P3 later consumes the same
identity and final audit.

**Option C — Let P3 document the wait retroactively.** P1–P2 proceed and P3
explains why. This cannot authorize an exposure period that has already
elapsed.

**Option D — Create a separate risk-register file committed by P1.** This is
durable and machine-readable but adds a permanent repository governance format
for a one-slate decision and risks treating source control as the approving
authority.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Binding evidence at P1 start | 30 | The implementer must prove authorization before touching the dependency-bearing workflows. |
| Freshness against the current audit | 25 | A decision based on stale package/advisory state is not sufficient. |
| Fail-closed execution behavior | 25 | Missing, expired, or contradicted approval must stop work. |
| Governance duplication risk | 10 | Multiple competing records could obscure the actual authority. |
| Repository-scope economy | 10 | A new permanent format should exist only if it provides durable value. |

| Option | Binding | Freshness | Fail closed | Duplication | Economy | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 2 | 2 | 5 | 5 | 52 |
| B | 5 | 5 | 5 | 4 | 5 | **98** |
| C | 1 | 1 | 1 | 4 | 5 | 34 |
| D | 5 | 4 | 4 | 3 | 2 | 80 |

### Selected option

Select **Option B**. P1's Dependencies/Start gate must require one immutable
decision record in the filed P1 issue, linked pull-request evidence, or another
repository-governed system of record. The issue text must enumerate the fields
so an empty “risk accepted” statement cannot pass:

- approving person/role and authorizing policy;
- UTC decision and expiry times;
- exact Node/npm executable paths and versions;
- exact audit command, native exit, report version, raw-evidence digest, and
  observed advisory inventory;
- reason generator/writer hardening should precede remediation;
- compensating controls and prohibited package changes;
- maximum authorized milestone (completion of P3); and
- explicit stop/rebaseline instruction.

At P1 start, rerun the audit with the recorded npm. If package graph, severity,
or advisory identities materially worsen, require renewed approval. P1
acceptance proves that the decision was valid through merge; P3 acceptance
proves that the authorized wait ended in remediation or exact governed
exceptions.

## `C-P1-05` — Remove successor-only facts from P1 acceptance

### Options

**Option A — Keep “P1A records P1's merge commit” in P1 acceptance.** This
expresses the desired chain but makes P1 impossible to close until future work
has started.

**Option B — Move the fact to P1A's dependency/start gate.** P1 acceptance
retains only evidence available by P1 merge; P1A cannot start until it records
P1's issue URL, blocked-by relationship, exact merge commit, and retained run
evidence.

**Option C — Require a two-sided handoff checklist in both issues.** P1 records
an evidence package and P1A records receipt. This is auditable, but only the P1
half can be a P1 acceptance criterion; treating both halves as current closure
recreates the defect.

**Option D — Use a parent tracking issue to own every handoff.** A project
manager can verify the sequence centrally, but a new coordination issue does
not remove the need for successor-local prerequisite evidence.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Current-issue closability | 35 | Acceptance must be provable when P1 is ready to merge. |
| Immutable predecessor traceability | 25 | P1A still needs the exact implementation baseline it consumes. |
| Responsibility clarity | 20 | The issue capable of performing the action should own it. |
| Fit with GitHub dependency workflow | 10 | Filed relationships and successor start gates should reinforce each other. |
| Editing churn | 10 | Moving one checklist item should remain straightforward. |

| Option | Closability | Traceability | Responsibility | GitHub fit | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 3 | 1 | 2 | 5 | 40 |
| B | 5 | 5 | 5 | 5 | 5 | **100** |
| C | 3 | 5 | 3 | 4 | 3 | 72 |
| D | 4 | 4 | 3 | 3 | 2 | 70 |

### Selected option

Select **Option B**. Delete “P1A records P1's exact merge commit” from P1
acceptance. P1 should instead produce a handoff package containing its issue
URL, reviewed head/merge commit when available, action provenance, validator
version, generator evidence, temporary-writer evidence, and reciprocal
P1↔T1 matrix.

P1A's Dependencies section must require that exact package before editing and
record P1 as the real blocked-by predecessor. P1A acceptance may prove that it
consumed P1's merge commit because that fact exists during P1A, but P1 must
remain independently closable at its own merge.

## `C-P1-06` — Separate explicit action inputs from reviewed defaults

### Options

**Option A — Explicitly declare every action input.** Copy every manifest
default into workflow YAML. This appears complete but creates noise, may expose
security-sensitive expressions such as tokens, and still cannot prevent the
action implementation from having non-input defaults.

**Option B — Maintain two exact contracts.** For every role, record the exact
YAML-declared input key/value set and a separate reviewed-default table derived
from the pinned `action.yml`. The validator rejects extra/missing explicit keys
and fails review when security-relevant manifest defaults differ from the
record.

**Option C — Validate only explicit YAML inputs and pin the action SHA.** Trust
the immutable manifest without documenting its defaults. This is reproducible
but leaves reviewers unable to see that checkout receives the default token,
clean behavior, and fetch depth.

**Option D — Vendor every action implementation.** Repository-local code can
eliminate external input-default drift, but it creates a large maintenance and
supply-chain patch burden far beyond the role-table finding.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Semantic accuracy of the policy model | 30 | Declared keys and action-resolved defaults are different facts. |
| Detectability of security-relevant drift | 25 | Review must notice changed token/cache/clean/extraction behavior. |
| Least-privilege readability | 20 | Reviewers need to understand effective credential and filesystem behavior. |
| Long-term maintainability | 15 | Dependabot/action updates should have an obvious atomic review path. |
| Implementation effort | 10 | Validator and metadata work should remain proportionate. |

| Option | Accuracy | Drift detection | Readability | Maintainability | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 3 | 2 | 2 | 2 | 45 |
| B | 5 | 5 | 5 | 5 | 4 | **98** |
| C | 3 | 2 | 2 | 4 | 5 | 58 |
| D | 5 | 5 | 4 | 1 | 1 | 76 |

### Selected option

Select **Option B**. Replace “Complete inputs” with **Exact explicitly
declared inputs** in every action role table. Adjacent to the role table,
record for each pinned action:

- the exact `action.yml` URL at the full SHA and its content digest;
- every manifest input name and default shape;
- the subset of defaults that affect credentials, checkout mutation,
  artifact selection/extraction, caching, retention, overwrite, or failure;
- the reviewed effective value for this role; and
- whether the value is explicit in YAML or inherited from the manifest.

The workflow-policy validator must reject an extra/missing/wrong explicit key,
but it must not pretend an omitted key does not exist. A fixture with a changed
test manifest default must force a review diagnostic. Immediately before
implementation and again before merge, re-fetch the exact pinned manifest and
prove its digest/default contract still matches the reviewed record.

## `I-P1-01` — Specify P1's temporary-branch writer proof

### Options

**Option A — Use a uniquely named temporary evidence workflow.** Commit an
evidence-only workflow on a unique temporary branch. It reproduces the
production temporary writer's exact steps but authorizes only that exact
temporary ref. Retain run/commit evidence, then remove the workflow and prove
its absence before the P1 production commit.

**Option B — Add a permanent `workflow_dispatch` target-ref input.** The same
workflow can write a temporary branch when manually dispatched. This improves
repeatability but permanently broadens the writer interface and adds a
high-risk input parser to production.

**Option C — Prove the writer in a disposable fork/test repository.** This
protects the real remote but does not exercise this repository's permissions,
branch protection, token behavior, or exact origin.

**Option D — Hand-edit the production predicate for one run.** This is quick
but produces evidence for a workflow version that is not the version merged,
and it is easy to forget or incompletely revert.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Production predicate integrity | 30 | Evidence must not leave a broad alternate write path in the final workflow. |
| Fidelity to real repository/token/lease behavior | 25 | The proof must exercise the actual origin and protected workflow semantics. |
| Verifiable cleanup and absence | 25 | Temporary authorization must be mechanically gone before merge. |
| Operator repeatability | 10 | Reviewers need an exact sequence rather than an improvised edit. |
| Temporary churn | 10 | Extra evidence commits are acceptable but should remain bounded. |

| Option | Integrity | Fidelity | Cleanup | Repeatability | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 2 | **94** |
| B | 2 | 5 | 2 | 5 | 5 | 67 |
| C | 5 | 2 | 5 | 3 | 3 | 77 |
| D | 1 | 4 | 1 | 1 | 5 | 43 |

### Selected option

Select **Option A**. P1 must name an exact evidence workflow path such as
`.github/workflows/evidence-p1-temporary-writer.yml` and require:

1. a collision-resistant temporary branch/ref recorded before creation;
2. a workflow copy whose only write predicate is ordinal equality with that
   exact ref and whose writer algorithm/action SHAs match the proposed
   production workflow;
3. positive changed/no-change runs plus stale-preflight, lost-lease,
   unrelated-ref, unexpected-path, and token-sentinel negatives;
4. immutable run URLs/IDs, workflow commit, expected/actual remote IDs, and
   validator output;
5. deletion of the evidence workflow and branch after retained evidence; and
6. final policy/path-set checks proving the evidence path is absent from the
   production commit and no alternate event/predicate remains.

The evidence workflow may not be merged to `main`, and the production
predicate is never hand-edited to permit a temporary branch.

## `C-P1A-01` — Replace grouped ranges with one row per stable ID

### Options

**Option A — Expand only the existing PS grouped ranges.** Split `M-01..14`,
`E-01..10`, and similar entries into rows without changing the current
inventory. This improves traceability but preserves missing cases and the
cross-repository `K-03` collision.

**Option B — Port the current Terraform T1A shared catalog row-by-row, then
apply manifest-specific PS values.** Shared digest/path/archive/context/
cleanup/resource/label cases retain one semantic ID; only the exact four
filenames and truly PS-only behavior differ.

**Option C — Put the oracle inventory only in a machine-readable fixture
manifest.** A JSON/YAML catalog can drive the harness and eliminate prose/code
drift, but an issue reviewer still needs a human-readable row for each ID and
adding another tracked format increases P1A's public contract.

**Option D — Keep grouped prose and require the implemented harness to list
individual IDs.** This postpones decisions to implementation and prevents the
issue from being an executable specification.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Complete security-case coverage | 35 | Missing digest/path/resource/cleanup cases create real fail-open risk. |
| Stable P/T semantic alignment | 25 | Counterpart IDs must communicate one behavior to parallel implementers. |
| Human reviewability | 20 | Every fixture and expected phase/state should be visible before coding. |
| Harness/catalog maintainability | 10 | The chosen representation should resist later inventory drift. |
| Issue and implementation churn | 10 | A large table costs effort but is justified only when it adds actual coverage. |

| Option | Coverage | Alignment | Reviewability | Maintainability | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 3 | 2 | 5 | 4 | 4 | 67 |
| B | 5 | 5 | 5 | 4 | 2 | **92** |
| C | 5 | 4 | 2 | 5 | 2 | 77 |
| D | 2 | 1 | 2 | 2 | 5 | 41 |

### Selected option

Select **Option B**, while allowing the harness to represent the same rows as
data internally. P1A's issue table must contain one row per stable ID with no
range notation. Start from current Terraform T1A's shared meanings and include
at least:

- `V-01..02`, `P-01..02`, `D-01..05`, `Z-01`;
- `M-01..14`, `E-01..15`, `L-01..04`, `B-01..02`;
- `R-01..13`, `W-01..05`, `S-01..11`;
- `K-01..04`, `C-01..08`; and
- `X-01..10`.

Retain a PS-only `H-*` ID only if its behavior is not already represented by
the aligned `S-*` script-identity cases; otherwise remove the duplicate.
`K-03` must mean repeated candidate cleanup after safe removal, matching T1A.
The former “caller unknown child” behavior moves to the aligned `C-03` caller
context case.

Machine-readable result validation must reject a missing, duplicated,
unexpected, or multiply emitted ID. Any future repository-specific ID requires
a reciprocal-matrix row stating why a shared semantic ID is not appropriate.

## `C-P1A-02` — Give every stable ID an exact oracle

### Options

**Option A — Add only an expected phase to each row.** This distinguishes
parameter/digest/archive/manifest/extraction failures but does not state
candidate state, cleanup ownership, sentinel preservation, or applicable
runtime.

**Option B — Use one complete oracle schema for every row.** Each row binds the
fixture/invocation, OS/edition applicability, expected status and phase,
pre-teardown candidate/caller state, cleanup owner/result, required diagnostic
fields, and outside-sentinel state.

**Option C — Compare complete golden diagnostic text.** Exact snapshots are
easy to automate but become brittle across path/runtime wording and can reward
matching text while filesystem postconditions are wrong.

**Option D — Replace row oracles with property/fuzz testing.** Generative
testing is valuable for extra coverage but cannot substitute for named
regression cases and deterministic acceptance evidence across three runtimes.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Fail-closed outcome precision | 30 | Each malformed input must fail at the intended boundary, not merely somewhere. |
| Filesystem/context postcondition proof | 25 | Cleanup errors can delete unrelated state or conceal uncertain state. |
| Resource and platform boundary exactness | 20 | Inclusive limits and OS-specific path behavior need byte/runtime-specific expectations. |
| Diagnostic usefulness without brittleness | 15 | Operators need stable fields while paths/messages may vary safely. |
| Specification authoring burden | 10 | A complete table is expensive, but ambiguity is more expensive during security review. |

| Option | Precision | State proof | Boundaries | Diagnostics | Burden | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 3 | 1 | 2 | 3 | 4 | 48 |
| B | 5 | 5 | 5 | 5 | 3 | **96** |
| C | 3 | 2 | 3 | 2 | 3 | 52 |
| D | 3 | 3 | 4 | 2 | 2 | 59 |

### Selected option

Select **Option B**. The P1A table must use these columns for every individual
ID:

1. stable ID;
2. exact fixture and invocation/bound parameters;
3. expected Windows PowerShell 5.1, Windows PowerShell 7, and Ubuntu
   PowerShell 7 applicability;
4. expected `pass`, `fail`, or narrowly authorized `skip`;
5. exact failure phase or success result;
6. candidate/archive/download/context state before harness teardown;
7. candidate cleanup and caller-context cleanup owner/result;
8. required structured diagnostic keys/label values; and
9. outside-sentinel and source-repository postcondition.

Resource rows must give literal byte values at below/exact/above 8 MiB and
32 MiB boundaries and say whether the limit is inclusive. Path rows must state
ordinal versus ordinal-ignore-case behavior. A native nonzero result or
exception message alone never satisfies an oracle. The harness's final
machine-readable summary must prove actual status/phase/state equals the row
and that totals equal the closed inventory.

## `C-P1A-03` — Define the context schema and disposed state

### Options

**Option A — Use a typed/versioned mutable context with explicit lifecycle
states.** Creation returns one validated object with exact scalar/collection
fields, ordered ownership entries, and `Active` state. Successful complete
cleanup transitions that same object to `Disposed`; repeated cleanup is a
validated no-op only in that state.

**Option B — Keep all state in a module-private registry keyed by a random
handle.** Callers receive an opaque ID. This resists field tampering but makes
cleanup dependent on process-local registry lifetime and complicates
cross-script/runspace testing.

**Option C — Make cleanup strictly single-use and reject every repeat call.**
This is simpler but conflicts with defensive `finally` layering, where a
second cleanup call after proved success should be harmless.

**Option D — Infer disposal when paths are missing.** This is convenient but a
missing path can mean prior cleanup, external mutation, a race, or incomplete
ownership; it cannot prove authorized disposal.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Ownership authenticity and tamper detection | 30 | Cleanup must operate only on paths created and journaled by this invocation. |
| Deletion safety under failure/repetition | 30 | The primary risk is recursive or uncertain deletion of caller/unrelated state. |
| Deterministic lifecycle semantics | 20 | Active, failed, and disposed contexts must have unambiguous transitions. |
| Caller and test usability | 10 | P1B will use the API from multiple jobs/runtimes and nested `finally` paths. |
| Implementation complexity | 10 | State machinery should remain reviewable in PowerShell 5.1. |

| Option | Ownership | Safety | Lifecycle | Usability | Complexity | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 3 | **96** |
| B | 5 | 5 | 4 | 2 | 2 | 84 |
| C | 4 | 3 | 4 | 2 | 5 | 72 |
| D | 1 | 1 | 2 | 4 | 5 | 38 |

### Selected option

Select **Option A**. P1A must define an exact context schema including:

- fixed schema and script version strings;
- invocation ID and diagnostic label as nonempty scalars;
- normalized FileSystem parent, invocation root, download directory, and
  candidate path as scalar absolute paths;
- one ordered collection of ownership records, each with kind, normalized
  path, parent relationship, creation phase, and expected ordinary type;
- lifecycle state from the closed set `Active`, `CleanupFailed`, `Disposed`;
  and
- captured cleanup diagnostics without secret/environment content.

Creation validates the parent, creates/journals one component at a time, and
returns `Active` only after its invariants hold. Removal validates the complete
schema and each parent/child relationship before deletion, deletes journaled
ordinary entries nonrecursively in reverse order, never follows reparse/link
state, and transitions to `Disposed` only after complete proved cleanup.

A second removal succeeds as a no-op only for the same valid `Disposed`
context and only after proving no journaled owned entry has reappeared.
`Active` with missing/unexpected entries or any substitution becomes
`CleanupFailed`, retains uncertain state, and reports it. Arbitrary missing
paths never imply disposal. The aligned `C-*` and `K-*` rows must exercise
normal, repeated, partial, substituted, unknown-child, and
primary-plus-cleanup paths.

## `C-P1A-04` — Close the skip/applicability contract

### Options

**Option A — Prohibit all skips.** Every ID must execute everywhere. This is
maximally simple but can make a platform fail because a test-only link
primitive cannot be created even though the production rejection code is
otherwise covered.

**Option B — Keep the current “narrowly justified” skip prose.** A case names
its reason and is not counted as a pass. Without a closed expected matrix,
however, an implementer can reclassify missing coverage as inapplicable.

**Option C — Define a closed per-runtime applicability/status matrix.** Every
ID has an expected `pass`, `fail`, or specifically authorized
primitive-dependent `skip` for each runtime. Missing or unexpected skip/status
is failure; each OS family must execute real link/reparse rejection.

**Option D — Replace unsupported primitives with mocks.** Mocking can avoid
skips but does not exercise native filesystem link/reparse behavior and can
create false confidence at the security boundary.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Coverage-inventory integrity | 35 | No mandatory ID may disappear through an “inapplicable” label. |
| Cross-platform realism | 25 | Native link/path behavior differs and must be exercised where available. |
| Result transparency | 20 | Reviewers need exact expected and actual pass/fail/skip totals. |
| Resistance to false confidence | 15 | Mocks or permissive skips must not masquerade as production coverage. |
| Harness burden | 5 | Some matrix bookkeeping is acceptable for a security harness. |

| Option | Inventory | Realism | Transparency | Confidence | Burden | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 2 | 5 | 4 | 4 | 81 |
| B | 2 | 4 | 3 | 2 | 5 | 57 |
| C | 5 | 5 | 5 | 5 | 3 | **98** |
| D | 5 | 1 | 4 | 1 | 2 | 61 |

### Selected option

Select **Option C**. P1A must publish a closed runtime matrix covering:

- Windows PowerShell exactly 5.1 on Windows;
- PowerShell major 7 on Windows; and
- PowerShell major 7 on Ubuntu.

For every stable ID/runtime pair, the issue states expected execution and
result. Only a named closed list of link/reparse fixture-creation rows may
skip, and only when an exact prerequisite probe proves the primitive is
unavailable. A skip record must contain ID, runtime, primitive, probe output,
and reason; it never satisfies a row expected to execute.

The harness fails on an absent result, unexpected ID, duplicate result,
unexpected skip, status mismatch, or totals mismatch. It emits separate
expected/actual pass, fail, and skip counts. At least one real root/ancestor
link rejection, below-root link rejection, candidate-leaf substitution, and
caller-context substitution must execute on each OS family. If that minimum is
not achieved, the runtime cell fails even when individual skip records are
well formed.

## `I-P1A-01` — Remove successor work from P1A acceptance

### Options

**Option A — Retain “P1B records P1A's merge commit.”** This keeps the desired
handoff visible but makes P1A acceptance depend on future activity.

**Option B — Make exact P1A receipt a P1B prerequisite.** P1A produces a
versioned evidence package; P1B records its issue URL, blocked-by relationship,
merge commit, script versions, stable-ID results, and reciprocal comparison
before editing.

**Option C — Put a placeholder P1A commit field in the P1B draft.** The field
would be filled after merge, but placeholders can be copied into a filed issue
or mistaken for completed evidence.

**Option D — Leave P1A open until P1B starts.** This serializes the handoff but
distorts issue status and prevents P1A's independent implementation from being
closed and released.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Temporal provability at P1A merge | 40 | Every P1A acceptance item must be demonstrable before P1B exists. |
| P1B baseline assurance | 25 | The writer must consume exact helper/context/harness versions and evidence. |
| Ownership of the handoff action | 15 | P1B is the first issue able to record receipt. |
| Filing/issue-status clarity | 10 | GitHub status should reflect completed work rather than coordination latency. |
| Edit simplicity | 10 | The correction should not require new tracking infrastructure. |

| Option | Provability | Baseline | Ownership | Status clarity | Simplicity | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 3 | 1 | 2 | 5 | 40 |
| B | 5 | 5 | 5 | 5 | 5 | **100** |
| C | 4 | 4 | 3 | 2 | 4 | 73 |
| D | 2 | 5 | 2 | 1 | 3 | 55 |

### Selected option

Select **Option B**. Remove the future P1B action from P1A acceptance. P1A
must finish by publishing:

- exact P1 predecessor commit;
- helper, context-manager, and harness commit/blob identities and script
  versions;
- the closed oracle inventory and per-runtime results;
- retained positive/negative evidence and skip totals;
- final affected/staged path proof; and
- the P1A↔T1A reciprocal matrix.

P1B's Dependencies section must require and record those exact values before
workflow editing. This preserves the chain without making P1A wait for a
successor.

## `C-P1B-01` — Put Markdown validation in the same job graph

### Options

**Option A — Make `build.yml` the event owner and call
`markdownlint.yml` locally.** `markdownlint.yml` declares only
`workflow_call`; `build.yml` invokes
`./.github/workflows/markdownlint.yml` as a job, and approval includes that job
in its exact `needs` set.

**Option B — Keep independent triggers and correlate runs through
`workflow_run` or the API.** This creates a cross-run trust protocol, extra
permissions/races, and artifact/status correlation that P1B does not need.

**Option C — Copy all Markdown steps into `build.yml`.** This gives a same-run
job but duplicates the reusable validation definition and makes P3's scheduled
dependency-only execution harder to isolate.

**Option D — Let branch protection combine independent required checks.**
Branch protection can block merge but cannot supply Markdown's result to
P1B's fail-closed terminal approval or writer authorization.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Executable dependency semantics | 35 | Approval must consume a real job result in its own `needs` graph. |
| Same-commit code identity | 25 | Validation must use the exact workflow revision being proposed. |
| Least-privilege/read-only isolation | 15 | Markdown validation must never inherit writer authority. |
| Long-term topology maintainability | 15 | P3 needs to extend the validation graph without duplicating event owners. |
| Contributor check visibility | 10 | PR users need one coherent set of named jobs and failures. |

| Option | Dependency | Identity | Privilege | Maintainability | Visibility | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 5 | **100** |
| B | 2 | 3 | 2 | 1 | 2 | 42 |
| C | 5 | 5 | 4 | 2 | 4 | 86 |
| D | 1 | 4 | 4 | 3 | 4 | 56 |

### Selected option

Select **Option A**. P1B must:

1. make `.github/workflows/build.yml` the sole owner of `pull_request`, push
   to `main`, and any enabled `merge_group`;
2. remove those external events from `markdownlint.yml`;
3. declare the exact reviewed `on.workflow_call` interface with no secrets or
   write permissions;
4. add a stable `validate_markdown` call job using
   `./.github/workflows/markdownlint.yml`, which GitHub resolves from the same
   commit as the caller;
5. give the call job `contents: read` only; and
6. make terminal approval's exact `needs` set include preparation,
   `validate_markdown`, and the Windows matrix.

The structural validator must reject a second external event owner, remote or
dynamic reusable workflow reference, unexpected callable input/secret,
permission increase, missing call job, and any approval dependency-set
deviation.

## `C-P1B-02` — Export four path-bound preparation hashes

### Options

**Option A — Export four statically named path-bound SHA-256 outputs.**
Preparation computes each candidate file's hash once, emits four immutable job
outputs, binds them into each matrix attestation, approval, and writer.

**Option B — Let each consumer recompute hashes from the downloaded artifact.**
Consumers can agree with one another, but without preparation's values they
cannot prove that transport/attestation corresponds to the exact prepared
candidate.

**Option C — Export one hash of a canonical manifest containing path/hash
pairs.** This is cryptographically adequate if every consumer obtains and
parses the same manifest, but adds a fifth transported object or requires
embedding/escaping a structured output.

**Option D — Sign a provenance attestation for the four files.** A signed
statement strengthens provenance but requires identity/keyless-attestation
policy beyond this repository's threat model; it does not remove the need for
plain path/hash values in writer checks.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| End-to-end path/byte binding | 35 | Every stage must agree on which filename owns which exact bytes. |
| Availability across GitHub job boundaries | 25 | Values must survive runner isolation and be usable in `needs` outputs. |
| Substitution/mix-up detection | 20 | Swapped files, stale artifacts, and changed transport must fail. |
| Approval/debug readability | 10 | Operators should see stable field names rather than decode an opaque bundle. |
| Mechanism complexity | 10 | Cryptographic extras should be added only when they close a real gap. |

| Option | Binding | Availability | Detection | Readability | Complexity | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | **98** |
| B | 2 | 5 | 2 | 4 | 5 | 65 |
| C | 5 | 4 | 5 | 3 | 3 | 87 |
| D | 5 | 3 | 5 | 2 | 1 | 76 |

### Selected option

Select **Option A**. Preparation must emit exactly:

- `copilot_instructions_sha256`;
- `powershell_instructions_sha256`;
- `style_guide_chat_sha256`; and
- `style_guide_full_sha256`.

Each value is canonical lowercase 64-hex SHA-256 bound to its fixed
repository-relative path. Preparation computes them after all byte/resource
checks and before upload, then never recomputes or rereads those outputs.
Every matrix record includes all four named values; approval requires equality
among all four records and preparation; the writer receives only approval's
validated copy and compares downloaded, independently regenerated,
destination, staged, committed, and post-push blobs to those values.

Reject missing/extra/empty/noncanonical hashes, swapped field values,
duplicate path keys, and a record whose artifact ID/digest/event SHA/ref/
`has_changes` matches but any path hash differs.

## `C-P1B-03` — Add permanent structural workflow-policy enforcement

### Options

**Option A — Extend P1's tracked validator and locked parser atomically.**
P1B updates the same policy program, fixtures, manifest, and lockfile from the
temporary graph to the final event/call/matrix/approval/writer graph.

**Option B — Add a separate P1B-specific validator.** This preserves the P1
program but creates two authorities and ambiguous ownership after P1B.

**Option C — Adopt an external workflow linter/action only.** A general linter
can catch schema errors but does not know PSStyleGuide's exact permissions,
output mapping, hashes, writer predicate, roles, or explicit/default policy.

**Option D — Use required manual security review.** Expert review remains
valuable but is not deterministic enforcement and cannot protect future
Dependabot/workflow changes automatically.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Single-policy continuity | 30 | One authoritative program must survive P1→P1B→P3. |
| Coverage of repository-specific security graph | 30 | The validator must know exact events, needs, outputs, permissions, and writer roles. |
| Parser/schema fail-closed behavior | 20 | YAML ambiguity, duplicate keys, aliases, and unknown forms must not bypass policy. |
| Offline deterministic execution | 10 | CI and local review should not depend on a service or mutable action. |
| Migration churn | 10 | Atomic replacement is preferable to parallel validators once guarantees are equal. |

| Option | Continuity | Coverage | Parser safety | Offline | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | **98** |
| B | 1 | 5 | 5 | 5 | 2 | 70 |
| C | 2 | 2 | 3 | 2 | 4 | 48 |
| D | 1 | 3 | 2 | 1 | 5 | 44 |

### Selected option

Select **Option A**. Because the selected P1 remedy already adds the locked
parser and package graph, P1B's ordinary changed-file scope is `build.yml`,
`markdownlint.yml`, and the already tracked
`Validate-WorkflowPolicy.mjs`. It must prove `package.json` and
`package-lock.json` remain byte-identical to P1. If implementation evidence
shows the reviewed parser itself must change, stop, add both package files to a
recomputed scope, and rerun provenance/audit/install review; do not force a
meaningless lockfile rewrite. P1B upgrades the one validator—not adds a
second—to prove:

- sole event owner and same-commit local callable workflow;
- exact event set, permissions, jobs, conditions, and `needs`;
- exact action repositories/full SHAs/comments/explicit keys plus reviewed
  defaults;
- one preparation artifact and four path hashes;
- exact 2×2 Windows matrix and each cell's unique output mapping;
- fail-closed `always()` approval and complete dependency result set;
- sole write-enabled job and exact event/`has_changes` predicate;
- no remote reusable workflow, mutable action, cache, auto-extraction,
  credential persistence, or unreviewed role; and
- schedule/manual no-publication paths once P3 extends the graph.

Fixtures must cover every rejected mutation independently. P3 later updates
the locked package graph but must retain the same validator, parser semantics,
stable policy IDs, and negative suite.

## `C-P1B-04` — Correct P1B's checkout/push credential boundary

### Options

**Option A — Apply P1's honest transient-checkout contract to the final
writer.** The minimal writer job has `contents: write`; pinned checkout may use
the token transiently, cleanup is proved, repository validation is token-free,
and only the exact push process receives the derived header.

**Option B — Replace checkout with credential-free public acquisition.** This
can narrow explicit materialization but introduces a second acquisition
implementation precisely where the final writer needs the most dependable
at-use commit verification.

**Option C — Split acquisition/validation and push into separate jobs.** A
read-only job could pass a prepared commit/tree to a tiny write job. The write
job must nevertheless reacquire and revalidate untrusted cross-job data at
use, largely recreating P1B while increasing transport complexity.

**Option D — Keep claiming persistence-disabled checkout never materializes a
token.** This is contradicted by the pinned manifest and cannot be accepted as
a security invariant.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Factual credential-boundary accuracy | 35 | The final writer is the slate's highest-privilege component. |
| Credential blast-radius minimization | 25 | Token-derived state should reach the smallest practical code surface. |
| Compatibility with at-use revalidation | 20 | Writer correctness depends on exact checkout, helper, regeneration, and remote checks. |
| Secret/log/process hygiene | 15 | Derived credentials must not persist or appear in diagnostics. |
| Topology complexity | 5 | Additional jobs/transport add attack and failure modes. |

| Option | Accuracy | Blast radius | At-use proof | Hygiene | Complexity | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 4 | 5 | 5 | 4 | **94** |
| B | 5 | 5 | 3 | 5 | 2 | 89 |
| C | 5 | 5 | 3 | 4 | 1 | 85 |
| D | 1 | 2 | 5 | 2 | 5 | 48 |

### Selected option

Select **Option A** and make it textually identical to P1's enduring
credential model. P1B must additionally require the writer to perform
post-checkout credential-state inspection before helper execution and another
inspection in `finally` after push. The token-derived header is:

- registered for masking before derivation can appear in output;
- stored only in a push-step-scoped environment variable;
- expanded into `git -c http.<validated-origin>.extraheader=... push ...` or an
  equivalent child-process-only environment-backed configuration;
- absent from remote URLs, command strings assembled with interpolation,
  files, artifacts, outputs, and diagnostic paths; and
- cleared with all temporary Git configuration even when push fails.

The issue must distinguish token existence, checkout's reviewed transient use,
absence from repository scripts, and push-only explicit materialization.
Negative drills mutate test-local credentials, never production environment
values, and prove sentinel absence plus unchanged remote state.

## `C-P1B-05` — Specify P1B's temporary-branch proof mechanism

### Options

**Option A — Use a P1B-specific temporary evidence workflow and remove it.**
The evidence workflow reproduces the final graph/writer but authorizes one
recorded temporary ref. Its absence is part of final validation.

**Option B — Refactor the writer into a permanent reusable workflow with
production and evidence callers.** This avoids code copying and permits exact
temporary calls, but permanently exposes a callable write interface whose
input/secret/permission boundary is materially broader.

**Option C — Add a permanent manual branch override to production.** Easy to
operate, but an enduring override is exactly the capability the production
predicate is meant to exclude.

**Option D — Test only in another repository.** Safe for `main`, but cannot
prove this repository's artifact permissions, branch protection, origin,
lease, and token behavior.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Fidelity to final writer algorithm and origin | 30 | The evidence must exercise exact hashes, approval, preflight, commit, lease, and post-push checks. |
| Final production attack-surface preservation | 25 | No branch override or generic write caller may remain. |
| Positive/negative proof completeness | 25 | Changed, no-op, stale, race, identity, event, and token cases all matter. |
| Mechanical cleanup/absence evidence | 15 | Reviewers must prove the temporary authorization was removed. |
| Evidence implementation effort | 5 | A temporary copy is acceptable if equality is validated. |

| Option | Fidelity | Surface | Proof | Cleanup | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 2 | **97** |
| B | 5 | 2 | 5 | 3 | 3 | 77 |
| C | 4 | 1 | 4 | 1 | 5 | 57 |
| D | 2 | 5 | 2 | 5 | 4 | 66 |

### Selected option

Select **Option A**. Name
`.github/workflows/evidence-p1b-temporary-writer.yml` as the only acceptable
temporary proof path. Before enabling `main`:

1. create one unique temporary branch and exact evidence-workflow commit;
2. have the structural validator compare every production writer
   step/role/script body to the evidence copy except the statically allowed
   event/ref predicate;
3. run preparation, Markdown call, all four Windows cells, four hashes,
   approval, at-use helper/regeneration, remote preflight, one-parent commit,
   exact lease/refspec, and post-push identity;
4. execute every named negative drill, including failed/cancelled/skipped
   dependency, malformed attestation, digest/manifest failure, stale remote,
   post-preflight race, no-op, unrelated event/ref, and token sentinel;
5. retain run IDs/URLs, commits, artifact IDs/digests, attestations, and remote
   before/after IDs; and
6. delete the evidence workflow/ref and prove the final production commit has
   neither that path nor any alternate write predicate.

No validation instruction may tell the operator to hand-edit the production
workflow.

## `C-P1B-06` — Mechanically validate unique matrix-output mapping

### Options

**Option A — Keep one matrix with four static outputs and four guarded emitter
steps.** Each canonical cell can execute only its matching emitter/output;
the policy validator proves the axes, guards, key mapping, and approval checks.

**Option B — Replace the matrix with four separately declared jobs.** Outputs
and dependencies become explicit, but workflow logic is duplicated four times
and is more likely to drift between editions/EOL fixtures.

**Option C — Upload one attestation artifact per cell and aggregate them.**
This avoids job-output overwrite but adds names/artifact discovery as another
transport protocol and must solve cardinality/digest/trust again.

**Option D — Use one shared output and assume deterministic matrix order.**
GitHub explicitly does not guarantee completion order; this is invalid.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Collision/overwrite resistance | 30 | No last-finisher behavior may erase another cell. |
| Cell-to-key authenticity | 30 | A passing cell must not populate another cell's identity. |
| Approval failure detection | 20 | Missing, duplicate, malformed, or mismatched records must block promotion. |
| Workflow maintainability | 10 | Shared validation logic should remain one matrix definition. |
| Runner/transport overhead | 10 | Extra jobs/artifacts cost time and add failure surfaces. |

| Option | Collision | Authenticity | Detection | Maintainability | Overhead | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | **98** |
| B | 5 | 5 | 5 | 2 | 3 | 90 |
| C | 5 | 4 | 4 | 3 | 2 | 80 |
| D | 1 | 1 | 1 | 5 | 5 | 36 |

### Selected option

Select **Option A**. Define exactly four matrix output keys:

```text
attestation_desktop_lf
attestation_desktop_crlf
attestation_core_lf
attestation_core_crlf
```

Use an exact `matrix.include` catalog containing edition, fixture EOL, stable
cell ID, and static emitter selector. The job declares all four outputs.
Exactly four emitter steps have mutually exclusive, literal guards matching
one canonical cell; each writes only its named step output after all cell
checks pass. A cell cannot construct an output key dynamically.

The structural validator must prove:

- the include catalog has exactly four unique axis/cell combinations;
- `strategy.job-total` is asserted as four and `fail-fast` is false;
- every emitter guard maps one cell to one output and no step can set two;
- approval receives exactly the four keys;
- every key is nonempty and parses to one bounded canonical record;
- embedded cell IDs are unique and equal their keys/axes; and
- all artifact identity, four hashes, event SHA/ref, and `has_changes` values
  equal preparation.

Negative fixtures cover every swapped guard/key, duplicate embedded cell ID,
empty output, extra matrix row, and last-finisher order permutation.

## `I-P1B-01` — Remove successor work from P1B acceptance

### Options

**Option A — Keep “P2 records P1B's merge commit” in P1B acceptance.** This
states the sequence but requires a future content issue to act before the
writer issue can close.

**Option B — Move exact P1B receipt into P2's prerequisite.** P1B closes on its
own graph/security evidence; P2 records the final P1B merge commit and run
evidence before changing source content.

**Option C — Remove the handoff requirement entirely.** P2 can rely on `main`,
but then it cannot distinguish the reviewed P1B implementation from a later
workflow change.

**Option D — Keep a non-blocking note in P1B and a blocking criterion in P2.**
This is semantically equivalent to Option B if the P1B note is explicitly a
handoff, not acceptance; it adds useful discoverability.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Independent P1B completion | 35 | The security boundary should close when its own evidence is complete. |
| P2 no-drift baseline identity | 30 | Content regeneration must target the exact merged publication pipeline. |
| Handoff discoverability | 15 | Maintainers should see the next dependency without confusing ownership. |
| Audit responsibility placement | 15 | P2 is the issue capable of recording receipt. |
| Textual change cost | 5 | A precise move is low-cost. |

| Option | Completion | Baseline | Discoverability | Responsibility | Cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 4 | 4 | 1 | 5 | 51 |
| B | 5 | 5 | 4 | 5 | 5 | 97 |
| C | 5 | 1 | 2 | 3 | 5 | 61 |
| D | 5 | 5 | 5 | 5 | 5 | **100** |

### Selected option

Select **Option D**. P1B's execution-order text may say that P2 follows and
must consume its merge, but delete the future action from P1B acceptance.
P1B's final handoff records:

- final workflow and validator commits/versions;
- external-action provenance/default records;
- positive/negative run IDs and temporary evidence workflow removal;
- preparation artifact ID/digest/four hashes;
- four matrix attestations and approval result;
- writer preflight/commit/lease/post-push identities;
- token sentinel and bounded diagnostics evidence; and
- the P1B↔T1B matrix.

P2's prerequisite must identify P1B's real issue URL/blocked-by relationship,
exact merge commit, and retained run evidence before editing. This makes the
handoff visible in both directions while only P2 owns receipt.

## `C-P2-01` — Update stale P1B pull-request expectations

### Options

**Option A — Rewrite P2 with a full copy of corrected P1B behavior.** This can
be accurate today but duplicates the complete graph and will drift again.

**Option B — State only P2-relevant event outcomes and consume exact P1B
evidence.** On PR, preparation, local Markdown validation, all four Windows
cells, and read-only approval run; only the writer skips. P2 links the exact
P1B merge/run evidence for algorithm details.

**Option C — Remove P2's CI evidence sections.** P1B already tests the graph,
but P2 still needs to prove its six-file content change triggers and passes the
enduring pipeline.

**Option D — Keep the current LF-only helper/push-only preparation text.** This
directly contradicts P1B and would accept an incorrect PR run.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Consistency with merged P1B | 35 | P2 cannot redefine which jobs/cells execute. |
| Evidence relevant to the content change | 25 | The six-file edit must prove real PR and no-drift post-merge behavior. |
| Resistance to future algorithm drift | 20 | P2 should cite, not clone, security internals owned by P1B. |
| Contributor-facing clarity | 15 | A PR author should know which jobs should run or skip. |
| Revision effort | 5 | Editing prose is low-cost relative to correctness. |

| Option | Consistency | Relevance | Drift resistance | Clarity | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 2 | 4 | 3 | 83 |
| B | 5 | 5 | 5 | 5 | 4 | **99** |
| C | 4 | 2 | 5 | 2 | 5 | 69 |
| D | 1 | 1 | 1 | 1 | 5 | 24 |

### Selected option

Select **Option B**. Replace P2's Pull-request evidence with:

1. the sole event-owner workflow triggers for every PR targeting `main`;
2. preparation creates and uploads the immutable four-file candidate even
   when `has_changes=false`;
3. the same-commit local Markdown call runs read-only;
4. all four Windows edition/EOL cells execute every applicable P1A ID and the
   production helper/context/harness;
5. four unique attestations reach read-only terminal approval;
6. approval succeeds only with the exact successful dependency set; and
7. the writer skips because the event is not an approved changed push to
   `main`.

Post-merge evidence should expect the same read-only graph,
`has_changes=false`, successful approval, and skipped writer because P2 commits
sources and generated artifacts together. P2 cites the exact P1B merge and run
IDs for held-stream, cleanup, attestation, and writer internals rather than
restating them.

## `C-P2-02` — Use NUL-delimited Git path-set checks

### Options

**Option A — Consume one tracked raw-byte path-set verifier introduced by
P1.** The verifier captures `git` stdout through
`System.Diagnostics.Process`, splits NUL records, compares raw ASCII bytes to
the expected PSStyleGuide paths, and unions unstaged/cached/untracked sources.

**Option B — Embed an equivalent raw-byte helper in P2's validation block.**
This can be correct but duplicates a subtle native-stream parser that every
other issue also needs.

**Option C — Improve the existing line-oriented porcelain regex.** Handling
quotes and rename arrows manually still depends on `core.quotePath`, record
forms, and text decoding; it is not a complete pathname parser.

**Option D — Assume repository conventions forbid unusual filenames.** An
affected-file security gate must reject unexpected paths rather than assume
contributors never create them.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Exact arbitrary-path safety | 40 | The gate must not misparse tabs, newlines, quotes, escapes, or rename pairs. |
| Windows PowerShell 5.1/PowerShell 7 consistency | 25 | Text pipelines encode native output differently; raw capture must work on both. |
| Complete working/index/untracked coverage | 15 | Deleted, renamed, staged, unstaged, and untracked paths all affect scope. |
| Reuse and negative-test quality | 10 | One verifier should carry tricky fixture coverage across issues. |
| P2-specific churn | 10 | P2 should remain a six-content-file issue once the verifier exists. |

| Option | Path safety | Cross-version | Coverage | Reuse | P2 churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 5 | **100** |
| B | 5 | 5 | 5 | 2 | 3 | 90 |
| C | 2 | 3 | 2 | 2 | 4 | 49 |
| D | 1 | 4 | 1 | 5 | 5 | 51 |

### Selected option

Select **Option A**. P1 must add the enduring
`.github/workflows/Test-ExactGitPathSet.ps1`; P2 invokes its exact merged
version without modifying it. The verifier must:

- use `#Requires -Version 5.1`;
- launch Git with argument arrays and redirected raw stdout/stderr;
- capture native exit immediately;
- use `--no-renames --name-only -z` for unstaged and cached diffs and
  `ls-files --others --exclude-standard -z` for untracked paths;
- split raw stdout only on byte `0x00`, reject malformed/trailing records, and
  compare every record to the exact expected ASCII byte sequence;
- union and sort ordinally without case folding;
- report missing and unexpected paths without lossy display of hostile bytes;
  and
- support working-tree, staged, or exact-both modes.

Its own disposable-repository fixtures must include spaces, tabs, quotes,
backslashes, a newline-bearing filename, non-ASCII bytes where the platform
permits them, deletions, renames, untracked files, and mixed staged/unstaged
state. P2 uses exact-both mode before staging and staged mode afterward against
the six approved paths.

## `C-P2-03` — Classify `git diff --exit-code`

### Options

**Option A — Branch explicitly on 0, 1, and all other exits.** Exit 0 means the
rerun is identical, 1 means ordinary generator drift, and any other value is a
Git/native execution failure with captured stderr.

**Option B — Use `git diff --quiet` and still classify its exit.** This reduces
output but has the same 0/1/error contract; a second command would be needed to
show useful drift evidence.

**Option C — Replace Git comparison with independent file hashes.** Hashes can
prove bytes but must separately compare index blobs versus working files and
would duplicate Git's staged-result model.

**Option D — Keep treating every nonzero exit as generator drift.** This hides
repository/corruption/argument/external-diff failures under an inaccurate
message.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Failure-class accuracy | 35 | Reviewers must distinguish content drift from Git malfunction. |
| Generator-idempotency proof | 30 | The rerun must prove the staged expected result is unchanged. |
| Consistency with inherited native-command policy | 20 | P1 requires immediate exit capture and semantic classification. |
| Actionable diagnostics | 10 | Ordinary drift should identify paths; command failure should preserve stderr/status. |
| Code churn | 5 | A small branch should be preferred once semantics are correct. |

| Option | Classification | Idempotence | Native policy | Diagnostics | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 5 | **100** |
| B | 5 | 5 | 5 | 3 | 4 | 95 |
| C | 4 | 4 | 4 | 4 | 2 | 78 |
| D | 1 | 3 | 1 | 1 | 5 | 36 |

### Selected option

Select **Option A**. Immediately after:

```text
git diff --exit-code -- <six exact paths>
```

P2 captures `$LASTEXITCODE` once and applies:

- `0`: continue; the final generator run produced no unstaged difference from
  the staged result;
- `1`: capture a separate NUL-safe changed-path summary, then fail with a
  generator-idempotency diagnostic; and
- any other value, including negative/platform-translated failure: fail as a
  Git command error with the exact exit and bounded stderr.

Do not rerun the original command before classifying its status. Disable or
reject unreviewed external diff helpers so exit semantics cannot be delegated
to arbitrary tooling. Add synthetic validation proving each branch emits a
distinct stable diagnostic category.

## `C-P2-04` — Machine-check the unchanged Compliant example

### Options

**Option A — Continue visual confirmation.** A reviewer checks the diff. This
is useful but not a repeatable acceptance proof.

**Option B — Define and ordinally compare the exact canonical Compliant
snippet.** Capture the heading, blank line, fence, braces, commands, truly
empty line, and closing fence as LF text; require exactly one occurrence before
and after editing in the source and generated artifacts.

**Option C — Require the entire pre-edit `STYLE_GUIDE.md` hash to remain
unchanged except approved lines.** This needs a general patch-range verifier
and conflicts with the intended Non-Compliant/metadata changes.

**Option D — Parse Markdown and compare the first PowerShell fence after the
Blank Line Usage heading.** Structural selection is resilient to unrelated
duplicates but adds a Markdown parser and can normalize away byte distinctions
such as the truly empty line.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Byte-level preservation certainty | 35 | The compliant blank line must remain literally empty and copy-ready. |
| Locality to the intended example | 25 | The check should permit only the neighboring Non-Compliant/rationale/metadata changes. |
| Cross-runtime reproducibility | 15 | Validation runs in Windows PowerShell and PowerShell 7 with LF files. |
| Failure diagnostics | 15 | Contributors should see missing/duplicate/changed snippet facts. |
| Ongoing specification burden | 10 | A short canonical snippet is acceptable; a full Markdown parser is not needed. |

| Option | Preservation | Locality | Reproducibility | Diagnostics | Burden | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 3 | 5 | 2 | 5 | 60 |
| B | 5 | 5 | 5 | 5 | 4 | **98** |
| C | 5 | 2 | 4 | 2 | 2 | 67 |
| D | 4 | 5 | 3 | 4 | 2 | 78 |

### Selected option

Select **Option B**. P2 must record the exact baseline snippet:

````text
**Compliant (blank line is truly empty):**

```powershell
{
    Invoke-SomeCmdlet

    Invoke-AnotherCmdlet
}
```
````

In the actual issue, use a safe outer four-backtick fence so the nested fence
is unambiguous. Build the expected string from a line array joined with LF and
compare with `StringComparison.Ordinal`; do not trim or normalize the source.
Require exactly one canonical occurrence in `STYLE_GUIDE.md` and, after
regeneration, exactly one in each generated artifact.

Before editing, also record the exact prerequisite commit and SHA-256 of this
snippet. After editing/staging/rerun, prove the ordinal bytes and digest are
unchanged. A fixture with a space on the empty line, changed fence language,
changed command, or duplicate block must fail. The rationale remains exempt
because it must not duplicate either operational example.

## `C-P2-05` — Consume rather than restate P1B

### Options

**Option A — Keep a detailed P1B algorithm copy in P2 and update it now.**
This gives a self-contained issue but creates two normative descriptions for
transport, cleanup, matrix, approval, and writer behavior.

**Option B — Define a narrow consumed-interface contract.** P2 records the
exact P1B issue/merge/run identities and names only the stable observations it
needs: unfiltered validation, four-file candidate, four cells/attestations,
read-only approval, no-drift `has_changes=false`, and skipped writer.

**Option C — Remove every P1B reference except “blocked by P1B.”** This avoids
drift but gives no evidence that P2 was tested against the intended publication
boundary.

**Option D — Create a separate shared pipeline specification document.** Both
issues could link it, but that introduces another normative artifact and
weakens immutable issue/commit ownership unless rigorously versioned.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Single source of algorithmic authority | 30 | P1B must remain the owner of helper/transport/writer mechanics. |
| Drift resistance across later edits | 30 | P2 should not become stale whenever the pipeline evolves. |
| Immutable evidence traceability | 20 | The exact merged implementation and runs must remain identifiable. |
| P2 implementer usability | 15 | A cold reader still needs concrete expected PR/push outcomes. |
| Documentation churn | 5 | Reducing repeated prose is beneficial but secondary. |

| Option | Authority | Drift | Traceability | Usability | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 1 | 4 | 4 | 2 | 48 |
| B | 5 | 5 | 5 | 5 | 5 | **100** |
| C | 5 | 5 | 2 | 1 | 5 | 76 |
| D | 3 | 4 | 3 | 3 | 2 | 65 |

### Selected option

Select **Option B**. P2's prerequisite records P1B's actual issue URL,
blocked-by relationship, exact merge commit, workflow/validator versions, and
retained positive/negative run IDs. Its permanent CI language is limited to:

- which stable P1B interface is invoked by the six-file change;
- which event-level jobs must run or skip;
- the exact expectation that committed sources and generated artifacts yield
  `has_changes=false`; and
- the requirement that unexpected drift fails P2 rather than relying on a bot
recovery commit.

Delete P2's paraphrases of `FileShare.Read`, same-stream ZIP parsing, cleanup
ordering, matrix internals, writer at-use sequence, credentials, and lease
implementation. Static inspection and P1B's retained changed-push evidence
remain the authority for writer behavior; P2 proves only that its no-drift
content follows the merged interface without weakening it.

## `I-P2-01` — Use one pathname encoding for every P2 proof

### Options

**Option A — Route pre-stage, post-stage, and idempotency drift path queries
through the same raw NUL-safe verifier.** One implementation and fixture suite
owns decoding/comparison everywhere.

**Option B — Fix only the pre-stage gate.** Keep
`git diff --cached --name-only` line-oriented after staging. This leaves the
same quoting/newline defect in the acceptance proof.

**Option C — Use separate NUL-safe command blocks for each phase.** This can be
correct but duplicates process capture, record validation, and raw-byte
comparison.

**Option D — Treat staged paths as safe because `git add` receives an expected
array.** The index can contain preexisting/malicious entries or unexpected
rename/deletion state; input arguments do not prove resulting scope.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Encoding consistency across phases | 35 | A proof chain is only as strong as its weakest pathname parser. |
| Complete pre/post/index coverage | 30 | Both the working set and staged result must equal the six files. |
| Hostile/unusual pathname rejection | 20 | Newlines, quotes, tabs, and rename pairs must not bypass a later gate. |
| Debugging consistency | 10 | Contributors should receive the same stable missing/unexpected diagnostics. |
| Invocation overhead | 5 | Reusing a script is cheap compared with maintaining multiple parsers. |

| Option | Consistency | Coverage | Hostile paths | Diagnostics | Overhead | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 5 | **100** |
| B | 2 | 3 | 2 | 3 | 5 | 51 |
| C | 4 | 5 | 5 | 3 | 2 | 86 |
| D | 1 | 1 | 1 | 2 | 5 | 26 |

### Selected option

Select **Option A**. P2 must invoke the exact P1 path-set verifier:

1. before staging, to require the complete union of working/index/untracked
   changes equals the six affected paths;
2. immediately after `git add -- <six paths>`, to require the cached set equals
   the same six and no unstaged/untracked path remains;
3. after the final generator rerun, to prove the staged set is still exact and
   the working-versus-index set is empty; and
4. when `git diff --exit-code` returns 1, to report the exact raw-path drift
   category without invoking a line-oriented name command.

All invocations use ordinal path identity and the same stable script version.
No `git status` or `git diff --name-only` output may be captured through a
PowerShell text pipeline anywhere in P2.

## `C-P3-01` — Add continuous read-only audit execution

### Options

**Option A — Extend the sole `build.yml` event owner with conditional
schedule/manual validation paths.** Schedule and `workflow_dispatch` call only
the local Markdown/dependency workflow and a read-only terminal result;
publication jobs are structurally ineligible.

**Option B — Give `markdownlint.yml` its own schedule/manual triggers.** This
is easy but reintroduces a second external event owner and splits policy
results across independent workflow runs.

**Option C — Rely on Dependabot/security alerts for continuous governance.**
Those services can propose or flag changes but do not execute the repository's
exact exception topology/expiry validator every day/week.

**Option D — Validate only on PR and push.** Expired exceptions can remain
accepted indefinitely when the repository has no new changes.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Continuous expiry/topology enforcement | 40 | Time-based policy must fail after time passes without a commit. |
| Publication-path isolation | 25 | Scheduled/manual dependency checks must never upload/promote/write artifacts. |
| One-event-owner preservation | 15 | P1B's same-run trust graph should remain structurally simple. |
| CI cost proportionality | 10 | Recurring validation should avoid the Windows candidate matrix and artifacts. |
| Maintainer operability | 10 | Manual rerun should be available without broad inputs or write permissions. |

| Option | Continuity | Isolation | One owner | Cost | Operability | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 5 | **100** |
| B | 5 | 5 | 1 | 5 | 5 | 88 |
| C | 2 | 5 | 5 | 5 | 3 | 72 |
| D | 1 | 5 | 5 | 5 | 3 | 64 |

### Selected option

Select **Option A**. P3 adds `build.yml` to its computed scope and preserves it
as the sole external event owner. Require:

- ordinary and Dependabot `pull_request` events targeting `main`;
- pushes to `main`;
- `merge_group` only when repository merge queue is enabled;
- one read-only weekly UTC schedule at a non-hour-boundary minute; and
- input-free `workflow_dispatch`.

For schedule/manual events, only the same-commit local
`validate_markdown_dependencies` call job and a read-only
`dependency_policy_result` job may run. Candidate preparation, artifact
upload, Windows candidate matrix, promotion approval, diagnostics for those
jobs, and writer must be skipped structurally by exact event guards.

The workflow-policy validator must enumerate the allowed event-to-job graph
and reject any schedule/manual path to an artifact action or write permission.
Retain run evidence for schedule and manual success plus negative fixtures in
which an expired exception fails the terminal result.

## `C-P3-02` — Define an exact exception lifetime

### Options

**Option A — Use one canonical approval instant and an at-most-30×24-hour
exclusive expiry.** Whole-second RFC 3339 UTC timestamps end in `Z`;
`createdAt == approvedAt`, expiry is later and at most 30 days afterward, and
injected `now >= expiresAt` fails.

**Option B — Use severity-dependent lifetimes.** Critical/high/moderate
findings could receive different limits. This may improve risk sensitivity but
adds policy branches and negotiation without a current repository authority
for those durations.

**Option C — Expire at a milestone such as “before next release.”** The
repository has no guaranteed release cadence, so the exception can remain
open indefinitely.

**Option D — Forbid all residuals.** Zero audit findings is preferred, but a
hard prohibition could force incompatible/unsafe package changes or make P3
unimplementable when no maintained fixed tree exists.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Temporal determinism | 35 | Fixtures and scheduled CI need one exact instant/inequality contract. |
| Maximum security exposure | 30 | Residual vulnerabilities require a short, nonrenewing-by-default window. |
| Boundary-test completeness | 20 | Before/at/after and malformed timestamps must be unambiguous. |
| Owner/operator clarity | 10 | Renewal must require real re-review, not a timestamp edit. |
| Exceptional-case flexibility | 5 | The policy should permit a justified residual without normalizing it. |

| Option | Determinism | Exposure | Tests | Clarity | Flexibility | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | **99** |
| B | 4 | 4 | 4 | 3 | 5 | 79 |
| C | 1 | 1 | 1 | 2 | 3 | 24 |
| D | 5 | 5 | 5 | 4 | 1 | 94 |

### Selected option

Select **Option A**, while retaining zero vulnerabilities as the preferred
state. The exception schema must require canonical whole-second RFC 3339 UTC
`createdAt`, `approvedAt`, and `expiresAt` strings ending in `Z`.
`createdAt` and `approvedAt` represent the same reviewed approval instant;
`expiresAt` is strictly later and no later than exactly 30×24 hours afterward.

The pure validator accepts an injected canonical UTC `now`. It rejects future
approval, malformed/offset/fractional/noncanonical timestamps, expiry at or
before approval, expiry one second beyond 30 days, and `now >= expiresAt`.
Fixtures cover one second before expiry, exact expiry, one second after, and
leap/month/year boundaries without using local time.

Renewal requires new clean-install/audit/fix-availability evidence, updated
exploitability/controls/follow-up status, and a new accountable approval.
Changing timestamps alone is forbidden. Schedule execution guarantees expiry
is enforced even without a repository change.

## `C-P3-03` — Add deterministic audit-policy oracles

### Options

**Option A — Define a closed stable `AUDIT-*` fixture catalog.** Immutable
local JSON fixtures and injected time/native status cover clean, residual,
schema, graph, topology, approval, expiry, and tool-failure outcomes.

**Option B — Exercise only the current live registry response.** This proves
integration but cannot deterministically produce rare malformed schemas,
expiry boundaries, or specific graph errors.

**Option C — Snapshot complete raw npm JSON and compare text.** This detects
any response change but treats harmless property order/additions as failure
without explaining consumed-field semantics.

**Option D — Use randomized/fuzzed audit objects without stable IDs.** Fuzzing
can supplement robustness but is not reproducible acceptance evidence and may
miss required governance states.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Schema/graph/policy branch coverage | 30 | Every consumed npm shape and exception equality rule must have an oracle. |
| Security-governance outcome coverage | 30 | Missing/extra/stale/expired approvals must fail predictably. |
| Determinism and offline replay | 25 | CI should test policy without registry timing/content changes. |
| Distinct actionable diagnostics | 10 | Schema, vulnerability, policy, registry/tool, and native failures need separate categories. |
| Fixture maintenance cost | 5 | Immutable focused fixtures should avoid unnecessary raw-report churn. |

| Option | Branches | Governance | Determinism | Diagnostics | Maintenance | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | **99** |
| B | 2 | 2 | 1 | 3 | 5 | 40 |
| C | 3 | 3 | 5 | 1 | 2 | 65 |
| D | 4 | 3 | 3 | 2 | 3 | 64 |

### Selected option

Select **Option A**. P3 must give one exact fixture, invocation, expected
category, and immutable-input postcondition to at least these IDs:

- `AUDIT-01` clean report/no exception passes;
- `AUDIT-02` clean report/stale exception fails;
- `AUDIT-03` residual/no approval fails;
- `AUDIT-04` exact approved residual passes;
- `AUDIT-05..07` missing, extra, and duplicate finding keys fail;
- `AUDIT-08..10` missing, extra, and topology-changed node paths fail;
- `AUDIT-11` malformed advisory object/type fails schema;
- `AUDIT-12` broken `via`/`effects` graph target fails graph;
- `AUDIT-13` metadata/property severity totals mismatch fails schema;
- `AUDIT-14` Boolean `fixAvailable` is accepted and interpreted;
- `AUDIT-15` reviewed-object `fixAvailable` is accepted and validated;
- `AUDIT-16` unsupported report version fails schema;
- `AUDIT-17` audit native exit versus derived result mismatch fails;
- `AUDIT-18..20` before, exact, and after-expiry outcomes;
- `AUDIT-21` malformed/noncanonical timestamp fails;
- `AUDIT-22` expiry beyond 30×24 hours fails;
- `AUDIT-23` registry/tool failure is distinct from vulnerabilities;
- `AUDIT-24` unexpected native exit is distinct and preserved; and
- `AUDIT-25` validator leaves every input fixture byte-identical.

Each fixture has a recorded SHA-256 and is copied to a disposable location
before any mutation negative. The harness rejects missing/duplicate/
unexpected IDs and verifies expected/actual totals, diagnostic category, and
no source/dependency/repository mutation.

## `C-P3-04` — Separate the pure audit validator from orchestration

### Options

**Option A — Add dependency-free `Validate-NpmAudit.mjs` pure core plus CLI.**
It accepts parsed audit data, optional exception data, injected UTC time, and
captured native status. PowerShell separately invokes exact npm and supplies
the preserved inputs.

**Option B — Keep all logic in `Test-NpmAuditPolicy.ps1`.** PowerShell can
validate JSON, but live command orchestration, schema logic, fixture mutation,
and time handling remain coupled and harder to unit test.

**Option C — Let the JavaScript validator invoke npm itself.** This moves code
but does not separate live registry/native-process behavior from pure policy
decisions.

**Option D — Use a generic JSON Schema validator only.** Schema validation can
check types but not reciprocal graph targets, lockfile node resolution, exact
approval equality, time policy, or native-exit consistency.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Pure deterministic fixture execution | 30 | Negative schema/topology/time cases must run without npm or network. |
| Separation of native/tool and policy failure | 25 | Registry/npm errors must not be mislabeled as vulnerability decisions. |
| Cross-platform reuse | 20 | The same core should run in Windows/Ubuntu Node cells and local harnesses. |
| Fail-closed consumed-schema validation | 15 | Unknown/missing/wrong shapes need precise handling beyond generic parsing. |
| Added implementation surface | 10 | Two components are justified only if their interfaces are small and explicit. |

| Option | Purity | Failure separation | Portability | Schema safety | Surface | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | **98** |
| B | 3 | 2 | 4 | 4 | 4 | 64 |
| C | 2 | 2 | 5 | 5 | 3 | 63 |
| D | 5 | 3 | 5 | 2 | 4 | 79 |

### Selected option

Select **Option A**. Add
`.github/workflows/Validate-NpmAudit.mjs` with:

- a pure exported function receiving plain parsed audit data, optional parsed
  exceptions, normalized lockfile package lookup, injected canonical `now`,
  captured npm version, and native exit;
- no filesystem, process, environment, clock, registry, or network access in
  that function;
- a thin CLI that reads exact explicit files/arguments, calls the core, emits
  bounded canonical JSON results, and maps stable categories to documented
  exits; and
- dependency-free implementation so audit policy does not depend on the
  vulnerable package graph it evaluates.

`Test-NpmAuditPolicy.ps1` owns resolving the selected npm application,
capturing raw stdout/stderr and exit immediately, preserving bounded raw
evidence, parsing JSON once, building lockfile node lookup, invoking the CLI,
and running cross-platform fixtures. The integration harness must demonstrate
distinct `clean`, `vulnerability`, `policy`, `schema`, `registry-tool`, and
`native-exit` outcomes.

## `C-P3-05` — Use one tracked Node-policy decision

### Options

**Option A — Add dependency-free `Check-NodePolicy.mjs` with pure export and
CLI.** The pre-commit hook invokes the CLI after resolving/querying Node;
`lint-staged-markdown.mjs` imports the same function; fixtures call both.

**Option B — Keep separate shell and JavaScript implementations with shared
fixtures.** Equality tests can detect some drift but still require maintaining
two parsers/semver decisions and can diverge outside fixture inputs.

**Option C — Put the policy only in the shell hook and have the staged API
trust its caller.** Direct programmatic invocation could bypass runtime policy,
and JavaScript callers would have no reusable decision.

**Option D — Rely only on `package.json` `engines.node`.** npm treats engines
as advisory unless strict mode is enabled, and the hook must reject unsupported
runtime before npm or `node_modules` access.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Single executable source of truth | 30 | Hook, staged API, workflow, and fixtures must not implement different support rules. |
| Exact version grammar and finite-set decision | 25 | Malformed/intervening/current/future majors must reject predictably. |
| Shell/Windows/Ubuntu integration | 20 | The same decision must work through Git/Husky and direct Node execution. |
| Stable boundary-oracle coverage | 15 | Patch floors and malformed forms need individual results. |
| Contributor diagnostics/remediation | 10 | Rejections should state observed version, accepted set, and upgrade action. |

| Option | One source | Grammar | Integration | Oracles | Diagnostics | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | **98** |
| B | 2 | 4 | 4 | 5 | 4 | 71 |
| C | 2 | 4 | 3 | 3 | 3 | 59 |
| D | 2 | 3 | 3 | 2 | 2 | 49 |

### Selected option

Select **Option A**. Add
`.github/workflows/Check-NodePolicy.mjs` with:

- a pure function accepting exactly one observed version string and one
  versioned finite policy object;
- strict whole-string grammar for canonical `major.minor.patch`;
- exact selected Node 22 and 24 patch floors, excluding 23, 25, 26, and every
  unreviewed future major;
- a small CLI returning stable supported/unsupported/malformed categories; and
- no imports from `node_modules`, filesystem, environment, or network.

The hook resolves `node` as an application, queries its raw version, and calls
the CLI before resolving npm or inspecting packages. The staged implementation
imports the same pure function. `engines.node` expresses the identical finite
semver union, while strict clean-install cells prove package compatibility.

Give individual stable IDs to lowest admitted/normal versions on each major,
one below each patch floor, below-minimum, each intervening/current/above-max
major, empty, whitespace, prefix, suffix, missing/extra component, leading
zero, and nonnumeric forms. A fixture comparison proves CLI, imported
decision, `engines` admission, and workflow matrix agree.

## `C-P3-06` — Consume the P1B workflow validator/parser

### Options

**Option A — Include and deliberately update the existing validator/parser in
P3.** P3 reruns all P1B fixtures and adds Node-matrix plus schedule/manual
event-subgraph policy.

**Option B — Leave the validator file untouched while replacing the package
lock.** The parser version/transitive graph can still change or disappear, so
file-level nonmodification does not prove policy continuity.

**Option C — Replace the YAML parser/validator with a new P3 implementation.**
This may align with new packages but discards reviewed P1B semantics exactly
when the workflow graph becomes more complex.

**Option D — Exclude structural workflow checks from dependency remediation.**
Lint/audit may pass while permissions, events, action inputs, or writer guards
silently weaken.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| P1B security-invariant regression protection | 35 | Package/workflow changes must preserve the verified writer boundary. |
| Locked parser/dependency integrity | 25 | The reviewed direct parser and safe configuration must survive lock regeneration. |
| New schedule/manual graph enforcement | 20 | P3 adds event paths that must be proved unable to publish. |
| Positive/negative fixture continuity | 15 | Stable policy IDs should detect both old and new graph mutations. |
| Package-migration churn | 5 | Updating one existing policy program is expected P3 work. |

| Option | Regression | Dependency | New graph | Fixtures | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | **99** |
| B | 3 | 2 | 2 | 3 | 5 | 53 |
| C | 2 | 3 | 4 | 2 | 2 | 53 |
| D | 1 | 1 | 1 | 1 | 5 | 24 |

### Selected option

Select **Option A**. P3's minimum expected scope must explicitly include:

- `.github/workflows/build.yml`;
- `.github/workflows/markdownlint.yml`;
- `.github/workflows/Validate-WorkflowPolicy.mjs`;
- `.github/workflows/package.json`; and
- `.github/workflows/package-lock.json`.

At start, record P1B's validator hash/version, direct YAML parser
name/version/manifest/lock nodes, and all fixture IDs/results. After package
selection, either retain the exact parser or document and re-review any
version change for license, provenance, schema/default behavior, aliases,
duplicate keys, tags, and Node engines.

Run every P1B positive/negative fixture unchanged, then add fixtures proving:
finite Node roles, exact selected npm, schedule/manual call-only graph,
read-only terminal result, and structural ineligibility of preparation,
artifact actions, Windows candidate validation, approval, and writer on those
events. Any lost or weakened P1B fixture blocks P3.

## `C-P3-07` — Reconcile package order with current advisories

### Options

**Option A — Make P3 consume P1's risk authorization and define a stop/
rebaseline branch.** The default sequence remains, but only while the decision
is valid and the audit has not materially worsened.

**Option B — Declare the sequence unconditional.** This preserves planning
simplicity but lets an expired/refused security decision be overridden by the
draft.

**Option C — Always move P3 first.** This minimizes waiting but contradicts the
required order and forces repeated workflow/package rebaselining.

**Option D — Maintain a parallel package-remediation branch until P3.** This
can shorten response time but creates two lock/workflow truths and difficult
merge/evidence reconciliation.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Security-policy authority | 35 | The issue order cannot overrule a governing vulnerability policy. |
| Exact prerequisite-baseline consistency | 25 | P3 must know which P1/P1A/P1B/P2 commits and package graph it remediates. |
| Deterministic go/stop/rebaseline behavior | 20 | Implementers need a closed decision path, not discretion. |
| Rework and merge risk | 10 | Parallel or repeated package updates can invalidate evidence. |
| Schedule continuity after P3 | 10 | The selected path must end in continuous governance, not just a one-time update. |

| Option | Authority | Baseline | Decision path | Rework | Continuity | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 5 | **100** |
| B | 1 | 5 | 1 | 5 | 5 | 56 |
| C | 4 | 1 | 4 | 1 | 5 | 61 |
| D | 3 | 2 | 2 | 1 | 3 | 47 |

### Selected option

Select **Option A**. P3's Dependencies and order section must require:

- the exact unexpired P1 advisory-risk decision;
- exact P1/P1A/P1B/P2 merge commits and their package/lock/workflow baseline;
- a fresh audit at P3 start using the recorded current CLI and another after
  selecting the final exact npm; and
- comparison of current package/advisory identities, severity, fix
  availability, and topology to the authorized wait.

If approval expired, policy refused the wait, a critical finding appears,
severity/material exploitability worsens, or the authorized package graph was
changed outside the sequence, stop. Regenerate the relevant issue order and
prerequisite baselines; do not perform an undocumented partial update inside
P1–P2 or silently continue P3 against different commits.

P3 acceptance explicitly closes the wait by proving zero vulnerabilities or
exact at-most-30-day governed residuals under continuous schedule/manual/PR/
push validation.

## `I-P3-01` — Specify exact NUL-safe P3 path validation

### Options

**Option A — Reuse P1's exact path-set verifier with a computed P3 allowlist.**
After package/API/exception decisions, record the exact path list once and use
the same raw NUL-safe script before staging, after staging, and after rerun.

**Option B — Embed a P3-specific NUL parser.** Correct in principle but repeats
the complex raw-process and hostile-filename logic already required by P2.

**Option C — Use line-oriented `git status`/`diff --name-only`.** Simpler but
fails the same quoting/newline/rename requirements identified in P2.

**Option D — Avoid exact scope because P3's file set is conditional.** A
conditional set can still be computed and frozen before editing; uncertainty
is not a reason to omit the gate.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Exact computed-scope enforcement | 35 | Package/API compatibility and optional exceptions require a flexible but closed allowlist. |
| NUL/raw-byte pathname correctness | 25 | Dependency work must not conceal unrelated workflow/source changes. |
| Conditional-file handling | 20 | Exception/lint-config files must be admitted only when their documented condition is true. |
| Windows/Ubuntu reproducibility | 10 | P3 validation spans both OS families. |
| Shared-verifier continuity | 10 | One stable tested mechanism should serve the whole slate. |

| Option | Scope | Path correctness | Conditional | Cross-platform | Continuity | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 5 | **100** |
| B | 5 | 5 | 5 | 4 | 2 | 92 |
| C | 3 | 2 | 4 | 3 | 2 | 57 |
| D | 1 | 5 | 1 | 5 | 3 | 52 |

### Selected option

Select **Option A**. P3 must first perform read-only package, API, audit, and
compatibility discovery. Before editing, it writes the exact expected path
set into retained implementation evidence, comprising all unconditional P3
files plus only:

- `npm-audit-exceptions.json` when a real approved residual exists; and
- a named lint configuration/nested implementation file when a documented
  selected-package API change makes it unavoidable.

The set then becomes immutable for that implementation attempt. Invoke the
exact merged `Test-ExactGitPathSet.ps1` version:

1. before staging, requiring complete changed scope equality;
2. after staging, requiring exact cached equality and no other change;
3. after clean install/audit/lint/hook/workflow validation and generator
   rerun, requiring the same cached set and empty unstaged/untracked set; and
4. from both Windows PowerShell 5.1 and PowerShell 7 evidence.

If discovery later reveals another file is needed, stop, explain/review the
condition, recompute the list, and restart the scope gate rather than editing
outside it.

## `C-CROSS-01` — Instantiate URLs/dependencies during filing

### Options

**Option A — Put placeholder URLs in every draft.** This makes fields visible
but risks filing literal placeholders or fabricated issue numbers.

**Option B — Define an atomic sequential filing protocol.** File P1, capture
its real URL, insert it into P1A and create the GitHub blocked-by relationship,
then repeat through P3. Verify each relationship before filing the next issue.

**Option C — File all five first, then perform one bulk backfill.** Real URLs
become available quickly, but a failure/interruption leaves successors filed
without required dependencies and implementers may start early.

**Option D — Use title-only prose and rely on project ordering.** This loses
GitHub's explicit dependency relationship and immutable issue identity.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Real URL/identity integrity | 30 | Drafts must not invent identifiers; filed issues must not retain placeholders. |
| Mechanical blocked-by correctness | 30 | Sequential implementation depends on actual GitHub relationships. |
| Cold operator procedure clarity | 20 | A filer should execute the sequence without guessing when to edit or verify. |
| Interruption/partial-filing safety | 15 | No successor should be available without its predecessor dependency. |
| Administrative effort | 5 | Extra filing steps are acceptable for correctness. |

| Option | Identity | Dependency | Procedure | Interruption safety | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 2 | 4 | 2 | 5 | 45 |
| B | 5 | 5 | 5 | 5 | 4 | **99** |
| C | 5 | 4 | 3 | 2 | 4 | 76 |
| D | 2 | 1 | 2 | 2 | 5 | 37 |

### Selected option

Select **Option B**. Keep draft issue bodies free of fake URLs. Give each
successor a `Dependencies` section with a filing gate that says, in
implementation-ready terms:

1. file the predecessor;
2. copy its canonical PSStyleGuide issue URL into the successor;
3. create the real GitHub `blocked by` relationship;
4. retrieve both issues and verify repository/number/title/relationship;
5. only then file or mark the successor ready; and
6. at implementation start, add the exact predecessor merge commit and
   retained evidence links.

File in P1, P1A, P1B, P2, P3 order. A forward informational reference such as
P2 saying P3 follows may remain title/P-label prose until P3 exists; after P3
is filed, backfill its real URL without treating it as a P2 prerequisite.
Retain a filing checklist with the five canonical URLs and four verified
blocked-by edges.

## `C-CROSS-02` — Keep predecessor evidence in successors

### Options

**Option A — Apply one successor-start/predecessor-handoff rule everywhere.**
Each issue closes on its own proof package; its successor records receipt of
the exact merge commit/evidence before editing.

**Option B — Require both predecessor and successor to prove receipt.** This
duplicates ownership and leaves predecessor acceptance temporally impossible.

**Option C — Put all merge commits in a central slate manifest.** A manifest
can aid program management but becomes another mutable authority and does not
place prerequisite checks where implementation occurs.

**Option D — Let successors use whatever is on `main`.** This is convenient but
does not prove they consumed the reviewed merge rather than a later drifted
state.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Temporal/causal correctness | 35 | Only a successor can prove receipt of a predecessor merge. |
| Immutable baseline traceability | 30 | Every implementation must bind to exact commits and retained evidence. |
| Independent issue closability | 20 | Completed work should not wait on an unstarted successor. |
| Cross-slate audit consistency | 15 | The same rule should govern P1→P1A→P1B→P2→P3. |

| Option | Causality | Traceability | Closability | Consistency | Total |
| --- | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | **100** |
| B | 2 | 5 | 1 | 3 | 57 |
| C | 4 | 4 | 5 | 3 | 81 |
| D | 2 | 1 | 5 | 2 | 46 |

### Selected option

Select **Option A** as a slate-wide editing rule:

- P1 acceptance contains no P1A action.
- P1A Dependencies records P1's exact merge/evidence; P1A acceptance contains
  no P1B action.
- P1B Dependencies records P1 and P1A exact merges/evidence; P1B acceptance
  contains no P2 action.
- P2 Dependencies records P1B's exact merge/evidence.
- P3 Dependencies records the exact P1/P1A/P1B/P2 chain and active risk
  decision.

Each predecessor ends with a non-acceptance `Handoff` paragraph listing the
evidence package it makes available. Each successor verifies commit
reachability, expected file/script/policy versions, and absence of unresolved
reciprocal blockers before editing. This yields immutable traceability without
cross-temporal checklist items.

## `C-CROSS-03` — Give counterpart stable IDs one meaning

### Options

**Option A — Use one shared semantic catalog and separate names only for real
repository-specific cases.** P1A ports T1A's shared IDs/oracles; unique cases
use explicit `PS-*` or `TF-*` identifiers and reciprocal rationale.

**Option B — Prefix every ID with P or T.** This prevents literal collisions
but sacrifices the useful ability to compare the same security behavior by
one stable name.

**Option C — Keep duplicate IDs with different meanings and explain them in
the reciprocal matrix.** Reviewers and automation can still confuse results;
an explanation does not repair ambiguous identifiers.

**Option D — Let each repository evolve independently.** This minimizes
coordination but undermines the requested thoughtful generator/security-layer
convergence.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Unambiguous stable-ID semantics | 35 | A result ID must identify one fixture/phase/state behavior everywhere. |
| Reciprocal evidence comparability | 25 | Parallel authors need direct same/difference/blocker mapping. |
| Honest repository-specific variation | 20 | Manifest/source/hook differences should remain possible without semantic overload. |
| Independent implementation freedom | 10 | Convergence should not force a shared runtime package. |
| Migration effort | 10 | Renaming/rebaselining results costs work but is one-time. |

| Option | Semantics | Comparability | Variation | Independence | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 3 | **96** |
| B | 5 | 2 | 5 | 5 | 3 | 81 |
| C | 1 | 2 | 3 | 5 | 5 | 49 |
| D | 1 | 1 | 5 | 5 | 5 | 52 |

### Selected option

Select **Option A**. The shared catalog owns common digest, archive, path,
manifest-shape, extraction, resource, context, cleanup, script-identity, and
label semantics. P1A adopts T1A's current row meanings, including aligned
`K-03` repeated candidate cleanup and `C-03` unknown caller entry.

The exact four expected filenames are row parameters, not a different
semantic ID. When a case truly exists only in PSStyleGuide, allocate a
`PS-*` ID; Terraform-only cases use `TF-*`. The reciprocal matrix records the
exact commits, evidence, and rationale for each unique case.

Harness summaries include catalog version plus ID. Cross-repository comparison
fails if the same shared ID has different fixture, expected phase/status,
cleanup state, or applicability. No shared runtime package or cross-repository
code import is required.

## `C-CROSS-04` — Retain one external event owner

### Options

**Option A — Keep `build.yml` as sole event owner through P1B and P3.**
`markdownlint.yml` remains call-only; P3 adds schedule/manual to `build.yml`
with event-conditioned read-only subgraphs.

**Option B — Let `markdownlint.yml` regain schedule/manual ownership in P3.**
This isolates dependency runs but recreates independent runs and two event
policies.

**Option C — Create a new dispatcher workflow and make both existing files
callable.** Architecturally clean in theory, but adds a third workflow and
forces a second major graph migration after P1B.

**Option D — Allow both workflows to own PR/push and depend on branch
protection.** This cannot give P1B approval one same-run dependency graph.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Same-run dependency coherence | 30 | Preparation, Markdown, matrix, and approval need one job graph. |
| Privileged-publication isolation | 25 | Event variants must not accidentally reach writer authority. |
| Ability to add schedule/manual safely | 20 | P3 must extend events without dismantling P1B. |
| Required-check/operator coherence | 15 | Contributors should see one authoritative workflow graph. |
| Topology simplicity | 10 | Fewer event owners and migrations reduce policy surface. |

| Option | Coherence | Isolation | Evolution | Check UX | Simplicity | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 5 | **100** |
| B | 3 | 5 | 4 | 3 | 3 | 74 |
| C | 5 | 5 | 5 | 4 | 2 | 91 |
| D | 1 | 2 | 1 | 2 | 3 | 32 |

### Selected option

Select **Option A**. P1B establishes the enduring ownership rule:

- `build.yml`: all external events and event-to-job policy;
- `markdownlint.yml`: local `workflow_call` only, no external event;
- terminal approval: exact same-run dependencies; and
- final writer: eligible only on approved changed push-to-main.

P3 extends only `build.yml`'s event map. Its structural validator proves
schedule/manual can call only dependency validation and read-only terminal
result. Acceptance in both P1B and P3 rejects any second workflow containing
`pull_request`, `push`, `merge_group`, `schedule`, or `workflow_dispatch`
unless a future separately reviewed architecture explicitly replaces this
contract.

## `C-CROSS-05` — Retain one workflow-policy validator

### Options

**Option A — Introduce one tracked validator in P1 and evolve it in P1B/P3.**
Stable policy IDs and fixtures change atomically with each sanctioned graph.

**Option B — Use temporary P1 tooling, then create the permanent validator in
P1B.** This matches the original issue boundary but leaves a tooling/evidence
transition and duplicates the initial role-policy work.

**Option C — Give each issue its own validator.** Issue-local code can be
tailored, but later contributors cannot know which program is authoritative.

**Option D — Use only a general external linter.** Generic schema checks do not
enforce repository-specific roles, outputs, hashes, and write predicates.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Single authoritative policy program | 35 | Merge protection and future updates need one source of truth. |
| P1→P1B→P3 enforcement continuity | 25 | There should be no untracked or unenforced graph transition. |
| Repository-specific invariant coverage | 20 | Exact action roles, hashes, outputs, events, and writer paths are essential. |
| Locked parser/package lifecycle | 10 | P3 must deliberately retain/update the reviewed parser. |
| Added maintenance burden | 10 | One evolving program is cheaper than parallel validators. |

| Option | Authority | Continuity | Coverage | Parser lifecycle | Burden | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 5 | **100** |
| B | 5 | 3 | 5 | 5 | 3 | 86 |
| C | 1 | 2 | 5 | 2 | 1 | 43 |
| D | 2 | 2 | 2 | 3 | 4 | 46 |

### Selected option

Select **Option A**. The enduring path is
`.github/workflows/Validate-WorkflowPolicy.mjs`; it has one script version,
stable policy-ID namespace, locked reviewed YAML parser, and immutable
positive/negative fixture catalog.

- P1 adds the program for the temporary writer.
- P1B atomically replaces temporary graph expectations with the local call,
  hashes, matrix mapping, approval, and final writer.
- P2 consumes the exact merged validator without changing workflows.
- P3 deliberately updates the same program/parser for finite Node roles and
  schedule/manual no-publication paths.

Every issue records the prior/final validator digest and fixture totals.
Acceptance rejects a missing validator invocation, skipped negative suite,
second policy program, parser removal, or unreviewed schema relaxation.

## `C-CROSS-06` — Use explicit-key/default terminology consistently

### Options

**Option A — Standardize two named role-table concepts across P1/P1B/P3.**
Every role has `Exact explicitly declared inputs` plus `Reviewed effective
defaults at pinned manifest`; validators apply the appropriate equality rule.

**Option B — Require every possible input to be explicit everywhere.** This
creates noisy YAML and cannot express implementation defaults outside action
inputs.

**Option C — Discuss only explicit YAML and rely on SHA pinning for defaults.**
Reproducible, but reviewers can overlook token, clean, cache, extraction, or
overwrite behavior inherited from manifests.

**Option D — Record manifest snapshots without connecting them to roles.**
The data exists but does not show which omitted default is effective for which
action use.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Cross-issue semantic consistency | 30 | P1, P1B, and P3 must not use “complete” to mean different things. |
| Effective security-behavior visibility | 30 | Token/cache/clean/extraction defaults affect real execution. |
| Atomic action-update review | 20 | Dependabot changes should trigger explicit keys and defaults review together. |
| Human table readability | 15 | A reviewer should distinguish authored YAML from inherited behavior quickly. |
| Terminology migration effort | 5 | Renaming columns is inexpensive. |

| Option | Consistency | Visibility | Update review | Readability | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 5 | **100** |
| B | 3 | 3 | 3 | 2 | 2 | 56 |
| C | 4 | 2 | 3 | 4 | 5 | 65 |
| D | 3 | 3 | 2 | 2 | 4 | 54 |

### Selected option

Select **Option A**. Apply this vocabulary without exception:

- **Exact explicitly declared inputs** means the literal `with` key/value set
  present in workflow YAML. Missing/extra/wrong keys fail.
- **Reviewed effective defaults at pinned manifest** means omitted manifest
  inputs and other documented defaults that affect the role. A pinned
  manifest digest/default change fails review.
- **Prohibited role/input** means an action use or explicit key outside the
  role table; it does not pretend omitted manifest defaults vanish.

P1 establishes the format, P1B replaces the temporary role inventory while
retaining the format, and P3 atomically updates Node roles/default records.
Validation fixtures cover an extra explicit key, omitted required explicit
key, changed explicit value, changed test-manifest default, unknown manifest
input, and action update whose tag/SHA/comment/default evidence is not updated
together.

## `C-CROSS-07` — Re-resolve action tags twice

### Options

**Option A — Re-resolve immediately before implementation and immediately
before merge.** Record tag target/provenance/manifest each time; any target
change stops merge for renewed review.

**Option B — Resolve only at implementation start.** This catches stale
planning values but leaves a review-to-merge time-of-check/time-of-use window.

**Option C — Resolve the release tag live on every CI run.** Continuous
detection sounds strong but introduces network/mutable-tag dependency into
otherwise deterministic validation and could fail unrelated builds.

**Option D — Use release tags directly in workflow YAML.** Dependabot-friendly
but loses the immutable full-SHA guarantee.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Immutable supply-chain assurance | 35 | Workflow YAML must execute reviewed commits from intended repositories. |
| Tag-movement TOCTOU control | 25 | A tag can move between planning, implementation, and merge. |
| Retained provenance auditability | 20 | Reviewers need exact release/tag/commit/manifest evidence. |
| Deterministic runtime/offline CI | 10 | Ordinary runs should not depend on live tag resolution. |
| Reviewer operational burden | 10 | Two checkpoints are modest relative to action privilege. |

| Option | Immutability | TOCTOU | Provenance | Determinism | Burden | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 4 | **98** |
| B | 5 | 2 | 4 | 5 | 5 | 81 |
| C | 5 | 5 | 4 | 1 | 2 | 82 |
| D | 1 | 1 | 2 | 4 | 5 | 38 |

### Selected option

Select **Option A**. P1 and P1B, and P3 whenever it retains/changes roles, must
perform two explicit provenance checkpoints. For every official action:

- resolve the reviewed release tag from the intended repository;
- record full commit SHA, tag object/target, release URL/date, repository
  ownership, and whether the tag is annotated;
- inspect the commit/release diff and security-relevant implementation;
- record exact `action.yml` URL/digest, input/default/runtime metadata, and
  adjacent YAML release comment; and
- ensure workflow YAML uses only the full SHA.

Repeat immediately before merge. If the tag target, release metadata,
manifest digest/defaults, or repository provenance differs, stop and rerun
review/fixtures; never silently substitute a new SHA. Retain both timestamped
records in PR evidence. Ordinary CI validates the recorded immutable
SHA/manifest contract offline and does not resolve tags live.

## `C-CROSS-08` — Reuse one NUL-safe affected-file gate

### Options

**Option A — Add one tracked PowerShell 5.1 raw-path verifier in P1 and reuse
it through P3.** Each issue supplies its own exact expected set/mode; one
fixture suite owns Git process capture and NUL parsing.

**Option B — Write an issue-specific path gate five times.** Each can match its
scope, but subtle differences in decoding, rename handling, untracked files,
and staged checks are likely.

**Option C — Use a third-party path-scope action.** This adds an external
action/permission/input role and may expose normalized rather than raw Git
pathnames; local implementation still needs Windows PowerShell evidence.

**Option D — Rely on reviewer diff inspection.** Visual review is valuable but
not an exact fail-closed scope gate.

### Finding-specific rubric

| Criterion | Weight | Why it matters here |
| --- | ---: | --- |
| Raw pathname correctness | 35 | Every issue's allowed-file boundary must resist quoted/newline/rename ambiguity. |
| Slate-wide behavioral consistency | 25 | P1, P1A, P1B, P2, and P3 should apply the same definition of path equality. |
| Negative-fixture depth | 20 | Tricky filenames and mixed index/worktree states need one maintained suite. |
| PowerShell/OS portability | 15 | The verifier must run under Windows PowerShell 5.1 and PowerShell 7 on both OS families. |
| Maintenance cost | 5 | One stable tool minimizes repeated security-sensitive code. |

| Option | Correctness | Consistency | Fixtures | Portability | Maintenance | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 5 | 5 | 5 | 5 | **100** |
| B | 4 | 2 | 2 | 3 | 1 | 56 |
| C | 3 | 3 | 3 | 2 | 3 | 57 |
| D | 1 | 1 | 1 | 2 | 5 | 27 |

### Selected option

Select **Option A**. P1 adds
`.github/workflows/Test-ExactGitPathSet.ps1` and its disposable-repository
fixture suite. The public command accepts:

- explicit repository root;
- explicit expected repository-relative path array;
- closed mode `Working`, `Staged`, or `Both`;
- optional requirement that the working/index difference be empty; and
- no ambient current-directory, glob, recursive enumeration, or text-decoded
  native output.

It resolves Git exactly, captures raw bytes with
`System.Diagnostics.Process`, uses NUL-delimited commands with `--no-renames`,
validates record termination/cardinality, and compares exact expected ASCII
bytes ordinally. It preserves native exit and emits stable missing/unexpected/
malformed categories without printing hostile raw path bytes unsafely.

P1 validates/adds this tool; P1A and P1B consume its exact predecessor version;
P2 uses it for all six-file gates; P3 uses it with the frozen computed scope.
Each issue records expected paths and invokes the tool before staging, after
staging, and after final rerun as applicable.

## Evaluation completion

All 42 unresolved PSStyleGuide findings have an options analysis, unique
weighted rubric, score table, and implementation-ready selection. The selected
remedies form one coherent architecture:

- P1 establishes the risk gate, deterministic generator, tracked workflow
  validator/parser, exact path-set verifier, honest token boundary, and
  temporary-writer evidence method.
- P1A ports the complete shared T1A oracle catalog and exact context/skip
  lifecycle.
- P1B establishes one event owner/local call, four-hash data flow, unique
  attestations, final validator policy, and verified writer.
- P2 remains a six-file documentation issue and consumes the exact P1B/path
  interfaces.
- P3 adds continuous dependency governance, pure Node/audit policy modules,
  finite runtime/npm policy, at-most-30-day exceptions, and retained workflow
  enforcement.

The five issue bodies consume these selections in execution order:
P1→P1A→P1B→P2→P3. They remain handoff-ready specifications without revision
labels or change-history commentary.
