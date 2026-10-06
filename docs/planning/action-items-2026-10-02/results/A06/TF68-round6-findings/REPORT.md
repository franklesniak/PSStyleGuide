<!-- markdownlint-disable MD013 -->
# TF68 round 6 findings: R16–R18

Read-only proposal for published, unaccepted H `ed9eea201cfd70a88a6b982b29904e2f6206a692`, tree `414509ef0a5f6db3cceab5e6b720fbcbcb3cb4ad`, accepted B `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce`, PS main `98177628b7bc02c646724bfc8aa0fd73fed0cd24`. Authenticated review `5427825804` is observed Lite; Codex `6015355951` is clean. The supplied current dynamic run `37456500523` is cancelled at its 20-minute ceiling and blocks merge. This packet does not change that status or request a retry. Four ordinary CI runs were still live at assignment; root owns later observations.

The exact review comments, complete raw Git blob/mode/size/SHA256 rows, scratch controls, and prior applicable evidence are bound in `evidence.json`. Source and worktree were clean/current at collection. Only this scratch directory was written. No product, metadata, dependencies, Git state, native state, planning, deadline, or counter changed. The inherited transfer counts remain A06/A03/A21/A07 = 1/3/5/5 of 12, deadline 2026-10-13T23:47:31Z.

Each section orders validation, stakeholders, options, rubric, scores, and selection. Scores are engineering judgments on a 0–10 scale, not performance measurements. Total = sum(weight × score) / 10. Ineligible options remain visible but cannot win. Deferral/no-change is represented once per finding; combining it with measurement is separately stated where meaningful.

## R16: Keep structural validation before record emission

Comments: 4194835328.

### Validation

The observation of two scans is correct. The claim that the first scan is redundant is false under the retained output contract. Lines 188–203 reject missing terminal NUL and any empty record before lines 205–213 allocate and emit records. Both scans are linear in byte length; this is not a quadratic algorithm. The actual callers at lines 790–792 pass the complete conversion result to the strict decoded allowlist checker. The private function also has a directly tested success-stream contract.

The exact current file SHA256 `8b59d48ebda6e45e5bf50167d8ce0ee19753efc321dd863014581c33edb38120` equals the file tested for canonical TF68-R8. Its saved final contract proof rejects a missing final NUL and an empty record after a valid prefix with zero emitted objects. A new minimal discriminator executes the actual extracted function and the comment's suggested private single-pass construction on bytes `61 00 00`: actual emits zero; suggested emits byte[] `61` before the same error. This is a concrete regression, not a claim that existing callers accepted malicious data. Allocation/copy failures can still propagate after earlier emissions; the retained guarantee discussed here is structural NUL validation, not universal transactional output.

The precise two-scan suggestion has no earlier dedicated decision. Reuse R8's exact-byte output-contract evidence and A06-D3's strict raw-path admission requirements. Do not reopen the OutputType choice.

### Stakeholders

Security reviewers and wrapper consumers need complete structural refusal before visible records. Test maintainers need real stream behavior. Windows 5.1/7 and Linux users need the same byte-array object boundaries. Contributors need a small readable parser; CI owners need measured, useful performance changes.

### Options before scoring

- A. Keep the two scans; explain why validation precedes output.
- B. Merge validation with immediate per-record emission, as suggested.
- C. Scan once into a private list of byte-array records; emit only after full validation.
- D. Scan once into a list of delimiter spans; validate fully, then copy and emit those spans.
- E. Use a compiled/native delimiter helper with an all-or-nothing result.
- F. Change callers/contracts to allow partial records, or drop late-empty validation.

### Unique weighted rubric

Failure atomicity (40%) means zero success objects for every structurally malformed NUL stream. Raw output/caller fidelity (25%) preserves byte values, per-record byte[] objects, empty results, diagnostics, and downstream allowlist behavior. Cross-runtime reliability (15%) favors the already supported APIs and avoids new compiler/runtime machinery. Clarity and practical utility (15%) asks whether a reader can see the validation boundary and whether added machinery buys a demonstrated benefit. Maintenance cost (5%) covers implementation and meaningful verification scope. B and F fail the first hard constraint regardless of total.

