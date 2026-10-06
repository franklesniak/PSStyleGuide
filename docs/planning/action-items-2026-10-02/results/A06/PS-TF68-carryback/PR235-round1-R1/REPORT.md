# PR235 round 1 R1: immutable-input guard finding

Recommendation **A97.8: retain the static union and refute the reported absent-path failure**. No material product defect was established and no product edit is proposed. This is a proposal for root's review disposition, not a submitted reply or resolution.

## Inputs and validation

PS H504cd7672ac9604ace765a4f451346f801f09ddd/treea716a1f8ff7e4f385e089b0f056adbcde9c973cb has parent B98177628b7bc02c646724bfc8aa0fd73fed0cd24. The worktree is clean; ten committed carryback paths remain the scope. evidence.json binds raw committed blobs/modes/hashes and read-only before/after identity checks. The dedicated workflow is absent at B and present at H; absence is recorded explicitly. Comment4200122706/review5434209468 targets copilot-code-review.yml line886 and claims missing union members cause pathspec errors. The completed overview explicitly reports **Lite**, a legitimate fallback with no rerequest warranted by effort alone.

The actual detector (lines303–421) requires the workflow npm tuple. Both root files absent select legacy; both regular select modern; a partial tuple fails. Legacy also requires absent declaration, Python lock and launcher. A bounded historical modern tuple can select node-only; full capability requires its current or evidenced historical inputs. Known absence at acquisition is supported. Creation of those omitted inputs later during setup is not authorized by that admission.

