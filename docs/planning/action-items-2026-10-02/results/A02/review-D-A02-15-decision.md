<!-- markdownlint-disable MD013 -->
# D-A02-15 — self-consistent baseline setup for finalization tests

Design only; parent publication/release is pending. Requested gpt-6-astra/high; effective settings unavailable. No tests, product/native/planning writes or descendants by this assessor. No earlier D-A02-15 record was found. This record supersedes its unpublished narrower date-only draft.

## 1. Validated linked findings

Read STATUS first, the selected D14 validation addendum, F2 caller decision, bounded production and SelfTest sections, and the evidence below. Three fixture assumptions fail independently. None justifies a production waiver.

1. **Inherited date.** Assert-AuthorFinalizationGitFixture preserves source STYLE_GUIDE.md in its hypothetical installed B, then creates yesterday's meaningful versioned H. It expects Now rejection specifically for Last Updated and delayed ordinary acceptance. A legitimate today-dated source makes H backward. Production correctly returns the Version-date diagnostic before checking the finalization flag; its omission mutant also remains rejected. The parent's actual-helper probe constructs B20261002/H20261001 and reports `STYLE_GUIDE.md Version date must not move backward from 20261002 to 20261001.` I inspected its bounded tail and the production early return. The writer independently confirmed this. The first broad probe-source read was truncated; no full-file read or independent execution is claimed. The same fixture casts an inherited revision to int although production supports int64; independent fixture revision0 also removes that setup dependency.
2. **No-op initial commit.** A complete committed source already contains the copied checker/caller inputs. The existing unconditional initial fixture commit then has no change. Parent's exact full-fixture run on source `6da2bdf3ed37a4c21efac47334cccf0a9388554d` exits1 at `Finalization fixture commit failed.` I read `D15-parent-current-guide-actual-caller.log`, its receipt/harness tail, and source HEAD. This result stops before the date case; it is not a full-caller date reproduction. The receipt records script SHA256 `9279341017b054efddb6b3a796dd0d7dcb3a5042da11cd5234cfa301971eb069` and log SHA256 `c782302644279967ad81f84ee457910da8fa4e37c667b94a618cda8bd195645b`.
3. **Incomplete installed inputs.** The D14 native-B aggregate first pass fails in the first F2 Now-positive because its inner clone retains native root-only .gitignore. The copied candidate checker correctly requires recursive personal-memory exclusion. I read the entire bounded `D14-precommit-final-pass1.log` and receipt. Outer HEAD=B48f4; its 71-path candidate tree `931389bc5efffba6413788b6b1ce5885437f0cff` and raw identities are unchanged; exit1. This is the missing ignore input, not the date failure. Earlier addition of the manifest to the overlay was insufficient.

Inspected source SHA256: validator `ba8dc366bd8e5d28a90b43e3d275bb610b23da4457392e923de78264bb0ee29e`; SelfTest `3fb3d24c0ca6b386eb4dedddbae0e86687fa65cf25584ceaf0996d4a6862d567`; helper probe `22bcef07bcaefcc81cbe84800ae593c25772561d0dc43ff09f32d68c3a25b2a6`. These are old inputs, not acceptance of a repair. The separate uncommitted-source complete date-caller probe is now terminal. I read its receipt and bounded log: source HEAD194864b466398bccb34f372a824f7506432f57aa, actual F2 Now=True/Later=False/Accept=False fails for the backward-Version-date diagnostic instead of the required Last Updated diagnostic, after its earlier cases. Receipt exit1, script SHA256 `d86ba124be1cd6a842e96b67b883a374b9e0d3f258ee260d1218c642a0317fe4`, log SHA256 `c4786efb145f021d78b8e94a9755777db9241cd5fdc599022953cc0a8cfdd71b`. That run does not reach delayed ordinary verification; the direct helper separately proves that inherited-date pair is invalid there. This is distinct from the committed-source setup failure.

The checker reads the classification manifest, tracked inventory, .gitignore, governed documents and repository-wide contracts. Its existing Read-GitTrackedPath with empty Revision uses bounded NUL-delimited `git ls-files --cached -z`. A six-file overlay (existing five plus .gitignore) addresses the two observed missing files, but not the supported local case in which a staged classification manifest refers to a newly staged file absent from source HEAD. Copying a manifest without its current path inventory is not a self-consistent installed policy. This supported staged-candidate interface, rather than hypothetical unrelated future rules, distinguishes complete tracked materialization from another literal-list extension.

