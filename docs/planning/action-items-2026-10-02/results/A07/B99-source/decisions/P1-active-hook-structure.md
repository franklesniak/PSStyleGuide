<!-- markdownlint-disable MD013 -->
# B99-PROVISIONAL-1: prove active hook structure

**Validated material admission defect; proposal C97.0, not repair release.** This record addresses structural membership. [P2](P2-filename-wide-enforcement.md) separately chooses the filename enforcement mechanism. Its proposed sole-validator route removes the prospective B99 fail hook, so the coherent combination applies this structural repair to the existing `agent-instruction-contract` always-run hook and preserved eleven-hook configuration. It does not add a redundant B99-hook check.

## 1. Validation and current evidence

The frozen validator's686–701 raw regex accepts the unchanged B99 text after a four-space `description: |` line. That scalar belongs to a repository mapping; the six-space lines are data, not an item of `hooks`. Existing root checks, repository counts and required preceding hook lines still pass by source tracing. Native pre-commit validates the `hooks` value, while unknown repository keys only generate a warning. Therefore native validity is not sufficient proof of the intended policy. The candidate admission remains source-traced; root separately reproduced the native configuration-data side, as bounded below. The same class can undermine the active always-run guard if admission continues to search arbitrary text. [Pinned schema and unknown-key handling](https://raw.githubusercontent.com/pre-commit/pre-commit/v4.6.2/pre_commit/clientlib.py).

Root reproduced data loading with Python3.12.10 and pre-commit4.6.2: the original configuration has12 actual hooks; the masked configuration has the same11 prior actual hooks and no B99 hook. Both pass native schema; the only warning is `Unexpected key(s) present on local: description`. B99 text remains scalar data. The hash-bound [result](../feedback-native-config/result.json) records no hooks, PowerShell candidate, installation, profile or network execution. This is native schema/data-loading reproduction, not final assembled-guard qualification or whole-environment attestation. The supplied review and four handoff source hashes were verified unchanged. No current artifact incident, full bypass reproduction, syntax pass or runtime/package attestation is claimed. The original native29-case matrices cover regular100644 filenames only; they do not validate YAML membership. D98's prospective twelve-row profile can detect a missing native row during final aggregate, but cannot replace admission at the actual product consumer.

## 2. Stakeholders and consequences

The owner, both maintainers and security reviewers need an admitted executable guard rather than plausible text. New contributors need valid normal configuration to succeed with a clear malformed-policy diagnostic; experienced users and agents need stable ordinary hook/suppression semantics. PowerShell and Windows/Linux maintainers need a small testable contract without a new dependency. CI/release, independent quality, QA and auditors need exact hook membership, meaningful hiding controls and preserved failed history. Dependency/supply-chain owners oppose a new parser boundary unless justified. Schedule/cost users benefit from reuse but cannot waive activation proof. Guide readers, generated outputs, privacy, cloud/recovery, accessibility and localization interfaces do not change; no governance or guide edits are proposed.

## 3. Distinct options, before scoring

- **A:** Retain raw text and treat the warning as harmless. Leaves the counterexample.
- **B:** Blacklist `description`, scalar headers or a few known unknown keys. Smaller, but misses other inert containers and duplicate mappings.
- **C:** Admit a bounded canonical repository/hooks envelope in the existing finite PowerShell contract. Bind each checked hook to its real local `hooks` sequence; reject unknown/duplicate envelope fields and ambiguous YAML forms. Keep exact reviewed hook-body contracts. No general YAML parser.
- **D:** Reuse qualified pre-commit/PyYAML parsing through a trusted bounded Python call, then separately inspect the parsed tree for unknown/duplicate keys, exact local membership and guard properties. Native load_config alone does not reject unknown fields or necessarily preserve duplicate-key information.
- **E:** Require the entire normalized reviewed configuration to equal a trusted literal template. Sound and small in concept, but couples every legitimate unrelated config change to a second full representation.
- **F:** Add a strict YAML parser/schema framework to PowerShell or a new helper. Sound if complete, but expands dependency and parser authority.
- **G:** Combine native parsed-tree validation and C's finite structural proof. Sound; extra representation/runtime has no demonstrated benefit for the current closed format.
- **H:** Rely only on aggregate row/count evidence or defer repair to reviewers. Useful independent verification, incomplete product admission.
- **I:** Remove only B99's native hook under P2 and leave raw structural checks unchanged. Removes the original target, but fails to establish the now-authoritative always-run validator hook.

Native parsing plus a blacklist is D with an incomplete schema and cannot close the defect. Factored finite helper within the same file is C, not a new framework. P2 complete-name enforcement plus C is the proposed coherent combination. P2 plus H/I leaves its actual activation unproved. No targeted exception can authorize scalar-hidden enforcement. Deferral is operationally possible while frozen, but cannot count as closure.

## 4. New rubric

