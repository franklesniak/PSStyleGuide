# PSStyleGuide open-finding evaluations

## Evaluation method

Each finding uses a distinct weighted rubric. Criterion scores are 1–5 and
weighted totals are normalized to 100. Correctness, security truth, executable
cardinality, and cold-reader usability outweigh churn.

## F01 — Literal P1B diagnostic authority

### Options

- **A:** retain prose and select paths during implementation.
- **B:** upload a fixed diagnostic directory.
- **C:** freeze one producer/path/upload row per diagnostic role.
- **D:** remove diagnostic uploads.

### Rubric

| Criterion | Weight | Purpose |
| --- | ---: | --- |
| Structural determinism | 30 | Policy must compare exact literals. |
| Secret/scope containment | 30 | Upload must not broaden after failure. |
| Failure observability | 20 | Useful bounded evidence must survive. |
| Runtime testability | 15 | Producer ordering and size need fixtures. |
| Churn | 5 | Secondary. |

### Scores

| Option | Determinism | Containment | Evidence | Tests | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 2 | 3 | 1 | 5 | 39 |
| B | 3 | 1 | 4 | 3 | 4 | 53 |
| C | 5 | 5 | 5 | 5 | 4 | **99** |
| D | 5 | 5 | 1 | 4 | 3 | 80 |

### Selected resolution

Select **C**. Add two normative rows: Windows cell and writer. Each names the
sole ordered producer, exact `.test-results/p1b/...jsonl` path, create-new
BOM-less UTF-8/1-MiB contract, closed redacted schema, exact collision-free
artifact name, every upload input, and failure-not-cancelled condition. Add a
literal `diagnostic_key` to all four matrix rows. Reject alternate producer,
wrong order/path, glob/directory/second file, oversize/encoding drift,
success/cancellation upload, and primary-result masking.

## F02 — Separate observations from approval

### Options

- **A:** retain one mixed finding object.
- **B:** add provenance flags to each mixed property.
- **C:** separate observed facts, approvals, topology, and evidence by key.
- **D:** approve only an aggregate report digest.

### Rubric

| Criterion | Weight | Purpose |
| --- | ---: | --- |
| Provenance truth | 35 | npm facts and human decisions have different sources. |
| Drift invalidation | 25 | Fact/topology changes must revoke approval. |
| Least approval scope | 20 | Exact residual keys must be governed. |
| Reviewer usability | 15 | Review should show facts versus decisions. |
| Schema cost | 5 | Lower priority. |

### Scores

| Option | Provenance | Drift | Scope | Usability | Cost | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 3 | 3 | 2 | 5 | 44 |
| B | 3 | 3 | 3 | 2 | 3 | 56 |
| C | 5 | 5 | 5 | 5 | 4 | **99** |
| D | 4 | 2 | 1 | 2 | 4 | 51 |

### Selected resolution

Select **C**. The exception root has exact `ObservedFindings`, `Approvals`,
`AuditNodePaths`, and `FollowUpEvidence`. Observations contain only report/
tree/lock/native facts. Approvals join on exact `(Package,AdvisoryUrl)`, copy
all reviewed factual fields, then add analysis, controls, owner, approval,
expiry, and follow-up evidence. Validate current facts, copied equality,
topology, and governance separately; any drift fails.

## F03 — Allocate every non-audit physical case

### Options

- **A:** keep behavior families and allocate IDs in code.
- **B:** use `(family,platform,runtime)` as a compound runtime key.
- **C:** list every immutable physical ID and singular oracle in the issue.
- **D:** depend on randomized property testing.

### Rubric

| Criterion | Weight | Purpose |
| --- | ---: | --- |
| Evidence cardinality | 30 | One ID must emit one result. |
| Platform/runtime truth | 25 | Applicability must be explicit. |
| Filing completeness | 20 | Implementers cannot invent allocation. |
| Mutation detection | 15 | Regrouping/missing cases must fail. |
| Catalog size | 10 | Secondary. |

### Scores

| Option | Cardinality | Platform | Complete | Mutation | Size | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 3 | 1 | 1 | 5 | 35 |
| B | 5 | 5 | 3 | 4 | 4 | 86 |
| C | 5 | 5 | 5 | 5 | 3 | **96** |
| D | 2 | 4 | 1 | 2 | 4 | 46 |

### Selected resolution

Select **C**. Allocate 16 manager rows across four OS/Node cells, 36 staged/
hook rows across those cells, 18 complete Husky installer rows, and 15
Ubuntu/Node-24 live-capture rows. Each physical record includes applicability,
literal fixture, expected identities/native outcome, side effects, diagnostic,
and one result. Freeze counts and reject missing, duplicate, unknown,
regrouped, skipped, orphaned, unused, or multiply emitted records.

## F04 — Freeze the npm-operation digest

### Options