The parent-integrated compact reproduction record is `results/A02/D15-supported-source-reproduction.json`; it preserves the three distinct reached failures and source/harness/log identities. No probe remains pending in this decision.

## 2. Stakeholders

The owner and sole writer need bounded test changes without implied authority. Documentation authors need valid same-day source changes and backward-date protection. Security and independent reviewers need meaningful actual-caller mutation controls, not failures caused by incomplete setup. CI/Windows/Linux maintainers need committed, staged-native-B and shallow-checkout inputs to work consistently. The maintainer responsible for cost needs existing Git/path primitives, not a new framework. No cloud/state, credentials, privacy, accessibility or localization behavior changes; actual guide bytes and production semantics stay outside scope.

## 3. Options before scoring

All repair options retain production and real-native-B checks. They must also handle the initial no-op setup explicitly.

- N: no change. All demonstrated setup defects remain.
- A: keep the existing private clone; materialize its source's complete bounded current tracked candidate (index path set/modes, current file bytes); normalize only private guide metadata to day-2/revision0; reuse source HEAD when staged setup is identical, otherwise commit B. Keep later candidate commits strict.
- S: extend the literal overlay to six files, plus date normalization and initial HEAD reuse. Small current repair, but a staged manifest/new-path pair can still be incomplete.
- I: initialize a fresh repository from the complete tracked candidate and commit B. Avoids no-op initial commit but changes topology/acquisition unnecessarily; the existing clone and endpoint fixture already work without requiring new history.
- E: same complete snapshot/date normalization as A, but allow an empty initial B commit. Can be correct, but no consumer needs B to differ from the seed commit. A dummy nonce file is a larger variant with irrelevant data. Never allow empty candidate commits globally.
- D: derive a stale candidate from source dates or skip it when impossible; repair other setup inputs. No stale non-backward date exists when inherited B is today. Skipping loses the required case on ordinary authoring days.
- H: replace actual-caller coverage with self-contained helper tests. Avoids repository setup but fails to detect lost forwarding in the real caller.
- R: build a new minimal guide/repository fixture and copied policy stubs. Could work; duplicates supported repository shape and loses actual-source integration. Reusing the real tracked snapshot with two normalized fields is smaller in maintenance scope.
- W: weaken backward-date checks, change actual guide dates, accept any failure, skip assertions, or change production baseline/API. Violates the selected contract. A new shared snapshot/date framework has no additional consumer and is outside this repair.

## 4. New rubric and scores

Scores1–5: fails, weak, partial, adequate with a stated limit, directly meets. Total=sum(weight × score)/5. Weights: actual-caller/mutation discriminator35%; controls and honest evidence30%; complete supported source/setup independence20%; maintenance surface10%; operational simplicity5%.

Hard constraints: no production or actual guide edit; no backward-date waiver; no skipped necessary regression; no hypothetical B relabeled native authority; no untracked/cache copying, source .git copying or unsafe path materialization; no generic public framework; no acceptance of old validation bytes.

| Option | Caller35 | Controls30 | Independence20 | Surface10 | Operation5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 4 | 1 | 5 | 3 | 48 |
| A | 5 | 5 | 5 | 4 | 4 | 97 |
| S | 4 | 5 | 2 | 5 | 5 | 81 |
| I | 5 | 5 | 5 | 3 | 3 | 94 |
| E | 5 | 5 | 5 | 3 | 4 | 95 |
| D | 3 | 4 | 2 | 4 | 4 | 65 |
| H | 3 | 3 | 5 | 4 | 4 | 71 |
| R | 4 | 4 | 5 | 2 | 3 | 79 |
| W | 1 | 1 | 4 | 1 | 1 | 32 |

Arithmetic checked for all nine rows. A's discriminator is a source-complete installed fixture while retaining existing Git topology and requiring no empty commit. I and E offer no extra assertion or trust property: caller checks need exact B/H and meaningful changed H, not a new seed/B distinction. These concrete redundant operations distinguish the options objectively; numerical closeness is not the selection rationale. S's smaller literal list does not close the current supported staged-input interface.

## 5. Select A — controlled scope

