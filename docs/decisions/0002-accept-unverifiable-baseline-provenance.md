# Decision 0002: Accept that the supply-freeze baseline cannot be machine-verified

## Metadata

- **Status:** Active
- **Owner:** Repository Maintainers
- **Last Updated:** 2026-08-29
- **Scope:** Records the accepted limitation on machine-verifying supply-freeze baseline provenance and its reconsideration conditions. Does not redefine enforcement of current reviewed bytes.

## Status

Accepted on 2026-08-01 by Frank Lesniak, PSStyleGuide repository owner.

This records a deliberate acceptance so the question is settled rather than rediscovered.
If the review triggers in the last section fire, reopen it.

## 1. What the fields are

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
independently compares them against literals hard-coded in the workflow. The baseline has no
such consumer.

## 2. The defect that prompted this, and its correction

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

## 3. What is accepted

**Nothing verifies that these three values remain mutually consistent.**

`validateContract()` checks the field's *shape* but cannot check its *content*, because
proving that a blob identifier matches a length and a digest requires reading Git objects,
and the validator is deliberately offline and Git-free. It also runs from a checkout made
with `fetch-depth: 1`, where the historical object need not be present at all.

So if these values are edited incorrectly in future, no test will catch it.

## 4. Why that is acceptable

| Question | Answer |
| --- | --- |
| Does any gate read these fields? | No. Nothing in the validator, the workflows, or the generator branches on them. |
| Can a wrong value cause a bad install? | No. The install is gated by `reviewedWorkingBytes` and by literals in `markdownlint.yml`, neither of which involves the baseline. |
| Can a wrong value cause a policy check to pass that should fail? | No. The baseline is not an input to any comparison. |
| What is the actual harm? | A future auditor reconstructing the change is misled about the starting state. |
| Is the harm detectable? | Yes, trivially, by anyone who runs `git cat-file blob <id>` and hashes the output. |

The exposure is a documentation-accuracy problem with a one-command manual check, not a
security or correctness problem. Building offline enforcement for it would mean either
teaching the validator to shell out to Git — abandoning the offline property that makes it
trustworthy in the first place — or adding a second, Git-aware verification step whose only
purpose is to check a field nothing consumes.

Neither is proportionate.

## 5. Options considered

| Option | Verdict |
| --- | --- |
| **Accept and document.** Leave the fields as accurate provenance with no automated check. | **Selected.** Proportionate to a field with no runtime consumer. |
| Add Git-aware verification inside the validator. | Rejected. Destroys the offline, dependency-free property that the preflight gate depends on, to check something nothing reads. |
| Add a separate Git-aware script run manually before merge. | Rejected for now, but the cheapest escalation if this ever matters. Roughly twenty lines. Would not run in continuous integration, since the objects may be absent under `fetch-depth: 1`. |
| Delete the baseline fields entirely. | Rejected. Issue #145 explicitly requires the frozen supply tuple to record baseline blob identifiers and digests, so removal needs a scope change, and the provenance has genuine audit value when correct. |

## 6. How to check it by hand

If you ever need to confirm the baseline, from a clone with full history:

```text
git cat-file blob 7e96fd1fd41765ba31488762f60c2f74ba17d3a8 | wc -c
git cat-file blob 7e96fd1fd41765ba31488762f60c2f74ba17d3a8 | sha256sum
```

These must equal `length` and `sha256` for `packageLockJson`, and the same two commands with
blob `923106fc4ee5508b7a03930b3d8b774db9fcd009` must equal the values for `packageJson`. A
shallow clone will not have the objects; use `git fetch --unshallow` first.

## Canonical guides

- [STYLE_GUIDE.md](../../STYLE_GUIDE.md)
- [STYLE_GUIDE_RATIONALE.md](../../STYLE_GUIDE_RATIONALE.md)

## 7. When this decision must be revisited

- Any gate, script, or workflow starts reading `supplyFreeze.baseline`. It then stops being
  inert provenance and needs real verification.
- The baseline is regenerated for a new supply freeze, at which point the values should be
  produced from `git cat-file` output rather than from a working tree, so the platform
  line-ending difference cannot recur.
- The repository gains a Git-aware pre-merge verification step for other reasons, which would
  make the rejected third option nearly free.