### Scores before selection

| Option | Failure atomicity 40% | Raw output/caller fidelity 25% | Cross-runtime reliability 15% | Clarity and practical utility 15% | Maintenance cost 5% | Total / 100 | Assessment |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 10 | 10 | 10 | 10 | 100 | Preserves the exact observed no-output refusal and simple allocation behavior. |
| B | 0 | 8 | 10 | 8 | 9 | 51.5 | Ineligible: a late empty record exposes an earlier record before throwing. |
| C | 10 | 10 | 9 | 7 | 6 | 92 | Viable, but retains all allocated records and adds collection machinery; no material benefit shown. |
| D | 10 | 10 | 9 | 8 | 7 | 94 | Viable two-phase design; replaces a simple byte scan with retained delimiter metadata. |
| E | 10 | 9 | 5 | 4 | 2 | 77 | Adds runtime/type-loading and deployment obligations for no measured bottleneck. |
| F | 0 | 2 | 6 | 2 | 5 | 19.5 | Ineligible: weakens the retained refusal contract. Caller array capture does not justify changing function output. |

### Selected procedure

Select A. Keep the function and its callers unchanged. Explain that the first scan validates the complete structure before output starts. Link the exact-byte contract proof and the single-pass negative control in the review disposition. Do not add a timing test or a new framework. No product path or metadata edit is proposed.

## R17: Retain the bounded duplicate summary cleanup

Comments: 4194835388, 4194835424.

### Validation

Both comments have identical bodies and form one finding. They are factually correct: the top executive-summary hashtable is stored in the top-section list and under the summary anchor. The cleanup loop visits it twice. Each visit reads the same completed Body and deterministically assigns equivalent CleanBody strings. No emitted section is duplicated by this loop itself; emission is controlled later.

The bounded actual-function probe runs `New-FullPayload` with current TF guide/rationale text and records reference identity at the existing cleanup statement. It sees 64 visits to 63 unique section objects. The only overlap is `## Executive Summary: Terraform Philosophy`, with 23 body lines and 17 cleaned lines. Removing only the observation marker produces identical full output (221,502 characters). These counts are not a wall-clock speedup claim. In this parser, fresh section objects are created for headings; the special summary top object is the single possible top/leaf-index overlap. Repeated cleanup therefore remains linear in input size, although a larger summary can increase its constant cost.

This is distinct from canonical PS234-R5, which proved quadratic repeated full-output-prefix scans under repeated summary boundaries and selected a cursor. That proven fix remains intact. R17 does not reproduce that old growth mechanism, and the current instruction-validation service bottleneck has not been attributed to this generator loop.

### Stakeholders

TF and PS document readers need exact ordering, markers, summary placement, and output bytes. Maintainers need understandable section ownership. Cross-platform contributors need compatible hashtable and identity behavior. CI operators need changes with a useful measured effect; reviewers need truthful operation-count claims.

### Options before scoring

- A. Keep the current loop and record the exact bounded duplicate work.
- B. Skip a section whose newly created object already has CleanBody.
- C. Build a HashSet of section objects, with explicit reference identity, then clean each once.
- D. Build one unique all-sections list during parsing and clean that list.
- E. Make the two cleanup loops disjoint by excluding the shared summary reference from one.
- F. Clean lazily at each emission site or recompute on demand.
- G. Start another timing/profile campaign before deciding.

### Unique weighted rubric

Composition correctness (40%) preserves aliases, marker semantics, heading collisions, order and all four goldens. Supported-runtime fidelity (20%) preserves PowerShell 5.1/7 and Linux behavior without new reference-comparer assumptions. Demonstrated benefit (15%) distinguishes eliminating one known repeated cleanup from fixing proven superlinear work or a measured bottleneck. Reader and ownership clarity (15%) favors direct collection roles over hidden processed-state or more emission paths. Maintenance scope (10%) covers extra state, coupled implementations and verification burden. Scores credit viable optimizations; they do not claim they are incorrect.

