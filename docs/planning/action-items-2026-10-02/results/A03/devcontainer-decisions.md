<!-- markdownlint-disable MD013 -->
# A03-D8: Devcontainer inventory and acquisition

Selected 2026-10-04. The coordinator inspected both native workflows, the real-Git fixture, primary documentation and all19 score totals. Both option lists, distinct rubrics and full tables were displayed before selection. U98 and S96 are selected; scoped private implementation is active. This is a remaining A03 source-first change after the current PR230 batch. It does not complete A03 or activate TF. No product, index, planning, native ref or setting was changed. The current aggregate was not disturbed.

## Input and boundary

Read STATUS, tasks/A03.md, results/A03/remaining-interfaces.md, A03-D3 and DECISION-PROCESS.md. The exact source workflows came from `git show`, not checkout contents:

| Repository | Native revision | Workflow blob | Bytes |
| --- | --- | --- | ---: |
| PS | 3e068afa36fbc963c4d716df9efb245468791fe8 | dde42437f9f5d579abee2e944321488a2ba4f793 | 3863 |
| TF | 06ad4f7c9b6847028cafdacf1ae55128d0f2d56c | bfad83b60e7a808d6f44ae11d4e6fab8d73cfaec | 7645 |

Both workflows run on Ubuntu 24.04, have `permissions: {}`, a ten-minute timeout, and no cancellation of older checks. Both fetch the exact event SHA anonymously into a fresh repository and compare the resulting commit ID. Neither checks out the candidate, runs candidate scripts, installs a devcontainer, or reads a candidate policy/configuration file. Preserve these properties and existing event coverage. A pull-request run checks the event merge snapshot, not independently the contributor head; this is an exclusion snapshot, not accepted-base approval.

The accepted `Validate-WorkflowPolicy.mjs` deliberately covers only build.yml and markdownlint.yml. Its co-located accepted contract is not a devcontainer authority. The classifier does classify every immediate `.github/workflows/*.yml`/`*.yaml` entry as maintenance. `git grep` found no devcontainer coverage in either repository's non-YAML workflow helpers/tests. The current tests here are inline Bash fixtures, which do not prove the caller's Git inventory flags. D3 requires common algorithms and preservation of useful checks; it does not authorize claiming immutable devcontainer validation where none exists. New focused tests must execute the extracted actual workflow body. They are regression evidence, not a new independent accepted-policy gate.

## Finding I: incomplete and inconsistent tracked-path inventories

