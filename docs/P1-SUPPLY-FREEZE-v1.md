<!-- markdownlint-disable MD013 -->
# Reproduce the P1 supply-freeze evidence

## Metadata

- **Status:** Active
- **Owner:** Repository Maintainers
- **Last Updated:** 2026-09-21
- **Scope:** Manual, read-only supply observation and separate historical provenance verification for issue 158. This method does not change the P1 schema or integrate a workflow gate.
- **Related:** [Issue 158](https://github.com/franklesniak/PSStyleGuide/issues/158), [policy contract](../.github/workflows/workflow-policy-contract.json), [recorder](../.github/workflows/Get-SupplyFreezeDigest.mjs), [focused tests](../.github/workflows/Get-SupplyFreezeDigest.test.mjs), [baseline decision](decisions/0002-accept-unverifiable-baseline-provenance.md)

## Meaning of a successful run

The recorder copies the existing `supplyFreeze` object without changing its `P1-SUPPLY-FREEZE-v1` schema, field names, values, or types. It emits new measurements under `currentObservation`. The historical producer is Windows/x64; the current recorder supports Linux/x64. These are different events. A current Linux installation cannot reconstruct the historical Windows installation.

`currentObservation.complete: true` means that the current measurement passed the recorder's toolchain, manifest, installed-tree, configuration, live-audit, and consistency guards. It does **not** verify every historical assertion, approve an advisory, extend an expiry, or replace a policy decision. The output states that policy authorization was not evaluated. A consumer must separately verify the historical evidence it needs and obtain an applicable advisory disposition. The existing owner, issue 149 reopener, and `2026-10-29T23:59:59.000Z` expiry remain unchanged.

`--no-audit` and `--any-toolchain` produce explicitly incomplete observations. Neither bypasses the cache boundary, authenticated npm-installation digest and census, installed/npm-tree safety refusals, or during-run consistency checks. `--any-toolchain` relaxes only the listed runtime/version/configuration/manifest/tree comparison guards; it never authorizes executing different npm bytes. Unsupported hosts refuse; there is no Windows emulation claim or BSD claim. The Windows refusal test proves that boundary, not a Windows supply measurement.

The recorder runs no install, Git command, lifecycle script, or workflow. It writes only stdout and stderr itself. Its npm children can write cache and diagnostic files in a caller-created private external directory. The caller must direct stdout outside the repository. Creating that directory, acquiring Git objects, and installing dependencies are separate preparation steps, outside the read-only measurement interval.

## Immutable source and adaptation

The source is [TerraformStyleGuide PR 27](https://github.com/franklesniak/TerraformStyleGuide/pull/27), merge commit `aae05282b57f093cec8b63e59138db72c982f10e`:

| Role | Immutable input |
| --- | --- |
| Recorder | [Get-SupplyFreezeDigest.mjs](https://github.com/franklesniak/TerraformStyleGuide/blob/aae05282b57f093cec8b63e59138db72c982f10e/.github/workflows/Get-SupplyFreezeDigest.mjs), Git blob `05778c0eda0273a9217f7dc953795c2240473a14` |
| Complete upstream method | [T1-SUPPLY-FREEZE-v1.md](https://github.com/franklesniak/TerraformStyleGuide/blob/aae05282b57f093cec8b63e59138db72c982f10e/docs/T1-SUPPLY-FREEZE-v1.md), Git blob `36010d2dac98631845d8e880689f7c315ccbcdb7` |
| P1 policy input | [PS commit 986a78cf](https://github.com/franklesniak/PSStyleGuide/tree/986a78cfad02abe9698ee258735d8451abeb9249), tree `9d97ac36c2c75916e17070ad8d22c9417a896722`, contract blob `7b45290c0aedfce01b1d156012afa06ca367a560` |

The installed-byte fold, npm-distribution authentication, configuration checks, JSON duplicate-key checks, advisory normalization, and quiescence checks derive from the upstream implementation. The port changes four current-manifest constants, adds the unchanged P1 assertion envelope and contract snapshot, requires external npm housekeeping authority, emits explicit null/empty fields for an intentionally skipped audit, preserves structured stderr diagnostic summaries without publishing child text, withholds every unsupported argv token and filesystem path/name from public diagnostics, translates descriptor I/O failures through each caller's documented refusal, restricts audit failures to the documented native outcome, exact-decodes every semantic npm stdout response, emits fixed JSON-response and npm-tree-check refusal categories without source content, rejects lossy UTF-8 JSON decoding, validates every present non-null advisory URL as a string, requires non-owner write bits to be clear on controlled inputs, makes installed-tree link containment and reviewed npm-installation identity unconditional, applies the same component-by-component resolver to links inside the npm installation, and publishes only fixed numeric audit-package summaries while keeping complete normalized response strings as inputs to the published normalized digest. These are explicit differences, not a claim of whole-recorder byte identity. Historical upstream review comments in the source describe T1; this method governs the P1 port.

The P1 assertion object is pinned by SHA-256 of recursive sorted-key JSON, without insignificant whitespace: `83c5138131de742734d22a818e21feb63d5ac11f8877adf52299809f04217362`. Changing an assertion requires a reviewed recorder change. Other contract fields can change without changing that assertion tuple; the complete raw contract identity is still reported and checked for changes during the run.

## Field provenance and output types

The JSON envelope has three objects: `supplyFreeze`, `provenance`, and `currentObservation`. It is not a replacement policy schema. In the table, **asserted** means copied from the pinned contract; **derived** means computed during this run; **external** means that the recorder does not perform the verification.

| Field or complete field family | Type | Provenance and verification |
| --- | --- | --- |
| `supplyFreeze.schema` | string | Asserted, exactly `P1-SUPPLY-FREEZE-v1`. |
| `supplyFreeze.reviewedCommit` | 40-character hexadecimal string | Asserted historical commit. External Git procedure below verifies its type and both path relationships. It is not today's HEAD. |
| `supplyFreeze.baseline.packageJson` and `.packageLockJson`: `blob`, `length`, `sha256` | string, nonnegative integer, string | Asserted historical raw Git blobs. External procedure verifies object ID, byte length, SHA-256, and commit/path membership. Working-tree line endings are not an input. |
| `supplyFreeze.reviewedWorkingBytes.packageJson` and `.packageLockJson`: `length`, `sha256` | nonnegative integer, string | Pinned assertions matched against actual current files in a strict run. The fixed SHA-256 and Git blob guards identify their exact bytes. A bypassed mismatch leaves `verifiedCurrentBytes` empty. |
| `supplyFreeze.producer`: `nodeVersion`, `npmVersion`, `platform`, `nodeArchive`, `nodeArchiveLength`, `nodeArchiveSha256`, `signedChecksums`, `signatureFingerprint`, `argv` | strings, integer length, string array argv | Asserted historical producer, archive, signature, and invocation. External archive/signature records must establish those claims. A current runtime cannot prove what command ran in the past. |
| `supplyFreeze.yaml`: `version`, `tarball`, `tarballLength`, `tarballSha256`, `integrity`, `enginesNode` | strings and integer length | Asserted package provenance. Tarball bytes and registry/signature evidence require external verification. Current installed payload bytes are measured separately. |
| `supplyFreeze.installedTree`: `packageCount`, `canonicalInstalledTreeLength`, `canonicalInstalledTreeSha256`, `canonicalLockTreeSha256` | two integers, two hexadecimal strings | Asserted historical values. No complete historical encoding recipe is established here. They are not regenerated, guessed, or equated to the new byte-fold digest. |
| `supplyFreeze.advisoryDecision`: `decisionOwner`, `recordedAtUtc`, `expiresAtUtc`, `expiresEarlierOn`, `policy`, `reason`, `compensatingControls` | strings and string array | Asserted historical authorization and its limits. The recorder does not approve findings or extend this decision. |
| `supplyFreeze.advisoryDecision.gateAudit` and `.producerAudit`: `observedAtUtc`, `command`, `nodeVersion`, `npmVersion`, `nativeExit`, `stdoutLength`, `stdoutSha256`, `vulnerabilities`; producer-only `findingKeys` | strings, integers, counts object, string array | Asserted historical raw audit evidence. External original response bytes are needed to verify their hashes. A new network response cannot prove those old hashes, timestamps, or dispositions. |
| `provenance.historicalAssertions`, `.verifiedCurrentBytes`, `.externalVerificationRequired` | string arrays | Explicit scope labels. They do not turn an asserted field into a measurement. |
| `provenance.historicalInstalledTreeRecipe` | string | States the unsupported reconstruction claim explicitly. |
| `provenance.contractSha256`, `.contractBlob` | hexadecimal strings | Derived from complete raw contract bytes, with before/after bytes, inode, and change-time checks. |
| `currentObservation.complete`, `.incompleteBecause`, `.policyAuthorization` | boolean, string array, string | Current measurement standing, reasons for incompleteness, and explicit absence of policy authorization. |
| `currentObservation.script.sha256` | hexadecimal string | Self-observed script bytes. Requires external verification before execution; it cannot authenticate itself. |
| `currentObservation.toolchain`: `node`, `npm`, `npmTree`, `platform`, `arch`, `umask` | strings | Observed runtime and authenticated npm-content fold. The npm tree digest and 1,916-file census are required in every mode. The raw npm version response is retained only for the strict equality check; the public `npm` field is the bounded numeric core plus fixed labels for withheld prerelease/build metadata, or a fixed length-only description for unrecognized output. Node itself must be authenticated externally. Strict host is Linux/x64, Node `v24.18.1`, npm `11.16.0`, umask `0022`. |
| `currentObservation.manifest`, `.manifestBlobs` | objects with `package.json` and `package-lock.json` string properties | Derived SHA-256 and Git blob IDs of current raw files. No Git subprocess is used. |
| `currentObservation.matchesReviewedManifest`, `.treeSatisfiesLockfile` | booleans | Exact current-file guard and actual `npm ls` result, including root path and complete declared top-level dependency set. |
| `currentObservation.installedTreeSha256`, `installedTreeFiles`, `installedTreeSymlinks`, `installedTreeDirectories`, `installedTreeSpecials`, `installedTreeModes`, `installedTreeDirectoryModes`, `installedTreeRootMode` | string, four integers, two mode-count objects, string | Derived from the entire installed tree, including ignored files. Two folds compare every returned field. These fields use the upstream byte recipe, not the historical P1 canonical recipe. |
| `currentObservation.registry`, `.auditSha256`, `.auditEnvironmentScrubbed`, `.auditCounts`, `.auditPackages` | string/null, string/null, array, counts object/null, fixed summary object/null | Public registry projection and normalized advisory recipe. Only the exact reviewed registry retains its authority; other HTTP(S) values retain a fixed scheme category, and other parseable or malformed values expose no caller-controlled protocol, authority, port, path, query, or fragment. Package keys, advisory identities, and inherited `via` names remain inputs to the published normalized digest. The public `auditPackages.directAdvisory` and `.inheritedOnly` objects each contain only integer `info`, `low`, `moderate`, `high`, `critical`, and `unclassified` counts; direct-advisory means the normalized record has advisory entries, not npm's separate `isDirect` project-dependency flag. An intentionally skipped audit emits explicit null values and an empty scrub list. Raw historical audit digests use a different recipe. |
| `currentObservation.npmProcesses[]`: `operation`, `nativeExit`, `signal`, `stderrLength` | string, integer, null, integer | Actual child outcomes in a successful complete observation; only audit may have native status 1 there. An incomplete diagnostic observation can retain the documented npm-ls native failure. Every semantic stdout byte stream is exact-decoded before parsing or comparison. Stderr remains diagnostic-only: its length counts decoded child characters and public diagnostics expose fixed categories and lengths, not child text or raw bytes. |

Audit counts use nonnegative safe integers for `info`, `low`, `moderate`, `high`, `critical`, and `total`; the buckets must sum to total. The complete upstream method specifies the byte-fold framing and advisory normalization. In brief: SHA-256 over sorted entries with single-byte kind tags and ASCII-decimal-length-prefixed UTF-8 paths, permission masks, raw link targets, and file bytes. The root, directories, and files include `mode & 0o555`; complete `mode & 0o777` histograms are separately compared. Link targets must resolve within the measured tree; undecodable names, special metadata, and mutable input shapes refuse under the documented guards.

## Prepare and record on Linux/x64

Use a trusted private checkout and verified Git/Node tools. Exclude concurrent changes by the same user to the checkout, Node distribution, cache directory, or their parents. Before starting any Node process, clear `NODE_OPTIONS`, `NODE_COMPILE_CACHE`, `NODE_V8_COVERAGE`, `NODE_REDIRECT_WARNINGS`, `NODE_DEBUG`, and `NODE_DEBUG_NATIVE`, and set `NODE_DISABLE_COMPILE_CACHE=1`. Node can configure output before the first JavaScript statement and write it at exit; a JavaScript refusal cannot undo those effects. This caller protocol applies independently to the recorder, test runner, and historical verifier. Bare invocation under arbitrary startup settings is not a read-only claim. The script cannot defend against code injected before its first statement, a hostile runtime, filesystem snapshots that are not atomic, permissions available to privileged actors or the same UID, ACL models not represented by POSIX mode bits, or a hostile parent of the checkout. It creates no claim of physical fault injection or Windows PowerShell execution.

Obtain the official Node `24.18.1` Linux/x64 archive and verify its SHA-256 **before extraction**. This binary recipe supports GNU/Linux x64 with kernel 4.18 or newer, glibc 2.28 or newer, and libstdc++ `GLIBCXX_3.4.25` or newer. It does not claim support for musl-based systems or vendor releases outside Node's supported binary platforms. The recipe requires Bash, `curl`, GNU Coreutils `env`, `id`, `mkdir`, `mktemp`, `sha256sum`, and `stat`, plus GNU `tar` with `xz` support. The separate historical procedure also requires a trusted Git executable. The pinned archive digest is `d6c664df3f3f61458e8c277585571328522d705166723a7c7823a9253a4d15a0`. The authenticated bundled npm tree must contain 1,916 files and have digest `f58556342f8abc9245e168904a6579b9b09e7dc10606df7a52fcd454ccec8231`; the recorder checks both. The archive checksum establishes the selected distribution bytes; signed release verification is separate provenance work when required.

The following commands run from the repository root in Bash. Set `strExpectedRecorder` to the exact SHA-256 from the independently reviewed candidate or its permanent handoff. A value copied from the script's own output is not independent verification. `SUPPLY_FREEZE_TEMP_BASE` can select an existing external base; otherwise the recipe checks `TMPDIR`, then `/tmp`. The selected base and every physical ancestor must be owned by root or the recording UID, and every group- or other-writable component must have the sticky bit. An unsafe selected value refuses rather than falling back. Physical checkout or base paths containing carriage returns or line feeds refuse before any file creation because the checksum-file syntax used below cannot represent those names safely. Save the final JSON outside the checkout.

```bash
set -eu
unset NODE_OPTIONS NODE_COMPILE_CACHE NODE_V8_COVERAGE NODE_REDIRECT_WARNINGS NODE_DEBUG NODE_DEBUG_NATIVE
export NODE_DISABLE_COMPILE_CACHE=1
strExpectedRecorder='PASTE_THE_INDEPENDENTLY_REVIEWED_RECORDER_SHA256'
for strCommand in curl env id mkdir mktemp sha256sum stat tar xz; do
  command -v "$strCommand" >/dev/null 2>&1 || {
    printf 'Required command is unavailable: %s\n' "$strCommand" >&2
    exit 1
  }
done
strCanonicalSuffix=$'\n.'
strCheckoutTagged="$(pwd -P && printf '.')" || {
  printf 'Checkout path could not be resolved physically.\n' >&2
  exit 1
}
case "$strCheckoutTagged" in
  *"$strCanonicalSuffix") strCheckout="${strCheckoutTagged%"$strCanonicalSuffix"}" ;;
  *) printf 'Checkout path could not be captured losslessly.\n' >&2; exit 1 ;;
esac
case "$strCheckout" in
  *$'\n'*|*$'\r'*) printf 'Checkout path contains an unsupported line break.\n' >&2; exit 1 ;;
esac
strSelectedBase="${SUPPLY_FREEZE_TEMP_BASE:-${TMPDIR:-/tmp}}"
case "$strSelectedBase" in
  /*) ;;
  *) printf 'Temporary base must be an absolute existing directory.\n' >&2; exit 1 ;;
esac
strExternalBaseTagged="$(cd -P -- "$strSelectedBase" 2>/dev/null && pwd -P && printf '.')" || {
  printf 'Temporary base must be an accessible existing directory.\n' >&2
  exit 1
}
case "$strExternalBaseTagged" in
  *"$strCanonicalSuffix") strExternalBase="${strExternalBaseTagged%"$strCanonicalSuffix"}" ;;
  *) printf 'Temporary base could not be captured losslessly.\n' >&2; exit 1 ;;
esac
case "$strExternalBase" in
  *$'\n'*|*$'\r'*) printf 'Temporary base contains an unsupported line break.\n' >&2; exit 1 ;;
esac
strCheckoutPrefix="${strCheckout%/}/"
case "$strExternalBase/" in
  "$strCheckoutPrefix"*) printf 'Temporary base must be outside the checkout.\n' >&2; exit 1 ;;
esac
strUid="$(id -u)"
strAt="$strExternalBase"
while :; do
  strStat="$(stat -Lc '%u %a' -- "$strAt")" || {
    printf 'Temporary base ancestry could not be inspected.\n' >&2
    exit 1
  }
  read -r strOwner strMode <<< "$strStat"
  intMode=$((8#$strMode))
  if { [ "$strOwner" != 0 ] && [ "$strOwner" != "$strUid" ]; } \
    || { (( (intMode & 0022) != 0 )) && (( (intMode & 01000) == 0 )); }; then
    printf 'Temporary base has an unsafe physical ancestor.\n' >&2
    exit 1
  fi
  [ "$strAt" = / ] && break
  strAt="${strAt%/*}"
  [ -n "$strAt" ] || strAt=/
done
umask 0022
strTools="$(mktemp -d "$strExternalBase/supply-freeze-tools.XXXXXXXXXX")"
curl -fsSLo "$strTools/node.tar.xz" \
  https://nodejs.org/dist/v24.18.1/node-v24.18.1-linux-x64.tar.xz
printf '%s  %s\n' \
  d6c664df3f3f61458e8c277585571328522d705166723a7c7823a9253a4d15a0 \
  "$strTools/node.tar.xz" | sha256sum -c -
mkdir "$strTools/node"
tar -xJf "$strTools/node.tar.xz" -C "$strTools/node" --strip-components=1
strNode="$strTools/node/bin/node"
strNpm="$strTools/node/bin/npm"
printf '%s  %s\n' "$strExpectedRecorder" \
  .github/workflows/Get-SupplyFreezeDigest.mjs | sha256sum -c -
# Preparation only: installs locked dependencies, with lifecycle scripts disabled.
# Run from a clean environment; user/global workspace or install settings can refuse.
env -u NPM_CONFIG_WORKSPACE -u npm_config_workspace \
  "$strNode" "$strNpm" --prefix .github/workflows ci \
  --ignore-scripts --no-audit --no-fund --workspaces=false
# The caller creates a fresh mode-0700 directory; do not reuse a populated one.
strCache="$(mktemp -d "$strExternalBase/supply-freeze-cache.XXXXXXXXXX")"
strOutput="$(mktemp "$strExternalBase/supply-freeze-observation.XXXXXXXXXX")"
env -u NODE_OPTIONS -u NODE_COMPILE_CACHE -u NODE_V8_COVERAGE \
  -u NODE_REDIRECT_WARNINGS -u NODE_DEBUG -u NODE_DEBUG_NATIVE \
  NODE_DISABLE_COMPILE_CACHE=1 "$strNode" .github/workflows/Get-SupplyFreezeDigest.mjs \
  --json "--cache-directory=$strCache" > "$strOutput"
"$strNode" --input-type=module - "$strOutput" <<'NODE'
import { readFileSync } from 'node:fs';
const result = JSON.parse(readFileSync(process.argv[2]));
if (result.currentObservation.complete !== true) process.exit(1);
console.log('Complete current observation; historical verification remains separate.');
NODE
printf 'Observation saved outside the repository: %s\n' "$strOutput"
```

The recorder's external cache directory must be absolute, canonical, empty, owned by the recording UID, and mode `0700`. Symlink cache aliases and repository/toolchain overlap refuse. Both the measured checkout and the physical recorder source repository are excluded, including diagnostic invocation through a script alias. Ancestors must be owned by root or the recording UID; writable ancestors require the sticky bit. The caller must prevent same-UID interference during the run. The complete initial installed-tree fold and its root, special-entry, and link checks run before the first npm subprocess; both installed-tree folds refuse special entries unconditionally. npm cache and logs are forced beneath that directory before every npm subprocess, including version and configuration probes; timing and update notification are disabled. Ambient repository-local cache/log paths cannot override these flags. Each npm child also removes all six Node startup variables listed above and forces `NODE_DISABLE_COMPILE_CACHE=1`; warnings remain visible as fixed categories and decoded-character lengths, while arbitrary child stderr text is withheld from public recorder diagnostics. Strict `npm ls` problem diagnostics expose only safe native status plus fixed `missing`, `invalid`, `extraneous`, and `other` counts; package identifiers, versions, paths, unknown kinds, and other problem payload text are withheld. Observable active compile-cache, coverage, warning-redirection, or Node debug settings refuse with exit 2 before npm, but this check cannot undo runtime effects before module entry. Strict mode also refuses when `NODE_OPTIONS` is present, including an empty value; `--any-toolchain` bypasses that observable hygiene check and marks the output as not a freeze record. The caller protocol above remains mandatory in every mode because pre-entry code can erase the variable before this check. Empty values of the five output/debug variables are inactive; compile caching is inactive when its disable flag is `1`. No existing directory permissions are changed. npm's private log files can still contain sensitive data; retain and inspect that caller-owned external directory accordingly.

## Verify historical Git provenance separately

Object acquisition is explicit preparation and writes the Git object database. From the expected PS clone, if the historical commit is absent, fetch its exact commit from the canonical repository before starting the read-only interval:

```bash
git fetch --no-tags https://github.com/franklesniak/PSStyleGuide.git \
  4346310e7deebffb4159c75e30d9546263dfd649
```

The following independent procedure uses the verified `strNode` from above and a trusted Git executable on PATH. Every Git child receives a closed environment containing only that trusted PATH, the `C` locale, the fixed no-lazy-fetch/no-replacement/no-optional-lock settings, disabled system/global configuration, and disabled Trace2 targets. This prevents inherited object-routing or trace destinations from writing outside the measured repository during verification. Missing objects, a failed native command, an unexpected commit/path blob, or any length/hash mismatch terminate without a successful verification message. Only after both baseline objects pass does it print one fixed all-input verification marker. It hashes raw stdout buffers, never a shell text pipeline or checkout conversion. It does not install, fetch, or update an index.

The pinned [Node 24.18.1 environment-variable reference](https://nodejs.org/download/release/v24.18.1/docs/api/cli.html#environment-variables) and [module compile-cache reference](https://nodejs.org/download/release/v24.18.1/docs/api/module.html#module-compile-cache) describe these startup output controls. The [Git environment-variable reference](https://git-scm.com/docs/git#_environment_variables) and [Trace2 target reference](https://git-scm.com/docs/api-trace2) define the Git controls. The [npm configuration reference](https://docs.npmjs.com/cli/v11/using-npm/config/) defines the separate cache, logs-dir, and timing settings. The pinned [npm 11.16.0 audit exit-code implementation](https://github.com/npm/cli/blob/v11.16.0/node_modules/npm-audit-report/lib/exit-code.js) returns 0 or 1; valid-looking stdout does not authorize another native outcome.

```bash
env -u NODE_OPTIONS -u NODE_COMPILE_CACHE -u NODE_V8_COVERAGE \
  -u NODE_REDIRECT_WARNINGS -u NODE_DEBUG -u NODE_DEBUG_NATIVE \
  NODE_DISABLE_COMPILE_CACHE=1 \
  GIT_NO_LAZY_FETCH=1 GIT_OPTIONAL_LOCKS=0 \
  GIT_NO_REPLACE_OBJECTS=1 "$strNode" --input-type=module <<'NODE'
import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
const freeze = JSON.parse(readFileSync('.github/workflows/workflow-policy-contract.json')).supplyFreeze;
assert.equal(freeze.reviewedCommit, '4346310e7deebffb4159c75e30d9546263dfd649');
assert.equal(typeof process.env.PATH, 'string');
const gitEnvironment = {
  PATH: process.env.PATH,
  LC_ALL: 'C',
  GIT_NO_LAZY_FETCH: '1',
  GIT_NO_REPLACE_OBJECTS: '1',
  GIT_OPTIONAL_LOCKS: '0',
  GIT_CONFIG_NOSYSTEM: '1',
  GIT_CONFIG_SYSTEM: '/dev/null',
  GIT_CONFIG_GLOBAL: '/dev/null',
  GIT_TRACE2: '0',
  GIT_TRACE2_EVENT: '0',
  GIT_TRACE2_PERF: '0',
};
const git = (...args) => execFileSync('git', ['--no-replace-objects', ...args],
  { encoding: 'buffer', maxBuffer: 1024 * 1024, stdio: ['ignore', 'pipe', 'pipe'],
    env: gitEnvironment });
assert.equal(git('cat-file', '-t', freeze.reviewedCommit).toString().trim(), 'commit');
for (const [key, path, blob] of [
  ['packageJson', '.github/workflows/package.json', '923106fc4ee5508b7a03930b3d8b774db9fcd009'],
  ['packageLockJson', '.github/workflows/package-lock.json', '7e96fd1fd41765ba31488762f60c2f74ba17d3a8'],
]) {
  const expected = freeze.baseline[key];
  assert.equal(expected.blob, blob);
  assert.equal(git('rev-parse', `${freeze.reviewedCommit}:${path}`).toString().trim(), blob);
  const bytes = git('cat-file', 'blob', blob);
  assert.equal(bytes.length, expected.length);
  assert.equal(createHash('sha256').update(bytes).digest('hex'), expected.sha256);
}
console.log('Historical packageJson and packageLockJson blob, path, length, and SHA-256 verification completed.');
NODE
```

This verifies baseline consistency and commit/path membership. It does not verify producer signatures, historical installed-tree recipes, original audit bytes, or policy authorization. [Decision 0002](decisions/0002-accept-unverifiable-baseline-provenance.md) retains the offline validator's Git-free scope; this manual procedure changes the former blanket statement that no verification is available.

## Invocation and refusal contract

Arguments are `--json`, `--no-audit`, `--any-toolchain`, and one required `--cache-directory=<path>`. There are no positional arguments or `--help` option. Unknown arguments refuse without publishing any token bytes; the diagnostic gives each unsupported token's original argv position and Unicode code-point length plus the fixed supported list. `--json` is required for complete field consumption; the default text format is a summary of the current observation and explicitly states that historical assertions need separate verification.

| Exit | Meaning |
| --- | --- |
| 0 | A complete or explicitly incomplete observation was emitted. Check `currentObservation.complete`; status alone is insufficient. |
| 2 | Unsupported invocation, observable active startup-output/debug environment, host, toolchain, npm identity (including the unconditional npm-tree digest/census), special npm-installation entry, or subprocess launch failure. |
| 3 | Script, manifest, or contract changed during measurement. |
| 4 | Missing, unreadable, or invalid-UTF-8 current manifest; also an unreviewed current manifest in strict mode. |
| 5 | Malformed/inconsistent or invalid-UTF-8 audit response, or audit native status outside 0/1, signal, or launch failure reaching the audit adapter. |
| 6 | Unreviewed npm install/transport configuration, including an invalid-UTF-8 configuration response. |
| 7 | Missing, invalid, redirected, or incomplete installed tree, including an invalid-UTF-8 npm-ls response. |
| 8 | Unreviewed process umask. |
| 9 | Unreviewed advisory registry. |
| 10 | During-run tree, npm, or watched-path consistency failure. npm-distribution consistency failures can use 2. |
| 11 | Special entry, escaping link, or unresolved link in the installed tree. Special-entry and link-containment refusals are never bypassed by `--any-toolchain`. |
| 12 | Undecodable filename. |
| 13 | Nonregular project npm configuration. |
| 14 | Unsafe installed-entry ownership, hard links, non-owner write bits, or special mode bits. |
| 15 | Nonregular or multiply writable manifest/configuration input, including non-owner write bits. |
| 16 | Missing, repeated, unsafe, nonprivate, populated, or overlapping external cache directory. Never bypassed. |
| 17 | Initial P1 contract missing, unreadable, nonregular, multiply writable, non-owner writable, invalid UTF-8, malformed, or different from the reviewed assertion tuple. Never bypassed. |

The immutable upstream method gives the original per-guard diagnostic-bypass distinctions for exits 2–15. This method's explicit tighter overrides apply: installed-tree special entries and escaping/unresolved links, npm-installation identity/link/special checks, cache safety, contract validation, exact UTF-8 decoding of semantic npm stdout, input UTF-8 validation, and non-owner write-mode checks are unconditional. The strict comparison against the reviewed current-manifest constants remains bypassable for a diagnostic record. Every refusal emits no JSON record. A sequential userspace walk is not an atomic filesystem snapshot; the two content folds and inode/change-time sweep have the upstream timestamp-granularity and concurrent-write limitations. The new contract snapshot has the same sequential-read limitation.

## Validation and scope

Run the tests under the pinned Node distribution with the same startup protocol:

```bash
env -u NODE_OPTIONS -u NODE_COMPILE_CACHE -u NODE_V8_COVERAGE \
  -u NODE_REDIRECT_WARNINGS -u NODE_DEBUG -u NODE_DEBUG_NATIVE \
  NODE_DISABLE_COMPILE_CACHE=1 \
  "$strNode" --test .github/workflows/Get-SupplyFreezeDigest.test.mjs
```

Linux tests execute the complete recorder against real installed bytes and a live audit; Windows tests execute the unsupported-host refusal. Production audit-adapter fixtures exercise accepted 0/1 outcomes and refusal of status 2, signal termination, spawn error, and non-JSON failure. ARGUMENT-PRIVACY executes the complete recorder and verifies original argv positions and lengths without token disclosure, including a cache argument before the unsupported tokens. FILESYSTEM-DIAGNOSTIC-PRIVACY exercises the production errno formatter, a nonregular project `.npmrc`, and a missing adjacent npm launcher in a secret-bearing disposable path; diagnostics retain only fixed roles and safe categories. DESCRIPTOR-FAILURE executes the production reader with bounded injected open/fstat/read/close outcomes for manifest exit 4, during-run exit 3, and initial-contract exit 17; it also verifies a single close attempt, first-failure preservation, and unchanged intentional symlink/type/ownership/mode refusals. JSON-RESPONSE-PRIVACY executes the production shared parsers and audit shape/normalization adapters, verifying fixed categories and response lengths without parser excerpts, duplicate keys, endpoint fields, or contract content. UTF8-INPUT and whole-process manifest/contract cases verify valid Unicode and unconditional invalid-byte refusal. NPM-STDOUT-UTF8 drives the production npm adapter with valid, empty, invalid, missing, and launch-failure byte-stream outcomes; semantic stdout uses the supplied phase exit while partial stderr on failure retains its fixed category and character count. AUDIT-PUBLIC-SUMMARY executes production normalization, canonicalization, fixed summary construction, and the text row renderer; raw package/`via` changes move the published normalized digest but never enter JSON or text display, absent/null advisory URLs remain compatible, and present non-string URLs reach the fixed normalization refusal. TREE-CHECK-PRIVACY drives production npm-ls validation categories with private path/name sentinels. LS-PROBLEM-PRIVACY verifies fixed categories with fake problem-version and path payloads; a whole-process case removes a transitive dependency in a disposable fake-path checkout and verifies exit 7, fixed counts, and no raw npm problem text. NODE-CHILD-ENV and whole-process fake debug settings verify child scrubbing and fixed startup refusal without retaining raw debug output. NPM-VERSION-PRIVACY verifies the production projection. A disposable copied npm installation with modified bytes now proves that `--any-toolchain` refuses before its controlled child marker; its observed private fold is admitted only in a separate test fixture to preserve the earlier first-child FIFO-order property. URL-PRIVACY verifies the production redactor, exact reviewed-registry exception, top-level initialization order, a strict whole-process registry refusal, and fixed custom-scheme handling. NPM-LINK-CONTAINMENT executes the production npm fold over a contained chain, a direct escape, an outside hop that returns inside, and a dangling target; its process-exit stub observes refusal 2 for the negative cases, while direct resolver cases also cover hop exhaustion, invalid UTF-8, and non-owner write modes. The same production-fold fixture verifies that a FIFO receives the fixed special-entry refusal without exposing its name; this is branch coverage, not a claim that a special-file payload was executed. A package-manifest FIFO in the complete Linux fixture proves strict and bypassed exit 11 before npm can open it, and the shared refusal is applied after both folds. Removing either npm enforcement branch or an installed-tree special refusal makes its focused expectation fail. HISTORICAL-VERIFICATION executes the authored JavaScript block with explicit Node startup controls and a closed per-Git-child environment; inherited trace destinations, config-defined Trace2 targets, and object redirections have no effect, normal completion emits one marker, while a late second-blob length or hash mismatch and an injected later native Git failure emit none. The whole-process Linux fixture also proves that `--any-toolchain` cannot bypass installed-tree containment and that non-owner write bits refuse across manifests, the contract, project configuration, installed files/directories/root, and the npm fold. Production-function fixtures prove bounded control flow; the Linux process cases prove no-record refusals. The Linux success case starts with polluted parent startup settings, applies the documented launch protocol, and checks a complete live observation, absent runtime output targets, and unchanged checkout bytes. Injected descriptor failures are not a claim of physical filesystem fault injection. A platform-specific skipped case is not a passing runtime cell.

For the read-only proof, capture before and after hashes and sizes of the manifest, lockfile, complete contract, and all four generated outputs; a deterministic digest and census of **every** installed-tree entry including ignored files; raw Git porcelain; and the raw staged-path set. Run `git status` with `GIT_OPTIONAL_LOCKS=0`. Keep the transcript, output, and snapshots outside the repository. All pairs must match. Record the recorder's exact Git blob and SHA-256, Node/npm identity, source commit, and observation digest in the permanent candidate handoff.

The reduced reciprocal matrix below applies to this narrow capability. The unchanged cycle-3 foundation and its complete role map remain established by the [permanent closure](https://github.com/franklesniak/PSStyleGuide/issues/159#issuecomment-5751908399) and [full reciprocal evidence](https://github.com/franklesniak/TerraformStyleGuide/issues/31#issuecomment-5751829095). This recorder does not reopen those workflow or generator implementations. Source is Terraform commit `aae05282b57f093cec8b63e59138db72c982f10e`; destination is the PS candidate based on `986a78cfad02abe9698ee258735d8451abeb9249`. The final candidate record binds the exact new blobs and test-result hashes.

| Row | Status | Normative/implementation locator, observed behavior, and applicability proof |
| --- | --- | --- |
| GF-PARAMETERS | Intentional difference | This method's invocation contract; recorder argument/cache validation. Retains upstream diagnostic flags; adds one external housekeeping directory. Cache refusal cases apply even with bypass. |
| GF-DESTINATION | Intentional difference | Recorder `strWorkflowDirectory` and `validateCacheDirectory`; source roots remain fixed, output is stdout, external npm effects are explicitly bounded. No caller-controlled repository destination. |
| GF-CONTENT | Intentional difference | Field-provenance table and `objOutput`; unchanged P1 assertions coexist with distinct Linux observations. Contract drift refuses and skipped audits retain an explicit null/empty envelope. Child stderr, unsupported argv, filesystem locations/names, malformed JSON, and npm-tree failures expose only fixed roles/categories/counts/lengths. Raw npm version labels remain only in the equality check, and unreviewed URL authorities/details are withheld from public fields and diagnostics. Raw audit package and `via` strings remain inputs to the published normalized digest, while public `auditPackages` is a fixed numeric summary; schema is not migrated to T1. |
| GF-SERIALIZATION | Same applicable behavior | Upstream `canonicalize`, `hashField`, and JSON renderer; BOM-less UTF-8 with final LF, byte-based manifest/tree folds, same installed/advisory recipes. Historical P1 digests are not equated. |
| GF-WRITE | Inapplicable | No generated-file writer, candidate publication, flush, replacement, or move is added. Child housekeeping is covered by GF-NODE-LOCK, not a generator transaction. |
| GF-FAILURE | Intentional difference | Upstream refusals plus cache 16 and assertion 17; open/fstat/read/close failures retain caller-specific exits, audit native failures are tightened, observable unsafe startup/debug settings refuse 2, input JSON and semantic npm stdout reject invalid UTF-8 at their owning phase, present non-null non-string advisory URLs reach the fixed audit-normalization refusal, and project-tree special entries, escaping/unresolved links, or npm-installation special entries remain refusals under `--any-toolchain` (installed tree exit 11, npm installation exit 2). Focused adapters prove controlled refusal outcomes; Linux whole-process cases prove no-record refusals. No rollback or atomic snapshot claim. |
| GF-HOSTS | Intentional difference | Both recorders require Linux/x64 Node24.18.1/npm11.16.0 and POSIX metadata. HOST proves native Windows refusal. The port makes caller startup isolation explicit and isolates npm children; NODE-CHILD-ENV and polluted-launch fixtures cover this addition. Generator PowerShell cells are unchanged and inapplicable to this JavaScript capability. |
| GF-VERSION | Inapplicable | No PowerShell authoring/version marker changes. Exact recorder blob and SHA-256 identify this JavaScript tool. |
| GF-NODE-LOCK | Intentional difference | Existing P1 manifests, historical Windows producer, and unchanged lock. Current Linux/npm authentication is required in every mode; external cache/log routing, caller/child runtime-output and debug isolation, a complete project-tree fold before npm, unconditional project-tree special/link refusal, npm-installation identity/link/special refusal, and non-owner write-mode refusal are strengthened. The setup establishes umask `0022` after nonmutating base checks and before its first artifact. Strict live success, bounded setup cases, and full read-only snapshots prove current effects. |
| GF-YAML | Inapplicable | Recorder uses built-in JSON parsing and upstream duplicate-key checks; it does not parse workflows or change yaml, its contract, or its installed payload. |
| GF-ACTION-PINS | Inapplicable | No action, workflow, or reviewed action manifest changes. |
| GF-ACTION-INPUTS | Inapplicable | No authored action input or action-default changes. |
| GF-GIT | Intentional difference | Separate raw-byte historical verification above; no internal Git. Missing/mismatched objects refuse. No push, refspec, lease, ancestry mutation, or raw path-set verifier change. |
| GF-GRAPH | Inapplicable | Manual capability only; no workflow trigger, permissions, needs, output graph, or writer integration. |
| GF-CREDENTIALS | Same applicable restriction | No GitHub token or push credential is requested. Upstream public-registry/transport checks remain; unsupported argv, filesystem paths/names, malformed JSON, npm-tree diagnostics, public npm-version labels, unreviewed URL authorities/details, and successful audit display publish no raw response/path/package strings, while private npm logs remain sensitive. Cache authority grants no repository write authority. |
| GF-EVIDENCE | Intentional difference | Focused production-function and whole-recorder tests cover argument and filesystem-diagnostic privacy, descriptor failure mapping, JSON and semantic-stdout UTF-8 response privacy, advisory URL typing, fixed audit summaries, unconditional npm identity, pre-child special refusal, link containment, non-owner write modes, Node debug isolation, npm version/URL projection, npm-tree diagnostic privacy, closed Git-child environments, and setup order; retained mutation probes, the historical verification procedure, and full before/after snapshots bind the claims. No temporary workflow or review/merge is part of this implementation task. |

Issue 158 remains nonblocking for issues 147 and 152. There is no new dependency edge, advisory extension, protected instruction change, or workflow integration. Task 134 must explicitly assess the D1-D5 port differences and the later review repairs, including contract/descriptor refusal classification, structured npm diagnostics, skipped-audit field presence, setup prerequisites and external-base/early-umask handling, npm-installation and unconditional installed-tree symlink containment, complete unsupported-token and filesystem-location withholding, JSON-response and semantic-stdout UTF-8 refusal, fixed audit display summaries, advisory URL type validation, unconditional npm executable identity, non-owner write-mode refusals, Node debug isolation, npm-tree diagnostic privacy, and the focused-test extraction boundary. These are explicit source differences, not a claim of whole-recorder convergence or a permanent PS-only exception. This narrow matrix does not assert a new whole-repository fixed point.
