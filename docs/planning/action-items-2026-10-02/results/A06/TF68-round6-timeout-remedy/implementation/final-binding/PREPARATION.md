<!-- markdownlint-disable MD013 -->
# Final-quality preparation: C88.5

Preparation only. Reuse the unchanged [independent source review](../independent-quality/REPORT.md): no material source defect was found on the frozen conversion repair. Its report and evidence remain immutable. No product tests, product edits, Git writes, remote requests, cleanup actions or planning-state edits were performed in this continuation. The final suite was running when root assigned this preparation; this reviewer did not poll it or infer a terminal result.

## One resolved review-facing accuracy correction

The inspected `pr-body-C88-prepared.md` (SHA256 `583fb1ffc9231f0cf8fb88aedf695da5249fc5a204e3da0ac00e3f2320a7241b`), paragraph beginning “Repeated Markdown checks,” says: “Returned values are deep copies; schema and policy checks still run.” A reuse hit returns the copied previously validated context at Test-AgentInstructions.ps1:3775, before the schema checks at 3789-4044. The surrounding per-call description can therefore imply that the schema checks rerun on every hit. This is a body accuracy issue, not a new product defect.

Root applied this exact clarification: “Returned values are deep copies of previously validated context. Fresh conversions retain all schema checks, and downstream policy checks still run.” This reviewer read back the corrected text and draft SHA256 `76bb1f3a0be83be5af41f45034220f0703e05cf669f1ec724b4d5c3ce6c3a211`. The narrow factual correction is resolved; it changes no product behavior or design and requires no test restart. No body or product change was made by this reviewer. Preserve the clarification in the final body at binding time.

## Validation setup and cleanup assessment

Read the complete final-validation `inside.py`, `launch.py`, `ownership.py`, `settlement.py` and `check-receipt-policy.py`; inspected their preparation diff, authorized manifest, readiness record and ten-control result. The packet retains the actual staged preflight, 13-test classifier command and complete all-files pre-commit invocation, with 300/300/3000-second stage caps. It requires all 11 hooks passed and zero skipped hooks, direct zero exit, source/index/dependency guards after stages, actual UTC date consistency, terminal cleanup and confirmed absence of the exact labelled container. No test removal or skip flag is introduced. The setup stages the exact supplied candidate tree over the real parent in a disposable full-history repository while retaining accepted B as origin/main; it does not substitute that parent for the later accepted-B/committed-head finalization check.

The container stays pinned, pull-never and offline. The environment drops inherited credentials, hook skips and arbitrary Git configuration; the source mount is a bounded read-only payload. Hash-checked source/dependency extraction and narrowly declared Husky executable-mode restoration preserve the prior fixture contract. Each container cleanup checks image and unique manifest label. The inherited diagnostic-only launcher docstring and preparation-only prose are stale descriptions of preparation state; the authorized manifest and operative commands make this a final local-validation run, and root already recorded that distinction. They do not establish or prevent a test result by themselves.

The D93 correction is supported by current evidence rather than retroactive reinterpretation. Its result records two current Git zombies, exact successful waits, no signals, empty final ownership and four passed real ownership controls. The final runner reuses the same collector. It leaves each direct Popen object's wait status with its owner, protects unresolved direct PIDs from adopted-child waits, tracks ancestry across session/group escape and retains primary failures when cleanup also fails. The new pure settlement filter accepts only empty ownership or successful already-exited children with matching PID/start-time waits, no signals and no remaining descendants; collection errors, live/unknown children, missing waits and unsuccessful exits fail. Ten focused receipt cases exercise that distinction. No material setup/cleanup finding was identified in this bounded inspection.

The old cold-comparison packet remains failed. Current successful exited-child evidence does not identify its historical unknown states, turn the old packet green or prove hosted completion. The prepared PR body accurately retains those limits and separates local timing from hosted margin.

## Scope, pair and pending final binding

The body retains the complete 19-path PR scope, distinguishes the current two-file conversion from earlier repairs, confines the helper to Markdown, preserves generic callers and describes compilation/name fallback without claiming a new dependency or runtime floor. It retains Windows 7.6.5/Linux 7.6.3 empirical limits, seven faulty-variant controls, failed prior dynamic CI, required fresh reviews and the later PS carryback. The explicit prepared/pending placeholders are appropriate at this stage and are not findings. Historical assertions about earlier PR work are retained context; this continuation does not independently repeat their complete historical validation or remote audit.

Root must supply terminal final-validation evidence, actual committed identity/tree, normal commit-hook result, accepted-base/committed-head endpoint and audit results, and the final PR body/hash before final binding. Reconcile those exact inputs and retain the resolved wording above, plus the existing requirement for current-input reviews and passing CI. Accepted TF/current PS comparison and applicable carryback still remain after landing. No final quality acceptance, CI waiver or paired convergence is declared here.

Identity references inspected (not a new source attestation):

- Frozen candidate tree `e71b81232ba0f197acf5f126e4b14f1e90ee7da2`; source catalog `06283ddd2dcd87c33dbc0e38fcaa17114034c6fcc04ff4dea037af1da4972cff`; original source review reused.
- Final readiness SHA256 `cc70a9ab7870c4c487004c2c1365cecfa4880a960160aefbab53103ace9a00b7`.
- Authorized final manifest SHA256 `775e0aa4d786f27a1e46baf0945f3f435e4b1710684ed7121e4f86c33b7410e4`; run `tf68-ed9-native-converter-final-validation-one`.
- D93 root result SHA256 `c02b8b68f7cf900cbe1f621ab425a257dba42ce05b3faa8516498f59fb14db76`.