**Validated cause and materiality.** PS uses a root-only, line-delimited `ls-tree` list. It misses nested devcontainer entries. TF recurses and reads unquoted NUL records, which preserves unusual names, but `-r` without `-t` omits tree entries. An actual Git tree object containing an empty `.devcontainer` subtree is rejected by PS and missed by TF. The empty-tree case is a preservation oracle for representable Git objects, not a claim that an ordinary index creates empty directories or that GitHub accepts this exact constructed object. No hosted experiment was made. The [Git ls-tree documentation](https://git-scm.com/docs/git-ls-tree) distinguishes recursion, inclusion of tree entries, and NUL output without quoting.

**Stakeholders.** Maintainers need one common boundary. Contributors with Unicode or newline filenames need deterministic results without false positives. Security reviewers need candidate paths treated only as data. QA needs regressions that detect changed Git flags, not just a copied matcher. The UX director needs a clear forbidden-path versus malformed-inventory failure. Future maintainers need the original root and nested behavior retained.

**Options, before scoring.** These cover retaining either current reader, changing its transport, combining their useful checks, and replacing the acquisition/reader mechanism. Each can pair with any eligible acquisition option below; duplication of their Cartesian product would not change either finding's tradeoffs.

- N: keep the divergent PS and TF implementations.
- P: use the PS root-only implementation in both repositories.
- T: use the existing TF recursive NUL implementation unchanged in both.
- L: recurse but keep line-delimited/quoted output and decode it in Bash.
- U: use one TF-style full-stream NUL matcher and `ls-tree -r -t --full-tree --name-only -z`; preserve root, nested, case-fold and malformed-tail checks.
- D: use separate root and recursive NUL inventories, then combine results.
- J: add a Node helper to parse the full NUL tree inventory; acquire its accepted executable source separately.
- C: check out the event tree and scan filesystem paths.
- R: replace Git inventory with a recursive GitHub tree API response, including pagination/truncation controls and a JSON parser.

**Unique rubric.** Scores 1â€“5; total = sum(weight Ã— score)/5. Completeness 35%: retain root/tree entries and nested entries without false negatives. Filename correctness 25%: preserve exact records and distinguish malformed data from clean data. Contributor/UX clarity 15%: stable results and direct actionable errors. QA observability 15%: test actual inventory-to-reader behavior and failure propagation. Operational simplicity 10%: no extra runtime/API or duplicated traversal. Correctness and usability precede churn. Hard constraints: no candidate execution or checkout, no permission/token increase, no lost useful checks, and malformed acquisition/inventory must not report success. Ineligible scores remain visible; scores do not override constraints.

| Option | Completeness 35 | Filenames 25 | UX 15 | QA 15 | Simplicity 10 | Arithmetic numerator / 5 | Total | Eligible |
| --- | ---: | ---: | ---: | ---: | ---: | --- | ---: | --- |
| N | 2 | 3 | 2 | 2 | 5 | (70+75+30+30+50)/5 | 51 | No: gaps persist |
| P | 2 | 2 | 3 | 2 | 5 | (70+50+45+30+50)/5 | 49 | No: loses TF checks |
| T | 4 | 5 | 4 | 4 | 5 | (140+125+60+60+50)/5 | 87 | No: loses tree entry check |
| L | 4 | 2 | 2 | 3 | 3 | (140+50+30+45+30)/5 | 59 | Yes, requires a complete quote decoder |
| U | 5 | 5 | 5 | 5 | 4 | (175+125+75+75+40)/5 | 98 | Yes |
| D | 5 | 5 | 4 | 4 | 3 | (175+125+60+60+30)/5 | 90 | Yes |
| J | 5 | 5 | 4 | 4 | 2 | (175+125+60+60+20)/5 | 88 | Yes, with extra trusted bootstrap |
| C | 3 | 3 | 3 | 3 | 2 | (105+75+45+45+20)/5 | 58 | No: checkout changes boundary |
| R | 4 | 5 | 3 | 3 | 2 | (140+125+45+45+20)/5 | 75 | Yes, if complete response verified |

**Selected solution: U, 98.** The one traversal preserves the useful union without a new runtime. T's smaller diff is not a reason to drop an existing check.

**Direct implementation instructions.** Use the same inline reader and Git command in both repositories. Set `LC_ALL=C` for ASCII case folding. Read NUL records to the end. Match `.devcontainer` as a complete path component at any depth, and `.devcontainer.json` as a complete final component. Retain near-match exclusions. Return 0 for a match, 1 for a clean complete inventory, and 2 for a malformed tail. Do not return early after a match: a later malformed tail must still fail. Write `git ls-tree -r -t --full-tree --name-only -z` output to a private file; check Git success before parsing. Do not store NUL bytes in shell variables. Fail the workflow for a forbidden path, malformed inventory, or Git failure. Distinguish these diagnostics. Keep the existing inline fixtures and add the tree-entry preservation case to the external real-Git tests.

## Finding A: acquisition URL validation differs from the actual supported environment

**Validated cause and materiality.** PS fixes github.com but validates the repository shape. TF binds the native `github.server_url` and validates a server string with `^https?://[^/?#[:space:]]+$`. The extracted function accepts HTTP and user-info such as `https://user@ghe.example`; it rejects a path. This is not evidence of a candidate-controlled attack: the value is a native GitHub context, not repository data or a PR field. The material decision is whether to preserve server-derived acquisition coherently, and what inputs the helper can truthfully accept for anonymous HTTPS acquisition. A bare regex match is not evidence that every accepted string is a supported deployment.

GitHub documents [server_url as the GitHub server URL and repository as owner/name](https://docs.github.com/en/actions/reference/workflows-and-actions/contexts). Fixed github.com is correct for these two current repositories; server-derived acquisition avoids fetching the same owner/name from the wrong server when the workflow is legitimately reused. Do not conflate that useful construction behavior with permission to migrate either repository.

[GitHub Enterprise Server does not provide GitHub-hosted runners](https://docs.github.com/en/enterprise-server@3.20/actions/how-tos/manage-runners/self-hosted-runners/add-runners). Therefore the TF `ghe.example` URL fixture is not proof that this unchanged Ubuntu hosted workflow can run on GHES. Conversely [Enterprise Cloud hosted-runner documentation includes GHE.com data-residency networking](https://docs.github.com/en/enterprise-cloud@latest/actions/reference/runners/github-hosted-runners); a non-github.com server is not inherently incompatible with hosted runners. However, [GHE.com permanently excludes public repositories and requires authentication for all API requests](https://docs.github.com/en/enterprise-cloud@latest/admin/data-residency/feature-overview-for-github-enterprise-cloud-with-data-residency). Hosted-runner availability therefore does not establish end-to-end support for this anonymous workflow there. Current demonstrated hosting remains these public GitHub.com repositories. Preserving server-derived construction means selecting the correct native origin and failing if anonymous access is unavailable; it does not supply access or declare an enterprise deployment supported. Neither URL validation nor these tests prove another deployment can fetch its event objects.

**Stakeholders.** Security wants credentials and cleartext excluded without implying an attack from trusted context. Maintainers want the current public repositories to keep working. Enterprise users need honest capability limits. Contributors and the UX director need early configuration errors rather than a misleading later clone failure. QA needs actual URL/argument assertions plus acquisition failures. Platform owners retain decisions about hosts, visibility, credentials and runners.

**Options, before scoring.**

- K: retain each repository's current acquisition construction unchanged.
- F: converge on fixed HTTPS github.com; explicitly reject any other native server context.
- T: copy TF's current permissive HTTP/HTTPS builder into both.
- H: use a common native-context builder with strict HTTPS DNS authority and owner/repository validation, no credentials or URL decorations; retain anonymous exact-SHA fetch. Do not broaden deployment claims.
- S: retain native server/repository context, validate the HTTPS-only authority envelope without user-info or URL decorations, and let Git validate hostname/IP syntax, DNS resolution and ports. Keep anonymous exact-SHA acquisition and fatal transport errors.
- G: H plus an allowlist restricted to github.com and valid single-tenant `*.ghe.com` names.
- M: use an accepted per-repository server allowlist/configuration with H.
- E: interpolate server_url directly and let Git parse it, retaining repository validation.
- A: replace anonymous fetch with a token-bearing checkout action and private-host support.
- V: keep F now and add H only in a later explicitly requested host migration (a staged combination).

**Unique rubric.** Scores 1â€“5; total = sum(weight Ã— score)/5. Acquisition integrity 30%: unambiguous HTTPS origin, no user-info, exact native repository/revision. Honest compatibility 25%: retain useful construction behavior without promising unsupported hosting or breaking the current deployment. UX/failure clarity 20%: reject malformed input early, preserve useful diagnostic causes. QA specificity 15%: test negative inputs and actual fetch identity/control flow. Maintenance 10%: readable bounded code without a new policy bootstrap. Hard constraints: native context only; no candidate URL/configuration authority; no token or privilege expansion; exact commit equality and fatal acquisition failures remain. Unsupported HTTP/user-info need not be preserved as a compatibility feature. No option authorizes host migration or self-hosted runner deployment.

| Option | Integrity 30 | Compatibility 25 | UX 20 | QA 15 | Maintenance 10 | Arithmetic numerator / 5 | Total | Eligible |
| --- | ---: | ---: | ---: | ---: | ---: | --- | ---: | --- |
| K | 3 | 3 | 3 | 2 | 4 | (90+75+60+30+40)/5 | 59 | Yes, leaves drift |
| F | 5 | 3 | 4 | 5 | 5 | (150+75+80+75+50)/5 | 86 | Yes, gives up portable construction |
| T | 2 | 4 | 3 | 3 | 5 | (60+100+60+45+50)/5 | 63 | No: accepts cleartext/user-info |
| H | 5 | 4 | 5 | 5 | 3 | (150+100+100+75+30)/5 | 91 | Yes, imposes a new DNS/IP policy |
| S | 5 | 5 | 4 | 5 | 5 | (150+125+80+75+50)/5 | 96 | Yes |
| G | 5 | 4 | 4 | 5 | 3 | (150+100+80+75+30)/5 | 87 | Yes, additional host policy without need |
| M | 5 | 4 | 3 | 4 | 2 | (150+100+60+60+20)/5 | 78 | Yes, accepted configuration bootstrap needed |
| E | 2 | 4 | 2 | 2 | 5 | (60+100+40+30+50)/5 | 56 | No: unclear credential/protocol boundary |
| A | 4 | 4 | 3 | 3 | 2 | (120+100+60+45+20)/5 | 69 | No: expands privileges and checkout |
| V | 5 | 3 | 3 | 4 | 4 | (150+75+60+60+40)/5 | 77 | Yes, defers useful common behavior |

**Assessment of S and correction of H's score.** S satisfies the trust, anonymous-access and exact-SHA constraints. Its input is the native `github.server_url`, not candidate data. Rejecting a non-HTTPS scheme, user-info and URL decorations preserves the intended construction boundary; Git then parses one quoted URL and its failed fetch remains fatal. Delegating a malformed port or unresolved host to Git cannot turn a failed acquisition into success because exact fetched-commit equality is still mandatory. S does not claim to make Git configuration, redirects or the entire runner hermetic; neither H nor the existing workflows establishes that separate property. No new transport trust claim is made.

H's DNS-label lengths, label-edge rules, 1–65535 port arithmetic and exclusion of IP/IPv6 literals were **new proposed restrictions**, not inherited repository policy. The actual supported deployment uses GitHub.com; that observation is not a DNS-only contract for the native GitHub context. TF currently accepts authority strings without those rules, and [Git documents HTTP(S) host and optional-port URL syntax](https://git-scm.com/docs/git-clone#_git_urls). No inspected current contract requires a custom duplicate hostname/port parser. HTTP/user-info rejection is also new hardening relative to TF, but it directly states the chosen HTTPS/anonymous envelope; it is not evidence that trusted GitHub context currently emits malicious input.

The original H score overvalued compatibility and maintenance. Under the unchanged rubric, H now has compatibility 4 (unnecessary exclusions) and maintenance 3 (custom DNS/port rules plus their test burden), giving 91. G inherits that custom parser burden, so its maintenance score also falls to 3, total 87. S scores 96: integrity 5, compatibility 5, UX 4, QA 5 and maintenance 5. Its honest UX cost is that invalid host/port values fail at Git acquisition rather than in an early bespoke message. H retains UX 5 for its earlier diagnosis. Git's existing failure diagnostic plus a clear acquisition-failed context is sufficient for these trusted inputs. We did not change the weights to make S win; the missing option exposed an unsupported restriction and an overgenerous prior score.

**Selected solution: S, 96, combined with U above.** Preserve TF's server-context binding with a small HTTPS/anonymous envelope. Delegate transport syntax and resolution to Git. Do not add an unsupported enterprise deployment claim. The prior H98 proposal is retained under a dated `PROPOSAL-prior-*.md` filename and remains unselected history.

**Direct implementation instructions.** Bind `EXPECTED_SERVER_URL` from `github.server_url` through job environment. Keep `EXPECTED_REPOSITORY` and `EXPECTED_REVISION` from native context. Use one common builder. Accept the literal `https://` scheme, a nonempty authority, and at most one trailing slash. Reject HTTP, user-info (`@`), whitespace/control bytes, backslashes, paths, query strings, fragments, empty authority and repeated trailing slashes. Do not implement DNS-label lengths, hostname/IP classification, DNS resolution, port-range arithmetic or an alternate-origin fallback. Leave authority internals, including hostname/IP and port validity, to Git's HTTPS transport. Validate owner/repository as two nonempty GitHub-style path segments; reject `.`/`..` segments and URL delimiters. Construct one quoted HTTPS remote argument. Do not obtain an origin, server override, executable helper or allowlist from candidate files. Keep anonymous fetch flags, credential suppression, fresh directory, exact fetched commit comparison and local credential residue check. Reject an all-zero event SHA before acquisition. Preserve Git's useful error and make any acquisition failure fatal. Do not add retries, authentication, runner changes, fallback hosts, or skipped-success paths. Keep failures within the existing ten-minute job bound. A URL construction result, including an IP/port-shaped authority accepted by this envelope, is not a claim that a GitHub deployment is supported or reachable there.

## Exact scope and meaningful validation

Selected source path set: `.github/workflows/devcontainer-ci.yml` and `.github/workflows/Test-CiHelpers.test.mjs` only. No validator/contract/classifier/package/lock/instruction changes are needed: discovery already classifies the YAML and the helper test file is already in the maintenance set and Node test caller. After PS native acceptance, port the same two changes to TF while retaining its other helper tests. Use a common private directory basename and neutral diagnostics so the algorithm/body can be identical; retain only proved repository display-name text if useful. No new configurable framework. Coordinate this test-file writer with pending D6 and the accepted A03 batch; do not mutate the currently running aggregate input.

Required meaningful validation:

1. Parse the actual YAML with the already locked parser. Assert native environment bindings, `permissions: {}`, Ubuntu runner, ten-minute bound, no job permission override, existing triggers/concurrency, and no checkout/action/token/candidate helper path. Extract and execute the actual run body on Linux with declared substitutions only. Windows may verify extraction/shape but must not claim Bash runtime coverage.
2. Use real Git objects for root and nested files/directories, uppercase names, UTF-8 and newline-containing parent names, root and nested empty forbidden-name trees, and a gitlink named `.devcontainer`. Include unrelated `.env`, `.devcontainer-example`, and `.devcontainer.json.bak` controls. Prove a synthetic malformed tail fails even after a match. Empty valid trees must pass. Preserve both match/no-match status semantics and workflow failure statuses.
3. Assert the exact `ls-tree -r -t --full-tree --name-only -z` argument shape and execute it against those objects. Mutate away `-r`, `-t`, and `-z` individually; each must fail its targeted oracle. Mutate the reader to return after its first match; the malformed-tail oracle must fail. This catches transport/reader coupling that the existing inline fixtures miss.
4. Exercise GitHub.com, a GHE.com-shaped host and host/port or bracketed-IP authority construction locally. These are envelope tests, not deployment claims. Reject HTTP, user-info, path/query/fragment, slash/backslash/control cases, empty authority, empty/dot repository segments and zero/invalid SHA before any fetch. Do not require early helper rejection of malformed DNS or out-of-range ports: test that a real Git transport parse/acquisition failure propagates as workflow failure, preserving its diagnostic without a custom parser or retry. Assert that the native server host, not a candidate origin or hard-coded alternate, determines the URL. A GHES-shaped construction case must expressly make no hosted availability claim.
5. Use a local immutable Git remote substituted only at the transport boundary after asserting the original expected HTTPS URL/flags. Keep Git's init/fetch/revision/tree operations real. A harmless candidate script marker must never execute. Verify clean success and failure propagation for fetch failure, wrong returned commit, inventory failure, malformed output, existing destination and credential residue. No production network, runtime archive, token or candidate execution in this fixture.
6. Run focused helper tests and actionlint after implementation, then the ordinary source aggregate and native lifecycle at the final candidate. Verify final raw common blobs/modes against TF after its later transfer. Do not reuse this private prototype as aggregate, hosted or publication proof.

## Evidence obtained now and limits

`inputs.json` records both raw Git blob identities/hashes and all fixture trees/inventories. `prepare.py` saves the exact native workflows and extracts their reader/URL functions unchanged except reader function names. It creates private bare Git objects with inert content. `probe.sh` runs those functions against real Git output. One existing image was used read-only with networking disabled: `psstyleguide-a03-linux:20261003`, image ID `sha256:759d782b64b4ff257f028c67d3dfed291d42c20f76776eca9ca8c11b91e0f7ee`, Bash 5.2.21. No build/install or host configuration change occurred.

Command: `docker run --rm --network none --read-only --mount type=bind,source=C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A03-devcontainer-decision-20261004,target=/input,readonly psstyleguide-a03-linux:20261003 -c 'bash /input/probe.sh'`. Terminal exit 0; all 15 inventory observations matched the expected matrix. Root match: all 0. Nested/newline: PS 1, TF/union 0. Empty forbidden tree: PS/union 0, TF 1. Near match: all 1. Malformed after match: TF 2. URL observations: GitHub, generic HTTPS, HTTP, user-info and GHE.com-shaped URL accepted; path rejected. Status 0 means matched/constructed, not workflow success. No failed fixture runs occurred.

This probe does not run the full workflow, remote acquisition, GitHub dispatch, a new strict URL implementation, or a future regression suite. It makes the inventory preservation issue concrete and reproduces the current URL contract. No owner authority is missing for proposal preparation. The coordinator displayed these finding-specific options, rubrics and tables, then selected U98 and S96 and released private implementation. Product integration still follows the current source acceptance gate. Any host migration, private authentication, runner installation or new immutable-policy framework is outside this proposal and needs its own actual requirement. Current A03 and source-first release gates remain open.

## Coordinator verification and current boundary

The prior H98 proposal was not implemented. Parent review identified the missing smaller option and requested an explicit contract basis for the extra DNS/IP rules. The revised unchanged-weight rubric selects S96; no human decision is needed. Short direct instructions use the requested writing approach; formal controlled-dictionary certification is not claimed.

Private proposal source SHA256 is58f73c4221d277a4ebf0cafa6807d3e2928065a9f0827e84c054678a6904c85b; evidence.json is8aea9809c28ddc74e7d3476508634318316f2992c8303e1eff7a5d260de2cdf9; probe.log is171614b9cb6e894bbfc0a1e20786415eb96584994bc1466c4913b85fc5414247. Parent inspected the exact reader/URL functions, compared their observations and checked all19 weighted totals. Native modes are100644; private sources and fixture data remain in C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A03-devcontainer-decision-20261004.

The same routed worker owns only the two-file private candidate in C:/Users/flesniak/AppData/Local/Temp/PSStyleGuide-A03-devcontainer-implementation-20261004. It starts from the already frozen D7 all75-file archive, SHA256 df7079920be986991a55f9a670668db320e77075f66e56bd498aafafecfef8a6. No product/index/private lifecycle-state mutation, full aggregate, native write, peer transfer or new runtime installation is authorized by this preparation. Actual source integration remains after PR230 acceptance, with D6 sharing test-file ownership serially.