- **A:** compute an unspecified canonical digest during implementation.
- **B:** hash the Markdown file as a whole.
- **C:** define and publish one exact vector preimage and literal digest.
- **D:** remove digest binding and compare argv only.

### Rubric

| Criterion | Weight | Purpose |
| --- | ---: | --- |
| Cross-consumer identity | 35 | Every surface needs the same authority. |
| Byte reproducibility | 25 | Preimage must be unambiguous. |
| Mutation sensitivity | 20 | Order/whitespace/vector drift must fail. |
| Maintainer clarity | 15 | Cold readers can recompute the digest. |
| Churn | 5 | Secondary. |

### Scores

| Option | Identity | Reproducible | Mutation | Clarity | Churn | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 3 | 2 | 3 | 2 | 5 | 55 |
| B | 2 | 4 | 5 | 2 | 2 | 60 |
| C | 5 | 5 | 5 | 5 | 5 | **100** |
| D | 3 | 5 | 3 | 4 | 4 | 73 |

### Selected resolution

Select **C**. Hash exactly the bytes between the package-vector fences,
starting `ci:`, ending with the LF after `lint:md:nested`, as BOM-less UTF-8
with LF and no fence bytes. The expected SHA-256 is
`bacd645f3b9fd5e2b740d865c64488d6853935de23c05b07639d0c9f02d8dff1`.
Bind wrapper, hook, workflow, validator, harness, and evidence to it.

## F05 — Close live-client retry semantics

### Options

- **A:** perform one attempt only.
- **B:** retry indefinitely using server hints.
- **C:** use bounded attempts with exact header precedence and a hard wait cap.
- **D:** use cached evidence when live reads fail.

### Rubric

| Criterion | Weight | Purpose |
| --- | ---: | --- |
| Fail-closed freshness | 30 | Network failure cannot preserve stale approval. |
| Rate-limit correctness | 25 | Server reset information must be respected. |
| Bounded execution | 20 | Workflow waits/requests need hard limits. |
| Evidence determinism | 15 | Attempts and delays must be testable. |
| Simplicity | 10 | Lower than correctness. |

### Scores

| Option | Fresh | Rate limit | Bounded | Evidence | Simple | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 3 | 5 | 5 | 5 | 90 |
| B | 3 | 5 | 1 | 2 | 1 | 55 |
| C | 5 | 5 | 5 | 5 | 4 | **98** |
| D | 1 | 5 | 5 | 3 | 4 | 59 |

### Selected resolution

Select **C**. Permit three attempts per logical GET, six total requests for
two endpoints. Use canonical integer `Retry-After` first; otherwise use a
canonical reset epoch only for 429 against one captured instant; otherwise use
fixed 1/2-second delays. Cap every required wait at 30 seconds and fail
malformed, duplicate, padded, signed, date-form, zero-remaining-without-reset,
over-cap, exhausted, redirect/auth/network/TLS, or unexpected status. Never
accept cache. Allocate 15 physical live-client cases.

## F06 — Revalidate P1 supply at P1B boundaries

### Options

- **A:** rely on the landed P1 commit without rechecking.
- **B:** rerun only `npm audit`.
- **C:** compare the complete immutable freeze at start and pre-merge.
- **D:** allow P1B to refresh package/lock state.

### Rubric

| Criterion | Weight | Purpose |
| --- | ---: | --- |
| Dependency integrity | 30 | Manifest/lock/tree/producer must stay bound. |
| Advisory truth | 25 | The dated risk decision must match live facts. |
| Slate sequencing | 20 | P3 work cannot leak into P1B. |
| Stop/rebaseline clarity | 15 | Drift needs one deterministic outcome. |
| Effort | 10 | Secondary. |

### Scores

| Option | Integrity | Advisory | Sequence | Rebaseline | Effort | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 2 | 2 | 4 | 2 | 5 | 46 |
| B | 2 | 4 | 4 | 3 | 4 | 60 |
| C | 5 | 5 | 5 | 5 | 4 | **98** |
| D | 3 | 3 | 1 | 1 | 2 | 43 |

### Selected resolution

Select **C**. At P1B start and immediately before merge, compare exact P1
manifest/lock blob IDs and hashes, Node/npm, lock/install producer argv,
installed tree, normalized audit state, and decision. Any registry/advisory/
tree/blob/tool/decision drift stops P1B and rebaselines affected successors.
P1B never edits dependencies.

## Integration trace

| Finding | Issue integration |
| --- | --- |
| F01, F06 | P1B diagnostic table/matrix key and supply-freeze boundaries |
| F02 | P3 observed/approval/topology schema |
| F03 | P3 physical manager/hook/Husky/capture allocations |
| F04 | P3 operation preimage and literal SHA-256 |
| F05 | P3 live retry/header/request budget |

No selected resolution adds, deletes, renames, or reorders an issue draft.
