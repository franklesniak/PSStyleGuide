# Criticism of the revised PSStyleGuide issue slate

## Review basis

This review compares P1, P1A, P1B, P2, and P3 with the latest T1, T1A, T1B,
T2, T3, and T4 contracts. It assumes each repository executes its one listed
sequential graph. It rechecked every prior PSStyleGuide finding and reviewed
the post-fixed-point T1A resource and harness-proof amendments.

The previous six PSStyleGuide findings remain closed. One new reciprocal
finding is actionable.

## C-01 — P1A does not bound exact filesystem enumeration

**Validity: confirmed.**

P1A requires exact download-entry, candidate-output, leaf-absence, and cleanup
proofs. It does not state whether those checks stream or materialize the full
directory result. An implementation can therefore satisfy the text with
`Directory.GetFileSystemEntries`, `.ToArray()`, or equivalent complete
collection storage. The number of entries, rather than the declared archive
ceilings, can then select process memory.

T1A now closes the same resource boundary. An exact-cardinality check stops
after `N + 1` results. An absence check consumes one stream to completion
without retaining the result set. Its closed harness proof rejects an eager
mutant and records that the bounded guard executes on all three runtime cells.

Microsoft documents that `EnumerateFileSystemEntries` exposes entries before
the whole collection is returned, while `GetFileSystemEntries` waits for the
complete array. This supports a bounded streaming contract:

- [Directory.GetFileSystemEntries remarks](https://learn.microsoft.com/en-us/dotnet/api/system.io.directory.getfilesystementries?view=netframework-4.8.1)
- [Enumerable class and deferred execution](https://learn.microsoft.com/en-us/dotnet/api/system.linq.enumerable)

**Recommendation:** amend P1A as follows:

1. Require every exact-cardinality scan for `N` entries to stop after
   `N + 1` results and retain no more than those results.
2. Require each leaf-absence scan to consume one enumeration to completion
   without accumulating the completed sequence.
3. Stop on an unreadable, matching, or unclassifiable entry and retain
   uncertain state when cleanup or ownership is involved.
4. Prohibit eager full-result APIs and conversions on these production paths.
5. Add one closed, versioned harness-proof row for all three required runtime
   cells. Bind it to the exact supplied scripts. Use syntax-tree inspection, a
   traced copy, and an eager-materialization mutant with a positive control.
6. Reject a missing, duplicate, unknown, skipped, or multiply emitted proof
   result.

T1A's separate pre-journal competing-writer proof does not have to be copied
into P1A. P1A explicitly excludes a competing untrusted writer, so the
reciprocal matrix can record that row as an intentional model difference. The
bounded-enumeration property is not such a difference because both issues
treat filesystem claims and resource declarations as untrusted.

## Intentional differences that are not findings

- P2 and T2/T4 implement repository-specific product work.
- P1A and T1A need semantic comparison, not equal functional case counts.
- The T1A competing-writer fault-injection proof can remain Terraform-only if
  the reciprocal matrix records P1A's explicit non-goal.
- PSStyleGuide staged lint and TerraformStyleGuide full lint remain deliberate.

## Convergence judgment

The issue graph and file slate remain correct. Close C-01 in P1A before
declaring the cross-repository drafts stable. No issue draft should be added,
deleted, renamed, or reordered.