### Scores before selection

| Option | Composition correctness 40% | Supported-runtime fidelity 20% | Demonstrated benefit 15% | Reader and ownership clarity 15% | Maintenance scope 10% | Total / 100 | Assessment |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 10 | 8 | 9 | 10 | 95.5 | No output defect or material runtime impact demonstrated; both collection roles remain explicit. |
| B | 10 | 10 | 9 | 8 | 8 | 93.5 | Feasible narrow optimization; turns an output property into a processing-state guard. |
| C | 10 | 8 | 9 | 7 | 6 | 86 | Feasible only after verifying identity semantics and all supported runtimes; adds a set for one overlapping object. |
| D | 10 | 9 | 9 | 7 | 6 | 88 | Larger parser/collection data-flow change; can also clean previously overwritten sections unnecessarily. |
| E | 10 | 10 | 9 | 7 | 7 | 91 | Avoids a set, but embeds the summary-index relationship in a second location. |
| F | 8 | 9 | 6 | 5 | 4 | 70.5 | Moves work and state into multiple output paths and may repeat cleanup for repeated markers. |
| G | 10 | 10 | 6 | 8 | 5 | 86 | Can measure wall time, but present one-section evidence does not justify more runs now. |

### Selected procedure

Select A. Keep the generator unchanged. Acknowledge the one repeated cleanup and its measured size. State that it is deterministic and does not duplicate output. Retain the existing cursor fix. Reconsider a narrow cleanup guard only if supported inputs or profiling show a material cost. Do not claim a runtime improvement or add an unneeded set now.

## R18: Retain the complete before/after key checks

Comments: 4194835467.

### Validation

The common keys are indeed visited twice. The repeated operation is in-memory dictionary membership/value comparison, not another filesystem walk or SHA-256 calculation: `Get-WorktreeFileDigestMap` has already produced the two maps. Both are ordinal `SortedDictionary[string,string]` instances. The loop must cover additions and deletions and must skip only the four exact allowed artifacts when that switch is set. Current complexity is proportional to the combined key visits with sorted-dictionary lookups; a set can reduce constant work but does not repair a demonstrated coverage defect.

A bounded probe executes the exact integrity function with fixed read-only control-surface/map stubs and a visit counter. Three identical keys cause six visits and pass. Changed, added, removed, and case-distinct added keys all fail with the fixed integrity diagnostic. The permitted artifact change passes only with the existing switch. The probe does not execute filesystem snapshotting, a semantic child, or the real wrapper. It validates this comparison loop; existing actual wrapper and platform evidence remains separate.

No exact previous decision for this key-union suggestion was found. A06-D3's complete integrity envelope and ordinal path requirements remain applicable. This is not the measured parser interpretation bottleneck and is not a remedy for the current cancelled service setup.

### Stakeholders

Security reviewers and recovery users need detection of every unauthorized added, deleted or changed path. Authors need correct four-artifact regeneration. Linux/case-sensitive users need ordinal identity. Maintainers need an auditable complete predicate; CI owners need useful improvements rather than speculative speed claims.

### Options before scoring

- A. Keep concatenated keys and the existing complete comparison.
- B. Build a HashSet[string] using StringComparer.Ordinal and compare its union once.
- C. Check all old keys, then only new keys absent from the old dictionary.
- D. Merge the two ordinally sorted key enumerators.
- E. Use a generic sort/unique pipeline without an explicit ordinal equivalence contract.
- F. Check only current keys, only old keys, or counts/digest aggregates.
- G. Add a profile/benchmark before any decision.

### Unique weighted rubric