The acquired guard (lines438–446) and final guard (lines862–889) preserve the same eleven-path union. The final guard runs after successful detection, including after a later failure, with a two-minute bound. It refuses credential/Git configuration channels, isolates Git configuration, compares the index and worktree against explicit HEAD using `--` path filters, and checks untracked names. It does not load every listed file or require each path to exist. Git documents these index/worktree comparisons and the difference exit status. [Git diff](https://git-scm.com/docs/git-diff)

The command `git ls-files --others` intentionally has no standard exclusions, retaining visibility of ignored untracked setup inputs. Git's must-match `--error-unmatch` is an explicit option; this guard does not use it. The docs explain that distinction; the native controls establish the disputed absent-path behavior. [Git ls-files](https://git-scm.com/docs/git-ls-files)

## Completed evidence and limits

Root's saved offline probe extracted the unchanged final Bash script from the actual committed workflow. Workflow SHA2569f7ebf318a3be35c4f9c925d632a34557c889de0139f6ea4430f23a29285d1e6; guard SHA2561ce41462bd0087c0d0845ff756df8f92291ed4d8e48c597f71e9edb0d9ec716b. The worker read and hash-bound the source/probe/raw results/runtime receipt without execution.

| Native cases | Count | Actual result |
| --- | --- | --- |
| Clean legacy node-only, modern node-only, modern full | 3 | Each exit0 with empty output/error |
| Absent root manifest or Python lock created untracked, ignored-untracked or staged | 6 | Each exit1 with corresponding creation evidence |
| Tracked modifications across all three layouts | 3 | Each exit1 with diff |
| Tracked deletions in legacy/full layouts | 2 | Each exit1 with diff |

All14 expected outcomes passed. Fixture construction used `/usr/bin/git`2.43.0. The unchanged guard resolved PATH Git to `/usr/local/bin/git`2.55.0, established by a separate runtime-resolution receipt. Bash was5.2.21. Image sha256:8bdc7722fc55e19fd3df48d8fddf4568a75d8792cfc4ee105c8a8173559362f4 was offline/read-only with private temporary fixtures and no product mounts. Host execution exited0 between20:34:11.372446Z and20:34:20.545369Z; container absent. Root specified a50-second host bound.

These are exact-guard synthetic Git controls, not full historical dependency installations, every Git version, service selection, or hostile concurrent-writer safety. Contents are tiny placeholders; this probe did not execute layout detection. That scope is sufficient for the specific pathspec claim.

Existing Test-CiHelpers.test.mjs1616–1629 covers clean/index/worktree/index-masked/untracked/ignored-untracked;1906–1924 asserts dedicated/coding parity except the aggregate;1925–1960 exercises actual capability/install/final-guard steps. The saved Linux TAP contains17 relevant successful cases and600 total passes with zero failures/cancellations/skips/todo. Validator/SelfTest retain immutable revision/staged handling, optional review-workflow admission, regular-file/bounded/UTF-8 checks and credential projection controls. These are complementary contracts, not a second native proof of every historical layout. The original Linux wrapper remains failed; H94.1's later composite interpretation and independent aggregate do not rewrite it. The earlier cold-pair cleanup failure remains failed too.

## Materiality and security

The claimed functional failure is refuted within the measured native scope. Filtering to initially applicable, tracked or existing files discards absence as an invariant. A legacy run could create package.json, or node-only could create requirements-dev.txt, after detection without an omitted guard noticing. The six creation controls demonstrate untracked, ignored and staged channels. The remaining declaration/launcher/config/hook names have the same union purpose; their individual creation cases were not separately probed, so coverage there follows source/command semantics rather than additional measured cases.

The cached comparison also catches index changes hidden by restoring working HEAD bytes. Removing HEAD, dropping cached comparison, ignoring nonzero results or adding ignore exclusions weakens protection. Filtering by final existence can miss tracked deletions. Narrowing is safe only with separate complete protection for every omitted path's acquired absence and subsequent index/worktree/untracked transitions; that reconstructs the union with more state.

## Options and finding-specific rubric

Maintainers need a justified disposition; historical contributors need supported absence; security/toolchain owners need every governed transition checked; auditors need honest scope and preserved failures. No user interface, localization, cloud behavior or hook semantics change is warranted.

Hard constraints: preserve clean supported layouts, fail closed on real Git errors, detect staged/worktree/ignored-untracked changes throughout the union, retain credential/config controls, and avoid claiming broad acceptance from fixtures. Violations disqualify an option regardless of score.

Weights: **C correctness35** measures actual Git semantics and admission; **S security27** complete governed transitions; **U usability19** supported layouts and clear diagnosis; **E evidence11** direct native/regression coverage; **M maintenance5** simple coupled contracts; **R resource cost3** avoiding redundant runs/state. Total100; correctness/security/usability81. Ratings0–5:0 contradiction;1 major gap;2 partial coverage with material gaps;3 workable with stated tradeoffs;4 strong with a bounded gap;5 direct satisfaction with minimal uncertainty. Total=sum(weight×rating)/5. Prospective edits still require normal validation; scores do not claim their execution.

| Option | Concrete approach | C | S | U | E | M | R | /100 |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| A | Retain static union; refute claim | 5 | 5 | 5 | 4 | 5 | 5 | 97.8 |
| B | Narrow by layout/capability only | 3 | 1 | 5 | 3 | 4 | 4 | 58.4 |
| C | Initially tracked paths only | 2 | 1 | 4 | 2 | 3 | 3 | 43.8 |
| D | Initially existing filesystem paths only | 2 | 2 | 4 | 2 | 3 | 3 | 49.2 |
| E | Snapshot all paths/absence; retain current guard | 5 | 5 | 4 | 4 | 2 | 2 | 89.2 |
| F | Require every union path to exist | 1 | 5 | 0 | 2 | 5 | 5 | 46.4 |
| G | Retain diffs; drop untracked check or add exclusions | 2 | 1 | 5 | 2 | 5 | 5 | 50.8 |
| H | Narrow active paths plus explicit unchanged-absence guard | 4 | 5 | 4 | 3 | 2 | 2 | 80.0 |
| I | Whole-repository tracked diff plus static untracked union | 4 | 5 | 4 | 3 | 2 | 3 | 80.6 |
| J | Retain union; add permanent regression test/comment | 5 | 5 | 5 | 4 | 3 | 4 | 95.2 |
| K | Defer for more native evidence | 3 | 4 | 2 | 1 | 5 | 5 | 60.4 |

B/C/D lose omitted creation protection; D can also miss deletions if applied at final time. F contradicts historical admission. G misses untracked/ignored creations. E adds redundant snapshots and state/recovery obligations. H can preserve security but must govern every omitted name and adds a coupled contract. I broadens immutability beyond setup inputs without demonstrated need. J is a reasonable documentation/regression alternative, but existing permanent tests and14 exact controls already cover this finding; it adds product review/validation cost without fixing a defect. K was needed before native evidence arrived and is unnecessary now. B/C/D with complete omitted-path protection reduce to H/E. Bypass/error suppression is disqualified. E/H/I/J are feasible alternatives with unnecessary scope/cost. A97.8 best preserves measured correctness/security/usability.

## Controlled-English recommendation for root

1. Bind comment4200122706 to unchanged H504cd767 and the14 saved outcomes.
2. State that missing optional names are filters: all three clean native fixture layouts passed without pathspec errors.
3. Retain both unions, explicit HEAD, cached/worktree checks, ignored-untracked visibility, credential/config refusal and failure propagation.
4. Explain conditional omission's lost creation detection using the six absent-to-present controls.
5. Make no product change for this refuted claim. Root may reply/resolve under the active review policy after independent verification.
6. Continue reviews/CI/service acceptance on root-owned evidence. Do not rerequest for Lite or treat this result as dedicated-service proof, task closure or paired acceptance.

The worker performed no test/fixture/container/install, product/Git/native write, request, planning/state/counter edit or descendant work. Parent-reported ordinary CI progress is context only; no native state was polled. Transfers2/4/6/6 and existing rounds/deadlines are unchanged.