Scores0–5 mean absent, deficient, partial, workable, strong, complete fit; they are engineering judgments. Weights total100. **Structure34** proves semantic membership and uniqueness for the actual guard, including scalar/duplicate ambiguity. **Security25** rejects inert/unknown containers, preserves trusted code/data and fails closed without new authority. **Usability18** accepts the canonical configuration and gives a useful contributor diagnosis without extra setup. **Compatibility12** preserves eleven bodies/pins and B/H, staged and landed semantics. **Verification8** supports independent actual mutations and native parity. **Cost3** measures maintainable size and repeated/runtime work, not permission to weaken proof. A high total cannot excuse a hidden guard, new unqualified executable dependency, lost existing hook or falsified test result.

## 5. Checked scoring and selection

| Option | Structure34 | Security25 | Usability18 | Compat12 | Verify8 | Cost3 | Total /100 | Limit |
| --- | ---: | ---: | ---: | ---: | ---: | ---: | ---: | --- |
| A | 1 | 1 | 2 | 5 | 2 | 5 | 37.2 | Invalid admission retained |
| B | 2 | 2 | 3 | 4 | 2 | 5 | 50.2 | Other scalar/unknown-key hiding remains |
| C | 5 | 5 | 5 | 4 | 5 | 4 | 97.0 | Finite grammar must be qualified |
| D | 5 | 5 | 4 | 3 | 5 | 2 | 89.8 | New trusted Python admission coupling |
| E | 5 | 5 | 2 | 2 | 4 | 4 | 79.8 | Every legitimate config edit needs synchronized template |
| F | 5 | 5 | 4 | 3 | 4 | 1 | 87.6 | New parser/schema surface |
| G | 5 | 5 | 4 | 3 | 5 | 1 | 89.2 | Two admission representations |
| H | 1 | 2 | 3 | 5 | 3 | 5 | 47.4 | Private final evidence is not product enforcement |
| I | 2 | 2 | 4 | 5 | 2 | 5 | 56.2 | Required always-run hook still unproved |

**Recommend C97.0**, the unique highest score. C supplies the missing structural proof in the existing closed reader architecture. D/G remain sound alternatives if the finite subset cannot be qualified; their lower compatibility/usability scores reflect actual new trusted runtime and duplicate-key/schema work, not a preference to retain incorrect regexes. A/B/H/I cannot close this finding. E/F are complete but impose avoidable coupling for the actual finite format.

## 6. Controlled-English proposed implementation

1. Wait for root to display and select both decisions. Keep product bytes frozen until repair release.
2. Use one finite structure check in the existing setup contract. Read the bounded normalized configuration already supplied by the safe reader.
3. Admit one `repos` root and the reviewed repository groups. Admit only `repo` and one `hooks` field for each local group. Admit the reviewed `rev` and one `hooks` field for the actionlint group.
4. Reject unknown or duplicate envelope keys. Reject tags, aliases, merge keys, flow/multidocument alternatives and scalar containers in that envelope. Allow ordinary blank lines and comments without treating their text as nodes.
5. Recognize hook IDs only while reading an admitted `hooks` sequence. Do not promote text inside a scalar or comment into a hook.
6. Require the unique `agent-instruction-contract` hook in a local sequence. Preserve its exact entry, `language: system`, `always_run: true`, `pass_filenames: false` and normal stages. Reject hidden, duplicate, altered or restricting definitions. Reject unknown or duplicate fields in this guard body; admit its reviewed entry scalar shape only.
7. Preserve all eleven reviewed hook IDs, bodies and pins. Apply P2's chosen mechanism without a second B99 hook if D is selected there.
8. Retain strict root/global activation admission. Do not replace unknown-field admission with a `description` blacklist.
9. Add meaningful tests to the existing SelfTest. Keep safe readers and owned fixture cleanup.

This is controlled wording, not formally dictionary-certified ASD-STE100. It releases neither source edits nor a new parser framework.

## 7. Final validation obligations and limits

After actual PS235 acceptance and semantic integration, root must qualify the assembled contract against the actual native pinned parser. Private cases must cover repo-level `description: |`, another unknown scalar key, duplicate `hooks`, missing `hooks`, altered nesting/indentation, remote/local relocation, tag/alias/merge/flow forms, commented IDs, and missing/duplicate/hidden/altered always-run guard. Each must change real configuration, produce the specific admission failure, and avoid borrowing unrelated diagnostics. Include the canonical positive configuration and comments/blanks within the admitted format. Native parser comparison must establish intended active IDs and no accepted ambiguity; all cases remain unexecuted now.

Use qualified runtimes and guarded private copies only. The ordinary final aggregate command remains `python3.12 -m pre_commit run --all-files` (Windows qualified3.12 equivalent). It includes `.github/workflows/Test-AgentInstructions.ps1 -SelfTest -RequireStagedInputMatch`; do not repeat the full SelfTest merely to count hooks. Run focused changed-contract Windows/Linux checks plus parser/PSSA and the required final quality/admission gates. Preserve direct exit, primary failure, cleanup, immutable source/index/dependency guards, runtime bounds and all previous failures. Rebind actual accepted B/exact H and author date; candidate code remains diagnostic authority until normal acceptance. Tests, commits, publication, transfer and counters remain held.
