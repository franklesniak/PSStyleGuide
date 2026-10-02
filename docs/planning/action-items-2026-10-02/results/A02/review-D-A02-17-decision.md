<!-- markdownlint-disable MD013 -->
# D-A02-17 — authoritative file-type checks in the private snapshot

Design only; parent publication/release pending. Requested gpt-6-astra/high; effective metadata unavailable. No tests, descendants or product/native/planning writes by this assessor. This author contributed to D15/D16; this is a design decision, not final independent acceptance.

## 1. Validated finding and limits

Read STATUS first. Inspected the exact private snapshot source, its bounded transport, the existing Node resolver/reader pattern, and worker logs. Current SelfTest SHA256 is `e95572bace634c507a175236a625eb848295d99f118c40012a4a9f28c193ff46`; validator SHA256 is `c8202d8591f247f1ed477e564b3890a519d0b93f66dd61812b7c4483ffc071d1`.

`D16-linux-fifo-info.log` records actual PowerShell7.4.6: a FIFO is System.IO.FileInfo, Attributes=Normal, LinkType=null, UnixMode present but `-rw-r--r--`; the guard would not reject it. Native stat identifies `fifo 11a4 644`. `D16-linux-controls.log` records intended100755/100644 mode/raw success through normalization/B/H1/H2, then the fixture blocks at OpenRead on that FIFO. The worker terminated only owned PID472; exit143 is not a pass. A later separate mode-only run passed; it does not supersede the FIFO failure.

The private current-worktree snapshot promises regular-file refusal before a bounded byte read. Git index mode100644/100755 proves the intended Git object type, not the current working filesystem object's type. Optional PowerShell UnixMode display is not authoritative on this actual host. Existing PS readers repeat that property test, so their reuse would not fix the demonstrated failure. No production-reader test, hostile writer or real data was involved.

