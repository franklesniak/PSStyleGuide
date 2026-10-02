<!-- markdownlint-disable MD013 -->
# D16/D17 guide and narrow A14 applicability audit

RESULT: No new guide rule or concrete missing design contract identified. D16 B and D17 A stay within the private SelfTest setup; their stated guarantees do not justify a PS155 competing-writer repair. This is prospective contract applicability, not final independent quality or acceptance of in-flight bytes.

STATUS read first. Complete decisions read at planning `a2a7452b9b2109fa3e168278f5693797047e6b85`: D16 mode100644/blob `0f982d2015d6ac09e002c3da683b4e8be98f2768`, raw SHA-256 `b190599eb2599f0b18879ca69764536084d5bb1c995584895e1fe2cb15a4367a` (10,768 bytes); D17 mode100644/blob `ae7a86632808d8572a389d1c76a4d9bad91fa1d1`, raw SHA-256 `ecaa6cad2772881e20337affee070ea06f9f6cc8edab5daa0116650914f6026f` (10,850 bytes). STATUS records D17 evaluation5952426420/public release; I did not perform a native/public readback or action. Sole a02 writer ownership is preserved.

D16 reuses compatible hashing with disposal and exact Git header/raw identity. Intended index100644/100755, rather than physical execute-bit parity, is the consumed property. Private-clone-only fileMode=false plus explicit installation/readback through later add/dirty-context/B/H consumers preserves that distinction; it neither modifies source/global configuration nor removes intended-mode checks. The [Git contract](https://git-scm.com/docs/git-config#Documentation/git-config.txt-corefileMode) confirms this option controls honoring physical executable-bit differences. The record avoids claiming historical7.x/5.1 support or current vendor-supported-host regression without corresponding evidence. Existing guide typing, helper-help, disposal/error/refusal and output/test contracts suffice; no new runtime-floor policy is needed.

D17's authoritative inquiry is appropriate for the demonstrated static nonregular-input problem. [Pinned Node24.18.1 documentation](https://nodejs.org/download/release/v24.18.1/docs/api/fs.html#fslstatsyncpath-options) confirms lstat examines the leaf link itself, bigint stats retain wide numeric values, and Stats.isFile identifies regular files. The selected inquiry uses an already-required resolved Node application, constant program text/separate absolute path, shell-free argument transport, cleared Node preload/path variables, bounded stdout/timeout/exit/cleanup and exact small lexical success records. Failure/malformed/oversized/nonregular results refuse before OpenRead. Before/after identity comparison complements existing path/link/source/hash/bounds/index controls; it does not replace them. No production reader, new dependency/public protocol or source write is selected.

The no-competing-writer boundary is explicit and material. A separate lstat cannot bind the subsequent PowerShell handle to the checked path; the inquiry timeout does not time or make OpenRead atomic. Post-read checks do not prove protection against arbitrary adversarial swaps. This limitation belongs in the new private helper's actual help/test evidence. D17 already requires preserving the exit143 failure, proving prompt static FIFO refusal without external termination, ordinary/binary/mode preservation, failed inquiry/identity mismatch refusal and bounded process cleanup. Those tests remain implementation obligations, not passes from this audit. Its measured per-file inquiry cost is explicitly required; no batching/framework optimization is justified without evidence.

## Full guide inputs reused and verified

Previous complete applicable immutable reads were reused after raw identity verification at PS `fe3d6738d5b331f88e21bf6b9815883b3bb353b8`. All modes100644:

| Input | Raw SHA-256 |
| --- | --- |
| `.github/instructions/docs.instructions.md` | `d44a17724478620b5b47ca4c9990a1dc9850707c2460a3117f96157b9d58978b` |
| `STYLE_GUIDE.md` | `331a401e3f26dbd4c497e156784c8f3e41f17bc295ec9f6a734639f2d6bb62fd` |
| `powershell.instructions.md` | `fd993b9658f434af7b668d18670326c19d76a0728a170465c686d628ce2597f8` |
| `.github/copilot-instructions.md` | `e8c5d01dc227dc109e412f364c2d036ad17d59d5c56be942b87b0e5a16b2be34` |
| `.github/instructions/yaml.instructions.md` | `ceba4a87452eded866681a914bdb9049b9eda1ae71a000da27fe566c07fb72d3` |
| `.github/workflows/scripts-README.md` | `b6af48d2e2d29449c7ab302dcde88cdafa30c6573b89065fcd31ab5adf25b8f2` |

Canonical PowerShell whole normative coverage was proved previously by generated[73:]==canonical bytes; only five frontmatter lines differ. Exact identities remain unchanged. Inventory contains no separate JavaScript/Node instruction guide. YAML is contextual only: these decisions do not change workflow acquisition, and the separately owned A05 guide question is not duplicated. Existing private-helper/help, named-parameter/typing, failure and testing rules apply to the selected SelfTest helpers. Fixture-specific type/identity/race limits belong in their local contract; no generic guide addition is needed.

## A14 five-role recheck

Read complete accepted A14 RESULT (raw SHA-256 `e0315093270b188bded21b4c3668fb99eb97364160b86e618800f3fb9fdd6283`), task (SHA-256 `a8f24c55f06245a265b1e0b8ca9b1df4cbf3483a4dcec169e326afda4570cc3d`) and relevant native-evidence records. Independently verified each PS native48f4 role blob/mode equals D92's8d9d8e4 input, and its raw hash equals the accepted record:

| D92 role | Native raw SHA-256 |
| --- | --- |
| Generator | `b65985bbda043ad16530d775ddc2f5c7e25ca2185a704605d7c8d9b09b4eda48` |
| Exact-path verifier | `b4cdfe400a8efcb4aab47433775966e898bb5e76e1e9161c02e26a03638be909` |
| Artifact verifier | `41a3a6afeed7d49a78b8112d6477f49b8f329de4e7d77c5e4789ca68f156f996` |
| CONTRIBUTING | `01091a192353fc5c571d6cdc37c451c5c5c33c115c55280fb1c71053bf78c5cc` |
| Build workflow | `d08cd80a10e75f0d998175c23c0a146edc7137f3a4f943da6b0278130bce02c0` |

The four code/workflow roles are also byte-identical at immutable PRfe3d. CONTRIBUTING changed in A02, so no five-whole-file current-candidate equivalence is claimed: its entire generation/publication caller section remains exactly native after comparing immutable fe3d, and D16/D17 select only SelfTest changes. The new reader is a real additional private consumer and was assessed here. Its static FIFO defect/Node type primitive do not close a live D92 create/publication/cleanup substitution window or admit a concurrent hostile writer. No credential/privilege/publisher/shared-runner authority change is selected. Thus the five-role conditional remains applicable to those pinned inputs; it is not a blanket declaration about every new reader or final candidate.

Keep PS155 open under its maintainer-owned residual, preserve PS156 retirement and historical test limits. Preserve original379 replacement,380 absent trigger,381–388 conditional dispositions and389/390 unverified whole-product obligations. No history credit, live issue refresh/closure or competing-writer repair is supplied. Reassess actual final changed callers/authority/primitives if they supply a concrete applicable trigger; do not revive retired helpers or extrapolate static refusal into race safety.

Limits: requested gpt-6.1-sol/medium, effective metadata unavailable. No descendants/tests/product/planning/native writes or changing-source quality acceptance. Only this scratch report written. Final independent quality remains separate after current remote quiescence; A02/PS224 rounds1/80, transfers0/12 and original request2026-10-02T07:26:08.214692Z/deadline2026-10-10T07:26:08.214692Z remain unchanged. No new request/transfer/separate loop.