Change only Assert-AuthorFinalizationGitFixture and directly necessary private setup in Test-AgentInstructions.SelfTest.ps1. Keep the existing clone, actual CLI, endpoint guards, dependency setup and cleanup controls. Replace the five-file overlay with one bounded current-tracked snapshot using existing Git/path primitives. Do not create a reusable public loader or alter production readers.

Enumerate the source index's complete tracked path set with bounded NUL-safe acquisition. Use its intended Git modes and current regular-file bytes; do not silently substitute HEAD blobs for modified files. Preserve the fixture's own .git control data. Exclude untracked/ignored files and node_modules from product materialization. Keep the existing explicit locked-package provisioning separately. Remove only clone-tracked paths absent from the snapshot. Reject unresolved index entries, unsafe/colliding paths, unsupported modes or inconsistent missing inputs rather than silently omitting them. Preserve relevant executable modes when indexing. Use existing containment/refusal and native-exit checks. Compare source snapshot and destination path/blob/mode/raw identities before the intentional fixture-only normalization. Recheck source stability; this is a private snapshot, not permission to stage the source worktree. A staged new classified path must travel with its manifest.

Capture one UTC DateTimeOffset for fixture data. Derive current day, day-1, day-2 and day+1 with date arithmetic. Derive the existing simulated later-clock expectation from the same value where needed. Do not change production time or add a public clock parameter.

Before establishing the private installed B, require exactly one supported Version and Last Updated field in its copied guide. Preserve body and major/minor. Set only fixture Version to `major.minor.<day-2>.0` and Last Updated to the matching ISO day. Use anchored field replacements, not body-wide date replacement. Stage the complete intended private setup. Compare its index tree with source HEAD's tree, checking Git exits. If equal, use exact HEAD as B. Otherwise commit B with the existing fixture mechanism. Do not add allow-empty to the candidate commit helper or hide a failed commit. Record that a reused B is assumed installed fixture policy, not an independently accepted native commit.

Build the meaningful stale versioned H at day-1/revision0 with the existing rendered prose change. It is newer than B but stale for Now. Keep specific finalization-date rejection, delayed ordinary acceptance and explicit limited status. Build current H at day0/revision0 and retain Now acceptance. Remove only the source-dependent int-cast/same-date increment construction; all three fixture dates are deliberately distinct. Keep production revision arithmetic untouched.

Keep the require-date omission mutant: it must accept the otherwise valid stale H, proving the unmutated caller's flag matters. Preserve delayed-clock/status mutations, mode/endpoint guards, promotion/new/local cases and genuine backward-date negatives. A live unshimmed caller crossing midnight may correctly reject yesterday's prepared data; report that failure and rerun the whole fixture with fresh data. Do not suppress it.

## 6. Verification before acceptance

After publication/release, combine the dimensions into three meaningful actual-fixture scenarios: (1) fully committed complete source with a current-day guide and a large valid revision; (2) already normalized day-2 source with exact no-op B reuse; (3) staged native-B complete candidate plus a valid newly staged classification/path pair, under shallow object availability where feasible. Initial B reuse must succeed in scenario2 while every meaningful H remains distinct. These scenarios cover committed and staged closure, independent dates/revision, and no-op setup without separate multi-minute runs for every overlapping dimension. Check source/raw/mode preservation and unsafe/unsupported materialization refusal with the existing bounded primitive controls. Reuse unchanged exact-input backward-date negatives and production-hash evidence where applicable; rerun only affected behavior. Do not create a generic test matrix.

For every valid setup, require stale Now to fail specifically for finalization date, identical stale B/H delayed ordinary mode to pass with limited status, current Now to pass, and the omission mutant to prove lost forwarding. Retain a genuinely backward ordinary H rejection. Verify the outer guide and production-validator hash remain unchanged. Preserve real native48f4 census/comparison as separate evidence; a full private candidate baseline does not replace it.

Preserve the separate parent date-caller result with its actual reached failure and unexecuted delayed case stated accurately. Run the relevant shallow-context and F1/F3 focused checks, refreeze all changed identities, then repeat two full passes through selected D14 native-B/staged-candidate placement. The failed pass and old SelfTest passes do not accept new bytes. No review-clock reset, transfer credit or A02 completion follows from this decision. Next: parent verifies/publishes this record and releases only this test-only scope to the sole writer.
