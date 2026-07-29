# PSStyleGuide P1/P2 review findings

## Overall assessment

P1 and P2 form a coherent, correctly ordered slate. P1 establishes deterministic
generation and a substantially stronger verification and synchronization pipeline;
P2 then relies on that foundation for a source-and-generated-artifact documentation
change. The main technical direction is sound, and several concerns raised in earlier
drafts have been resolved.

Seven findings remain. Four should be settled before filing or implementation because
they affect a security boundary, near-term workflow compatibility, or an undefined
implementation contract. The remaining findings are precision and maintainability
repairs that can be made without changing the slate's intended architecture.

## Scope and method

- Primary review targets:
  `docs/planning/PSStyleGuide/01PSStyleGuideP1.md` and
  `docs/planning/PSStyleGuide/02PSStyleGuideP2.md`.
- Execution order assumed: P1, then P2.
- The H1 titles and P1/P2 identifiers are intentional and are not findings.
- `docs/planning/TerraformStyleGuide/03TerraformStyleGuideT1.md` and
  `docs/planning/TerraformStyleGuide/04TerraformStyleGuideT2.md` were read only
  for cross-repository alignment. This review does not critique T1 or T2.
- Repository files, installed validation commands, PowerShell 5.1 and PowerShell 7,
  Git behavior, and the pinned GitHub Action implementations were checked directly.

## Findings

### P1-1 — The security-sensitive archive helper is not automatically exercised before merge

Priority: high.

P1 requires the production helper's fixture suite in every push consumer, but not in
the pull-request Ubuntu job or pull-request Windows matrix. The helper is a new
security boundary that validates an untrusted ZIP structure and controls extraction.
An ordinary P1 pull request can therefore pass its automatic checks without executing
that helper at all.

The controlled write-path drill supplies valuable point-in-time pre-merge Ubuntu
evidence, and the post-merge push matrix covers the Windows editions. It does not
replace an automatic check on every pull-request revision. Furthermore, P1's expected
post-merge push has `has_changes=false`, so synchronization—and its Ubuntu-capable
helper invocation—skips.

Recommended correction:

1. Run the exact tracked helper's complete fixture suite in the pull-request Ubuntu
   job under PowerShell 7.
2. Run it in the two pull-request LF cells: once under Windows PowerShell 5.1 and once
   under PowerShell 7.
3. Do not repeat the same helper suite in the CRLF cells. Helper behavior is
   independent of the generator-source EOL fixture, so those repetitions add cost
   without adding coverage.
4. Retain P1's in-situ self-test requirement in every push consumer before the
   production helper invocation.
5. Add the three automatic pre-merge executions to pull-request evidence and
   acceptance criteria.

This proves every claimed helper platform before merge and still detects consumer
wiring or runner-environment failures after merge. The equivalent Terraform
prerequisite can use the same pattern to preserve the intended cross-repository
alignment.

### P1-2 — The helper cannot implement all required checks from its specified interface

Priority: high.

P1 says the helper accepts only:

- the candidate download directory;
- the initially nonexistent destination directory; and
- the expected archive digest.

The same helper must prove that both paths are outside the tracked checkout and emit
the artifact ID, run ID, and run attempt in diagnostics when available. The issue does
not define how it receives or authoritatively discovers the checkout root or diagnostic
context.

Deriving the checkout root from the process working directory is brittle. Reading
`GITHUB_WORKSPACE` makes the helper CI-specific and leaves the local fixture contract
undefined. Artifact and run context could be read from environment variables, passed
as parameters, or logged by the caller; each produces a materially different contract.

Recommended correction:

1. Add a mandatory `CheckoutRoot` parameter.
2. Add optional `ArtifactId`, `RunId`, and `RunAttempt` parameters, or explicitly make
   those fields caller-owned and remove them from the helper's diagnostic obligation.
3. Require all three path parameters to resolve through the filesystem provider before
   comparison.
4. Define containment with a path-separator boundary, so a sibling such as
   `/work/repository-other` is not treated as a child of `/work/repository`.
5. Define Windows comparison as ordinal case-insensitive and POSIX comparison as
   ordinal case-sensitive after normalization.
6. Use the same parameter names and semantics in P1 and T1, apart from their
   intentional manifest-name difference.

This converts an architectural intention into an implementable, testable interface.

### P1-3 — The modified workflow retains a Node 20 checkout action despite the active Node 24 migration

Priority: high and time-sensitive.

