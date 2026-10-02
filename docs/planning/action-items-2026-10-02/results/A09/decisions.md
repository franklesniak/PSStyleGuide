<!-- markdownlint-disable MD013 -->
# A09 decisions before candidate changes or focused probes

Preparation only. A03/A07 implementation acceptance is pending. PS main48f4d8a and TF main06ad4f7c are the inspected product inputs; A02 PR224 is not accepted input. Requested gpt-6-astra/high; effective settings unavailable. Transfers0/8; no PR clock.

## D1 — stale strict-success fixture after the freeze became optional

Validation: PS test lines2230–2279 and TF2291–2340 copy current workflow manifests, lockfiles, installed tree and historical profile, then invoke strict mode and require native0 and complete=true. Production lines5444–5466 compare the copied bytes with four immutable historical identity constants and exit4 on mismatch. Both current manifest/lock pairs have changed since those constants. This is a deterministic incompatible fixture precondition, not a new vulnerability in the intentional refusal. Historical PS205/TF55 runtime passes used different package inputs. Their full strict-success pass cannot be reassigned to current packages. A bounded source-guard probe will verify the mismatch and positive historical control without npm, network or historical installation.

Stakeholders: both maintainers and optional-diagnostic users need a test that explains current behavior; supply-chain/security reviewers need the refusal preserved; contributors and CI operators need no routine obsolete install; auditors need truthful historical input identity; package maintainers and cost owners benefit from avoiding unnecessary legacy downloads. No cloud/state owner, destructive recovery operator or new platform/UI is involved. Windows users need an explicit syntax/source-bound result, not a Linux success claim.

Options before scoring: A leave the incompatible test and rely on historic passes; B update frozen production constants/profile to current dependencies; C split current refusal/diagnostic expectations from historical strict-success reproduction, retaining existing meaningful negative controls; D delete the whole Linux test; E recreate legacy installed dependencies on every test run. A no longer supports current test acceptance; B rewrites the preserved fact; D loses useful failure/read-only oracles. A bounded test-only synthetic strict fixture may be part of C if it is labeled synthetic and retains production guards; it must not pretend to reproduce historical installed bytes. Existing exact historical pass remains separately reusable only for unchanged inputs.

New rubric: truthful/current test oracle35%, preserved safety30%, practical reproducibility20%, maintenance10%, churn5%. Scores0 absent/contrary,1 severe gap,2 weak,3 adequate with substantial limits,4 strong with a stated limit,5 directly supported for this scope. Totals=sum(weight*score)/5. Hard constraints: no frozen-fact rewrite, no production bypass, no skipped result called pass, no routine historical dependency installation, no unclaimed live audit substituted for a fixture.

| Option | Oracle35 | Safety30 | Repro20 | Maintenance10 | Churn5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 4 | 1 | 2 | 5 | 44 |
| B | 1 | 2 | 4 | 2 | 3 | 42 |
| C | 5 | 5 | 4 | 4 | 3 | 92 |
| D | 2 | 1 | 5 | 5 | 5 | 55 |
| E | 4 | 3 | 2 | 1 | 1 | 57 |

Selection: Use C. Keep the production historical hash guard. Add a current-package mismatch case. Require native4 and empty record output. Keep a positive control using the exact recorded package bytes. Label source-bound and synthetic tests as such. Separate any complete historical installed-tree reproduction from current-package diagnostics. Keep the test's other refusal and mutation checks reachable; do not put all later cases behind a strict-success assertion on current packages. Audit every strict invocation in the large Linux test when splitting it. Preserve missing-object, acquisition and three-group TF tests. Do not install legacy dependencies now.

Probe plan after this decision: execute only the extracted production manifest comparison and refusal block with current versus named historical raw package bytes. Replace process.exit with a captured sentinel. Record observed status and whether output is empty. This proves the guard and fixture mismatch, not whole-recorder Linux execution. Candidate acceptance later needs actual Linux test execution under the supported Node/npm and caller protocol; use deterministic stubs for response/failure tests and keep any live audit explicitly separate.

## D2 — outdated mismatch instruction suggests a mandatory new freeze

Validation: both production line5465 diagnostics say a changed manifest needs a new reviewed freeze. Current PS method explicitly says a dependency change does not require a new historical profile. TF method also labels the diagnostic optional and separates its frozen tuple from active workflow policy. Strict refusal is correct; its repair instruction is misleading after accepted R05. This is a distinct caller-facing defect from the test precondition.

Stakeholders: contributors updating dependencies, maintainers, incident/debug operators and auditors need to distinguish unsupported historical comparison from current supply policy. Security reviewers need no relaxed comparison or renewed advisory grant. CI/release owners need no added mandatory ledger. Documentation readers need an actionable short diagnostic; historical producers' facts must remain intact. No new cloud permissions, service or data path is affected.

Options: A retain current text; B replace the fixed diagnostic with the optional-profile/current-validation distinction; C remove strict mode; D automatically select or rewrite a current profile; E add another manual approval/freeze ledger. No separate broad documentation rewrite is needed. B can include one short current-method clarification wherever its invocation would otherwise imply strict success on current packages.

New rubric: truthful operational guidance40%, preserved refusal/integrity25%, usable next action20%, maintenance10%, churn5%. Same0–5 anchors. Hard constraints: preserve native4 and empty stdout; do not expose untrusted values; do not weaken the tuple; do not imply --any-toolchain is clean/current policy acceptance or extend the old advisory grant.

