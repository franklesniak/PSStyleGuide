# TF68 mutation repair: final source and affected-evidence review

**PASS_REPAIRED_SOURCE_WITH_AGGREGATE_PENDING.** No material findings. Reuses the completed runtime checker and mutation-constructor source reviews; this addendum binds their findings to final bytes and the completed six-case proof.

Final source SHA256:

- `Test-AgentInstructions.ps1`: `9ca8f6ab530f4e1f30a9745d38a4f70d94d48016565e568d15b4a02b4b85b011`.
- `Test-AgentInstructions.SelfTest.ps1`: `1fe8a9b289505421cf207be24a880b0b1dfa8edf97405219babb7a3a20d4c3b9`.

Both matched during review and at report creation. The final SelfTest is exactly the reviewed immutable draft `d4726cd0b6be9655518ababe919aa3071f52fc6c94603fd6664b65da352616dc` with the single unique author-function version line changed from 1.2 to 1.1. No other text differs. Main remains unchanged. Final constructor and full-file parser/analyzer records bind these final hashes and report success with zero parser errors/diagnostics.

## Actual caller evidence

Read the preparation/execution drivers, authorized input manifest, terminal result/status, all six raw stdout/stderr pairs, and root verification. Run `tf68-20261006-mutation-six-one` completed with container and selected-driver exit 0. Native child exits are exactly `0, 1, 0, 0, 0, 1`:

1. Delayed promotion passes and explicitly says finalization date was not verified.
2. Prior-day rendered guide with finalization enabled fails specifically because STYLE_GUIDE.md must use 2026-10-06.
3. The same guide's delayed rerun passes with the limited date-status statement.
4. Current-day guide passes explicit author finalization.
5. The repaired require-date mutant accepts the exact prior-day candidate rejected by case 2.
6. The repaired initial-coverage mutant rejects the exact delayed promotion accepted by case 1, specifically requiring README.md to use 2026-10-07.

Independently compared full command arrays, argument arrays, cwd, and clock for pairs 2/5 and 1/6: all equal. The recorded checker hashes correctly distinguish original and intended mutants. Verified all 12 raw stream hashes, terminal status/result hashes, and eight manifest/driver/guard payload hashes. All stderr streams are empty, so concatenation does not obscure cross-stream order in these cases.

The preparation retains actual fixture setup, candidate construction, caller assertions and unchanged clock helper, selecting six cases and adapting only native capture/bounds. It preserves the original cleanup. The proof uses freshly reconstructed fixture B/H objects; it does not claim replay of deleted historical objects. Ordinary validator bootstrap is separately identified. Actual mutant constructors still alter only their two checked spans, and no production bypass was added.

Full serialized host before/after guards compare equal. Full private before/after guards also compare equal, including 80 source entries, 1,914 dependency entries, HEAD, complete refs, index, Git metadata/configuration and fixture executable mode. The manifest binds candidate tree `414509ef0a5f6db3cceab5e6b720fbcbcb3cb4ad`, published H `5ec4bdc06431de05e93067b0e52f0dfbb1631392`, and accepted B `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce`. This is a prospective candidate tree, not a new accepted commit.

`IMPLEMENTATION.md` and `evidence.json` are preserved preparation-time records; their not-yet-executed statements describe that earlier state. The authorized manifest and later terminal/root-result records establish completed execution. Their chronological difference is not treated as a failure or rewritten history.

## Limits and remaining gates

This closes affected source/caller proof only. The complete mandatory aggregate, normal commit, actual accepted-B/new-H endpoint and current-audit checks, exact body/final acceptance binding, fresh required hosted/review/CI acceptance, and eventual peer gates remain pending. Prior failed validation stays failed history; these expected negative child exits are successful test oracles, not CI waivers. No new performance claim follows from one timing per child. Strict no failed/cancelled-CI landing, round 5, original deadline `2026-10-13T23:47:31Z`, and transfers 1/3/5/5 of 12 are preserved. Reviewer performed no tests, product changes, native operations, or delegation.