The current `build.yml` uses the moving reference `actions/checkout@v4`. The current
v4 and exact v4.3.1 action metadata both declare `using: node20`. Node 20 reached end
of life in April 2026. GitHub began making Node 24 the runner default on June 16,
2026, and states that Node 20 will be removed from runners in fall 2026. GitHub tells
workflow users to update to action versions that run on Node 24.

P1 substantially rewrites `build.yml` but pins only the artifact actions. Its
instruction not to begin a repository-wide unrelated-action migration is reasonable;
it should not prevent correction of the checkout action in the workflow P1 is already
changing.

Recommended correction:

1. In P1's `build.yml` scope, update checkout to the then-current approved Node
   24-based release and pin it to a verified full commit SHA.
2. As of this review, the concrete candidate is
   `actions/checkout@de0fac2e4500dabe0009e67214ff5f5447ce83dd`
   with an adjacent `# v6.0.2` comment.
3. Reverify that release and SHA immediately before implementation, just as P1
   requires for the artifact actions.
4. Keep a broader repository-wide action migration out of P1. Record the remaining
   `actions/checkout@v4` in `markdownlint.yml` as a separate near-term maintenance
   item.

If maintainers do not want checkout modernization in P1, they should create and
complete a prerequisite issue before Node 20 removal and state that dependency
explicitly. Silently retaining v4 is the weakest choice because it creates a known,
short-horizon compatibility risk in the newly hardened workflow.

### P1-4 — P1 currently fails the repository's own Markdown lint

Priority: medium.

Running the installed `markdownlint-cli2` configuration against the issue files
reports two MD029 errors:

- `01PSStyleGuideP1.md:487`
- `01PSStyleGuideP1.md:488`

The unindented action fence after ordered item 4 ends the list as parsed by the
linter. Items 5 and 6 are then interpreted as a new list whose expected numbering is
1 and 2.

Recommended correction: indent the action fence and associated content so it remains
part of item 4, or restart the post-fence list at `1.` and `2.`. Using `1.` for every
source Markdown ordered-list marker is another stable option.

This is not merely cosmetic while the draft lives under `docs/planning`: the
repository's `lint:md` command includes all `**/*.md` files.

### P2-1 — P2 requires a rationale changelog that PSStyleGuide does not have

Priority: high.

P2 says to add a "matching top rationale changelog row" and requires Version, Last
Updated, and changelog metadata to agree. Current `STYLE_GUIDE_RATIONALE.md` has no
changelog, version-history section, dated-row schema, or prior changelog rows.
Neither authoritative PSStyleGuide source establishes such a convention.

This requirement appears to have crossed over from TerraformStyleGuide context, where
the repository-specific T2 issue can rely on an existing rationale changelog.

Recommended correction:

1. **Preferred:** remove the rationale-changelog instruction from P2's metadata step,
   content confirmation, and acceptance criteria. Continue to update `STYLE_GUIDE.md`
   Version and Last Updated and add the rationale prose to
   `STYLE_GUIDE_RATIONALE.md`.
2. If PSStyleGuide deliberately wants a changelog, make that an explicit scope
   addition. Specify its heading, placement, row schema, initial-history policy,
   table-of-contents impact, and ownership rules. Do not call the first entry a
   "matching" row when no existing row or schema exists.

The first option is the better fit for P2's focused documentation repair and avoids
inventing repository policy incidentally.

### P2-2 — The automated middle-dot test proves only global co-occurrence, not the required example

Priority: medium.

P2's validation reads each touched file and, when it finds the Non-Compliant marker,
checks only whether the file contains `LF + four middle dots + LF` somewhere. This
can pass when:

- the intended Non-Compliant block contains the wrong line;
- the four-dot line occurs in unrelated prose or another code block;
- the warning does not precede the block;
- the block does not use a `text` fence; or
- multiple conflicting Non-Compliant examples exist.

Manual content confirmation catches some of these cases, but the automated test is
described as confirming the exact visualization. It does not currently establish
that claim.

Recommended correction:

1. Define one canonical multi-line snippet that includes the heading or marker,
   warning, opening `text` fence, both command lines, the exact four-dot third line,
   and closing fence.
2. Require exactly one canonical occurrence in each source/generated document that
   is expected to contain the example.
3. Reject any additional occurrence of the Non-Compliant marker.
4. Continue the independent no-trailing-whitespace, no-CR, and no-BOM checks.
5. If exact prose is intentionally allowed to differ among output formats, parse a
   tightly bounded region from the unique marker through its closing fence and assert
   the fence language, line count, adjacency, and exact line contents instead of
   matching a global snippet.

