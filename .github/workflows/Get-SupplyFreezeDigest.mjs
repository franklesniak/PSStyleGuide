// PS port of TerraformStyleGuide PR #27, commit aae05282b57f093cec8b63e59138db72c982f10e.
// Original recorder blob: 05778c0eda0273a9217f7dc953795c2240473a14.
// Upstream comments below describe the original T1 implementation and its reviews.
// P1 adaptation: unchanged historical supplyFreeze assertions, separate current
// Linux observations, and caller-provided external npm housekeeping directory.
// Historical Git verification is a separate procedure in docs/P1-SUPPLY-FREEZE-v1.md.
// No workflow invokes this recorder. No historical P1 digest is re-baselined here.
// Derives the T1-SUPPLY-FREEZE-v1 digests reproducibly.
//
// Why this file exists. The original freeze record carried two fields recorded
// as "normalized SHA-256" -- one over `npm ls --all --json`, one over
// `npm audit --json`. The procedure that produced those two numbers was never
// committed; only its outputs were, in a pull request description. A digest
// whose derivation is unrecorded proves nothing, because a reader who computes
// a different value cannot tell whether the inputs changed or whether they
// normalized differently. Issue #22 requires "exact equality of every recorded
// field" against that record, which for those two fields no one could discharge.
//
// So the derivation lives here, in the repository, and the record quotes what
// this file produces. The two superseded values are NOT reproduced by this
// script and cannot be: their recipe is unknown. See docs/T1-SUPPLY-FREEZE-v1.md.
//
// With the documented Node startup environment, this script is read-only: it runs
// no install and writes nothing into the repository
// or the installed tree it measures, and it asserts the manifest and lockfile are
// byte-identical after it finishes. (The `npm ls`/`npm audit` children it runs may write
// to npm's own cache -- an update-notifier timestamp, or a debug log on failure -- which
// is outside that measured surface.)

import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { closeSync, constants as fsConstants, existsSync, fstatSync, lstatSync, openSync,
  readdirSync, readFileSync, readlinkSync, realpathSync, statSync } from 'node:fs';
import { basename, delimiter, dirname, isAbsolute, join } from 'node:path';
import { fileURLToPath } from 'node:url';

// Round 52, reported by Codex. These three lived beside formatUntrustedText,
// two thousand lines below the unrecognized-argument refusal that CALLS it.
// Function declarations hoist; `const` bindings do not -- they sit in the
// temporal dead zone until their line executes. So the one refusal most likely
// to carry a mistyped credential threw instead of redacting it. Measured:
//
//   node Get-SupplyFreezeDigest.mjs --bogus
//     -> ReferenceError: Cannot access 'RE_URL_IN_TEXT' before initialization
//        exit 1, where the record documents exit 2
//
// A regression from round 51, which hoisted the expressions out of the function
// for reuse without checking that every caller runs after them. Declared here,
// above every use, because the top of the module is the only position where
// that cannot silently become false again as call sites move.
//
// The scheme tolerates the three characters the WHATWG URL parser deletes from
// its input -- U+0009, U+000A, U+000D -- and the authority separator is any run
// of forward or back slashes, or none, which is what that parser accepts. Both
// rules are the specification's, not a guess; the reasoning is at
// formatUntrustedText, which is where they are used.
const RE_PARSER_DELETES = /[\t\n\r]/gu;
// Round 57, reported by Codex, and the SEVENTH round on this one expression.
// Rounds 47 through 52 each widened it within http and https -- tolerating the
// characters the parser deletes, then the slash runs it ignores -- and every one
// of those fixes was still answering "how is an http url spelled". It only ever
// matched two schemes, while formatUntrustedText is the general funnel for
// caller- and subprocess-controlled text. Measured, all five printed verbatim
// with both credentials intact:
//
//   ftp://user:SECRET@host/p?token=S2      file:///etc/x?token=SECRET
//   ftps://user:SECRET@host/               ws://user:SECRET@host/
//   git+ssh://user:SECRET@host/r.git
//
// redactUrl() handles every one of them correctly -- new URL() parses all five
// and the credentials come out -- so the prefilter was the only thing standing
// between them and a retained log. Six rounds of widening a scheme allowlist
// that was never the right shape.
//
// So the scheme is no longer enumerated. RFC 3986 defines it as
// ALPHA *( ALPHA / DIGIT / "+" / "-" / "." ), and that is what this matches,
// with the three parser-deleted characters tolerated anywhere inside it for the
// reason round 51 established. Everything from the scheme onward goes to
// redactUrl, which has failed CLOSED since round 38 -- an unparseable tail is
// withheld rather than trusted.
//
// The cost, stated rather than discovered later: this over-matches. A path or
// argument containing a colon after a letter -- `/tmp/a:b/npm` -- is treated as
// a scheme and its tail is withheld. That is deliberate. A refusal message that
// renders an unusual path awkwardly is a nuisance; one that prints a credential
// is the defect this funnel exists to prevent, and the asymmetry decides it.
// The compared registry row is unaffected: https://registry.npmjs.org/ parses,
// its pathname is exactly '/', and redactUrl returns it character-identical.
const RE_URL_IN_TEXT = /[A-Za-z][A-Za-z0-9+.\-\t\n\r]*:[\s\S]*/u;
const RE_LINE_BREAK = /\r\n|[\n\r\u2028\u2029]/gu;

// Round 56, reported by Codex, and the round-55 fix caught in its own turn.
// That round moved this block above SUPPORTED_ARGUMENTS and then wrote that it
// "genuinely precedes every other statement". It did not: process.umask(), the
// three --flag membership scans and strWorkflowDirectory still ran ahead of it,
// so the claim was false in the same commit that made it. Fixing the position a
// reviewer pointed at and restating the invariant as though the class were
// closed is the habit this file keeps rediscovering.
//
// It is now the first executable statement in the module, ahead of every
// constant that is not a compile-time regular expression. That is checkable
// rather than asserted: nothing above this line executes except the four
// literal RE_ constructions, and the block depends only on hoisted function
// declarations and imports.
//
// The window between Node COMPILING this file and this read cannot be closed
// from inside the script -- the record says so, and no reordering changes it.
// What reordering buys is that the window is no longer widened by anything the
// caller supplies, which a long argument list previously did.
//
// The rationale below travelled with the code this time. Round 55 moved the
// statements and left rounds 12 and 13 explaining them from forty lines away,
// under a stub pointer -- the same split this loop has reported against the
// record four times.

// Round 12, reported. The self-read used to sit AFTER the toolchain guard, and
// therefore after an `npm --version` subprocess -- tens of milliseconds during
// which this file could be replaced. The process would go on executing the
// source Node had already loaded while reporting the SHA-256 of a different
// file, so restoring the reviewed bytes over a modified version inside that
// window produced the authoritative script digest for a run that derived every
// other field with other code. Neither the final content checks nor the
// quiescence sweep looked at the script.
//
// Three changes, because no one of them is sufficient. The read is now the
// first thing this script does, so the window between Node's load and the read
// contains no code of ours. The bytes are kept and re-compared at the end. And
// the script's own inode-change time is checked against PROCESS START rather
// than against the later recording ceiling, so a replacement anywhere in the
// process lifetime is caught.
//
// The residual, stated rather than implied: Node reads and compiles this file
// before any statement here executes, so a replacement in THAT window is
// invisible to the script itself and can only be closed by a trusted launcher
// hashing the file before invoking node. That is outside what one read-only
// script can bootstrap, and the record says so.
//
// Round 13, reported. `import.meta.url` is NOT always the file Node compiled.
// Under `--preserve-symlinks-main` -- which an ambient NODE_OPTIONS can supply --
// it is the symlink that was invoked, and measured, lstat on it reports
// isSymbolicLink() true while the source Node actually loaded is the target.
// Every check here would then have described the link's inode: its content
// comparison reads through the link and its ctime never moves, so a target
// modified at compile time and restored before the self-read would emit the
// reviewed digest for code that was never reviewed.
//
// Resolving first makes every subsequent check -- the digest, the content
// re-comparison and the ctime ceiling -- describe the bytes that were compiled.
// That alone closes the attack, because restoring a modified target during the
// run moves the TARGET's ctime past process start.
// Round 55, reported by Codex, and it is the round-12 comment being wrong about
// its own position. That comment says "the read is now the first thing this
// script does, so the window between Node's load and the read contains no code
// of ours" -- but argument membership and the unsupported-argument filter ran
// first, roughly 150 lines of code and one refusal ahead of it. A long argument
// list widens that window, and the ctime baseline was captured after it too, so
// a replacement landing inside it could be read as the reviewed bytes while the
// process kept executing the source Node had already compiled.
//
// The window between Node's compile and this read cannot be closed from inside
// the script -- the record says so -- but it can be kept as small as the
// language allows, which is what the comment claimed and did not deliver. The
// snapshot and its ctime baseline now genuinely precede every other statement.
const strInvokedPath = fileURLToPath(import.meta.url);
const strScriptPath = realpathSync(strInvokedPath);
const boolEntryPointIsLink = strInvokedPath !== strScriptPath;
const objScriptBefore = readFileSync(strScriptPath);
const strScriptSha256 = sha256(objScriptBefore);
// Round 18, reported. Math.round can round the uptime DOWN, which places the
// computed start LATER than the real one -- and anything changed inside that
// sliver carries a ctime below the ceiling and escapes the check. Math.ceil can
// only place the computed start earlier, which is the direction that fails safe:
// it can raise a false alarm, never miss a replacement.
const intProcessStartedAt = Date.now() - Math.ceil(process.uptime() * 1000);
// Round 29, swept rather than reported. The quiescence sweep's cross-clock
// comparison was the reported finding; this is the same defect one comparison
// over, on the script's own identity, and no reviewer named it.
//
// The round-18 note above chose Math.ceil to bias the ceiling earlier because
// that direction fails safe. It does -- but it buys at most 1 ms, and the
// backdating measured this round is up to 4.13 ms, so the margin is smaller than
// the error it was protecting against. A replacement landing within roughly 3 ms
// of process start carried a ctime below the ceiling and passed.
//
// Same remedy as the sweep: read the stamp from the filesystem now and compare
// it against the filesystem later, so no clock enters the comparison at all.
const intScriptChangedAtStart = (() => {
  try {
    return lstatSync(strScriptPath).ctimeMs;
  } catch (objError) {
    process.stderr.write(
      'supply-freeze: this script became unreadable during the run; refusing to report.\n' +
      formatErrorLocation(objError, strScriptPath));
    process.exit(3);
  }
})();

const REVIEWED_NODE = 'v24.18.1';
const REVIEWED_NPM = '11.16.0';

// The npm INSTALLATION, as opposed to the version string npm prints about
// itself. Round 56: the version string is written by the program being
// identified, so it cannot identify it. See the guard above the first runNpm
// call for the measured forgery this exists to refuse.
//
// Derived from lib/node_modules/npm inside node-v24.18.1-linux-x64.tar.xz,
// fetched from nodejs.org and checked against the archive digest the two
// workflows already pin (D6C664DF...) before it was opened -- so this constant
// describes the bytes CI extracts rather than the machine it was computed on.
// The container's own /opt/node24 folds to the same value, which is a
// corroboration and not the source. Re-derived from that same archive in round
// 58 when the fold framing changed -- a new encoding must be measured against
// the pinned artifact again, not carried over on the argument that the trees
// matched under the OLD encoding, which is the very ambiguity round 58 reported.
const REVIEWED_NPM_TREE_SHA256 = 'f58556342f8abc9245e168904a6579b9b09e7dc10606df7a52fcd454ccec8231';
const REVIEWED_NPM_TREE_FILES = 1916;

// Reported and confirmed: the toolchain guard originally checked Node and npm
// and not the platform, so a reader on Windows passed the guard and then could
// not match the recorded tree digest however correct their lockfile was. npm's
// bin-links writes `.cmd` and `.ps1` shims on Windows where POSIX gets symlinks,
// so the two trees genuinely differ on disk. The digest is reproducible from the
// lockfile AND this platform, never from the lockfile alone, and saying only the
// latter was an overclaim in the record rather than a defect in the fold.
const REVIEWED_PLATFORM = 'linux';
const REVIEWED_ARCH = 'x64';

// The manifest and lockfile digests the workflow policy already pins. Repeated
// here so this script fails loudly rather than reporting digests for a tree
// that is not the reviewed one.
const REVIEWED_PACKAGE_SHA256 = '59e676d981cffa350cb72e7ea4b1aeec2c49d56621958a095aa0e76733ec2cd9';
const REVIEWED_LOCK_SHA256 = '5efc1286025cdc3ad03796c5f4e44cc697e674a30e61de05e299b2a30abad1a2';

// The same two files as Git blob identities, which is what the record's blob
// column holds. Round 2, reported by Copilot: the documented way to check those
// was `git log -1 --format=%H -- <path>`, which prints a COMMIT hash. Measured,
// it printed a COMMIT hash where the record holds a BLOB id, so a reader
// following the instructions compared two different kinds of hash and would
// have concluded the record was wrong.
//
// Computing them here goes past the reported fix. A documented git incantation
// is a manual step a reader can mistype or skip; deriving the blob identity in
// the script makes it a checked field like every other value in the record.
const REVIEWED_PACKAGE_BLOB = '84bd0421fcf17984220a408e42c5e0523ef65be6';
const REVIEWED_LOCK_BLOB = 'c3f949822315ec5ff4cc1028922c31d0186cf9cf';

// Install-shaping npm configuration, with the values the recorded tree was
// produced under. Round 2, reported: a reader with `bin-links=false` or
// `omit=dev` in a user or global .npmrc gets a different tree from the same
// lockfile, and the toolchain guard accepted them because Node, npm and the
// platform were all correct. Measured -- under `bin-links=false` npm ci exited
// 0 and produced 0 symlinks instead of the recorded 8, and the script reported
// a mismatched digest without a word of complaint.
//
// `npm config list --json` reports the EFFECTIVE configuration, including
// environment and .npmrc overrides, so these are checked rather than assumed.
//
// Round 3, reported: `package-lock-only` has to be listed explicitly. npm
// defines it as "only use the package-lock.json, ignoring node_modules", and it
// force-sets package-lock=true, so the entry below it cannot catch it
// indirectly. Measured -- `npm ci` under package-lock-only=true exits 0 saying
// "up to date" while reducing node_modules to a single .package-lock.json file.
//
// Round 9, reported and confirmed, and the most serious of that round. npm has
// its OWN `umask` config, separate from the process umask the guard below
// checks, and it was absent from this list. npm documents it as additive rather
// than a replacement -- "npm does not circumvent this, but rather adds the
// `--umask` config to it" -- with a default of 0, and it is not deprecated.
//
// Measured, two real `npm ci` installs from the identical lockfile with the
// process umask at 0022 in BOTH:
//   npm umask 0   (default) -> {"644":2157,"755":20}            the recorded digest
//   npm umask 077           -> {"600":2156,"700":12,"755":8,"644":1}   a different one
// The second run then emitted `freezeRecord: true` with an empty
// notFreezeRecordBecause, matchesReviewedManifest true and `umask 0022` printed
// in its own toolchain block -- a complete, unqualified freeze record over a
// tree that is not the reviewed one. The process-umask guard looked straight at
// it and was satisfied, because it reads a different umask.
//
// `npm config list --json` does report the key (63 under NPM_CONFIG_UMASK=077),
// so this guard could always have seen it and simply never asked. That is the
// same "an install-shaping setting the config guard could see and didn't"
// defect as bin-links in round 2, package-lock-only in round 3 and the registry
// in round 5. The permission histogram is the backstop here for the same reason
// it is for the process umask: it records the observed modes rather than a
// predicate over them, so a tree installed under either umask names its own
// cause even when neither guard was watching at install time.
const REVIEWED_NPM_CONFIG = Object.freeze({
  'bin-links': true,
  omit: [],
  include: [],
  'install-strategy': 'hoisted',
  'legacy-peer-deps': false,
  'package-lock': true,
  'package-lock-only': false,
  umask: 0,
  // Reported by Codex. `dry-run` is install-shaping and was absent from this
  // table, so configDrift -- which iterates only the reviewed keys -- could not
  // see it. npm documents `--dry-run` for `npm ci` (default false); under it
  // `npm ci` exits 0 and writes nothing, so the documented reinstall becomes a
  // no-op and the recorder would fold whatever stale or tampered tree was
  // already on disk instead of refusing the configuration. `npm ls` checks the
  // dependency GRAPH, not the bytes, so a graph-valid stale tree still passes
  // treeSatisfiesLockfile -- the same "an install-shaping setting the guard
  // could see and didn't" defect as bin-links (r2), package-lock-only (r3) and
  // umask (r9).
  //
  // Measured on npm 10.9.7 from an identical `file:` lockfile under process
  // umask 0022: a clean `npm ci` installs node_modules/dep; the same command
  // under NPM_CONFIG_DRY_RUN=true exits 0 and creates nothing, and against a
  // tree whose dep/package.json was edited to 9.9.9 it exits 0 and leaves the
  // edit in place where a clean `npm ci` wipes and restores it. `npm config
  // list --json` reports dry-run true under the env var and false when clean, so
  // this guard sees it exactly as it sees the three keys above; a clean run does
  // not drift.
  'dry-run': false,
  // Round 11, reported and confirmed. npm applies this option when it CREATES
  // lockfiles, and that includes the hidden `node_modules/.package-lock.json`
  // the fold hashes. npm documents it as producing lockfiles without registry
  // `resolved` keys, default false.
  //
  // Measured with a real `npm ci` from the identical lockfile: the hidden
  // lockfile came back with 0 `resolved` keys against the reviewed tree's 125,
  // moving the installed-tree digest while the census still
  // reported the recorded 2177/8/336 and nothing refused. The package payloads
  // were byte-identical; only npm's own bookkeeping file changed.
  //
  // Excluding `.package-lock.json` from the fold was considered and rejected:
  // that removes real coverage of a file npm writes and tools read, to dodge a
  // configuration problem the guard should simply catch.
  'omit-lockfile-registry-resolved': false,
});

// Transport and trust, checked ONLY when an audit will run.
//
// Round 19, reported: pinning the registry URL pins where the request is
// ADDRESSED, not where it goes or who it trusts. npm honours `proxy`,
// `https-proxy` and the standard proxy environment variables for outgoing HTTPS,
// and `ca`, `cafile` and `strict-ssl` decide which certificates count -- so a
// TLS-intercepting proxy with a trusted custom CA can return a filtered,
// schema-valid audit while this script records the posture as public-registry.
//
// Round 20, reported: putting them in the table above made them unconditional,
// which broke `--no-audit` behind a proxy with exit 6. That is precisely the
// false failure the registry guard was placed on the audit path to avoid in
// round 5 -- the installed tree is pinned by lockfile integrity hashes and is
// not exposed to any of this. Separated so the install-shaping checks stay
// unconditional and these do not.
const REVIEWED_NPM_TRANSPORT = Object.freeze({
  proxy: null,
  'https-proxy': null,
  noproxy: [],
  ca: null,
  cafile: null,
  'strict-ssl': true,
});

// Round 20, reported. Validating the six once did not bind them: the audit runs
// in a separate process that reloads configuration, so an .npmrc rewritten in
// between reinstated a proxy the check had just cleared. Derived from the
// reviewed values themselves, so the values compared and the values used cannot
// diverge.
// A null reviewed value cannot be expressed as a flag: measured, `--proxy=`
// makes npm warn `invalid config proxy=""` and `--ca=` breaks the TLS handshake
// outright, because an empty string is not the same as unset. Only non-null
// values become flags; the null ones are bound by scrubbing them from the
// child's environment instead.
function transportFlags() {
  return Object.entries(REVIEWED_NPM_TRANSPORT)
    .filter(([, objValue]) => objValue !== null)
    .map(([strKey, objValue]) =>
      `--${strKey}=${Array.isArray(objValue) ? objValue.join(',') : objValue}`);
}

// The environment half of the same binding. npm reads npm_config_* and the
// standard proxy variables; both are fixed when this process starts and were
// covered by the pre-audit check, but removing them from the child makes the
// binding explicit rather than inherited.
// Names only, never values. A scrubbed NODE_EXTRA_CA_CERTS path or proxy URL
// can carry a hostname, a username, or a token, and this record is published.
// Recorded, not compared: a non-empty list tells the reader the ambient
// environment tried to steer the audit, and that the answer below was taken
// with those overrides removed rather than under them.
const arrScrubbedTrustVariables = [];

function transportEnvironment() {
  const objEnv = { ...process.env };
  const dropTrustVariable = (strName) => {
    if (!Object.hasOwn(objEnv, strName)) return;
    delete objEnv[strName];
    if (!arrScrubbedTrustVariables.includes(strName)) arrScrubbedTrustVariables.push(strName);
  };
  // Round 21, reported. NODE_EXTRA_CA_CERTS is a Node-level trust root, invisible
  // to `npm config list` -- which keeps reporting ca: null and strict-ssl: true --
  // so an interceptor whose certificate chains to it could return a filtered,
  // schema-valid report attributed to the public registry. Checking npm's trust
  // settings and inheriting Node's was a gap the previous round's fix left open.
  // Round 22, reported. NODE_EXTRA_CA_CERTS was one of several Node-level trust
  // overrides. NODE_USE_SYSTEM_CA, and --use-system-ca / --use-openssl-ca passed
  // through NODE_OPTIONS, redirect Node at the system or OpenSSL store, where an
  // enterprise or interceptor CA can authenticate a filtered response while npm
  // still reports ca: null and strict-ssl: true. SSL_CERT_FILE and SSL_CERT_DIR
  // are the OpenSSL half of the same thing.
  dropTrustVariable('NODE_EXTRA_CA_CERTS');
  dropTrustVariable('NODE_USE_SYSTEM_CA');
  dropTrustVariable('SSL_CERT_FILE');
  dropTrustVariable('SSL_CERT_DIR');
  // Round 24, reported. NODE_TLS_REJECT_UNAUTHORIZED was the one Node trust
  // override never scrubbed, and it does not redirect the trust store -- it
  // switches verification off. Measured here against a self-signed HTTPS
  // server: with the variable set to 0 a default request is ACCEPTED, while a
  // request carrying an explicit rejectUnauthorized: true is still REJECTED
  // with DEPTH_ZERO_SELF_SIGNED_CERT. npm 10.9.7 does pass it explicitly, but
  // only on one branch -- make-fetch-happen/lib/options.js reads the variable
  // itself whenever strictSSL arrives undefined or null. Relying on a bundled
  // transitive dependency to keep taking the other branch is the same kind of
  // version-dependent incidental protection this script declined to rely on
  // for the symlinked root.
  dropTrustVariable('NODE_TLS_REJECT_UNAUTHORIZED');
  // Round 27, swept rather than reported, and reported here with its limits.
  // The list above is a denylist, and this script's own history says denylists
  // over this surface come up short, so the siblings were looked for rather
  // than waited for. OpenSSL takes its configuration from OPENSSL_CONF and
  // finds providers and engines through OPENSSL_MODULES and OPENSSL_ENGINES,
  // and an activated provider supplies the primitives that verify signatures --
  // which would subvert the audit's transport more completely than any CA
  // override.
  //
  // What was MEASURED is narrower than that, and the difference matters.
  // Proven: Node reads OPENSSL_CONF, because a malformed file makes it exit
  // with `node: OpenSSL configuration error` before running any script.
  // NOT proven: that the file can steer this process's TLS. An OPENSSL_CONF
  // setting MinProtocol to TLSv1.3 left a TLSv1.2 handshake negotiating
  // TLSv1.2 unchanged -- twice, once through the `system_default` section and
  // once through the `nodejs_conf` section with --openssl-shared-config --
  // because Node sets its TLS parameters programmatically and those win.
  // Loading a hostile provider was not attempted; building one is far outside
  // what this verification can do.
  //
  // Scrubbed regardless, for the reason NODE_TLS_REJECT_UNAUTHORIZED is: the
  // cost is three lines, and the alternative is relying on Node continuing to
  // override a configuration file it demonstrably parses.
  dropTrustVariable('OPENSSL_CONF');
  dropTrustVariable('OPENSSL_MODULES');
  dropTrustVariable('OPENSSL_ENGINES');
  // Round 24, reported. The previous version removed two exact tokens from
  // NODE_OPTIONS. Measured on Node v22.22.2, every one of these spellings is
  // accepted and none of them matched: --use-openssl-ca=true, --use-openssl-ca=1,
  // --use-system-ca=true, --use-system-ca=TRUE, --no-use-system-ca,
  // --use-bundled-ca=false. That is the second consecutive round in which this
  // filter was extended and still incomplete, which is the argument against
  // extending it a third time.
  //
  // The variable is dropped entirely instead. A caller who can set NODE_OPTIONS
  // does not need a CA flag to subvert the answer at all: --require and --import
  // preload arbitrary code into the very process that produces the audit report,
  // so no list of trust-related tokens could ever have been sufficient. Dropping
  // also retires the previous round's quoting hazard -- nothing is parsed here,
  // so nothing can be corrupted -- at the cost of an ambient --max-old-space-size
  // not reaching the audit child. The name is recorded when that happens.
  dropTrustVariable('NODE_OPTIONS');
  for (const strKey of Object.keys(objEnv)) {
    const strLower = strKey.toLowerCase();
    if (strLower === 'http_proxy' || strLower === 'https_proxy' || strLower === 'no_proxy'
      || Object.keys(REVIEWED_NPM_TRANSPORT).some(
        (strConfig) => strLower === `npm_config_${strConfig.replace(/-/gu, '_')}`)) {
      if (REVIEWED_NPM_TRANSPORT[strLower.replace(/^npm_config_/u, '').replace(/_/gu, '-')] === null
        || strLower.endsWith('_proxy')) dropTrustVariable(strKey);
    }
  }
  // Round 25, swept rather than reported. A reviewer read the loop above as
  // leaving no_proxy in place, on the grounds that the `_` -> `-` mapping turns
  // it into `no-proxy`, which is not a key. The mapping half is right and the
  // conclusion is not: the test is a disjunction, and `no_proxy` ends with
  // `_proxy`. Measured -- with NO_PROXY and no_proxy both set, both names appear
  // in auditEnvironmentScrubbed.
  //
  // The finding was wrong, but that an expression can be read that way is the
  // argument for checking what it PRODUCED rather than trusting how it reads --
  // the same move made for `npm ls` in this round, one guard over. A future edit
  // that breaks the scrub now fails here, loudly, instead of quietly sending the
  // audit through an interceptor.
  //
  // Only the null-valued settings are checked. The non-null ones -- noproxy and
  // strict-ssl -- are deliberately bound the other way, by transportFlags() on
  // the command line, which outranks the environment; and an ambient
  // npm_config_noproxy is refused before this by the pre-audit configuration
  // check, measured at exit 6.
  const arrResidual = Object.keys(objEnv).filter((strKey) => {
    const strLower = strKey.toLowerCase();
    if (strLower === 'http_proxy' || strLower === 'https_proxy' || strLower === 'no_proxy') return true;
    if (!strLower.startsWith('npm_config_')) return false;
    const strConfig = strLower.replace(/^npm_config_/u, '').replace(/_/gu, '-');
    return REVIEWED_NPM_TRANSPORT[strConfig] === null;
  });
  if (arrResidual.length > 0) {
    process.stderr.write(
      'supply-freeze: the transport scrub did not bind the audit environment.\n' +
      // Round 45, swept from the reported argument defect rather than reported.
      // NOT exploitable: a name carrying a control character cannot survive the
      // filter above, because it would have to match a reviewed transport key
      // exactly to be counted residual, so this list is provably a subset of
      // constants. Escaped anyway -- that argument is non-local, and an invariant
      // that every non-self-computed value passes the formatter needs no argument.
      `  still present      ${arrResidual.sort().map((strName) => formatUntrustedText(strName)).join(', ')}\n` +
      '  this is a defect in this script, not in your configuration: those names\n' +
      '  should have been removed from the child environment before the audit ran.\n' +
      '  pass --no-audit to record the lockfile-derived fields without an audit.\n');
    process.exit(6);
  }
  return objEnv;
}

// The process umask the recorded tree was installed under.
//
// Round 4, reported and confirmed. The fold records `mode & 0o111`, and an
// earlier reply to this PR argued that mask was umask-portable because "0o755
// under umask 077 is still 0o700, still executable". That is true about
// EXECUTABILITY and irrelevant to the RECORDED VALUE: 0o755 & 0o111 is 0o111,
// 0o700 & 0o111 is 0o100, so the two hash differently. Measured -- a full
// `npm ci` under umask 077 produced a digest that differs from the recorded
// one, a mismatch caused by nothing but the reader's umask.
//
// npm documents that folders and executables are masked by both npm's
// configured umask and the underlying system umask. npm's own `umask` config
// defaults to 0 and is reported by `npm config list`, so the config guard above
// sees nothing wrong; the process umask is a separate input it never looked at.
//
// So it is pinned rather than assumed away. This is the sixth environmental
// input the record pins, alongside Node, npm, platform, arch and npm config,
// and it is the cheapest of them for a reader to satisfy.
const REVIEWED_UMASK = 0o022;

// Round 15, reported. This was read three times -- once by the guard, once by
// its own failure message, and once by the record -- so the value refused and
// the value reported were separate observations of the same thing. Read once,
// formatted once, used everywhere.
const intObservedUmask = process.umask();
const strObservedUmask = `0${intObservedUmask.toString(8).padStart(3, '0')}`;

// The registry the recorded advisory posture was snapshotted from. Checked only
// on the audit path -- see the comment at its use for why the installed tree is
// not exposed to this and a --no-audit run therefore is not refused.
const REVIEWED_REGISTRY = 'https://registry.npmjs.org/';

const strWorkflowDirectory = dirname(fileURLToPath(import.meta.url));
const arrRawArguments = process.argv.slice(2);
const arrCacheArguments = arrRawArguments.filter((strArg) => strArg.startsWith('--cache-directory='));
const arrArguments = arrRawArguments.filter((strArg) => !strArg.startsWith('--cache-directory='));

const boolJson = arrArguments.includes('--json');
const boolAnyToolchain = arrArguments.includes('--any-toolchain');
const boolSkipAudit = arrArguments.includes('--no-audit');

// Round 31, reported. Parsing was three membership tests and nothing else, so
// every unrecognized argument was accepted in silence. Measured: `--no-audti`
// exits 0 and performs the registry audit, which is the opposite of what the
// caller asked for -- and the one option whose whole purpose is to keep this
// process off the network is also the one most likely to be typed from memory.
// The record it produces is not wrong, but it is not the record requested, and
// nothing in the output says so.
//
// Refused rather than warned: a warning on stderr is invisible to `--json`
// consumers, which are the callers most likely to be scripted.

// The identity of an inode, for the checks that ask "is this the same file it
// was a moment ago". Round 71, reported by Codex, and this is the round-67
// inode half caught being only as wide as the type carrying it. Those sites
// recorded `objStat.ino` from a default stat, where ino is a JS number -- so an
// inode above 2^53 arrives ALREADY ROUNDED. Measured on node 22.22.2:
//
//   Number(2n ** 53n + 1n) === Number(2n ** 53n)   // true, both 9007199254740992
//
// Two distinct inodes therefore collapse to one reading, and a replacement
// within one timestamp tick compares EQUAL -- exactly the hole round 67 added
// the inode half to close, reopened by the width of the number. This container
// hands out small inodes (the repository root measured 475146), so the check was
// correct here by accident of filesystem rather than by construction; XFS, ZFS,
// btrfs and NFS all expose 64-bit inode numbers.
//
// ctimeNs comes with bigint stats and is what the same-tick argument wanted all
// along: nanoseconds rather than milliseconds narrows the window by six orders
// of magnitude. Callers take ONE bigint lstat and pass the result here -- two
// stats of the same path can disagree, which would be a race inside the race
// detector.
function statIdentity(objStats) {
  return `${objStats.ino}:${objStats.ctimeNs}`;
}

// Renders one quiescence-sweep reading. Round 67: the sweep began recording
// `${ino}:${ctimeMs}` rather than a bare timestamp, and this message still fed
// the value to `new Date(...).toISOString()`. Measured before this was added --
// the sweep DETECTED the change correctly and then died formatting its own
// refusal with `RangeError: Invalid time value`, turning a clean exit 10 into an
// exit 1 stack trace. A refusal that cannot print itself is not a refusal, and
// the reading is the thing an operator uses to tell a rewrite-in-place from a
// swap, so both halves are shown.
//
// Round 71: the reading became `${ino}:${ctimeNs}`, and this is the round-67
// crash above being deliberately NOT repeated. Nanoseconds break the old
// arithmetic twice over -- a current ctimeNs is about 1.78e18, which is past
// Number.MAX_SAFE_INTEGER (9.007e15) so Number() rounds it, and past the ±8.64e15
// milliseconds Date accepts so the same `RangeError: Invalid time value` returns.
// The division is therefore BigInt, before any conversion to Number: exact, and
// the quotient is a millisecond count Date has always accepted.
function formatSweepReading(objReading) {
  if (objReading === -1) return 'absent';
  const strReading = String(objReading);
  const intSeparator = strReading.indexOf(':');
  if (intSeparator < 0) return new Date(Number(strReading)).toISOString();
  const strInode = strReading.slice(0, intSeparator);
  const intChangedAt = Number(BigInt(strReading.slice(intSeparator + 1)) / 1000000n);
  return `inode ${strInode}, ctime ${new Date(intChangedAt).toISOString()}`;
}

// A caller controls the complete argv token, including the part before `=` and
// every apparent flag name. That token can itself be a credential, so no spelling
// is a safe disclosure boundary. Keep only the argument position and decoded
// character length. The fixed supported list below supplies the useful repair
// guidance without echoing any caller bytes into a retained diagnostic.
function formatUnsupportedInvocation(arrAllArguments, objSupportedArguments) {
  return arrAllArguments.flatMap((strArg, intIndex) => (
    objSupportedArguments.has(strArg) || strArg.startsWith('--cache-directory=')
      ? []
      : [`argument ${intIndex + 1} (${[...strArg].length} Unicode code points withheld)`]
  )).join(', ');
}

const SUPPORTED_ARGUMENTS = new Set(['--json', '--any-toolchain', '--no-audit']);
const arrUnsupported = arrArguments.filter((strArg) => !SUPPORTED_ARGUMENTS.has(strArg));
if (arrUnsupported.length > 0) {
  process.stderr.write(
    'supply-freeze: refusing to record digests for an unrecognized invocation.\n' +
    // Round 45, reported by Codex. Caller-supplied bytes, written to a retained
    // log verbatim. Measured with `$'--bogus\\nsupply-freeze: all inputs
    // quiescent, 0 problems'`: the forged sentence landed at column 0, inside a
    // refusal, claiming the opposite of what the run had just decided.
    //
    // Round 63, reported by Codex, and the round-45 fix above was answering the
    // wrong question. It sent the whole argument through formatUntrustedText,
    // which redacts from a URL SCHEME onward -- so `--registry=https://h/TOKEN`
    // was withheld and `--registry=//host/path?token=SECRET` was not, because a
    // schemeless network-path reference has no scheme colon for RE_URL_IN_TEXT
    // to find. npm accepts that spelling; the refusal printed the token.
    //
    // Widening the pattern is the move rounds 47 through 52 already made five
    // times, each widening introducing the next gap, and the rule those rounds
    // settled on is to derive the boundary from the parser rather than guess it.
    // The parser is no help here: `new URL('//host/p')` THROWS without a base,
    // so a network-path reference is not a URL by the standard's own definition.
    // There is no pattern to derive, which is why every attempt to widen one has
    // found another shape.
    //
    // No part of an unsupported token is rendered. Its position and length, plus
    // the fixed supported list, identify where to repair the invocation without
    // treating caller-controlled flag spelling as public metadata.
    `  unrecognized       ${formatUnsupportedInvocation(arrRawArguments, SUPPORTED_ARGUMENTS)}\n` +
    `  supported          ${[...SUPPORTED_ARGUMENTS, '--cache-directory=<path>'].join(' ')}\n` +
    '  a mistyped option would otherwise be ignored in silence, and the run would\n' +
    '  record something other than what was asked for.\n');
  process.exit(2);
}

// Round 52, reported by Codex against the script's self-hash, and swept to the
// class rather than the site. This hashed a STRING, and every caller that had
// read a file handed it text decoded as UTF-8 -- which is lossy: any invalid
// byte sequence decodes to U+FFFD, so a file containing a raw 0x80 and a file
// containing a genuine U+FFFD produce the same string and therefore the same
// digest. This file itself carries two literal U+FFFD characters, so the
// substitution is available in practice, not only in principle. Measured:
//
//   original raw sha256 c0ff4a6f...   tampered raw sha256 95226a6a...
//   what this function returned for BOTH: c0ff4a6f...
//
// A byte-different script reporting the reviewed script identity defeats the one
// control that binds these numbers to the code that produced them.
//
// The reported site was the script. The same decode fed `package.json` and
// `package-lock.json`, whose SHA-256 rows and blob ids are COMPARED fields, and
// gitBlobId is defined over raw bytes by git in the first place -- so computing
// one from a decoded string was wrong twice over. Bytes end to end now: the
// reads return Buffers, the digests are taken over Buffers, and the re-read
// comparisons use Buffer.equals rather than string identity.
//
// A string is still accepted, because the advisory posture legitimately hashes a
// canonical JSON string this file generated rather than a file it read.

// Cache/log routing is never waived by diagnostic switches. Validate before the
// first npm process; asking npm for its configuration can itself create logs.
function refuseCache() {
  process.stderr.write('supply-freeze: --cache-directory requires one existing empty private external directory; refusing before npm.\n');
  process.exit(16);
}
function hasUnsupportedNodeStartupEnvironment(objEnv) {
  return Boolean((objEnv.NODE_COMPILE_CACHE && objEnv.NODE_DISABLE_COMPILE_CACHE !== '1')
    || objEnv.NODE_V8_COVERAGE || objEnv.NODE_REDIRECT_WARNINGS
    || objEnv.NODE_DEBUG || objEnv.NODE_DEBUG_NATIVE);
}
function validateCacheDirectory() {
  if (process.platform !== 'linux' || process.arch !== 'x64') {
    process.stderr.write('supply-freeze: this recorder supports Linux/x64 only.\n');
    process.exit(2);
  }
  // Runtime cache/coverage/warning output can occur before or after our code.
  // This refusal prevents a complete claim, but cannot undo startup effects.
  // The caller must scrub these variables BEFORE Node starts; see the method.
  if (hasUnsupportedNodeStartupEnvironment(process.env)) {
    process.stderr.write('supply-freeze: unsupported Node startup-output environment; use the documented startup scrub.\n');
    process.exit(2);
  }
  if (arrCacheArguments.length !== 1) refuseCache();
  const strCandidate = arrCacheArguments[0].slice('--cache-directory='.length);
  if (!isAbsolute(strCandidate) || strCandidate.includes('\0')) refuseCache();
  try {
    const strResolved = realpathSync(strCandidate);
    // Reject aliases, dot segments and symlink ancestors, not just a linked leaf.
    if (strCandidate !== strResolved) refuseCache();
    const strRepository = realpathSync(dirname(dirname(strWorkflowDirectory)));
    const strPhysicalRepository = realpathSync(dirname(dirname(dirname(strScriptPath))));
    const strDistribution = realpathSync(dirname(dirname(process.execPath)));
    const inside = (a, b) => a === b || a.startsWith(`${b === '/' ? '' : b}/`);
    const overlaps = (a, b) => inside(a, b) || inside(b, a);
    if (overlaps(strResolved, strRepository) || overlaps(strResolved, strPhysicalRepository)
      || overlaps(strResolved, strDistribution)) refuseCache();
    const objRoot = lstatSync(strResolved, { bigint: true });
    if (!objRoot.isDirectory() || objRoot.isSymbolicLink()
      || objRoot.uid !== BigInt(process.getuid()) || (objRoot.mode & 0o7777n) !== 0o700n
      || readdirSync(strResolved).length !== 0) refuseCache();
    // A sticky shared parent (e.g. /tmp) protects this owned leaf from another
    // uid's rename. Same-uid concurrent mutation remains a caller exclusion.
    for (let strAt = dirname(strResolved); ; strAt = dirname(strAt)) {
      const objAt = lstatSync(strAt);
      if (!objAt.isDirectory() || objAt.isSymbolicLink()
        || (objAt.uid !== 0 && objAt.uid !== process.getuid())
        || ((objAt.mode & 0o022) !== 0 && (objAt.mode & 0o1000) === 0)) refuseCache();
      if (strAt === dirname(strAt)) break;
    }
    return strResolved;
  } catch { refuseCache(); }
}
const strExternalCacheDirectory = validateCacheDirectory();
const objNpmProcessResults = [];

function sha256(objInput) {
  return createHash('sha256')
    .update(Buffer.isBuffer(objInput) ? objInput : Buffer.from(objInput, 'utf8'))
    .digest('hex');
}

function nonOwnerWriteReason(objStats) {
  const objWriteMask = typeof objStats.mode === 'bigint' ? 0o022n : 0o022;
  const objZero = typeof objStats.mode === 'bigint' ? 0n : 0;
  const objWriteBits = objStats.mode & objWriteMask;
  return objWriteBits === objZero
    ? null
    : `is writable by non-owner classes (write bits ${Number(objWriteBits)
      .toString(8).padStart(4, '0')})`;
}

// Round 41, reported by Codex. Names read off the tree are attacker-chosen, and
// POSIX permits every byte in a filename except NUL and the slash -- newline,
// carriage return and ESC included. Printed verbatim into a refusal, a name
// carrying a newline ends the line and starts a new one at column 0, which in a
// retained CI log is indistinguishable from something this script said. That is
// CWE-117 log forging, and it was reachable at three refusals:
//
//   ln -s /etc/hostname $'zevil\nsupply-freeze: all checks passed, tree is clean'
//
//   supply-freeze: refusing to record digests for a tree whose links leave it.
//     escaping links     2 (expected 0)
//       node_modules/eastasianwidth/zevil
//   supply-freeze: all checks passed, tree is clean      <-- the filename
//
// An ESC is worse than a newline: `\033[2K\033[G` erases the rendered line and
// returns the cursor, so the real path is overwritten rather than merely joined.
//
// \p{Cc} is the Unicode Control category -- C0, DEL and C1. \p{Cf} is Format,
// which carries the bidirectional overrides and isolates behind Trojan Source
// (CVE-2021-42574); those reorder rendered text without emitting any byte a C0
// filter would catch. Printable text of every script is left alone, so a package
// with a legitimately non-ASCII path still prints as itself.
//
// Escaping rather than stripping is deliberate, and it is what the Trojan Source
// authors recommend for display tools: the operator has to be able to act on the
// name. \xNN and \u{NNNN} are unambiguous and the true name is recoverable.
//
// Applied where these names are COLLECTED rather than where they are printed.
// Rounds 35 through 40 were six consecutive defects of one shape -- a value made
// safe at one print site while it stayed dangerous in the variable -- and the
// sixth was at a site my own round-39 sweep had listed and not opened. A name
// that is escaped on the way into the array cannot be un-escaped by a later edit
// that adds a print site.
// Round 43, reported by Codex. The single way this file renders "where an errno
// happened", so the escaping cannot be present at some sites and absent at
// others.
//
// It was absent at three of five. Round 41 escaped this class by replacing one
// exact template string containing `strPath`; the sites spelling their fallback
// `strScriptPath` or `'(path not reported)'` never matched, and I described that
// as a mechanical sweep. It was a pattern match, for the third round running.
// The mechanical sweep is over the VALUE -- `grep -n 'objError.path'` -- and the
// durable fix is to stop hand-building the line at all: `grep formatErrorLocation`
// now audits every site completely, and a new refusal that reports an errno
// location has one obvious thing to call.
//
// objError.path carries whatever bytes the failing path had. Measured:
//
//   lstatSync('/tmp/gone43\nsupply-freeze: all inputs quiescent, 0 problems')
//   ->  error              ENOENT at /tmp/gone43
//       supply-freeze: all inputs quiescent, 0 problems     <-- column 0
//
// String() before escaping because objError.path is not guaranteed to be a
// string; a Buffer path would otherwise reach String.prototype.replace as an
// object.
// Round 63, reported by Codex. This escaped control characters and stopped
// there, so it was the one untrusted-text path that bypassed the redaction
// funnel every other diagnostic in this file goes through. The path here is
// attacker-chosen in exactly the cases this function exists for: a tree entry
// that vanishes mid-scan is reported through here, and an entry may legally be
// named `https:/user:SECRET@host/path?token=X`. formatUntrustedText falls back
// to formatTreeName when it finds no url, so this is a strict widening -- the
// same escaping as before on ordinary paths, plus redaction on the ones that
// carry a credential.
function formatErrorLocation(objError, strFallback) {
  return `  error              ${objError?.code ?? 'unknown'}`
    + ` at ${formatUntrustedText(String(objError?.path ?? strFallback))}\n`;
}

// Round 45, reported by Codex, and a defect in the escaper round 44 made
// authoritative. Cc and Cf miss U+2028 LINE SEPARATOR and U+2029 PARAGRAPH
// SEPARATOR, which are categorized Zl and Zp. Measured: both survived this
// function unchanged and reached the record as raw bytes.
//
// The referee is not my judgement about which renderers break lines -- it is the
// language this file is written in. ECMA-262 defines LineTerminator as exactly
// LF, CR, U+2028 and U+2029, so two of the four characters the spec calls line
// terminators were being escaped and two were not. Zl and Zp have no other
// members today, and naming the categories rather than the two code points keeps
// that true if Unicode adds one.
function formatTreeName(strName) {
  return strName.replace(/[\p{Cc}\p{Cf}\p{Zl}\p{Zp}]/gu, (strChar) => {
    const intCode = strChar.codePointAt(0);
    return intCode <= 0xff
      ? `\\x${intCode.toString(16).padStart(2, '0')}`
      : `\\u{${intCode.toString(16).padStart(4, '0')}}`;
  });
}



// "A JSON object", as distinct from everything else `typeof x === 'object'`
// admits. Both `null` and an array answer 'object', and each of those has now
// been reported as a hole in the audit shape guard -- null in round 2, arrays
// in round 6. One predicate, used everywhere, rather than a conjunction
// rewritten at each call site and wrong in a different way each time.
// Severity order for the recorded counts AND for the shape guard below. One
// list drives both, so the field that is compared and the field that is
// validated cannot describe different shapes.
//
// Round 13, reported by Copilot. `counts` used to be npm's own object copied
// straight through, so its KEY ORDER came from npm's JSON emitter. The digest
// was never at risk -- canonicalize sorts keys -- but the record quotes the
// counts as a compared field, and a reader string-comparing that value would
// see a false mismatch if a future npm emitted the same numbers in a different
// order. Rebuilding in a fixed order makes the compared text depend on the
// values alone.
// The five buckets npm's aggregate vulnerability logic recognizes, and the
// recorded order. SEVERITY_ORDER is derived rather than written out twice so the
// domain and the record can never drift apart.
const SEVERITY_LEVELS = Object.freeze(['info', 'low', 'moderate', 'high', 'critical']);
const SEVERITY_ORDER = Object.freeze([...SEVERITY_LEVELS, 'total']);

// Round 33, reported. npm copies a truthy source severity into an advisory
// verbatim, but only the five levels above are counted, so `severity: "urgent"`
// produced a report with total 1, every bucket 0, and a null package severity --
// measured exit 0, recording a posture whose own arithmetic disagreed with
// itself. Absence stays legal, because npm may omit the field; a present value
// outside the domain is a value this record cannot mean anything by.
function assertSeverity(strLabel, objValue, strName) {
  if (objValue === undefined || objValue === null) return;
  if (typeof objValue !== 'string' || !SEVERITY_LEVELS.includes(objValue)) {
    throw new TypeError(
      `${strLabel} in ${strName} is ${JSON.stringify(objValue)}, which is not one of`
      + ` ${SEVERITY_LEVELS.join(', ')}`);
  }
}

function orderedCounts(objCounts) {
  if (!objCounts || typeof objCounts !== 'object') return null;
  const objOrdered = {};
  for (const strSeverity of SEVERITY_ORDER) objOrdered[strSeverity] = objCounts[strSeverity];
  return objOrdered;
}

function isPlainObject(objValue) {
  return typeof objValue === 'object' && objValue !== null && !Array.isArray(objValue);
}

// A Git blob identity is SHA-1 over `blob <byteLength>\0<content>`. Implemented
// rather than shelled out to `git`, so the check works in an exported tree with
// no repository and cannot be confused by the working directory.
function gitBlobId(objInput) {
  const objBytes = Buffer.isBuffer(objInput) ? objInput : Buffer.from(objInput, 'utf8');
  return createHash('sha1')
    .update(`blob ${objBytes.length}\0`, 'utf8')
    .update(objBytes)
    .digest('hex');
}

// One canonical serialization for the advisory record: keys in sorted order, no
// insignificant whitespace. Two readers who agree on the field selection below
// therefore agree on the bytes.
function canonicalize(objValue) {
  if (Array.isArray(objValue)) return `[${objValue.map(canonicalize).join(',')}]`;
  if (objValue && typeof objValue === 'object') {
    return `{${Object.keys(objValue).sort()
      .map((strKey) => `${JSON.stringify(strKey)}:${canonicalize(objValue[strKey])}`)
      .join(',')}}`;
  }
  return JSON.stringify(objValue ?? null);
}

// Round 16, reported. Every manifest read after the first snapshot was a bare
// readFileSync, so a manifest deleted or made unreadable mid-run threw before
// the comparison it feeds could issue the documented exit 3 -- exit 1 and a raw
// node:fs trace instead. A read that cannot complete IS the input changing.
// Round 80, reported by Codex as a P2 and validated. Reads a manifest through a
// descriptor whose type was checked ON THAT DESCRIPTOR, never by re-resolving the
// path.
//
// The preflight loop lstat()s the manifest by NAME, and snapshotOrRefuse() and
// readOrRefuse() then each open() it by NAME again. Three independent
// resolutions of an attacker-controlled name, so the thing whose type was
// approved need not be the thing whose bytes are read. Swap a regular file for a
// FIFO in between and the reviewed bytes are consumed from a stream while npm ls
// and npm audit consume whatever is written next; the sweep compares the same
// FIFO inode and ctime at the end and exit 15 never fires.
//
// Measured: one FIFO path, one inode, returned REVIEWED-BYTES on the first open
// and ATTACKER-BYTES on the second. NOT measured: winning the race itself, which
// is timing-dependent. The mechanism is demonstrated; the exploit is not.
//
// O_NONBLOCK is load-bearing rather than defensive tidiness. Opening a FIFO for
// reading BLOCKS until a writer appears, so checking the type after a plain
// open() would hang the run on exactly the input this guard exists to refuse --
// a fix that deadlocks CI gets reverted, which is no fix.
// objRefusal carries the CALLER's answer for a file that is not a regular file.
// Codex P3 on a756ebe: the branches below were written for manifests, and this
// helper also serves the script self-check, so a raced script replacement refused
// with exit 15 and "a manifest is not a regular file" -- pointing the reader at
// the wrong input. The table classifies script replacement as exit 3.
//
// Codex named the ELOOP branch; the fstat branch below it had the identical defect
// and is fixed here too. Fixing only the reported instance would have left the
// same wrong answer one branch away.
function readViaVerifiedDescriptor(strPath, intMissingExit, fnOnMissing,
    objRefusal = { exit: 15, what: 'manifest', holdable: true }) {
  let intFd;
  try {
    intFd = openSync(strPath,
      fsConstants.O_RDONLY | fsConstants.O_NONBLOCK | fsConstants.O_NOFOLLOW);
  } catch (objError) {
    // O_NOFOLLOW, reported by Codex as a P1 against the descriptor fix one commit
    // earlier -- which closed the FIFO shape of this TOCTOU and left the symlink
    // shape wide open. Measured on the shipped code: opening a symlink without
    // this flag reported isFile()=true, isSymbolicLink()=false, and returned the
    // TARGET's bytes. The descriptor was bound, but bound to the wrong object, so
    // fstat approved a link as a regular file -- the exact case exit 15 exists to
    // refuse, defeated by the fix written to enforce it.
    //
    // The kernel refuses at open, so unlike an lstat-then-open check there is no
    // window to race. ELOOP is how it says "that was a symlink"; it is translated
    // here because the raw errno reads like a loop, not a refusal.
    if (objError?.code === 'ELOOP') {
      process.stderr.write(
        `supply-freeze: refusing to record digests for a ${objRefusal.what} that is `
        + 'not a regular file.\n'
        + `  ${strPath.split('/').pop().padEnd(18)} is a symlink\n`
        + '  refused by the kernel at open (O_NOFOLLOW), so no window exists between\n'
        + '  checking the type and reading the bytes. Only a regular file returns the\n'
        + '  same bytes to this process and to npm.\n');
      process.exit(objRefusal.exit);
    }
    fnOnMissing(objError);
    process.exit(intMissingExit);
  }
  let boolCloseAttempted = false;
  const closeDescriptorOnce = () => {
    if (boolCloseAttempted) return null;
    boolCloseAttempted = true;
    try {
      closeSync(intFd);
      return null;
    } catch (objError) {
      return objError;
    }
  };
  const refuseDescriptorFailure = (objError) => {
    // close(2) can report a late I/O failure after releasing the fd. Never retry
    // an uncertain fd: it may already have been reused. If fstat/read failed
    // first, preserve that failure and make one close attempt only for cleanup.
    closeDescriptorOnce();
    fnOnMissing(objError);
    process.exit(intMissingExit);
  };
  let objStats;
  try {
    objStats = fstatSync(intFd);
  } catch (objError) {
    refuseDescriptorFailure(objError);
  }
  if (!objStats.isFile()) {
    const strKind = objStats.isSymbolicLink() ? 'a symlink'
      : objStats.isDirectory() ? 'a directory'
        : objStats.isFIFO() ? 'a FIFO'
          : objStats.isSocket() ? 'a socket'
            : objStats.isCharacterDevice() || objStats.isBlockDevice() ? 'a device node'
              : 'not a regular file';
    closeDescriptorOnce();
    process.stderr.write(
      `supply-freeze: refusing to record digests for a ${objRefusal.what} that is `
      + 'not a regular file.\n'
      + `  ${strPath.split('/').pop().padEnd(18)} is ${strKind}\n`
      + '  checked on the open descriptor, not by name: a name can be swapped between\n'
      + '  the check and the read, and only a regular file returns the same bytes to\n'
      + '  this process and to npm.\n');
    process.exit(objRefusal.exit);
  }
  if (objRefusal.holdable) {
    // Codex P2 on 57ec78c, bound to the descriptor this time. nlink and uid are
    // read from the OPEN fd whose bytes are about to be returned, not from a
    // by-name lstat a swap can outrun. A second hard link, or another owner, is a
    // write path the quiescence sweep cannot see -- it compares this inode, and a
    // rewrite through the other path lands on this inode -- so npm could be fed
    // different bytes between the snapshot and the final re-read while the two
    // byte-equality reads still compare equal. Group/other write bits grant the
    // same capability to a non-owner even when uid and nlink look private.
    // intUid is computed here, not
    // borrowed from a scope it does not belong to -- the borrowed reference in
    // the first cut of this class died with ReferenceError on every run.
    const intUid = typeof process.getuid === 'function' ? process.getuid() : null;
    const strWhy = (objStats.nlink > 1)
      ? `is hard-linked ${objStats.nlink} times, so a second path can rewrite these bytes`
      : (intUid !== null && objStats.uid !== intUid)
        ? `is owned by uid ${objStats.uid}, but this recorder runs as uid ${intUid}`
        : nonOwnerWriteReason(objStats);
    if (strWhy !== null) {
      closeDescriptorOnce();
      process.stderr.write(
        `supply-freeze: refusing to record digests for a ${objRefusal.what} that `
        + 'the recording user does not solely control.\n'
        + `  ${strPath.split('/').pop().padEnd(18)} ${strWhy}\n`
        + '  checked on the open descriptor whose bytes are returned. The compared\n'
        + '  hashes must come from bytes only this run can hold stable; an alternate\n'
        + '  path, owner, or non-owner write grant lets npm read other bytes between\n'
        + '  the snapshot and the final read.\n');
      process.exit(objRefusal.exit);
    }
  }
  let bufContents;
  try {
    bufContents = readFileSync(intFd);
  } catch (objError) {
    refuseDescriptorFailure(objError);
  }
  const objCloseError = closeDescriptorOnce();
  if (objCloseError !== null) {
    fnOnMissing(objCloseError);
    process.exit(intMissingExit);
  }
  return bufContents;
}

function readOrRefuse(strPath, objRefusal = { exit: 15, what: 'manifest', holdable: true }) {
  return readViaVerifiedDescriptor(strPath, 3, (objError) => {
    process.stderr.write(
      'supply-freeze: a recorded input could not be re-read; refusing to report.\n' +
      formatErrorLocation(objError, strPath) +
      '  it was readable when this run began, so it changed underneath the record.\n');
  }, objRefusal);
}

// Round 56, reported by Codex. Locates the npm INSTALLATION that backs the
// executable the PATH prepend will resolve, and refuses rather than guessing.
//
// A Node distribution puts npm at lib/node_modules/npm and links bin/npm into
// it, so the installation is found relative to this Node -- never by asking npm
// where it lives, which would be taking the word of the program under suspicion.
// The link is resolved and required to land inside that directory: a fold of a
// genuine tree proves nothing if some other file is what actually executes, and
// that gap is this same finding one level in.
function npmInstallationRootOrRefuse() {
  const strRoot = join(dirname(process.execPath), '..', 'lib', 'node_modules', 'npm');
  let strRealRoot;
  let strRealNpm;
  try {
    strRealRoot = realpathSync(strRoot);
    strRealNpm = realpathSync(join(dirname(process.execPath), 'npm'));
  } catch (objError) {
    process.stderr.write(
      'supply-freeze: refusing to run an npm whose installation cannot be located.\n' +
      `  node               ${formatUntrustedText(process.execPath)}\n` +
      `  expected npm at    ${formatUntrustedText(strRoot)}\n` +
      formatErrorLocation(objError, strRoot) +
      '  a Node distribution keeps npm at lib/node_modules/npm and links bin/npm into\n' +
      '  it. Without that layout there is nothing to verify the executable against,\n' +
      '  and its own --version output is not evidence about itself.\n' +
      // Reported by Codex. This check runs before the version/platform gate that
      // --any-toolchain waives, so on Windows -- where npm sits beside node.exe,
      // not under lib/node_modules/npm -- a reader following the documented
      // --any-toolchain path met a bare "cannot locate npm" rather than the real
      // reason. The reason is scope, not a missing file: this recorder computes
      // only on the reviewed Unix distribution layout. A Windows install writes
      // .cmd/.ps1 shims where this POSIX fold records symlinks and folds modes
      // Windows does not carry, so its tree is not comparable to the reviewed one
      // whatever the flag. --any-toolchain relaxes which VERSIONS are acceptable,
      // never this layout, so the honest answer to a non-Unix platform is to say
      // so here rather than to half-discover npm and fold a tree that means nothing.
      (process.platform === 'win32'
        ? '  this is a non-Unix (Windows) layout: npm sits beside node.exe and bin\n' +
          '  entries are .cmd/.ps1 shims, not the symlinks this POSIX fold records, so\n' +
          '  the tree is not comparable to the reviewed one. --any-toolchain relaxes\n' +
          '  which versions are acceptable, never this Unix-layout requirement.\n'
        : ''));
    process.exit(2);
  }
  // Round 62, reported by Codex. Containment proved the CLI sits inside the
  // resolved root and said nothing about where that ROOT sits. With
  // lib/node_modules/npm a symlink to a writable external directory, the root
  // resolves outside the distribution -- so the ancestors folded below are that
  // external tree's, not this distribution's, and swapping the external parent
  // during the npm calls moves nothing the folds watch. Keeping bin/npm-cli.js
  // as a hardlink to the genuine leaf even satisfies the per-invocation inode
  // check while npm loads malicious siblings around it.
  //
  // The root must therefore be inside the distribution before containment means
  // anything, because every other check in this chain is relative to it.
  const strDistribution = dirname(dirname(realpathSync(process.execPath)));
  if (!isInsideOrEqual(strRealRoot, strDistribution)) {
    process.stderr.write(
      'supply-freeze: refusing an npm installation that resolves outside this Node distribution.\n' +
      `  node               ${formatUntrustedText(process.execPath)}\n` +
      `  distribution       ${formatUntrustedText(strDistribution)}\n` +
      `  npm resolves to    ${formatUntrustedText(strRealRoot)}\n` +
      '  the ancestors this script folds are the distribution\'s, so an installation\n' +
      '  reached through a link out of it is verified against the wrong directories --\n' +
      '  its real parents could be replaced without moving anything that is watched.\n');
    process.exit(2);
  }
  if (strRealNpm !== strRealRoot && !strRealNpm.startsWith(`${strRealRoot}/`)) {
    process.stderr.write(
      'supply-freeze: refusing to run an npm that is not part of this Node installation.\n' +
      `  node               ${formatUntrustedText(process.execPath)}\n` +
      `  npm resolves to    ${formatUntrustedText(strRealNpm)}\n` +
      `  installation is    ${formatUntrustedText(strRealRoot)}\n` +
      '  the executable that would answer is outside the tree this script can verify,\n' +
      '  so folding that tree would vouch for bytes that are not the ones running.\n');
    process.exit(2);
  }
  return { root: strRealRoot, cli: strRealNpm };
}

// Content and shape only, deliberately not modes. The reviewed digest has to
// hold for a tree extracted by CI's `tar -xJf` and for one laid down by a
// package manager, and the process umask reaches the first of those -- folding
// permission bits would turn an extraction detail into a refusal. What the
// attack substitutes is code, and code is content.
//
// Directory and symlink entries are folded by name so that adding a file, or
// replacing a real file with a link to one, cannot leave the digest unmoved.
// Round 58, reported by Codex, and both halves are omissions from the round-56
// and round-57 work rather than new surface.
//
// The ROOT INODE. The change fold recorded only entries reached by readdirSync,
// never strRoot itself. On POSIX a directory swap -- rename the genuine npm
// aside, put a hostile directory at the same path, restore afterwards -- moves
// the ROOT's ctime and leaves every descendant's untouched, so both digests
// returned to their starting values while the hostile npm had already answered
// every subprocess. The root is now the first record in the change fold.
//
// The LAUNCHER. `bin/npm` lives beside the distribution's bin/node, OUTSIDE
// lib/node_modules/npm, so folding the installation never saw it. Replacing that
// one symlink after the initial containment check is enough to answer every call
// and restore before the end. It is folded here so the launcher and the tree it
// points into are one authenticated object rather than two checks that can
// disagree about which interval they cover.
//
// Inode numbers accompany every change record for the same reason: ctime catches
// a write, ino catches a swap, and a rename-in/rename-out can move one without
// the other on some filesystems.
// Round 79, reported by Codex as a P3 against the check below, and the same
// defect at the ancestor walk one function down -- so it is fixed once, here,
// and used at both.
//
// Round 77 replaced a separator-less startsWith with `root + '/'`, which is
// correct for every root EXCEPT the filesystem root: for `/` it builds the
// prefix `//`, no absolute path starts with that, and a Node distribution laid
// out at the root (`/bin/node` with npm under `/lib/node_modules/npm`) refuses
// every descendant as outside itself. That check runs before the reviewed-version
// comparison and `--any-toolchain` does not reach it, so the false refusal is
// unconditional. Fixing a boundary bug by introducing a different boundary bug is
// exactly the churn this helper stops -- there is now ONE containment predicate.
const isInsideOrEqual = (strChild, strParent) => strChild === strParent
  || strChild.startsWith(strParent === '/' ? '/' : `${strParent}/`);

// Resolve one link component by component without ever accepting an excursion
// outside the folded root. A final realpath containment check is insufficient:
// `root/link -> /tmp/hop -> root/file` ends inside while an uncovered external
// pointer still decides which bytes load. The explicit walk establishes the
// boundary at every component; the kernel result is retained as an independent
// agreement check for cases the userspace resolver did not anticipate.
function classifyContainedSymlink(strRealRoot, strPath, strRelative) {
  const funcInside = (strCandidate) => isInsideOrEqual(strCandidate, strRealRoot);
  let boolLeavesTree = false;
  try {
    let strAt = strRealRoot;
    let arrPending = strRelative.split('/').filter((strPart) => strPart.length > 0);
    let intHops = 0;
    while (arrPending.length > 0) {
      const strPart = arrPending.shift();
      if (strPart === '.') continue;
      if (strPart === '..') {
        strAt = dirname(strAt);
        if (!funcInside(strAt)) { boolLeavesTree = true; break; }
        continue;
      }
      const strCandidate = strAt === '/' ? `/${strPart}` : `${strAt}/${strPart}`;
      if (!funcInside(strCandidate)) { boolLeavesTree = true; break; }
      const objComponent = lstatSync(strCandidate);
      if (objComponent.isSymbolicLink()) {
        intHops += 1;
        if (intHops > 40) {
          throw Object.assign(new Error('too many levels of symbolic links'), { code: 'ELOOP' });
        }
        const bufLink = readlinkSync(strCandidate, { encoding: 'buffer' });
        if (!Buffer.from(bufLink.toString('utf8'), 'utf8').equals(bufLink)) {
          throw Object.assign(new Error('link target is not valid UTF-8'), { code: 'EILSEQ' });
        }
        const strTarget = bufLink.toString('utf8');
        if (isAbsolute(strTarget)) strAt = '/';
        arrPending = strTarget.split('/').filter((strPart2) => strPart2.length > 0)
          .concat(arrPending);
        continue;
      }
      if (arrPending.length > 0 && !objComponent.isDirectory()) {
        throw Object.assign(new Error('not a directory'), { code: 'ENOTDIR' });
      }
      strAt = strCandidate;
    }
    if (!boolLeavesTree && !funcInside(strAt)) boolLeavesTree = true;
    if (!boolLeavesTree && realpathSync(strPath) !== strAt) {
      throw Object.assign(new Error('resolution disagreed with the kernel'), { code: 'EDIVERGE' });
    }
  } catch (objError) {
    return { status: 'unresolved', code: objError?.code ?? 'unknown' };
  }
  return { status: boolLeavesTree ? 'escaping' : 'contained' };
}

function foldNpmInstallation(strRoot, strLauncherPath) {
  const objHash = createHash('sha256');
  const objChangeHash = createHash('sha256');
  let intFiles = 0;
  let intSymlinks = 0;
  // Codex P2 on e6a517b. The installed-tree walker (refuseUnreviewedInodeMetadata)
  // and the descriptor-bound manifest read both refuse an entry a second path can
  // rewrite -- a regular file hard-linked elsewhere, or one owned by another uid --
  // because the quiescence sweep compares this inode and a write through the other
  // path lands on it between the snapshot and the final re-read. This npm-installation
  // fold read npm's own bytes with neither guard. The nlink guard is regular-file
  // only, matching the installed-tree walker: a directory's link count counts its
  // subdirectories and a symlink is not a byte source, so only a regular file's extra
  // link is a rewrite path. objStat comes from lstatSync(..., { bigint: true }), so
  // nlink, uid and mode are BigInt. Symlink mode is excluded because Linux reports
  // pseudo-permissions on links; their targets are constrained by the resolver.
  const refuseExternallyMutableNpmEntry = (strPath, strLabel, objStat, boolRegularFile) => {
    const bigOwnUid = typeof process.getuid === 'function' ? BigInt(process.getuid()) : null;
    const strWhy = (boolRegularFile && objStat.nlink > 1n)
      ? `is hard-linked ${objStat.nlink} times, so a second path can rewrite these bytes`
      : (bigOwnUid !== null && objStat.uid !== bigOwnUid)
        ? `is owned by uid ${objStat.uid}, but this recorder runs as uid ${bigOwnUid}`
        : (!objStat.isSymbolicLink() ? nonOwnerWriteReason(objStat) : null);
    if (strWhy === null) return;
    process.stderr.write(
      'supply-freeze: refusing an npm installation entry the recording user does not '
      + 'solely control.\n'
      + `  entry              ${formatUntrustedText(strLabel)}\n`
      + `  observed           ${strWhy}\n`
      + `  metadata           nlink ${objStat.nlink}, uid ${objStat.uid}, mode `
      + `${Number(objStat.mode & 0o7777n).toString(8).padStart(4, '0')}, recorder uid `
      + `${bigOwnUid === null ? '(unknown)' : bigOwnUid}\n`
      + '  the npmTree fold reads these bytes and the quiescence sweep compares this\n'
      + '  inode; a second hard link, another owner, or a non-owner write grant is a\n'
      + '  write path that sweep cannot exclude, so npm could be fed other bytes while\n'
      + '  the digest compares equal.\n');
    process.exit(2);
  };
  const considerRootOrLauncher = (strPath, strLabel, boolEnforceSoleControl = false) => {
    try {
      const objStat = lstatSync(strPath, { bigint: true });
      // Codex P2 on e6a517b: the installation root and the npm launcher are read by
      // this recorder as well, so refuse one a second path can rewrite before folding,
      // exactly as the walk refuses regular files below. Only the root and launcher
      // enforce this; the ancestor sweep reuses this helper for change detection and
      // passes boolEnforceSoleControl false, matching the foldAncestors note that a
      // distribution ancestor is a precondition, not bytes this fold reads. The root
      // is a directory and the launcher a symlink, so the regular-file nlink guard
      // does not apply to them; the uid guard does.
      if (boolEnforceSoleControl) {
        refuseExternallyMutableNpmEntry(strPath, strLabel, objStat, objStat.isFile());
      }
      hashField(objChangeHash, strLabel);
      hashField(objChangeHash, `${statIdentity(objStat)}:${objStat.mode}`);
      // The launcher's target is part of its identity: repointing a symlink
      // moves its ctime, but recording where it points makes the refusal say so
      // and covers a filesystem that does not.
      //
      // Reported by Copilot, and by Codex as the same defect one sibling over.
      // The target is read as RAW BYTES, not decoded text. readlinkSync without
      // an encoding decodes as UTF-8, and every byte sequence that is not valid
      // UTF-8 decodes to U+FFFD -- so the walk below was given a buffer in 80/D
      // for exactly this, and this considerRootOrLauncher read was missed. String
      // encoding here collapses two distinct launcher/ancestor targets to the same
      // change-hash input, so on a filesystem whose ctime does not move on a
      // repoint the swap this field exists to catch would go unrecorded. Measured:
      // raw targets 0x80 and 0x81 collide decoded (efbfbd == efbfbd) and stay
      // distinct as buffers (80 != 81).
      if (objStat.isSymbolicLink()) {
        hashField(objChangeHash, readlinkSync(strPath, { encoding: 'buffer' }));
      }
    } catch (objError) {
      process.stderr.write(
        'supply-freeze: refusing to verify an npm installation that cannot be read.\n' +
        formatErrorLocation(objError, strPath));
      process.exit(2);
    }
  };
  considerRootOrLauncher(strRoot, '(installation root)', true);
  if (strLauncherPath !== undefined) considerRootOrLauncher(strLauncherPath, '(npm launcher)', true);
  // Round 59, reported by Codex, and the round-58 fix caught one level up.
  //
  // Folding an inode says "this directory was not replaced". It says nothing
  // about the PATH used to reach it. Rename lib/node_modules aside, put a
  // hostile tree at that name, let npm answer every call, rename the original
  // back: the renamed parent's ctime moves, and the genuine npm root and every
  // descendant keep their inode and ctime exactly. Both folds match. Swapping
  // `bin` does the same to the launcher.
  //
  // So every directory on the way down is folded too, from the distribution
  // root to each authenticated leaf -- typically <dist>, <dist>/bin,
  // <dist>/lib and <dist>/lib/node_modules.
  //
  // It stops AT the distribution root deliberately. Above it the ancestors are
  // /tmp, /opt, / and so on, whose change times move for reasons that have
  // nothing to do with this record -- the same over-sensitivity the quiescence
  // sweep's round-36 note refused to take on, and an over-sensitive check that
  // refuses real runs is not a stricter check.
  //
  // Stopping here is a PRECONDITION, not a closed check, and an earlier revision
  // justified it wrongly (reported by Codex): it argued a caller able to rewrite
  // the directory CONTAINING the distribution could replace node itself, but
  // replacing node ON DISK does not replace the running process -- the
  // interpreter stays the authenticated one while an npm subprocess is
  // redirected, so that argument did not cover the interval it claimed to. What
  // actually holds is narrower: the distribution must live where it cannot be
  // renamed during the run (in CI a job-private extraction directory), and the
  // pre-invocation recheck of the npm command line's inode narrows the window to
  // the gap before exec without eliminating it. See docs/T1-SUPPLY-FREEZE-v1.md,
  // "What this script cannot check about itself".
  const strDistributionRoot = dirname(dirname(realpathSync(process.execPath)));
  const arrSeen = [];
  const foldAncestors = (strLeaf) => {
    let strCurrent = dirname(strLeaf);
    // Round 77, found by sweeping the CLASS of round 76's defect rather than
    // stopping at the instance. Two siblings of it lived here.
    //
    // The hop guard used to be `intHop < 64`, which on exhaustion fell out of
    // the loop and returned normally. Same shape as round 76: the walk runs
    // UPWARD, so the ancestors an exhausted cap drops are the ones NEAREST the
    // distribution root -- the outermost, most security-relevant end -- and it
    // dropped them without a word. It now throws, like considerThroughLinks and
    // like the node_modules ancestor walk.
    //
    // The boundary test used to be startsWith(strDistributionRoot) with no
    // separator, so `/usr/localX` tested as inside `/usr/local`. That is
    // over-inclusive rather than a hole -- it folds an unrelated sibling
    // directory into the toolchain digest and shows up as unexplained digest
    // churn -- but the file already had this right one function away, where the
    // node_modules boundary check spells it `!== root && !startsWith(root + '/')`.
    // Two boundary tests, same file, one correct. That divergence IS the defect.
    for (let intHop = 0; ; intHop += 1) {
      if (!isInsideOrEqual(strCurrent, strDistributionRoot)) return;
      if (intHop >= 64) {
        throw new Error('toolchain fold: ancestor chain exceeds 64 levels');
      }
      if (!arrSeen.includes(strCurrent)) {
        arrSeen.push(strCurrent);
        considerRootOrLauncher(strCurrent, `(ancestor) ${strCurrent.slice(strDistributionRoot.length) || '/'}`);
      }
      if (strCurrent === strDistributionRoot) return;
      const strParent = dirname(strCurrent);
      if (strParent === strCurrent) return;
      strCurrent = strParent;
    }
  };
  foldAncestors(strRoot);
  if (strLauncherPath !== undefined) foldAncestors(strLauncherPath);
  const walk = (strDirectory, strRelative) => {
    let arrNames;
    try {
      // Round 80/E, Codex. readdirSync's default decoding turns any name that is
      // not valid UTF-8 into U+FFFD, so with a sibling literally named U+FFFD two
      // distinct raw-byte entries both fold by reading the same decoy path twice.
      // Names are read as buffers and required to round-trip; anything that does
      // not is refused rather than folded, which is what the installed-tree fold
      // already does.
      const arrRaw = readdirSync(strDirectory, { encoding: 'buffer' });
      for (const bufName of arrRaw) {
        if (!Buffer.from(bufName.toString('utf8'), 'utf8').equals(bufName)) {
          process.stderr.write(
            'supply-freeze: refusing to verify an npm installation with a name that '
            + 'is not valid UTF-8.\n'
            + `  directory          ${formatUntrustedText(strDirectory)}\n`
            // Reported by Codex. The raw name is attacker-controlled and can carry
            // a username, path or token before the invalid byte; hex is trivially
            // reversible from a retained CI log, so it is withheld the same way the
            // root-link target refusal below withholds its target -- a length and a
            // digest prefix, which still tell two different bad names apart.
            + `  entry              ${bufName.length} bytes, sha256 `
            + `${createHash('sha256').update(bufName).digest('hex').slice(0, 16)} `
            + '(not valid UTF-8)\n'
            + '  the name cannot be folded distinctly from a sibling named U+FFFD, so\n'
            + '  two different installations could record the same npmTree digest.\n');
          process.exit(2);
        }
      }
      arrNames = arrRaw.map((bufName) => bufName.toString('utf8')).sort();
    } catch (objError) {
      process.stderr.write(
        'supply-freeze: refusing to verify an npm installation that cannot be read.\n' +
        formatErrorLocation(objError, strDirectory));
      process.exit(2);
    }
    for (const strName of arrNames) {
      const strPath = join(strDirectory, strName);
      const strKey = strRelative === '' ? strName : `${strRelative}/${strName}`;
      try {
        const objStat = lstatSync(strPath, { bigint: true });
        if (objStat.isDirectory()) {
          refuseExternallyMutableNpmEntry(strPath, strKey, objStat, false);
          hashField(objHash, 'd');
          hashField(objHash, strKey);
          walk(strPath, strKey);
        } else if (objStat.isSymbolicLink()) {
          intSymlinks += 1;
          hashField(objHash, 'l');
          hashField(objHash, strKey);
          // The npm subprocess follows this link, so its full resolution must be
          // decided only by entries this installation fold covers. This applies
          // under --any-toolchain too: that flag waives the reviewed digest, not
          // the promise that the two folds surround the same executing bytes.
          const objContainment = classifyContainedSymlink(strRoot, strPath, strKey);
          if (objContainment.status !== 'contained') {
            process.stderr.write(
              'supply-freeze: refusing to verify an npm installation whose link is '
              + 'not contained in the folded installation.\n'
              + `  entry              ${formatUntrustedText(strKey)}\n`
              + (objContainment.status === 'unresolved'
                ? `  resolution         could not be established (${objContainment.code})\n`
                : '  resolution         leaves the folded installation\n')
              + '  the link target is withheld because it can contain private path data.\n'
              + '  npm follows this link while answering recorder subprocesses, but the\n'
              + '  npmTree folds observe only entries inside this installation. An external\n'
              + '  hop could therefore change the answers without moving either fold.\n');
            process.exit(2);
          }
          // Round 80/D, Codex. The installed-tree fold reads link targets as
          // buffers; this sibling decoded them. Measured: targets 0x80 and 0x81
          // both decode to U+FFFD, so two npm installations produced the same
          // toolchain.npmTree while the record claims to identify the one that
          // answered.
          hashField(objHash, readlinkSync(strPath, { encoding: 'buffer' }));
        } else if (objStat.isFile()) {
          // Codex P2 on e6a517b: refuse an externally mutable regular file before
          // folding its bytes, the same guard the installed-tree walker and the
          // descriptor-bound manifest read apply. objStat is a bigint lstat.
          refuseExternallyMutableNpmEntry(strPath, strKey, objStat, true);
          intFiles += 1;
          hashField(objHash, 'f');
          hashField(objHash, strKey);
          hashField(objHash, sha256(readFileSync(strPath)));
        } else {
          // Round 80, reported by Codex as a P3. This branch folded a bare '?'
          // and the path, so a FIFO and a character device at the same path
          // produced the SAME toolchain.npmTree value while the record claims to
          // describe the npm installation that answered.
          //
          // This is round 9's finding C3 -- "special-file types collide in the ?
          // branch" -- fixed in the installed-tree fold and never applied here.
          // The corrected version sat thirty lines away for seventy rounds. Same
          // tags, same rdev, so the two folds now agree.
          const strSpecialTag = objStat.isFIFO() ? 'P'
            : objStat.isSocket() ? 'S'
              : objStat.isCharacterDevice() ? 'C'
                : objStat.isBlockDevice() ? 'B'
                  : '?';
          objHash.update(strSpecialTag, 'utf8');
          hashField(objHash, strKey);
          hashField(objHash, String(objStat.rdev));
        }
        // Round 57, and this half exists because the reply that shipped the
        // content fold argued its way out of it and was wrong.
        //
        // That argument was: a replacement restored before the end must be
        // restored byte-identically, so the npm that answered every call IS the
        // reviewed npm and nothing was forged. The second clause does not
        // follow from the first. The npm that ANSWERED was the replacement; only
        // the npm ON DISK AT THE END is the reviewed one, and the forged
        // configuration, lockfile assertion and advisory posture are already in
        // the record by then. Restoring bytes does not un-forge an answer that
        // was already given -- exactly the reasoning used one finding over for
        // .npmrc, applied there and then denied here.
        //
        // Content alone therefore catches only a replacement that PERSISTS.
        // Inode change times catch replace-and-restore, because both writes move
        // ctime and neither moves it back. Neither observable covers the other's
        // case, which is the same conclusion the .npmrc sweep reached, and the
        // two are folded separately so a mismatch says which one moved.
        hashField(objChangeHash, strKey);
        hashField(objChangeHash, statIdentity(objStat));
      } catch (objError) {
        process.stderr.write(
          'supply-freeze: refusing to verify an npm installation that changed while being read.\n' +
          formatErrorLocation(objError, strPath));
        process.exit(2);
      }
    }
  };
  walk(strRoot, '');
  return {
    sha256: objHash.digest('hex'),
    changeSha256: objChangeHash.digest('hex'),
    files: intFiles,
    symlinks: intSymlinks,
  };
}

// Round 31, reported. npm ships as `#!/usr/bin/env node`, so the runtime its
// subprocesses use is whatever `node` PATH resolves first -- NOT the Node running
// this file. A recorder launched as `/opt/reviewed/bin/node ./Get-...mjs` with a
// different node earlier on PATH reports the reviewed process.version while every
// config read, tree walk and audit runs under the other one. Demonstrated with a
// PATH shim: the shim was invoked by npm while the parent stayed on its own
// execPath, so `toolchain.node` described the parent alone.
//
// Binding by PATH rather than by exec'ing npm-cli.js directly, because npm is a
// symlink to a .js file here but a shell wrapper on other installs, and the
// wrapper case would silently keep the old behaviour. Putting this Node's own
// directory first makes `env node` resolve to it however npm is packaged.
//
// Round 60, reported by Codex twice over, and the round-31 reasoning above is
// what has to change rather than be extended.
//
// That comment chose PATH over exec'ing npm-cli.js "because npm is a symlink to
// a .js file here but a shell wrapper on other installs". True in general, and
// no longer relevant here: the installation is now pinned by digest, so the
// layout is not a guess -- bin/npm is known to resolve to a .js file inside
// lib/node_modules/npm, and that resolved path is what the fold authenticates.
//
// PATH resolution turned out to be attacker-influenceable in two separate ways:
//
//   a colon in the path. PATH is colon-SEPARATED, so prepending a directory
//   whose name contains ':' inserts two entries instead of one. A distribution
//   at /tmp/reviewed:copy/bin puts /tmp/reviewed first, and an attacker's
//   /tmp/reviewed/npm answers every call while the genuine
//   /tmp/reviewed:copy/bin/npm is the file both folds authenticate. A legal
//   POSIX path silently redirects the executable.
//
//   a different basename. npm's shebang is `#!/usr/bin/env node`, so the
//   prepend only binds the runtime if a file literally named `node` sits in
//   that directory. Invoke the reviewed binary as bin/node24 and `env node`
//   falls through to the ambient PATH, so the genuine npm CLI runs under an
//   attacker's runtime -- and both folds still pass, because the launcher and
//   the installation really are genuine.
//
// Both disappear if nothing is resolved by name. The child is now this
// process's OWN executable, running the resolved npm CLI by absolute path:
// no PATH lookup for the program, and no shebang to interpret, so the runtime
// is the same authenticated binary that is executing this line.
//
// The prepend is kept for npm's own internal lookups, and skipped when the
// directory contains a colon -- there it corrupts PATH rather than extending
// it, and with the direct invocation above it is no longer load-bearing.
function npmChildEnv(objEnv) {
  const objBase = objEnv ?? process.env;
  const strNodeDirectory = dirname(process.execPath);
  // Round 73, reported by Codex against the round-72 --workspaces=false fix. npm
  // also honours the SINGULAR `-w/--workspace <name>` selector, and --no-workspaces
  // (which is what --workspaces=false is) beside any `workspace` setting is a hard
  // npm error, "Can not use --no-workspaces and --workspace at the same time" -- so
  // an environment carrying NPM_CONFIG_WORKSPACE=foo refused before configDrift
  // could classify anything. Measured: the singular var alone already exits 1
  // (ENOWORKSPACES) in this non-workspace repo, with the forced flag it exits 1 on
  // the conflict, and env-setting workspaces=false collides the same way -- there
  // is no value that both silences the plural and tolerates the singular. Both
  // settings, both casings, are scrubbed from the child so the CLI --workspaces=false
  // has nothing to collide with. A plural setting sourced from a user/global .npmrc
  // is not in the environment and is still overridden by that flag; a singular one
  // from a file is exotic and surfaces npm's own conflict rather than a silent tree.
  const objScrubbed = {};
  for (const [strKey, strValue] of Object.entries(objBase)) {
    if (/^npm_config_workspaces?$/i.test(strKey)) continue;
    if (/^NODE_(?:OPTIONS|COMPILE_CACHE|V8_COVERAGE|REDIRECT_WARNINGS|DEBUG|DEBUG_NATIVE)$/i
      .test(strKey)) continue;
    objScrubbed[strKey] = strValue;
  }
  objScrubbed.NODE_DISABLE_COMPILE_CACHE = '1';
  if (strNodeDirectory.includes(delimiter)) return objScrubbed;
  objScrubbed.PATH = `${strNodeDirectory}${delimiter}${objBase.PATH ?? ''}`;
  return objScrubbed;
}

const NPM_DIAGNOSTIC_CATEGORIES = Object.freeze([
  ['warning', /(?:^|\r?\n)npm warn(?:ing)?(?:\s|$)/iu],
  ['notice', /(?:^|\r?\n)npm notice(?:\s|$)/iu],
  ['error', /(?:^|\r?\n)npm error(?:\s|$)/iu],
]);

function writeNpmDiagnosticSummary(strOperation, objResult) {
  const strStderr = typeof objResult.stderr === 'string' ? objResult.stderr : '';
  const arrCategories = NPM_DIAGNOSTIC_CATEGORIES
    .filter(([, objPattern]) => objPattern.test(strStderr))
    .map(([strCategory]) => strCategory);
  if (arrCategories.length === 0) arrCategories.push('other-output');
  process.stderr.write(
    'supply-freeze: npm diagnostic summary (child text withheld):\n' +
    `  operation          ${formatUntrustedText(String(strOperation))}\n` +
    `  native exit        ${Number.isInteger(objResult.status) ? objResult.status : 'none'}\n` +
    `  signal             ${objResult.signal == null ? 'none' : 'present'}\n` +
    `  stderr length      ${strStderr.length} characters\n` +
    `  categories         ${arrCategories.join(', ')}\n` +
    '  inspect npm logs only in the private external cache directory and treat their\n' +
    '  contents as sensitive; this public summary does not reproduce child output.\n');
}

function runNpm(arrNpmArguments, objEnv) {
  // Round 60. Re-checked before every invocation rather than only at the fold,
  // because the path is re-resolved by the operating system at exec time: an
  // ancestor renamed aside between the fold and this call would send the same
  // path string to a different file. This does not close that race -- nothing
  // inside the process can -- but it reduces the window from the whole run to
  // the gap between this stat and the exec.
  const intInodeNow = (() => {
    try { return lstatSync(strNpmCli, { bigint: true }).ino; } catch { return null; }
  })();
  if (intInodeNow !== intNpmCliInode) {
    process.stderr.write(
      'supply-freeze: the npm command line is no longer the file that was authenticated.\n' +
      `  npm cli            ${formatUntrustedText(strNpmCli)}\n` +
      `  authenticated      inode ${intNpmCliInode}\n` +
      `  resolves now to    ${intInodeNow === null ? 'nothing' : `inode ${intInodeNow}`}\n` +
      '  the path was redirected after the installation was folded, so the program\n' +
      '  about to answer is not the program this run verified.\n');
    process.exit(2);
  }
  try {
    // Codex P3 on 57ec78c. Every npm the script runs is pinned out of workspace
    // mode. In this non-workspace checkout `npm config list`, `config get`, `ls`
    // and `audit` all REFUSE with ENOWORKSPACES when the ambient environment or a
    // user/global .npmrc sets workspaces=true, so a correct checkout could not
    // produce a record. A command-line flag outranks every ambient source (env and
    // project/user/global .npmrc), and `workspaces` is not a reviewed config key --
    // it cannot shape a non-workspace install -- so forcing it false un-breaks the
    // CLI without hiding drift. Measured: config list/get went from exit 1
    // (ENOWORKSPACES) to 0 under ambient workspaces=true; --version, ls and audit
    // accept the flag. configDrift compares only reviewed keys, so the false it now
    // reports for `workspaces` in `config list --json` is never examined.
    const objResult = spawnSync(process.execPath,
      [strNpmCli, ...arrNpmArguments, '--workspaces=false',
        `--cache=${join(strExternalCacheDirectory, 'cache')}`,
        `--logs-dir=${join(strExternalCacheDirectory, 'logs')}`,
        '--timing=false', '--update-notifier=false'], {
      cwd: strWorkflowDirectory,
      env: npmChildEnv(objEnv),
      encoding: 'utf8',
      maxBuffer: 64 * 1024 * 1024,
      stdio: ['ignore', 'pipe', 'pipe'],
    });
    // Keep the existence and fixed category of warnings visible on success as
    // well as failure. Child text is never emitted: npm's own best-effort
    // redaction does not cover arbitrary configuration values or paths.
    if (objResult.stderr) {
      writeNpmDiagnosticSummary(arrNpmArguments[0], objResult);
    }
    objNpmProcessResults.push({ operation: arrNpmArguments[0], nativeExit: objResult.status,
      signal: objResult.signal, stderrLength: objResult.stderr?.length ?? 0 });
    if (objResult.error) throw objResult.error;
    if (objResult.status !== 0) {
      const objFailure = new Error('npm process returned a nonzero status or signal');
      Object.assign(objFailure, { status: objResult.status, signal: objResult.signal,
        stdout: objResult.stdout, stderr: objResult.stderr });
      throw objFailure;
    }
    return objResult.stdout;
  } catch (objError) {
    // Round 29, reported. When npm is absent from PATH, is not executable, or
    // dies before printing, execFileSync throws a spawn failure that nothing
    // caught: the run ended at exit 1 with a raw Node stack trace, in exactly
    // the case exit 2 exists to name. Measured on a PATH carrying node but not
    // npm -- a plausible reproduction environment -- the reader got a dump of
    // spawnargs instead of "unreviewed toolchain".
    //
    // Handled here rather than at the version probe that was reported, because
    // every npm invocation in this file has the same failure mode and fixing the
    // one that was demonstrated is the habit this script keeps being corrected
    // for. Spawn failures ONLY: a non-zero exit means npm ran and disagreed,
    // which is a different diagnosis, and `npm audit` returns 1 to report
    // advisories. Relabelling those as a toolchain problem would replace a stack
    // trace with a confident wrong answer, which is worse.
    if (typeof objError?.syscall === 'string' && objError.syscall.startsWith('spawnSync')) {
      process.stderr.write(
        'supply-freeze: refusing to record digests on an unreviewed toolchain.\n' +
        `  npm could not be run: ${formatUntrustedText(String(objError.code ?? objError.message))}\n` +
        // Round 47, reported by Codex, and this is round 45's sweep caught one
        // line below where it stopped. That round escaped the message above and
        // recorded this refusal as safe because it is "built from a constant
        // command name" -- true of the line above, and this line prints the
        // ARGUMENTS. The audit invocation carries `--registry=${strRegistry}`,
        // which under --any-toolchain is an unvalidated, possibly credentialed
        // value. Measured, with npm removed after `config get registry`:
        //
        //   invocation  npm audit --json --registry=https://user:hunter2@…?token=SUPPLYSECRET
        //
        // at exit 2, while npm's own error text on the adjacent path redacted
        // the same URL correctly. The invocation is kept rather than dropped --
        // knowing WHICH call failed is the whole diagnostic -- with every
        // argument through the funnel.
        `  invocation         npm ${arrNpmArguments.map((strArgument) => formatUntrustedText(strArgument)).join(' ')}\n` +
        `  reviewed npm       ${REVIEWED_NPM}\n` +
        '  the reviewed npm must be runnable before anything is recorded; its version\n' +
        '  is itself a compared field, so an npm that cannot report one cannot be\n' +
        '  confirmed as the reviewed toolchain.\n');
      process.exit(2);
    }
    throw objError;
  }
}

// Round 59, reported by Codex. runNpm classifies a SPAWN failure and rethrows
// everything else, which was deliberate -- a non-zero exit means npm ran and
// disagreed, and `npm audit` uses exit 1 to report advisories. But nothing
// caught that rethrow for the calls that MUST succeed, so an npm which starts
// and then exits non-zero ended the run at exit 1 with an uncaught stack trace,
// in the case the refusal table calls exit 2. Measured, with the user and global
// config pointed at one file:
//
//   NPM_CONFIG_USERCONFIG=/tmp/c NPM_CONFIG_GLOBALCONFIG=/tmp/c node Get-...mjs
//     -> node:internal/errors:985 ... Error: Command failed: npm --version
//        Exit prior to config file resolving
//        exit 1, where the record documents exit 2
//
// And npm's stderr reached the log unescaped, so a config path carrying a
// newline forges a line there -- the CWE-117 class this file funnels everything
// else through formatUntrustedText to avoid.
//
// A wrapper rather than a change to runNpm, because runNpmAllowingFailure needs
// the throw: the audit's exit 1 is data, not a failure. Every call that must
// succeed goes through here and names the refusal its own failure means, so a
// broken `ls` is still a tree problem and a broken `config` is still a
// configuration problem, rather than everything becoming "unreviewed toolchain".
function runNpmOrRefuse(arrNpmArguments, objEnv, intFailureExit, strMeaning) {
  try {
    return runNpm(arrNpmArguments, objEnv);
  } catch (objError) {
    process.stderr.write(
      `supply-freeze: ${strMeaning}\n` +
      `  invocation         npm ${arrNpmArguments.map((strArgument) => formatUntrustedText(strArgument)).join(' ')}\n` +
      `  npm exit status    ${formatUntrustedText(String(objError?.status ?? objError?.code ?? 'unknown'))}\n` +
      '  npm ran and refused the invocation, so the value this run needed was never\n' +
      '  produced; nothing is recorded from a call that did not answer.\n');
    process.exit(intFailureExit);
  }
}

// Round 60. npm writes its ls problems as `<kind>: <spec>, required by <x>`,
// and the round-59 redactor treats any RFC 3986 scheme token as the start of a
// URL -- so `extraneous:` reads as a scheme and the entire diagnostic is
// withheld. Measured, every line of a real refusal came back as
// `extraneous:/// (path, credentials and query redacted)`, which names nothing.
//
// That over-matching was a deliberate trade and it is still the right one; what
// was wrong is feeding this string to the funnel whole. The kind is a fixed
// lowercase vocabulary npm controls, so it is separated and checked rather than
// redacted, and everything after it -- the part that can carry a registry URL
// with credentials -- goes through the funnel unchanged.
const RE_LS_PROBLEM_KIND = /^([a-z]+): ([\s\S]*)$/u;
function formatLsProblem(strProblem) {
  const arrParts = RE_LS_PROBLEM_KIND.exec(strProblem);
  if (arrParts === null) return formatUntrustedText(strProblem);
  return `${arrParts[1]}: ${formatUntrustedText(arrParts[2])}`;
}

function runNpmAllowingFailure(arrNpmArguments, objEnv) {
  try {
    return runNpm(arrNpmArguments, objEnv);
  } catch (objError) {
    // `npm audit` uses exit 1 to mean "advisories found", not "command failed".
    if (objError.status === 1 && objError.signal === null
      && !objError.code && !objError.syscall
      && typeof objError.stdout === 'string' && objError.stdout.trim().startsWith('{')) {
      return objError.stdout;
    }
    // Valid-looking JSON cannot convert a terminated or failed command into a
    // complete observation. npm 11.16.0 documents only 0 and 1 audit outcomes.
    process.stderr.write('supply-freeze: npm audit failed outside the accepted native 0/1 outcomes; refusing.\n');
    process.exit(5);
  }
}

// The installed tree, folded from the bytes actually on disk.
//
// The first version of this script digested a normalized `npm ls --all --json`,
// because that is what the original record's field was named after. Attacking
// it before shipping showed the field would have been close to worthless:
// editing `node_modules/glob/package.json` to version 9.9.9 and re-running left
// the digest completely unchanged, because `npm ls` reports the resolved graph
// that the LOCKFILE determines, not the bytes present on disk. The lockfile's
// own SHA-256 is already a recorded field, so that digest restated an existing
// one while appearing to measure something new.
//
// This measures the stated intent instead -- what is actually installed, which
// is what actually runs. It is the same shape as the parser-tree fold the
// workflow policy already performs over node_modules/yaml, widened to the whole
// tree. Path and length are folded in alongside content so that renaming or
// truncating a file moves the digest, and symlink targets are folded in so a
// redirected `.bin` entry does too.
//
// Reproducibility is measured, not assumed: four independent `npm ci` installs
// in four different absolute paths produce identical digests, which also proves
// no machine-specific path leaks into the hashed bytes.
//
// Round 28, reported. This said "three" while the pull request said "four", and
// the reported fix was to write "multiple" so the two could not disagree. The
// count IS the evidence here, so the disagreement was settled by re-running the
// experiment rather than by deleting the number: four installs, in four paths of
// deliberately differing lengths, all folding to one value. Recorded as four
// because four were run and observed, not because the larger number was chosen.
//
// Round 49, reported by Codex. That sentence used to name the value, and the
// value went stale the moment directory read bits were folded in one round
// earlier -- leaving a reader two different expected results for one recipe, in
// a file whose whole argument is that a hand-copied digest rots while looking
// authoritative. The count is kept because the count is what this paragraph is
// evidence for; the digest is dropped rather than restated because THE CLAIM
// HERE IS AGREEMENT, not the particular number they agreed on. Four installs in
// four paths folding identically is what proves no path leaks into the hashed
// bytes, and that survives any change to the fold. The current value has exactly
// one home, and it is the record.
//
// Re-running the four installs under the new fold would have let the number stay,
// and it is not restated from a single run instead: this host has no registry
// access, so four independent `npm ci` installs cannot be performed here, and a
// number copied from one run would assert an agreement nobody measured.
//
// Every variable-length field is length-prefixed, and that is load-bearing
// rather than tidiness. Reported and confirmed: the first framing wrote
// `L <path> -> <target>\n`, which is not injective, because a POSIX path or
// symlink target may itself contain a newline. Two genuinely different trees
// hashed identically --
//
//   tree one:  a -> "T\nL b -> U",  c -> "V"
//   tree two:  a -> "T",            b -> "U\nL c -> V"
//
// both feed `L a -> T\nL b -> U\nL c -> V\n`. Measured, not argued: the two
// directories produced the same digest.
//
// The same defect was in the FILE framing and was not reported; carrying the
// finding across found it. `F <path>:<length>\n<content>` collides just as
// readily -- one file named `a:2\nXYF b` containing `ZW` hashes exactly like two
// files `a` and `b` containing `XY` and `ZW`. Also measured.
//
// Length-prefixing makes the encoding prefix-free: a reader takes the tag, then
// digits up to the separator, then exactly that many bytes, with no ambiguity
// about where a field ends. Directories are recorded too, so a stray empty one
// cannot hide in a tree whose files are all accounted for.
function hashField(objHash, objField) {
  const objBytes = Buffer.isBuffer(objField) ? objField : Buffer.from(objField, 'utf8');
  objHash.update(`${objBytes.length}:`, 'utf8');
  objHash.update(objBytes);
}

// Round 66, reported by Codex. The fold hashes `mode & 0o555` and the histogram
// records `mode & 0o777`, so three inode properties were invisible to every
// compared field: the OWNER, the hard-link count, and the setuid/setgid/sticky
// bits. A `4755` binary recorded as `755`; a package directory owned by another
// uid folded exactly like one owned by the recorder, and that owner can chmod
// and rewrite it after the final sweep whatever the mode bits say.
//
// Codex offered "include or refuse". These REFUSE rather than fold, and the
// reason is reproducibility: uid and gid are properties of the machine, not of
// the published bytes, so hashing them would make the tree digest differ between
// two hosts that installed identical packages -- destroying the cross-machine
// reproduction the whole record exists to provide. Refusing closes the same hole
// and moves no digest, so the frozen values stay valid.
//
// gid is deliberately NOT refused on. A differing gid is only exploitable when
// the group can also write, and group-write now refuses through the shared
// non-owner-write predicate. Refusing on gid as well would false-refuse every
// tree installed under a setgid directory, which inherits the parent's gid by
// design, without closing another write path.
//
// This is the containment rule the tree already applies to symlinks that leave
// it, one property over: an entry the recorder does not own, or that a second
// path can write through, is not contained by this tree.

// Round 74, reported by Codex against 4628 and its sibling reinstall snippets.
// Appended to every "reinstall with npm ci" refusal below. The bare command
// those print is correct in a clean environment but refuses under an ambient npm
// workspace setting -- NPM_CONFIG_WORKSPACES, or a `workspace`/`workspaces` line
// in a user/global .npmrc. Measured on npm 10.9.7 and reported on 11.16.0:
// `NPM_CONFIG_WORKSPACES=true npm ci` exits 1 "No workspaces found", and no
// single npm ci invocation is robust to every source -- `--workspaces=false`
// then collides with any singular `workspace` selector ("Can not use
// --no-workspaces and --workspace at the same time"), and dropping it re-exposes
// the plural case. So the hint keeps the terse command for the clean-environment
// common case and points at the recipe that clears the ambient settings, rather
// than reprinting a longer command that still fails one case. One constant, so
// the six sites cannot drift -- which is how they diverged from the doc's
// reproduction block, itself carrying `env -u ... --workspaces=false`, to begin
// with.
const strWorkspaceReinstallNote =
  '  (if npm refuses here with a workspace error, an ambient npm workspace\n' +
  '  setting is in play; the reproduction steps in docs/P1-SUPPLY-FREEZE-v1.md\n' +
  '  clear it.)\n';

function refuseUnreviewedInodeMetadata(strPath, strChild, objStats, strKind) {
  const intSpecialBits = objStats.mode & 0o7000;
  const intOwnUid = typeof process.getuid === 'function' ? process.getuid() : null;
  const strProblem = intSpecialBits !== 0
    ? `setuid/setgid/sticky bits set (${intSpecialBits.toString(8).padStart(4, '0')})`
    : (strKind === 'file' && objStats.nlink > 1)
      ? `hard-linked ${objStats.nlink} times, so a second path can rewrite these bytes`
      : (intOwnUid !== null && objStats.uid !== intOwnUid)
        ? `owned by uid ${objStats.uid}, but this recorder runs as uid ${intOwnUid}`
        : nonOwnerWriteReason(objStats);
  if (strProblem === null) return;
  process.stderr.write(
    'supply-freeze: refusing to record a tree entry the recorder does not solely control.\n' +
    `  entry              ${formatUntrustedText(strChild)}\n` +
    `  kind               ${strKind}\n` +
    `  observed           ${strProblem}\n` +
    '  the digest records permissions and bytes, but a snapshot of those values does\n' +
    '  not keep them stable: another owner, a non-owner write grant, or a second hard\n' +
    '  link can rewrite the inode after the final sweep, and a setuid bit does not\n' +
    '  appear in a 0o777 histogram at all.\n' +
    '  reinstall the tree as the recording user with the documented command:\n' +
    '    npm ci --ignore-scripts --no-audit --no-fund\n' +
    strWorkspaceReinstallNote);
  process.exit(14);
}

// Round 48, reported by Codex, and it is a hiding place rather than a collision
// in the recorded value. POSIX filenames are bytes; `readdirSync` decodes them as
// UTF-8, and every byte sequence that is not valid UTF-8 decodes to U+FFFD. Two
// entries in one directory therefore share a decoded name whenever one has an
// undecodable name and the other is literally named U+FFFD -- and `join` then
// resolves BOTH loop iterations to the second file.
//
// Measured, with a directory holding one entry named 0x80 and one named
// 0xEF 0xBF 0xBD (U+FFFD's own encoding):
//
//   readdir decoded names   ["�", "�"]   -- equal
//   readdir raw names       80 , efbfbd            -- distinct
//   mutating the 0x80 file  digest 4ec884fe... -> 4ec884fe...   (unmoved)
//   mutating the other file digest 4ec884fe... -> d3335220...   (moved)
//
// So the 0x80 file's bytes were never read: the count said 2179 while one file
// was hashed twice and another not at all. The ctime sweep is blind for the same
// reason -- it decodes names the same way, so both entries collapse to one label
// and it lstats the same file twice -- which is why the run above completed and
// reported a tree it had not measured. A file whose content never reaches the
// digest is content an attacker may choose freely.
//
// REFUSED rather than folded as raw bytes. Both were offered; the deciding factor
// is that this cannot turn away a legitimate artifact. `npm ci` from the reviewed
// lockfile produces no such name -- the reviewed tree folds byte-identically with
// this check in place -- so the refusal fires only for a tree this script has just
// proven it cannot measure. Folding raw bytes would let it RECORD such a tree,
// which is a capability this record does not need and would buy by threading
// Buffers through the symlink, special-file and label paths of the one function
// least safe to rewrite for a case npm does not produce.
//
// The check is the round trip, not a search for U+FFFD: a name that decodes and
// re-encodes to its own bytes is unambiguous, so a file legitimately named U+FFFD
// still folds. Only the names that LOSE information are refused.
//
// Used by both walkers. The fold is the site that was reported; the quiescence
// sweep enumerates the same tree with the same decode, and rounds 36 and 37 are
// this file's record of what fixing only the reported site costs.
function readdirOrRefuseUndecodable(strDirectory, strRelative) {
  return readdirSync(strDirectory, { withFileTypes: true, encoding: 'buffer' }).map((objEntry) => {
    const strName = objEntry.name.toString('utf8');
    if (!Buffer.from(strName, 'utf8').equals(objEntry.name)) {
      process.stderr.write(
        'supply-freeze: refusing to fold a tree with an undecodable entry name.\n' +
        `  directory          node_modules${strRelative ? `/${formatUntrustedText(strRelative)}` : ''}\n` +
        // Reported by Codex. The entry name is attacker-controlled and can carry a
        // secret before the invalid byte (e.g. token_SUPPLYSECRET_<byte>); a full
        // hex dump is trivially reversible from a retained CI log. Withheld the
        // same way the root-link target refusal withholds its target -- a length
        // and a digest prefix, which still distinguish two different bad names.
        `  entry              ${objEntry.name.length} byte`
          + `${objEntry.name.length === 1 ? '' : 's'}, sha256 `
          + `${createHash('sha256').update(objEntry.name).digest('hex').slice(0, 16)} `
          + '(not valid UTF-8)\n' +
        '  such a name decodes to U+FFFD, so a sibling named U+FFFD shares it and both\n' +
        '  resolve to one file -- the other file is never read and never reaches the\n' +
        '  digest, which would report a tree it did not measure.\n' +
        '  npm ci from the reviewed lockfile does not produce such a name; reinstall\n' +
        '  with the documented command:\n' +
        '    npm ci --ignore-scripts --no-audit --no-fund\n' +
        strWorkspaceReinstallNote);
      process.exit(12);
    }
    // A faithful stand-in for the Dirent: the walkers use the name and the three
    // type predicates and nothing else, and the predicates are delegated rather
    // than recomputed so a DT_UNKNOWN hint still answers false to all three and
    // still falls through to the lstat below.
    return {
      name: strName,
      isFile: () => objEntry.isFile(),
      isDirectory: () => objEntry.isDirectory(),
      isSymbolicLink: () => objEntry.isSymbolicLink(),
    };
  });
}

// Round 79/C, reported by Codex and reproduced. Extracted from foldInstalledTree
// so the SAME refusal can run before the baseline quiescence scan. It used to run
// only inside the fold, which happens AFTER that scan, so the baseline followed an
// external node_modules symlink and walked the target first:
//
//   node_modules -> quiet external dir -> exit 7  (boundary refusal won the race)
//   node_modules -> /proc              -> exit 10, EACCES at node_modules/1/fdinfo
//
// Which refusal fired depended on whether the external tree happened to walk
// cleanly, so the documented exit 7 was not guaranteed and an arbitrarily large or
// volatile external tree was traversed on the way to rejecting it. One function,
// called at both sites, keeps the two from drifting the way the boundary tests did.
function refuseEscapingTreeRoot(strRoot) {
  // Round 80, reported by Codex as a P2 and reproduced. The endpoint-only
  // realpathSync check below accepts a chain that LEAVES the boundary and comes
  // back -- node_modules -> /tmp/ext/mid -> <workflow>/real-tree -- because the
  // final target is inside. Measured on the fixture: direct in-boundary link
  // exit 0, direct external link exit 7, leave-and-return chain exit 0.
  //
  // The external hop is recorded, but its PARENT is not, and that parent can be
  // renamed aside while npm ls and npm audit run, then restored before the second
  // fold. Both folds then describe the original in-boundary tree while npm
  // answered from a different one.
  //
  // Every hop is therefore tested, not just the endpoint -- the same rule the
  // round-42 component walk already applies to package symlinks. A chain is only
  // as trustworthy as the weakest parent along it.
  {
    let strHop = strRoot;
    for (let intHop = 0; ; intHop += 1) {
      let objHopStats;
      try { objHopStats = lstatSync(strHop); } catch { break; }
      if (!objHopStats.isSymbolicLink()) break;
      // Round 81, reported by Codex as a P3 and reproduced. The hop cap is tested
      // AFTER the target's type, the way considerThroughLinks does it -- not
      // before. The pre-fix order threw at intHop === 40 on the loop's next turn,
      // BEFORE lstat inspected the final non-link target, so a chain of exactly 40
      // hops to an in-boundary directory refused at exit 10 -- one hop short of the
      // limit the throw message itself names ("exceeds 40 hops" is 41+, not 40).
      // 40 is Linux MAXSYMLINKS: the kernel resolves 40 links and returns ELOOP on
      // the 41st, so this now refuses at the same length the kernel does. Measured
      // on real chains -- pre-fix N=40 threw while N=39 accepted; post-fix N=40
      // accepts and N=41 throws, matching considerThroughLinks, the component walk
      // and the ancestor-depth cap, which the same sweep confirmed already accept
      // 40 and refuse 41.
      if (intHop >= 40) {
        throw new Error('node_modules root: symlink chain exceeds 40 hops');
      }
      // Raw bytes, then a round-trip check. Codex P2 on a756ebe: readlinkSync's
      // default decoding turns any target that is not valid UTF-8 into U+FFFD, so
      // a chain like `node_modules -> bad_<0x80> -> /tmp/ext/mid -> <workflow>/tree`
      // with a decoy `bad_<U+FFFD>` INSIDE the workflow made this loop inspect the
      // decoy and never see the external hop -- reproduced at exit 0 where the
      // invariant is an unconditional exit 7.
      //
      // The component walk added in 198eb02 does not help: the decoy is inside the
      // boundary, so containment passes on the wrong link entirely.
      //
      // Refusing is chosen over carrying Buffer paths through the loop. An
      // undecodable target in the node_modules root chain is pathological, and a
      // containment claim that cannot be stated in the same bytes the kernel uses
      // is a claim this recorder should not make.
      const bufTarget = readlinkSync(strHop, { encoding: 'buffer' });
      if (!Buffer.from(bufTarget.toString('utf8'), 'utf8').equals(bufTarget)) {
        process.stderr.write(
          'supply-freeze: refusing to record digests for a node_modules link whose '
          + 'target is not valid UTF-8.\n'
          + `  hop                ${intHop + 1} (path withheld: on hops after the\n`
          + '                     first it is built from a target the tree author\n'
          + '                     chose, so printing it leaks the same bytes the\n'
          + '                     target redaction below withholds)\n'
          + `  target             ${bufTarget.length} bytes, sha256 `
          + `${createHash('sha256').update(bufTarget).digest('hex').slice(0, 16)}\n`
          + '  the target cannot be distinguished from a sibling named U+FFFD, so\n'
          + '  containment cannot be decided on the bytes the kernel would use.\n');
        process.exit(7);
      }
      const strTarget = bufTarget.toString('utf8');
      // resolve(), not a bare isAbsolute() branch. Reported by Codex as a P2
      // against the per-hop rule added one commit earlier, and reproduced: the
      // relative branch went through join(), which normalizes `..`, while the
      // absolute branch passed the raw target straight to the containment test.
      // So `${workflow}/../extmid/mid` tested as INSIDE the workflow directory on
      // a plain string prefix, then resolved to an external hop that linked back
      // inside. Measured on the fixture: exit 0 accepted, where the same chain
      // without `..` refuses at exit 7. The guard I added to catch chains that
      // leave and return was itself bypassable by three characters.
      // AN ACTUAL COMPONENT WALK. Codex asked for this three times; I reached for a
      // shortcut three times, and each shortcut was reproduced as a bypass:
      //
      //   resolve()                   -> symlinked components invisible   (198eb02)
      //   realpathSync(dirname(raw))  -> join() collapsed `..` LEXICALLY  (1a75c44)
      //
      // The second is subtle and worth stating precisely, because Codex attributed it
      // to realpathSync: path.join('<workflow>', 'in/../xcase') returns
      // '<workflow>/xcase' BEFORE realpathSync is called, so realpath is handed a
      // decoy path and never encounters `in` at all. Measured at exit 0 with an
      // in-workflow decoy `xcase` and `in` pointing outside.
      //
      // strAt is ALWAYS a resolved real path, so `..` applies to the real position --
      // which is exactly what the kernel does. The FINAL component is left
      // unresolved; the loop's next iteration is what follows it.
      const arrParts = strTarget.split('/').filter((strPart) => strPart.length > 0);
      let strNext;
      try {
        // EVERY intermediate position is checked, not just the endpoint. Codex P2 on
        // 4c4529b -- the fourth defect in this one class, and the third in a fix of
        // mine. The walk was correct about WHERE the chain ends and blind to where it
        // GOES: `node_modules -> ../../esc/back/nm`, with the external `esc/back`
        // symlinked back under the workflow, resolved to an in-boundary endpoint while
        // traversing an unswept external directory. Measured at exit 0.
        //
        // A boundary that is only tested at the destination is not a boundary. `..`
        // moves and resolved intermediates are each tested as they happen, so a chain
        // that leaves is refused at the step that leaves it.
        let strAt = isAbsolute(strTarget) ? '/' : realpathSync(dirname(strHop));
        // Inside the boundary OR an ancestor of it. "Always inside" is WRONG and was
        // measured wrong: an absolute target starts the walk at `/`, so every ancestor
        // (`/`, `/tmp`, ...) tripped the check and four in-boundary controls that must
        // return 0 returned 7. Any absolute path must traverse its own ancestors; what
        // must never happen is stepping SIDEWAYS out of the tree -- to a directory that
        // is neither the workflow, nor within it, nor on the path to it. Ancestors are
        // already swept by the ancestor sweep; `esc` in the repro is not.
        const funcAncestor = (strWhere) => strWorkflowDirectory === strWhere
          || strWorkflowDirectory.startsWith(`${strWhere === '/' ? '' : strWhere}/`);
        const funcStep = (strWhere) => {
          if (!isInsideOrEqual(strWhere, strWorkflowDirectory) && !funcAncestor(strWhere)) {
            process.stderr.write(
              'supply-freeze: refusing to record digests for a node_modules link that '
              + 'leaves the watched boundary.\n'
              + `  hop                ${intHop + 1}\n`
              + '  an intermediate component of the chain resolves outside the workflow\n'
              + '  directory. The endpoint may return inside, but the directories the\n'
              + '  chain passes through are not swept and can be swapped while npm runs.\n');
            process.exit(7);
          }
        };
        if (arrParts.length === 0) { strNext = strAt; }
        for (let intPart = 0; intPart < arrParts.length; intPart += 1) {
          const strPart = arrParts[intPart];
          if (strPart === '.') { continue; }
          if (strPart === '..') { strAt = dirname(strAt); funcStep(strAt); continue; }
          const strCand = join(strAt, strPart);
          if (intPart === arrParts.length - 1) { strNext = strCand; break; }
          strAt = realpathSync(strCand);
          funcStep(strAt);
        }
        if (strNext === undefined) { strNext = strAt; }
      } catch (objError) {
        process.stderr.write(
          'supply-freeze: refusing to record digests for a node_modules link whose '
          + 'path cannot be resolved.\n'
          // Reported by Codex, the same target-withhold class as the undecodable
          // refusal above. objError.path and strHop are built from a target the
          // tree author chose -- on every hop the failing component comes from that
          // target -- and formatErrorLocation would print them through
          // formatUntrustedText, which withholds only URL-shaped credentials, so a
          // plain `/.../SECRET_token/link` would reach the retained log. Only the
          // hop number and the errno, neither attacker-derived, are reported.
          + `  hop                ${intHop + 1}\n`
          + `  error              ${formatUntrustedText(String(objError?.code ?? 'unknown'))}\n`
          + '  every component of a root link must resolve, or containment cannot be\n'
          + '  decided.\n');
        process.exit(7);
      }
      if (!isInsideOrEqual(strNext, strWorkflowDirectory)) {
        process.stderr.write(
          'supply-freeze: refusing a node_modules symlink chain that leaves the '
          + 'watched boundary.\n'
          + `  node_modules       ${formatUntrustedText(strRoot)}\n`
          + `  hop ${intHop + 1} resolves outside ${formatUntrustedText(strWorkflowDirectory)}\n`
          + '  the chain may return inside the boundary, but a hop outside it has a\n'
          + '  parent nothing watches: that parent can be renamed aside, a different\n'
          + '  tree put in its place for npm ls and npm audit, and the original\n'
          + '  restored before the final sweep. Both folds would then describe a tree\n'
          + '  npm never read.\n'
          + '  point every hop of node_modules inside the workflow directory, or make\n'
          + '  it a real directory.\n');
        process.exit(7);
      }
      strHop = strNext;
    }
  }
  const strResolvedRoot = realpathSync(strRoot);
  if (strResolvedRoot !== strWorkflowDirectory
    && !strResolvedRoot.startsWith(`${strWorkflowDirectory}/`)) {
    process.stderr.write(
      'supply-freeze: refusing a node_modules symlink that leaves the watched boundary.\n' +
      `  node_modules       ${formatUntrustedText(strRoot)}\n` +
      // The resolved target is attacker-supplyable, so it is formatted rather
      // than interpolated raw -- the same rule the escaping-link refusal was
      // given in round 39.
      `  resolves outside   ${formatUntrustedText(strWorkflowDirectory)}\n` +
      '  the sweep follows this link and watches its target, but nothing watches\n' +
      '  the directories ABOVE that target. One of them can be renamed aside, a\n' +
      '  different tree put in its place for npm ls and npm audit, and the original\n' +
      '  restored before the final sweep -- the link and the target inode still\n' +
      '  compare equal, while the recorded answers came from bytes never folded.\n' +
      '  --any-toolchain does not waive this: it is a self-consistency check, not a\n' +
      '  comparison against a reviewed constant.\n' +
      '  point node_modules at a directory inside the workflow directory, or make\n' +
      '  it a real directory.\n');
    process.exit(7);
  }
  return strResolvedRoot;
}

function foldInstalledTree(strRoot) {
  const objHash = createHash('sha256');
  let intFiles = 0;
  let intSymbolicLinks = 0;
  let intDirectories = 0;
  let intSpecials = 0;
  const arrSpecialPaths = [];
  // Round 38. Collected rather than thrown so the refusal can name every
  // escaping link at once, matching how special files are reported.
  const arrEscapingLinks = [];
  // Round 39. Links whose resolution FAILED, which is a different diagnosis from
  // a link that resolved somewhere it should not have and is reported separately
  // so the two do not read as one problem.
  const arrUnresolvedLinks = [];
  const strRealRoot = realpathSync(strRoot);
  // Round 4 backstop, corrected in round 5. The umask guard reads the RECORDING
  // process, so it cannot see a tree installed under a different umask in an
  // earlier shell. The tree's own permission bits are the tell that survives.
  //
  // Round 5, reported: the first version of this counted GROUP-READABLE files,
  // which distinguishes umask 077 (no group read) from 022 and nothing else.
  // umask 027 clears 0o027, leaving group read set -- 0o644 becomes 0o640 and
  // 0o755 becomes 0o750, both still group-readable. Measured: a tree installed
  // under 027 and recorded under 022 moved the digest to 62eddc28... while the
  // census still reported the recorded 2177 of 2177. A backstop blind to one of
  // the umasks the guard explicitly rejects is not a backstop.
  //
  // A histogram over the full permission bits distinguishes every umask, because
  // it records the bits themselves rather than a predicate over them:
  //   umask 022 -> {"644":2157,"755":20}
  //   umask 027 -> {"640":2157,"750":20}
  //   umask 077 -> {"600":2157,"700":20}
  // Recorded, not enforced, and deliberately NOT folded into the digest: the
  // full mode is machine state, and pinning it would reintroduce exactly the
  // drift the execute-bit normalization exists to avoid.
  const objModeHistogram = new Map();
  // Directories are counted separately rather than folded into the histogram
  // above. Merging them would turn the recorded {"644":2157,"755":20} into a
  // shape where files and directories are indistinguishable, which is a worse
  // diagnostic than either alone.
  const objDirectoryModeHistogram = new Map();
  const walk = (strDirectory, strRelative) => {
    const arrEntries = [...readdirOrRefuseUndecodable(strDirectory, strRelative)]
      .sort((objLeft, objRight) => (objLeft.name < objRight.name ? -1 : objLeft.name > objRight.name ? 1 : 0));
    for (const objEntryHint of arrEntries) {
      const strPath = join(strDirectory, objEntryHint.name);
      const strChild = strRelative ? `${strRelative}/${objEntryHint.name}` : objEntryHint.name;
      // Round 8, reported. `readdir` may answer DT_UNKNOWN for an entry -- some
      // NFS and FUSE mounts do -- and a Dirent carrying that hint returns false
      // from isFile(), isDirectory() AND isSymbolicLink() alike. Every such
      // entry would fall through to the `?` branch below, which records a tag
      // and a path and NOTHING else: no content, no target, and no recursion
      // into a directory's children. A tree on such a filesystem would fold to
      // a digest that silently omits most of it while still reporting
      // freezeRecord: true.
      //
      // lstatSync answers from the inode rather than the directory hint, and
      // Stats exposes the same predicates as Dirent, so it substitutes cleanly.
      // It must be lstat rather than stat: stat would follow symlinks and
      // reclassify each of the 8 `.bin` entries as the file it points at.
      //
      // Only consulted when the hint is inconclusive, so the common path costs
      // nothing. Not reproducible here -- every filesystem on this host reports
      // real types, checked across /proc, /sys, /dev, /run and /tmp -- so the
      // trigger is taken from the readdir contract while the consequence is
      // measured: an entry that answers false to both predicates does take the
      // content-free `?` branch.
      const objEntry = (objEntryHint.isFile() || objEntryHint.isDirectory() || objEntryHint.isSymbolicLink())
        ? objEntryHint
        : lstatSync(strPath);
      if (objEntry.isSymbolicLink()) {
        intSymbolicLinks += 1;
        objHash.update('L', 'utf8');
        hashField(objHash, strChild);
        // Round 3, reported. readlinkSync's default string encoding decodes the
        // target as UTF-8, and a POSIX target is arbitrary bytes. Two distinct
        // targets therefore collided: raw 0x80 and raw 0x81 both decode to the
        // single replacement character U+FFFD and hashed identically -- measured
        // on ext4. Requesting a Buffer hashes the bytes the kernel actually
        // stored, which is what "injective" has to mean here.
        hashField(objHash, readlinkSync(strPath, { encoding: 'buffer' }));
        // Round 38, reported by Codex. A link whose target lies OUTSIDE the tree
        // names bytes this fold never reads, and hashing the target text does
        // not cover them. Measured: with node_modules/eastasianwidth replaced by
        // a link to an external directory holding a minimal
        // {"name","version","main"} manifest, `npm ls --all` exits 0,
        // treeSatisfiesLockfile comes back TRUE so the exit-7 refusal never
        // fires, the script records a digest at exit 0 -- and rewriting the code
        // behind that link afterwards leaves the digest byte-identical. A
        // reviewed run would have emitted freezeRecord: true over a tree whose
        // executing code was outside the record and free to change.
        //
        // Only OUT-OF-TREE targets are refused, and that boundary is the whole
        // of the reasoning. A link pointing back inside node_modules names bytes
        // this walk already folds at their real location, so editing them does
        // move the digest -- covered, and refusing it would be a false failure
        // on the eight .bin shims a normal install creates. It is what the link
        // reaches that matters, not that it is a link.
        //
        // Containment is tested against the RESOLVED root, so a legitimately
        // symlinked node_modules root does not read as an escape.
        //
        // Round 41 corrected the sentence that stood here. It claimed "a chain
        // that leaves the tree in two hops is caught", and that was false: it was
        // caught only if it ENDED outside. Codex refuted it, and the measurement
        // is below. Writing the claim down is what stopped it being checked.
        //
        // Round 39, reported by Codex. The previous version swallowed a failed
        // resolution on the claim that "the quiescence sweep refuses it as a
        // changed input". That claim was false, and the sentence writing it down
        // is what made it look answered: the sweep lstat()s tree entries, and
        // lstat reports the LINK's own inode, so a target that appears and
        // disappears outside the tree never moves anything the sweep reads.
        //
        // Measured, with node_modules/eastasianwidth/vendor-helper.js pointing at
        // an absent external path:
        //   record run  (target absent)  -> exit 0, digest aa1d1b71c280, 0 refusals
        //   build window (target present) -> the external file loads via require
        //   verify run  (target absent)  -> exit 0, digest aa1d1b71c280
        // `npm ls` reported the lockfile satisfied throughout, because the link
        // is nested rather than a top-level package. Both a recording run and a
        // verifying run agree at exit 0 while the code that actually loaded came
        // from outside the digest.
        //
        // So a failed resolution refuses. Not only ENOENT: when resolution fails
        // for ANY reason this fold cannot establish containment, and containment
        // is the entire claim this guard makes. Refusing an unproven claim is the
        // conservative reading, and it is the reading that does not have to be
        // revisited when a new errno shows up.
        // Round 41, reported by Codex. EVERY HOP is tested for containment, not
        // just the endpoint. realpathSync collapses the whole chain, so a link
        // that leaves the tree and comes back read as contained:
        //
        //   node_modules/eastasianwidth/zchain.js -> /tmp/mid41 -> <in-tree file>
        //
        // Measured on this tree, repointing /tmp/mid41 between two runs while the
        // link's own text stayed `/tmp/mid41` throughout:
        //   /tmp/mid41 -> eastasianwidth.js  exit 0, 0 refusals, 7480241947adfc1c
        //   /tmp/mid41 -> README.md          exit 0, 0 refusals, 7480241947adfc1c
        //
        // Both endpoints are already folded, so both sets of bytes are inside the
        // digest. What is NOT inside it is WHICH of them `zchain.js` selects, and
        // that selector is an out-of-tree pointer anyone can repoint between the
        // recording run and the build that loads through it. Two runs emit the
        // same successful freeze record over different executing code -- the
        // exact failure the round-38 endpoint check exists to stop. An
        // intermediate hop simply walks around it.
        //
        // The rule enforced is: RESOLUTION NEVER LEAVES THE TREE. Every component
        // the walk passes through -- not merely the symlinks, not merely the
        // endpoint -- must be inside the real root.
        //
        // Round 42 replaced a narrower rule with that one, reported by Codex.
        // Round 41 required only that every symlink FOLLOWED live inside the
        // tree, which still admitted:
        //
        //   zg.js -> /tmp/control42/../../<abs path back into node_modules>
        //
        // Measured: the kernel resolves and reads it, and the guard accepted it
        // at exit 0 with zero refusals. /tmp/control42 is an ordinary directory,
        // so round 41 never tested it -- but its TYPE is not covered by the
        // digest either. Replacing it with a symlink to /tmp/evil after recording
        // sends the `..` somewhere else entirely, and the link text, and so the
        // digest, never move. An out-of-tree component is uncovered whatever it
        // happens to be today.
        //
        // A useful consequence: an absolute target now fails at its first
        // component, because an absolute path starts at "/" and works inward.
        // That refuses absolute links without a separate rule for them, and it
        // closes the reproducibility gap round 41 recorded but did not fix --
        // an absolute target folds a machine-specific string.
        //
        // That is the precise invariant, and it took two wrong versions. The
        // fold pins a link by hashing its target TEXT, so the mapping from that
        // text to bytes has to be decided entirely by things the digest covers --
        // that is, by entries inside the tree. Any symlink OUTSIDE the tree that
        // the resolution passes through is a pointer the record does not cover
        // and an attacker can repoint afterwards.
        //
        // The first attempt walked hop by hop and called realpathSync() on each
        // hop's parent before testing it. That silently resolved the outside hop
        // instead of catching it, and it accepted:
        //
        //   zparent.js -> /tmp/outdir41/back/README.md   (/tmp/outdir41/back
        //                                                 being a symlink back
        //                                                 into node_modules)
        //
        // which is the same defect one directory level up: repointing
        // /tmp/outdir41/back changes which in-tree file loads. The comment there
        // asserted that case was covered. It was not, and only running it said
        // so -- the assertion is what stopped it being checked, exactly as with
        // the two-hop sentence this round corrected.
        //
        // Walking COMPONENTS rather than hops fixes it, because the thing that
        // must be tested is where each symlink SITS, not where it points. The
        // walk starts at the resolved root instead of at "/" so that the tree's
        // own ancestors -- /home may legitimately be a symlink -- are never
        // themselves candidates for refusal.
        //
        // 40 is Linux MAXSYMLINKS. Past it the kernel returns ELOOP and so does
        // this walk, which routes to the unresolved-link refusal rather than to a
        // silent accept -- an unprovable containment claim is refused, per R39.
        const objContainment = classifyContainedSymlink(strRealRoot, strPath, strChild);
        if (objContainment.status === 'unresolved') {
          // errno codes are a closed OS-defined set, so naming the code is safe
          // in a way that naming the target is not.
          arrUnresolvedLinks.push({
            path: formatUntrustedText(strChild), code: objContainment.code,
          });
          continue;
        }
        if (objContainment.status === 'escaping') {
          // Round 39, reported by Codex. The resolved target is NOT retained.
          // It is chosen by whoever wrote the link, unbounded in length, and
          // can carry a username, internal layout or a path-borne token into a
          // CI log that outlives the run. The in-tree name is what an operator
          // needs to act; `ls -l` on the tree answers "where did it point".
          //
          // Dropped at the point of COLLECTION rather than at the point of
          // printing, which is the part that matters: rounds 35 through 38 were
          // each a leak of a value that some earlier round had redacted at one
          // print site while leaving it live in a variable. A value that was
          // never stored cannot be printed by a later edit.
          //
          // Round 41 applies the same reasoning to the name's own BYTES, which
          // this round showed were attacker-chosen too.
          arrEscapingLinks.push({ path: formatUntrustedText(strChild) });
        }
        continue;
      }
      if (objEntry.isDirectory()) {
        // Round 11, reported and confirmed. This branch used to fold the tag
        // and the path and nothing else, so a directory's permission bits were
        // invisible to the digest AND to the census. Measured on
        // node_modules/glob: 0755 -> 0745 -> 0700 left the digest at
        // 4cdc37a7... and the counts at 2177/8/336 throughout.
        //
        // That is not cosmetic. A directory's execute bit is its traverse
        // permission, so clearing it for group or other makes everything
        // beneath unreachable for those classes while the packages themselves
        // are byte-perfect -- the same "a tree that cannot run is not the tree
        // this record claims to have measured" argument that put execute bits
        // on files in round 2, one entry kind over.
        //
        // Round 48, reported by Codex, and it is round 12 arriving at the entry
        // kind round 11 had just added. This comment used to say "normalized
        // execute bits, matching the file branch" -- but the file branch stopped
        // being execute-only in round 12, when READ was folded in because a file
        // a class cannot read is a file that class cannot load. The sentence
        // claimed to match a branch it no longer matched, and the mask was the
        // one round 12 had already rejected.
        //
        // For a directory the two bits are different powers: `x` is traverse to a
        // KNOWN name, `r` is permission to LIST. Measured on node_modules/glob,
        // 0755 -> 0711: the digest stayed at 16f42788... and every compared field
        // with it, while only the directory-mode histogram moved -- and that was
        // marked non-compared in the record AT THE TIME, so a reviewed run still
        // emitted the freeze. (The histograms became compared fields later, when a
        // write-granting POSIX ACL was measured landing on exactly the 0644 -> 0664
        // delta their exemption had called harmless. This mask fix stands on its
        // own regardless -- a directory's own bits belong in the digest.)
        // Measured on the consequence, as a non-owner: readdir on that
        // directory is EACCES while reading a known path through it still
        // succeeds. So the tree stays loadable by exact path and stops being
        // ENUMERABLE, which is what every glob-based package discovery does.
        //
        // `mode & 0o555` -- read and execute, the same mask as files, for the
        // same "can each permission class still use this" property. Write bits
        // stay out for the reason they do on files. This MOVES the frozen tree
        // digest, because 0755 masks to 555 where it used to mask to 111; the
        // record's tree row was re-taken in the same commit and the reasoning is
        // recorded there.
        intDirectories += 1;
        const objDirectoryStats = lstatSync(strPath);
        refuseUnreviewedInodeMetadata(strPath, strChild, objDirectoryStats, 'directory');
        const intDirectoryMode = objDirectoryStats.mode;
        objDirectoryModeHistogram.set(
          (intDirectoryMode & 0o777).toString(8).padStart(3, '0'),
          (objDirectoryModeHistogram.get((intDirectoryMode & 0o777).toString(8).padStart(3, '0')) ?? 0) + 1);
        objHash.update('D', 'utf8');
        hashField(objHash, strChild);
        hashField(objHash, (intDirectoryMode & 0o555).toString(8).padStart(3, '0'));
        walk(strPath, strChild);
        continue;
      }
      if (!objEntry.isFile()) {
        // A socket, device or FIFO under node_modules is not something an
        // install produces. Recorded rather than skipped so it cannot hide.
        //
        // Round 9, reported by Copilot and confirmed WIDER than reported. The
        // branch used to fold a bare '?' tag and the path, so every special
        // entry at a given path hashed identically. Copilot said two different
        // TYPES would collide; measured, five distinct filesystem objects at
        // one path all folded identically -- FIFO, Unix socket, character
        // device (1,3), character device (1,5) and block device (7,0). The two
        // character devices differ only in minor number, which is the
        // /dev/null-versus-/dev/zero distinction, so the collision was not even
        // limited to type. The census was blind to all five: 2177/8/336 in
        // every case, identical to a tree with no special entry at all.
        //
        // The type tag and the device number are folded so the encoding is
        // injective here too. `rdev` lives on Stats and not on Dirent, so this
        // takes an lstat -- charged only to entries that reach this branch,
        // which in a real install is none of them.
        //
        // Folding this correctly matters independently of the exit-11 refusal
        // below, because --any-toolchain waives that refusal and still runs the
        // fold. A digest whose injectivity depends on a guard is not injective
        // in exactly the runs where nothing else is checking.
        //
        // Round 48, swept rather than reported. This said the bypass "bypasses
        // every guard" -- the same overclaim round 47 corrected in the record's
        // Consumers section, left standing here because that round fixed the
        // sentence it was shown rather than the claim. It does not: unsupported
        // arguments, a missing or non-walkable root, malformed audit output, an
        // undecodable entry name and integrity-during-run failures all still
        // refuse. What is true is the narrow thing this argument actually needs
        // -- the exit-11 refusal is waived and the fold still runs.
        intSpecials += 1;
        // Round 64, reported by Codex, and the round-63 sweep for this exact
        // class returned the wrong answer. That round routed formatErrorLocation
        // through the funnel and reported the remaining formatTreeName callers
        // as "two tree-name renderers that print entry names already covered by
        // the exit-12 UTF-8 refusal". Both halves were false. There were FOUR
        // such callers, not two; and exit 12 refuses a name that is not valid
        // UTF-8, which says nothing about a name that is perfectly valid UTF-8
        // AND shaped like a credentialed url. Reproduced end to end on the
        // reviewed toolchain, with a FIFO planted inside a package so npm ls
        // still passes and exit 11 is actually reached:
        //
        //   supply-freeze: refusing to record digests for a tree containing
        //   special files.
        //     special entries    1 (expected 0)
        //       node_modules/glob/https:_user:SECRET@host?token=X
        //
        // Every one of the four sites now takes formatUntrustedText, which falls
        // back to formatTreeName when it finds no url -- so an ordinary package
        // path renders exactly as before and only a credential-shaped name is
        // withheld. The operator keeps the diagnostic in every case that is not
        // an attack.
        arrSpecialPaths.push(formatUntrustedText(strChild));
        const objSpecial = lstatSync(strPath);
        const strTag = objSpecial.isFIFO() ? 'P'
          : objSpecial.isSocket() ? 'S'
          : objSpecial.isCharacterDevice() ? 'C'
          : objSpecial.isBlockDevice() ? 'B'
          : '?';
        objHash.update(strTag, 'utf8');
        hashField(objHash, strChild);
        hashField(objHash, String(objSpecial.rdev));
        continue;
      }
      // Round 2, reported. The fold hashed path and content and ignored the
      // mode entirely, so `chmod -x` on a package binary left the digest
      // byte-identical while breaking the CLI with EACCES -- measured, the
      // digest did not move at all. A tree that cannot run is not the tree
      // this record claims to have measured.
      //
      // The NORMALIZED execute bits rather than the full mode. node-tar applies
      // the process umask when it extracts, so the read and write bits are a
      // property of the extracting machine; recording the full mode would make
      // the digest drift for a reason that has nothing to do with the package.
      //
      // Round 4 correction, and it matters because the original reasoning here
      // was wrong. This comment used to claim the execute bits "survive the
      // umasks that occur in practice: 0o755 under umask 077 is still 0o700,
      // still executable by its owner." The file does remain executable, but
      // the RECORDED VALUE moves -- 0o111 becomes 0o100 -- so the mask is no
      // more umask-portable than the full mode was, only less obviously so.
      // The umask is therefore pinned and checked; see REVIEWED_UMASK.
      //
      // Round 3, reported. An earlier version collapsed all three execute
      // classes to a single boolean, which meant 0o755 and 0o655 hashed
      // identically. That is not a harmless normalization: POSIX consults only
      // the OWNER bits when the process euid owns the file, so 0o655 is not
      // executable by the user who installed it. Measured with an owner-matched
      // process -- a 0o655 file owned by that user gives "Permission denied"
      // while group and other still carry +x. All three classes are recorded.
      //
      // Round 12, reported and confirmed. This folded `mode & 0o111` alone, so
      // READ permission was invisible: measured, 0644 -> 0600 on an installed
      // .js file left the digest byte-identical. The owner running the recorder
      // can still read it and `npm ls` still passes, but a group or other user
      // can no longer load that module -- and the histogram that does move was
      // an explicitly non-compared diagnostic AT THE TIME, so every compared
      // field stayed equal and a reviewed run would emit freezeRecord: true for
      // a tree those users cannot use.
      //
      // `mode & 0o555` is read AND execute, which together are exactly the
      // "can each permission class still load this" property. Write bits stay
      // out of the DIGEST deliberately: they do not affect loadability.
      //
      // They are no longer outside the RECORD, and the reason is the POSIX ACL
      // finding. An ACL granting write to a named user widens the ACL mask, and
      // per acl(5) the mask IS what st_mode's group bits report -- so
      // `setfacl -m u:someone:rw-` on a 0644 file reads back 0664 with the bytes
      // and this fold untouched. Measured, writing system.posix_acl_access
      // directly: deny and read-grant move nothing, write-grant moves only the
      // histogram, execute-grant moves this fold too. The histograms are
      // therefore compared fields now; the old exemption called 0644 -> 0664
      // "harmless machine state" when it is the signature of a frozen tree
      // becoming writable by someone the record never accounted for.
      //
      // The umask being pinned and checked is what makes all of this stable:
      // under the reviewed umask the tree is uniformly 644/755 with no
      // group-write bucket, so comparing the histogram cannot false-refuse.
      intFiles += 1;
      const objFileStats = lstatSync(strPath);
      refuseUnreviewedInodeMetadata(strPath, strChild, objFileStats, 'file');
      const intMode = objFileStats.mode;
      const strPermissions = (intMode & 0o777).toString(8).padStart(3, '0');
      objModeHistogram.set(strPermissions, (objModeHistogram.get(strPermissions) ?? 0) + 1);
      objHash.update('F', 'utf8');
      hashField(objHash, strChild);
      hashField(objHash, (intMode & 0o555).toString(8).padStart(3, '0'));
      hashField(objHash, readFileSync(strPath));
    }
  };
  // The root itself, which the walk above never sees because it starts inside
  // it. Reported in the same round as the directory bits and for the same
  // reason: clearing traverse permission on `node_modules` locks every class
  // out of the entire tree at once, and that was the one directory the fold
  // could never have noticed. Tagged distinctly from a child directory so the
  // record for the root cannot be confused with an entry named after it.
  // It is reported as its own field rather than folded into the directory
  // histogram, so that histogram keeps summing to `directories` -- a census
  // whose total does not match the count beside it is a diagnostic that costs
  // the reader time to reconcile.
  const objRootStats = lstatSync(strRoot);
  // Round 67, reported by Codex, and the round-66 metadata refusal stopping one
  // inode short. Every directory and file INSIDE the tree was checked for a
  // foreign owner, a second hard link and special mode bits; `node_modules`
  // itself was only mode-hashed. The root is the entry whose owner matters most,
  // because whoever owns a directory can replace the top-level package entries
  // within it after the final sweep -- the exact capability the child checks
  // exist to refuse, left open on the one directory that contains all of them.
  //
  // Round 75, reported by Codex, and the paragraph above is the defect. It read:
  // "Applied only when lstat says this is a real directory. A symlinked root is a
  // different case with its own refusal and its own bypass behaviour above, and
  // folding an ownership check into that path would change which of the two
  // refusals a reader sees for an unchanged condition." That reasoning protected
  // the tidiness of the diagnostics and left the check off the directory the fold
  // actually traverses.
  //
  // Measured, and the pair of controls is what makes it readable. With only the
  // TOP directory chowned to uid 65534 (chowning the children instead proves
  // nothing -- the per-entry checks catch those and the refusal is theirs):
  //
  //   real node_modules, root-only foreign uid       -> exit 14, "owned by uid 65534"
  //   symlink to that SAME directory, same ownership -> exit 0, record emitted
  //   symlink, target and children all uid 0         -> exit 0   (control)
  //
  // Same inode, same owner, different answer purely because lstat saw a link. The
  // capability left open is the one this refusal exists to deny: whoever owns the
  // traversed directory can replace top-level package entries after the final
  // sweep, and no compared field records that uid.
  if (objRootStats.isDirectory()) {
    refuseUnreviewedInodeMetadata(strRoot, 'node_modules', objRootStats, 'directory');
  } else if (objRootStats.isSymbolicLink()) {
    // The stat -- not the lstat -- is the directory `walk` traverses, and it is
    // already consulted a few lines below for the root mode, for exactly this
    // reason (round 24). The metadata check was the one thing still reading the
    // link instead of the target.
    //
    // The escape refusal is the second half, and it is the sibling finding: the
    // quiescence sweep follows the link and watches the TARGET, but not the
    // target's parent. Measured -- perturbing the target's parent mid-run exits
    // 0 while perturbing the project directory (control) and the target itself
    // both exit 10 -- so that parent can be renamed aside, repointed for npm ls
    // and npm audit, and restored before the final sweep, with the link and the
    // original target still comparing equal.
    //
    // Sweeping an arbitrary external ancestor chain is NOT the fix, and this file
    // already says why one guard over, where the manifest rule chose to refuse:
    // it "would mean walking an unbounded chain outside the checkout, where
    // ctimes move for unrelated reasons", so refusing "keeps the input boundary a
    // set this script can actually prove". A target inside the workflow directory
    // has a chain that terminates in the swept set and IS provable; one outside
    // does not. So the boundary decides, rather than the symlink.
    const strResolvedRoot = refuseEscapingTreeRoot(strRoot);
    refuseUnreviewedInodeMetadata(
      strResolvedRoot, 'node_modules (symlink target)', statSync(strRoot), 'directory');
  }
  // Round 24, reported and measured. The mode folded here came from lstat, which
  // for a symlinked root describes the LINK -- 0777 on Linux, always -- and never
  // the directory `walk` actually traverses. With node_modules symlinked to a real
  // tree under --any-toolchain, flipping the target from 0755 to 0700, which locks
  // every other user out of the entire tree, left the digest, the counts, and both
  // histograms byte-identical at 59799ca3...
  //
  // stat follows, so the traversed directory is the one measured. For a root that
  // is a real directory lstat and stat agree and the frozen digest does not move.
  // Neither call can throw: boolRootWalkable already refused, before this runs and
  // regardless of --any-toolchain, any root stat cannot resolve to a directory.
  const intRootMode = statSync(strRoot).mode;
  objHash.update('R', 'utf8');
  // Round 48, same report and same mask as the directory branch above, applied
  // here because the root is a directory too and this is the one whose loss is
  // total: `node_modules` at 0711 stops every class but the owner from listing
  // ANY package, which is the whole tree at once rather than one package. Folded
  // through the same `0o555` for the same reason. Fixed at both sites in one
  // change rather than at the branch that happened to be quoted -- the mask
  // appeared in exactly these two places, and rounds 36 and 37 are this file's
  // record of what fixing only the reported site costs.
  hashField(objHash, (intRootMode & 0o555).toString(8).padStart(3, '0'));
  // Round 12, reported. lstat sees the root itself, but only its execute mask
  // was folded -- and a 0755 directory and a 0777 symlink both mask to 111, so
  // a `node_modules` that is a SYMLINK to a byte-identical tree elsewhere folded
  // to exactly the same digest and counts as the real thing. `walk` then follows
  // the link, so the redirect controlling where all installed code loads from
  // was the one thing the fold ignored. Measured: identical digest either way.
  //
  // The reporter added that `npm ls --all --json` exits 0 with a symlinked root,
  // which would let a full record be emitted. That did NOT reproduce here -- on
  // npm 10.9.7 it exits non-zero for both a relative symlink and an absolute one
  // to an external tree, so refusal 7 already fires. The fold is fixed anyway:
  // --any-toolchain bypasses that guard and still folds, and an incidental
  // protection that depends on npm's version is not one to rely on.
  //
  // Folded only when the root is NOT a directory, so the reviewed layout's
  // digest is unaffected. `R` is followed by a length prefix, which begins with
  // a digit, and `K` by a letter, so the two cannot be confused.
  const boolRootIsDirectory = objRootStats.isDirectory();
  if (!boolRootIsDirectory) {
    objHash.update('K', 'utf8');
    hashField(objHash, objRootStats.isSymbolicLink() ? 'L' : '?');
    if (objRootStats.isSymbolicLink()) {
      hashField(objHash, readlinkSync(strRoot, { encoding: 'buffer' }));
    }
  }
  walk(strRoot, '');
  const sortHistogram = (objMap) => Object.fromEntries([...objMap.entries()].sort(
    (objLeft, objRight) => (objLeft[0] < objRight[0] ? -1 : 1)));
  return {
    sha256: objHash.digest('hex'),
    files: intFiles,
    symlinks: intSymbolicLinks,
    directories: intDirectories,
    specials: intSpecials,
    specialPaths: arrSpecialPaths,
    escapingLinks: arrEscapingLinks,
    unresolvedLinks: arrUnresolvedLinks,
    modes: sortHistogram(objModeHistogram),
    directoryModes: sortHistogram(objDirectoryModeHistogram),
    rootMode: (intRootMode & 0o777).toString(8).padStart(3, '0'),
    rootIsDirectory: boolRootIsDirectory,
  };
}

// The newest inode-change time anywhere under the tree, with the path carrying
// it. Stat-only: no file is read, so this costs a fraction of a content fold.
//
// Round 9, reported by Codex and confirmed by construction. The two content
// folds detect a write that lands BETWEEN their two reads of the same entry.
// They cannot detect a write that lands after the SECOND fold has already read
// that entry, because nothing reads it again -- both folds then agree on bytes
// that are already stale. Measured with the second fold paused just after it
// read `.package-lock.json`: writing to that file gave exit 0, no exit-10
// refusal, and the then-recorded digest reported for a tree whose file
// was 64829 bytes at emission against the 64794 bytes actually hashed.
//
// This sweep tests a different predicate -- "was anything under this tree
// touched during the recording window" rather than "did two reads agree" -- and
// it catches that case precisely because it runs after the write.
//
// ctime rather than mtime, and that choice is load-bearing. `utimes` sets atime
// and mtime to any value a caller likes, so mtime is forgeable; the same call
// moves ctime FORWARD to the moment of the forgery. Measured: a write moved
// ctime, and the utimes attempt to restore the timestamps moved it again.
//
// This narrows the window; it does not make a userspace walk atomic, and
// nothing in this script can. See the comment at its use.
// Round 11: the manifests are swept too. They live one directory ABOVE
// node_modules, so the round-9 sweep did not reach them -- which is exactly the
// gap the manifest recheck below was reported for.
function newestChangeTime(strRoot, arrExtraPaths) {
  let intNewest = 0;
  let strNewestPath = '';
  // Round 42, reported by Codex. Every swept entry's change time is retained,
  // not just the maximum over them. See the comparison for why the maximum was
  // not safe.
  const objEntryChangeTimes = new Map();
  // Round 67, reported by Codex. This recorded ctimeMs alone, so an entry
  // replaced within a single filesystem timestamp tick compared EQUAL to its
  // baseline while the path resolved to a different inode. My round-66 reply
  // declined exactly this hardening and said a swap that moves neither change
  // time would be a live finding; timestamp granularity is that swap, and this
  // is me taking the option I declined. The precedent was already in this file:
  // the npm-installation fold has hashed inode-and-change-time since round 56 for
  // this reason, so the sweep was the weaker of two checks against one attack.
  // Round 71 widened both to `${ino}:${ctimeNs}` from a bigint stat -- see
  // statIdentity for why the number-typed version was lossy.
  const consider = (strPath, strLabel) => {
    const objStats = lstatSync(strPath, { bigint: true });
    objEntryChangeTimes.set(strLabel, statIdentity(objStats));
    // Deliberately back to a Number for the "newest" tracking alone. That value
    // is returned as `ctimeMs` and consumed by callers that do Number things
    // with it; widening the identity comparison is not a licence to change a
    // type two call sites away.
    const intChangedAt = Number(objStats.ctimeMs);
    if (intChangedAt > intNewest) {
      intNewest = intChangedAt;
      strNewestPath = strLabel;
    }
    return objStats;
  };
  // Round 57, reported by Codex. A path that is allowed not to exist, recorded
  // as -1 when it does not. The sweep comparison already distinguishes a moved
  // change time from an entry appearing or disappearing, and -1 makes all four
  // transitions fall out of the same equality test: absent-to-absent matches,
  // while absent-to-present, present-to-absent and rewritten-in-place all
  // differ. Throwing on a missing optional path would refuse every ordinary run
  // instead, since this repository ships no .npmrc.
  const considerOptional = (strPath, strLabel) => {
    // Round 62 made this follow the link chain, because npm reads the project
    // config THROUGH a symlink and sweeping only the link missed a target that
    // was created, consumed by the audit and restored.
    //
    // Round 63, reported by Codex twice over, and following the link turned out
    // to be the wrong fix rather than an incomplete one. Two holes remained, and
    // neither is reachable by sweeping harder:
    //
    //   The target's PARENT still decides which file npm opens. With .npmrc a
    //   link to <external>/dir/npmrc, `dir` can be renamed aside, replaced by a
    //   directory holding a hostile npmrc for the audit, and restored. The link,
    //   the original target inode and the workflow directory all keep their
    //   change times. Measured, both sweeps agreed while npm consumed
    //   "registry=https://evil".
    //
    //   A DANGLING link collapsed to the same state as an absent file. Hop 0
    //   recorded the link, hop 1 threw ENOENT, and this handler then OVERWROTE
    //   the entry with -1 -- so a link to a path that does not exist yet swept
    //   identically to no file at all. The target could be created for the audit
    //   and removed before the final sweep. Measured: absent, before and after
    //   all three recorded {".npmrc":-1} while npm read the injected config.
    //
    // Sweeping the target's ancestors would close the first and not the second,
    // and would pull arbitrary external directories into the sweep -- the
    // over-sensitivity the round-36 comment below rejects for good reason.
    //
    // So the SHAPE is refused instead. This repository ships no .npmrc, npm's
    // project config is a plain per-directory file, and nothing legitimate here
    // needs that path to be a link, a FIFO or a directory. Refusing a
    // non-regular .npmrc closes both holes outright and takes the whole class
    // with them, rather than answering the two mechanisms that were reported.
    // A regular file has no link chain, no external ancestors and no dangling
    // state, so what remains is exactly the round-57 rewrite-in-place case this
    // sweep already handles.
    let objLinkStats;
    try {
      objLinkStats = lstatSync(strPath);
    } catch (objError) {
      if (objError?.code !== 'ENOENT') throw objError;
      objEntryChangeTimes.set(strLabel, -1);
      return;
    }
    if (!objLinkStats.isFile()) {
      const strKind = objLinkStats.isSymbolicLink() ? 'symbolic link'
        : objLinkStats.isDirectory() ? 'directory'
          : objLinkStats.isFIFO() ? 'FIFO'
            : objLinkStats.isSocket() ? 'socket'
              : objLinkStats.isCharacterDevice() ? 'character device'
                : objLinkStats.isBlockDevice() ? 'block device'
                  : 'not a regular file';
      process.stderr.write(
        'supply-freeze: refusing a project npm configuration that is not a regular file.\n' +
        `  path               ${formatUntrustedText(strPath)}\n` +
        `  observed           ${strKind}\n` +
        '  npm reads this as a configuration source, and only a regular file can be held\n' +
        '  still across the run: a link is opened through a target whose own parent can be\n' +
        '  swapped mid-run, and a link that does not resolve is indistinguishable from no\n' +
        '  file at all while its target can still be created for the audit and removed.\n' +
        '  remove the entry, or make it a regular file.\n');
      process.exit(13);
    }
    // Codex P2 on e6a517b. The non-regular refusal above closes the link/FIFO/
    // directory shapes; a REGULAR-file .npmrc still recorded only inode and ctime
    // through `consider`, so a second hard link or a foreign owner -- a write path
    // the change sweep cannot see, because it compares this inode and a rewrite
    // through the other path lands on it -- went unrefused. Apply the descriptor-
    // bound guard the manifests use (readViaVerifiedDescriptor): open once with
    // O_NOFOLLOW, fstat the descriptor, and refuse a file the recording user does not solely control,
    // bound to that descriptor so a name swap between the lstat above and this check
    // cannot outrun it. npm reads this as a configuration source, so the bytes must
    // be ones only this run can vouch for -- the same property the manifest read
    // requires. The existing non-regular refusal is unchanged.
    let intFd;
    try {
      intFd = openSync(strPath,
        fsConstants.O_RDONLY | fsConstants.O_NONBLOCK | fsConstants.O_NOFOLLOW);
    } catch (objError) {
      // A symlink (ELOOP), FIFO or vanished target appearing between the lstat above
      // and this open is the swap the descriptor bind exists to refuse: it is no
      // longer the regular file just classified. Refuse it as a non-regular .npmrc.
      process.stderr.write(
        'supply-freeze: refusing a project npm configuration that changed while being read.\n' +
        formatErrorLocation(objError, strPath) +
        '  it was a regular file a moment ago, so a second path swapped it mid-run.\n');
      process.exit(13);
    }
    try {
      const objFdStats = fstatSync(intFd, { bigint: true });
      const bigOwnUid = typeof process.getuid === 'function' ? BigInt(process.getuid()) : null;
      const strWhy = (objFdStats.nlink > 1n)
        ? `is hard-linked ${objFdStats.nlink} times, so a second path can rewrite these bytes`
        : (bigOwnUid !== null && objFdStats.uid !== bigOwnUid)
          ? `is owned by uid ${objFdStats.uid}, but this recorder runs as uid ${bigOwnUid}`
          : nonOwnerWriteReason(objFdStats);
      if (strWhy !== null) {
        process.stderr.write(
          'supply-freeze: refusing a project npm configuration the recording user does not '
          + 'solely control.\n' +
          `  path               ${formatUntrustedText(strPath)}\n` +
          `  observed           ${strWhy}\n` +
          `  metadata           nlink ${objFdStats.nlink}, uid ${objFdStats.uid}, mode ` +
          `${Number(objFdStats.mode & 0o7777n).toString(8).padStart(4, '0')}, recorder uid ` +
          `${bigOwnUid === null ? '(unknown)' : bigOwnUid}\n` +
          '  checked on the open descriptor whose inode npm reads; a second hard link,\n' +
          '  another owner, or a non-owner write grant is a write path this sweep cannot\n' +
          '  exclude, so npm could be fed other bytes while the recorded change time\n' +
          '  still compares equal.\n');
        process.exit(15);
      }
    } finally {
      closeSync(intFd);
    }
    consider(strPath, strLabel);
  };
  const walk = (strDirectory, strRelative) => {
    for (const objEntryHint of readdirOrRefuseUndecodable(strDirectory, strRelative)) {
      const strPath = join(strDirectory, objEntryHint.name);
      const strChild = strRelative ? `${strRelative}/${objEntryHint.name}` : objEntryHint.name;
      const objStats = consider(strPath, `node_modules/${strChild}`);
      if (objStats.isDirectory()) walk(strPath, strChild);
    }
  };
  // Round 24 for the root, round 26 for the manifests -- the same defect, and the
  // first fix closed only the instance that had been reported. `consider` lstats,
  // so for a symlink it records the LINK's ctime, and modifying the TARGET moves
  // stat's ctime while leaving lstat's untouched. Measured: chmod on a target gave
  // stat ctime moved true, lstat ctime moved false. A manifest that is a symlink
  // could therefore have its target swapped after the snapshot and restored before
  // the final byte comparison, with every check passing.
  //
  // Every path this script READS THROUGH a link is swept through the link, and the
  // behaviour is defined once so a fourth such path cannot be added and forgotten.
  //
  // Tree ENTRIES deliberately do not get this. The fold hashes a symlink's target
  // BYTES rather than the file it points at, so following one here would sweep
  // something the digest never measured -- the rule is to follow exactly where
  // this script's own reads follow, which is the root and the two manifests.
  //
  // A dangling link makes the next hop's lstat throw ENOENT, which lands in
  // scanOrRefuse and becomes the documented exit 10: a manifest that stopped
  // resolving mid-run IS a recorded input changing.
  //
  // Round 36, reported by Codex. Every hop is considered, not the outer link and
  // the final target. The previous version called realpathSync, which COLLAPSES
  // the chain -- so with `outer -> mid -> real`, it swept `outer` and `real` and
  // never looked at `mid`. Measured: repointing `mid` alone changed the bytes
  // read through `outer` from one file to another while `outer`'s lstat ctime and
  // the original target's stat ctime both stayed put, so the swap was invisible
  // to every value this sweep collected.
  //
  // The walk is the LEAF'S LINK CHAIN, deliberately, and not every component of
  // the resolved path. Considering directory components would pull `/`, `/home`
  // and every parent into the sweep, whose ctimes move for reasons that have
  // nothing to do with this record -- an over-sensitive check that refuses real
  // runs is not a stricter check, it is a broken one. A symlinked DIRECTORY
  // component is therefore still outside this, and is stated in the record
  // rather than implied closed.
  // Round 63, reported by Codex. Every hop was resolved as a STRING, and
  // `readlinkSync` without an encoding decodes the stored bytes as UTF-8. A
  // target the kernel stored as `d/\x80` therefore came back as `d/�`, and
  // re-encoding that for the next `lstat` asks for a DIFFERENT file -- one
  // literally named with the three bytes `EF BF BD`. An actor who plants that
  // sibling gets the sweep to watch the decoy while npm follows the link to the
  // real target, which can then be rewritten mid-run and restored invisibly.
  //
  // Measured, with the link pointing at `d/<0x80>` and a decoy at `d/<EF BF BD>`:
  //
  //   readFileSync through the link : "REAL npmrc: registry=https://evil.example"
  //   lstat(readlink as string) ino : 2033814   <- what the sweep watched
  //   lstat(readlink as bytes)  ino : 2033813   <- what npm actually opened
  //
  // This is the round-52 defect one layer out: the self-hash read decoded text
  // where it needed raw bytes, and the fold already stores a symlink's target as
  // the raw bytes the kernel gave it. The sweep was the remaining place that
  // round-tripped a path through a lossy decode. So the walk is done in Buffers
  // end to end -- `lstatSync` and `readlinkSync` both take and return them, and
  // no decode happens at all. Labels stay strings because they are map keys and
  // diagnostics, never paths.
  const dirnameBytes = (bufPath) => {
    const intSlash = bufPath.lastIndexOf(0x2F);
    return intSlash <= 0 ? Buffer.from('/') : bufPath.subarray(0, intSlash);
  };
  const considerThroughLinks = (strPath, strLabel) => {
    let bufCurrent = Buffer.from(strPath);
    for (let intHop = 0; ; intHop += 1) {
      const objStats = consider(
        bufCurrent, intHop === 0 ? strLabel : `${strLabel} (link hop ${intHop})`);
      if (!objStats.isSymbolicLink()) return;
      // A cycle would otherwise spin here. The throw is the same exit 10 a
      // dangling link produces, and for the same reason: the path stopped
      // resolving to bytes this script can name.
      if (intHop >= 40) {
        throw new Error(`${strLabel}: symlink chain exceeds 40 hops`);
      }
      const bufTarget = readlinkSync(bufCurrent, 'buffer');
      bufCurrent = bufTarget[0] === 0x2F
        ? bufTarget
        : Buffer.concat([dirnameBytes(bufCurrent), Buffer.from('/'), bufTarget]);
    }
  };
  considerThroughLinks(strRoot, 'node_modules');
  // Round 75, the other half of the symlinked-root finding. considerThroughLinks
  // watches the link and every hop's target; it does not watch the directories
  // ABOVE the final target, and a rename of one of those is what swaps the tree
  // without moving anything already swept. Measured before this was added:
  // perturbing the target's parent mid-run exited 0, while the project directory
  // (control) and the target itself both exited 10.
  //
  // Bounded by construction ONCE foldInstalledTree runs -- but round 79 showed
  // that is not the same as bounded here, and the paragraph this replaces claimed
  // otherwise. It said "there is no unbounded external walk", reasoning from the
  // escape check in foldInstalledTree. That check runs LATER than this baseline
  // scan, so the baseline follows an external root and walks it first. Codex
  // reported it and it reproduces:
  //
  //   node_modules -> quiet external dir -> exit 7  (boundary refusal wins)
  //   node_modules -> /proc              -> exit 10, EACCES at node_modules/1/fdinfo
  //
  // So the documented exit 7 is not guaranteed; which refusal fires depends on
  // whether the external tree happens to walk cleanly. The unbounded external walk
  // the old comment denied was real, and the claim was load-bearing -- it was the
  // stated reason this is a sweep rather than a refusal. FIXED in round 80:
  // refuseEscapingTreeRoot() now runs before the baseline scan, and node_modules
  // -> /proc refuses at exit 7 instead of walking into it and reporting exit 10.
  // With that guard ahead of the walk, the bounded-by-construction claim above is
  // true as written rather than true only after the fold.
  //
  // Labels carry the full path, not the basename: round 67 fixed exactly that
  // collision, where two swept paths sharing a basename collapsed to one map key.
  (() => {
    let strResolvedRoot;
    try {
      strResolvedRoot = realpathSync(strRoot);
    } catch {
      // A root that does not resolve is refused elsewhere, at exit 7 and 10. This
      // sweep adds nothing to that diagnosis, so it declines to compete with it.
      return;
    }
    if (strResolvedRoot === strRoot) return;
    let strAncestor = dirname(strResolvedRoot);
    for (let intDepth = 0; ; intDepth += 1) {
      if (strAncestor === strWorkflowDirectory
        || !strAncestor.startsWith(`${strWorkflowDirectory}/`)) break;
      // Swept rather than reported, and it is this round's own code caught being
      // a check that narrows itself. The depth guard used to `break`, which is
      // the wrong direction twice over: this walk runs from the target UPWARD, so
      // the entries a cap drops are the OUTERMOST ones -- the ancestors nearest
      // the workflow directory, which are exactly the ones a rename-aside would
      // move. A silent break there reads as "swept the chain" while having
      // dropped the part that matters.
      //
      // It also differed from its sibling for no reason a reader could infer:
      // considerThroughLinks, thirty lines up, caps at 40 hops and THROWS, on the
      // stated grounds that a path which stopped resolving is an exit 10 rather
      // than something to continue past. Same cap, same situation, opposite
      // behaviour. This now throws too, and the throw is the same exit 10.
      if (intDepth >= 40) {
        throw new Error(
          'node_modules symlink target: ancestor chain exceeds 40 levels');
      }
      consider(strAncestor, `node_modules target ancestor ${strAncestor}`);
      strAncestor = dirname(strAncestor);
    }
  })();
  walk(strRoot, '');
  // Round 67, reported by Codex, and a defect in the round-66 ancestor sweep
  // added one commit earlier. The label was the path's BASENAME, so two swept
  // paths sharing a basename collapsed to one map key and the later write won.
  // Cloning this repository into a directory named `workflows` makes the
  // repository-root ancestor and the workflow directory collide exactly that
  // way, and the entry that survives is the ancestor -- so creating and deleting
  // `.github/workflows/.npmrc` during the audit window would move a change time
  // that no longer appears in the compared map. That is the precise injection
  // the workflow-directory entry was added to catch, defeated by the checkout's
  // name. Labels are now supplied by the caller and are unique by construction
  // rather than by luck of the directory names.
  for (const [strPath, strLabel] of arrExtraPaths) {
    considerThroughLinks(strPath, strLabel);
  }
  // Round 56, reported by Codex, and the reason the workflow DIRECTORY is one of
  // the swept paths rather than only the files inside it.
  //
  // npm reads a PROJECT .npmrc from the directory the child runs in. The audit
  // child runs here, npm has no flag that relocates that source, and the comment
  // above the --userconfig/--globalconfig binding says so in as many words: the
  // static case is caught because the pre-audit `npm config list` runs in this
  // same directory and would report a planted proxy, but a .npmrc CREATED after
  // that check and before the audit was covered by nothing. The finding's sharp
  // half is what came next -- delete it again afterwards and no later check
  // looked at it either, so a redirected, filtered, schema-valid advisory posture
  // was recordable at freezeRecord: true with no trace left behind.
  //
  // Sweeping the directory's own ctime closes the create-and-remove case that a
  // content comparison structurally cannot: a file that is gone by the end has no
  // content to compare, but creating an entry and removing it both move the
  // ctime of the directory that held it. Measured, create-then-delete of .npmrc
  // moved this directory's ctime by 164 microseconds -- absent before, absent
  // after, and the mutation still visible.
  //
  // The directory is swept rather than the .npmrc path specifically, because the
  // defect is not about one filename: anything appearing beside the manifests
  // mid-run is a write into the directory whose contents this record describes.
  //
  // Round 57, reported by Codex, and the round-56 fix directly above caught one
  // case short. A directory's ctime moves when an ENTRY is created or removed --
  // it does not move when an existing file's CONTENTS are rewritten, because
  // that changes the file's inode and not the directory's. Measured on a
  // pre-existing .npmrc, rewritten hostile and restored benign:
  //
  //   directory ctime moved: false   <- all the round-56 sweep watched
  //   file      ctime moved: true    <- what nothing watched
  //
  // So a committed or pre-existing .npmrc could be rewritten after the transport
  // check, consumed by the audit, and restored, with the directory sweep seeing
  // nothing. npm documents the per-project .npmrc as a configuration source
  // distinct from the user and global files the audit call redirects, so this is
  // a live source rather than a theoretical one.
  //
  // The file is therefore swept in its own right, as an OPTIONAL path: it does
  // not exist in this repository today, and a check that refused every run for
  // the absence of a file nobody ships would be worse than the hole it closed.
  // Both halves are needed and neither subsumes the other -- the directory
  // catches create-and-remove, the file catches rewrite-in-place.
  considerOptional(join(strWorkflowDirectory, '.npmrc'), '.npmrc');
  return { ctimeMs: intNewest, path: strNewestPath, entries: objEntryChangeTimes };
}

// The advisory posture, reduced to what a policy decision actually turns on.
//
// Kept: which package is affected, its resolved severity, whether it is direct,
// and per advisory the stable GitHub Security Advisory identifier, its severity,
// CWE list, CVSS score and vector, and affected range.
//
// Dropped, deliberately:
//   * `title` -- prose. GitHub rewords advisory titles without the advisory
//     changing identity, so a title in the digest produces drift that means
//     nothing. The GHSA id is the identity.
//   * `fixAvailable` -- changes the day a fix ships upstream. That is news, but
//     it is not a change in what this repository installs.
//   * `effects` and `nodes` -- derivable from the tree fold above, so including
//     them would make one change move two numbers.
//
// Unlike the tree fold, this digest is NOT reproducible from the lockfile alone
// and is not meant to be: it is a snapshot of an advisory database that changes
// as new advisories are published.
//
// Round 11 correction. This comment used to say drift here "calls for a policy
// re-decision, not a failed build", which reads as non-blocking and contradicts
// the record: the advisory fields ARE compared, so a mismatch IS an equality
// failure. What differs is the response -- re-decide the policy rather than
// investigate the tree -- not whether the check fails. The record was corrected
// one round earlier and this comment was left behind, which is the same partial
// fix the correction was about.
// Round 56, reported by Codex. JSON.parse builds objects by repeatedly defining
// properties, so when one object carries the same key twice the LAST value
// silently wins and the earlier one is gone before any shape check can run.
// Measured on a two-record `vulnerabilities` object naming one package twice:
//
//   {"pkg":{severity:"high", via:["GHSA-real-real-real"]},
//    "pkg":{severity:"low",  via:["GHSA-fake-fake-fake"]}}
//   -> Object.keys(...).length === 1, and the HIGH record is the one discarded
//
// Every downstream check then sees a complete, well-formed, one-record report:
// the package count is consistent, the shape validates, and auditSha256 folds
// only the survivor -- so altering the discarded record does not move the
// digest. An endpoint can hide an advisory behind a duplicate of its own
// package name and this script exits 0 with a clean posture.
//
// The TEXT is scanned rather than the parsed value, because by the time there
// is a parsed value the evidence has been destroyed. Only text JSON.parse has
// already accepted is scanned, so this is looking for a repeat rather than
// validating grammar. A string is a KEY when the next non-whitespace character
// after it is a colon, which in well-formed JSON happens only inside an object;
// array scopes push a null so that strings inside them are never counted.
//
// Keys are compared DECODED, not as raw source. "a" and "a" are the same
// member name and a raw comparison would call them different -- the escape is
// exactly what an endpoint hiding a duplicate would reach for.
function firstDuplicateJsonKey(strText) {
  const arrScopes = [];
  const intLength = strText.length;
  let intAt = 0;
  while (intAt < intLength) {
    const strChar = strText[intAt];
    if (strChar === '{') { arrScopes.push(new Set()); intAt += 1; continue; }
    if (strChar === '[') { arrScopes.push(null); intAt += 1; continue; }
    if (strChar === '}' || strChar === ']') { arrScopes.pop(); intAt += 1; continue; }
    if (strChar !== '"') { intAt += 1; continue; }
    let intEnd = intAt + 1;
    while (intEnd < intLength && strText[intEnd] !== '"') {
      intEnd += strText[intEnd] === '\\' ? 2 : 1;
    }
    const strLiteral = strText.slice(intAt, intEnd + 1);
    intAt = intEnd + 1;
    let intProbe = intAt;
    while (intProbe < intLength && ' \t\n\r'.includes(strText[intProbe])) intProbe += 1;
    if (strText[intProbe] !== ':') continue;
    const objScope = arrScopes[arrScopes.length - 1];
    if (!(objScope instanceof Set)) continue;
    const strKey = JSON.parse(strLiteral);
    if (objScope.has(strKey)) return strKey;
    objScope.add(strKey);
  }
  return null;
}

const JSON_RESPONSE_REFUSALS = Object.freeze({
  invalidJson: 'invalid JSON',
  repeatedKey: 'repeated object key',
  unexpectedSchema: 'unexpected response schema',
  normalizationFailure: 'response normalization failed',
});

function refuseJsonResponse(strWhat, strReasonKey, strBody, intExit, boolAudit = false) {
  const strReason = JSON_RESPONSE_REFUSALS[strReasonKey];
  if (strReason === undefined) throw new Error('unknown internal JSON refusal category');
  process.stderr.write(
    `supply-freeze: ${strWhat} returned an unusable response.\n` +
    `  category           ${strReason}\n` +
    `  decoded length     ${Buffer.byteLength(strBody, 'utf8')} UTF-8 bytes\n` +
    '  source content and parser details are withheld because JSON inputs can contain\n' +
    '  registry credentials, package names, and other private configuration.\n' +
    '  this is an input or format failure; nothing is recorded.\n' +
    (boolAudit ? '  pass --no-audit to record the lockfile-derived fields alone.\n' : ''));
  process.exit(intExit);
}

function decodeUtf8ExactlyOrRefuse(bufContents, strWhat, intExit) {
  const strContents = bufContents.toString('utf8');
  if (!Buffer.from(strContents, 'utf8').equals(bufContents)) {
    process.stderr.write(
      `supply-freeze: ${strWhat} is not valid UTF-8; refusing to parse it.\n` +
      `  byte length        ${bufContents.length}\n` +
      '  invalid bytes and decoded content are withheld; a lossy replacement character\n' +
      '  could otherwise make different input bytes parse as the same JSON value.\n');
    process.exit(intExit);
  }
  return strContents;
}

// Round 56. Every npm-controlled JSON body this script parses goes through here,
// rather than the audit alone that was reported. `ls --all --json` decides
// treeSatisfiesLockfile and `config list --json` decides whether the install and
// transport settings are the reviewed ones -- both are answers from the same
// endpoint-fed process, and both are just as lossy on a duplicate key. Fixing
// only the reported site is the habit this loop keeps reporting against.
function parseNpmJsonOrRefuse(strBody, strWhat, intExit) {
  let objParsed;
  try {
    objParsed = JSON.parse(strBody);
  } catch {
    refuseJsonResponse(strWhat, 'invalidJson', strBody, intExit);
  }
  const strDuplicate = firstDuplicateJsonKey(strBody);
  if (strDuplicate !== null) refuseJsonResponse(strWhat, 'repeatedKey', strBody, intExit);
  return objParsed;
}

// The duplicate scan runs AFTER the parse, deliberately, and this order is the
// whole of its error handling. firstDuplicateJsonKey decodes each key literal
// with JSON.parse, which is only safe on text already known to be well formed --
// scanning first would let a malformed body throw out of the scanner as a raw
// SyntaxError at exit 1, in the one place exit 5 exists to name. That is the
// round-16 defect this function was written to close, and putting the new check
// above the parse would have reintroduced it while fixing something else.
function parseAuditOrRefuse(strBody) {
  let objParsed;
  try {
    objParsed = JSON.parse(strBody);
  } catch {
    refuseJsonResponse('npm audit', 'invalidJson', strBody, 5, true);
  }
  const strDuplicate = firstDuplicateJsonKey(strBody);
  if (strDuplicate !== null) {
    refuseJsonResponse('npm audit', 'repeatedKey', strBody, 5, true);
  }
  return objParsed;
}

// Round 51, reported by Codex, and the THIRD round on one expression. Rounds 49
// and 50 each widened a character class -- first anchoring the match, then making
// the boundary case-blind -- and both were still asking "what character ends this
// token" of a string that is still PERCENT-ENCODED. Measured:
//
//   .../GHSA-aaaa-bbbb-cccc%78  -> GHSA-aaaa-bbbb-cccc   (segment is ...ccccx)
//   .../GHSA-aaaa-bbbb-cccc%79  -> GHSA-aaaa-bbbb-cccc   (segment is ...ccccy)
//   .../GHSA-aaaa-bbbb-cccc%2D64 -> GHSA-aaaa-bbbb-cccc  (segment is ...cccc-64)
//
// `%` is not in the boundary class, so the encoded suffix reads as a delimiter and
// two urls naming different advisories collapse to one identity and one
// auditSha256 -- reached instead of the exit-5 refusal, in the field this record
// exists to compare exactly. The hyphen case shows the encoding reaches even the
// boundary character round 49 added.
//
// The lesson the url scanner took four rounds to learn applies here too, and this
// is it applied rather than restated: STOP ASKING WHAT DELIMITS THE TOKEN. The id
// is not a substring to be found in a blob of text, it is a complete PATH SEGMENT
// of a url. So the url is parsed, its path split into segments, each segment
// decoded, and a segment must equal the identifier EXACTLY. There is no boundary
// character left to guess, because there is no boundary -- a segment either is the
// identifier or is not, and any extra character, raw or encoded, makes it not.
//
// Fails closed twice, matching redactUrl's round-38 lesson: a url `new URL()`
// cannot parse yields no identity, and so does a segment that will not decode.
// Both fall through to the source-id test, which finds a real identity or refuses.
//
// Every segment is examined rather than only the last, so a trailing slash and any
// future path shape still work. The 14 ids recorded in T1-SUPPLY-FREEZE-v1 all
// extract byte-identically under this, which is the constraint it was measured
// against: their urls are https://github.com/advisories/<id>, whose final segment
// decodes to itself.
const RE_GHSA_EXACT = /^GHSA-[0-9a-z]{4}-[0-9a-z]{4}-[0-9a-z]{4}$/u;
function ghsaIdFromUrl(strUrl) {
  let objUrl;
  try {
    objUrl = new URL(strUrl);
  } catch {
    return null;
  }
  // Round 52, reported by Codex. Returning the FIRST matching segment made
  // `/GHSA-aaaa-bbbb-cccc/GHSA-dddd-eeee-ffff` and
  // `/GHSA-aaaa-bbbb-cccc/GHSA-gggg-hhhh-jjjj` one identity -- the same
  // collision this function was written to close, moved from "which characters
  // end the token" to "which of several tokens is the token". A url naming two
  // advisories does not name one of them; it is malformed, and the honest answer
  // is no identity rather than a guess at precedence. Collected and counted, so
  // exactly one is an identity and anything else falls through to the source-id
  // test, which finds a real identity or refuses at exit 5.
  const arrFound = [];
  for (const strSegment of objUrl.pathname.split('/')) {
    let strDecoded;
    try {
      strDecoded = decodeURIComponent(strSegment);
    } catch {
      return null;
    }
    if (RE_GHSA_EXACT.test(strDecoded)) {
      arrFound.push(strDecoded);
    }
  }
  return arrFound.length === 1 ? arrFound[0] : null;
}

function normalizeAudit(objAudit) {
  const objVulnerabilities = objAudit.vulnerabilities ?? {};
  const objOutput = {
    auditReportVersion: objAudit.auditReportVersion ?? null,
    counts: orderedCounts(objAudit.metadata?.vulnerabilities),
    // Round 40, reported by Codex. A PLAIN object literal here inherits
    // Object.prototype, so assigning a package named `__proto__` invoked the
    // prototype SETTER instead of creating an own property. The record was lost
    // in silence: the raw report still had `__proto__` as an own key, so the
    // round-38 count cross-check saw one vulnerability and agreed with
    // `total: 1`, while this map ended up with zero own keys.
    //
    // Measured, changing only `range` -- a field the counts do not depend on:
    //   name `__proto__`, range <1.0.0  -> auditSha256 5438d3f58398151c
    //   name `__proto__`, range <9.9.9  -> auditSha256 5438d3f58398151c  identical
    //   name `normalpkg`, range <1.0.0  -> auditSha256 950e0376cfe3dc8c
    //   name `normalpkg`, range <9.9.9  -> auditSha256 bd1fb640b93a13ec  moves
    // The package contributed NOTHING to the digest while the run exited 0
    // recording `high: 1, total: 1`.
    //
    // A null prototype removes the mechanism for every inherited name at once
    // rather than for the one name that was reported -- `constructor` and
    // `toString` had the same shape of problem. JSON.stringify treats a
    // null-prototype object identically, so the recorded auditSha256 for a real
    // report is unchanged; that is verified rather than assumed.
    packages: Object.create(null),
  };
  for (const strName of Object.keys(objVulnerabilities).sort()) {
    const objVulnerability = objVulnerabilities[strName];
    const arrAdvisories = [];
    // Round 47, reported by Codex. String `via` entries were dropped on the
    // `continue` below, so the only field naming WHAT made a package vulnerable
    // was discarded. Measured, three reports identical but for that name:
    //
    //   via ["examplepkg"] / ["depA"] / ["depB"]  -> all posture f8682da6e254c9f0
    //
    // with the same `inheritedpkg  high (inherited through dependencies)` line in
    // all three. Three different claims about causation, one record.
    //
    // The comment that justified the drop said the chain "is already covered by
    // the tree", and that is the sentence this review reliably turns into the
    // next finding. It is wrong for a reason worth writing down: the installed
    // tree records which packages DEPEND on which, and this field records which
    // package the REGISTRY declared vulnerable. A tree edge is not an advisory
    // claim, and the posture digest is a statement about the registry's answer.
    //
    // Retained rather than the offered alternative of refusing a string that
    // names no vulnerability record. That alternative keeps the digest stable --
    // an unresolvable name is the only case that collides -- but it rests on npm
    // always emitting resolvable names, which is a guess about an implementation
    // rather than a documented grammar. Same rule that declined npm's name
    // grammar in round 43 and duplicate ids in round 44: retaining what was
    // supplied cannot refuse a legitimate report, while requiring resolution can.
    //
    // Order is preserved rather than sorted. Sorting would make two orderings of
    // the same names one record, and every round since 43 has been about closing
    // collisions rather than opening new ones; whether npm's ordering is stable
    // is exactly the implementation guess this file keeps declining to make.
    const arrViaPackages = [];
    // Round 22, reported. A string `via` is ITERABLE, so this loop walked it
    // character by character, matched no advisory in any character, and returned
    // zero advisories without throwing -- the digest lost the advisory identity
    // and the human output relabelled the package as inherited. The try/catch
    // added last round cannot help: nothing throws. Shapes that are wrong but
    // iterable need a type check, not an exception handler.
    // Round 31, reported, and the sixth widening -- the `?? []` here is the same
    // manufacture-a-value habit the advisory fields were cleaned of last round,
    // hiding one level up. A vulnerability with NO `via` key at all was handed an
    // empty array, iterated zero times, and recorded as a package with no
    // advisory identity: measured, exit 0 with a complete-looking record and the
    // package relabelled inherited. The non-array case refused; the missing case,
    // which is the likelier endpoint failure, did not.
    //
    // `via` is required, so its absence is a malformed report rather than an
    // empty one. Checked with a property test rather than a truthiness one: an
    // explicit `via: null` is also absent for this purpose, and `?? []` treated
    // it as a legitimate empty list.
    if (!Object.hasOwn(objVulnerability, 'via') || objVulnerability.via === null) {
      throw new TypeError(`vulnerability ${strName} has no via array`);
    }
    if (!Array.isArray(objVulnerability.via)) {
      throw new TypeError(`vulnerability ${strName} has a non-array via`);
    }
    for (const objVia of objVulnerability.via ?? []) {
      // A `via` entry that is a bare string names another package in the chain
      // rather than an advisory. Recorded, not dropped -- see arrViaPackages.
      if (typeof objVia === 'string') {
        arrViaPackages.push(objVia);
        continue;
      }
      // Round 24, reported. The round-22 fix validated the CONTAINER and left
      // its MEMBERS unchecked, so `via: [null]` and `via: [7]` both fell through
      // the old combined test onto `continue` -- no advisory, no throw, and the
      // package relabelled as inherited in a record that looks complete. Only
      // the two documented member shapes are accepted now; an array is excluded
      // explicitly because typeof [] is 'object' and it has none of the fields
      // read below.
      if (typeof objVia !== 'object' || objVia === null || Array.isArray(objVia)) {
        throw new TypeError(
          `vulnerability ${strName} has a via member that is neither a package name`
          + ` nor an advisory object (got ${objVia === null ? 'null' : typeof objVia})`);
      }
      const strUrl = typeof objVia.url === 'string' ? objVia.url : '';
      // Round 49, reported by Codex. This was unanchored at both ends, so a
      // longer token that merely BEGINS with a GHSA-shaped prefix matched its
      // prefix and the remainder was discarded. Measured on three urls:
      //
      //   .../GHSA-aaaa-bbbb-ccccx  -> GHSA-aaaa-bbbb-cccc
      //   .../GHSA-aaaa-bbbb-ccccy  -> GHSA-aaaa-bbbb-cccc
      //   .../GHSA-aaaa-bbbb-cccc   -> GHSA-aaaa-bbbb-cccc
      //
      // Two reports naming different advisories therefore recorded one identity
      // and one auditSha256 -- the same collision class as the round-43 source
      // ids, in the field this record exists to compare exactly, and reached
      // instead of the exit-5 refusal the paragraph below documents.
      //
      // Boundaries on both sides. A trailing `-` is excluded as well as a
      // trailing alphanumeric, so `GHSA-aaaa-bbbb-cccc-dddd` does not match its
      // own prefix either. With no match the identity falls through to the
      // source-id test below, which either finds a real identity or refuses --
      // both correct, and neither is a truncated name npm never emitted.
      //
      // Round 50, reported by Codex, in those boundary classes one round after
      // they were written. Both were `[0-9a-z]`, so an UPPERCASE alphanumeric
      // counted as a boundary and the truncation the round-49 fix exists to stop
      // was still reachable one case letter away. Measured on the same urls:
      //
      //   .../GHSA-aaaa-bbbb-ccccX  -> GHSA-aaaa-bbbb-cccc
      //   .../GHSA-aaaa-bbbb-ccccY  -> GHSA-aaaa-bbbb-cccc
      //
      // Two reports naming different advisories, one identity and one
      // auditSha256 -- the defect the paragraph above claims to have closed.
      //
      // The class is what a GHSA identifier is MADE OF rather than a guess at
      // what delimits one, which is the distinction rounds 47 through 49 spent
      // three rounds learning on the url scanner: these ids are drawn from an
      // alphabet of alphanumerics and `-`, so any of those on either side means
      // the token continues and this match is a piece of a longer one. Case is
      // irrelevant to that question -- an uppercase letter can only appear here
      // in a malformed report, and `X` is no more a delimiter than `x` is.
      // Applied to BOTH sides, since the leading class also lacked `-`, so
      // `x-GHSA-aaaa-bbbb-cccc` matched its own tail.
      //
      // The form npm actually emits is untouched, and that is the constraint
      // this is measured against rather than an aspiration:
      // https://github.com/advisories/GHSA-vh95-rmgr-6w4m is bounded by `/` and
      // end-of-string, neither of which is an identifier character.
      // Round 51 replaced the boundary lookarounds with a decoded whole-segment
      // test. See ghsaIdFromUrl above for why the boundary question was the wrong
      // one to keep answering.
      const strGhsaId = ghsaIdFromUrl(strUrl);
      // Round 29, reported, and the fifth widening of this guard -- the comment
      // above already counted four. Rounds 22 and 24 checked the container and
      // then the member TYPE, and left the member's FIELDS unchecked, so `{}`
      // satisfied every test and was recorded. Measured on the reviewed path:
      // `via: [{}]` exited 0 and produced a freeze record carrying an advisory
      // whose id was the invented string `npm-source-unknown`, folded into
      // auditSha256 -- a fabricated identity inside the one field this record
      // exists to compare exactly.
      //
      // Each previous round answered the shape it was shown. This one states the
      // rule instead: EVERY field read below is validated, and nothing is ever
      // invented. `?? 'unknown'` was the only fallback that manufactured a value
      // rather than recording absence, and it is gone. An advisory with no GHSA
      // url and no integer source has no identity to record, so the report is
      // refused as malformed rather than described with a name npm never gave it.
      // Round 43, reported by Codex. SAFE integer, and positive. Number.isInteger
      // accepts any integral double, including values past 2^53-1 where distinct
      // JSON integers stop having distinct doubles. Measured, two reports
      // differing only in that last digit:
      //
      //   source 9007199254740992 -> npm-source-9007199254740992, ce8b43dd...
      //   source 9007199254740993 -> npm-source-9007199254740992, ce8b43dd...
      //
      // Two different malformed reports, one identity, one advisory posture, both
      // recorded at exit 0 -- a collision in the single field this record exists
      // to compare exactly, reached instead of the documented exit-5 refusal.
      //
      // Number.isSafeInteger is not an approximation of the property wanted here;
      // it IS the property, defined as the range over which an integer round-trips
      // through a double unambiguously. Real npm source ids are around 10^6, so
      // nothing npm emits is refused by this.
      if (!strGhsaId
        && !(Number.isSafeInteger(objVia.source) && objVia.source > 0)) {
        throw new TypeError(
          `advisory in ${strName} carries neither a GHSA url nor a positive`
          + ' safe-integer source, so it has no identity to record');
      }
      // The remaining recorded fields are absence-or-type: npm may legitimately
      // omit any of them, and `null` records that honestly. What is refused is a
      // present value of the wrong type, which would otherwise be copied verbatim
      // into a digest this record asserts is stable.
      assertSeverity('advisory severity', objVia.severity, strName);
      for (const [strField, objValue, strExpected] of [
        ['range', objVia.range, 'string'],
        ['cvss.score', objVia.cvss?.score, 'number'],
        ['cvss.vectorString', objVia.cvss?.vectorString, 'string'],
      ]) {
        if (objValue !== undefined && objValue !== null && typeof objValue !== strExpected) {
          throw new TypeError(
            `advisory in ${strName} has a ${strField} of type ${typeof objValue},`
            + ` expected ${strExpected}`);
        }
      }
      if (objVia.cvss !== undefined && objVia.cvss !== null && !isPlainObject(objVia.cvss)) {
        throw new TypeError(`advisory in ${strName} has a non-object cvss`);
      }
      // Round 45, reported by Codex. `typeof x === 'number'` is true of Infinity,
      // and JSON.parse produces it from any literal that overflows a double, so
      // 1e400 reached the record as Infinity -- which canonicalize serializes as
      // null, the same bytes an absent score produces. Measured, four reports
      // that differ in what they claim about severity:
      //
      //   score 1e400 / -1e400 / null / omitted  -> all posture b7129f7835277b88
      //
      // This is the only number the advisory record carries, so finiteness is the
      // whole of what the digest needs: every finite double has a distinct
      // JSON.stringify form, and the non-finite ones are exactly those that
      // collapse to null.
      //
      // The 0-10 bound is a second, separate assertion, and it is taken here --
      // unlike the name-grammar and duplicate-id rejections declined in rounds 43
      // and 44 -- because CVSS DEFINES its score range as 0.0 to 10.0 in the
      // specification. That is a normative source, not an npm implementation
      // detail I would be guessing at, so refusing outside it cannot turn a
      // legitimate report away.
      //
      // Reported with String(), not JSON.stringify(): the latter renders Infinity
      // as `null`, which would print a refusal saying the score is null while
      // refusing it for not being a number.
      const objCvssScore = objVia.cvss?.score;
      if (objCvssScore !== undefined && objCvssScore !== null
        && !(Number.isFinite(objCvssScore) && objCvssScore >= 0 && objCvssScore <= 10)) {
        throw new TypeError(
          `advisory in ${strName} has a cvss.score of ${String(objCvssScore)},`
          + ' expected a finite number in the CVSS range 0-10');
      }
      arrAdvisories.push({
        id: strGhsaId ?? `npm-source-${objVia.source}`,
        severity: objVia.severity ?? null,
        cwe: (() => {
          const arrCwe = objVia.cwe ?? [];
          if (!Array.isArray(arrCwe)) {
            throw new TypeError(`advisory in ${strName} has a non-array cwe`);
          }
          // Round 24, swept rather than reported: the same container-checked,
          // members-unchecked defect as `via`, one field over. `[null, 7]` is an
          // array, sorts without complaint, and writes those members straight
          // into a digest this record asserts is stable. cwe is the only other
          // parsed-JSON array this script iterates or spreads.
          if (arrCwe.some((objEntry) => typeof objEntry !== 'string')) {
            throw new TypeError(`advisory in ${strName} has a non-string cwe entry`);
          }
          return [...arrCwe].sort();
        })(),
        cvssScore: objVia.cvss?.score ?? null,
        cvssVector: objVia.cvss?.vectorString ?? null,
        range: objVia.range ?? null,
      });
    }
    // Round 43, reported by Codex. Ordered by the WHOLE normalized advisory, not
    // by its id alone. Sorting on id left same-id advisories tied, and a tie in a
    // stable sort keeps whatever order the endpoint happened to send. Measured,
    // the same two advisories under one id, submitted in both orders:
    //
    //   [alpha, beta] -> advisory posture f26e6366d0ebee4f...
    //   [beta, alpha] -> advisory posture bfeb78bead8e8a85...
    //
    // Normalization exists to erase exactly that difference, so this was the one
    // guarantee the advisory fold makes, failing on its own terms.
    //
    // Codex offered "reject duplicate ids OR tie-break". Tie-breaking, because I
    // cannot establish that npm never legitimately reports one source id against
    // more than one path, and refusing a real report is worse than ordering it.
    //
    // Keyed on the serialization rather than a hand-written field-by-field
    // comparator so the ordering stays TOTAL when a field is added later. A
    // comparator listing today's fields silently stops being total the moment
    // someone adds tomorrow's. Key order is fixed by the construction above, so
    // the serialization is deterministic, and `id` is written first, so comparing
    // serializations lexicographically still orders by id and only then by the
    // remaining fields -- the previous ordering, with its ties resolved.
    const funcAdvisoryKey = (objAdvisory) => JSON.stringify(objAdvisory);
    arrAdvisories.sort((objLeft, objRight) => {
      const strLeft = funcAdvisoryKey(objLeft);
      const strRight = funcAdvisoryKey(objRight);
      return strLeft < strRight ? -1 : strLeft > strRight ? 1 : 0;
    });
    // Round 33, swept rather than reported. The reported defect was an
    // unvalidated advisory severity; these three package fields -- the object
    // those advisories hang on -- had NO validation at all, which is the same
    // bare `?? null` that was cleaned out one level down last round. Measured on
    // the reviewed path, all four exited 0 and wrote the junk straight into
    // auditSha256: `severity: 7`, `severity: "urgent"`, `isDirect: "yes"`,
    // `range: 5`. Validating the level a reviewer names and leaving the adjacent
    // level bare is how this guard has been widened seven times.
    assertSeverity('package severity', objVulnerability.severity, strName);
    for (const [strField, objValue, strExpected] of [
      ['isDirect', objVulnerability.isDirect, 'boolean'],
      ['range', objVulnerability.range, 'string'],
    ]) {
      if (objValue !== undefined && objValue !== null && typeof objValue !== strExpected) {
        throw new TypeError(
          `${strName} has a ${strField} of type ${typeof objValue}, expected ${strExpected}`);
      }
    }
    objOutput.packages[strName] = {
      severity: objVulnerability.severity ?? null,
      isDirect: objVulnerability.isDirect ?? null,
      range: objVulnerability.range ?? null,
      advisories: arrAdvisories,
      // Raw, deliberately. Escaping on the way into a digest is what round 44
      // established must never happen -- formatTreeName is not injective, so it
      // would manufacture the collisions these rounds keep closing. The print
      // site escapes; JSON.stringify handles the record losslessly.
      viaPackages: arrViaPackages,
    };
  }
  // Round 40. The null prototype above closes the mechanism that was reported;
  // this closes the FAILURE MODE, which is broader and is what actually hurt --
  // normalization dropping a record and the run still exiting 0. Any future
  // reason a package fails to land here (a name colliding with something, an
  // early continue added later) now refuses instead of quietly shortening the
  // record the digest is taken over.
  //
  // Stated as a count equality rather than a key-by-key comparison because the
  // loop's whole contract is one output package per input record; if that ever
  // stops holding, the digest is being taken over a different set than the
  // counts describe, and which key went missing is a diagnosis for the operator
  // rather than something this assertion needs to name.
  const intRawRecords = Object.keys(objVulnerabilities).length;
  const intNormalized = Object.keys(objOutput.packages).length;
  if (intNormalized !== intRawRecords) {
    throw new TypeError(
      `normalization produced ${intNormalized} packages from ${intRawRecords} `
      + 'vulnerability records; the digest would not cover every reported package');
  }
  return objOutput;
}

function auditCountsOrRefuse(strAuditResponse, objAudit) {
  if (!isPlainObject(objAudit)) {
    refuseJsonResponse('npm audit', 'unexpectedSchema', strAuditResponse, 5, true);
  }
  const objCounts = objAudit.metadata?.vulnerabilities;
  if (!(Number.isSafeInteger(objAudit.auditReportVersion) && objAudit.auditReportVersion > 0)
    || !isPlainObject(objAudit.vulnerabilities)
    || !isPlainObject(objCounts)
    || !SEVERITY_ORDER.every((strSeverity) => Number.isSafeInteger(objCounts[strSeverity])
      && objCounts[strSeverity] >= 0)
    || !Object.values(objAudit.vulnerabilities).every(isPlainObject)) {
    refuseJsonResponse('npm audit', 'unexpectedSchema', strAuditResponse, 5, true);
  }
  return objCounts;
}

function normalizeAuditOrRefuse(strAuditResponse, objAudit) {
  try {
    return normalizeAudit(objAudit);
  } catch {
    refuseJsonResponse('npm audit', 'normalizationFailure', strAuditResponse, 5, true);
  }
}

const strPackagePath = join(strWorkflowDirectory, 'package.json');
const strLockPath = join(strWorkflowDirectory, 'package-lock.json');

// Round 66, reported by Codex as a P1, and it is a hole in what "the inputs did
// not move" means. Every sweep so far watched INODES -- the tree root, the two
// manifests, this directory -- while npm resolves its cwd by NAME. Rename the
// genuine `.github` aside after the config check and the first fold, put a
// different `.github/workflows` at the same pathname carrying a project `.npmrc`
// or lockfile that points the audit somewhere else, let the audit child run, then
// rename the original parent back before the final sweep. Every watched inode is
// untouched: the workflows directory, the manifests and every node_modules entry
// keep their own ctimes, so both sweeps agree and both folds match, while the
// audit answered from a directory this script never measured.
//
// The ancestors are therefore swept too. A rename is a modification of the
// CONTAINING directory, so moving `.github` moves the repository root's ctime,
// and renaming it back moves it again; the renamed inode's own ctime moves as
// well, since rename(2) updates it. Either is enough for the existing per-entry
// comparison to refuse.
//
// The chain stops at the repository root rather than climbing to `/`. Above the
// checkout the ancestors are shared with the rest of the machine -- `/home`, the
// mount point, `/` -- and their ctimes move for reasons that have nothing to do
// with this run, so sweeping them would refuse healthy runs without closing
// anything this script can defend. A checkout whose PARENT is writable by an
// attacker is outside the boundary and is stated as a precondition in the record.
const arrWorkflowAncestors = [
  dirname(strWorkflowDirectory),
  dirname(dirname(strWorkflowDirectory)),
];

// Round 66, reported by Codex as a P1, and the same defect one input over. A
// symlinked `package.json` or `package-lock.json` had its link AND its final
// target watched, but not the target's PARENT. That parent can be renamed aside
// and replaced after the snapshot, so `npm ls` and `npm audit` -- which open the
// path by name -- read different bytes, and restoring the parent before the final
// sweep leaves the watched link and the original target's ctimes matching. The
// run could emit freezeRecord: true with lockfile and advisory answers derived
// from bytes other than the compared manifest hashes.
//
// This is refused rather than swept, and the deciding argument is that the script
// ALREADY refuses this exact shape one file over: exit 13 rejects a `.npmrc` that
// is a symlink, on the reasoning that "a link is opened through a target whose own
// parent can be swapped mid-run". The manifests are the more load-bearing inputs
// -- they are the compared hashes -- and were held to the weaker rule. Sweeping
// the target's ancestors instead would mean walking an unbounded chain outside the
// checkout, where ctimes move for unrelated reasons; refusing keeps the input
// boundary a set this script can actually prove.
for (const [strPath, strLabel] of [[strPackagePath, 'package.json'], [strLockPath, 'package-lock.json']]) {
  let objLinkStats;
  try {
    objLinkStats = lstatSync(strPath);
  } catch {
    continue;
  }
  // Round 74, reported by Codex, and this is the round-66 manifest-symlink fix
  // caught testing for the shape that was reported instead of the property that
  // matters. It asked `isSymbolicLink()` and let every other non-regular kind
  // through, while the comment above claimed the .npmrc rule was being applied
  // here -- and that rule (exit 13) refuses symlink, directory, FIFO, socket AND
  // device. The narrower test was the weaker of two checks written for one class.
  //
  // A FIFO is the case that makes this a correctness bug rather than a tidiness
  // one, and it defeats a different guard than the symlink does. Its bytes are
  // not a file at all but a stream, supplied per open by whoever holds the write
  // end: snapshotOrRefuse() reads the reviewed bytes, then `npm ls` and `npm
  // audit` open the same path and consume whatever is written next. Nothing in
  // the quiescence sweep can see it -- the sweep compares the FIFO's inode and
  // change time, which a writer feeding different bytes never touches.
  // Codex P2 on 57ec78c. The nlink/uid rewrite check that used to live HERE, on
  // the preflight `lstat()` by name, is moved onto the OPEN descriptor in
  // readViaVerifiedDescriptor. The reads that supply the compared bytes --
  // snapshotOrRefuse() and the final readOrRefuse() -- open the manifest by name
  // and only re-checked isFile() on the descriptor, so a manifest that was a plain
  // nlink-1 file at this preflight could be swapped for reviewed bytes carrying a
  // second hard link before the snapshot: write malicious bytes for `npm ls`/`npm
  // audit`, restore the reviewed bytes before the final read, and the byte-equality
  // re-read compares equal while npm answered from other bytes. A check on the
  // descriptor whose bytes are returned has no such gap. This preflight now only
  // classifies a manifest that is not a regular file at all.
  if (objLinkStats.isFile()) continue;
  const strKind = objLinkStats.isSymbolicLink() ? 'a symlink'
    : objLinkStats.isDirectory() ? 'a directory'
      : objLinkStats.isFIFO() ? 'a FIFO'
        : objLinkStats.isSocket() ? 'a socket'
          : objLinkStats.isBlockDevice() ? 'a block device'
            : objLinkStats.isCharacterDevice() ? 'a character device'
              : 'not a regular file';
  process.stderr.write(
    'supply-freeze: refusing a recorded manifest that is not a regular file.\n' +
    `  manifest           ${formatUntrustedText(strLabel)}\n` +
    `  what it is         ${strKind}\n` +
    '  this path is opened by name by npm ls and npm audit, and only a regular file\n' +
    '  can be held still across the run. A symlink is opened through a target whose\n' +
    '  own parent can be renamed aside mid-run and restored before the final sweep,\n' +
    '  so the link and its original target still compare equal while npm answered\n' +
    '  from different bytes. A FIFO or socket is worse: it yields whatever its\n' +
    '  writer supplies at each open, so the bytes hashed here and the bytes npm\n' +
    '  read need never have been the same, and no inode or change-time comparison\n' +
    '  can detect the difference.\n' +
    '  the same rule already applies to a project .npmrc at exit 13; replace it with\n' +
    '  a regular file inside the workflow directory.\n');
  process.exit(15);
}
const strTreeRoot = join(strWorkflowDirectory, 'node_modules');
// Round 17, reported, and the previous round's fix caught half-done. The
// RE-reads were routed through a refusal; these initial snapshot reads were left
// bare, so a manifest missing or unreadable before the recorder starts threw an
// uncaught filesystem error and exited 1 -- ahead of the exit-4 guard that
// exists to name exactly this, and contradicting the record's claim that every
// refusal names its values on stderr.
function snapshotOrRefuse(strPath) {
  return readViaVerifiedDescriptor(strPath, 4, (objError) => {
    process.stderr.write(
      'supply-freeze: refusing to record digests for an unreviewed manifest.\n' +
      `  ${strPath.split('/').pop().padEnd(18)} could not be read\n` +
      formatErrorLocation(objError, strPath) +
      '  the reviewed manifest must be present and readable before anything is recorded.\n');
  });
}

function snapshotContractOrRefuse(strPath) {
  const refuseInitialContractRead = (objError) => {
    process.stderr.write(
      'supply-freeze: refusing to record an unreadable P1 contract.\n' +
      `  ${strPath.split('/').pop().padEnd(18)} could not be read\n` +
      formatErrorLocation(objError, strPath) +
      '  the reviewed P1 contract must be a readable, regular, singly linked file\n' +
      '  owned by this recording user before anything is recorded.\n');
  };
  try {
    return readViaVerifiedDescriptor(strPath, 17, refuseInitialContractRead,
      { exit: 17, what: 'P1 contract', holdable: true });
  } catch (objError) {
    // readViaVerifiedDescriptor translates every native descriptor-operation
    // failure. This boundary preserves the initial-contract fallback for an
    // unexpected exception outside that translation.
    refuseInitialContractRead(objError);
    process.exit(17);
  }
}

function readContractOrRefuse(strPath) {
  try {
    return readOrRefuse(strPath, { exit: 3, what: 'P1 contract', holdable: true });
  } catch (objError) {
    process.stderr.write(
      'supply-freeze: the P1 contract became unreadable during recording; refusing.\n' +
      formatErrorLocation(objError, strPath));
    process.exit(3);
  }
}

// Round 19, reported. This ceiling used to be captured after the snapshots and
// after `npm ls`, so a manifest replaced after the snapshot and restored before
// the ceiling escaped every check: the byte comparisons matched the restored
// file, the sweep ignored a ctime that predated the ceiling, and `npm ls` had
// validated the tree against the temporary lockfile in between. Captured before
// the first read of anything recorded, the window closes.
const intRecordingStartedAt = Date.now();

const objPackageBefore = snapshotOrRefuse(strPackagePath);
const objLockBefore = snapshotOrRefuse(strLockPath);
const strPackageJsonBefore = decodeUtf8ExactlyOrRefuse(
  objPackageBefore, 'package manifest', 4);
const strContractPath = join(strWorkflowDirectory, 'workflow-policy-contract.json');
const objContractBefore = snapshotContractOrRefuse(strContractPath);
function contractIdentityOrRefuse() {
  try { return lstatSync(strContractPath, { bigint: true }); } catch {
    process.stderr.write('supply-freeze: P1 contract became unreadable during recording; refusing.\n');
    process.exit(3);
  }
}
const objContractIdentityBefore = contractIdentityOrRefuse();
const objContract = parseNpmJsonOrRefuse(
  decodeUtf8ExactlyOrRefuse(objContractBefore, 'P1 contract', 17), 'P1 contract', 17);
const objSupplyFreeze = objContract.supplyFreeze;
if (!isPlainObject(objSupplyFreeze)
  || sha256(canonicalize(objSupplyFreeze)) !== '83c5138131de742734d22a818e21feb63d5ac11f8877adf52299809f04217362') {
  process.stderr.write('supply-freeze: P1 historical assertions differ from the reviewed tuple; refusing.\n');
  process.exit(17);
}


// Round 29, reported -- the baseline half of the quiescence sweep. Read here
// rather than at the ceiling above so that a missing or unreadable manifest
// still produces its own exit-4 diagnosis instead of being reported as a failed
// scan, and read before the version probe, `npm ls`, the audit and both folds,
// so it precedes every byte this run records.
//
// A tree absent at baseline is left at 0 rather than refused: the reviewed path
// already refuses a missing node_modules with a clearer message further down,
// and under --any-toolchain a tree that appears mid-run should trip the sweep,
// which comparing against 0 does.
// Round 31, reported, and a regression this baseline introduced last round. The
// guard was `existsSync`, which is true for a node_modules that is a regular file
// or a symlink to one -- so newestChangeTime called readdirSync on a non-directory
// and scanOrRefuse reported ENOTDIR as exit 10, "an entry vanished while being
// read; record against a quiescent tree". Measured against the previous commit:
// the same tree gave exit 7, "node_modules present, but not a directory". A
// correct refusal was replaced with one that sends the operator chasing a race
// that never happened, because this scan was inserted ahead of the root
// validation that already answers the question.
//
// The condition is now walkability, not existence. `statSync` follows a symlinked
// root, which is what newestChangeTime does too, so the two agree about what is
// walkable; anything else defers to the root refusal further down, which names
// the real problem.
// Round 44, reported by Codex, and an exact hit on the sentence the round-31
// comment above used to DEFEND the statSync choice: "the two agree about what is
// walkable". They do agree -- and both are wrong about a symlinked root, which
// the reviewed path refuses outright further down. So this baseline would walk
// an external tree the run has already decided not to record.
//
// Measured on a symlinked root pointing at a target holding an unreadable
// directory: exit 10, "the baseline quiescence scan could not complete ... an
// entry vanished or became unreadable", when the true answer is exit 7, "not the
// installed tree". A refusal naming a race that never happened, again -- the same
// defect round 31 fixed, one layer up. A large or concurrently changing target
// also pays an unbounded walk before the refusal it was always going to get.
//
// The root rejection is therefore made BEFORE the scan rather than after the
// fold. lstat, not stat: the question is what node_modules IS, not what it points
// at. A missing root is left alone -- lstat throwing means there is nothing to
// reject here, and the later refusal names it MISSING with better wording.
//
// The message lives in one function called from both sites, so the early refusal
// and the post-fold one cannot drift apart. The post-fold check is kept rather
// than replaced: it reads the root again, later, and so still catches a root
// swapped mid-run.
function refuseRootThatIsNotADirectory(strRootMode) {
  process.stderr.write(
    'supply-freeze: refusing to record digests for a tree that is not the installed tree.\n' +
    '  node_modules       present, but not a directory\n' +
    `  root mode          ${strRootMode}\n` +
    '  npm ci creates node_modules as a real directory. A symlinked root points the\n' +
    '  install somewhere this record does not describe, however identical its contents.\n');
  process.exit(7);
}

if (!boolAnyToolchain) {
  let objRootLinkStats = null;
  try {
    objRootLinkStats = lstatSync(strTreeRoot);
  } catch {
    objRootLinkStats = null;
  }
  if (objRootLinkStats && !objRootLinkStats.isDirectory()) {
    refuseRootThatIsNotADirectory((objRootLinkStats.mode & 0o777).toString(8).padStart(3, '0'));
  }
}

const objBaselineChange = (() => {
  let objRootStats = null;
  try {
    objRootStats = statSync(strTreeRoot);
  } catch {
    objRootStats = null;
  }
  if (!objRootStats?.isDirectory()) {
    return {
      ctimeMs: 0,
      path: '(no walkable installed tree when recording began)',
      entries: new Map(),
    };
  }
  // Round 79/C. The escape refusal runs HERE, before the baseline walk, so an
  // external node_modules target is rejected rather than traversed on the way to
  // being rejected. lstat, not stat: a root that is not a symlink has nothing to
  // resolve, and asking stat would follow the very link this is guarding.
  // Round 80, reported by Codex against the guard added one commit earlier -- and
  // it is round 79's finding A recreated by the fix for finding C. A raced
  // node_modules (removed or swapped between the existsSync probe and this
  // lstat) threw OUTSIDE scanOrRefuse, so the ordinary concurrent-mutation case
  // became an exit-1 stack trace instead of the documented exit 10 or exit 7.
  //
  // Fixing an uncaught-throw instance and then writing a new uncaught throw two
  // commits later is the class going unswept: round 77 swept for guards that
  // silently narrow, never for throws outside the refusal wrapper. Both the
  // existence probe and the type read now sit inside it.
  scanOrRefuse(() => {
    if (existsSync(strTreeRoot) && lstatSync(strTreeRoot).isSymbolicLink()) {
      refuseEscapingTreeRoot(strTreeRoot);
    }
  }, 'the root type check before the baseline scan');
  return scanOrRefuse(
    () => newestChangeTime(strTreeRoot, [
    [strPackagePath, 'package.json'],
    [strLockPath, 'package-lock.json'],
    [strWorkflowDirectory, 'workflow directory'],
    [arrWorkflowAncestors[0], 'workflow parent directory'],
    [arrWorkflowAncestors[1], 'repository root'],
  ]),
    'the baseline quiescence scan');
})();

const strNodeVersion = process.version;

// Round 55, reported by Codex. npmChildEnv prepends this Node's own directory to
// the child PATH, which binds `npm` to the reviewed installation -- but only when
// npm is actually THERE. Copy or relocate the reviewed node binary without its
// npm beside it and that prepend resolves nothing, the inherited PATH decides,
// and the only thing authenticating the executable that answers is its own
// `--version` output.
//
// A replacement that prints `11.16.0` therefore passes the toolchain guard and
// then supplies every subsequent answer: the `config list` this script checks
// for install-shaping settings, the `ls` that asserts the tree satisfies the
// lockfile, and the `audit` that becomes the recorded advisory posture. That is
// a full forged record at `freezeRecord: true`, with an attacker-chosen set of
// advisories, and no field in the output would look wrong.
//
// Version text is not identity. The binding is positional and is now asserted
// rather than assumed: the npm that will run must exist in this Node's own
// directory, which is what the PATH prepend was always relying on. If it is not
// there, the run refuses instead of silently falling through to whatever the
// ambient PATH offers.
//
// Checked before the first npm subprocess, because every later guard reads an
// answer this one decides the provenance of. It is not gated on
// --any-toolchain: that flag waives which VERSIONS are acceptable, never whether
// the program answering is the one this process resolved.
//
// Round 56, reported by Codex, and the round-55 fix above shown to be worth
// almost nothing. Existence is not identity either. The reply that shipped it
// dismissed the residual as "a hostile npm written into the reviewed Node's own
// bin directory -- requires write access to the toolchain itself", and that
// dismissal was simply wrong: nobody has to write to the toolchain, because the
// node binary is world-readable and can be COPIED. Measured end to end, with no
// privileged access anywhere:
//
//   cp /opt/node24/bin/node   /tmp/x/node       # the genuine reviewed binary
//   cat > /tmp/x/npm <<'SH'   ... 9 lines ...   # replays captured npm output,
//   chmod +x /tmp/x/npm                         # with the advisories deleted
//   /tmp/x/node Get-SupplyFreezeDigest.mjs --json
//
//   -> freezeRecord: true, notFreezeRecordBecause: [],
//      treeSatisfiesLockfile: true, matchesReviewedManifest: true,
//      auditCounts {info:0,low:0,moderate:0,high:0,critical:0,total:0},
//      auditPackages {}
//
// process.version is genuinely v24.18.1 because it IS the reviewed binary, so
// the toolchain guard is satisfied honestly; existsSync passes because the
// attacker put a file there; and all seven real advisories are erased from a
// record that says, in its own output, that it is a freeze record.
//
// So npm is authenticated by its bytes. `dirname(execPath)/npm` in a Node
// distribution is a symlink into `lib/node_modules/npm`, and that whole
// installation is folded and compared against the digest of the npm shipped
// inside the reviewed Node archive. Two conditions, and neither alone is
// sufficient:
//
//   containment -- realpath(the npm that will run) must land INSIDE the folded
//                  tree. Folding a genuine tree while a different file executes
//                  as npm is exactly the gap this finding is about, one level in.
//   bytes       -- the folded tree must equal REVIEWED_NPM_TREE_SHA256, so a
//                  replicated directory layout is not enough; the attacker has
//                  to supply the real npm, at which point it is the real npm.
//
// REVIEWED_NPM_TREE_SHA256 was NOT taken from the container this was developed
// on. It is derived from node-v24.18.1-linux-x64.tar.xz downloaded from
// nodejs.org, whose SHA-256 was checked against the digest markdownlint.yml
// already pins before the archive was opened (build.yml does not fetch Node) --
// so the constant comes from the same bytes CI's markdownlint job extracts, not
// from a local directory of unknown
// provenance. Both fold to f5855634..., 1916 files and no symlinks.
//
// The byte comparison is gated on --any-toolchain and the containment check is
// not, which is the same line the version guard draws: that flag waives which
// VERSION is acceptable -- and a digest over a tree IS a version -- while never
// waiving whether the program answering is the one this process resolved.
//
// The residual, stated rather than implied, because the round-55 reply's
// residual was wrong and this one should not be taken on trust: the tree is
// folded at one instant and npm executes a moment later, so a replacement
// landing between them is not caught here. That is the same TOCTOU the script's
// own compile-to-read window has, it is not closable from inside the process,
// and it costs the attacker a race they previously did not have to win.
const strNpmBesideNode = join(dirname(process.execPath), 'npm');
if (!existsSync(strNpmBesideNode)) {
  process.stderr.write(
    'supply-freeze: refusing to run npm that is not bound to this Node installation.\n' +
    `  node               ${formatUntrustedText(process.execPath)}\n` +
    `  expected npm at    ${formatUntrustedText(strNpmBesideNode)}\n` +
    // Round 61, reported by Codex, and this text is my own round-60 change left
    // undescribed. It still explained the PATH forgery that round 60 removed:
    // npm is no longer resolved through PATH at all, so "the ambient PATH
    // decides which program answers" stopped being true in the same commit that
    // made this refusal matter for a different reason.
    '  the launcher is how this script LOCATES and authenticates the npm command\n' +
    '  line: it resolves bin/npm through its symlink, requires the result to sit\n' +
    '  inside lib/node_modules/npm, and folds that installation against the npm\n' +
    '  shipped in the reviewed Node archive. Without it there is nothing to\n' +
    '  resolve, so there is nothing to authenticate -- and a version string npm\n' +
    '  prints about itself is not evidence about which program printed it.\n' +
    '  run the recorder with a complete Node installation, not a relocated binary.\n');
  process.exit(2);
}
const objNpmInstallation = npmInstallationRootOrRefuse();
const strNpmTreeRoot = objNpmInstallation.root;
const strNpmCli = objNpmInstallation.cli;
// Found by the uncaught-throw class sweep, which round 79's finding A called for
// and which nothing had actually run until now. Round 77 swept for guards that
// silently NARROW their coverage; this is the other half -- calls that THROW
// outside the refusal wrapper.
//
// npmInstallationRootOrRefuse() resolved strNpmCli on the line above, and the
// line below is already a scanOrRefuse. Remove or swap npm-cli.js in that window
// and this threw ENOENT uncaught: an exit-1 stack trace where the documented
// answer is a refusal. The omission is glaring only because its neighbour is
// wrapped, which is exactly why it survived seventy-odd rounds.
//
// The full sweep found three module-scope fs calls outside scanOrRefuse. The
// other two -- realpathSync and readFileSync on the script's own path at startup
// -- are NOT defects and are deliberately left alone: they run before anything is
// recorded, so there is no record to protect and no refusal to make.
// Round 80/C, Codex, against the wrap added one commit earlier. Routing this
// through scanOrRefuse fixed the uncaught throw but reported exit 10 -- "the
// recorded inputs changed" -- for what is actually the npm command line failing
// to stay readable before its authenticated inode baseline exists. The table
// classifies an unreadable or unauthenticated npm installation as exit 2, so the
// generic tree-quiescence diagnostic sent operators hunting a repository mutation
// instead of a toolchain swap. Right guard, wrong answer.
let intNpmCliInode;
try {
  intNpmCliInode = lstatSync(strNpmCli, { bigint: true }).ino;
} catch (objError) {
  process.stderr.write(
    'supply-freeze: refusing to verify an npm installation that cannot be read.\n'
    + `  npm command line   ${formatUntrustedText(strNpmCli)}\n`
    + formatErrorLocation(objError, strNpmCli)
    + '  it was located and authenticated moments ago, so the toolchain changed\n'
    + '  underneath this run.\n');
  process.exit(2);
}
const objNpmTree = scanOrRefuse(
  () => foldNpmInstallation(strNpmTreeRoot, strNpmBesideNode), 'the npm installation fold');
// Round 58, reported by Codex: REVIEWED_NPM_TREE_FILES was printed in the
// refusal and never compared, so it documented a number rather than asserting
// one. It is an independent backstop now -- the digest is the primary check and
// the census fails on a different property, so an encoding weakness in one is
// not a weakness in both.
if (!boolAnyToolchain && (objNpmTree.sha256 !== REVIEWED_NPM_TREE_SHA256
  || objNpmTree.files !== REVIEWED_NPM_TREE_FILES)) {
  process.stderr.write(
    'supply-freeze: refusing to trust an npm installation that is not the reviewed one.\n' +
    `  node               ${formatUntrustedText(process.execPath)}\n` +
    `  npm installation   ${formatUntrustedText(strNpmTreeRoot)}\n` +
    `  observed           ${objNpmTree.sha256} (${objNpmTree.files} files, ${objNpmTree.symlinks} symlinks)\n` +
    `  reviewed           ${REVIEWED_NPM_TREE_SHA256} (${REVIEWED_NPM_TREE_FILES} files, 0 symlinks)\n` +
    '  the version string npm prints is written by npm, so it cannot establish which\n' +
    '  program printed it. A copied node with a script named npm beside it passes a\n' +
    '  version check and an existence check alike, and then supplies the configuration,\n' +
    '  the lockfile assertion and the advisory posture -- measured, erasing every\n' +
    '  advisory while the output still said freezeRecord: true.\n' +
    '  install the reviewed Node distribution whole, or pass --any-toolchain to record\n' +
    '  explicitly-unreviewed output.\n');
  process.exit(2);
}
const strNpmVersion = runNpmOrRefuse(['--version'], undefined, 2,
  'the reviewed npm could not report its version.').trim();

// Round 26, reported, and the most serious finding this script has taken.
// NODE_OPTIONS=--require runs a module before the first statement of this file,
// so every answer below can be replaced before it is ever computed. Measured
// here: a preload that patches child_process.execFileSync, calls
// module.syncBuiltinESMExports() and redefines process.version turned a run
// that refuses with exit 2 on this container's Node v22.22.2 into
//
//   freezeRecord: true, notFreezeRecordBecause: [], treeSatisfiesLockfile: true,
//   matchesReviewedManifest: true, auditCounts all zero
//
// on an unreviewed toolchain, erasing 7 genuine advisories. Nothing downstream
// could have caught it, because the forgery is upstream of everything.
//
// This check is HYGIENE, NOT A SECURITY BOUNDARY, and the record says so in the
// same words. Code that runs first wins: a preload ending with
// `delete process.env.NODE_OPTIONS` leaves this reading undefined. Measured --
// with that one extra line the variable reads null while the patched
// execFileSync is still in place. What closes the hole is clearing the variable
// BEFORE node starts, which is why the documented command is now
// `env -u NODE_OPTIONS node ./Get-SupplyFreezeDigest.mjs`.
//
// What it does buy is the accidental case: a runner or shell that exports
// NODE_OPTIONS for unrelated reasons no longer silently shapes a freeze record.
//
// Blanket rather than a list of preload spellings. Rounds 23 and 24 each
// extended a denylist over this exact variable and each was still incomplete --
// --use-system-ca=true and five other spellings survived the second one. A
// third attempt at enumerating NODE_OPTIONS syntax is not warranted, and the
// cost is only that a benign --max-old-space-size must be cleared too.
// Round 35, reported by Codex. The value is not printed. NODE_OPTIONS is as
// attacker-controlled as the trust variables scrubbed for the audit, and it
// carries the same freight: a --require path exposes a username and a layout,
// an --import URL can carry a host or a token. The scrub above this file
// records those by NAME ONLY for exactly that reason, and refusal output goes
// to the same CI logs the record does -- so echoing this one in full defeated
// that rule one screen away from where it is stated. Presence and length are
// enough to act on: the operator re-runs with `env -u NODE_OPTIONS` either way,
// and length distinguishes "set to empty" from "set to something".
if (!boolAnyToolchain && typeof process.env.NODE_OPTIONS === 'string') {
  process.stderr.write(
    'supply-freeze: refusing to record digests with NODE_OPTIONS set.\n' +
    `  NODE_OPTIONS       present, ${process.env.NODE_OPTIONS.length} characters (value not shown)\n` +
    '  --require and --import execute code before this script does, so any answer\n' +
    '  it reports can be forged. run the documented command instead:\n' +
    '    use the verified Node and external cache command in docs/P1-SUPPLY-FREEZE-v1.md\n' +
    '  this is a hygiene check, not a security boundary -- a preload can unset the\n' +
    '  variable before this line runs. see the residuals in the record.\n');
  process.exit(2);
}

// A symlinked entry point is not the reviewed invocation: the reviewed command
// runs this file directly. Refused alongside the toolchain because it is the
// same question -- is this the environment the record was made in -- rather than
// a twelfth exit number for a cause exit 2 already names.
if (!boolAnyToolchain && boolEntryPointIsLink) {
  process.stderr.write(
    'supply-freeze: refusing to record digests from a symlinked entry point.\n' +
    // Round 40, reported by Codex. Both paths used to be printed here. Whoever
    // creates the link chooses its NAME as well as its target, so a link called
    // `USER_token-SUPPLYSECRET.mjs` put that string verbatim into `invoked as`
    // -- measured, one occurrence in the refusal output -- and CI retains logs.
    //
    // Neither path is printed now. Whoever invoked the command already knows the
    // path they typed, and the resolved target is this file; nothing here needs
    // the log to tell them. This is the same names-only rule the trust scrub and
    // the escaping-link refusal state.
    '  the path used to invoke this script is a symlink; neither it nor its target\n' +
    '  is printed, because both are chosen by whoever created the link.\n' +
    '  under --preserve-symlinks-main the source Node compiles is the target, not\n' +
    '  the link. Run the file directly so the script identity is unambiguous.\n');
  process.exit(2);
}

if (!boolAnyToolchain && (strNodeVersion !== REVIEWED_NODE || strNpmVersion !== REVIEWED_NPM
  || process.platform !== REVIEWED_PLATFORM || process.arch !== REVIEWED_ARCH)) {
  process.stderr.write(
    'supply-freeze: refusing to record digests on an unreviewed toolchain.\n' +
    // Round 45, swept from the reported argument defect. strNpmVersion is the
    // stdout of a subprocess, so it is not a value this process computed. NOT
    // demonstrated exploitable: the PATH pin puts node's own directory first and
    // npm ships beside node, so a planted npm earlier in the inherited PATH never
    // wins -- measured, a fake npm printing a forged line was simply not reached.
    // That is one layout's accident rather than a property of this script, and
    // this refusal exists precisely to report a toolchain it does not trust.
    `  observed Node ${formatUntrustedText(strNodeVersion)}, npm ${formatUntrustedText(strNpmVersion)}, ${process.platform}/${process.arch}\n` +
    `  reviewed Node ${REVIEWED_NODE}, npm ${REVIEWED_NPM}, ${REVIEWED_PLATFORM}/${REVIEWED_ARCH}\n` +
    '  pass --any-toolchain to compute anyway; the result is then not a freeze record.\n');
  process.exit(2);
}

// This script's own digest, reported alongside the values it derives.
//
// Raised while answering the reproduction-steps finding, and it is the reason
// that finding is more than a documentation fix: "run the script and compare"
// is ambiguous unless the reader knows WHICH script. Review has moved the
// installed-tree digest several times without any dependency changing -- making
// the fold injective, then recording execute bits, then hashing symlink targets
// as raw bytes. That is exactly the confusion a reader would hit: a correct
// tree, a correct lockfile, and a number that does not match, with nothing in
// the record to explain why.
//
// No digest is quoted anywhere in this file's comments, and round 13 is when
// that finally became true. A comment claiming exactly this sat beside
// comments quoting the installed-tree digest -- which by then had moved twice
// and so were wrong, demonstrating the claim while contradicting it. A number
// in a comment has nothing deriving it and goes stale silently; the record
// holds the authoritative values and the script regenerates them.
//
// No circularity: the digest is computed over the file and never stored in it.
// The digest itself is computed at the very top of this file; see there for why.
// This comment stays here because it explains WHY the field exists at all.

// Install-shaping configuration, checked before anything is measured. See
// REVIEWED_NPM_CONFIG above for why: the toolchain guard passes a reader whose
// ambient npm configuration silently produced a different tree.
// npm serializes an unset `noproxy` as [''] rather than [] -- its config
// definition is `default: ''` with type [String, Array], so the empty string
// survives into the array form. Round 21, reported as P1: comparing against []
// therefore treated npm's own default as drift and exited 6 before the audit on
// an otherwise clean machine, which would have blocked the primary freeze record
// from ever being regenerated.
//
// Not reproducible on this host -- its npm reports a populated noproxy from
// configuration rather than the environment -- so this rests on the reporter's
// measurement across npm 10.9.8 and 11.4.2 plus npm's documented default. The
// normalization is correct either way: '', [] and [''] all mean "no exclusions".
function normalizeConfigValue(objValue) {
  const arrValue = Array.isArray(objValue) ? objValue : [objValue];
  const arrMeaningful = arrValue.filter(
    (objEntry) => objEntry !== '' && objEntry !== null && objEntry !== undefined);
  return Array.isArray(objValue) || objValue === '' ? arrMeaningful : objValue;
}

// Round 36, reported by Codex. Keys whose OBSERVED value must never be printed.
// A rejected `proxy` or `https-proxy` is a URL and can carry credentials; `ca`
// is a private trust anchor; `cafile` is a path that can name a username or an
// internal layout. The refusal text goes to CI logs, so printing them there is
// the same leak the NODE_OPTIONS refusal was fixed for one round earlier, and
// the audit scrub two hundred lines up already records this exact class of input
// by name only, for this exact reason.
//
// A key belongs here when its value can carry a host, a username, a token or a
// key. The membership test is the value's SHAPE, not which table it lives in --
// which is why this is a property consulted by the formatter rather than a flag
// passed at one call site. REVIEWED_NPM_CONFIG's keys are booleans, small
// enumerations and an integer umask; none can carry a secret, and their observed
// values are the whole diagnostic point of that refusal, so they still print.
//
// The REVIEWED value is always printed, for every key. Those are literals in
// this file, visible to anyone reading the source, so redacting them would cost
// the reader the comparison while protecting nothing.
//
// Round 48, reported by Codex. `noproxy` was missing, and it is the one key in
// REVIEWED_NPM_TRANSPORT whose value is LITERALLY A LIST OF HOSTS. Measured on
// the drift line this set feeds:
//
//   NPM_CONFIG_NOPROXY=private-user.internal,SUPPLYSECRET.example
//     -> noproxy  observed ["private-user.internal","SUPPLYSECRET.example"], …
//
// Applying the membership test written two paragraphs up decides this on its own
// -- "a key belongs here when its value can carry a host" -- so the omission was
// not a judgement that noproxy is safe, it was the test not being run over the
// whole table. Four of the six transport keys were covered; `strict-ssl` is a
// boolean and needs no cover; `noproxy` was the gap.
//
// The paragraph above also said REVIEWED_NPM_CONFIG's keys "are booleans, small
// enumerations and an integer umask", which is true of that table and was doing
// duty as if it described both. configDrift formats BOTH tables -- the transport
// one at its own call site -- and that is exactly the "the membership test is the
// value's shape, NOT WHICH TABLE IT LIVES IN" sentence failing on the table it
// was written to distinguish.
//
// Every reviewed value in this set is null except noproxy's, which is []. Neither
// can leak, so the null-vs-set rendering below still says which side differs
// without printing a host.
const SENSITIVE_CONFIG_KEYS = Object.freeze(['proxy', 'https-proxy', 'noproxy', 'ca', 'cafile']);

// Round 37, reported by Codex, and the third round running on one class. Rounds
// 35 and 36 each fixed the reported site: NODE_OPTIONS, then the transport
// values. Round 36's fix was described as covering the class and did not -- it
// made configDrift's OUTPUT safe, which is a fix to one formatter, while the
// registry refusal builds its line by hand and prints the URL verbatim. Fixing
// the class means every path by which a URL reaches output, so this is applied
// at the three that exist rather than at the one reported.
//
// A URL carries its secrets in two places: userinfo (`https://user:token@host`)
// and the query. Both are removed; scheme, host and path are kept, because a
// reader needs to see WHICH registry was refused for the message to be worth
// printing at all. Measured: the reviewed registry has neither part, so this is
// a no-op on every non-bypassed run.
function redactUrl(strValue) {
  try {
    const objUrl = new URL(strValue);
    // Round 38, reported by Codex, and it is this helper's own comment being
    // wrong one round after it was written. That comment said scheme, host and
    // path are kept "because a reader has to see WHICH registry was refused" --
    // but the host answers that question, and the PATH is as free-form as the
    // query. Measured: NPM_CONFIG_REGISTRY=https://host/SUPPLYSECRET/ is
    // returned verbatim by npm, so the token rode out in the pathname of a value
    // this function had already declared safe.
    //
    // The path is dropped rather than kept, and the boundary is exact: a
    // pathname of `/` is what a bare origin produces, so the reviewed registry
    // https://registry.npmjs.org/ is returned CHARACTER-IDENTICAL and the
    // compared row does not move. Anything longer is withheld.
    const boolPathCarries = objUrl.pathname !== '/' && objUrl.pathname !== '';
    const boolCarriedSecret = objUrl.username !== '' || objUrl.password !== ''
      || objUrl.search !== '' || objUrl.hash !== '' || boolPathCarries;
    const strSafe = `${objUrl.protocol}//${objUrl.host}${boolPathCarries ? '/' : objUrl.pathname}`;
    return boolCarriedSecret ? `${strSafe} (path, credentials and query redacted)` : strSafe;
  } catch {
    // Round 38, reported by Copilot, in the round-37 fix above and in the
    // sentence defending it. This returned strValue unchanged, on the reasoning
    // that a malformed registry value is itself the diagnostic and that this
    // helper should not decide an unparseable string is a secret. That is a
    // redactor that FAILS OPEN, and the reasoning was backwards: an unparseable
    // string is exactly the case where nothing has inspected the value, so it is
    // the one to withhold rather than the one to trust.
    //
    // Measured: `registry.example.invalid/path?token=...` throws in new URL()
    // because it has no scheme, so the token was returned verbatim and reached
    // both the refusal text and objRecord.registry. The parseable case that
    // carries the same token was redacted; the malformed one was not.
    //
    // Length and the fact of being unparseable are kept, matching what the
    // NODE_OPTIONS refusal reports. That is the whole of the diagnostic the old
    // branch was defending -- "this value is not a URL" -- without the payload.
    return `unparseable, ${strValue.length} characters (value not shown)`;
  }
}

// npm's own error text embeds the full request URL, which is how the same token
// escapes through a guard that never touches the registry setting. Measured, an
// audit against a credentialed registry returns:
//   request to https://host/path?token=... failed, reason: connect ECONNREFUSED
// so the message cannot be forwarded verbatim either.
// Round 44, reported by Codex against the record's package names. Sweeping the
// class rather than the site: this is the ONE funnel every piece of untrusted
// text passes through on its way to an operator, and it redacted urls while
// leaving control characters intact. Three sinks were affected -- npm's non-JSON
// output, the endpoint's own `message`, and normalizeAudit's TypeErrors, which
// embed report package names and field values.
//
// Renamed from redactUrlsInText because it now does both jobs and the name has to
// say so; a caller reaching for "redact" would not have guessed it also escapes.
//
// Escaping happens HERE, at the print site, and deliberately not where these
// names are hashed. formatTreeName is not injective -- a name holding the literal
// four characters \x0a and a name holding a real newline escape to the same
// string -- so escaping before the digest would create exactly the collision
// class rounds 43 and 44 have been closing. The JSON record keeps the raw bytes,
// where JSON.stringify escapes them losslessly.
//
// Round 46, reported by Codex, in the redaction added one round earlier for the
// unrecognized-argument defect. The prefilter matched lowercase http/https only,
// so the case of the scheme decided whether a credential was withheld. Measured
// on the same secret, twice:
//
//   --registry=https://registry.example.invalid/path?token=SUPPLYSECRET
//     -> https://registry.example.invalid/ (path, credentials and query redacted)
//   --registry=HTTPS://registry.example.invalid/path?token=SUPPLYSECRET
//     -> printed verbatim, token included
//
// The referee, again, is a specification rather than my judgement: RFC 3986
// section 3.1 says scheme names are case-insensitive, and the WHATWG URL parser
// lowercases the scheme, so `new URL('HTTPS://h/')` has protocol 'https:'. This
// prefilter feeds that parser and disagreed with it about what a URL is -- the
// same shape as round 45's escaper disagreeing with ECMA-262 about what ends a
// line. A prefilter is allowed to be broader than its parser; it must never be
// narrower.
//
// Round 48, reported by Codex, and it is the sentence directly above being
// violated by the same expression two rounds later. The class excluded the two
// quote characters, so a quote inside a URL ENDED the match and everything after
// it was printed untouched. Measured on the unrecognized-argument refusal:
//
//   --registry=https://host/a'b?token=SUPPLYSECRET
//     -> https://host/ (path, credentials and query redacted)'b?token=SUPPLYSECRET
//   --registry=https://host/a"b?token=SUPPLYSECRET
//     -> https://host/ (path, credentials and query redacted)"b?token=SUPPLYSECRET
//   --registry=https://host/ab?token=SUPPLYSECRET        (the control)
//     -> https://host/ (path, credentials and query redacted)
//
// That output is worse than no redaction: it carries the parenthetical that says
// the query was withheld and then prints the query. `'` is a sub-delim under RFC
// 3986 section 2.2 and legal in a path; `"` is not, but the WHATWG parser accepts
// it and percent-encodes it, and `new URL()` -- the parser this prefilter feeds
// -- takes both. So both were narrower than the parser, which is the one thing
// the rule above forbids.
//
// The class was made whitespace-delimited: a run of non-space characters after
// the scheme, on the reasoning that trailing punctuation gets swallowed into the
// redaction rather than left outside it, and that redactUrl fails CLOSED on
// anything it cannot parse. That comment then claimed "there is no character this
// can now stop at except whitespace, so there is no third quote-like character
// waiting to be found in round 49."
//
// Round 49, reported by Codex, and that sentence was wrong in the round it named.
// Whitespace IS a character the parser accepts inside a URL: the WHATWG parser
// percent-encodes an internal space rather than ending the URL there. Measured
// through the same refusal:
//
//   new URL('https://host/a b?token=SUPPLYSECRET')
//     -> https://host/a%20b?token=SUPPLYSECRET        (accepted)
//   --registry=https://host/a b?token=SUPPLYSECRET
//     -> https://host/ (path, credentials and query redacted) b?token=SUPPLYSECRET
//
// The tab form behaves the same way. So the previous fix moved the boundary from
// two characters to one and left the shape of the defect exactly as it was.
//
// The real lesson is that NO delimiter works. A scanner has to decide where a URL
// ends, and the parser this scanner feeds accepts every character including
// whitespace -- so for any terminator chosen, a URL containing it is narrower than
// the parser, which is the one thing the rule above forbids. Enumerating
// terminators was never going to converge; that is why this is the third round on
// one expression.
//
// The only rule that is broader than the parser is to stop at nothing: from the
// scheme to the END OF THE LINE. A line terminator is the one thing that cannot
// sit inside a URL in this output, because the escaper below turns every line
// separator into a printable escape before anything is written.
//
// This also settles the case reported as "match the complete option value". Each
// argv element is formatted by its OWN call -- the callers map over arguments and
// join afterwards -- so for an argument, end-of-line and end-of-value are the same
// boundary, and the whole value is redacted without a separate code path.
//
// The cost is real and is accepted rather than hidden: text AFTER a url on the
// same line is withheld too, so npm's `request to <url> failed, reason: ECONNREFUSED`
// now reports the host and loses the reason. A withheld diagnostic is recoverable
// by rerunning; a published credential is not, and this output goes to CI logs.
//
// Round 50, reported by Codex, and it is the paragraph above being wrong about
// its own file. That paragraph defended end-of-line as the boundary by saying a
// line terminator "cannot sit inside a URL in this output, because the escaper
// below turns every line separator into a printable escape before anything is
// written". The escaper ran AFTER the scan, so at SCAN time a terminator was
// still a terminator -- a sentence true of the output, applied to the input.
// Measured on the unrecognized-argument refusal, separator between path and
// query:
//
//   --registry=https://host/a<LF>b?token=SUPPLYSECRET
//     -> https://host/ (path, credentials and query redacted)\x0ab?token=SUPPLYSECRET
//   --registry=https://host/a<U+2028>b?token=SUPPLYSECRET
//     -> https://host/ (path, credentials and query redacted)\u{2028}b?token=SUPPLYSECRET
//
// CR and U+2029 behave as LF and U+2028 do. `new URL()` takes all four: it
// DELETES tab, LF and CR from its input and percent-encodes U+2028 and U+2029.
// So the prefilter was narrower than the parser it feeds for the third time --
// now on the one character class the round-49 rule was written around.
//
// The ORDER is inverted rather than the class widened again: escape first, then
// scan. After formatTreeName no line terminator exists anywhere in the string, so
// the class stops at nothing and round 49's sentence becomes true of the text
// being scanned rather than of text already printed. The class is kept rather
// than written `.`, which means exactly this under ECMA-262, because an
// expression that names its own boundary survives an edit that moves the escaper.
//
// Handing redactUrl already-escaped text is safe because that helper's output
// cannot carry what the escaper would have caught: for http and https the WHATWG
// host parser strips tab, LF, CR and the zero-width formats and REFUSES every
// other Cc/Cf/Zl/Zp code point, so protocol and host are printable ASCII, and the
// unparseable branch prints a length rather than a value. Probed over twelve such
// code points in three host positions -- every one either vanished or threw.
// Round 51, reported by Codex, and it is the round-50 fix directly above opening
// the hole it was written to close. Escaping FIRST rewrites tab, LF and CR into
// printable `\xNN`, which breaks the literal `https` the prefilter matches --
// while the parser DELETES those same three characters and parses happily.
// Measured on the unrecognized-argument refusal:
//
//   --registry=ht<LF>tps://host/a?token=ROUND51SECRET
//     new URL() -> https://host/a?token=ROUND51SECRET   (accepted)
//     printed   -> --registry=ht\x0atps://host/a?token=ROUND51SECRET
//
// CR and TAB behave the same, at every position inside the scheme. So the
// prefilter was narrower than its parser for the FOURTH round running, this time
// because the previous round's fix put an escaper in front of it.
//
// The referee is normative rather than mine. The WHATWG URL Standard's basic URL
// parser removes "all ASCII tab or newline" from its input and defines that set
// as exactly U+0009, U+000A and U+000D. Enumerating a set a specification CLOSES
// is not the guessing rounds 47-49 lost to -- it is reading the parser's own rule.
//
// The scan therefore runs on the RAW text and is broader than the parser on both
// axes the parser is permissive about: the scheme tolerates those three
// characters interleaved anywhere inside it, and the body is `[\s\S]*`, every
// character to end of string. That second half is what round 50 bought by
// escaping first, kept here without an escaper standing in front of the scan.
// The three characters are then removed before redactUrl, exactly as the parser
// removes them, so the span scanned and the string the parser sees are one URL.
//
// Escaping is applied LAST again -- to the untouched prefix, and to redactUrl's
// output as belt and braces. The latter is a no-op today, since that output is
// printable ASCII, but it means a future edit to redactUrl cannot forge a line.
//
// One redaction per call, because the body runs to end of string. That makes the
// withheld-line count exact, and it is now REPORTED rather than left silent:
// round 50 quietly widened the accepted cost from "text after a url on the same
// line" -- which the paragraph above still claimed -- to "every following line".
// Swept here rather than waiting to be told. Measured, an npm failure block lost
// all three of its `npm ERR!` lines with nothing in the output saying so.
// Swept in round 52, before a reviewer reached it, and it is the sentence three
// paragraphs up being wrong in the round that wrote it. That sentence claimed the
// scan is "broader than the parser on both axes the parser is permissive about".
// There is a THIRD axis. For a special scheme the parser does not require `//` at
// all: its special-authority-ignore-slashes state skips any run of U+002F and
// U+005C, including an empty run. Measured, all four accepted and all four
// leaking through a scan that demanded exactly two forward slashes:
//
//   https:host/a?token=...    -> https://host/a?token=...   (accepted, leaked)
//   https:/host/a?token=...   -> https://host/a?token=...   (accepted, leaked)
//   https:\\host/a?token=...  -> https://host/a?token=...   (accepted, leaked)
//   https:/\host/a?token=...  -> https://host/a?token=...   (accepted, leaked)
//
// So the separator is any run of either slash, or none, with the deleted
// characters interleaved -- the parser's own rule rather than a slash count I
// picked. Backslashes are NOT stripped before redactUrl the way tab, LF and CR
// are: the parser converts those itself, and removing them here would be this
// file editing a url rather than reading one.
//
// The cost of allowing an EMPTY run is real and accepted on the standing
// reasoning: prose containing a bare `https:` now has the rest of its line
// withheld, because nothing distinguishes that from a url this parser accepts.
// redactUrl fails closed on it and prints a length rather than the text. A
// withheld diagnostic is recoverable by rerunning; a published credential is not.
// The three expressions above are declared at the top of the module; see the
// note there for why position matters.
function formatUntrustedText(strText) {
  const strRaw = String(strText);
  const intUrlAt = strRaw.search(RE_URL_IN_TEXT);
  if (intUrlAt < 0) {
    return formatTreeName(strRaw);
  }
  const strTail = strRaw.slice(intUrlAt);
  // Two round-52 corrections, one swept and one reported by Codex.
  //
  // The count was overstated: a tail ending in a line terminator reported one
  // further line withheld when no further line followed it, and npm output
  // routinely ends in a newline. A terminator at the very end introduces no
  // line, so it is not counted.
  //
  // And it is counted WITHOUT materializing the matches. `split` and `match`
  // both allocate one array element per line -- for `split`, a substring each.
  // The audit subprocess is permitted 64 MiB of output, so a schema-invalid
  // response whose message carries millions of newlines would allocate hundreds
  // of megabytes to compute a single integer, and die of memory pressure in
  // place of the documented exit 5. An incremental scan holds one match at a
  // time regardless of input size.
  let intWithheld = 0;
  let intLastEnd = -1;
  RE_LINE_BREAK.lastIndex = 0;
  for (let objBreak = RE_LINE_BREAK.exec(strTail); objBreak !== null;
    objBreak = RE_LINE_BREAK.exec(strTail)) {
    intWithheld += 1;
    intLastEnd = objBreak.index + objBreak[0].length;
  }
  if (intLastEnd === strTail.length) {
    intWithheld -= 1;
  }
  return formatTreeName(strRaw.slice(0, intUrlAt))
    + formatTreeName(redactUrl(strTail.replace(RE_PARSER_DELETES, '')))
    + (intWithheld > 0
      ? ` (and ${intWithheld} further line${intWithheld === 1 ? '' : 's'} withheld)`
      : '');
}

function configDrift(objReviewed, objEffective) {
  return Object.entries(objReviewed)
    .filter(([strKey, objExpected]) =>
      canonicalize(normalizeConfigValue(objEffective[strKey] ?? null))
        !== canonicalize(normalizeConfigValue(objExpected)))
    .map(([strKey, objExpected]) => {
      const objObserved = objEffective[strKey] ?? null;
      const strObserved = SENSITIVE_CONFIG_KEYS.includes(strKey)
        // Null is printed as itself: it is the reviewed value for every key in
        // this set except noproxy, whose reviewed value is the empty list, so
        // "observed null" cannot leak anything and saying so is more useful than
        // a redaction marker that hides which side differs. Neither an absent
        // value nor an empty one carries a host, and any noproxy that DRIFTS is
        // populated by definition -- '', [] and [''] all normalize to "no
        // exclusions" and so never reach this line -- which is why the populated
        // case is the only one that has to be withheld.
        ? (objObserved === null ? 'null' : 'set (value not shown)')
        // Round 61, reported by Codex. These are the INSTALL-shaping keys, and
        // the transport branch above was withheld while this one was rendered
        // raw -- on the assumption that omit, include, install-strategy and the
        // rest cannot carry a secret. npm does not enforce that. Measured on npm
        // 11.16.0, `NPM_CONFIG_OMIT=https://user:SECRET@host/p?token=X` is
        // accepted and comes back verbatim in the omit array, so the exit-6
        // refusal published both credentials into a retained log.
        //
        // The rule this file already applies everywhere else is that a value
        // this process did not compute goes through the funnel, whatever key it
        // arrived under. An argument about which keys can hold a URL is the same
        // shape as the scheme allowlist rounds 47-59 spent seven rounds
        // retiring: a list of safe cases that npm, not this script, decides.
        // Round 64, reported by Codex, and the round-61 fix above caught being
        // a URL redactor where a value withholder was needed. That round routed
        // these through formatUntrustedText on the reasoning that "a value this
        // process did not compute goes through the funnel" -- which is correct
        // and insufficient, because the funnel only withholds from a URL SCHEME
        // onward. Measured by Codex on npm 11.16.0: `NPM_CONFIG_OMIT=hunter2`
        // comes back as `omit: ["hunter2"]`, is not URL-shaped, and was printed
        // verbatim into the retained exit-6 log.
        //
        // So the value is described rather than rendered -- but only the parts
        // that can carry a secret. A boolean or a number cannot, and they are
        // the diagnostic a caller actually needs: someone who set
        // bin-links=false must see `false` to understand the refusal. Strings
        // are the only shape that can hold a credential, so strings become a
        // length and everything else prints.
        : formatObservedConfig(objObserved);
      return `  ${strKey.padEnd(18)} observed ${strObserved}, reviewed ${JSON.stringify(objExpected)}`;
    });
}

// Describes an observed configuration value without emitting any string it
// contains. Booleans and numbers are rendered because they cannot carry a
// secret and are what makes this refusal actionable; strings are reduced to a
// length; arrays are described element-wise so `omit: []` -- the reviewed value
// and by far the most common observation -- still reads as an empty array
// rather than as an opaque placeholder.
function formatObservedConfig(objObserved) {
  const describe = (objValue) => {
    if (objValue === null) return 'null';
    if (typeof objValue === 'boolean' || typeof objValue === 'number') {
      return JSON.stringify(objValue);
    }
    if (typeof objValue === 'string') {
      return `(string withheld, ${objValue.length} characters)`;
    }
    if (Array.isArray(objValue)) return `[${objValue.map(describe).join(', ')}]`;
    return '(value withheld)';
  };
  return describe(objObserved);
}

if (!boolAnyToolchain) {
  const objEffective = parseNpmJsonOrRefuse(
    runNpmOrRefuse(['config', 'list', '--json'], undefined, 6,
      'npm could not report its effective configuration.'), 'npm config list', 6);
  const arrDrift = configDrift(REVIEWED_NPM_CONFIG, objEffective);
  if (arrDrift.length > 0) {
    process.stderr.write(
      'supply-freeze: npm configuration would shape the install away from the reviewed tree.\n' +
      `${arrDrift.join('\n')}\n` +
      '  these come from the environment or a user/global .npmrc and change what npm ci produces.\n' +
      '  re-install with them at their reviewed values before recording a freeze.\n');
    process.exit(6);
  }
}

// The process umask, which npm's own config does not report. See REVIEWED_UMASK.
//
// This reads the umask of the RECORDING process, which is a proxy for the one
// the install ran under -- the same install-time/measure-time gap the
// package-lock-only guard has. It catches the common case, where one shell does
// both. For the case where it cannot see the cause, the permission-bit
// histogram recorded below is the backstop: it records the observed modes
// themselves, so umask 022 (644/755), 027 (640/750) and 077 (600/700) are all
// distinguishable from the record alone -- as is any other umask, which a
// predicate over a single chosen bit could not manage.
if (!boolAnyToolchain && intObservedUmask !== REVIEWED_UMASK) {
  process.stderr.write(
    'supply-freeze: refusing to record digests under an unreviewed umask.\n' +
    `  umask              observed ${strObservedUmask}, `
      + `reviewed 0${REVIEWED_UMASK.toString(8).padStart(3, '0')}\n` +
    '  npm applies the process umask when it extracts, so this changes the recorded\n' +
    '  execute bits and therefore the installed-tree digest.\n' +
    '  re-install and re-record under the reviewed umask:\n' +
    `    (umask 0${REVIEWED_UMASK.toString(8).padStart(3, '0')}; `
      + 'npm ci --ignore-scripts --no-audit --no-fund)\n'
      + strWorkspaceReinstallNote);
  process.exit(8);
}

const objRecord = {
  script: { sha256: strScriptSha256 },
  toolchain: {
    node: strNodeVersion,
    npm: strNpmVersion,
    // Round 56. Emitted because the guard that produced it refuses on mismatch,
    // so a reader holding this output can see WHICH npm answered rather than
    // taking on faith that some check passed. `npm` above is what npm says
    // about itself; this is what its bytes say.
    npmTree: objNpmTree.sha256,
    platform: process.platform,
    arch: process.arch,
    umask: strObservedUmask,
  },
  manifest: {
    'package.json': sha256(objPackageBefore),
    'package-lock.json': sha256(objLockBefore),
  },
  manifestBlobs: {
    'package.json': gitBlobId(objPackageBefore),
    'package-lock.json': gitBlobId(objLockBefore),
  },
  matchesReviewedManifest:
    sha256(objPackageBefore) === REVIEWED_PACKAGE_SHA256 &&
    sha256(objLockBefore) === REVIEWED_LOCK_SHA256 &&
    gitBlobId(objPackageBefore) === REVIEWED_PACKAGE_BLOB &&
    gitBlobId(objLockBefore) === REVIEWED_LOCK_BLOB,
};

// Reported and confirmed: this used to record `matchesReviewedManifest: false`
// and then print a full record and exit 0, which contradicted the comment on the
// pinned constants above and let an automated caller reading the process status
// accept digests taken over supply inputs nobody reviewed. Refusing here, before
// node_modules is even opened, is what that comment already claimed.
if (!boolAnyToolchain && !objRecord.matchesReviewedManifest) {
  process.stderr.write(
    'supply-freeze: refusing to record digests for an unreviewed manifest.\n' +
    `  package.json       observed ${objRecord.manifest['package.json']}\n` +
    `                     reviewed ${REVIEWED_PACKAGE_SHA256}\n` +
    `  package-lock.json  observed ${objRecord.manifest['package-lock.json']}\n` +
    `                     reviewed ${REVIEWED_LOCK_SHA256}\n` +
    `  package.json       blob     ${gitBlobId(objPackageBefore)}\n` +
    `                     reviewed ${REVIEWED_PACKAGE_BLOB}\n` +
    '  a changed manifest needs a new reviewed freeze, not a digest against this one.\n');
  process.exit(4);
}

// `npm ls` is kept, but as a consistency assertion rather than a digest source:
// it exits non-zero when the installed tree does not satisfy the lockfile, which
// is the one question it answers that the byte fold cannot.
function treeCheckFailure(strCategory, objSafeDetail = {}) {
  return Object.assign(new Error(strCategory), {
    treeCheck: { category: strCategory, ...objSafeDetail },
  });
}

function validateNpmLsTree(objLs, strExpectedDirectory, strPackageJson) {
  if (typeof objLs.path !== 'string') {
    throw treeCheckFailure('missing path');
  }
  let strReportedDirectory;
  let strExpectedRealDirectory;
  try {
    strReportedDirectory = realpathSync(objLs.path);
    strExpectedRealDirectory = realpathSync(strExpectedDirectory);
  } catch {
    throw treeCheckFailure('path resolution failed');
  }
  if (strReportedDirectory !== strExpectedRealDirectory) {
    throw treeCheckFailure('path mismatch');
  }
  let objManifest;
  try {
    objManifest = JSON.parse(strPackageJson);
  } catch {
    throw treeCheckFailure('manifest JSON invalid');
  }
  const arrDeclared = [...new Set([
    ...Object.keys(objManifest.dependencies ?? {}),
    ...Object.keys(objManifest.devDependencies ?? {}),
    ...Object.keys(objManifest.optionalDependencies ?? {}),
    ...Object.keys(objManifest.peerDependencies ?? {}),
  ])].sort();
  const arrReported = Object.keys(objLs.dependencies ?? {}).sort();
  if (JSON.stringify(arrDeclared) !== JSON.stringify(arrReported)) {
    throw treeCheckFailure('dependency-set mismatch',
      { declared: arrDeclared.length, reported: arrReported.length });
  }
}

function describeTreeCheckFailure(objError) {
  if (objError?.status !== undefined) {
    const strStatus = Number.isSafeInteger(objError.status) ? String(objError.status) : 'unknown';
    return `npm ls native-status failure (exit ${strStatus})`;
  }
  const objDetail = objError?.treeCheck;
  if (objDetail?.category === 'dependency-set mismatch') {
    return `dependency-set mismatch (declared ${objDetail.declared}, reported ${objDetail.reported})`;
  }
  if (['missing path', 'path resolution failed', 'path mismatch', 'manifest JSON invalid']
    .includes(objDetail?.category)) {
    return objDetail.category;
  }
  return 'tree validation failed';
}

let strTreeCheckDetail = '';
try {
  // Round 19, reported. This reloaded `omit` from whatever .npmrc exists when it
  // starts, and every root dependency here is a dev dependency -- so `omit=dev`
  // makes `npm ls` exit 0 against a tree that is missing entirely. Measured: no
  // node_modules exits 1 plain, 0 under omit=dev, and 1 again with the inclusion
  // named on the command line. Without this, an incomplete tree could be
  // recorded with treeSatisfiesLockfile true.
  // Round 20, reported. The inclusion flags did not bind the tree SELECTION:
  // `--package-lock-only` makes npm load the virtual tree from the lockfile
  // instead of the actual one on disk. Measured -- with no node_modules at all,
  // `npm ls --all --json --package-lock-only --include=...` exits 0 while the
  // same command with `--package-lock-only=false` exits 1.
  // Round 22, reported. `--all` does not survive an ambient `depth=0`: npm then
  // checks direct dependencies only and exits 0 with a transitive package
  // missing, recording treeSatisfiesLockfile true. Depth is pinned explicitly.
  // Round 24, reported and measured. Two more ambient escapes, and they escape
  // by different mechanisms, which is why one property was never going to catch
  // both. In a directory with an EMPTY but present node_modules, the pinned
  // command exited 1 as it should; with NPM_CONFIG_GLOBAL=true it exited 0 and
  // reported path=/opt/node22/lib -- the host's global tree, a different tree
  // entirely -- and with NPM_CONFIG_LINK=true it exited 0 having reported the
  // root and zero dependencies. Either would have recorded
  // treeSatisfiesLockfile: true for a tree containing nothing.
  // Round 59. `npm ls` uses a non-zero exit to mean "the tree has problems",
  // which is a fact about the tree and not a failure of the call -- the same
  // distinction `npm audit` needs, so it takes the same path. Previously the
  // throw escaped uncaught and a problematic tree ended the run at exit 1 with a
  // stack trace; now the output is classified by parseNpmJsonOrRefuse, which
  // refuses at the documented exit 7 when what came back is not a tree report.
  // Round 60, reported by Codex, and a regression I introduced one round
  // earlier. Round 59 moved this call to runNpmAllowingFailure so that a
  // problematic tree would stop crashing the run -- and that wrapper DISCARDS
  // the exit status. `npm ls` documents its non-zero exit as "extraneous,
  // missing, and invalid packages" and still prints a complete tree object,
  // so the checks below saw a report with the right root path and the right
  // top-level key set and passed it. Measured, against a manifest whose only
  // dependency is not installed:
  //
  //   exit status 1, stdout a valid tree object, .path present,
  //   top-level keys unchanged, the missing entry present with missing: true
  //
  // treeSatisfiesLockfile: true, for a tree that does not satisfy the lockfile.
  // Fixing the crash by widening what counts as success turned a stack trace
  // into a wrong answer, which is exactly what the round-29 comment warned
  // against two functions up and what I did anyway.
  //
  // The status is authoritative and the JSON is only evidence for the message.
  // A non-zero exit IS the tree failing to satisfy the lockfile, which is what
  // exit 7 names.
  let strLsOutput;
  try {
    strLsOutput = runNpm(['ls', '--all', '--json', '--long',
      '--package-lock-only=false', '--depth=4294967295',
      '--include=dev', '--include=optional', '--include=peer',
      '--global=false', '--link=false']);
  } catch (objLsError) {
    // Round 66, reported. This refusal used to be unconditional, which
    // contradicted the comment forty lines below -- "the bypass still applies to
    // a tree that is PRESENT but does not satisfy the lockfile" -- and the
    // exit-7 bypass row in the record. Measured before the fix: an empty
    // node_modules under `--any-toolchain --no-audit --json` exited 7, while the
    // same flags on an intact tree exited 0 with freezeRecord false. npm ls
    // exits non-zero for exactly the incomplete tree the bypass is meant to let
    // a reader measure, so the failure is now RECORDED under the bypass and
    // refused only on a reviewed run. Rethrowing reaches the outer catch, which
    // sets treeSatisfiesLockfile false and builds the detail from this status --
    // the same path the wrong-tree and filtered-dependency checks below already
    // take, so all three tree failures now behave alike under the flag.
    if (boolAnyToolchain) {
      throw objLsError;
    }
    const arrProblems = (() => {
      try {
        const objBody = JSON.parse(typeof objLsError?.stdout === 'string' ? objLsError.stdout : '');
        return Array.isArray(objBody?.problems) ? objBody.problems : [];
      } catch { return []; }
    })();
    process.stderr.write(
      'supply-freeze: refusing to record digests for a tree that is not the installed tree.\n' +
      '  npm ls exit status ' + formatUntrustedText(String(objLsError?.status ?? 'unknown')) + '\n' +
      (arrProblems.length > 0
        ? arrProblems.slice(0, 8).map((strProblem) =>
          `  problem            ${formatLsProblem(String(strProblem))}\n`).join('')
          + (arrProblems.length > 8 ? `  (and ${arrProblems.length - 8} more)\n` : '')
        : '  npm reported no problem list with the failure.\n') +
      '  npm ls exits non-zero for extraneous, missing and invalid packages, and\n' +
      '  still prints a tree, so the report cannot be read as agreement.\n' +
      '  install first with the documented command, then record:\n' +
      '    npm ci --ignore-scripts --no-audit --no-fund\n' +
      strWorkspaceReinstallNote);
    process.exit(7);
  }
  // The exit code alone has now been wrong four times, in rounds 19, 20, 22 and
  // 24, each time because a different ambient input changed which tree npm was
  // describing. Naming one more flag would close this instance and leave the
  // class open, so the ANSWER is checked rather than only the inputs: --long
  // makes npm report the absolute path of the tree it actually walked, and the
  // dependency set says whether that tree was filtered on the way out. A future
  // flag that redirects the tree fails the first check; one that empties it
  // fails the second, whatever the flag turns out to be called.
  const objLs = parseNpmJsonOrRefuse(strLsOutput, 'npm ls', 7);
  validateNpmLsTree(objLs, strWorkflowDirectory, strPackageJsonBefore);
  objRecord.treeSatisfiesLockfile = true;
} catch (objError) {
  objRecord.treeSatisfiesLockfile = false;
  // The reason used to be discarded, which left every failure looking identical
  // in the refusal below -- "satisfies lockfile false" and nothing else. The two
  // checks above fail for reasons an operator cannot guess from that line.
  strTreeCheckDetail = describeTreeCheckFailure(objError);
}

// Round 3. Carried across from the package-lock-only finding rather than
// reported directly, because it is the same defect the manifest guard above
// already fixed, left standing one field over: `treeSatisfiesLockfile` was
// RECORDED and never ENFORCED. Measured -- a tree with one package directory
// deleted, and a tree reduced by `package-lock-only=true` to a single
// .package-lock.json file, both exited 0 and printed a full freeze record.
//
// A missing node_modules used to reach readdirSync and abort with a raw ENOENT
// stack trace, which tells a reader nothing about what this script wanted.
// Round 15, reported. A MISSING root is refused whatever the flags say. The
// bypass promises output that is "explicitly not a freeze record" -- but with no
// node_modules there is nothing to fold, so before this the bypassed run threw a
// raw ENOENT, and after the scan errors were caught it exited 10 blaming a tree
// that changed while recording. Nothing changed; the tree was never there.
//
// The bypass still applies to a tree that is PRESENT but does not satisfy the
// lockfile, which is a number a reader can legitimately want.
// Round 16, reported, and the same misdiagnosis one case over. The previous
// round made a MISSING root unconditional and stopped there; a root that exists
// but is a regular file, or a symlink to one, still reached the fold and came
// back as exit 10 "the recorded inputs changed" -- measured, ENOTDIR -- for a
// root that had been stable for the whole run. Walkability is checked with stat
// rather than lstat, so a symlink to a real directory stays foldable and is
// handled by the reviewed-run guard that already covers it.
const boolRootWalkable = existsSync(strTreeRoot) && (() => {
  try {
    return statSync(strTreeRoot).isDirectory();
  } catch {
    return false;
  }
})();

if (!boolRootWalkable) {
  process.stderr.write(
    'supply-freeze: refusing to record digests for a tree that is not the installed tree.\n' +
    `  node_modules       ${existsSync(strTreeRoot) ? 'present, but not a directory' : 'MISSING'}\n` +
    '  there is nothing to fold, so no digest exists to report -- with or without\n' +
    '  --any-toolchain. install first with the documented command:\n' +
    '    npm ci --ignore-scripts --no-audit --no-fund\n' +
    strWorkspaceReinstallNote);
  process.exit(7);
}

if (!boolAnyToolchain && (!existsSync(strTreeRoot) || !objRecord.treeSatisfiesLockfile)) {
  process.stderr.write(
    'supply-freeze: refusing to record digests for a tree that is not the installed tree.\n' +
    `  node_modules       ${existsSync(strTreeRoot) ? 'present' : 'MISSING'}\n` +
    `  satisfies lockfile ${objRecord.treeSatisfiesLockfile}\n` +
    // Only allowlisted categories and safe counts/status reach this line. npm's
    // reported path, package names, and raw error text are never retained in the
    // detail object, so a local private path or endpoint-controlled dependency
    // name cannot become durable diagnostic output.
    (strTreeCheckDetail ? `  because            ${strTreeCheckDetail}\n` : '') +
    '  install first with the documented command, then record:\n' +
    '    npm ci --ignore-scripts --no-audit --no-fund\n' +
    '  note that package-lock-only=true makes npm ci a no-op that reports success.\n' +
    strWorkspaceReinstallNote);
  process.exit(7);
}

// Round 15, reported and confirmed. Both scans read the tree entry by entry, so
// a concurrent delete between a readdir and the read that follows it raises
// ENOENT from inside the walk -- and nothing caught it. Measured, with the fold
// paused and `node_modules/glob` removed after the root readdir had already
// listed it: exit code 1 and a raw `node:fs` stack trace, where the record
// documents exit 10 and a message naming the cause.
//
// A scan that cannot complete has, by definition, failed to observe a tree that
// held still, so it is the same refusal -- the recorded inputs changed while
// recording. The errno and the path it failed on are reported, because "the
// tree moved" and "this file became unreadable" send a reader to different
// places.
//
// Deliberately NOT caught inside the walk to skip the entry: that would drop it
// from the digest silently, which is the defect round 8 found in the
// content-free `?` branch. A scan either completes over everything or refuses.
function scanOrRefuse(fnScan, strWhat) {
  try {
    return fnScan();
  } catch (objError) {
    process.stderr.write(
      'supply-freeze: the recorded inputs changed while recording; refusing to report.\n' +
      `  detected by        ${strWhat} could not complete\n` +
      formatErrorLocation(objError, '(path not reported)') +
      '  an entry vanished or became unreadable while it was being read, so no\n' +
      '  complete measurement of the tree exists. record against a quiescent tree.\n');
    process.exit(10);
  }
}

// Round 18, reported by Copilot. The symlinked-root refusal below read
// objTree.rootIsDirectory, which only exists AFTER the whole redirected tree had
// been walked and hashed -- so a reviewed run did the entire fold before
// refusing, and a root pointed at an arbitrarily large tree would be scanned in
// full before anything objected. lstat answers the same question before a single
// entry is read.
if (!boolAnyToolchain
  && !scanOrRefuse(() => lstatSync(strTreeRoot), 'the root type check').isDirectory()) {
  process.stderr.write(
    'supply-freeze: refusing to record digests for a tree that is not the installed tree.\n' +
    '  node_modules       present, but a symlink rather than a directory\n' +
    '  npm ci creates node_modules as a real directory. A symlinked root points the\n' +
    '  install somewhere this record does not describe, however identical its contents.\n');
  process.exit(7);
}

const objTree = scanOrRefuse(() => foldInstalledTree(strTreeRoot), 'the first fold');
objRecord.installedTreeSha256 = objTree.sha256;
objRecord.installedTreeFiles = objTree.files;
objRecord.installedTreeSymlinks = objTree.symlinks;
objRecord.installedTreeDirectories = objTree.directories;
objRecord.installedTreeSpecials = objTree.specials;
objRecord.installedTreeModes = objTree.modes;
objRecord.installedTreeDirectoryModes = objTree.directoryModes;
objRecord.installedTreeRootMode = objTree.rootMode;

// Round 9. A FIFO, socket or device node under node_modules means this is not
// an installed tree, which is the same thing refusal 7 asserts for a different
// cause -- so it gets the same treatment rather than a digest.
//
// The fold above now distinguishes these entries from one another, so the
// number reported under --any-toolchain is honest either way. This refusal is
// about what a REVIEWED run is allowed to mint: `npm ci` produces no such
// entry, so a record over a tree containing one would be a freeze record for
// something npm cannot have built.
// Round 12. `npm ci` creates node_modules as a real directory. A symlinked root
// redirects where every installed module loads from while the contents behind it
// can be byte-identical, so it is the same class as refusal 7 already covers --
// this is not the installed tree -- and it reuses that exit rather than adding
// an eleventh number for a tenth cause.
// Round 44. Reached only when the root changed after the early rejection above,
// since a symlinked root is refused before the baseline scan now.
if (!boolAnyToolchain && !objTree.rootIsDirectory) {
  refuseRootThatIsNotADirectory(objTree.rootMode);
}

if (!boolAnyToolchain && objTree.specials > 0) {
  process.stderr.write(
    'supply-freeze: refusing to record digests for a tree containing special files.\n' +
    `  special entries    ${objTree.specials} (expected 0)\n` +
    `${objTree.specialPaths.slice(0, 10).map((strPath) => `    node_modules/${strPath}\n`).join('')}` +
    (objTree.specialPaths.length > 10
      ? `    ... and ${objTree.specialPaths.length - 10} more\n` : '') +
    '  npm ci creates only files, directories and symlinks; a FIFO, socket or\n' +
    '  device node under node_modules did not come from the install.\n');
  process.exit(11);
}

// Round 38, reported by Codex. Refused rather than recorded: a link out of the
// tree makes the installed-tree digest silent about the code that actually
// loads, which is the one thing that digest exists to pin.
if (objTree.escapingLinks.length > 0) {
  process.stderr.write(
    'supply-freeze: refusing to record digests for a tree whose links leave it.\n' +
    `  escaping links     ${objTree.escapingLinks.length} (expected 0)\n` +
    `${objTree.escapingLinks.slice(0, 10).map((objLink) =>
      `    node_modules/${objLink.path}\n`).join('')}` +
    (objTree.escapingLinks.length > 10
      ? `    ... and ${objTree.escapingLinks.length - 10} more\n` : '') +
    '  each link above passes outside the tree root somewhere along its chain --\n' +
    '  which is not the same as ending outside it, and a chain that leaves and\n' +
    '  comes back is refused too: the hop outside decides which in-tree bytes load\n' +
    '  and nothing in this record covers that hop. the target is not\n' +
    '  printed: it is chosen by whoever wrote the link and CI logs are retained, so\n' +
    '  a target carrying a username, internal layout or a path-borne token would\n' +
    '  outlive this run. run `ls -l` on the names above to see where they point.\n' +
    '  the fold hashes a link\'s target text, not the bytes behind it, so a target\n' +
    '  outside node_modules is code this digest does not cover and cannot detect\n' +
    '  changes to. npm ci installs package contents in place; a package directory\n' +
    '  that is a link to somewhere else did not come from the install.\n');
  process.exit(11);
}

// Round 39, reported by Codex. A link this fold could not resolve is refused
// rather than skipped. Containment is what the guard above asserts, and a link
// whose resolution failed is one whose containment was never established --
// including the case where the target is absent for exactly as long as this
// script is looking at it, which is invisible to the lstat-based sweep.
if (objTree.unresolvedLinks.length > 0) {
  process.stderr.write(
    'supply-freeze: refusing to record digests for a tree with links it cannot resolve.\n' +
    `  unresolved links   ${objTree.unresolvedLinks.length} (expected 0)\n` +
    `${objTree.unresolvedLinks.slice(0, 10).map((objLink) =>
      `    node_modules/${objLink.path} (${objLink.code})\n`).join('')}` +
    (objTree.unresolvedLinks.length > 10
      ? `    ... and ${objTree.unresolvedLinks.length - 10} more\n` : '') +
    '  resolution failing means this fold could not establish that the link stays\n' +
    '  inside the tree, so the containment the digest depends on is unproven rather\n' +
    '  than satisfied. a target that is absent while this runs and restored after it\n' +
    '  leaves the link text -- and therefore the digest -- completely unchanged.\n' +
    '  reinstall with npm ci; npm ci does not create links it cannot resolve.\n');
  process.exit(11);
}

function auditPackageDisplaySummary(objPackages) {
  const newSeverityCounts = () => Object.fromEntries(
    [...SEVERITY_LEVELS, 'unclassified'].map((strSeverity) => [strSeverity, 0]));
  const objSummary = {
    directAdvisory: newSeverityCounts(),
    inheritedOnly: newSeverityCounts(),
  };
  for (const objValue of Object.values(objPackages)) {
    const strCause = objValue.advisories.length > 0 ? 'directAdvisory' : 'inheritedOnly';
    objSummary[strCause][objValue.severity ?? 'unclassified'] += 1;
  }
  return objSummary;
}

function renderAuditPackageSummary(objSummary) {
  return renderRecordRow('audit package summary', JSON.stringify(objSummary));
}

if (boolSkipAudit) {
  objRecord.registry = null;
  objRecord.auditSha256 = null;
  // No audit child ran, so nothing was scrubbed. Emitted anyway so the field is
  // present on every record shape and a reader never has to distinguish "absent
  // because nothing was scrubbed" from "absent because this build is older".
  objRecord.auditEnvironmentScrubbed = [];
  objRecord.auditCounts = null;
  objRecord.auditPackages = null;
} else {
  // The advisory posture is a snapshot of whatever registry answers the audit
  // request, and nothing else in this script constrains which one that is.
  //
  // Round 5, reported. npm posts the audit to the configured registry, so a
  // reader behind an enterprise proxy or a private mirror gets a posture digest
  // computed from THAT registry's advisory view. A mirror that filters
  // advisories, or simply has none, returns a schema-valid report -- so the
  // round-1 shape guard passes it -- and the script records a confident-looking
  // clean posture at exit 0. That is the same class of defect as the endpoint
  // error the shape guard was added for, arriving from a source that looks
  // healthy.
  //
  // Checked HERE rather than in REVIEWED_NPM_CONFIG, and that placement is the
  // point. The registry does not shape the installed tree: every one of the 125
  // packages in the lockfile carries an `integrity` hash, and `npm ci` verifies
  // each tarball against it, so a substituted registry cannot change the bytes
  // on disk without failing the install outright. Only the advisory half is
  // exposed. Refusing a `--no-audit` run on a mirror would be a false failure
  // for a reader whose tree is provably byte-identical.
  if (!boolAnyToolchain) {
    const arrTransportDrift = configDrift(
      REVIEWED_NPM_TRANSPORT,
      parseNpmJsonOrRefuse(runNpmOrRefuse(['config', 'list', '--json'], undefined, 6,
        'npm could not report its effective configuration.'), 'npm config list', 6));
    if (arrTransportDrift.length > 0) {
      process.stderr.write(
        'supply-freeze: npm transport configuration would change where the audit goes.\n' +
        `${arrTransportDrift.join('\n')}\n` +
        '  a proxy or a custom trust store can return a schema-valid but filtered report.\n' +
        '  the installed tree is unaffected, so --no-audit records the lockfile-derived\n' +
        '  fields from any transport.\n');
      process.exit(6);
    }
  }
  const strRegistry = runNpmOrRefuse(['config', 'get', 'registry'], undefined, 9,
    'npm could not report the registry the audit would use.').trim();
  if (!boolAnyToolchain && strRegistry !== REVIEWED_REGISTRY) {
    process.stderr.write(
      'supply-freeze: refusing to record an advisory posture from an unreviewed registry.\n' +
      `  registry           observed ${redactUrl(strRegistry)}\n` +
      `                     reviewed ${REVIEWED_REGISTRY}\n` +
      '  npm posts the audit request to the configured registry, and a mirror that\n' +
      '  filters or lacks advisories returns a schema-valid but misleadingly clean report.\n' +
      '  the installed tree is unaffected -- lockfile integrity hashes pin those bytes --\n' +
      '  so --no-audit records the lockfile-derived fields from any registry.\n');
    process.exit(9);
  }
  // Recorded through the same redaction. The refusal above is gated on
  // !boolAnyToolchain, so a bypassed run never reaches it -- which is exactly
  // the run that can carry an unreviewed, credentialed registry, and it would
  // otherwise land the token in the emitted artifact rather than merely in a
  // log line. A no-op for the reviewed registry, which has no userinfo or query.
  objRecord.registry = redactUrl(strRegistry);
  // Round 11, reported. The registry was READ in one npm process and the audit
  // then ran in a SEPARATE one that reloaded configuration from scratch, so a
  // user or global .npmrc rewritten between the two would send the audit to a
  // different registry while objRecord.registry still named the validated one
  // -- a schema-valid answer from a mirror, recorded under the wrong source.
  //
  // Passing the validated value on the command line closes it by construction
  // rather than by a second check afterwards: npm gives command-line config the
  // highest precedence, so this invocation cannot be redirected by any file or
  // environment variable. The value passed is the one already compared against
  // REVIEWED_REGISTRY and the one recorded, so all three agree by construction.
  //
  // Round 12, reported, and this is the previous round's fix caught being
  // partial. Pinning the registry on this command line closed one input and
  // left the rest reloading: the audit subprocess still reads `omit` and
  // `include` from whatever .npmrc exists when it starts, and npm's own
  // `npm audit --help` lists `[--omit <dev|optional|peer> ...]`.
  //
  // Every one of the 125 packages in this lockfile is a dev dependency, so
  // `omit=dev` empties the audited set entirely. Measured: `npm audit --json
  // --omit=dev` returns a schema-valid report with total 0 against the true 7 --
  // it passes the shape guard and would be recorded as a clean posture,
  // attributed to the registry this script had just validated.
  //
  // `include` counteracts `omit` in npm's precedence, so naming all three
  // groups explicitly neutralises any ambient omission rather than checking for
  // it afterwards. Measured: under `omit=dev` this restores total 7, and on a
  // clean run it leaves total 7 unchanged.
  // Round 16, reported. A truncated or malformed body that still starts with `{`
  // is returned by runNpmAllowingFailure and then thrown on by JSON.parse as a
  // raw SyntaxError -- exit 1, before the shape guard below could call it what
  // it is. Unparseable output is exactly "not an audit report".
  const strAuditResponse = runNpmAllowingFailure([
    'audit', '--json',
    `--registry=${strRegistry}`,
    '--include=dev', '--include=optional', '--include=peer',
    // Round 16, reported. npm's metavulnerability calculation loads packuments
    // through the cache, and npm documents prefer-offline as bypassing staleness
    // checks -- so an ambient prefer-offline lets inherited advisories be
    // computed from stale version data while the bulk advisory request still
    // goes to the validated registry. Forcing revalidation on this invocation
    // binds the whole posture to a current snapshot, not just its bulk half.
    '--prefer-offline=false', '--offline=false', '--prefer-online=true',
    ...transportFlags(),
    // Round 35, reported by Codex, and this is the round-20 fix caught being
    // half a fix. That round bound the six transport settings against a rewrite
    // between the check and the audit, and its own comment describes the split:
    // the non-null ones become flags, "the null ones are bound by scrubbing them
    // from the child's environment instead". Scrubbing the ENVIRONMENT does not
    // touch the FILE half of the same source. npm loads project, user and global
    // npmrc files, and proxy/https-proxy/ca/cafile are all null -- so they carry
    // no flag, and a file rewritten after the check supplies them to this child.
    //
    // Measured, npm 10.9.7: with npm_config_proxy and every *_proxy variable
    // removed from the environment, a proxy set in an npmrc still reaches the
    // child -- via NPM_CONFIG_USERCONFIG, which survives the scrub because
    // `userconfig` is not a REVIEWED_NPM_TRANSPORT key and does not end in
    // `_proxy`, and via a plain ./.npmrc with no variable set at all. Also
    // measured: `--proxy=` does not close it. It is not merely noisy -- npm
    // warns `invalid config` and KEEPS the npmrc value, so the empty flag is
    // inert, which is why round 20 could not express the null values as flags
    // and had to reach for the environment.
    //
    // --userconfig and --globalconfig DO exist, and being command line they
    // outrank every file. Pointed at an empty source and a missing one: both
    // read as empty, and npm refuses the same path twice with `double-loading
    // config`, so the two must differ. No temporary file is written for this --
    // this script writes none anywhere, and re-introducing a writer to hold two
    // empty files would cost more than it closes.
    //
    // The PROJECT npmrc is NOT closed by this and is not claimed to be. It is
    // read from the directory this child runs in, npm has no flag that relocates
    // that source, and `--proxy=` is inert per above. What covers it instead:
    // the transport check above runs `npm config list --json` in the same
    // directory, and a committed .github/workflows/.npmrc is visible there --
    // measured, its proxy appears in that output -- so the static case exits 6.
    // Round 56/57 closed the window this comment used to leave open: the
    // quiescence sweep now covers the workflow directory AND .npmrc itself, so
    // a project npmrc created mid-run, or rewritten in place and restored, is
    // refused at exit 10. What remains is a project npmrc created in the window between that check
    // and this line, which is a write into the repository working directory
    // mid-run: the same residual class as the preload the NODE_OPTIONS refusal
    // documents, and named in the record rather than papered over.
    //
    // Round 36, reported by Codex, and this is the round-35 fix above caught in
    // its turn. The global substitute was `/nonexistent/supply-freeze-globalconfig`
    // -- a path ASSUMED to be missing rather than one that cannot exist. If it
    // does exist npm reads it, measured returning a planted proxy alongside
    // `--userconfig=/dev/null`, and the assumption is weakest exactly where this
    // script runs: measured in this container, the process is uid 0 and
    // `mkdir /nonexistent` succeeds. Replacing one attacker-supplyable config
    // source with another one is not a fix.
    //
    // `/dev/null/...` cannot exist, and not by assumption. /dev/null is a
    // character device, so every path beneath it is ENOTDIR for everyone
    // including root -- measured, both `mkdir` and `touch` refuse. npm reads it
    // as an absent config file and the audit returns the true 7/7 posture.
    // Still two distinct paths because npm rejects the same file twice with
    // `double-loading config`, and the dedupe is by RESOLVED path: measured,
    // `/dev/../dev/null` collides with `/dev/null` too.
    ...(boolAnyToolchain ? [] : ['--userconfig=/dev/null',
      '--globalconfig=/dev/null/supply-freeze-globalconfig']),
    // Round 21, reported. The binding is applied only to reviewed runs. Under
    // --any-toolchain the configuration refusal is correctly bypassed, but
    // forcing the reviewed transport anyway made the audit fail with exit 5 on a
    // network that needs an ambient proxy -- denying the explicitly-marked
    // non-freeze output the flag promises. A bypassed run uses its own transport
    // and says so in notFreezeRecordBecause.
  ].filter((strArgument) => boolAnyToolchain
    ? !Object.keys(REVIEWED_NPM_TRANSPORT).some((strKey) => strArgument.startsWith(`--${strKey}=`))
    : true), boolAnyToolchain ? undefined : transportEnvironment());
  const objAudit = parseAuditOrRefuse(strAuditResponse);
  // Reported and confirmed, and the most serious of the round. `npm audit`
  // exits nonzero for two completely different reasons: advisories were found,
  // and the audit endpoint failed. Under --json it prints a JSON object either
  // way, so the old "stdout starts with a brace" test accepted an endpoint
  // error as a report. Measured against a dead registry: npm emitted
  // {"message":"... ECONNREFUSED ...","error":{...}}, normalizeAudit saw zero
  // packages, and the script printed a confident posture digest over an empty
  // set and exited 0. A network blip would have silently rewritten the record.
  //
  // The shape is checked rather than the exit status, because the exit status
  // is what conflates the two cases in the first place.
  // Round 2, reported by Copilot: `typeof null === 'object'`, so the original
  // metadata test accepted `metadata.vulnerabilities: null` and the counts then
  // recorded as null -- the exact endpoint-failure shape the guard exists to
  // refuse, readmitted through a JavaScript quirk. The null test was present on
  // `vulnerabilities` and absent on `metadata.vulnerabilities`; asymmetry in a
  // guard is a defect even when both halves look alike.
  //
  // Strengthened past the reported fix: the severity counts must each be an
  // integer. That refuses null, an empty object, and a shape change, rather
  // than only the one value that was reported.
  //
  // Round 6, reported by Copilot: that strengthening still was not the class.
  // `typeof [] === 'object'` too, so an ARRAY passed both tests -- measured,
  // `vulnerabilities: []` and an array-shaped `metadata.vulnerabilities` were
  // both accepted. Round 2 closed `null` and left `[]` open, which is the same
  // "fixed the reported value, not the predicate" mistake one step over.
  //
  // Both tests now route through isPlainObject rather than repeating a
  // hand-written conjunction, so the two halves cannot drift apart again --
  // that asymmetry is what admitted `null` in the first place.
  // Round 19, reported. Valid JSON whose root is `null` reached this line and
  // threw before the shape refusal below could speak. The root is checked first
  // now, with the same predicate every other shape test uses.
  const objCounts = auditCountsOrRefuse(strAuditResponse, objAudit);
  // Round 44, reported by Codex. SAFE integers, the same class round 43 closed on
  // the advisory source id and did not sweep to its siblings here. Past 2^53-1
  // distinct JSON integers stop having distinct doubles, so two different reports
  // canonicalize to one record. Measured, reports differing only in a last digit:
  //
  //   auditReportVersion 9007199254740992 / ...93  -> both posture 7427fbb568f68e6f
  //   info = total = 9007199254740992 / ...93      -> both posture 9dc26eff097871ba
  //
  // The second pair also satisfies the bucket-sum check below, because setting one
  // bucket and the total to the same unsafe value keeps the arithmetic consistent
  // -- a self-consistent report that is still two reports recorded as one.
  //
  // SEVERITY_ORDER ends with 'total', so this covers the total as well as the five
  // levels. The sum check downstream stays sound once these are safe: a bucket sum
  // that is inexact necessarily exceeds 2^53-1, and the total it is compared to
  // cannot, so an inexact sum can never compare equal.
  // auditCountsOrRefuse also checks each vulnerability entry. Round 17 found
  // that a valid top level with `{"x": null}` otherwise reaches normalization
  // and throws at exit 1 instead of using the audit response refusal at exit 5.
  // Round 33, swept from the reported severity defect. Integer-ness was the only
  // test these counts got, so `total: -1` and buckets summing to 9 against a
  // total of 1 both recorded at exit 0. The total is the sum of its parts
  // whatever npm chooses to count, so this catches an endpoint whose arithmetic
  // contradicts itself without assuming HOW npm tallies.
  //
  // Requiring the counts to be exactly recomputable from the vulnerabilities
  // block was considered and NOT taken. It holds on the real report only because
  // npm currently tallies one per vulnerable package -- an implementation detail,
  // not a contract. Were npm to count advisories instead, that check would refuse
  // a genuine report and block the freeze on a healthy repository, which is a
  // worse failure than the one it prevents.
  const intBucketSum = SEVERITY_LEVELS.reduce(
    (intAcc, strSeverity) => intAcc + objCounts[strSeverity], 0);
  if (intBucketSum !== objCounts.total) {
    process.stderr.write(
      'supply-freeze: npm audit returned a report whose counts contradict themselves.\n' +
      `  severity buckets   ${SEVERITY_LEVELS.map((s) => `${s}=${objCounts[s]}`).join(' ')}\n` +
      `  they sum to        ${intBucketSum}\n` +
      `  total says         ${objCounts.total}\n` +
      '  an advisory posture that disagrees with its own arithmetic cannot be compared;' +
      ' nothing is recorded.\n' +
      '  pass --no-audit to record the lockfile-derived fields alone.\n');
    process.exit(5);
  }
  // Round 38, reported by Codex. The sum check above tests the counts against
  // THEMSELVES, so a response whose counts contradict its own vulnerability
  // records passed: nonzero severities with an empty `vulnerabilities` object
  // sums correctly and normalized to a nonzero auditCounts over an EMPTY
  // auditPackages map, recorded at exit 0. The inverse -- populated records with
  // all-zero counts -- passed the same way.
  //
  // The test is emptiness against zero, in both directions, and that shape is
  // load-bearing. The comment above explains why the counts are NOT required to
  // be recomputable from the records: npm currently tallies one per vulnerable
  // package, which is an implementation detail, and a stricter check would
  // refuse a genuine report if npm ever counted advisories instead. A
  // biconditional on emptiness survives either choice -- under any tallying
  // rule, zero records means zero total and some records means a nonzero one --
  // so it catches the contradiction without betting on the rule.
  if ((Object.keys(objAudit.vulnerabilities).length === 0) !== (objCounts.total === 0)) {
    process.stderr.write(
      'supply-freeze: npm audit returned counts that contradict its vulnerability records.\n' +
      `  vulnerability records   ${Object.keys(objAudit.vulnerabilities).length}\n` +
      `  total says              ${objCounts.total}\n` +
      '  one of the two is empty and the other is not, so the posture cannot be'
      + ' compared; nothing is recorded.\n' +
      '  pass --no-audit to record the lockfile-derived fields alone.\n');
    process.exit(5);
  }
  const objNormalizedAudit = normalizeAuditOrRefuse(strAuditResponse, objAudit);
  objRecord.auditSha256 = sha256(canonicalize(objNormalizedAudit));
  // Sorted so two runs that scrubbed the same set produce the same list. Not
  // folded into auditSha256: the advisory posture is a statement about the
  // registry's answer, and which local variables had to be removed to reach the
  // registry cleanly is a statement about this machine.
  objRecord.auditEnvironmentScrubbed = [...arrScrubbedTrustVariables].sort();
  objRecord.auditCounts = objNormalizedAudit.counts;
  // The normalized response, including package keys, advisory ids and `via`
  // names, remains input to auditSha256 above. The public display is deliberately a
  // fixed vocabulary of numeric summaries: registry-controlled strings are
  // response content and can contain credentials or private package names.
  // “Direct advisory” retains the prior display distinction (advisories.length
  // > 0); it is not npm's separate isDirect project-dependency flag.
  objRecord.auditPackages = auditPackageDisplaySummary(objNormalizedAudit.packages);
}

// Read-only is an assertion, not a claim. `npm ls` and `npm audit` are supposed
// to leave both files alone; this proves they did rather than trusting them.
if (!readOrRefuse(strPackagePath).equals(objPackageBefore)
  || !readOrRefuse(strLockPath).equals(objLockBefore)) {
  process.stderr.write('supply-freeze: package metadata changed while reading it; refusing to report\n');
  process.exit(3);
}

// Round 8, reported. The assertion above covers the two manifest files and
// nothing else, so `node_modules` was read exactly once and never looked at
// again. Between that fold and this point sits `npm audit` -- a network round
// trip measured at ~2.0s against a ~0.1s fold -- and anything that edited an
// already-hashed file during that window left installedTreeSha256 describing a
// tree that no longer existed, under a freezeRecord: true heading.
//
// Re-folding brackets the audit rather than merely reordering around it:
// moving the audit earlier would have made the race less likely and still
// undetectable, and "less likely" is not a property a freeze record can rest
// on. The second fold is the same code over the same tree, so a mismatch means
// the bytes moved underneath it.
//
// Round 9 correction, and it is this comment's own argument turned around. An
// earlier version of this paragraph said re-folding brackets the slow operation
// "rather than narrowing the window", which claimed more than two sequential
// walks can deliver: a write landing after the second fold has read an entry
// leaves both folds agreeing on stale bytes, and that was demonstrated rather
// than argued. What brackets the audit is the PAIR of folds; the second fold's
// own duration is a window this comparison does not cover. The quiescence check
// after it covers that one, and the limit that remains is stated there.
//
// Done unconditionally, including under --no-audit where the window is only
// microseconds wide. A guarantee that holds except in the case nobody thought
// about is the defect this review found five times over; the cost is one extra
// pass at roughly 0.1s.
const objTreeAfter = scanOrRefuse(() => foldInstalledTree(strTreeRoot), 'the second fold');
// Round 35, reported by Codex. Every field is compared, not the digest alone.
// The digest folds `mode & 0o555` -- read and execute -- so the write bits and
// the setuid/setgid/sticky bits are outside it BY DESIGN, for the reasons the
// round-12 comment on the fold gives. That makes the mode histograms and the
// root mode genuinely non-derivable from the digest: measured, 0644 and 0664
// both fold to 444 while landing in DIFFERENT histogram buckets, so a group
// write bit added between the folds moves `modes` and leaves both digests
// equal. installedTreeModes is copied from the FIRST fold, so the record would
// carry a histogram that no longer described the tree, at exit 0.
//
// Compared as the whole object rather than as the two fields reported. The
// digest is one field among several the fold returns, and enumerating the two
// that are currently outside it would re-open the moment a third is added --
// the same "fixed the reported instance, not the class" mistake rounds 2 and 6
// each made on the audit shape guard. Anything foldInstalledTree returns is now
// held still between the folds, whether or not the digest covers it.
const arrFoldDrift = Object.keys(objTree).filter((strField) =>
  JSON.stringify(objTree[strField]) !== JSON.stringify(objTreeAfter[strField]));
if (arrFoldDrift.length > 0) {
  process.stderr.write(
    'supply-freeze: the installed tree changed while recording; refusing to report.\n' +
    `  fields that moved   ${arrFoldDrift.join(', ')}\n` +
    `  first fold         ${objTree.sha256}\n` +
    `  second fold        ${objTreeAfter.sha256}\n` +
    `  counts             ${objTree.files}/${objTree.symlinks}/${objTree.directories}` +
      ` then ${objTreeAfter.files}/${objTreeAfter.symlinks}/${objTreeAfter.directories}` +
      ' (files/symlinks/directories)\n' +
    arrFoldDrift.filter((strField) => strField !== 'sha256').map((strField) =>
      `  ${strField.padEnd(18)} ${JSON.stringify(objTree[strField])}` +
      ` then ${JSON.stringify(objTreeAfter[strField])}\n`).join('') +
    '  something wrote to node_modules while this ran. record against a quiescent tree.\n');
  process.exit(10);
}

// Round 61, reported by Codex: this recheck used to run AFTER the quiescence
// sweep, the final manifest comparison and the script self-check. Folding 1916
// files takes real time, and anything written to a manifest or to node_modules
// during that walk landed after every input check had already passed -- so the
// run could emit freezeRecord: true while its manifest and tree digests
// described bytes no longer on disk. Moved ahead of those checks, so the last
// thing to touch the filesystem before the sweep is this fold and the sweep
// still gets the final word on the inputs.
// Round 57, reported by Codex, and the round-56 npm authentication caught being
// a snapshot where it needed to be an interval.
//
// That round folded the npm installation once, before the first npm subprocess,
// and my reply called the remaining gap a TOCTOU the attacker "has to win a race"
// for. That undersold it by the width of the whole run. The fold happened around
// line 2450 and the last npm subprocess -- the audit -- runs roughly 950 lines
// later, so the window was not microseconds: it was every npm call in the
// program. With a writable copied distribution an actor could present the
// genuine tree to the check, replace bin/npm-cli.js immediately afterwards, and
// have the replacement answer the version, config, ls and audit calls. Nothing
// looked at the installation again -- not the tree folds, which walk
// node_modules, and not the quiescence sweep, which walks node_modules, the two
// manifests and the workflow directory.
//
// So the installation is folded a SECOND time, here, after every npm subprocess
// has run. Bytes rather than a stamp, because that is what the first fold
// compared and a replacement restored before this point must still be caught by
// the same measure. Refusing at exit 2 keeps this on the toolchain refusal, which
// is what it is: the program that answered was not the program that was checked.
//
// Round 71, reported by Codex, and this gate was wrong. It used to read: "gated
// the same way the first fold's byte comparison is -- --any-toolchain waives
// which npm is acceptable and marks the output not a freeze record, so there is
// no freeze record here to protect." Both halves of that were true and the
// conclusion did not follow.
//
// The first fold's COMPARISON is gated because it tests this installation
// against REVIEWED_NPM_TREE_SHA256, a constant a bypassed run has explicitly
// waived. This check tests nothing of the kind: it compares the run's OWN
// before value against its OWN after value, so it needs no reviewed digest and
// nothing about --any-toolchain makes it inapplicable. The fold itself
// (foldNpmInstallation, above) already runs unconditionally, so the baseline
// was being computed and then thrown away under bypass.
//
// What that cost: `npmTree` is emitted in the toolchain block of every run,
// bypassed ones included. Codex verified with a dummy npm CLI that writes into
// its own installation during `--version` -- the bypassed run exits 0 and
// reports the npmTree hash from BEFORE the write, so the record pairs one
// installation's hash with another installation's version, `ls` and audit
// answers. An explicitly-non-freeze record is still a record, and a value that
// describes a program that stopped existing mid-run is wrong rather than merely
// unblessed.
//
// This is round 66's finding AR again -- the npm ls exit 7 was bypassed by the
// same reasoning and corrected the same way -- so the rule is now explicit:
// --any-toolchain waives comparisons against REVIEWED_* constants, and nothing
// else. Self-consistency checks run in every mode.
{
  const objNpmTreeAfter = scanOrRefuse(
    () => foldNpmInstallation(strNpmTreeRoot, strNpmBesideNode), 'the second npm installation fold');
  if (objNpmTreeAfter.sha256 !== objNpmTree.sha256
    || objNpmTreeAfter.changeSha256 !== objNpmTree.changeSha256) {
    process.stderr.write(
      'supply-freeze: the npm installation changed while it was being used.\n' +
      `  npm installation   ${formatUntrustedText(strNpmTreeRoot)}\n` +
      `  when checked       ${objNpmTree.sha256} (${objNpmTree.files} files)\n` +
      `  after the run      ${objNpmTreeAfter.sha256} (${objNpmTreeAfter.files} files)\n` +
      `  what moved         ${objNpmTreeAfter.sha256 !== objNpmTree.sha256
        ? 'contents' : 'inode change times, with the contents restored'}\n` +
      '  the npm measured before the first subprocess is not the npm on disk now, so\n' +
      '  the configuration, the lockfile assertion and the advisory posture were not\n' +
      '  necessarily answered by the installation whose hash this run recorded.\n' +
      // Round 71. This refusal now fires under --any-toolchain too, where the
      // installation was never checked against a reviewed digest -- so the
      // wording says "measured" and "recorded" rather than "verified" and
      // "authenticated", which would have been a claim a bypassed run is not
      // entitled to make.
      '  this check compares the run against itself, so --any-toolchain does not\n' +
      '  waive it: the recorded npmTree would otherwise describe a program that\n' +
      '  stopped existing while it was still answering questions.\n');
    process.exit(2);
  }
}

// Round 9, reported by Codex. The comparison above answers "did two reads of
// the same entry agree", and a write that lands after the SECOND fold read an
// entry escapes it -- demonstrated, with the recorded digest emitted at exit 0
// for a file that had already grown by 35 bytes. See newestChangeTime.
//
// Same cause as the refusal above, so the same exit code: the installed tree
// changed while recording. A second exit number for one cause would inflate the
// table that the round-7 finding had to correct, and the message names which of
// the two detectors fired.
//
// What this does and does not promise, stated plainly because the round-8
// comment on the fold above overreached and this is the correction -- and then
// this correction overreached in its turn, which round 29 had to fix. It read
// "between them the two mechanisms detect any write that lands before this sweep
// reads the affected entry". That was false in two distinct ways, and stating a
// guarantee this sweep does not provide is worse than the gap itself, because a
// reader stops looking.
//
// First: it compared clocks that do not agree, measured at 2000 of 2000 writes
// missed inside a ~4 ms window. That one is now fixed -- see the comparison.
//
// Second, and NOT fixed because it cannot be by this means: any ctime comparison
// is blind below the filesystem's timestamp granularity. If an entry is written
// twice within one tick -- once before the baseline and once after the second
// fold -- both stamps truncate to the same value and the sweep sees no change.
// On ext3, one tick is a full second. The double fold is what actually covers
// that case, by comparing bytes rather than times; the sweep supplements it for
// writes that land after the second fold, and neither is a substitute for the
// other. Neither makes the walk atomic either: a write landing after the
// sweep has passed an entry is not detected by anything here, and cannot be,
// because a userspace sequential scan has no atomic snapshot to compare against.
// A filesystem-level snapshot would close it outright and is the right answer
// for a reader who has one; that is a property of the host, not of this script.
const objNewestChange = scanOrRefuse(
  () => newestChangeTime(strTreeRoot, [
    [strPackagePath, 'package.json'],
    [strLockPath, 'package-lock.json'],
    [strWorkflowDirectory, 'workflow directory'],
    [arrWorkflowAncestors[0], 'workflow parent directory'],
    [arrWorkflowAncestors[1], 'repository root'],
  ]), 'the quiescence sweep');
// Round 29, reported. This compared a filesystem-stamped ctime against a
// `Date.now()` ceiling -- two different clocks. Linux stamps inode times from
// the COARSE clock and truncates to the filesystem's granularity, while
// Date.now() reads the fine one, so a ctime is systematically backdated
// relative to the ceiling it was being tested against.
//
// Measured on this container, ext2/ext3, 2000 files each written strictly AFTER
// capturing the ceiling: 2000 of 2000 landed BELOW it, backdated by up to
// 4.13 ms. Not an exotic-filesystem edge case -- the comparison was wrong every
// single time within that window.
//
// The reported remedy of rounding the ceiling down by the granularity was
// measured and rejected: it breaks the documented workflow. This script is run
// as `npm ci && node Get-SupplyFreezeDigest.mjs`, so a backdated ceiling makes
// the install that just finished trip the refusal.
//
// So the comparison is now like-for-like. The baseline is a ctime read from the
// same filesystem, through the same lstat, truncated by the same granularity as
// every value it is compared against, captured before any recorded byte is read.
// No clock is consulted and no margin is guessed.
// Round 42, reported by Codex. Compared PER ENTRY. This used to compare one
// maximum against another, and a maximum silently loses any change that does not
// exceed it.
//
// If any swept inode carries a ctime AHEAD of the recorder's clock -- clock skew
// on a network filesystem, or a local inode stamped before the clock was stepped
// backward -- then the baseline maximum is that future value, and a write landing
// after the second fold gets a LOWER ctime. The maximum does not move, the
// comparison passes, and the run records a digest for bytes that are no longer on
// disk. Measured, with a control:
//
//   normal clock, mid-run write to a swept file  -> exit 10, refused
//   one inode stamped 600s ahead, same write     -> exit 0, ACCEPTED
//
// Same write, same timing; the only difference was one future-stamped inode.
//
// The per-entry comparison needs no clock at all -- it compares the baseline
// reading against the final reading of the same inode, so a ctime that moves in
// EITHER direction is a difference. That is where the skew-robustness comes from,
// and it is why a separate "refuse future ctimes" rule was considered and
// dropped: it would add a false-failure mode on a legitimately skewed network
// filesystem while detecting nothing this does not already catch.
// Round 68, found by sweeping my own previous round rather than reported. The
// compared value carries an inode AND a change time since the same-tick swap fix,
// and the optional-path sentinel -1 records absence, so ONE 'change time moved'
// label stood for four different transitions. Detection was correct for all four;
// the sentence the operator reads was wrong for three. Measured before this was
// added, driving the shipped functions verbatim:
//
//   inode differs, ctime identical -> "change time moved" above two IDENTICAL
//                                     timestamps
//   .npmrc appears mid-run         -> "change time moved" above "baseline
//                                     reading absent"
//   .npmrc removed mid-run         -> "change time moved" above "final reading
//                                     absent"
//   ctime moves, inode same        -> "change time moved"  (the one true case)
//
// The second is the worst of them: an appearing .npmrc is the project-config
// injection the optional sweep exists to catch, and something absent cannot have
// had its change time move. A refusal that contradicts its own data on its face
// is one an operator stops trusting, which costs more than the missing word.
//
// The round-57 note below is right that -1 makes all four transitions fall out of
// one equality test. That is a claim about DETECTION, and it was silent about
// reporting -- the label was then written as though a single transition existed.
//
// They are named apart because they are different attack signatures: a swap is
// not a rewrite and neither is an injection, and that distinction is what an
// operator triages on. The strings reuse 'appeared during the run' and
// 'disappeared during the run' verbatim from the presence branches below, so one
// transition never has two spellings.
const funcDescribeSweepChange = (objWas, objNow) => {
  if (objWas === -1) return 'appeared during the run';
  if (objNow === -1) return 'disappeared during the run';
  const strWas = String(objWas);
  const strNow = String(objNow);
  const strWasInode = strWas.slice(0, strWas.indexOf(':'));
  const strNowInode = strNow.slice(0, strNow.indexOf(':'));
  if (strWasInode === strNowInode) return 'change time moved';
  return strWas.slice(strWasInode.length) === strNow.slice(strNowInode.length)
    ? 'replaced by a different inode, within one timestamp tick'
    : 'replaced by a different inode';
};
const funcFirstSweepDifference = (objBaseline, objFinal) => {
  for (const [strLabel, intFinal] of objFinal) {
    if (!objBaseline.has(strLabel)) {
      return { kind: 'appeared during the run', label: strLabel, now: intFinal };
    }
    if (objBaseline.get(strLabel) !== intFinal) {
      return {
        kind: funcDescribeSweepChange(objBaseline.get(strLabel), intFinal),
        label: strLabel,
        was: objBaseline.get(strLabel),
        now: intFinal,
      };
    }
  }
  for (const [strLabel, intWas] of objBaseline) {
    if (!objFinal.has(strLabel)) {
      return { kind: 'disappeared during the run', label: strLabel, was: intWas };
    }
  }
  return null;
};
const objSweepDifference = funcFirstSweepDifference(
  objBaselineChange.entries, objNewestChange.entries);
if (objSweepDifference) {
  process.stderr.write(
    'supply-freeze: the recorded inputs changed while recording; refusing to report.\n' +
    '  detected by        per-entry inode identity and change time, not by the fold\n' +
    '                     comparison\n' +
    `  entry              ${formatUntrustedText(objSweepDifference.label)}\n` +
    `  what changed       ${objSweepDifference.kind}\n` +
    (objSweepDifference.was === undefined
      ? ''
      : `  baseline reading   ${formatSweepReading(objSweepDifference.was)}\n`) +
    (objSweepDifference.now === undefined
      ? ''
      : `  final reading      ${formatSweepReading(objSweepDifference.now)}\n`) +
    `  entries swept      ${objBaselineChange.entries.size} at baseline, ` +
      `${objNewestChange.entries.size} at the end\n` +
    `  recording began    ${new Date(intRecordingStartedAt).toISOString()}\n` +
    '  an entry changed after this run began, so the digest above describes bytes\n' +
    '  that are no longer on disk. record against a quiescent tree.\n' +
    '  every swept entry is compared against its own baseline reading, so a change\n' +
    '  is caught whichever direction the timestamp moves, and a swap that moves no\n' +
    '  timestamp at all is caught by the inode half. comparing one newest\n' +
    '  ctime against another would miss any write that lands below a maximum set\n' +
    '  by an inode stamped ahead of this machine\'s clock.\n');
  process.exit(10);
}

// Round 11, reported and confirmed. The manifest assertion above runs BEFORE
// the second fold and the sweep, and nothing read the manifests again after it,
// so a write landing in that interval was invisible: measured, editing
// package.json during the second fold gave exit 0 with the reviewed hash
// the reviewed manifest hash reported, matchesReviewedManifest: true, and
// different bytes actually on disk at emission.
//
// That is the identical late-write window the second fold was added to close
// for node_modules, left open one file over -- the same "fixed it here, not
// there" shape this review has now found several times. The content comparison
// is repeated here, after every scan and immediately before the record is
// emitted, so the hashes reported are the bytes last observed.
if (!readOrRefuse(strPackagePath).equals(objPackageBefore)
  || !readOrRefuse(strLockPath).equals(objLockBefore)) {
  process.stderr.write(
    'supply-freeze: package metadata changed after the tree was recorded; refusing to report\n' +
    '  the manifest hashes above would describe bytes that are no longer on disk.\n');
  process.exit(3);
}

// Round 12. The script's own bytes, re-compared after everything else. A
// replacement during the run would otherwise leave the reported script digest
// describing a file that is not the one that produced these numbers.
// The script self-check owns its own answer: a raced replacement of THIS SCRIPT is
// exit 3 per the refusal table, not the manifest's exit 15.
if (!readOrRefuse(strScriptPath, { exit: 3, what: 'script' }).equals(objScriptBefore)) {
  process.stderr.write(
    'supply-freeze: this script changed while it was running; refusing to report.\n' +
    `  reported digest    ${strScriptSha256}\n` +
    '  the file on disk no longer matches the source that derived these values.\n');
  process.exit(3);
}

// Round 18, reported, and the same defect round 15 fixed for the umask. The
// value compared and the value printed were two separate stat calls, so a
// message could quote a timestamp that was never the one refused.
// Round 22, reported. The read above is guarded and this stat was not, so the
// source vanishing between them exited 1 with a stack trace where the table says
// exit 3. Same transition, same refusal.
const intScriptChangedAt = (() => {
  try {
    return lstatSync(strScriptPath).ctimeMs;
  } catch (objError) {
    process.stderr.write(
      'supply-freeze: this script became unreadable during the run; refusing to report.\n' +
      formatErrorLocation(objError, strScriptPath));
    process.exit(3);
  }
})();
if (intScriptChangedAt !== intScriptChangedAtStart) {
  process.stderr.write(
    'supply-freeze: this script was replaced during the run; refusing to report.\n' +
    `  script ctime       ${new Date(intScriptChangedAt).toISOString()}\n` +
    `  was at start       ${new Date(intScriptChangedAtStart).toISOString()}\n` +
    `  process began      ${new Date(intProcessStartedAt).toISOString()}\n` +
    '  the bytes may have been restored, but the run is no longer attributable.\n' +
    '  the two ctimes are filesystem-stamped and directly comparable; the process\n' +
    '  line is context only and is not what this refusal tested.\n');
  process.exit(3);
}

// Round 7, reported. `--any-toolchain` promised output that is "explicitly not
// a freeze record", and then emitted the identical heading and the identical
// JSON schema as a reviewed run -- measured under umask 077, the bypassed run
// printed the same `T1-SUPPLY-FREEZE-v1 digests` banner with
// `matchesReviewedManifest: true` and no key distinguishing it. A consumer
// reading saved output could not tell the two apart without independently
// re-deriving every pinned value, which is the work the record exists to save.
//
// The promise was in the help text and the document; it was not in the output.
// It is now a field, so it survives being piped to a file.
//
// --no-audit is tracked separately rather than lumped in: it produces a
// legitimately partial record whose missing half is visible as a null digest,
// which is a different thing from a record whose guards did not run.
const arrNotFreezeBecause = [];
if (boolAnyToolchain) arrNotFreezeBecause.push('guards bypassed with --any-toolchain');
if (boolSkipAudit) arrNotFreezeBecause.push('advisory posture not recorded (--no-audit)');
objRecord.freezeRecord = arrNotFreezeBecause.length === 0;
objRecord.notFreezeRecordBecause = arrNotFreezeBecause;

// Round 46, reported by Codex. Round 45 swept the toolchain versions after the
// unrecognized-argument defect and escaped the exit-2 refusal that prints them --
// then stopped, because that sweep ranged over REFUSALS rather than over every
// site that renders the value. This renderer prints the same npm version on the
// SUCCESS path and did not escape it. Measured, with node relocated so that npm
// is not beside it and an unreviewed npm answering first on PATH:
//
//   T1-SUPPLY-FREEZE-v1 digests -- NOT A FREEZE RECORD
//     !! guards bypassed with --any-toolchain
//     npm                  11.16.0
//   T1-SUPPLY-FREEZE-v1 digests          <- forged, at column 0, exit 0
//
// which re-asserts the freeze header three lines under the banner denying it.
//
// That also corrects the round-45 reply's reachability claim. I reported the
// fake-npm path as "not demonstrated" because the PATH pin puts this Node's own
// directory first and npm ships beside node. Both halves are still true and the
// conclusion did not follow: the pin only wins when npm is IN that directory,
// and a copied or relocated node is an ordinary layout, not an exotic one.
//
// Fixed as an invariant rather than at the field reported, because "which fields
// are attacker-reachable" is exactly the argument that failed last round: EVERY
// value interpolated into the human record passes the formatter. On digests,
// counts, modes and booleans it is a no-op -- formatTreeName rewrites only
// Cc/Cf/Zl/Zp and none of them contain those -- so the rule costs nothing and,
// unlike the sweep it replaces, cannot be applied to some sites and not others.
// Verified byte-identical against the pre-fix output on a clean run.
function renderRecordRow(strLabel, objValue) {
  return `  ${strLabel.padEnd(21)}${formatUntrustedText(objValue)}\n`;
}

const objContractAfter = readContractOrRefuse(strContractPath);
const objContractIdentityAfter = contractIdentityOrRefuse();
if (!objContractBefore.equals(objContractAfter)
  || objContractIdentityBefore.ino !== objContractIdentityAfter.ino
  || objContractIdentityBefore.ctimeNs !== objContractIdentityAfter.ctimeNs) {
  process.stderr.write('supply-freeze: P1 contract changed during recording; refusing.\n');
  process.exit(3);
}
const { freezeRecord: boolComplete, notFreezeRecordBecause: arrIncompleteBecause,
  ...objCurrentObservation } = objRecord;
const objOutput = {
  supplyFreeze: objSupplyFreeze,
  provenance: {
    historicalAssertions: ['supplyFreeze.reviewedCommit', 'supplyFreeze.baseline',
      'supplyFreeze.producer', 'supplyFreeze.yaml', 'supplyFreeze.installedTree',
      'supplyFreeze.advisoryDecision'],
    verifiedCurrentBytes: objRecord.matchesReviewedManifest ? ['supplyFreeze.reviewedWorkingBytes'] : [],
    externalVerificationRequired: ['historical Git objects and commit/path relationships',
      'producer archive and signature', 'yaml tarball', 'historical audit responses and disposition'],
    historicalInstalledTreeRecipe: 'not established; not reproduced by this observation',
    contractSha256: sha256(objContractBefore),
    contractBlob: gitBlobId(objContractBefore),
  },
  currentObservation: { complete: boolComplete, incompleteBecause: arrIncompleteBecause,
    policyAuthorization: 'not evaluated; current advisories do not extend the historical disposition',
    ...objCurrentObservation, npmProcesses: objNpmProcessResults },
};
if (boolJson) {
  process.stdout.write(`${JSON.stringify(objOutput, null, 2)}\n`);
} else {
  process.stdout.write(
    (objRecord.freezeRecord
      ? 'P1 current Linux observation (historical assertions require separate verification)\n'
      : `P1 current Linux observation -- NOT A COMPLETE OBSERVATION\n${
        arrNotFreezeBecause.map((strReason) => `  !! ${formatUntrustedText(strReason)}\n`).join('')}`) +
    renderRecordRow('script sha256', objRecord.script.sha256) +
    renderRecordRow('Node', objRecord.toolchain.node) +
    renderRecordRow('npm', objRecord.toolchain.npm) +
    renderRecordRow('platform', `${objRecord.toolchain.platform}/${objRecord.toolchain.arch}`) +
    renderRecordRow('umask', objRecord.toolchain.umask) +
    renderRecordRow('package.json', objRecord.manifest['package.json']) +
    renderRecordRow('package-lock.json', objRecord.manifest['package-lock.json']) +
    renderRecordRow('matches reviewed', objRecord.matchesReviewedManifest) +
    renderRecordRow('tree satisfies lock', objRecord.treeSatisfiesLockfile) +
    renderRecordRow('installed tree', objRecord.installedTreeSha256) +
    `    (${formatUntrustedText(objRecord.installedTreeFiles)} files, ${formatUntrustedText(objRecord.installedTreeSymlinks)} symlinks, ${formatUntrustedText(objRecord.installedTreeDirectories)} directories, ${formatUntrustedText(objRecord.installedTreeSpecials)} special entries on disk)\n` +
    `    (file permissions ${formatUntrustedText(JSON.stringify(objRecord.installedTreeModes))}; a different shape is consistent with a different install umask, or with modes changed after install)\n` +
    `    (directory permissions ${formatUntrustedText(JSON.stringify(objRecord.installedTreeDirectoryModes))}, node_modules itself ${formatUntrustedText(objRecord.installedTreeRootMode)})\n` +
    (objRecord.auditSha256
      ? renderRecordRow('registry', objRecord.registry) +
        renderRecordRow('advisory posture', objRecord.auditSha256) +
        renderRecordRow('advisory counts', JSON.stringify(objRecord.auditCounts)) +
        renderAuditPackageSummary(objRecord.auditPackages)
      : '  advisory posture     (skipped)\n'));
}