| Option | Truth40 | Integrity25 | Usability20 | Maintenance10 | Churn5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 1 | 5 | 1 | 4 | 5 | 50 |
| B | 5 | 5 | 5 | 5 | 4 | 99 |
| C | 3 | 1 | 3 | 4 | 3 | 52 |
| D | 2 | 1 | 4 | 2 | 2 | 43 |
| E | 2 | 4 | 1 | 1 | 1 | 43 |

Selection: Use B after prerequisites. Replace the single common line in both helpers with fixed text: "These files do not match this historical profile. Use current locked-install and parser-integrity checks for routine validation. A dependency change does not require a new historical profile." Preserve the historical comparison and status. Explain in each active method that current packages normally differ from the frozen profile; strict refusal is expected, and diagnostic flags produce incomplete observations. Keep external-cache and startup hygiene requirements. Test the new fixed diagnostic in D1's mismatch case. Do not rewrite archived T1 facts or old accepted execution records.

## D3 — converge common recorder code while preserving incompatible historical facts

Validation: complete raw helper diff has34 changed lines in each direction across23 intervals. These are source-history comments, four frozen manifest identities, profile tuple digest, profile labels/method path, and output provenance fields. The security and measurement algorithms are already common. The tests have extra TF three-commit/five-blob provenance cases and factual labels; they must not be reduced to PS's two-blob scope. PS P1 method maps to TF's active CURRENT-PROVENANCE companion, not to the retained T1 archive. Current profile descriptions do not mean that today's package graph has the old profile identity.

Stakeholders: both maintainers and code reviewers need identical shared algorithms; auditors and historical record owners need truthful schemas, producer histories and object sets; optional-tool operators need predictable fixed diagnostics; dependency contributors need current checks independent of this history; security engineers need unchanged initialization order, literal authority and refusal behavior. No cloud/state data or new dependency is involved. Windows/Linux operators must retain unsupported-host and actual Linux boundaries. Cost owners need a small change that does not re-review thousands of unchanged algorithm lines as an invented rewrite.

Options: A retain all distributed labels/data differences as whole-file exceptions; B put the small per-repository constants/provenance descriptor in one closed literal region of the existing self-snapshotted helper, use identical common code and generic fixed diagnostics, and use narrow closed fixture data for tests; C make arbitrary external profiles/plugins executable or selectable; D overwrite one schema/factual history with the peer's; E rewrite the recorder as a new generic framework or remove it. F: retain the exact necessary existing literal/history hunks, align only unnecessary diagnostics and common tests, and record each remaining region by factual role without centralizing it. F is materially distinct from both the whole-file exception A and the centralized descriptor B. A18 permits narrow necessary regions; distributed literals are not a whole-file or algorithm exemption. B does not add a file loader, external import or new ledger. Common algorithm changes unrelated to D1/D2 are out of scope.

New rubric: historical truth35%, exact shared behavior/security30%, reviewer/test clarity20%, maintenance10%, churn5%. Same0–5 anchors. Hard constraints: preserve every historical field/type/value; do not source expected digest from the very object being checked; preserve first self-snapshot and refusal ordering; preserve JSON output distinctions; keep all relevant TF negative groups and native acquisition failures; no routine workflow call or new mutable configuration surface.

| Option | History35 | Security30 | Clarity20 | Maintenance10 | Churn5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| A | 5 | 4 | 3 | 3 | 5 | 82 |
| B | 5 | 5 | 5 | 4 | 3 | 96 |
| C | 3 | 1 | 2 | 2 | 2 | 41 |
| D | 0 | 3 | 2 | 4 | 4 | 38 |
| E | 3 | 2 | 2 | 1 | 1 | 44 |
| F | 5 | 5 | 4 | 5 | 5 | 96 |

Selection revised after independent option-quality review: Use F with D1/D2 after A03/A07 acceptance. The rubric and A–E scores are unchanged. F scores96, equal to B. F has less centralized readability than B (4 versus5), but stronger maintenance continuity and lower churn (5/5 versus4/3). Both preserve historical truth and the same security algorithm. On that tie, prefer F: it avoids new binding/initialization changes without a demonstrated descriptor benefit and preserves the already-reviewed literal/output relationships. This is a qualitative tie resolution, not new empirical evidence or a changed rubric.

Keep each necessary historical pin, schema field, provenance label and factual attribution in its current narrow region. Align the fixed diagnostic guidance from D2 and any other labels that have no necessary historical meaning. Align common tests where the same supported behavior is exercised. Preserve TF's extra three-group provenance cases and all failure oracles. Do not exempt the whole helper, test or document. Maintain an explicit raw region map for the remaining differences. Do not claim identical raw files; claim identical shared regions plus named factual exceptions.

Do not add the centralized descriptor in this repair. B remains a possible later design if actual literal-binding drift, duplicated branching or an accepted new profile consumer creates a demonstrated need. An aesthetic preference for colocated constants is not such a finding. Do not introduce an external profile loader or import anything before the self-snapshot.

Keep both historical JSON files unchanged. Preserve PS historicalAssertions/historicalInstalledTreeRecipe and TF reviewedAssertions/historicalRecordStatus meanings. Keep the independent expected tuple digest and four manifest identities. Do not rename immutable schemas, renew advisory facts or overwrite authentic source history. Map the PS active P1 method to TF's active CURRENT-PROVENANCE companion; retained T1 archive facts remain separate.

Candidate verification: compare raw common intervals and every remaining narrow factual region. Run D1/D2's changed focused tests and supported Linux fixture roles. Preserve unsupported-host evidence separately. Compare profile objects and archive bytes before/after. Recheck no automatic setup depends on historical reproduction. No additional full historical diagnostic run is justified solely by retaining unchanged literals. The scoring is a design judgment, not evidence that an unimplemented candidate passes.
