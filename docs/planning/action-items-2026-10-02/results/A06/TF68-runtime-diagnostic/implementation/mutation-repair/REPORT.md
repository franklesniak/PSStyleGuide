<!-- markdownlint-disable MD013 -->
# Repaired date-policy tests: focused proof passed

The SelfTest-only repair selected in [the canonical decision](../MUTATION-REPAIR.md) is implemented. Main validator SHA256 `9ca8f6ab530f4e1f30a9745d38a4f70d94d48016565e568d15b4a02b4b85b011` is unchanged. Final SelfTest SHA256 is `1fe8a9b289505421cf207be24a880b0b1dfa8edf97405219babb7a3a20d4c3b9`; the prospective candidate tree is `414509ef0a5f6db3cceab5e6b720fbcbcb3cb4ad`. The two named arguments now change through checked parsed source extents. Original caller assertions and clock controls remain.

Final Windows PowerShell7.6.5 constructor controls passed. Parser and PSScriptAnalyzer1.24.0 reported no errors or warning/error diagnostics. The metadata annotation uses the accepted landing-branch version, with no cumulative in-progress increment. See [implementation and limits](IMPLEMENTATION.md).

One offline Linux PowerShell7.6.3 real-caller proof passed on2026-10-06, ending10:51:49Z. The six expected native results were0,1,0,0,0,1: delayed promotion accepted; stale guide finalization refused; ordinary delayed guide accepted; current-date guide accepted; deliberate require-date fault accepted the stale guide; deliberate initial-coverage fault refused delayed promotion. The original unmodified and faulty caller pairs used identical arguments, working directory and clock. Raw stdout supports each oracle; every stderr was empty.

[Root verification](ROOT-RESULT-VERIFICATION.json) confirms all80source/1914dependency and complete host/private Git identity guards matched. The parent took145.47seconds within210; each native child took15.44–17.87seconds within45; the complete run took166.69seconds within240. These are observed durations, not a speedup claim. The fixture created fresh private B/H objects; no previous ephemeral identity was replayed.

This proof covers the affected caller cases. One final mandatory aggregate, normal commit, actual accepted-base/new-commit checks, current audit, independent final binding, fresh native reviews and successful CI, landing and peer acceptance remain. The earlier failed aggregate remains failed history. No CI retry, product Git write, new review round, transfer or merge occurred. Round5/80, original2026-10-13T23:47:31Z deadline and transfers1/3/5/5of12 are unchanged. No owner action is needed.

[Artifact index](ARTIFACT-INDEX.json) maps each saved file to its original raw hash and local evidence path. Source guard catalogs, driver/specs and raw transport artifacts remain at the indexed source root and its runs directory.