The existing `### Blank Line Usage` section in `STYLE_GUIDE_RATIONALE.md` should also
be named explicitly as the rationale destination. Doing so prevents a duplicate
section and makes the implementation unambiguous.

### P1/P2-1 — Evidence links point to moving major branches instead of the reviewed action commits

Priority: medium.

The configured artifact-action pins and their relied-upon contracts are correct as of
review:

- upload-artifact v7.0.1 is
  `043fb46d1a93c77aae656e7c1c64a875d1fc6a0a`;
- download-artifact v8.0.1 is
  `3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c`;
- the upload action exposes `archive` and a bare-hex `artifact-digest`; and
- the download implementation uses the artifact digest as the expected hash, honors
  `skip-decompress`, and makes digest mismatch fatal when configured as `error`.

However, the References sections use raw GitHub URLs under moving `v7` and `v8`
branches. A later reader can therefore inspect different code from the exact
implementation on which the issue's security reasoning relies.

Recommended correction: link `action.yml`, the relevant README sections, and download
implementation files at the exact full commit SHAs. Exact patch-release pages may
remain as human-readable release context.

## Confirmed strengths and resolved concerns

- The repository's broad `.gitattributes` rule,
  `* text=auto eol=lf`, is correct for the stated cross-repository checkout policy.
- P1 correctly distinguishes the checkout invariant from producer correctness.
- The current generator really does have the four stated write sites, retains
  `#Requires -Version 5.1`, and currently lacks a script version.
- P1's proposed frontmatter construction produces the same bytes as the current
  `powershell.instructions.md` under both Windows PowerShell 5.1 and PowerShell 7.
- The four-cell Windows topology is the actual edition × LF/CRLF cross-product, and
  the lone-CR probe is separate and runs once per edition.
- The candidate transport has two independent digest checks: the pinned download
  action's native validation and the helper's retained-ZIP SHA-256 comparison.
- The archive lifecycle, manifest checks, extraction sequencing, exact blob proofs,
  and expected-SHA `--force-with-lease` design are fail-closed and technically sound.
- P2's factual premise is correct: the stored Compliant and Non-Compliant examples
  both currently have an empty third line.
- Four U+00B7 MIDDLE DOT characters in a `text` fence are a durable, portable
  visualization that does not teach literal trailing whitespace.
- P2 correctly prohibits changing `.github/copilot-instructions.md`, while allowing
  the distinct generated root-level `copilot-instructions.md` to change through
  regeneration.
- P2's version snapshot is correct if its stated baseline and UTC date still apply.
- P1's final local-validation block already addresses the supplied unstaged-change
  concern. Before `git add`, it requests porcelain v1 status with all untracked files,
  derives the complete changed-path set, and compares it case-sensitively with exactly
  the three expected P1 implementation paths. A third modified or untracked path
  fails. It then independently verifies the exact staged set.
- The complete attached T2 text is consistent with the prerequisite context used for
  this review; no T2 finding is asserted here.

## Primary references

- [GitHub: Deprecation of Node 20 on GitHub Actions runners](https://github.blog/changelog/2025-09-19-deprecation-of-node-20-on-github-actions-runners/)
- [actions/checkout v4 action metadata](https://raw.githubusercontent.com/actions/checkout/v4/action.yml)
- [actions/checkout v4.3.1 action metadata](https://raw.githubusercontent.com/actions/checkout/34e114876b0b11c390a56381ad16ebd13914f8d5/action.yml)
- [actions/checkout v6.0.2 action metadata](https://raw.githubusercontent.com/actions/checkout/de0fac2e4500dabe0009e67214ff5f5447ce83dd/action.yml)
- [actions/upload-artifact v7.0.1 action metadata](https://raw.githubusercontent.com/actions/upload-artifact/043fb46d1a93c77aae656e7c1c64a875d1fc6a0a/action.yml)
- [actions/download-artifact v8.0.1 action metadata](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/action.yml)
- [actions/download-artifact v8.0.1 download implementation](https://raw.githubusercontent.com/actions/download-artifact/3e5f45b2cfb9172054b4087a40e8e0b5a5461e7c/src/download-artifact.ts)
- [GitHub: Secure use reference for GitHub Actions](https://docs.github.com/en/actions/reference/security/secure-use)
