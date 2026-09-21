import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { cpSync, existsSync, linkSync, lstatSync, mkdirSync, mkdtempSync,
  readFileSync, readdirSync, readlinkSync, realpathSync, rmSync, symlinkSync,
  writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { delimiter, dirname, isAbsolute, join } from 'node:path';
import { fileURLToPath } from 'node:url';
import test from 'node:test';

const workflow = dirname(fileURLToPath(import.meta.url));
const source = readFileSync(join(workflow, 'Get-SupplyFreezeDigest.mjs'), 'utf8');
const sha = (bytes) => createHash('sha256').update(bytes).digest('hex');

// Extract the production function, rather than duplicating its predicate in a
// test-only implementation. Subprocess outcomes here are synthetic fixtures.
const start = source.indexOf('function runNpmAllowingFailure(');
const end = source.indexOf('\n}\n', start) + 2;
assert.ok(start >= 0 && end > start);
const auditFunction = (runNpm) => new Function('runNpm', 'process',
  `${source.slice(start, end)}; return runNpmAllowingFailure;`)(runNpm, {
  stderr: { write() {} }, exit(code) { throw new Error(`refusal:${code}`); },
});
const report = '{"auditReportVersion":2,"vulnerabilities":{}}';

test('NODE-CHILD-ENV: production child projection removes startup writers without hiding warnings', () => {
  const from = source.indexOf('function npmChildEnv(');
  const to = source.indexOf('\n}\n', from) + 2;
  assert.ok(from >= 0 && to > from);
  const project = new Function('dirname', 'delimiter', 'process',
    `${source.slice(from, to)}; return npmChildEnv;`)(dirname, delimiter, process);
  const input = { PATH: '/trusted', NODE_OPTIONS: '--trace-warnings', NODE_COMPILE_CACHE: '/forbidden',
    NODE_V8_COVERAGE: '/forbidden', NODE_REDIRECT_WARNINGS: '/forbidden', NODE_DISABLE_COMPILE_CACHE: '0',
    npm_config_workspace: 'wrong', KEEP_THIS: 'yes' };
  const output = project(input);
  for (const key of ['NODE_OPTIONS', 'NODE_COMPILE_CACHE', 'NODE_V8_COVERAGE', 'NODE_REDIRECT_WARNINGS',
    'npm_config_workspace']) assert.equal(Object.hasOwn(output, key), false);
  assert.equal(output.NODE_DISABLE_COMPILE_CACHE, '1');
  assert.equal(output.KEEP_THIS, 'yes');
  assert.equal(Object.hasOwn(output, 'NODE_NO_WARNINGS'), false);
  assert.equal(input.NODE_DISABLE_COMPILE_CACHE, '0');
});

test('NPM-DIAGNOSTIC: production summary preserves category and outcome without child text', () => {
  const from = source.indexOf('const NPM_DIAGNOSTIC_CATEGORIES');
  const functionStart = source.indexOf('function writeNpmDiagnosticSummary(', from);
  const to = source.indexOf('\n}\n', functionStart) + 2;
  assert.ok(from >= 0 && functionStart > from && to > functionStart);
  let diagnostic = '';
  const writeSummary = new Function('formatUntrustedText', 'process',
    `${source.slice(from, to)}; return writeNpmDiagnosticSummary;`)(String, {
    stderr: { write(value) { diagnostic += value; } },
  });
  const childText = 'npm warn deprecated UNIQUE_SECRET_WARNING\n';
  writeSummary('config', { status: 0, signal: null, stderr: childText });
  assert.match(diagnostic, /operation\s+config/);
  assert.match(diagnostic, /native exit\s+0/);
  assert.match(diagnostic, /signal\s+none/);
  assert.match(diagnostic, new RegExp(`stderr length\\s+${childText.length} characters`));
  assert.match(diagnostic, /categories\s+warning/);
  assert.doesNotMatch(diagnostic, /UNIQUE_SECRET_WARNING|deprecated/);
});

test('AUDIT-STATUS: native success and advisory status are distinct from process failures', () => {
  assert.equal(auditFunction(() => report)(['audit']), report);
  assert.equal(auditFunction(() => { throw { status: 1, signal: null, stdout: report }; })(['audit']), report);
  for (const outcome of [
    { status: 2, signal: null, stdout: report },
    { status: null, signal: 'SIGTERM', stdout: report },
    { status: 1, signal: null, code: 'EIO', stdout: report },
    { status: 1, signal: null, syscall: 'spawnSync', stdout: report },
    { status: 1, signal: null, stdout: 'not JSON' },
  ]) assert.throws(() => auditFunction(() => { throw outcome; })(['audit']), /refusal:5/);
});

test('ARGUMENT-PRIVACY: unsupported tokens expose only original position and code-point length', () => {
  const strFlag = '--TASK130_F11_🔑=BEARER_SECRET';
  const strOperand = 'TASK130_F11_SEPARATED_SECRET';
  const strConcatenated = '--TASK130_F11_CONCATENATED_SECRET';
  const result = spawnSync(process.execPath, [join(workflow, 'Get-SupplyFreezeDigest.mjs'),
    '--cache-directory=/not-used', strFlag, strOperand, strConcatenated, '--json'], { encoding: 'utf8' });
  assert.equal(result.status, 2, result.stderr);
  assert.equal(result.stdout, '');
  assert.match(result.stderr,
    new RegExp(`argument 2 \\(${[...strFlag].length} Unicode code points withheld\\)`));
  assert.match(result.stderr,
    new RegExp(`argument 3 \\(${[...strOperand].length} Unicode code points withheld\\)`));
  assert.match(result.stderr,
    new RegExp(`argument 4 \\(${[...strConcatenated].length} Unicode code points withheld\\)`));
  assert.match(result.stderr, /supported\s+--json --any-toolchain --no-audit --cache-directory=<path>/);
  assert.doesNotMatch(result.stderr, /TASK130_F11|BEARER_SECRET|SEPARATED_SECRET|CONCATENATED_SECRET|🔑/u);
});

test('DESCRIPTOR-FAILURE: open, fstat, read, and close failures retain caller exits and close once', () => {
  const from = source.indexOf('function readViaVerifiedDescriptor(');
  const to = source.indexOf('\n}\n', from) + 2;
  assert.ok(from >= 0 && to > from);
  const objRegular = {
    isFile: () => true, isSymbolicLink: () => false, isDirectory: () => false,
    isFIFO: () => false, isSocket: () => false, isCharacterDevice: () => false,
    isBlockDevice: () => false, nlink: 1, uid: 1000,
  };
  const fixture = (objScenario = {}, intMissingExit = 17) => {
    const arrMissing = [];
    const arrDiagnostic = [];
    let intCloseCalls = 0;
    const readVerified = new Function('openSync', 'fsConstants', 'fstatSync',
      'readFileSync', 'closeSync', 'process',
      `${source.slice(from, to)}; return readViaVerifiedDescriptor;`)(
      () => {
        if (objScenario.openError) throw objScenario.openError;
        return 41;
      }, { O_RDONLY: 1, O_NONBLOCK: 2, O_NOFOLLOW: 4 }, () => {
        if (objScenario.fstatError) throw objScenario.fstatError;
        return objScenario.stats ?? objRegular;
      }, () => {
        if (objScenario.readError) throw objScenario.readError;
        return Buffer.from('fixture bytes');
      }, () => {
        intCloseCalls += 1;
        if (objScenario.closeError) throw objScenario.closeError;
      }, {
        getuid: () => 1000,
        stderr: { write(value) { arrDiagnostic.push(value); } },
        exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
      });
    return {
      invoke: () => readVerified('/fixture/input', intMissingExit, (error) => arrMissing.push(error),
        { exit: 15, what: 'contract', holdable: true }),
      arrMissing, arrDiagnostic, closeCalls: () => intCloseCalls,
    };
  };

  const objSuccess = fixture();
  assert.deepEqual(objSuccess.invoke(), Buffer.from('fixture bytes'));
  assert.equal(objSuccess.closeCalls(), 1);
  assert.deepEqual(objSuccess.arrMissing, []);

  for (const intMissingExit of [4, 3, 17]) {
    for (const strStage of ['open', 'fstat', 'read', 'close']) {
      const objPrimary = Object.assign(new Error(`${strStage}-primary`), { code: 'EIO' });
      const objClose = Object.assign(new Error('close-secondary'), { code: 'EIO' });
      const objScenario = strStage === 'open'
        ? { openError: objPrimary }
        : strStage === 'fstat'
          ? { fstatError: objPrimary, closeError: objClose }
          : strStage === 'read'
            ? { readError: objPrimary, closeError: objClose }
            : { closeError: objPrimary };
      const objFixture = fixture(objScenario, intMissingExit);
      assert.throws(objFixture.invoke, (error) => error.refusal === intMissingExit);
      assert.equal(objFixture.arrMissing.length, 1);
      assert.equal(objFixture.arrMissing[0], objPrimary);
      assert.equal(objFixture.closeCalls(), strStage === 'open' ? 0 : 1);
    }
  }

  const objEloop = fixture({ openError: Object.assign(new Error('link'), { code: 'ELOOP' }) });
  assert.throws(objEloop.invoke, (error) => error.refusal === 15);
  assert.equal(objEloop.closeCalls(), 0);
  assert.deepEqual(objEloop.arrMissing, []);

  for (const stats of [
    { ...objRegular, isFile: () => false, isDirectory: () => true },
    { ...objRegular, nlink: 2 },
    { ...objRegular, uid: 1001 },
  ]) {
    const objIntentional = fixture({ stats, closeError: new Error('close-secondary') });
    assert.throws(objIntentional.invoke, (error) => error.refusal === 15);
    assert.equal(objIntentional.closeCalls(), 1);
    assert.deepEqual(objIntentional.arrMissing, []);
  }
});

test('JSON-RESPONSE-PRIVACY: parser, schema, and normalization refusals withhold source content', () => {
  const parseFrom = source.indexOf('function firstDuplicateJsonKey(');
  const parseFunction = source.indexOf('function parseAuditOrRefuse(', parseFrom);
  const parseTo = source.indexOf('\n}\n', parseFunction) + 2;
  const auditFrom = source.indexOf('function auditCountsOrRefuse(');
  const normalizeFunction = source.indexOf('function normalizeAuditOrRefuse(', auditFrom);
  const auditTo = source.indexOf('\n}\n', normalizeFunction) + 2;
  assert.ok(parseFrom >= 0 && parseTo > parseFunction && auditFrom >= 0 && auditTo > normalizeFunction);
  let strDiagnostic = '';
  const objFunctions = new Function('process', 'Buffer', 'isPlainObject',
    'SEVERITY_ORDER', 'normalizeAudit',
    `${source.slice(parseFrom, parseTo)}\n${source.slice(auditFrom, auditTo)}; return {`
      + 'parseNpmJsonOrRefuse, parseAuditOrRefuse, auditCountsOrRefuse, normalizeAuditOrRefuse};')({
    stderr: { write(value) { strDiagnostic += value; } },
    exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
  }, Buffer, (value) => value !== null && typeof value === 'object' && !Array.isArray(value),
  ['info', 'low', 'moderate', 'high', 'critical', 'total'], () => {
    throw new TypeError('TASK130_F13_NORMALIZATION_SECRET');
  });
  const assertPrivateRefusal = (fn, intExit, strCategory, strSecret) => {
    strDiagnostic = '';
    assert.throws(fn, (error) => error.refusal === intExit);
    assert.match(strDiagnostic, new RegExp(`category\\s+${strCategory}`));
    assert.match(strDiagnostic, /decoded length\s+\d+ UTF-8 bytes/);
    assert.doesNotMatch(strDiagnostic, new RegExp(strSecret));
  };

  assertPrivateRefusal(
    () => objFunctions.parseAuditOrRefuse('<TASK130_F13_INVALID_SECRET'),
    5, 'invalid JSON', 'TASK130_F13_INVALID_SECRET');
  assertPrivateRefusal(
    () => objFunctions.parseAuditOrRefuse('{"TASK130_F13_DUPLICATE_SECRET":1,"TASK130_F13_DUPLICATE_SECRET":2}'),
    5, 'repeated object key', 'TASK130_F13_DUPLICATE_SECRET');
  assertPrivateRefusal(
    () => objFunctions.parseNpmJsonOrRefuse(
      '{"TASK130_F13_CONTRACT_SECRET":1,"TASK130_F13_CONTRACT_SECRET":2}', 'P1 contract', 17),
    17, 'repeated object key', 'TASK130_F13_CONTRACT_SECRET');
  assertPrivateRefusal(
    () => objFunctions.parseNpmJsonOrRefuse('<TASK130_F13_CONTRACT_INVALID_SECRET', 'P1 contract', 17),
    17, 'invalid JSON', 'TASK130_F13_CONTRACT_INVALID_SECRET');
  const strSchema = '{"message":"TASK130_F13_SCHEMA_SECRET","error":{}}';
  assertPrivateRefusal(
    () => objFunctions.auditCountsOrRefuse(strSchema, JSON.parse(strSchema)),
    5, 'unexpected response schema', 'TASK130_F13_SCHEMA_SECRET');
  assertPrivateRefusal(
    () => objFunctions.auditCountsOrRefuse('null', null),
    5, 'unexpected response schema', 'null');
  const strArraySchema = '["TASK130_F13_ARRAY_SCHEMA_SECRET"]';
  assertPrivateRefusal(
    () => objFunctions.auditCountsOrRefuse(strArraySchema, JSON.parse(strArraySchema)),
    5, 'unexpected response schema', 'TASK130_F13_ARRAY_SCHEMA_SECRET');
  const objValidCounts = { info: 0, low: 0, moderate: 0, high: 0, critical: 0, total: 0 };
  const objValidAudit = { auditReportVersion: 2, vulnerabilities: {},
    metadata: { vulnerabilities: objValidCounts } };
  assert.equal(objFunctions.auditCountsOrRefuse(JSON.stringify(objValidAudit), objValidAudit), objValidCounts);
  const strNormalization = '{"package":"TASK130_F13_NORMALIZATION_SECRET"}';
  assertPrivateRefusal(
    () => objFunctions.normalizeAuditOrRefuse(strNormalization, JSON.parse(strNormalization)),
    5, 'response normalization failed', 'TASK130_F13_NORMALIZATION_SECRET');
});

test('NPM-LINK-CONTAINMENT: production resolver rejects every uncovered resolution shape',
  { skip: process.platform !== 'linux' }, () => {
    const from = source.indexOf('const isInsideOrEqual = ');
    const to = source.indexOf('\nfunction foldNpmInstallation(', from);
    assert.ok(from >= 0 && to > from);
    const classify = new Function('dirname', 'isAbsolute', 'lstatSync', 'readlinkSync',
      'realpathSync', `${source.slice(from, to)}; return classifyContainedSymlink;`)(
      dirname, isAbsolute, lstatSync, readlinkSync, realpathSync);
    const foldFrom = to + 1;
    // Match the repository's column-zero function-close convention instead of
    // coupling this production slice to an unrelated review-history comment.
    const foldTo = source.indexOf('\n}\n', foldFrom) + 2;
    assert.ok(foldTo > foldFrom);
    const diagnostic = [];
    const testProcess = {
      execPath: process.execPath,
      getuid: process.getuid.bind(process),
      stderr: { write(value) { diagnostic.push(value); } },
      exit(code) {
        throw Object.assign(new Error(`refusal:${code}`), { refusal: code });
      },
    };
    const hashFieldForFixture = (hash, value) => {
      const bytes = Buffer.isBuffer(value) ? value : Buffer.from(String(value), 'utf8');
      hash.update(String(bytes.length), 'utf8');
      hash.update(':', 'utf8');
      hash.update(bytes);
    };
    // Exercise the production npm fold itself. The injected functions are
    // bounded fixture dependencies, including simplified hash framing; these
    // outcomes prove containment/refusal control flow, not a production digest.
    // The branch under test remains the exact source slice the recorder executes.
    const foldNpm = new Function('createHash', 'dirname', 'isAbsolute', 'join',
      'lstatSync', 'readlinkSync', 'realpathSync', 'readdirSync', 'readFileSync',
      'process', 'formatUntrustedText', 'formatErrorLocation', 'hashField',
      'statIdentity', 'sha256',
      `${source.slice(from, foldTo)}; return foldNpmInstallation;`)(
      createHash, dirname, isAbsolute, join, lstatSync, readlinkSync, realpathSync,
      readdirSync, readFileSync, testProcess, String,
      (error, path) => `  error              ${error?.code ?? 'unknown'} at ${path}\n`,
      hashFieldForFixture, (stats) => `${stats.ino}:${stats.ctimeNs}`, sha);

    const temporary = mkdtempSync(join(tmpdir(), 'npm-link-containment-'));
    const root = join(temporary, 'npm');
    const outside = join(temporary, 'outside');
    mkdirSync(root);
    mkdirSync(outside);
    writeFileSync(join(root, 'target'), 'inside');
    writeFileSync(join(outside, 'target'), 'outside');
    try {
      symlinkSync('target', join(root, 'contained-b'));
      symlinkSync('contained-b', join(root, 'contained-a'));
      assert.deepEqual(classify(root, join(root, 'contained-a'), 'contained-a'),
        { status: 'contained' });
      assert.equal(foldNpm(realpathSync(root)).symlinks, 2);

      symlinkSync(join(outside, 'target'), join(root, 'direct-escape'));
      assert.deepEqual(classify(root, join(root, 'direct-escape'), 'direct-escape'),
        { status: 'escaping' });
      assert.throws(() => foldNpm(realpathSync(root)), { refusal: 2 });
      assert.doesNotMatch(diagnostic.join(''), new RegExp(outside.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
      rmSync(join(root, 'direct-escape'));

      symlinkSync(join(root, 'target'), join(outside, 'return-hop'));
      symlinkSync(join(outside, 'return-hop'), join(root, 'escape-return'));
      assert.deepEqual(classify(root, join(root, 'escape-return'), 'escape-return'),
        { status: 'escaping' });
      assert.throws(() => foldNpm(realpathSync(root)), { refusal: 2 });
      rmSync(join(root, 'escape-return'));

      symlinkSync('missing', join(root, 'dangling'));
      assert.deepEqual(classify(root, join(root, 'dangling'), 'dangling'),
        { status: 'unresolved', code: 'ENOENT' });
      assert.throws(() => foldNpm(realpathSync(root)), { refusal: 2 });
      rmSync(join(root, 'dangling'));

      symlinkSync('loop-b', join(root, 'loop-a'));
      symlinkSync('loop-a', join(root, 'loop-b'));
      assert.deepEqual(classify(root, join(root, 'loop-a'), 'loop-a'),
        { status: 'unresolved', code: 'ELOOP' });

      symlinkSync(Buffer.from([0x80]), join(root, 'invalid-utf8'));
      assert.deepEqual(classify(root, join(root, 'invalid-utf8'), 'invalid-utf8'),
        { status: 'unresolved', code: 'EILSEQ' });
    } finally {
      rmSync(temporary, { recursive: true, force: true });
    }
  });

test('HOST: native unsupported host refuses without npm or output', { skip: process.platform === 'linux' }, () => {
  const result = spawnSync(process.execPath, [join(workflow, 'Get-SupplyFreezeDigest.mjs'), '--json'], { encoding: 'utf8' });
  assert.equal(result.status, 2);
  assert.equal(result.stdout, '');
  assert.match(result.stderr, /Linux\/x64 only/);
});

function fingerprint(root) {
  const rows = [];
  function walk(path, relative) {
    const stat = lstatSync(path, { bigint: true });
    const common = [relative, stat.mode.toString(), stat.ino.toString(), stat.ctimeNs.toString()];
    if (stat.isSymbolicLink()) rows.push([...common, 'L', readlinkSync(path, { encoding: 'buffer' }).toString('hex')]);
    else if (stat.isFile()) rows.push([...common, 'F', sha(readFileSync(path))]);
    else if (stat.isDirectory()) {
      rows.push([...common, 'D']);
      for (const entry of readdirSync(path).sort()) walk(join(path, entry), `${relative}/${entry}`);
    } else rows.push([...common, 'S']);
  }
  walk(root, '');
  return { sha256: sha(JSON.stringify(rows)), entries: rows.length,
    files: rows.filter((row) => row[4] === 'F').length,
    directories: rows.filter((row) => row[4] === 'D').length,
    links: rows.filter((row) => row[4] === 'L').length };
}

test('LINUX: strict success, entire ignored tree preservation, and refusal properties',
  { skip: process.platform !== 'linux' || process.arch !== 'x64' }, () => {
    const temporary = mkdtempSync(join(tmpdir(), 'p1-recorder-tests-'));
    const checkout = join(temporary, 'checkout');
    const fixture = join(checkout, '.github', 'workflows');
    mkdirSync(fixture, { recursive: true });
    for (const name of ['Get-SupplyFreezeDigest.mjs', 'package.json', 'package-lock.json', 'workflow-policy-contract.json']) {
      cpSync(join(workflow, name), join(fixture, name));
    }
    cpSync(join(workflow, 'node_modules'), join(fixture, 'node_modules'), { recursive: true, verbatimSymlinks: true });
    const contract = JSON.parse(readFileSync(join(fixture, 'workflow-policy-contract.json')));
    const invoke = (flags = [], env = {}) => {
      const cache = mkdtempSync(join(temporary, 'cache-'));
      return spawnSync(process.execPath, [join(fixture, 'Get-SupplyFreezeDigest.mjs'),
        '--json', `--cache-directory=${cache}`, ...flags], {
        encoding: 'utf8', maxBuffer: 16 * 1024 * 1024,
        env: { ...process.env, ...env },
      });
    };
    const refuse = (result, code) => {
      assert.equal(result.status, code, result.stderr);
      assert.equal(result.stdout, '');
    };
    try {
      const before = fingerprint(checkout);
      const success = invoke([], {
        npm_config_cache: join(checkout, 'forbidden-cache'),
        npm_config_logs_dir: join(checkout, 'forbidden-logs'),
        npm_config_timing: 'true',
      });
      assert.equal(success.status, 0, success.stderr);
      const result = JSON.parse(success.stdout);
      assert.equal(result.currentObservation.complete, true);
      assert.deepEqual(result.supplyFreeze, contract.supplyFreeze);
      assert.deepEqual(result.provenance.verifiedCurrentBytes, ['supplyFreeze.reviewedWorkingBytes']);
      assert.equal(result.currentObservation.toolchain.platform, 'linux');
      assert.equal(result.supplyFreeze.producer.platform, 'win32-x64');
      assert.ok(result.currentObservation.npmProcesses.every((item) => item.signal === null
        && (item.nativeExit === 0 || (item.operation === 'audit' && item.nativeExit === 1))));
      assert.deepEqual(fingerprint(checkout), before);
      assert.equal(existsSync(join(checkout, 'forbidden-cache')), false);
      assert.equal(existsSync(join(checkout, 'forbidden-logs')), false);

      const startupTargets = ['node-cache', 'node-coverage', 'node-warnings'].map((name) => join(checkout, name));
      const scrubbed = spawnSync('env', ['-u', 'NODE_OPTIONS', '-u', 'NODE_COMPILE_CACHE',
        '-u', 'NODE_V8_COVERAGE', '-u', 'NODE_REDIRECT_WARNINGS', 'NODE_DISABLE_COMPILE_CACHE=1',
        process.execPath, join(fixture, 'Get-SupplyFreezeDigest.mjs'), '--json',
        `--cache-directory=${mkdtempSync(join(temporary, 'startup-cache-'))}`], {
        encoding: 'utf8', maxBuffer: 16 * 1024 * 1024,
        env: { ...process.env, NODE_OPTIONS: '--trace-warnings', NODE_COMPILE_CACHE: startupTargets[0],
          NODE_V8_COVERAGE: startupTargets[1], NODE_REDIRECT_WARNINGS: startupTargets[2], NODE_DISABLE_COMPILE_CACHE: '0' },
      });
      assert.equal(scrubbed.status, 0, scrubbed.stderr);
      assert.equal(JSON.parse(scrubbed.stdout).currentObservation.complete, true);
      assert.ok(startupTargets.every((path) => !existsSync(path)));
      assert.deepEqual(fingerprint(checkout), before);
      refuse(invoke(['--no-audit'], { NODE_REDIRECT_WARNINGS: join(temporary, 'unsupported-warnings') }), 2);

      const partialRun = invoke(['--no-audit']);
      assert.equal(partialRun.status, 0, partialRun.stderr);
      const partial = JSON.parse(partialRun.stdout);
      assert.equal(partial.currentObservation.complete, false);
      assert.equal(Object.hasOwn(partial.currentObservation, 'registry'), true);
      assert.equal(partial.currentObservation.registry, null);
      assert.equal(Object.hasOwn(partial.currentObservation, 'auditSha256'), true);
      assert.equal(partial.currentObservation.auditSha256, null);
      assert.equal(Object.hasOwn(partial.currentObservation, 'auditEnvironmentScrubbed'), true);
      assert.deepEqual(partial.currentObservation.auditEnvironmentScrubbed, []);
      assert.equal(Object.hasOwn(partial.currentObservation, 'auditCounts'), true);
      assert.equal(partial.currentObservation.auditCounts, null);
      assert.equal(Object.hasOwn(partial.currentObservation, 'auditPackages'), true);
      assert.equal(partial.currentObservation.auditPackages, null);
      assert.equal(partial.currentObservation.installedTreeSha256, result.currentObservation.installedTreeSha256);

      const packagePath = join(fixture, 'package.json');
      const packageBytes = readFileSync(packagePath);
      writeFileSync(packagePath, Buffer.concat([packageBytes, Buffer.from('\n')]));
      refuse(invoke(['--no-audit']), 4);
      const diagnostic = invoke(['--no-audit', '--any-toolchain']);
      assert.equal(diagnostic.status, 0, diagnostic.stderr);
      const diagnosticRecord = JSON.parse(diagnostic.stdout);
      assert.equal(diagnosticRecord.currentObservation.complete, false);
      assert.deepEqual(diagnosticRecord.provenance.verifiedCurrentBytes, []);
      writeFileSync(packagePath, packageBytes);

      const contractPath = join(fixture, 'workflow-policy-contract.json');
      const contractBytes = readFileSync(contractPath);
      rmSync(contractPath);
      refuse(invoke(['--no-audit', '--any-toolchain']), 17);
      writeFileSync(contractPath, contractBytes);
      const contractAliasDirectory = join(temporary, 'contract-link-target');
      mkdirSync(contractAliasDirectory);
      linkSync(contractPath, join(contractAliasDirectory, 'contract-alias'));
      refuse(invoke(['--no-audit', '--any-toolchain']), 17);
      rmSync(contractAliasDirectory, { recursive: true });
      rmSync(contractPath);
      mkdirSync(contractPath);
      refuse(invoke(['--no-audit', '--any-toolchain']), 17);
      rmSync(contractPath, { recursive: true });
      writeFileSync(contractPath, contractBytes);
      const altered = JSON.parse(contractBytes);
      altered.supplyFreeze.baseline.packageJson.length++;
      writeFileSync(contractPath, JSON.stringify(altered));
      refuse(invoke(['--no-audit', '--any-toolchain']), 17);
      writeFileSync(contractPath, contractBytes);

      const privateConfig = join(temporary, 'UNIQUE_SECRET_CONFIG');
      writeFileSync(privateConfig, '');
      const configFailure = invoke(['--no-audit'], {
        NPM_CONFIG_USERCONFIG: privateConfig,
        NPM_CONFIG_GLOBALCONFIG: privateConfig,
      });
      refuse(configFailure, 2);
      assert.doesNotMatch(configFailure.stderr, /UNIQUE_SECRET_CONFIG/);
      assert.match(configFailure.stderr, /npm diagnostic summary \(child text withheld\)/);
      assert.match(configFailure.stderr, /stderr length\s+\d+ characters/);

      const extra = join(fixture, 'node_modules', 'yaml', 'unexpected-file');
      writeFileSync(extra, 'changed bytes');
      const changed = invoke(['--no-audit']);
      assert.equal(changed.status, 0, changed.stderr);
      assert.notEqual(JSON.parse(changed.stdout).currentObservation.installedTreeSha256,
        result.currentObservation.installedTreeSha256);
      rmSync(extra);
      symlinkSync('/etc/passwd', extra);
      refuse(invoke(['--no-audit']), 11);
      rmSync(extra);
      linkSync(packagePath, join(temporary, 'manifest-alias'));
      refuse(invoke(['--no-audit']), 15);
      rmSync(join(temporary, 'manifest-alias'));

      const unsafe = [fixture, '/'];
      const nonempty = mkdtempSync(join(temporary, 'nonempty-'));
      writeFileSync(join(nonempty, 'existing'), 'x');
      unsafe.push(nonempty, join(temporary, 'absent'));
      const linked = join(temporary, 'cache-link');
      symlinkSync(mkdtempSync(join(temporary, 'target-')), linked);
      unsafe.push(linked);
      const publicDirectory = join(temporary, 'public');
      mkdirSync(publicDirectory, { mode: 0o755 });
      unsafe.push(publicDirectory);
      for (const cache of unsafe) {
        const response = spawnSync(process.execPath, [join(fixture, 'Get-SupplyFreezeDigest.mjs'),
          '--json', '--any-toolchain', `--cache-directory=${cache}`], { encoding: 'utf8' });
        refuse(response, 16);
      }
      // A diagnostic alias must not turn the physical source repository into
      // an external cache, even when the measured checkout is elsewhere.
      const aliasWorkflow = join(temporary, 'alias', '.github', 'workflows');
      mkdirSync(aliasWorkflow, { recursive: true });
      symlinkSync(join(fixture, 'Get-SupplyFreezeDigest.mjs'), join(aliasWorkflow, 'Get-SupplyFreezeDigest.mjs'));
      const physicalCache = mkdtempSync(join(checkout, 'cache-'));
      const aliasRun = (cache) => spawnSync(process.execPath, ['--preserve-symlinks-main',
        join(aliasWorkflow, 'Get-SupplyFreezeDigest.mjs'), '--any-toolchain', '--no-audit', '--json',
        `--cache-directory=${cache}`], { encoding: 'utf8', maxBuffer: 16 * 1024 * 1024 });
      refuse(aliasRun(physicalCache), 16);
      assert.deepEqual(readdirSync(physicalCache), []);
      for (const name of ['package.json', 'package-lock.json', 'workflow-policy-contract.json', 'node_modules']) {
        cpSync(join(fixture, name), join(aliasWorkflow, name), { recursive: true, verbatimSymlinks: true });
      }
      const validAlias = aliasRun(mkdtempSync(join(temporary, 'alias-cache-')));
      assert.equal(validAlias.status, 0, validAlias.stderr);
      assert.equal(JSON.parse(validAlias.stdout).currentObservation.complete, false);
      refuse(invoke(['--secret=https://user:UNIQUE_SECRET@example.test']), 2);
      assert.doesNotMatch(invoke(['--secret=https://user:UNIQUE_SECRET@example.test']).stderr, /UNIQUE_SECRET/);
    } finally {
      // Every mutation is confined to this fresh, externally allocated fixture.
      rmSync(temporary, { recursive: true, force: true });
    }
  });
