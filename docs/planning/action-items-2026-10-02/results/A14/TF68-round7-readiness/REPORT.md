<!-- markdownlint-disable MD013 -->
# Round7 A14 readiness: Markdown native conversion

**The prior A14 assessment remains applicable. No new material filesystem finding is established.** Retain A14 D92 B96/D93 B100, PS155's open maintainer-owned residual and PS156's retirement limits. TF remains unmerged. This is candidate readiness, not accepted-pair or race-safety proof.

Current TF `89bf3920fb8008752c7f179e7c69c4c2979750d8` / tree `e71b81232ba0f197acf5f126e4b14f1e90ee7da2` has the single parent `ed9eea201cfd70a88a6b982b29904e2f6206a692`. Accepted TF B remains `e21b74fe0b56551008f78f9f2946cd2a0f9c19ce`; accepted PS remains `98177628b7bc02c646724bfc8aa0fd73fed0cd24`. STATUS was read first; its round6 state predates the coordinator's round7 handoff. Local immutable parent/tree evidence agrees with that handoff. No remote state was queried.

## Two-file delta and raw binding

Both changed files retain mode100644. Evidence records raw parent/current/PS identities, complete changed hunk coordinates and the raw diff hash.

| Candidate file | Blob | SHA256 |
| --- | --- | --- |
| `Test-AgentInstructions.SelfTest.ps1` | `07886736b000aeff5d5d431ed31098bcdc4add48` | `dd2aaf7f23e77f00cf264ba1b4b130d34006cec9958f94e24570f2982231415e` |
| `Test-AgentInstructions.ps1` | `67e0c1ce95ff6b99c76f1959b5c284e208b450dd` | `e2a7767f70ffc3d38e9225d7ed6a723d9329135e3b104b3cec9654122ae7d35c` |

`ConvertFrom-ParserJsonContext` adds a Markdown-only opt-in. It walks an already-parsed JsonElement using fixed C# source compiled by Add-Type. JSON values are data, not compiler source. Each call creates its own graph; only code/type identity persists in the process. Name-sensitive objects fall back to the original PowerShell cast. The existing byte limit, JsonDocument options/root gate, disposal and later structural-schema checks remain. The default decoder callers do not opt in. SelfTest adds original/native differential and refusal cases and checks that the actual Markdown caller selects the native path. This worker inspected those changes without executing tests.

The six raw function bodies for safe repository input reading, Node resolution, parser process execution, reuse-slot creation, reuse cleanup and structural deep copying remain byte-identical to the parent. Nine scoped files also retain exact modes/blobs: generator, exact-path verifier, artifact gate, generator harness, build workflow, coding setup, dedicated review setup, instruction workflow and CONTRIBUTING. Thus the prior generator publication, neutral-directory cleanup, child authority and workflow-permission analysis can be reused directly.

## A14 applicability and carryback

The new converter is an in-process JSON conversion facility. It adds no P/Invoke filesystem primitive, handle-relative open/rename/delete, publication consumer, credential, runner or competing-writer requirement. Add-Type introduces runtime compilation/loading work, but this call specifies fixed embedded code and no output-assembly path or new download. It does not change repository path authority. Digest-derived naming and type-shape checks must not be presented as authentication against a malicious same-process actor that can preload arbitrary code; no such new threat requirement is admitted by this delta.

Keep the existing check/read/spawn windows, pathname readback/publication/cleanup, neutral-directory substitution, hardlink/Windows alias limits and same-user authority limits. Memory cleanup and ordinary differential tests do not close those filesystem races. No supported filesystem failure or useful new race-closing primitive was found; no new A14 options/rubric exercise is required.

The conditional PS carryback stays at **ten paths**. These two files already belong to that union. Carry the common converter, its actual Markdown opt-in, and differential/freshness tests together after TF acceptance. The production validator has no language exception. Preserve only the existing narrow SelfTest provenance distinction and genuine destination metadata rules. This update invalidates obsolete two-file prospective hashes, not the previously established path scope. Root must rebind actual landed TF/current PS bytes and review any intervening change before implementation.

Current-head CI and reviews, actual dedicated activation, normal TF landing/landed evidence, conditional PS carryback and reverse comparison remain gates. Old-head platform/runtime results stay evidence for their named inputs; this assessment makes no current-head runtime claim. Reopen A14 for an exact supported failure, admitted concurrent writer/hostile parent, specific useful filesystem primitive, or materially changed caller/privilege/storage authority. Preserve the later R5/recovery and A18/A19 rechecks.

A14 remains0/8. Round7 is supplied by the coordinator; the original deadline2026-10-13T23:47:31Z and A06/A03/A21/A07=1/3/5/5of12 remain unchanged. Root owns state and counter updates.

**Next action:** after actual TF acceptance, bind the landed source/current PS and update the two files within the existing carryback scope, then recheck changed A14 predicates.

Only this report and evidence.json were written. No product/planning/Git/native changes, test execution, review polling/requests or descendants occurred. Evidence SHA256: `74820afb4b6a19bb886de6b86a4676669e78b444dc20f9dbf8e62ed6da415617`.
