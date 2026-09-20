<!-- markdownlint-disable MD013 -->
# Decision 0002: Keep historical baseline verification outside the offline validator

## Metadata

- **Status:** Accepted
- **Owner:** Repository Maintainers
- **Last Updated:** 2026-09-20
- **Scope:** Records the accepted limitation on automatic offline verification of supply-freeze baseline provenance, the separate manual verification method, and reconsideration conditions. Does not redefine enforcement of current reviewed bytes.

## Date

- **Date:** 2026-08-01

Accepted by Frank Lesniak, PSStyleGuide repository owner.

This records a deliberate acceptance so the question is settled rather than rediscovered.
If the review triggers in the last section fire, reopen it.

## Context

`workflow-policy-contract.json` contains a `supplyFreeze.baseline` object recording what
`package.json` and `package-lock.json` looked like on `main` before the dependency change,
as a Git blob identifier plus that blob's byte length and SHA-256:

```json
"baseline": {
  "packageJson": {
    "blob": "923106fc4ee5508b7a03930b3d8b774db9fcd009",
    "length": 987,
    "sha256": "05da30054a296c0b2a409a527958abcae149bec72b6c8f50ce30b2bf45b77260"
  },
  "packageLockJson": {
    "blob": "7e96fd1fd41765ba31488762f60c2f74ba17d3a8",
    "length": 64608,
    "sha256": "25ffbe3c4e5b26615318235dffe2908dbddcf2788a40f7c7bdb620ec0314415d"
  }
}
```

This is **provenance**, not a gate. It answers "what did we start from?" for a human auditor
reconstructing the change. It is required by issue #145's frozen supply tuple.

Note the distinction from its sibling `supplyFreeze.reviewedWorkingBytes`, which records the
*current* reviewed bytes and **is** enforced — `verifyPackageDigests()` compares the real
`package.json` and `package-lock.json` against it before `npm ci` runs, and `markdownlint.yml`
independently compares them against literals hard-coded in the workflow. The offline validator does not consume the historical baseline. The separate manual
procedure below verifies it without adding a workflow gate.

## The defect that prompted this, and its correction

Codex found during review of pull request #150 that `baseline.packageLockJson` recorded a
length of 66,425 and a SHA-256 of `b62a8891…`, while `git cat-file blob 7e96fd1f…` yields
64,608 bytes and `25ffbe3c…`. The recorded pair described the same content after LF-to-CRLF
conversion, matching bit for bit.

The finding was verified against the actual Git objects rather than accepted on its face, and
one detail confirmed it was an error rather than a convention: the sibling `packageJson`
entry recorded its blob's real bytes. The two halves of one record were following different
conventions. The likely cause is that the producer platform is `win32-x64` while
`.gitattributes` is `* text=auto eol=lf`, so a Windows working tree holds CRLF while the blob
stays LF.

The lockfile entry now describes the blob it names. That correction is not what this decision
accepts.

## Decision

**The offline validator does not verify that these three values remain mutually consistent.**

Amended on 2026-09-20 under issue 158: the [P1 reproduction method](../P1-SUPPLY-FREEZE-v1.md#verify-historical-git-provenance-separately) now provides separate raw-byte Git verification. It checks the historical commit type, both commit/path relationships, exact blob identifiers, byte lengths, and SHA-256 values. Missing objects and mismatches refuse. Object acquisition is a separate explicit fetch before the read-only interval; the verification disables lazy fetch, replacement objects, and optional lock writes. The recorder does not invoke Git or claim this external step ran.

`validateContract()` checks the field's *shape* but cannot check its *content*, because
proving that a blob identifier matches a length and a digest requires reading Git objects,
and the validator is deliberately offline and Git-free. It also runs from a checkout made
with `fetch-depth: 1`, where the historical object need not be present at all.

An incorrect value can now be detected by that explicit manual procedure. It remains outside the offline validator and CI. A recorder observation alone does not establish historical provenance.

## Consequences

| Question | Answer |
| --- | --- |
| Does any automated gate read these fields? | No. The separate manual procedure verifies them; the validator, workflows, and generator retain their existing authority. |
| Can a wrong value cause a bad install? | No. The install is gated by `reviewedWorkingBytes` and by literals in `markdownlint.yml`, neither of which involves the baseline. |
| Can a wrong value authorize a current install? | No. The current reviewed bytes remain the installation authority. The manual provenance comparison refuses a mismatch. |
| What is the actual harm? | A future auditor reconstructing the change is misled about the starting state. |
| Is the harm detectable? | Yes, trivially, by anyone who runs `git cat-file blob <id>` and hashes the output. |

The original exposure was misleading historical documentation rather than current installation authority. The manual procedure now checks the relevant historical facts. Putting that procedure inside the offline validator would expand its execution boundary and require historical objects in shallow CI.

Keeping Git outside the offline validator remains proportionate. Issue 158 authorizes the separate manual verification method, which is now available without adding Git subprocesses to the recorder.

### Positive

The new procedure makes baseline consistency reproducible while preserving the offline validator and unchanged P1 schema. Missing shallow-clone objects are an explicit refusal.

### Negative

Verification remains a separate manual step with separately retained evidence. Historical producer signatures, original audit bytes, and unknown canonical installed-tree recipes are not reconstructed.

## Alternatives considered

| Option | Verdict |
| --- | --- |
| **Accept and document.** Leave the fields as accurate provenance with no automated check. | Historical selection, now amended by issue 158 to provide a separate manual verification procedure. |
| Add Git-aware verification inside the validator. | Rejected. Expands the offline preflight gate's execution boundary to verify historical provenance that is not current installation authority. |
| Add a separate Git-aware script run manually before merge. | Selected as a separate documented manual procedure under issue 158. It refuses missing objects and does not run in continuous integration. |
| Delete the baseline fields entirely. | Rejected. Issue #145 explicitly requires the frozen supply tuple to record baseline blob identifiers and digests, so removal needs a scope change, and the provenance has genuine audit value when correct. |

## How to check it by hand

Use the [complete raw-byte procedure](../P1-SUPPLY-FREEZE-v1.md#verify-historical-git-provenance-separately). It checks both baseline objects against historical commit `4346310e7deebffb4159c75e30d9546263dfd649`, fails on missing objects or native errors, and avoids checkout line-ending conversion. Run the explicitly documented acquisition step before verification when the objects are absent. Do not infer success from a command that only prints a hash.

## Canonical guides

- [STYLE_GUIDE.md](../../STYLE_GUIDE.md)
- [STYLE_GUIDE_RATIONALE.md](../../STYLE_GUIDE_RATIONALE.md)

## When this decision must be revisited

- A workflow or automatic gate starts relying on `supplyFreeze.baseline`. The new manual method does not authorize that integration.
- The baseline is regenerated for a new supply freeze, at which point the values should be
  produced from `git cat-file` output rather than from a working tree, so the platform
  line-ending difference cannot recur.
- A new Git-aware verification capability changes the tradeoff between a separate manual step and automatic enforcement.