Integrity coverage (42%) requires additions, deletions, changed digests, and exact four-artifact exception behavior. Ordinal and exception fidelity (23%) preserves case-distinct paths, fixed diagnostics and visible failures. Demonstrated practical value (20%) weighs actual benefits without equating fewer lookups with measured end-to-end time. Audit clarity (10%) favors a single complete comparison over implicit comparer choices or multiple partial passes. Maintenance cost (5%) covers added memory/state and cross-repository validation. E and F are ineligible in their stated forms; an explicit ordinal set is separately evaluated as B.

### Scores before selection

| Option | Integrity coverage 42% | Ordinal and exception fidelity 23% | Demonstrated practical value 20% | Audit clarity 10% | Maintenance cost 5% | Total / 100 | Assessment |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 10 | 10 | 8 | 10 | 10 | 96 | Checks shared paths twice; preserves simple complete coverage with no new set state. |
| B | 10 | 10 | 9 | 8 | 7 | 94.5 | Viable constant-factor reduction, with another allocation and no measured runtime need. |
| C | 10 | 10 | 9 | 7 | 7 | 93.5 | Avoids a set, but splits one integrity predicate into multiple paths. |
| D | 10 | 9 | 9 | 5 | 3 | 87.2 | Can preserve order and linear traversal; adds iterator state and edge cases. |
| E | 6 | 4 | 7 | 6 | 6 | 57.4 | Ineligible as stated: case-sensitive path identity must not be collapsed or culture-dependent. |
| F | 2 | 5 | 5 | 6 | 7 | 39.4 | Ineligible: can lose added/deleted-path coverage or the exact per-path artifact exception. |
| G | 10 | 10 | 6 | 8 | 5 | 87.5 | Potential future measurement; current duplicate checks alone do not warrant another run. |

### Selected procedure

Select A. Keep the comparison unchanged. Acknowledge the repeated common-key lookup. Explain that file hashing is not repeated by this loop. Preserve all integrity cases and the exact artifact allowance. Revisit an ordinal set only if profiling shows a material cost. Do not weaken the key census or claim this resolves the service timeout.

## Validation reuse, boundaries and next action

All proposals are no-change. No new product test or metadata edit is needed to implement those dispositions. Reuse the unchanged R8 final-byte parser/analyzer and raw-record contracts; the current hosted 156 assertions × two runs × three platforms remain current root-collected evidence, not a new run by this worker. The new private extracted-function probe passed native exit 0 on qualified PowerShell 7.6.5. It adds a negative discriminator and operation counts, not a full generator/wrapper/PowerShell 5.1/Linux acceptance claim. It makes no wall-clock or billing claim. Raw source copies equal the current immutable H blobs. The source is guarded again before binding.

If an optimization is selected instead, root must release the exact product scope first. R16 would require malformed late-record no-emission and byte-array boundary controls; R17 would require identity/heading-collision/repeated-marker controls and both languages' four-output goldens; R18 would require ordinal added/deleted/changed/allowed-artifact controls plus actual wrapper children. Applicable final precommit, metadata, review, hosted and peer requirements would then be rebound. No such edit is selected here, so no additional A06 transfer is triggered; existing conditional peer obligations remain.

Primary references: [PowerShell pipeline processing](https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_pipelines?view=powershell-7.5) explains output being processed as generated; the actual private negative control demonstrates why this matters here. [`HashSet<T>`](https://learn.microsoft.com/en-us/dotnet/api/system.collections.generic.hashset-1?view=net-9.0) documents set membership and comparer-based construction; it does not establish that a set improves this workload or prove Windows 5.1 compatibility of a new comparer. Current implementation and exact local probes are the primary evidence for these findings. Earlier canonical decisions reused: A06 design D1/D3; TF68 round3 R8 output contract; PS234 round1 R5 summary cursor and R6 measurement-reporting distinctions. None is misrepresented as an earlier decision on R17/R18 themselves.

One next action: root reviews and displays these three ordered decisions, then posts their evidence-based dispositions if selected. Keep the separate cancelled-setup blocker and runtime remediation work active; do not merge or retry from this proposal.