A useful existing native primitive is `fs.lstatSync` with `Stats.isFile()`, already used in Validate-WorkflowPolicy.mjs readOrdinaryFile and its parser-tree reader. Node is already required by the actual F2 validator/parser. Its production resolver uses Get-Command node -CommandType Application, a shell-free resolved executable and removal of NODE_OPTIONS/NODE_PATH. Existing Read-BoundedProcessData provides a stdout cap, timeout, native exit and child-tree cleanup. No new executable/package is necessary. [Node24 fs documentation](https://nodejs.org/download/release/v24.18.1/docs/api/fs.html#fslstatsyncpath-options) describes lstat (without following a symlink) and Stats.isFile; bigint stats can preserve exact identity values. [Python3.12 stat.S_ISREG](https://docs.python.org/3.12/library/stat.html#stat.S_ISREG) offers another genuine native type test, but its interpreter selection is more involved in this caller.

This is static nonregular-input refusal, not an atomic race-confinement repair. A separate lstat followed by PowerShell OpenRead still has a check/open interval; repeated metadata/hash checks detect some changes, not every adversarial race. Do not claim that this selection makes that interval atomic or provides a total timeout for arbitrary competing-writer substitution.

## 2. Stakeholders

Contributors and the sole maintainer need a self-test that rejects a static FIFO without hanging. Security/quality reviewers need a genuine type oracle and honest race limits. Windows/Linux/toolchain maintainers need existing required runtimes and bounded child cleanup. Documentation authors need raw candidate bytes and intended index modes preserved. Cost/schedule stakeholders need bounded targeted validation rather than a general filesystem framework. No cloud, credentials, state recovery, personal-data or actual document changes are involved.

## 3. Options before scoring

- N: keep the optional display-property guard. The actual static FIFO remains admitted to OpenRead.
- A: use a small private Node lstat inquiry immediately before opening each leaf and after reading it, through the existing bounded process transport. Keep the current bounded PowerShell byte reader and all other controls.
- B: use Python lstat/S_ISREG similarly. Valid primitive, but requires the existing platform-specific interpreter selection/probe path in a scope that does not retain its result.
- C: native stat/file or platform shell tests. Can work locally; adds GNU/BSD/Windows variants and another command contract.
- D: batch all Node metadata into a snapshot-wide exchange. Reduces process startup cost; requires a new bounded multi-path transport/schema or scratch exchange file and lifecycle. There is no measured startup bottleneck yet.
- E: move all byte reading into a Node child with native flags, handle validation and binary/base64 transport. Could bound more of the open/read behavior, but expands the actual reader and race semantics beyond the demonstrated static-type repair.
- F: introduce platform P/Invoke/native filesystem interop. Larger portability/security surface without a need for this static refusal.
- G: raise the PowerShell floor, skip the Linux/FIFO case, or declare the tested type unsupported without an authoritative guard. Does not establish type safety; the real supported test host already exhibits the defect.
- W: treat failed type inquiry as empty input, trust index mode alone, or remove raw/type guards. Inadmissible weakening.

## 4. Fresh rubric and scores

Scores1–5: fails, weak, partial, adequate with limits, directly meets. Total=sum(weight × score)/5. Weights: demonstrated static refusal40%; preserved byte/mode/identity controls25%; reuse and cross-platform integration20%; implementation/maintenance surface10%; runtime cost5%.

Hard constraints: reject nonregular current inputs before reading; preserve raw bytes, index modes, link/containment/bounds/source checks and failure truth; no new package/public API, production-reader edit, fallback-on-error or atomic-race claim. A high score cannot waive these.

| Option | Refusal40 | Controls25 | Reuse20 | Surface10 | Cost5 | Total |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| N | 1 | 2 | 5 | 5 | 5 | 53 |
| A | 5 | 5 | 5 | 4 | 2 | 95 |
| B | 5 | 5 | 4 | 3 | 2 | 89 |
| C | 5 | 4 | 2 | 3 | 3 | 77 |
| D | 5 | 5 | 4 | 2 | 5 | 90 |
| E | 5 | 4 | 4 | 2 | 3 | 83 |
| F | 5 | 4 | 2 | 1 | 4 | 74 |
| G | 1 | 2 | 2 | 4 | 5 | 39 |
| W | 1 | 1 | 4 | 5 | 5 | 44 |

Arithmetic checked. Select A. It supplies the missing actual native type fact at the read boundary without changing the byte reader or adding bulk transport. Its startup overhead is explicit, not measured away. If measurements show material cost, reassess D in this same record before implementing an optimization; do not silently expand the design.

## 5. Controlled selection A

Change only the private F2 snapshot and its directly necessary focused tests in Test-AgentInstructions.SelfTest.ps1. Resolve the already required Node application once for this private fixture, using the existing production resolution pattern. Use ProcessStartInfo.ArgumentList with constant program text and a separate absolute file-path argument. Use shell-free redirected streams, clear NODE_OPTIONS/NODE_PATH as the existing parser does, and call Read-BoundedProcessData. Use a small fixed result cap (4096 bytes) and existing bounded timeout convention (5000ms). Treat missing runtime, nonzero exit, malformed result, oversized output or timeout as failure; do not continue to OpenRead.

Have the Node inquiry call lstatSync with exact bigint metadata and require isFile() before returning a regular-file result. Do not follow a leaf symlink. Return only a constant-shape small success response: a fixed regular-file marker and bounded decimal-string identity fields for device, inode, mode, size and modification/change timestamps. A fixed ASCII record is sufficient; do not introduce a general JSON schema, path-key mapping, exchange file or persistent protocol framework. Validate the exact field count and lexical bounds; do not coerce wide integers to floating point or interpret timestamp text as a date. Distinguish an actual nonregular result from a failed inquiry in diagnostics. Do not read candidate bytes in the inquiry.

Keep the existing component/link checks. Immediately before OpenRead, require a successful authoritative regular result. After the bounded read closes, repeat the inquiry and require regular type and unchanged captured identity. Keep existing PowerShell component/type/mode stability checks as additional checks, not as the type authority. Preserve the complete later source snapshot and HEAD rechecks, Git blob/SHA256 computation, 16MiB per-file/64MiB aggregate bounds, path/index limits, intended Git mode installation/readback and private fileMode behavior. Do not drop a guard merely because lstat now exists.

Keep the static/refusal claim narrow. The fixture assumes no competing writer during this snapshot. The inquiry does not bind the later PowerShell handle to the earlier path. Its timeout covers only the Node inquiry; it is not a timeout for the subsequent .NET OpenRead and cannot prevent that call from blocking after an adversarial path replacement. Do not add a global race guarantee, restore removed machinery, or change the production reader as part of this repair.

## 6. Targeted verification and ownership

First run the actual extracted final snapshot against a real FIFO in the existing disposable Linux environment. It must fail promptly before any blocking data open, without external termination. Preserve the prior exit143 evidence. Check ordinary empty/binary files and intended100644/100755 still retain exact bytes/blobs/modes. Reuse existing link/path controls; add a static Unix socket/nonregular control if practical in that same fixture. Do not create privileged devices or touch real state.

Exercise malformed/failed inquiry output and nonzero/timeout refusal through the existing transport testing seams where available. Confirm no owned child remains. Check before/after identity mismatch refusal with a controlled synthetic input; do not call this an adversarial race proof. Run a focused Windows positive and relevant actual F2 scenario, then the required final aggregate gates after refreeze. Reuse unchanged D15 date/no-op setup and D16 hash/mode evidence where exact affected-property checks support it; do not rerun unrelated long suites only to manufacture breadth. Record process overhead on the real71-path snapshot.

A02 owns this new private reader. A14's accepted conditional finding concerned the five unchanged native D92 roles; this does not retroactively change their evidence. Recheck candidate applicability narrowly because a new reader now exists, but do not label a static FIFO defect a competing-writer trigger or a PS155 repair. No A14 policy decision or issue mutation is selected here. Review clock, transfers, native pins and outstanding authority are unchanged. Parent verifies/publishes this record before release to the sole writer.
