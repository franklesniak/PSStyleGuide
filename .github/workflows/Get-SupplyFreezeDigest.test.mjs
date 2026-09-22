import assert from 'node:assert/strict';
import { createHash } from 'node:crypto';
import { spawnSync } from 'node:child_process';
import { chmodSync, cpSync, existsSync,
  linkSync, lstatSync, mkdirSync, mkdtempSync, readFileSync, readdirSync,
  readlinkSync, realpathSync, rmSync, symlinkSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { delimiter, dirname, isAbsolute, join, posix as pathPosix } from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
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
  const startupFrom = source.indexOf('function hasUnsupportedNodeStartupEnvironment(');
  const startupTo = source.indexOf('\n}\n', startupFrom) + 2;
  const from = source.indexOf('function npmChildEnv(');
  const to = source.indexOf('\n}\n', from) + 2;
  assert.ok(startupFrom >= 0 && startupTo > startupFrom && from >= 0 && to > from);
  const unsupportedStartup = new Function(
    `${source.slice(startupFrom, startupTo)}; return hasUnsupportedNodeStartupEnvironment;`)();
  assert.equal(unsupportedStartup({}), false);
  assert.equal(unsupportedStartup({ NODE_COMPILE_CACHE: '/disabled',
    NODE_DISABLE_COMPILE_CACHE: '1' }), false);
  assert.equal(unsupportedStartup({ NODE_DEBUG: 'child_process' }), true);
  assert.equal(unsupportedStartup({ NODE_DEBUG_NATIVE: 'HTTP' }), true);
  const project = new Function('dirname', 'delimiter', 'process',
    `${source.slice(from, to)}; return npmChildEnv;`)(dirname, delimiter, process);
  const input = { PATH: '/trusted', NODE_OPTIONS: '--trace-warnings', NODE_COMPILE_CACHE: '/forbidden',
    NODE_V8_COVERAGE: '/forbidden', NODE_REDIRECT_WARNINGS: '/forbidden',
    NODE_DEBUG: 'child_process', NODE_DEBUG_NATIVE: 'HTTP', NODE_DISABLE_COMPILE_CACHE: '0',
    npm_config_workspace: 'wrong', KEEP_THIS: 'yes' };
  const output = project(input);
  for (const key of ['NODE_OPTIONS', 'NODE_COMPILE_CACHE', 'NODE_V8_COVERAGE', 'NODE_REDIRECT_WARNINGS',
    'NODE_DEBUG', 'NODE_DEBUG_NATIVE', 'npm_config_workspace']) {
    assert.equal(Object.hasOwn(output, key), false);
  }
  assert.equal(output.NODE_DISABLE_COMPILE_CACHE, '1');
  assert.equal(output.KEEP_THIS, 'yes');
  assert.equal(Object.hasOwn(output, 'NODE_NO_WARNINGS'), false);
  assert.equal(input.NODE_DISABLE_COMPILE_CACHE, '0');
});

test('NPM-REGISTRY-TRANSPORT: the audit binds one checked environment value and withholds argv', () => {
  const environmentFrom = source.indexOf('function npmEnvironmentWithRegistry(');
  const operationFrom = source.indexOf('const NPM_OPERATION_LABELS', environmentFrom);
  const operationFunction = source.indexOf('function npmOperationLabel(', operationFrom);
  const operationTo = source.indexOf('\n}\n', operationFunction) + 2;
  assert.ok(environmentFrom >= 0 && operationFrom > environmentFrom
    && operationFunction > operationFrom && operationTo > operationFunction);
  const objSyntheticProcess = { env: {
    npm_config_registry: 'TASK130_F42_LOWERCASE_SECRET',
    NPM_CONFIG_REGISTRY: 'TASK130_F42_UPPERCASE_SECRET',
    NpM_CoNfIg_ReGiStRy: 'TASK130_F42_MIXED_SECRET',
    KEEP_PARENT: 'yes',
  } };
  const functions = new Function('process',
    `${source.slice(environmentFrom, operationTo)};
return { npmEnvironmentWithRegistry, npmOperationLabel };`)(objSyntheticProcess);
  const strRegistry = 'TASK130_F42_BEARER_SENTINEL';
  const objParentBound = functions.npmEnvironmentWithRegistry(undefined, strRegistry);
  assert.deepEqual(objParentBound, {
    KEEP_PARENT: 'yes', NPM_CONFIG_REGISTRY: strRegistry,
  });
  assert.equal(objSyntheticProcess.env.NPM_CONFIG_REGISTRY,
    'TASK130_F42_UPPERCASE_SECRET');
  const objStrictInput = { npm_config_registry: 'TASK130_F42_STRICT_SECRET',
    KeepStrict: 'yes' };
  assert.deepEqual(functions.npmEnvironmentWithRegistry(objStrictInput, strRegistry), {
    KeepStrict: 'yes', NPM_CONFIG_REGISTRY: strRegistry,
  });
  assert.equal(objStrictInput.npm_config_registry, 'TASK130_F42_STRICT_SECRET');
  assert.deepEqual([
    functions.npmOperationLabel(['--version']),
    functions.npmOperationLabel(['config', 'get', 'registry']),
    functions.npmOperationLabel(['ls', '--json']),
    functions.npmOperationLabel(['audit', '--json']),
    functions.npmOperationLabel(['TASK130_F42_UNKNOWN_OPERATION']),
  ], ['version query', 'configuration query', 'installed-tree query',
    'advisory audit', 'unclassified operation']);

  const auditFrom = source.indexOf('  const objAuditEnvironment = npmEnvironmentWithRegistry(');
  const auditTo = source.indexOf('\n  const objAudit = parseAuditOrRefuse(', auditFrom);
  assert.ok(auditFrom >= 0 && auditTo > auditFrom);
  const arrCalls = [];
  const buildAudit = new Function('boolAnyToolchain', 'strRegistry',
    'transportEnvironment', 'transportFlags', 'REVIEWED_NPM_TRANSPORT',
    'npmEnvironmentWithRegistry', 'runNpmAllowingFailure',
    `${source.slice(auditFrom, auditTo)};
return { strAuditResponse, objAuditEnvironment };`);
  const funcTransport = () => ({ npm_config_registry: 'TASK130_F42_FILE_OR_ENV_SECRET',
    KEEP_TRANSPORT: 'yes' });
  const funcFlags = () => ['--fetch-retries=0'];
  const funcRun = (arrArguments, objEnvironment) => {
    arrCalls.push({ arrArguments, objEnvironment });
    return report;
  };
  const objStrict = buildAudit(false, strRegistry, funcTransport, funcFlags,
    { 'fetch-retries': 0 }, functions.npmEnvironmentWithRegistry, funcRun);
  const objDiagnostic = buildAudit(true, strRegistry, funcTransport, funcFlags,
    { 'fetch-retries': 0 }, functions.npmEnvironmentWithRegistry, funcRun);
  assert.equal(objStrict.strAuditResponse, report);
  assert.equal(objDiagnostic.strAuditResponse, report);
  assert.equal(arrCalls.length, 2);
  for (const objCall of arrCalls) {
    assert.equal(objCall.arrArguments[0], 'audit');
    assert.equal(objCall.arrArguments.some((value) => value.startsWith('--registry=')), false);
    assert.equal(objCall.arrArguments.join(' ').includes(strRegistry), false);
    assert.equal(objCall.objEnvironment.NPM_CONFIG_REGISTRY, strRegistry);
    assert.equal(Object.keys(objCall.objEnvironment)
      .filter((strKey) => /^npm_config_registry$/iu.test(strKey)).length, 1);
  }
  assert.equal(arrCalls[0].objEnvironment.KEEP_TRANSPORT, 'yes');
  assert.equal(Object.hasOwn(arrCalls[0].objEnvironment, 'KEEP_PARENT'), false);
  assert.equal(arrCalls[0].arrArguments.includes('--fetch-retries=0'), true);
  assert.equal(arrCalls[1].objEnvironment.KEEP_PARENT, 'yes');
  assert.equal(Object.hasOwn(arrCalls[1].objEnvironment, 'KEEP_TRANSPORT'), false);
  assert.equal(arrCalls[1].arrArguments.includes('--fetch-retries=0'), false);

  const labelFrom = source.indexOf('const NPM_OPERATION_LABELS');
  const summaryFrom = source.indexOf('const NPM_DIAGNOSTIC_CATEGORIES', labelFrom);
  const summaryFunction = source.indexOf('function writeNpmDiagnosticSummary(', summaryFrom);
  const summaryTo = source.indexOf('\n}\n', summaryFunction) + 2;
  const runFrom = source.indexOf('function runNpm(');
  const wrapperTo = source.indexOf('\n}\n', source.indexOf('function runNpmOrRefuse(', runFrom)) + 2;
  let objScenario;
  let strDiagnostic = '';
  const objProcess = {
    execPath: '/reviewed/node',
    stderr: { write(value) { strDiagnostic += value; } },
    exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
  };
  const arrResults = [];
  const objWrappers = new Function('lstatSync', 'strNpmCli', 'intNpmCliInode', 'process',
    'spawnSync', 'npmChildEnv', 'join', 'strExternalCacheDirectory',
    'strWorkflowDirectory', 'decodeUtf8ExactlyOrRefuse', 'objNpmProcessResults',
    'Buffer', 'formatUntrustedText', 'REVIEWED_NPM',
    `${source.slice(labelFrom, summaryTo)}
${source.slice(runFrom, wrapperTo)}
return { runNpm, runNpmOrRefuse };`)(
    () => ({ ino: 41n }), '/reviewed/npm-cli.js', 41n, objProcess,
    () => objScenario, (value) => value ?? {}, join, '/private-cache', '/workflow',
    (value) => value.toString('utf8'), arrResults, Buffer, String, '11.16.0');
  const arrPrivateAudit = ['audit', '--json', `--registry=${strRegistry}`];
  objScenario = { stdout: null, stderr: Buffer.alloc(0), status: null, signal: null,
    error: { syscall: 'spawnSync fixture', code: 'ENOENT', message: strRegistry } };
  assert.throws(() => objWrappers.runNpm(arrPrivateAudit, {}, 5), { refusal: 2 });
  assert.match(strDiagnostic, /operation\s+advisory audit \(arguments withheld\)/);
  assert.doesNotMatch(strDiagnostic, /TASK130_F42|BEARER_SENTINEL|--registry/);
  strDiagnostic = '';
  objScenario = { stdout: Buffer.from('{}'), stderr: Buffer.alloc(0),
    status: 7, signal: null };
  assert.throws(() => objWrappers.runNpmOrRefuse(
    arrPrivateAudit, {}, 9, 'fixture refusal'), { refusal: 9 });
  assert.match(strDiagnostic, /operation\s+advisory audit \(arguments withheld\)/);
  assert.doesNotMatch(strDiagnostic, /TASK130_F42|BEARER_SENTINEL|--registry/);
});

test('NODE-DISTRIBUTION-RESOLUTION: every production observation maps native failure to exit 2', () => {
  const helperFrom = source.indexOf('function resolveNodeDistributionOrRefuse(');
  const helperTo = source.indexOf('\n}\n', helperFrom) + 2;
  const cacheFrom = source.indexOf('function validateCacheDirectory(');
  const cacheTo = source.indexOf('\n}\n', cacheFrom) + 2;
  const rootFrom = source.indexOf('function npmInstallationRootOrRefuse(');
  const rootTo = source.indexOf('\n}\n', rootFrom) + 2;
  const insideFrom = source.indexOf('const isInsideOrEqual = ');
  const insideTo = source.indexOf('\n\n', insideFrom);
  assert.ok(helperFrom >= 0 && helperTo > helperFrom && cacheFrom >= 0 && cacheTo > cacheFrom
    && rootFrom >= 0 && rootTo > rootFrom && insideFrom >= 0 && insideTo > insideFrom);
  const arrDiagnostic = [];
  const objProcess = {
    platform: 'linux', arch: 'x64', execPath: '/dist/bin/node', env: {},
    getuid: () => 1000,
    stderr: { write(value) { arrDiagnostic.push(value); } },
    exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
  };
  const formatLocation = (objError) =>
    `  error              ${objError?.code ?? 'unknown'} (filesystem location withheld)\n`;
  const resolveDistribution = new Function('process', 'formatErrorLocation',
    `${source.slice(helperFrom, helperTo)}; return resolveNodeDistributionOrRefuse;`)(
    objProcess, formatLocation);
  assert.equal(resolveDistribution(() => '/dist'), '/dist');
  const objSecretError = Object.assign(new Error('TASK130_F43_PRIVATE_STACK'), {
    code: 'ENOENT', path: '/TASK130_F43_PRIVATE_PATH',
  });
  const failDistribution = (strPath) => {
    if (strPath === '/dist' || strPath === '/dist/bin/node') throw objSecretError;
    return strPath;
  };
  const validateCache = new Function('process', 'arrCacheArguments', 'isAbsolute',
    'refuseCache', 'hasUnsupportedNodeStartupEnvironment', 'realpathSync', 'dirname',
    'strWorkflowDirectory', 'strScriptPath', 'resolveNodeDistributionOrRefuse',
    'lstatSync', 'readdirSync',
    `${source.slice(cacheFrom, cacheTo)}; return validateCacheDirectory;`)(
    objProcess, ['--cache-directory=/cache'], isAbsolute,
    () => { throw Object.assign(new Error('cache refusal'), { refusal: 16 }); },
    () => false, failDistribution, dirname, '/repo/.github/workflows',
    '/physical/.github/workflows/Get-SupplyFreezeDigest.mjs', resolveDistribution,
    () => { throw new Error('cache validation continued after distribution failure'); }, () => []);
  arrDiagnostic.length = 0;
  assert.throws(() => validateCache(), { refusal: 2 });
  assert.match(arrDiagnostic.join(''), /unreviewed toolchain/);
  assert.doesNotMatch(arrDiagnostic.join(''), /TASK130_F43|PRIVATE_PATH|PRIVATE_STACK/);

  const root = new Function('join', 'dirname', 'process', 'realpathSync',
    'formatErrorLocation', 'resolveNodeDistributionOrRefuse',
    `${source.slice(insideFrom, insideTo)}
${source.slice(rootFrom, rootTo)}; return npmInstallationRootOrRefuse;`)(
    join, dirname, objProcess, (strPath) => {
      if (strPath === '/dist/lib/node_modules/npm') return strPath;
      if (strPath === '/dist/bin/npm') return '/dist/lib/node_modules/npm/bin/npm-cli.js';
      return failDistribution(strPath);
    }, formatLocation, resolveDistribution);
  arrDiagnostic.length = 0;
  assert.throws(() => root(), { refusal: 2 });
  assert.match(arrDiagnostic.join(''), /unreviewed toolchain/);
  assert.doesNotMatch(arrDiagnostic.join(''), /TASK130_F43|PRIVATE_PATH|PRIVATE_STACK/);

  // The fold caller already had a general scan boundary. Before the selected
  // phase wrapper, a raw executable-resolution error therefore became safe but
  // misleading exit 10 rather than the native exit 1 seen at the npm-root call.
  const scanFrom = source.indexOf('function scanOrRefuse(');
  const scanTo = source.indexOf('\n}\n', scanFrom) + 2;
  assert.ok(scanFrom >= 0 && scanTo > scanFrom);
  const scan = new Function('process', 'formatErrorLocation',
    `${source.slice(scanFrom, scanTo)}; return scanOrRefuse;`)(objProcess, formatLocation);
  arrDiagnostic.length = 0;
  assert.throws(() => scan(() => { throw objSecretError; },
    'the npm installation fold'), { refusal: 10 });
  assert.match(arrDiagnostic.join(''), /recorded inputs changed while recording/);
  assert.doesNotMatch(arrDiagnostic.join(''), /TASK130_F43|PRIVATE_PATH|PRIVATE_STACK/);

  assert.equal((source.match(/resolveNodeDistributionOrRefuse\(/gu) ?? []).length, 4);
  assert.match(source,
    /resolveNodeDistributionOrRefuse\(\s*\(\) => realpathSync\(dirname\(dirname\(process\.execPath\)\)\)\)/u);
  assert.equal((source.match(
    /resolveNodeDistributionOrRefuse\(\s*\(\) => dirname\(dirname\(realpathSync\(process\.execPath\)\)\)\)/gu)
    ?? []).length, 2);
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

test('FILESYSTEM-DIAGNOSTIC-PRIVACY: errno locations expose only fixed roles', () => {
  const from = source.indexOf('function formatErrorLocation(');
  const to = source.indexOf('\n}\n', from) + 2;
  assert.ok(from >= 0 && to > from);
  const formatLocation = new Function(
    `${source.slice(from, to)}; return formatErrorLocation;`)();
  const strSecretPath = '/tmp/TASK130_F33_BEARER_SECRET/package.json';
  const strDiagnostic = formatLocation({ code: 'ENOENT', path: strSecretPath });
  assert.equal(strDiagnostic,
    '  error              ENOENT (filesystem location withheld)\n');
  assert.doesNotMatch(strDiagnostic, /TASK130_F33|BEARER_SECRET|package\.json/);

  const sweepStart = source.indexOf('if (objSweepDifference) {',
    source.indexOf('const objSweepDifference = '));
  const sweepEnd = source.indexOf('\n}\n', sweepStart) + 2;
  assert.ok(sweepStart >= 0 && sweepEnd > sweepStart);
  let strSweepDiagnostic = '';
  assert.throws(() => new Function('objSweepDifference', 'process', 'formatSweepReading',
    'objBaselineChange', 'objNewestChange', 'intRecordingStartedAt',
    source.slice(sweepStart, sweepEnd))({
    kind: 'changed during the run', label: '/tmp/TASK130_F33_SWEEP_SECRET', was: 1, now: 2,
  }, {
    stderr: { write(value) { strSweepDiagnostic += value; } },
    exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
  }, String, { entries: new Map([['private', 1]]) },
  { entries: new Map([['private', 2]]) }, 0), { refusal: 10 });
  assert.match(strSweepDiagnostic, /watched filesystem path\/name withheld/);
  assert.doesNotMatch(strSweepDiagnostic, /TASK130_F33|SWEEP_SECRET/);

  const foldStart = source.indexOf('function formatInstalledTreeFoldDrift(');
  const foldRefusalStart = source.indexOf('if (arrFoldDrift.length > 0) {', foldStart);
  const foldEnd = source.indexOf('\n}\n', foldRefusalStart) + 2;
  assert.ok(foldStart >= 0 && foldRefusalStart > foldStart && foldEnd > foldRefusalStart);
  const objFirstFold = {
    sha256: 'a'.repeat(64), files: 1, symlinks: 0, directories: 1,
    escapingLinks: [], unresolvedLinks: [],
  };
  const objSecondFold = {
    sha256: 'b'.repeat(64), files: 1, symlinks: 2, directories: 1,
    escapingLinks: [{ path: 'TASK130_F33_SECOND_FOLD_BEARER_SECRET' }],
    unresolvedLinks: [{ path: 'TASK130_F33_UNRESOLVED_SECRET', code: 'ENOENT' }],
  };
  // The actual refusal block is mode-independent. Execute it in both caller
  // mode fixtures so a future diagnostic-mode guard cannot waive privacy.
  for (const boolAnyToolchain of [false, true]) {
    let strFoldDiagnostic = '';
    assert.throws(() => new Function('objTree', 'objTreeAfter', 'process',
      'boolAnyToolchain', source.slice(foldStart, foldEnd))(
      objFirstFold, objSecondFold, {
        stderr: { write(value) { strFoldDiagnostic += value; } },
        exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
      }, boolAnyToolchain), { refusal: 10 });
    assert.match(strFoldDiagnostic,
      /content digest, symbolic-link count, escaping-link set, unresolved-link set/);
    assert.doesNotMatch(strFoldDiagnostic,
      /TASK130_F33|SECOND_FOLD_BEARER_SECRET|UNRESOLVED_SECRET|"path"/);
    assert.match(strFoldDiagnostic, /changed field values withheld/);
  }
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
  const from = source.indexOf('function nonOwnerWriteReason(');
  const functionStart = source.indexOf('function readViaVerifiedDescriptor(', from);
  const to = source.indexOf('\n}\n', functionStart) + 2;
  assert.ok(from >= 0 && functionStart > from && to > functionStart);
  const objRegular = {
    isFile: () => true, isSymbolicLink: () => false, isDirectory: () => false,
    isFIFO: () => false, isSocket: () => false, isCharacterDevice: () => false,
    isBlockDevice: () => false, nlink: 1, uid: 1000, mode: 0o644,
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
    { ...objRegular, mode: 0o664 },
  ]) {
    const objIntentional = fixture({ stats, closeError: new Error('close-secondary') });
    assert.throws(objIntentional.invoke, (error) => error.refusal === 15);
    assert.equal(objIntentional.closeCalls(), 1);
    assert.deepEqual(objIntentional.arrMissing, []);
  }
});

test('INITIAL-SELF-SNAPSHOT: resolution and descriptor failures use fixed exit 3', () => {
  const from = source.indexOf('function refuseInitialScriptRead(');
  const to = source.indexOf('\nconst strInvokedPath = ', from);
  assert.ok(from >= 0 && to > from);
  let objScenario;
  let strDiagnostic = '';
  const objProcess = {
    stderr: { write(value) { strDiagnostic += value; } },
    exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
  };
  const initialSnapshot = new Function('realpathSync', 'readViaVerifiedDescriptor',
    'process', 'formatErrorLocation', `${source.slice(from, to)}; return initialScriptSnapshotOrRefuse;`)(
    () => {
      if (objScenario.resolveError) throw objScenario.resolveError;
      return '/resolved/recorder.mjs';
    }, (strPath, intExit, fnOnMissing, objRefusal) => {
      assert.equal(strPath, '/resolved/recorder.mjs');
      assert.equal(intExit, 3);
      assert.deepEqual(objRefusal, { exit: 3, what: 'script', holdable: false });
      if (objScenario.readError) fnOnMissing(objScenario.readError);
      return Buffer.from('reviewed source');
    }, objProcess, (objError) =>
      `  error              ${objError?.code ?? 'unknown'} (filesystem location withheld)\n`);

  objScenario = {};
  assert.deepEqual(initialSnapshot('/invoked/recorder.mjs'), {
    path: '/resolved/recorder.mjs', bytes: Buffer.from('reviewed source'),
  });
  for (const strStage of ['resolve', 'read']) {
    strDiagnostic = '';
    objScenario = { [`${strStage}Error`]: Object.assign(new Error('TASK130_F37_PRIVATE_PATH'),
      { code: 'EIO', path: '/tmp/TASK130_F37_PRIVATE_PATH' }) };
    assert.throws(() => initialSnapshot('/tmp/TASK130_F37_PRIVATE_PATH'), { refusal: 3 });
    assert.match(strDiagnostic, /initial snapshot/);
    assert.match(strDiagnostic, /EIO \(filesystem location withheld\)/);
    assert.doesNotMatch(strDiagnostic, /TASK130_F37|PRIVATE_PATH|Error:| at /);
  }
});

test('INITIAL-SELF-SNAPSHOT: active module initializer refuses a post-load missing source', () => {
  const temporary = mkdtempSync(join(tmpdir(), 'p1-active-initial-snapshot-'));
  const recorder = join(temporary, 'TASK130_F37_PRIVATE_SOURCE.mjs');
  const loader = join(temporary, 'loader.mjs');
  const registration = join(temporary, 'register.mjs');
  try {
    cpSync(join(workflow, 'Get-SupplyFreezeDigest.mjs'), recorder);
    const strTarget = pathToFileURL(recorder).href;
    writeFileSync(loader, `import { unlinkSync } from 'node:fs';
import { fileURLToPath } from 'node:url';
const target = ${JSON.stringify(strTarget)};
export async function load(url, context, nextLoad) {
  const result = await nextLoad(url, context);
  if (url === target) unlinkSync(fileURLToPath(url));
  return result;
}
`);
    writeFileSync(registration, `import { register } from 'node:module';
register(${JSON.stringify(pathToFileURL(loader).href)}, import.meta.url);
`);
    const result = spawnSync(process.execPath, ['--import', pathToFileURL(registration).href,
      recorder], { encoding: 'utf8' });
    assert.equal(result.status, 3, result.stderr);
    assert.equal(result.stdout, '');
    assert.match(result.stderr, /initial snapshot/);
    assert.match(result.stderr, /ENOENT \(filesystem location withheld\)/);
    assert.doesNotMatch(result.stderr,
      /TASK130_F37|PRIVATE_SOURCE|p1-active-initial-snapshot|Error:| at /);
  } finally {
    rmSync(temporary, { recursive: true, force: true });
  }
});

test('INITIAL-SELF-SNAPSHOT: active module initializer refuses a post-load FIFO',
  { skip: process.platform !== 'linux' }, () => {
    const temporary = mkdtempSync(join(tmpdir(), 'p1-active-initial-fifo-'));
    const recorder = join(temporary, 'TASK130_F37_PRIVATE_FIFO.mjs');
    const loader = join(temporary, 'loader.mjs');
    const registration = join(temporary, 'register.mjs');
    try {
      cpSync(join(workflow, 'Get-SupplyFreezeDigest.mjs'), recorder);
      const strTarget = pathToFileURL(recorder).href;
      writeFileSync(loader, `import { unlinkSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
import { fileURLToPath } from 'node:url';
const target = ${JSON.stringify(strTarget)};
export async function load(url, context, nextLoad) {
  const result = await nextLoad(url, context);
  if (url === target) {
    const path = fileURLToPath(url);
    unlinkSync(path);
    const made = spawnSync('mkfifo', [path]);
    if (made.status !== 0) throw new Error('fixture could not create FIFO');
  }
  return result;
}
`);
      writeFileSync(registration, `import { register } from 'node:module';
register(${JSON.stringify(pathToFileURL(loader).href)}, import.meta.url);
`);
      const result = spawnSync(process.execPath, ['--import', pathToFileURL(registration).href,
        recorder], { encoding: 'utf8', timeout: 5000 });
      assert.equal(result.status, 3, result.stderr);
      assert.equal(result.stdout, '');
      assert.match(result.stderr, /input role\s+script; path\/name withheld; is a FIFO/);
      assert.doesNotMatch(result.stderr,
        /TASK130_F37|PRIVATE_FIFO|p1-active-initial-fifo|Error:| at /);
    } finally {
      rmSync(temporary, { recursive: true, force: true });
    }
  });

test('INPUT-DIRECTORY-CONTROL: internal ancestors apply owner, sticky, and direct-parent rules', () => {
  const from = source.indexOf('function refuseUncontrolledInputDirectory(');
  const to = source.indexOf('\nvalidateRecordedInputDirectoryChain();', from);
  assert.ok(from >= 0 && to > from);
  const strWorkflowDirectory = '/repo/.github/workflows';
  const makeStats = (uid = 1000n, mode = 0o755n, boolDirectory = true,
    boolSymlink = false) => ({ uid, mode, isDirectory: () => boolDirectory,
    isSymbolicLink: () => boolSymlink });
  const invoke = (objByPath) => {
    let strDiagnostic = '';
    const validate = new Function('lstatSync', 'process', 'dirname',
      'strWorkflowDirectory', 'formatErrorLocation',
      `${source.slice(from, to)}; return validateRecordedInputDirectoryChain;`)(
      (strPath) => {
        const value = objByPath[strPath];
        if (value instanceof Error) throw value;
        return value;
      }, {
        getuid: () => 1000,
        stderr: { write(value) { strDiagnostic += value; } },
        exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
      }, dirname, strWorkflowDirectory, (objError) =>
        `  error              ${objError?.code ?? 'unknown'} (filesystem location withheld)\n`);
    return { validate, diagnostic: () => strDiagnostic };
  };
  const accepted = {
    '/repo': makeStats(0n, 0o1777n),
    '/repo/.github': makeStats(1000n, 0o1777n),
    '/repo/.github/workflows': makeStats(1000n, 0o755n),
  };
  invoke(accepted).validate();
  for (const [strCase, objChanged] of [
    ['nonsticky ancestor', { '/repo': makeStats(1000n, 0o775n) }],
    ['writable direct parent', { '/repo/.github/workflows': makeStats(1000n, 0o1777n) }],
    ['foreign owner', { '/repo/.github': makeStats(2000n, 0o755n) }],
    ['symlink', { '/repo/.github': makeStats(1000n, 0o755n, true, true) }],
  ]) {
    const objFixture = invoke({ ...accepted, ...objChanged });
    assert.throws(objFixture.validate, { refusal: 15 }, strCase);
    assert.match(objFixture.diagnostic(), /path\/name withheld/);
    assert.doesNotMatch(objFixture.diagnostic(), /\/repo/);
  }
  const objErrorFixture = invoke({ ...accepted,
    '/repo/.github': Object.assign(new Error('TASK130_F38_PRIVATE_PATH'), { code: 'EIO' }) });
  assert.throws(objErrorFixture.validate, { refusal: 15 });
  assert.match(objErrorFixture.diagnostic(), /EIO \(filesystem location withheld\)/);
  assert.doesNotMatch(objErrorFixture.diagnostic(), /TASK130_F38|PRIVATE_PATH|\/repo/);
});

test('JSON-ROOT-GUARDS: production contract and strict config guards reject non-object roots', () => {
  const plainFrom = source.indexOf('function isPlainObject(');
  const plainTo = source.indexOf('\n}\n', plainFrom) + 2;
  const contractFrom = source.indexOf('if (!isPlainObject(objContract))');
  const contractTo = source.indexOf('\nif (!isPlainObject(objSupplyFreeze)', contractFrom);
  const installFrom = source.indexOf('if (!isPlainObject(objEffective))');
  const installTo = source.indexOf('\n  if (arrDrift.length > 0)', installFrom);
  const transportFrom = source.indexOf('if (!isPlainObject(objTransportEffective))');
  const transportTo = source.indexOf('\n    if (arrTransportDrift.length > 0)', transportFrom);
  assert.ok(plainFrom >= 0 && plainTo > plainFrom);
  assert.ok(contractFrom >= 0 && contractTo > contractFrom);
  assert.ok(installFrom >= 0 && installTo > installFrom);
  assert.ok(transportFrom >= 0 && transportTo > transportFrom);

  const contractGuard = new Function('objContract', 'process',
    `${source.slice(plainFrom, plainTo)}\n${source.slice(contractFrom, contractTo)}\n`
    + 'return objSupplyFreeze;');
  const configGuard = (from, to, name) => new Function(name, 'configDriftOrRefuse',
    'REVIEWED_NPM_CONFIG', 'REVIEWED_NPM_TRANSPORT', 'process',
    `${source.slice(plainFrom, plainTo)}\n${source.slice(from, to)}\n`
    + `return ${name === 'objEffective' ? 'arrDrift' : 'arrTransportDrift'};`);
  const installGuard = configGuard(installFrom, installTo, 'objEffective');
  const transportGuard = configGuard(transportFrom, transportTo, 'objTransportEffective');
  const objPrivateRoots = [
    null,
    ['TASK131_F31_PRIVATE_ARRAY'],
    'TASK131_F31_PRIVATE_STRING',
    17,
    false,
  ];
  const invoke = (guard, value, intExit, strCategory, boolConfig = false) => {
    let strDiagnostic = '';
    const objProcess = {
      stderr: { write(strValue) { strDiagnostic += strValue; } },
      exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
    };
    const configDriftOrRefuse = (_reviewed, effective) => {
      assert.equal(effective !== null && typeof effective === 'object'
        && !Array.isArray(effective), true,
      'the production guard must run before configDriftOrRefuse');
      return [];
    };
    assert.throws(() => boolConfig
      ? guard(value, configDriftOrRefuse, {}, {}, objProcess)
      : guard(value, objProcess), { refusal: intExit });
    assert.match(strDiagnostic, strCategory);
    assert.match(strDiagnostic, /expected\s+JSON object/);
    assert.match(strDiagnostic, /nothing is recorded/);
    assert.doesNotMatch(strDiagnostic,
      /TASK131_F31|PRIVATE_(?:ARRAY|STRING)|TypeError|Get-SupplyFreezeDigest|file:\/\/|\n\s+at\s/u);
  };
  for (const value of objPrivateRoots) {
    invoke(contractGuard, value, 17, /P1 contract root.*unexpected response schema/);
    invoke(installGuard, value, 6, /npm configuration.*unexpected response schema/, true);
    invoke(transportGuard, value, 6, /npm configuration.*unexpected response schema/, true);
  }

  const objContract = { supplyFreeze: { retained: true }, unrelated: 'allowed' };
  const objUnexpectedRefusal = {
    stderr: { write(value) { assert.fail(`valid object emitted a refusal: ${value}`); } },
    exit(code) { assert.fail(`valid object exited with ${code}`); },
  };
  assert.equal(contractGuard(objContract, objUnexpectedRefusal),
    objContract.supplyFreeze);
  const objEffective = { registry: 'reviewed', unrelated: 'allowed' };
  const configDriftOrRefuse = (_reviewed, effective) => {
    assert.equal(effective, objEffective);
    return ['valid-object-control'];
  };
  assert.deepEqual(installGuard(objEffective, configDriftOrRefuse, {}, {}, objUnexpectedRefusal),
    ['valid-object-control']);
  assert.deepEqual(transportGuard(objEffective, configDriftOrRefuse, {}, {}, objUnexpectedRefusal),
    ['valid-object-control']);
});

test('RECURSIVE-COMPARISON-REFUSAL: contract and strict config boundaries translate recursion failure', () => {
  const canonicalFrom = source.indexOf('function canonicalize(');
  const tupleFunction = source.indexOf('function supplyFreezeTupleDigestOrRefuse(', canonicalFrom);
  const tupleTo = source.indexOf('\n}\n', tupleFunction) + 2;
  const contractFrom = source.indexOf('const objSupplyFreeze = objContract.supplyFreeze;');
  const contractTo = source.indexOf('\n\n\n// Round 29', contractFrom);
  const configFrom = source.indexOf('function normalizeConfigValue(');
  const configFunction = source.indexOf('function configDriftOrRefuse(', configFrom);
  const configTo = source.indexOf('\n}\n', configFunction) + 2;
  const installFrom = source.indexOf('if (!isPlainObject(objEffective))');
  const installTo = source.indexOf('\n  if (arrDrift.length > 0)', installFrom);
  const transportFrom = source.indexOf('if (!isPlainObject(objTransportEffective))');
  const transportTo = source.indexOf('\n    if (arrTransportDrift.length > 0)', transportFrom);
  assert.ok(canonicalFrom >= 0 && tupleFunction > canonicalFrom && tupleTo > tupleFunction);
  assert.ok(contractFrom >= 0 && contractTo > contractFrom);
  assert.ok(configFrom >= 0 && configFunction > configFrom && configTo > configFunction);
  assert.ok(installFrom >= 0 && installTo > installFrom);
  assert.ok(transportFrom >= 0 && transportTo > transportFrom);

  const nested = (intDepth, objLeaf = 0) => {
    let objValue = objLeaf;
    for (let intAt = 0; intAt < intDepth; intAt++) objValue = [objValue];
    return objValue;
  };
  const nestedObject = (intDepth, objLeaf = 0) => {
    let objValue = objLeaf;
    for (let intAt = 0; intAt < intDepth; intAt++) objValue = { next: objValue };
    return objValue;
  };
  const objDeep = nested(10000, 'TASK131_F2_PRIVATE_RECURSIVE_VALUE');
  const objContract = JSON.parse(
    readFileSync(join(workflow, 'workflow-policy-contract.json'), 'utf8'));
  let strDiagnostic = '';
  const objProcess = {
    stderr: { write(strValue) { strDiagnostic += strValue; } },
    exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
  };
  const objTupleFunctions = new Function('sha256', 'process',
    `${source.slice(canonicalFrom, tupleTo)};
return { canonicalize, supplyFreezeTupleDigestOrRefuse };`)(sha, objProcess);
  const contractBoundary = new Function('objContract', 'isPlainObject',
    'supplyFreezeTupleDigestOrRefuse', 'sha256', 'canonicalize', 'process',
    `${source.slice(contractFrom, contractTo)};
return objSupplyFreeze;`);
  const isPlainObject = (value) => value !== null
    && typeof value === 'object' && !Array.isArray(value);

  assert.equal(objTupleFunctions.supplyFreezeTupleDigestOrRefuse(objContract.supplyFreeze),
    '83c5138131de742734d22a818e21feb63d5ac11f8877adf52299809f04217362');
  assert.doesNotThrow(() => objTupleFunctions.supplyFreezeTupleDigestOrRefuse({
    retained: nested(20), unrelated: 'allowed',
  }));
  assert.equal(contractBoundary({ ...objContract, unrelated: 'allowed' }, isPlainObject,
    objTupleFunctions.supplyFreezeTupleDigestOrRefuse, sha,
    objTupleFunctions.canonicalize, objProcess), objContract.supplyFreeze);
  strDiagnostic = '';
  assert.throws(() => contractBoundary({ supplyFreeze: { recursive: objDeep },
    unrelated: 'allowed' }, isPlainObject,
  objTupleFunctions.supplyFreezeTupleDigestOrRefuse, sha,
  objTupleFunctions.canonicalize, objProcess), { refusal: 17 });
  assert.match(strDiagnostic, /historical assertions could not be compared safely/);
  assert.match(strDiagnostic, /nothing is recorded/);
  assert.doesNotMatch(strDiagnostic,
    /TASK131_F2|PRIVATE_RECURSIVE_VALUE|RangeError|Maximum call stack|Get-SupplyFreezeDigest|file:\/\/|\n\s+at\s/u);
  strDiagnostic = '';
  assert.throws(() => objTupleFunctions.supplyFreezeTupleDigestOrRefuse(
    nestedObject(10000, 'TASK131_F2_PRIVATE_OBJECT_VALUE')), { refusal: 17 });
  assert.match(strDiagnostic, /historical assertions could not be compared safely/);
  assert.doesNotMatch(strDiagnostic,
    /TASK131_F2|PRIVATE_OBJECT_VALUE|RangeError|Maximum call stack|Get-SupplyFreezeDigest|file:\/\/|\n\s+at\s/u);

  const objConfigFunctions = new Function('canonicalize', 'process',
    `${source.slice(configFrom, configTo)};
return { configDrift, formatObservedConfig, configDriftOrRefuse };`)(
    objTupleFunctions.canonicalize, objProcess);
  const configBoundary = (from, to, name, reviewedName, resultName) =>
    new Function(name, 'isPlainObject', 'configDriftOrRefuse', 'configDrift',
      reviewedName, 'process',
      `${source.slice(from, to)};
return ${resultName};`);
  const installBoundary = configBoundary(installFrom, installTo, 'objEffective',
    'REVIEWED_NPM_CONFIG', 'arrDrift');
  const transportBoundary = configBoundary(transportFrom, transportTo,
    'objTransportEffective', 'REVIEWED_NPM_TRANSPORT', 'arrTransportDrift');

  const objUnexpectedRefusal = {
    stderr: { write(value) { assert.fail(`valid config emitted a refusal: ${value}`); } },
    exit(code) { assert.fail(`valid config exited with ${code}`); },
  };
  assert.deepEqual(installBoundary({ 'bin-links': true, unrelated: 'allowed' },
    isPlainObject, objConfigFunctions.configDriftOrRefuse, objConfigFunctions.configDrift,
    { 'bin-links': true }, objUnexpectedRefusal), []);
  assert.deepEqual(transportBoundary({ proxy: null, unrelated: 'allowed' },
    isPlainObject, objConfigFunctions.configDriftOrRefuse, objConfigFunctions.configDrift,
    { proxy: null }, objUnexpectedRefusal), []);

  // The getter returns a small drifting value to the comparison and the deep
  // value to the formatter. This exercises the actual recursive formatter,
  // not a synthetic exception substituted for configDrift.
  let intReads = 0;
  const objFormatterFailure = {};
  Object.defineProperty(objFormatterFailure, 'bin-links', {
    enumerable: true,
    get() {
      intReads += 1;
      return intReads === 1 ? 'different' : objDeep;
    },
  });
  strDiagnostic = '';
  assert.throws(() => installBoundary(objFormatterFailure, isPlainObject,
    objConfigFunctions.configDriftOrRefuse, objConfigFunctions.configDrift,
    { 'bin-links': true }, objProcess),
  { refusal: 6 });
  assert.equal(intReads, 2);
  assert.match(strDiagnostic, /npm configuration could not be compared safely/);
  assert.doesNotMatch(strDiagnostic,
    /TASK131_F2|PRIVATE_RECURSIVE_VALUE|RangeError|Maximum call stack|Get-SupplyFreezeDigest|file:\/\/|\n\s+at\s/u);

  strDiagnostic = '';
  assert.throws(() => transportBoundary({ proxy: objDeep }, isPlainObject,
    objConfigFunctions.configDriftOrRefuse, objConfigFunctions.configDrift,
    { proxy: null }, objProcess),
  { refusal: 6 });
  assert.match(strDiagnostic, /npm configuration could not be compared safely/);
  assert.match(strDiagnostic, /nothing is recorded/);
  assert.doesNotMatch(strDiagnostic,
    /TASK131_F2|PRIVATE_RECURSIVE_VALUE|RangeError|Maximum call stack|Get-SupplyFreezeDigest|file:\/\/|\n\s+at\s/u);
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

test('UTF8-INPUT: byte-lossy JSON sources refuse before parsing', () => {
  const from = source.indexOf('function decodeUtf8ExactlyOrRefuse(');
  const to = source.indexOf('\n}\n', from) + 2;
  assert.ok(from >= 0 && to > from);
  let diagnostic = '';
  const decode = new Function('Buffer', 'process',
    `${source.slice(from, to)}; return decodeUtf8ExactlyOrRefuse;`)(Buffer, {
    stderr: { write(value) { diagnostic += value; } },
    exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
  });
  const valid = Buffer.from('{"label":"雪"}', 'utf8');
  assert.equal(decode(valid, 'fixture JSON', 17), valid.toString('utf8'));
  const invalid = Buffer.from([0x7b, 0x22, 0x78, 0x22, 0x3a, 0x22, 0x80, 0x22, 0x7d]);
  assert.throws(() => decode(invalid, 'fixture JSON', 17), { refusal: 17 });
  assert.match(diagnostic, /not valid UTF-8/);
  assert.match(diagnostic, /byte length\s+9/);
  assert.doesNotMatch(diagnostic, /�|80/u);
});

test('NPM-STDOUT-UTF8: production npm adapter exact-decodes semantic stdout by phase', () => {
  const summaryFrom = source.indexOf('const NPM_OPERATION_LABELS');
  const summaryFunction = source.indexOf('function writeNpmDiagnosticSummary(', summaryFrom);
  const summaryTo = source.indexOf('\n}\n', summaryFunction) + 2;
  const decodeFrom = source.indexOf('function decodeUtf8ExactlyOrRefuse(');
  const decodeTo = source.indexOf('\n}\n', decodeFrom) + 2;
  const runFrom = source.indexOf('function runNpm(');
  const runTo = source.indexOf('\nfunction runNpmOrRefuse(', runFrom);
  assert.ok(summaryFrom >= 0 && summaryTo > summaryFunction
    && decodeFrom >= 0 && decodeTo > decodeFrom && runFrom >= 0 && runTo > runFrom);
  let objScenario;
  let strDiagnostic = '';
  const arrResults = [];
  const objProcess = {
    execPath: '/reviewed/node',
    stderr: { write(value) { strDiagnostic += value; } },
    exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
  };
  const runNpm = new Function('lstatSync', 'strNpmCli', 'intNpmCliInode', 'process',
    'spawnSync', 'npmChildEnv', 'join', 'strExternalCacheDirectory',
    'strWorkflowDirectory', 'decodeUtf8ExactlyOrRefuse', 'objNpmProcessResults',
    'Buffer', 'formatUntrustedText', 'REVIEWED_NPM',
    `${source.slice(summaryFrom, summaryTo)}\n${source.slice(runFrom, runTo)}\n; return runNpm;`)(
    () => ({ ino: 41n }), '/reviewed/npm-cli.js', 41n, objProcess,
    () => objScenario, (value) => value ?? {}, join, '/private-cache', '/workflow',
    new Function('Buffer', 'process',
      `${source.slice(decodeFrom, decodeTo)}; return decodeUtf8ExactlyOrRefuse;`)(Buffer, objProcess),
    arrResults, Buffer, String, '11.16.0');

  objScenario = { stdout: Buffer.from('{"label":"�"}', 'utf8'),
    stderr: Buffer.alloc(0), status: 0, signal: null };
  assert.equal(runNpm(['config'], {}, 6), '{"label":"�"}');
  objScenario = { stdout: Buffer.alloc(0), stderr: Buffer.alloc(0), status: 0, signal: null };
  assert.equal(runNpm(['config'], {}, 6), '');

  strDiagnostic = '';
  objScenario = { stdout: Buffer.from('{"registry":"reviewed"}'),
    stderr: Buffer.from([0x80]), status: 0, signal: null };
  assert.equal(runNpm(['config', 'get', 'registry'], {}, 9), '{"registry":"reviewed"}');
  assert.match(strDiagnostic, /stderr length\s+1 characters/);
  assert.match(strDiagnostic, /categories\s+other-output/);
  assert.doesNotMatch(strDiagnostic, /80/);

  for (const [arrArguments, intPhase, intInvalidByte] of [
    [['--version'], 2, 0x80], [['config', 'list', '--json'], 6, 0x81],
    [['config', 'get', 'registry'], 9, 0x80], [['ls'], 7, 0x81], [['audit'], 5, 0x80],
  ]) {
    strDiagnostic = '';
    objScenario = { stdout: Buffer.from(
      [0x7b, 0x22, 0x78, 0x22, 0x3a, 0x22, intInvalidByte, 0x22, 0x7d]),
    stderr: Buffer.alloc(0), status: 0, signal: null };
    assert.throws(() => runNpm(arrArguments, {}, intPhase), { refusal: intPhase });
    assert.match(strDiagnostic, new RegExp(`npm ${arrArguments[0]} stdout is not valid UTF-8`));
    assert.doesNotMatch(strDiagnostic, /�|80|81/u);
  }

  strDiagnostic = '';
  objScenario = { stdout: Buffer.from(report), stderr: Buffer.alloc(0), status: 1, signal: null };
  assert.equal(auditFunction(runNpm)(['audit']), report);

  objScenario = { stdout: Buffer.from('{"problems":[]}'), stderr: Buffer.alloc(0),
    status: null, signal: 'SIGTERM' };
  assert.throws(() => runNpm(['ls'], {}, 7), /nonzero status or signal/);
  assert.deepEqual(arrResults.at(-1),
    { operation: 'ls', nativeExit: null, signal: 'SIGTERM', stderrLength: 0 });

  const strPrivateStderr = 'npm warn TASK130_F34_PRIVATE_PARTIAL_STDERR\n';
  for (const [arrArguments, intPhase] of [
    [['--version'], 2], [['config', 'list', '--json'], 6],
    [['config', 'get', 'registry'], 9], [['ls', '--all', '--json'], 7],
    [['audit', '--json'], 5],
  ]) {
    strDiagnostic = '';
    objScenario = { stdout: Buffer.alloc(8192), stderr: Buffer.from(strPrivateStderr),
      status: null, signal: 'SIGTERM', pid: 41,
      error: { syscall: 'spawnSync fixture', code: 'ENOBUFS', message: 'fixture' } };
    assert.throws(() => runNpm(arrArguments, {}, intPhase), { refusal: intPhase });
    assert.match(strDiagnostic, /categories\s+warning/);
    assert.match(strDiagnostic,
      new RegExp(`stderr length\\s+${strPrivateStderr.length} characters`));
    assert.match(strDiagnostic, new RegExp(`npm ${arrArguments[0]} exceeded the bounded response size`));
    assert.match(strDiagnostic, /truncated response cannot be parsed/);
    assert.doesNotMatch(strDiagnostic, /TASK130_F34|PRIVATE_PARTIAL_STDERR|npm could not be run/);
  }

  for (const strCode of ['ENOENT', 'EACCES', 'E2BIG']) {
    strDiagnostic = '';
    objScenario = { stdout: null, stderr: Buffer.alloc(0), status: null, signal: null,
      error: { syscall: 'spawnSync fixture', code: strCode, message: 'fixture' } };
    assert.throws(() => runNpm(['config'], {}, 6), { refusal: 2 });
    assert.match(strDiagnostic, new RegExp(`npm could not be run: ${strCode}`));
  }

  strDiagnostic = '';
  objScenario = { stdout: null, stderr: null, status: 0, signal: null };
  assert.throws(() => runNpm(['audit'], {}, 5), { refusal: 5 });
  assert.match(strDiagnostic, /returned no stdout byte stream/);
});

test('CACHE-MOUNT-TOPOLOGY: visible backing coordinates reject protected aliases', () => {
  const from = source.indexOf('const MOUNTINFO_MAX_BYTES');
  const to = source.indexOf('\nfunction readMountInfoOrRefuse(', from);
  assert.ok(from >= 0 && to > from);
  const strTopologySource = source.slice(from, to);
  const objFunctions = new Function('pathPosix',
    `${strTopologySource}; return { parseMountInfo, cacheMountAliasesProtected };`)(pathPosix);
  const parse = (...arrLines) => objFunctions.parseMountInfo(`${arrLines.join('\n')}\n`);
  const strRoot = '1 1 8:1 / / rw - ext4 /dev/root rw';

  assert.equal(objFunctions.cacheMountAliasesProtected('/tmp/cache', ['/repo'],
    parse(strRoot)), false);
  assert.equal(objFunctions.cacheMountAliasesProtected('/cache', ['/repo'], parse(
    strRoot,
    '2 1 8:1 /repo/empty /cache rw - none /repo/empty rw')), true);
  assert.equal(objFunctions.cacheMountAliasesProtected('/cache-root/empty', ['/repo'], parse(
    strRoot,
    '2 1 8:1 /repo /cache-root rw - none /repo rw')), true);
  assert.equal(objFunctions.cacheMountAliasesProtected('/source/repo/empty', ['/repo'], parse(
    strRoot,
    '2 1 8:1 /source/repo /repo rw - none /source/repo rw')), true);
  assert.equal(objFunctions.cacheMountAliasesProtected('/source/repo/empty', ['/visible/repo'], parse(
    strRoot,
    '2 1 8:1 /source /visible rw - none /source rw')), true);
  assert.equal(objFunctions.cacheMountAliasesProtected('/cache', ['/repo'], parse(
    strRoot,
    '2 1 8:2 / /repo/vendor rw - ext4 /dev/other rw',
    '3 1 8:2 /private-cache /cache rw - none /private-cache rw')), true);
  assert.equal(objFunctions.cacheMountAliasesProtected('/cache', ['/repo'], parse(
    strRoot,
    '2 1 9:1 / /cache rw - tmpfs tmpfs rw')), false);

  assert.throws(() => objFunctions.cacheMountAliasesProtected('/cache', ['/repo'], parse(
    strRoot,
    '2 1 8:1 /first /cache rw - none /first rw',
    '3 2 8:1 /second /cache rw - none /second rw')), /stacked mount is ambiguous/);
  assert.throws(() => objFunctions.cacheMountAliasesProtected('/cache/sub', ['/repo'], parse(
    strRoot,
    '2 1 8:1 /hidden /cache/sub rw - none /hidden rw',
    '3 1 9:1 / /cache rw - tmpfs tmpfs rw')), /hidden mount is ambiguous/);

  const arrEscaped = parse(strRoot,
    '2 1 8:1 /repo\\040space /cache\\040space rw - none /repo\\040space rw');
  assert.equal(objFunctions.cacheMountAliasesProtected('/cache space', ['/repo space'],
    arrEscaped), true);
  assert.throws(() => parse('2 1 8:1 /bad\\777 /cache rw - none none rw'),
    /invalid mountinfo path escape/);
  assert.throws(() => parse('2 1 08:1 / / rw - ext4 /dev/root rw'),
    /invalid mountinfo fields/);
  assert.throws(() => parse('2 1 8:1 / / rw - '), /invalid mountinfo fields/);
  assert.throws(() => parse(
    '1 2 8:1 / / rw - ext4 /dev/root rw',
    '2 1 8:1 /nested /nested rw - none /nested rw'), /mountinfo parent cycle/);

  const strDescendantBlock = `    const objMountPoints = new Map();
    for (const objMount of arrMounts) {
      if (objMount.mountPoint !== strProtectedRoot
        && mountPathContains(strProtectedRoot, objMount.mountPoint)) {
        objMountPoints.set(objMount.mountPoint, true);
      }
    }
    for (const strMountPoint of objMountPoints.keys()) {
      arrProtected.push(mountCoordinateForPath(strMountPoint, arrMounts));
    }
`;
  const strWithoutDescendants = strTopologySource.replace(strDescendantBlock, '');
  assert.notEqual(strWithoutDescendants, strTopologySource);
  const objWithoutDescendants = new Function('pathPosix',
    `${strWithoutDescendants}; return { parseMountInfo, cacheMountAliasesProtected };`)(pathPosix);
  assert.equal(objWithoutDescendants.cacheMountAliasesProtected('/cache', ['/repo'], parse(
    strRoot,
    '2 1 8:2 / /repo/vendor rw - ext4 /dev/other rw',
    '3 1 8:2 /private-cache /cache rw - none /private-cache rw')), false);

  const strOverlapBlock = `  return arrProtected.some((objProtected) => objCache.device === objProtected.device
    && (mountPathContains(objCache.path, objProtected.path)
      || mountPathContains(objProtected.path, objCache.path)));
`;
  const strWithoutOverlap = strTopologySource.replace(strOverlapBlock, '  return false;\n');
  assert.notEqual(strWithoutOverlap, strTopologySource);
  const objWithoutOverlap = new Function('pathPosix',
    `${strWithoutOverlap}; return { parseMountInfo, cacheMountAliasesProtected };`)(pathPosix);
  assert.equal(objWithoutOverlap.cacheMountAliasesProtected('/cache', ['/repo'], parse(
    strRoot,
    '2 1 8:1 /repo/empty /cache rw - none /repo/empty rw')), false);
});

test('CACHE-MOUNTINFO-READ: production reader is bounded, exact, and closes once', () => {
  const refusalFrom = source.indexOf('function refuseCacheMountTopology(');
  const refusalTo = source.indexOf('\n}\n', refusalFrom) + 2;
  const from = source.indexOf('const MOUNTINFO_MAX_BYTES');
  const readerFrom = source.indexOf('function readMountInfoOrRefuse(', from);
  const to = source.indexOf('\n}\n', readerFrom) + 2;
  const decodeFrom = source.indexOf('function decodeUtf8ExactlyOrRefuse(');
  const decodeTo = source.indexOf('\n}\n', decodeFrom) + 2;
  assert.ok(refusalFrom >= 0 && refusalTo > refusalFrom && from >= 0
    && readerFrom > from && to > readerFrom && decodeFrom >= 0 && decodeTo > decodeFrom);
  const fixture = (openSyncFixture, readSyncFixture, closeSyncFixture) => {
    let strDiagnostic = '';
    const objProcess = {
      stderr: { write(value) { strDiagnostic += value; } },
      exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
    };
    const read = new Function('Buffer', 'pathPosix', 'openSync', 'readSync', 'closeSync',
      'fsConstants', 'process',
      `${source.slice(refusalFrom, refusalTo)}\n${source.slice(from, to)}\n`
      + `${source.slice(decodeFrom, decodeTo)}\nreturn readMountInfoOrRefuse;`)(
      Buffer, pathPosix, openSyncFixture, readSyncFixture, closeSyncFixture,
      { O_RDONLY: 0, O_NOFOLLOW: 0 }, objProcess);
    return { read, diagnostic: () => strDiagnostic };
  };

  const bufValid = Buffer.from('1 1 8:1 / / rw - ext4 /dev/root rw\n');
  let intOffset = 0;
  let intCloses = 0;
  const objValid = fixture(() => 41, (_fd, bufTarget, intAt, intLength) => {
    if (intOffset === bufValid.length) return 0;
    const intRead = Math.min(7, intLength, bufValid.length - intOffset);
    bufValid.copy(bufTarget, intAt, intOffset, intOffset + intRead);
    intOffset += intRead;
    return intRead;
  }, () => { intCloses += 1; });
  assert.equal(objValid.read(), bufValid.toString('utf8'));
  assert.equal(intCloses, 1);

  intCloses = 0;
  const objReadFailure = fixture(() => 42, () => { throw new Error('read failure'); },
    () => { intCloses += 1; });
  assert.throws(() => objReadFailure.read(), { refusal: 16 });
  assert.equal(intCloses, 1);

  intCloses = 0;
  const objCloseFailure = fixture(() => 43, () => 0, () => {
    intCloses += 1;
    throw new Error('close failure');
  });
  assert.throws(() => objCloseFailure.read(), { refusal: 16 });
  assert.equal(intCloses, 1);

  const objOpenFailure = fixture(() => { throw new Error('open failure'); }, () => 0,
    () => { throw new Error('unexpected close'); });
  assert.throws(() => objOpenFailure.read(), { refusal: 16 });

  intCloses = 0;
  let boolInvalidRead = false;
  const objInvalidUtf8 = fixture(() => 44, (_fd, bufTarget, intAt) => {
    if (boolInvalidRead) return 0;
    boolInvalidRead = true;
    bufTarget[intAt] = 0x80;
    return 1;
  }, () => { intCloses += 1; });
  assert.throws(() => objInvalidUtf8.read(), { refusal: 16 });
  assert.equal(intCloses, 1);
  assert.match(objInvalidUtf8.diagnostic(), /Linux mount topology is not valid UTF-8/);

  intCloses = 0;
  const objOverflow = fixture(() => 45, (_fd, _bufTarget, _intAt, intLength) => intLength,
    () => { intCloses += 1; });
  assert.throws(() => objOverflow.read(), { refusal: 16 });
  assert.equal(intCloses, 1);
});

test('AUDIT-LAUNCH-FAILURE: native spawn failure exits 2 before audit classification', () => {
  const summaryFrom = source.indexOf('const NPM_OPERATION_LABELS');
  const summaryFunction = source.indexOf('function writeNpmDiagnosticSummary(', summaryFrom);
  const summaryTo = source.indexOf('\n}\n', summaryFunction) + 2;
  const runFrom = source.indexOf('function runNpm(');
  const runTo = source.indexOf('\nfunction runNpmOrRefuse(', runFrom);
  assert.ok(summaryFrom >= 0 && summaryTo > summaryFunction && runFrom >= 0 && runTo > runFrom);
  const strRunner = `
import { spawnSync } from 'node:child_process';
import { join } from 'node:path';
const objProcess = { execPath: '/TASK139_F2_ABSENT_NODE', stderr: process.stderr,
  exit: process.exit.bind(process) };
const arrResults = [];
const runNpm = new Function('lstatSync', 'strNpmCli', 'intNpmCliInode', 'process',
  'spawnSync', 'npmChildEnv', 'join', 'strExternalCacheDirectory',
  'strWorkflowDirectory', 'decodeUtf8ExactlyOrRefuse', 'objNpmProcessResults',
  'Buffer', 'formatUntrustedText', 'REVIEWED_NPM',
  ${JSON.stringify(`${source.slice(summaryFrom, summaryTo)}\n${source.slice(runFrom, runTo)}\n; return runNpm;`) })(
  () => ({ ino: 41n }), '/reviewed/npm-cli.js', 41n, objProcess, spawnSync,
  () => ({}), join, '/private-cache', '/workflow',
  (value) => value.toString('utf8'), arrResults, Buffer, String, '11.16.0');
runNpm(['audit', '--json'], {}, 5);
`;
  const objResult = spawnSync(process.execPath, ['--input-type=module'], {
    input: strRunner, encoding: 'utf8', timeout: 5000,
  });
  assert.equal(objResult.status, 2, objResult.stderr);
  assert.equal(objResult.stdout, '');
  assert.match(objResult.stderr, /npm could not be run: ENOENT/);
  assert.match(objResult.stderr, /operation\s+advisory audit \(arguments withheld\)/);
  assert.doesNotMatch(objResult.stderr, /outside the accepted native 0\/1 outcomes|Error:| at /);
});

test('CACHE-MOUNT-GUARD-CALL: whole process refuses a forced alias before npm',
  { skip: process.platform !== 'linux' || process.arch !== 'x64' }, () => {
    const strCall = `    if (cacheMountAliasesProtected(strResolved,
      [strRepository, strPhysicalRepository, strDistribution], arrMounts)) {
      refuseCacheMountTopology();
    }
`;
    const strFunction = 'function cacheMountAliasesProtected(strCache, arrProtectedRoots, arrMounts) {\n';
    const strChildImport = "import { spawnSync } from 'node:child_process';";
    assert.equal(source.split(strCall).length - 1, 1);
    assert.equal(source.split(strFunction).length - 1, 1);
    assert.equal(source.split(strChildImport).length - 1, 1);
    const temporary = mkdtempSync(join(tmpdir(), 'cache-mount-call-'));
    const repository = join(temporary, 'repository');
    const workflow = join(repository, '.github', 'workflows');
    const marker = join(temporary, 'npm-started');
    mkdirSync(workflow, { recursive: true });
    const strInstrumented = source
      .replace(strFunction, `${strFunction}  if (process.env.TASK139_FORCE_CACHE_ALIAS === '1') return true;\n`)
      .replace(strChildImport, `import { spawnSync as spawnSyncNative } from 'node:child_process';
import { writeFileSync as writeTask139Marker } from 'node:fs';
const spawnSync = (...arrArguments) => {
  writeTask139Marker(process.env.TASK139_NPM_MARKER, 'started');
  return spawnSyncNative(...arrArguments);
};`);
    assert.notEqual(strInstrumented, source);
    const invoke = (strCandidate, arrFlags) => {
      const recorder = join(workflow, 'Get-SupplyFreezeDigest.mjs');
      writeFileSync(recorder, strCandidate);
      chmodSync(recorder, 0o644);
      const cache = mkdtempSync(join(temporary, 'cache-'));
      return { result: spawnSync(process.execPath, [recorder, '--json',
        `--cache-directory=${cache}`, ...arrFlags], {
        encoding: 'utf8', maxBuffer: 16 * 1024 * 1024,
        env: { ...process.env, TASK139_FORCE_CACHE_ALIAS: '1', TASK139_NPM_MARKER: marker },
      }), cache };
    };
    try {
      for (const arrFlags of [[], ['--any-toolchain', '--no-audit']]) {
        const objRun = invoke(strInstrumented, arrFlags);
        assert.equal(objRun.result.status, 16, objRun.result.stderr);
        assert.equal(objRun.result.stdout, '');
        assert.match(objRun.result.stderr, /mount topology.*aliases a protected surface/);
        assert.equal(existsSync(marker), false);
        assert.deepEqual(readdirSync(objRun.cache), []);
      }
      const strWithoutCall = strInstrumented.replace(strCall, '');
      assert.notEqual(strWithoutCall, strInstrumented);
      const objMutant = invoke(strWithoutCall, ['--any-toolchain', '--no-audit']);
      assert.notEqual(objMutant.result.status, 16,
        'removing the production guard call must defeat the exit-16 expectation');
      assert.equal(existsSync(marker), false);
    } finally {
      rmSync(temporary, { recursive: true, force: true });
    }
  });

test('NPM-RESPONSE-LIMIT: real child overflow uses the owning phase before a catch',
  { skip: process.platform !== 'linux' || process.arch !== 'x64' }, () => {
    const summaryFrom = source.indexOf('const NPM_DIAGNOSTIC_CATEGORIES');
    const summaryFunction = source.indexOf('function writeNpmDiagnosticSummary(', summaryFrom);
    const summaryTo = source.indexOf('\n}\n', summaryFunction) + 2;
    const runFrom = source.indexOf('function runNpm(');
    const runTo = source.indexOf('\nfunction runNpmOrRefuse(', runFrom);
    assert.ok(summaryFrom >= 0 && summaryTo > summaryFunction && runFrom >= 0 && runTo > runFrom);
    const temporary = mkdtempSync(join(tmpdir(), 'p1-response-limit-'));
    const npmCli = join(temporary, 'npm-cli.cjs');
    const runner = join(temporary, 'runner.mjs');
    try {
      writeFileSync(npmCli,
        `process.stdout.write(Buffer.alloc(65 * 1024 * 1024, 0x78));\n`);
      writeFileSync(runner, `import { spawnSync } from 'node:child_process';
import { lstatSync } from 'node:fs';
import { join } from 'node:path';
const strNpmCli = ${JSON.stringify(npmCli)};
const intNpmCliInode = lstatSync(strNpmCli, { bigint: true }).ino;
const strExternalCacheDirectory = ${JSON.stringify(temporary)};
const strWorkflowDirectory = ${JSON.stringify(temporary)};
const objNpmProcessResults = [];
const REVIEWED_NPM = '11.16.0';
const npmChildEnv = () => ({});
const decodeUtf8ExactlyOrRefuse = () => { throw new Error('truncated stdout reached decoder'); };
const formatUntrustedText = String;
${source.slice(summaryFrom, summaryTo)}
${source.slice(runFrom, runTo)}
try {
  runNpm(['ls', '--all', '--json'], {}, 7);
  process.exit(98);
} catch (error) {
  process.stderr.write('response-limit refusal was catchable: ' + error.message + '\\n');
  process.exit(99);
}
`);
      const result = spawnSync(process.execPath, [runner], {
        encoding: 'utf8', maxBuffer: 1024 * 1024, timeout: 15000,
      });
      assert.equal(result.status, 7, result.stderr);
      assert.equal(result.stdout, '');
      assert.match(result.stderr, /npm ls exceeded the bounded response size/);
      assert.match(result.stderr, /truncated response cannot be parsed/);
      assert.doesNotMatch(result.stderr, /catchable|truncated stdout reached decoder/);
    } finally {
      rmSync(temporary, { recursive: true, force: true });
    }
  });

test('AUDIT-PUBLIC-SUMMARY: response names affect the normalized digest but never display', () => {
  const severityFrom = source.indexOf('const SEVERITY_LEVELS');
  const severityTo = source.indexOf('\n// A Git blob identity', severityFrom);
  const canonicalFrom = source.indexOf('function canonicalize(');
  const canonicalTo = source.indexOf('\n}\n', canonicalFrom) + 2;
  const ghsaFrom = source.indexOf('const RE_GHSA_EXACT');
  const normalizeFrom = source.indexOf('function normalizeAudit(', ghsaFrom);
  const normalizeTo = source.indexOf('\n}\n', normalizeFrom) + 2;
  const displayFrom = source.indexOf('function auditPackageDisplaySummary(');
  const renderFrom = source.indexOf('function renderAuditPackageSummary(', displayFrom);
  const displayTo = source.indexOf('\n}\n', renderFrom) + 2;
  assert.ok(severityFrom >= 0 && severityTo > severityFrom
    && canonicalFrom >= 0 && canonicalTo > canonicalFrom
    && ghsaFrom >= 0 && normalizeTo > normalizeFrom
    && displayFrom >= 0 && displayTo > renderFrom);
  const functions = new Function('renderRecordRow',
    `${source.slice(severityFrom, severityTo)}
${source.slice(canonicalFrom, canonicalTo)}
${source.slice(ghsaFrom, normalizeTo)}
${source.slice(displayFrom, displayTo)}
return {normalizeAudit, canonicalize, auditPackageDisplaySummary, renderAuditPackageSummary};`)(
    (label, value) => `${label} ${value}\n`);
  const objAudit = {
    auditReportVersion: 2,
    metadata: { vulnerabilities: {
      info: 1, low: 0, moderate: 1, high: 1, critical: 0, total: 3,
    } },
    vulnerabilities: {
      TASK130_F16_DIRECT_SECRET: {
        severity: 'high', isDirect: false, range: '<1.0.0',
        via: [{ source: 12345, severity: 'high', range: '<1.0.0',
          cwe: [], cvss: { score: 7.5, vectorString: 'CVSS:3.1/TEST' } }],
      },
      TASK130_F16_VIA_KEY: {
        severity: 'moderate', isDirect: true, range: '<2.0.0',
        via: ['TASK130_F16_INHERITED_SECRET'],
      },
      TASK130_F16_UNCLASSIFIED_SECRET: {
        isDirect: false, range: '<3.0.0', via: ['TASK130_F16_UNKNOWN_VIA_SECRET'],
      },
    },
  };
  const objNormalized = functions.normalizeAudit(objAudit);
  const objNullUrl = structuredClone(objAudit);
  objNullUrl.vulnerabilities.TASK130_F16_DIRECT_SECRET.via[0].url = null;
  assert.deepEqual(functions.normalizeAudit(objNullUrl), objNormalized);
  const objGhsaUrl = structuredClone(objAudit);
  objGhsaUrl.vulnerabilities.TASK130_F16_DIRECT_SECRET.via[0].url =
    'https://github.com/advisories/GHSA-aaaa-bbbb-cccc';
  assert.match(JSON.stringify(functions.normalizeAudit(objGhsaUrl)),
    /"id":"GHSA-aaaa-bbbb-cccc"/u);
  for (const value of [7, false, [], { TASK130_F36_PRIVATE_URL_FIELD: true }]) {
    const objInvalidUrl = structuredClone(objAudit);
    objInvalidUrl.vulnerabilities.TASK130_F16_DIRECT_SECRET.via[0].url = value;
    assert.throws(() => functions.normalizeAudit(objInvalidUrl), /url of type/);
  }
  const refusalFrom = source.indexOf('const JSON_RESPONSE_REFUSALS');
  const refusalFunction = source.indexOf('function refuseJsonResponse(', refusalFrom);
  const refusalTo = source.indexOf('\n}\n', refusalFunction) + 2;
  const normalizeAdapterFrom = source.indexOf('function normalizeAuditOrRefuse(');
  const normalizeAdapterTo = source.indexOf('\n}\n', normalizeAdapterFrom) + 2;
  assert.ok(refusalFrom >= 0 && refusalTo > refusalFunction
    && normalizeAdapterFrom >= 0 && normalizeAdapterTo > normalizeAdapterFrom);
  let strUrlDiagnostic = '';
  const normalizeOrRefuse = new Function('process', 'Buffer', 'normalizeAudit',
    `${source.slice(refusalFrom, refusalTo)}\n${source.slice(normalizeAdapterFrom, normalizeAdapterTo)};`
      + ' return normalizeAuditOrRefuse;')({
    stderr: { write(value) { strUrlDiagnostic += value; } },
    exit(code) { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
  }, Buffer, functions.normalizeAudit);
  const objPrivateUrl = structuredClone(objAudit);
  objPrivateUrl.vulnerabilities.TASK130_F16_DIRECT_SECRET.via[0].url =
    { TASK130_F36_PRIVATE_URL_FIELD: 'BEARER_SECRET' };
  const strPrivateUrlBody = JSON.stringify(objPrivateUrl);
  assert.throws(() => normalizeOrRefuse(strPrivateUrlBody, objPrivateUrl), { refusal: 5 });
  assert.match(strUrlDiagnostic, /category\s+response normalization failed/);
  assert.doesNotMatch(strUrlDiagnostic, /TASK130_F36|BEARER_SECRET|PRIVATE_URL_FIELD/);
  const objSummary = functions.auditPackageDisplaySummary(objNormalized.packages);
  const strJsonPublic = JSON.stringify(objSummary);
  const strTextPublic = functions.renderAuditPackageSummary(objSummary);
  assert.doesNotMatch(`${strJsonPublic}\n${strTextPublic}`, /TASK130_F16|CVSS:3.1/i);
  assert.equal(objSummary.directAdvisory.high, 1);
  assert.equal(objSummary.inheritedOnly.moderate, 1);
  assert.equal(objSummary.directAdvisory.moderate, 0);
  assert.equal(objSummary.directAdvisory.unclassified, 0);
  assert.equal(objSummary.inheritedOnly.unclassified, 1);
  const objChanged = structuredClone(objAudit);
  objChanged.vulnerabilities.TASK130_F16_VIA_KEY.via =
    ['TASK130_F16_DIFFERENT_INHERITED_SECRET'];
  const strDigest = sha(functions.canonicalize(objNormalized));
  const strChangedDigest = sha(functions.canonicalize(functions.normalizeAudit(objChanged)));
  assert.notEqual(strDigest, strChangedDigest);
  const objRenamed = structuredClone(objAudit);
  objRenamed.vulnerabilities.TASK130_F16_RENAMED_SECRET =
    objRenamed.vulnerabilities.TASK130_F16_DIRECT_SECRET;
  delete objRenamed.vulnerabilities.TASK130_F16_DIRECT_SECRET;
  const strRenamedDigest = sha(functions.canonicalize(functions.normalizeAudit(objRenamed)));
  assert.notEqual(strDigest, strRenamedDigest);
});

test('TREE-CHECK-PRIVACY: production classifier emits only fixed categories and counts', () => {
  const from = source.indexOf('function treeCheckFailure(');
  const to = source.indexOf('\nlet strTreeCheckDetail', from);
  assert.ok(from >= 0 && to > from);
  const physical = new Map([
    ['/expected', '/physical/expected'],
    ['/reported', '/physical/expected'],
    ['/TASK130_F20_PRIVATE_PATH', '/physical/private'],
  ]);
  const functions = new Function('realpathSync',
    `${source.slice(from, to)}; return {validateNpmLsTree, describeTreeCheckFailure};`)(
    (path) => {
      if (path === '/TASK130_F20_THROW_SECRET') throw new Error('TASK130_F20_REALPATH_SECRET');
      return physical.get(path) ?? path;
    });
  const manifest = JSON.stringify({ dependencies: { expected: '1.0.0' } });
  assert.doesNotThrow(() => functions.validateNpmLsTree(
    { path: '/reported', dependencies: { expected: {} } }, '/expected', manifest));
  const describeValidation = (objLs, expected = '/expected', packageJson = manifest) => {
    try {
      functions.validateNpmLsTree(objLs, expected, packageJson);
      assert.fail('expected validation failure');
    } catch (error) {
      return functions.describeTreeCheckFailure(error);
    }
  };
  const arrDetails = [
    describeValidation({ dependencies: { TASK130_F20_NAME_SECRET: {} } }),
    describeValidation({ path: '/TASK130_F20_PRIVATE_PATH', dependencies: {} }),
    describeValidation({ path: '/reported',
      dependencies: { TASK130_F20_NAME_SECRET: {}, second: {} } }),
    describeValidation({ path: '/TASK130_F20_THROW_SECRET', dependencies: {} }),
    describeValidation({ path: '/reported', dependencies: { expected: {} } },
      '/expected', '{"TASK130_F20_MANIFEST_SECRET":'),
    functions.describeTreeCheckFailure({
      status: 1, stdout: 'TASK130_F20_NATIVE_STDOUT_SECRET',
    }),
    functions.describeTreeCheckFailure(new Error('TASK130_F20_UNEXPECTED_SECRET')),
  ];
  assert.deepEqual(arrDetails, [
    'missing path',
    'path mismatch',
    'dependency-set mismatch (declared 1, reported 2)',
    'path resolution failed',
    'manifest JSON invalid',
    'npm ls native-status failure (exit 1)',
    'tree validation failed',
  ]);
  assert.doesNotMatch(arrDetails.join('\n'), /TASK130_F20|PRIVATE|SECRET/);
});

test('LS-PROBLEM-PRIVACY: production summary emits only allowlisted kinds and counts', () => {
  const from = source.indexOf('const LS_PROBLEM_KINDS');
  const to = source.indexOf('\nfunction runNpmAllowingFailure(', from);
  assert.ok(from >= 0 && to > from);
  const functions = new Function(
    `${source.slice(from, to)}; return {summarizeLsProblems, formatLsProblemSummary,
      safeLsNativeStatus};`)();
  const arrProblems = [
    'missing: TASK130_F22_MISSING_SECRET /TASK130_F22_PRIVATE_PATH',
    'invalid: pkg@TASK130_F22_VERSION_SECRET /TASK130_F22_PRIVATE_PATH',
    'extraneous: TASK130_F22_EXTRA_SECRET',
    'privatekindsecret: TASK130_F22_LOWERCASE_UNKNOWN_SECRET',
    'TASK130_F22_UNKNOWN_KIND: TASK130_F22_UNKNOWN_SECRET',
    'malformed TASK130_F22_MALFORMED_SECRET',
    { TASK130_F22_OBJECT_SECRET: true },
    null,
  ];
  assert.deepEqual(functions.summarizeLsProblems(arrProblems), {
    total: 8, missing: 1, invalid: 1, extraneous: 1, other: 5,
  });
  const strSummary = functions.formatLsProblemSummary(arrProblems);
  assert.equal(strSummary,
    '  problem count      8\n'
    + '  problem categories missing 1, invalid 1, extraneous 1, other 5\n');
  assert.doesNotMatch(strSummary, /TASK130_F22|PRIVATE|SECRET|privatekindsecret/);
  assert.equal(functions.safeLsNativeStatus(7), '7');
  for (const value of ['7', 7.5, Number.MAX_SAFE_INTEGER + 1, null, undefined]) {
    assert.equal(functions.safeLsNativeStatus(value), 'unknown');
  }
});

function historicalMethodBlocks() {
  const strMethod = readFileSync(join(workflow, '..', '..', 'docs', 'P1-SUPPLY-FREEZE-v1.md'), 'utf8');
  const extract = (strHeading) => {
    const intStart = strMethod.indexOf(`### ${strHeading}\n`);
    assert.ok(intStart >= 0);
    const arrBlock = /```bash\n([\s\S]*?)\n```/u.exec(strMethod.slice(intStart));
    assert.notEqual(arrBlock, null);
    const arrPayload = /<<'NODE'\n([\s\S]*?)\nNODE$/u.exec(arrBlock[1]);
    assert.notEqual(arrPayload, null);
    return { shell: arrBlock[1], payload: arrPayload[1] };
  };
  const acquisition = extract('Acquire and verify');
  const offline = extract('Verify offline');
  assert.equal(acquisition.payload, offline.payload,
    'both authored recipes must retain the same complete verifier');
  return { acquisition, offline };
}

test('HISTORICAL-RECIPE-IDENTITY: paired and offline verifiers have identical payloads', () => {
  historicalMethodBlocks();
});

test('HISTORICAL-ACQUISITION: exact authored shell gates verification on native fetch success',
  { skip: process.platform !== 'linux' }, () => {
    const { acquisition, offline } = historicalMethodBlocks();
    const strCommit = '4346310e7deebffb4159c75e30d9546263dfd649';
    const arrBlobs = ['923106fc4ee5508b7a03930b3d8b774db9fcd009',
      '7e96fd1fd41765ba31488762f60c2f74ba17d3a8'];
    const strProject = join(workflow, '..', '..');
    const temporary = mkdtempSync(join(tmpdir(), 'p1-historical-acquisition-'));
    const objEnvironment = { ...process.env, NODE_DISABLE_COMPILE_CACHE: '1',
      GIT_NO_LAZY_FETCH: '1', GIT_NO_REPLACE_OBJECTS: '1', GIT_OPTIONAL_LOCKS: '0',
      GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: '/dev/null', GIT_CONFIG_SYSTEM: '/dev/null' };
    for (const strKey of Object.keys(objEnvironment)) {
      if (strKey.startsWith('GIT_') && !['GIT_NO_LAZY_FETCH', 'GIT_NO_REPLACE_OBJECTS',
        'GIT_OPTIONAL_LOCKS', 'GIT_CONFIG_NOSYSTEM', 'GIT_CONFIG_GLOBAL', 'GIT_CONFIG_SYSTEM'].includes(strKey)) {
        delete objEnvironment[strKey];
      }
    }
    for (const strKey of ['NODE_OPTIONS', 'NODE_COMPILE_CACHE', 'NODE_V8_COVERAGE',
      'NODE_REDIRECT_WARNINGS', 'NODE_DEBUG', 'NODE_DEBUG_NATIVE']) delete objEnvironment[strKey];
    const objGitPath = spawnSync('sh', ['-c', 'command -v git'], { encoding: 'utf8', env: objEnvironment });
    assert.equal(objGitPath.status, 0, objGitPath.stderr);
    const strGit = objGitPath.stdout.trim();
    const git = (cwd, args, input) => spawnSync(strGit, args, {
      cwd, input, env: objEnvironment, maxBuffer: 128 * 1024 * 1024,
    });
    const requireSuccess = (objResult) => {
      assert.equal(objResult.status, 0, objResult.stderr.toString());
      assert.equal(objResult.signal, null);
      return objResult.stdout;
    };
    try {
      const bufComplete = requireSuccess(git(strProject, ['pack-objects', '--revs', '--stdout'], `${strCommit}\n`));
      const bufTreeIds = requireSuccess(git(strProject,
        ['rev-list', '--objects', '--filter=blob:none', '--no-object-names', strCommit]));
      const bufTrees = requireSuccess(git(strProject, ['pack-objects', '--stdout'], bufTreeIds));
      const strPack = join(temporary, 'complete.pack');
      writeFileSync(strPack, bufComplete);
      const objContract = JSON.parse(readFileSync(join(workflow, 'workflow-policy-contract.json')));
      const run = (strName, strInitial, intFetchStatus, strShell, boolBadHash = false) => {
        const strRepository = join(temporary, strName);
        const strBin = join(temporary, `${strName}-bin`);
        const strLog = join(temporary, `${strName}-calls.jsonl`);
        mkdirSync(strRepository);
        mkdirSync(strBin);
        requireSuccess(git(strRepository, ['init', '-q']));
        if (strInitial !== 'absent') {
          requireSuccess(git(strRepository, ['index-pack', '--stdin'], strInitial === 'complete' ? bufComplete : bufTrees));
          requireSuccess(git(strRepository, ['cat-file', '-e', `${strCommit}^{commit}`]));
        } else assert.notEqual(git(strRepository, ['cat-file', '-e', `${strCommit}^{commit}`]).status, 0);
        for (const strBlob of arrBlobs) {
          assert.equal(git(strRepository, ['cat-file', '-e', strBlob]).status === 0, strInitial === 'complete');
        }
        const strContractDirectory = join(strRepository, '.github', 'workflows');
        mkdirSync(strContractDirectory, { recursive: true });
        const objCandidate = structuredClone(objContract);
        if (boolBadHash) objCandidate.supplyFreeze.baseline.packageLockJson.sha256 = '0'.repeat(64);
        writeFileSync(join(strContractDirectory, 'workflow-policy-contract.json'), JSON.stringify(objCandidate));
        // A transport fixture supplies real pinned objects without network. Every
        // verifier Git child still executes the real Git binary with its closed env.
        const strShim = join(strBin, 'git');
        writeFileSync(strShim, `#!${process.execPath}
import assert from 'node:assert/strict';
import { appendFileSync, readFileSync } from 'node:fs';
import { spawnSync } from 'node:child_process';
const args = process.argv.slice(2);
appendFileSync(${JSON.stringify(strLog)}, JSON.stringify(args) + '\\n');
if (args[0] === 'fetch') {
  assert.deepEqual(args, ['fetch', '--no-tags', '--refetch',
    'https://github.com/franklesniak/PSStyleGuide.git', ${JSON.stringify(strCommit)}]);
  if (${intFetchStatus} !== 0) process.exit(${intFetchStatus});
  const result = spawnSync(${JSON.stringify(strGit)}, ['index-pack', '--stdin'],
    { input: readFileSync(${JSON.stringify(strPack)}), env: process.env });
  process.exit(result.status ?? 74);
}
assert.equal(process.env.GIT_NO_LAZY_FETCH, '1');
assert.equal(process.env.GIT_NO_REPLACE_OBJECTS, '1');
assert.equal(process.env.GIT_OPTIONAL_LOCKS, '0');
assert.equal(process.env.GIT_CONFIG_NOSYSTEM, '1');
const result = spawnSync(${JSON.stringify(strGit)}, args, { stdio: 'inherit', env: process.env });
process.exit(result.status ?? 74);
`);
        chmodSync(strShim, 0o755);
        const objResult = spawnSync('bash', ['--noprofile', '--norc', '-c', strShell], {
          cwd: strRepository, encoding: 'utf8',
          env: { ...objEnvironment, strNode: process.execPath, PATH: `${strBin}${delimiter}${process.env.PATH}` },
          timeout: 30000, maxBuffer: 1024 * 1024,
        });
        assert.equal(objResult.signal, null);
        assert.equal(objResult.error, undefined);
        const calls = existsSync(strLog) ? readFileSync(strLog, 'utf8').trim().split('\n').map(JSON.parse) : [];
        return { result: objResult, calls, repository: strRepository };
      };
      const strSuccess = 'Historical packageJson and packageLockJson blob, path, length, and SHA-256 verification completed.\n';
      for (const strInitial of ['absent', 'trees', 'complete']) {
        const objRun = run(`acquire-${strInitial}`, strInitial, 0, acquisition.shell);
        assert.equal(objRun.result.status, 0, objRun.result.stderr);
        assert.equal(objRun.result.stdout, strSuccess);
        assert.equal(objRun.calls.filter((args) => args[0] === 'fetch').length, 1);
        assert.equal(objRun.calls.length, 6);
        for (const strBlob of arrBlobs) requireSuccess(git(objRun.repository, ['cat-file', '-e', strBlob]));
      }
      for (const strInitial of ['absent', 'trees', 'complete']) {
        const objRun = run(`fetch-fails-${strInitial}`, strInitial, 73, acquisition.shell);
        assert.equal(objRun.result.status, 73, objRun.result.stderr);
        assert.equal(objRun.result.stdout, '');
        assert.equal(objRun.calls.length, 1, 'failed fetch must not start verification');
      }
      const objLateFailure = run('late-verification-fails', 'absent', 0, acquisition.shell, true);
      assert.notEqual(objLateFailure.result.status, 0);
      assert.equal(objLateFailure.result.stdout, '');
      assert.equal(objLateFailure.calls.length, 6);
      const objOffline = run('offline-complete', 'complete', 73, offline.shell);
      assert.equal(objOffline.result.status, 0, objOffline.result.stderr);
      assert.equal(objOffline.result.stdout, strSuccess);
      assert.equal(objOffline.calls.length, 5);
      assert.equal(objOffline.calls.some((args) => args[0] === 'fetch'), false);
      for (const strInitial of ['absent', 'trees']) {
        const objRun = run(`offline-${strInitial}`, strInitial, 73, offline.shell);
        assert.notEqual(objRun.result.status, 0);
        assert.equal(objRun.result.stdout, '');
        assert.equal(objRun.calls.some((args) => args[0] === 'fetch'), false);
      }
      const strMutant = acquisition.shell.replace(' && \\\n', ';\n');
      assert.notEqual(strMutant, acquisition.shell);
      const objMutant = run('ungated-mutant', 'complete', 73, strMutant);
      assert.equal(objMutant.result.status, 0, objMutant.result.stderr);
      assert.equal(objMutant.result.stdout, strSuccess);
      assert.ok(objMutant.calls.length > 1,
        'removing the connector must defeat the failed-acquisition expectation');
    } finally {
      rmSync(temporary, { recursive: true, force: true });
    }
  });

test('HISTORICAL-VERIFICATION: authored JavaScript block reports success only after both blobs pass',
  { skip: process.platform !== 'linux' }, () => {
    const strVerifier = historicalMethodBlocks().offline.payload;
    const strExpectedSuccess =
      'Historical packageJson and packageLockJson blob, path, length, and SHA-256 verification completed.\n';
    const strProjectRoot = join(workflow, '..', '..');
    const temporary = mkdtempSync(join(tmpdir(), 'historical-verification-'));
    const strFixtureRepository = join(temporary, 'repository');
    const objSetupEnvironment = { ...process.env, GIT_NO_LAZY_FETCH: '1',
      GIT_NO_REPLACE_OBJECTS: '1', GIT_OPTIONAL_LOCKS: '0', GIT_CONFIG_NOSYSTEM: '1',
      GIT_CONFIG_GLOBAL: '/dev/null', GIT_CONFIG_SYSTEM: '/dev/null', GIT_TRACE: '0',
      GIT_TRACE2: '0', GIT_TRACE2_EVENT: '0', GIT_TRACE2_PERF: '0' };
    delete objSetupEnvironment.GIT_DIR;
    delete objSetupEnvironment.GIT_WORK_TREE;
    delete objSetupEnvironment.GIT_OBJECT_DIRECTORY;
    delete objSetupEnvironment.GIT_ALTERNATE_OBJECT_DIRECTORIES;
    mkdirSync(strFixtureRepository);
    const objInit = spawnSync('git', ['init', '-q'], {
      cwd: strFixtureRepository, encoding: 'utf8', env: objSetupEnvironment,
    });
    assert.equal(objInit.status, 0, objInit.stderr);
    const objHistoricalPack = spawnSync('git', ['pack-objects', '--revs', '--stdout'], {
      cwd: strProjectRoot, input: '4346310e7deebffb4159c75e30d9546263dfd649\n',
      encoding: null, env: objSetupEnvironment, maxBuffer: 128 * 1024 * 1024,
    });
    assert.equal(objHistoricalPack.status, 0, objHistoricalPack.stderr.toString());
    const objIndexPack = spawnSync('git', ['index-pack', '--stdin'], {
      cwd: strFixtureRepository, input: objHistoricalPack.stdout,
      encoding: 'utf8', env: objSetupEnvironment,
    });
    assert.equal(objIndexPack.status, 0, objIndexPack.stderr);
    const objHistoricalObject = spawnSync('git', ['cat-file', '-e',
      '4346310e7deebffb4159c75e30d9546263dfd649^{commit}'], {
      cwd: strFixtureRepository, encoding: 'utf8', env: objSetupEnvironment,
    });
    assert.equal(objHistoricalObject.status, 0, objHistoricalObject.stderr);
    const strContractDirectory = join(strFixtureRepository, '.github', 'workflows');
    const strContractPath = join(strContractDirectory, 'workflow-policy-contract.json');
    const objContract = JSON.parse(readFileSync(join(workflow, 'workflow-policy-contract.json')));
    mkdirSync(strContractDirectory, { recursive: true });
    const invokeVerifier = (objCandidate, objExtraEnv = {}, arrDeletedEnvironment = []) => {
      writeFileSync(strContractPath, JSON.stringify(objCandidate));
      const objEnvironment = {
        ...process.env,
        NODE_DISABLE_COMPILE_CACHE: '1',
        ...objExtraEnv,
      };
      delete objEnvironment.GIT_DIR;
      delete objEnvironment.GIT_WORK_TREE;
      for (const strKey of ['NODE_OPTIONS', 'NODE_COMPILE_CACHE', 'NODE_V8_COVERAGE',
        'NODE_REDIRECT_WARNINGS', 'NODE_DEBUG', 'NODE_DEBUG_NATIVE']) {
        delete objEnvironment[strKey];
      }
      for (const strKey of arrDeletedEnvironment) delete objEnvironment[strKey];
      return spawnSync(process.execPath, ['--input-type=module'], {
        cwd: strFixtureRepository,
        input: strVerifier,
        encoding: 'utf8',
        env: objEnvironment,
      });
    };
    try {
      const objSuccess = invokeVerifier(objContract);
      assert.equal(objSuccess.status, 0, objSuccess.stderr);
      assert.equal(objSuccess.stdout, strExpectedSuccess);

      const strClassicTrace = join(temporary, 'classic-trace-TASK130_F27_PRIVATE');
      const strNormalTrace = join(temporary, 'normal-trace-TASK130_F27_PRIVATE');
      const strEventTrace = join(temporary, 'event-trace-TASK130_F27_PRIVATE');
      const strPerfTrace = join(temporary, 'perf-trace-TASK130_F27_PRIVATE');
      const strGlobalConfig = join(temporary, 'global-TASK130_F27_PRIVATE.config');
      writeFileSync(strGlobalConfig,
        `[trace2]\n\tnormalTarget = ${strNormalTrace}\n\teventTarget = ${strEventTrace}\n`
        + `\tperfTarget = ${strPerfTrace}\n`);
      const objTraceIsolated = invokeVerifier(objContract, {
        GIT_TRACE: strClassicTrace,
        GIT_TRACE2: strNormalTrace,
        GIT_TRACE2_EVENT: strEventTrace,
        GIT_TRACE2_PERF: strPerfTrace,
      });
      assert.equal(objTraceIsolated.status, 0, objTraceIsolated.stderr);
      assert.equal(objTraceIsolated.stdout, strExpectedSuccess);
      for (const strTraceTarget of [strClassicTrace, strNormalTrace, strEventTrace, strPerfTrace]) {
        assert.equal(existsSync(strTraceTarget), false);
      }

      const objConfigIsolated = invokeVerifier(objContract, {
        GIT_CONFIG_GLOBAL: strGlobalConfig, GIT_CONFIG_SYSTEM: strGlobalConfig,
      }, ['GIT_TRACE', 'GIT_TRACE2', 'GIT_TRACE2_EVENT', 'GIT_TRACE2_PERF']);
      assert.equal(objConfigIsolated.status, 0, objConfigIsolated.stderr);
      assert.equal(objConfigIsolated.stdout, strExpectedSuccess);
      for (const strTraceTarget of [strNormalTrace, strEventTrace, strPerfTrace]) {
        assert.equal(existsSync(strTraceTarget), false);
      }

      const objObjectIsolated = invokeVerifier(objContract, {
        GIT_OBJECT_DIRECTORY: join(temporary, 'TASK130_F27_PRIVATE_OBJECTS'),
        GIT_ALTERNATE_OBJECT_DIRECTORIES: join(temporary, 'TASK130_F27_PRIVATE_ALTERNATES'),
      });
      assert.equal(objObjectIsolated.status, 0, objObjectIsolated.stderr);
      assert.equal(objObjectIsolated.stdout, strExpectedSuccess);

      const objLengthMismatch = structuredClone(objContract);
      objLengthMismatch.supplyFreeze.baseline.packageLockJson.length += 1;
      const objLengthFailure = invokeVerifier(objLengthMismatch);
      assert.notEqual(objLengthFailure.status, 0);
      assert.equal(objLengthFailure.stdout, '');

      const objHashMismatch = structuredClone(objContract);
      objHashMismatch.supplyFreeze.baseline.packageLockJson.sha256 = '0'.repeat(64);
      const objHashFailure = invokeVerifier(objHashMismatch);
      assert.notEqual(objHashFailure.status, 0);
      assert.equal(objHashFailure.stdout, '');

      const objBlobMismatch = structuredClone(objContract);
      objBlobMismatch.supplyFreeze.baseline.packageLockJson.blob = '0'.repeat(40);
      const objBlobFailure = invokeVerifier(objBlobMismatch);
      assert.notEqual(objBlobFailure.status, 0);
      assert.equal(objBlobFailure.stdout, '');

      const objGitPath = spawnSync('sh', ['-c', 'command -v git'], { encoding: 'utf8' });
      assert.equal(objGitPath.status, 0, objGitPath.stderr);
      const strWrapperDirectory = join(temporary, 'native-failure-bin');
      const strWrapperPath = join(strWrapperDirectory, 'git');
      const strCountPath = join(temporary, 'git-call-count');
      mkdirSync(strWrapperDirectory);
      writeFileSync(strWrapperPath, `#!/usr/bin/env node
const fs = require('node:fs');
const { spawnSync } = require('node:child_process');
const countPath = ${JSON.stringify(strCountPath)};
const count = fs.existsSync(countPath) ? Number(fs.readFileSync(countPath, 'utf8')) + 1 : 1;
fs.writeFileSync(countPath, String(count));
if (count === 4) {
  process.stderr.write('TASK130_F24_INJECTED_NATIVE_STATUS_73\\n');
  process.exit(73);
}
const result = spawnSync(${JSON.stringify(objGitPath.stdout.trim())}, process.argv.slice(2),
  { stdio: 'inherit', env: process.env });
process.exit(result.status ?? 74);
`);
      chmodSync(strWrapperPath, 0o755);
      const objNativeFailure = invokeVerifier(objContract, {
        PATH: `${strWrapperDirectory}${delimiter}${process.env.PATH}`,
      });
      assert.notEqual(objNativeFailure.status, 0);
      assert.equal(objNativeFailure.stdout, '');
      assert.equal(readFileSync(strCountPath, 'utf8'), '4');
      assert.match(objNativeFailure.stderr, /TASK130_F24_INJECTED_NATIVE_STATUS_73/);

      for (const [strCase, intCall, strAction] of [
        ['wrong-path-blob', 4, "process.stdout.write('0'.repeat(40) + '\\n'); process.exit(0);"],
        ['final-native-read', 5, 'process.exit(73);'],
      ]) {
        const strCaseDirectory = join(temporary, strCase);
        const strCaseCounter = join(temporary, `${strCase}-count`);
        mkdirSync(strCaseDirectory);
        const strCaseWrapper = join(strCaseDirectory, 'git');
        writeFileSync(strCaseWrapper, `#!${process.execPath}
const fs = require('node:fs');
const { spawnSync } = require('node:child_process');
const counter = ${JSON.stringify(strCaseCounter)};
const count = fs.existsSync(counter) ? Number(fs.readFileSync(counter, 'utf8')) + 1 : 1;
fs.writeFileSync(counter, String(count));
if (count === ${intCall}) { ${strAction} }
const result = spawnSync(${JSON.stringify(objGitPath.stdout.trim())}, process.argv.slice(2),
  { stdio: 'inherit', env: process.env });
process.exit(result.status ?? 74);
`);
        chmodSync(strCaseWrapper, 0o755);
        const objFailure = invokeVerifier(objContract, {
          PATH: `${strCaseDirectory}${delimiter}${process.env.PATH}`,
        });
        assert.notEqual(objFailure.status, 0, strCase);
        assert.equal(objFailure.stdout, '');
        assert.equal(readFileSync(strCaseCounter, 'utf8'), String(intCall));
      }
    } finally {
      rmSync(temporary, { recursive: true, force: true });
    }
  });

test('INSTALLED-TREE-SPECIAL: both folds apply the fixed special-entry refusal', () => {
  const from = source.indexOf('function refuseInstalledTreeSpecials(');
  const to = source.indexOf('\n}\n', from) + 2;
  assert.ok(from >= 0 && to > from);
  const diagnostic = [];
  const refuseSpecials = new Function('process',
    `${source.slice(from, to)}; return refuseInstalledTreeSpecials;`)({
    stderr: { write: (value) => diagnostic.push(value) },
    exit: (code) => { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
  });
  assert.doesNotThrow(() => refuseSpecials({ specials: 0, specialPaths: [] }));
  assert.throws(() => refuseSpecials({ specials: 1,
    specialPaths: ['TASK130_F26_PRIVATE_FIFO'] }), { refusal: 11 });
  assert.match(diagnostic.join(''), /special entries\s+1 \(expected 0\)/);
  assert.doesNotMatch(diagnostic.join(''), /TASK130_F26_PRIVATE_FIFO/);
  assert.deepEqual(source.match(/refuseInstalledTreeSpecials\(objTree(?:After)?\);/gu),
    ['refuseInstalledTreeSpecials(objTree);', 'refuseInstalledTreeSpecials(objTreeAfter);']);
});

test('NPM-VERSION-PRIVACY: raw npm labels never enter public toolchain sinks', () => {
  const from = source.indexOf('function unicodeCodePointLength(');
  const describeFrom = source.indexOf('function describeNpmVersion(', from);
  const to = source.indexOf('\n}\n', describeFrom) + 2;
  assert.ok(from >= 0 && describeFrom > from && to > describeFrom);
  const functions = new Function(
    `${source.slice(from, to)}; return { unicodeCodePointLength, describeNpmVersion };`)();
  assert.equal(functions.describeNpmVersion('11.16.0'), '11.16.0');
  const strDecorated = functions.describeNpmVersion(
    '11.16.0-TASK130-F28-PRIVATE-PRERELEASE.1+TASK130-F28-PRIVATE-BUILD');
  assert.equal(strDecorated, '11.16.0 (prerelease and build metadata withheld)');
  assert.doesNotMatch(strDecorated, /TASK130-F28|PRIVATE/);
  assert.equal(functions.describeNpmVersion('11.16.0+TASK130-F28-PRIVATE-BUILD'),
    '11.16.0 (build metadata withheld)');
  const strMalformed = functions.describeNpmVersion('TASK130_F28_PRIVATE_雪');
  assert.equal(strMalformed,
    'unrecognized npm version output (21 Unicode code points; value withheld)');
  assert.doesNotMatch(strMalformed, /TASK130_F28|PRIVATE|雪/u);
  const recordFrom = source.indexOf('npm: strNpmVersion');
  const recordTo = source.indexOf('\n', recordFrom);
  assert.ok(recordFrom >= 0 && recordTo > recordFrom);
  const strRecordedVersion = new Function('strNpmVersionPublic', 'strNpmVersionRaw',
    `return ({ ${source.slice(recordFrom, recordTo)} }).npm;`)(
    strDecorated, '11.16.0-TASK130-F28-PRIVATE-PRERELEASE.1+TASK130-F28-PRIVATE-BUILD');
  assert.equal(strRecordedVersion, strDecorated);
  assert.doesNotMatch(strRecordedVersion, /TASK130-F28|PRIVATE/);
  const guardFrom = source.indexOf('if (!boolAnyToolchain && (strNodeVersion !== REVIEWED_NODE');
  const guardTo = source.indexOf('\n}\n', guardFrom) + 2;
  assert.ok(guardFrom >= 0 && guardTo > guardFrom);
  const arrDiagnostic = [];
  const strRawSecret = 'TASK130_F28_PRIVATE_RAW_VERSION';
  const strPublicSecret = functions.describeNpmVersion(strRawSecret);
  assert.throws(() => new Function('boolAnyToolchain', 'strNodeVersion', 'REVIEWED_NODE',
    'strNpmVersionRaw', 'REVIEWED_NPM', 'REVIEWED_PLATFORM', 'REVIEWED_ARCH',
    'process', 'strNpmVersionPublic',
    'formatUntrustedText', source.slice(guardFrom, guardTo))(
    false, 'v24.18.1', 'v24.18.1', strRawSecret, '11.16.0', 'linux', 'x64', {
      platform: 'linux', arch: 'x64', stderr: { write: (value) => arrDiagnostic.push(value) },
      exit: (code) => { throw Object.assign(new Error(`refusal:${code}`), { refusal: code }); },
    }, strPublicSecret, String), { refusal: 2 });
  assert.match(arrDiagnostic.join(''), /unrecognized npm version output \(31 Unicode code points; value withheld\)/);
  assert.doesNotMatch(arrDiagnostic.join(''), /TASK130_F28|PRIVATE_RAW_VERSION/);
});

test('URL-PRIVACY: only the exact reviewed registry retains an authority', () => {
  const registryFrom = source.indexOf("const REVIEWED_REGISTRY = '");
  const registryTo = source.indexOf('\n', registryFrom);
  const lengthFrom = source.indexOf('function unicodeCodePointLength(');
  const lengthTo = source.indexOf('\n}\n', lengthFrom) + 2;
  const redactFrom = source.indexOf('function redactUrl(');
  const redactTo = source.indexOf('\n}\n', redactFrom) + 2;
  assert.ok(registryFrom >= 0 && registryTo > registryFrom
    && registryFrom < source.indexOf('const strInvokedPath = ')
    && lengthFrom >= 0 && lengthTo > lengthFrom && redactFrom >= 0 && redactTo > redactFrom);
  const reviewed = 'https://registry.npmjs.org/';
  const redact = new Function(
    `${source.slice(registryFrom, registryTo)}
${source.slice(lengthFrom, lengthTo)}
${source.slice(redactFrom, redactTo)}
return redactUrl;`)();
  assert.equal(redact(reviewed), reviewed);
  for (const [strRaw, strExpected] of [
    ['https://TASK130_F29_PRIVATE_HOST:8443/TASK130_F29_PRIVATE_PATH?token=PRIVATE',
      'https://(authority and URL details withheld)'],
    ['http://TASK130_F29_PRIVATE_HOST/', 'http://(authority and URL details withheld)'],
    ['git+ssh://TASK130_F29_PRIVATE_PROTOCOL/path', 'URL authority and details withheld'],
  ]) {
    const strSafe = redact(strRaw);
    assert.equal(strSafe, strExpected);
    assert.doesNotMatch(strSafe, /TASK130_F29|PRIVATE|8443|git\+ssh/u);
  }
  assert.equal(redact('TASK130_F29_PRIVATE_雪'),
    'unparseable, 21 Unicode code points (value not shown)');

  const regexFrom = source.indexOf('const RE_PARSER_DELETES = ');
  const regexTo = source.indexOf('\n\n', regexFrom);
  const objRegex = new Function(
    `${source.slice(regexFrom, regexTo)}; return { RE_PARSER_DELETES, RE_URL_IN_TEXT, RE_LINE_BREAK };`)();
  const treeFrom = source.indexOf('function formatTreeName(');
  const treeTo = source.indexOf('\n}\n', treeFrom) + 2;
  const formatFrom = source.indexOf('function formatUntrustedText(');
  const formatTo = source.indexOf('\n}\n', formatFrom) + 2;
  const format = new Function('RE_PARSER_DELETES', 'RE_URL_IN_TEXT', 'RE_LINE_BREAK',
    'redactUrl', `${source.slice(treeFrom, treeTo)}\n${source.slice(formatFrom, formatTo)}\nreturn formatUntrustedText;`)(
    objRegex.RE_PARSER_DELETES, objRegex.RE_URL_IN_TEXT, objRegex.RE_LINE_BREAK, redact);
  const strGeneral = format('prefix https://TASK130_F29_PRIVATE_GENERAL:9443/path?token=PRIVATE');
  assert.equal(strGeneral, 'prefix https://(authority and URL details withheld)');
  assert.doesNotMatch(strGeneral, /TASK130_F29|PRIVATE_GENERAL|9443|token=/u);

  const assignmentFrom = source.indexOf('objRecord.registry = redactUrl(strRegistry);');
  const assignmentTo = source.indexOf('\n', assignmentFrom);
  const objRecord = {};
  const strRegistry = 'git+ssh://TASK130_F29_PRIVATE_JSON/path';
  new Function('objRecord', 'redactUrl', 'strRegistry',
    source.slice(assignmentFrom, assignmentTo))(objRecord, redact, strRegistry);
  assert.equal(JSON.stringify(objRecord), '{"registry":"URL authority and details withheld"}');
  const renderFrom = source.indexOf('function renderRecordRow(');
  const renderTo = source.indexOf('\n}\n', renderFrom) + 2;
  const render = new Function('formatUntrustedText',
    `${source.slice(renderFrom, renderTo)}; return renderRecordRow;`)(format);
  assert.equal(render('registry', objRecord.registry),
    '  registry             URL authority and details withheld\n');
  assert.doesNotMatch(render('registry', objRecord.registry), /TASK130_F29|PRIVATE_JSON|git\+ssh/);
});

test('NPM-LINK-CONTAINMENT: production resolver rejects every uncovered resolution shape',
  { skip: process.platform !== 'linux' }, () => {
    const metadataFrom = source.indexOf('function nonOwnerWriteReason(');
    const metadataTo = source.indexOf('\n}\n', metadataFrom) + 2;
    const from = source.indexOf('const isInsideOrEqual = ');
    const to = source.indexOf('\nfunction foldNpmInstallation(', from);
    assert.ok(metadataFrom >= 0 && metadataTo > metadataFrom && from >= 0 && to > from);
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
    let boolDistributionFailure = false;
    const realpathForFixture = (strPath) => {
      if (boolDistributionFailure && strPath === process.execPath) {
        throw Object.assign(new Error('TASK130_F43_PRIVATE_STACK'), {
          code: 'ENOENT', path: '/TASK130_F43_PRIVATE_DISTRIBUTION',
        });
      }
      return realpathSync(strPath);
    };
    const resolveFrom = source.indexOf('function resolveNodeDistributionOrRefuse(');
    const resolveTo = source.indexOf('\n}\n', resolveFrom) + 2;
    assert.ok(resolveFrom >= 0 && resolveTo > resolveFrom);
    const resolveDistribution = new Function('process', 'formatErrorLocation',
      `${source.slice(resolveFrom, resolveTo)}; return resolveNodeDistributionOrRefuse;`)(
      testProcess, (error) =>
        `  error              ${error?.code ?? 'unknown'} (filesystem location withheld)\n`);
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
      'statIdentity', 'sha256', 'resolveNodeDistributionOrRefuse',
      `${source.slice(metadataFrom, metadataTo)}
${source.slice(from, foldTo)}; return foldNpmInstallation;`)(
      createHash, dirname, isAbsolute, join, lstatSync, readlinkSync, realpathForFixture,
      readdirSync, readFileSync, testProcess, String,
      (error) => `  error              ${error?.code ?? 'unknown'}\n`,
      hashFieldForFixture, (stats) => `${stats.ino}:${stats.ctimeNs}`, sha,
      resolveDistribution);

    const temporary = mkdtempSync(join(tmpdir(), 'npm-link-containment-'));
    const root = join(temporary, 'npm');
    const outside = join(temporary, 'outside');
    mkdirSync(root);
    mkdirSync(outside);
    writeFileSync(join(root, 'target'), 'inside');
    writeFileSync(join(outside, 'target'), 'outside');
    chmodSync(root, 0o755);
    chmodSync(outside, 0o755);
    chmodSync(join(root, 'target'), 0o644);
      chmodSync(join(outside, 'target'), 0o644);
    try {
      boolDistributionFailure = true;
      diagnostic.length = 0;
      assert.throws(() => foldNpm(realpathSync(root)), { refusal: 2 });
      assert.match(diagnostic.join(''), /unreviewed toolchain/);
      assert.doesNotMatch(diagnostic.join(''), /TASK130_F43|PRIVATE_DISTRIBUTION|PRIVATE_STACK/);
      boolDistributionFailure = false;

      symlinkSync('target', join(root, 'contained-b'));
      symlinkSync('contained-b', join(root, 'contained-a'));
      assert.deepEqual(classify(root, join(root, 'contained-a'), 'contained-a'),
        { status: 'contained' });
      assert.equal(foldNpm(realpathSync(root)).symlinks, 2);

      const nestedDirectory = join(root, 'TASK130_F33_PRIVATE_NPM_DIRECTORY');
      mkdirSync(nestedDirectory);
      chmodSync(nestedDirectory, 0o755);
      assert.equal(foldNpm(realpathSync(root)).symlinks, 2);
      chmodSync(nestedDirectory, 0o775);
      diagnostic.length = 0;
      assert.throws(() => foldNpm(realpathSync(root)), { refusal: 2 });
      assert.doesNotMatch(diagnostic.join(''), /TASK130_F33|PRIVATE_NPM_DIRECTORY/);
      chmodSync(nestedDirectory, 0o755);

      chmodSync(root, 0o775);
      assert.throws(() => foldNpm(realpathSync(root)), { refusal: 2 });
      chmodSync(root, 0o755);
      chmodSync(join(root, 'target'), 0o664);
      assert.throws(() => foldNpm(realpathSync(root)), { refusal: 2 });
      chmodSync(join(root, 'target'), 0o644);
      assert.equal(foldNpm(realpathSync(root)).symlinks, 2);

      const special = join(root, 'TASK130_F23_PRIVATE_FIFO');
      const makeFifo = spawnSync('mkfifo', [special], { encoding: 'utf8' });
      assert.equal(makeFifo.status, 0, makeFifo.stderr);
      diagnostic.length = 0;
      assert.throws(() => foldNpm(realpathSync(root)), { refusal: 2 });
      assert.match(diagnostic.join(''), /npm installation containing a special entry/);
      assert.match(diagnostic.join(''), /observed type\s+FIFO/);
      assert.doesNotMatch(diagnostic.join(''), /TASK130_F23|PRIVATE_FIFO/);
      rmSync(special);
      diagnostic.length = 0;
      assert.equal(foldNpm(realpathSync(root)).symlinks, 2);

      symlinkSync(join(outside, 'target'), join(root, 'direct-escape'));
      assert.deepEqual(classify(root, join(root, 'direct-escape'), 'direct-escape'),
        { status: 'escaping' });
      diagnostic.length = 0;
      assert.throws(() => foldNpm(realpathSync(root)), { refusal: 2 });
      assert.doesNotMatch(diagnostic.join(''), new RegExp(outside.replace(/[.*+?^${}()|[\]\\]/g, '\\$&')));
      assert.doesNotMatch(diagnostic.join(''), /direct-escape/);
      rmSync(join(root, 'direct-escape'));

      symlinkSync(join(root, 'target'), join(outside, 'return-hop'));
      symlinkSync(join(outside, 'return-hop'), join(root, 'escape-return'));
      assert.deepEqual(classify(root, join(root, 'escape-return'), 'escape-return'),
        { status: 'escaping' });
      diagnostic.length = 0;
      assert.throws(() => foldNpm(realpathSync(root)), { refusal: 2 });
      assert.doesNotMatch(diagnostic.join(''), /escape-return/);
      rmSync(join(root, 'escape-return'));

      symlinkSync('missing', join(root, 'dangling'));
      assert.deepEqual(classify(root, join(root, 'dangling'), 'dangling'),
        { status: 'unresolved', code: 'ENOENT' });
      diagnostic.length = 0;
      assert.throws(() => foldNpm(realpathSync(root)), { refusal: 2 });
      assert.match(diagnostic.join(''), /resolution\s+could not be established \(ENOENT\)/);
      assert.doesNotMatch(diagnostic.join(''), /dangling/);
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
    const checkout = join(temporary, 'TASK131_F31_PRIVATE_PATH');
    const fixture = join(checkout, '.github', 'workflows');
    mkdirSync(fixture, { recursive: true });
    for (const name of ['Get-SupplyFreezeDigest.mjs', 'package.json', 'package-lock.json', 'workflow-policy-contract.json']) {
      cpSync(join(workflow, name), join(fixture, name));
      chmodSync(join(fixture, name), 0o644);
    }
    cpSync(join(workflow, 'node_modules'), join(fixture, 'node_modules'), { recursive: true, verbatimSymlinks: true });
    const contract = JSON.parse(readFileSync(join(fixture, 'workflow-policy-contract.json')));
    const invokeFrom = (strFixture, flags = [], env = {}, objBaseEnvironment = process.env,
      intTimeout = undefined) => {
      const cache = mkdtempSync(join(temporary, 'cache-'));
      return spawnSync(process.execPath, [join(strFixture, 'Get-SupplyFreezeDigest.mjs'),
        '--json', `--cache-directory=${cache}`, ...flags], {
        encoding: 'utf8', maxBuffer: 16 * 1024 * 1024,
        env: { ...objBaseEnvironment, ...env }, timeout: intTimeout,
      });
    };
    const invoke = (flags = [], env = {}, objBaseEnvironment = process.env,
      intTimeout = undefined) => invokeFrom(fixture, flags, env, objBaseEnvironment, intTimeout);
    // A removed startup guard would enable child-process debug output before the
    // assertion runs. Use a fixed minimal environment so that failure output can
    // contain only the fake sentinel and synthetic fixture paths, never host secrets.
    const objBoundedDebugEnvironment = {
      PATH: `${dirname(process.execPath)}${delimiter}/usr/bin${delimiter}/bin`,
      HOME: temporary,
      TMPDIR: temporary,
      LANG: 'C.UTF-8',
      NODE_DISABLE_COMPILE_CACHE: '1',
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
      assert.deepEqual(Object.keys(result.currentObservation.auditPackages),
        ['directAdvisory', 'inheritedOnly']);
      for (const objCause of Object.values(result.currentObservation.auditPackages)) {
        assert.deepEqual(Object.keys(objCause),
          ['info', 'low', 'moderate', 'high', 'critical', 'unclassified']);
        assert.ok(Object.values(objCause).every(Number.isSafeInteger));
      }
      assert.ok(result.currentObservation.npmProcesses.every((item) => item.signal === null
        && (item.nativeExit === 0 || (item.operation === 'audit' && item.nativeExit === 1))));
      assert.deepEqual(fingerprint(checkout), before);
      assert.equal(existsSync(join(checkout, 'forbidden-cache')), false);
      assert.equal(existsSync(join(checkout, 'forbidden-logs')), false);

      // Exercise the real module and its surrounding scanOrRefuse call with a
      // bounded test-only failure at the THIRD executable-resolution observation.
      // The first npm-root observation passes; the later fold observation exits 2
      // from the shared phase boundary before scanOrRefuse can translate it to 10.
      const strF43Checkout = join(temporary, 'f43-probe-checkout');
      cpSync(checkout, strF43Checkout, { recursive: true, verbatimSymlinks: true });
      const strF43Fixture = join(strF43Checkout, '.github', 'workflows');
      const strF43Recorder = join(strF43Fixture, 'Get-SupplyFreezeDigest.f43-probe.mjs');
      const strImport = "  readdirSync, readFileSync, readlinkSync, readSync, realpathSync, statSync } from 'node:fs';";
      const strInstrumentedImport = "  readdirSync, readFileSync, readlinkSync, readSync, realpathSync as realpathSyncNative, statSync } from 'node:fs';";
      const strUrlImport = "import { fileURLToPath } from 'node:url';\n";
      const strF43Source = source.replace(strImport, strInstrumentedImport).replace(strUrlImport,
        `${strUrlImport}let intTask130F43Observations = 0;
const realpathSync = (strPath, ...arrArguments) => {
  if (strPath === process.execPath && (intTask130F43Observations += 1) === 2) {
    throw Object.assign(new Error('TASK130_F43_PRIVATE_STACK'), {
      code: 'ENOENT', path: '/TASK130_F43_PRIVATE_DISTRIBUTION',
    });
  }
  return realpathSyncNative(strPath, ...arrArguments);
};
`);
      assert.notEqual(strF43Source, source);
      writeFileSync(strF43Recorder, strF43Source);
      const objF43FoldFailure = spawnSync(process.execPath, [strF43Recorder,
        '--json', '--any-toolchain', '--no-audit',
        `--cache-directory=${mkdtempSync(join(temporary, 'f43-cache-'))}`], {
        encoding: 'utf8', maxBuffer: 16 * 1024 * 1024, env: process.env,
      });
      refuse(objF43FoldFailure, 2);
      assert.match(objF43FoldFailure.stderr, /unreviewed toolchain/);
      assert.doesNotMatch(objF43FoldFailure.stderr,
        /TASK130_F43|PRIVATE_DISTRIBUTION|PRIVATE_STACK|Get-SupplyFreezeDigest\.f43-probe/);
      rmSync(strF43Checkout, { recursive: true, force: true });

      const strStickyCheckout = join(temporary, 'sticky-internal-ancestors');
      cpSync(checkout, strStickyCheckout, { recursive: true, verbatimSymlinks: true });
      const strStickyFixture = join(strStickyCheckout, '.github', 'workflows');
      chmodSync(strStickyCheckout, 0o1777);
      chmodSync(join(strStickyCheckout, '.github'), 0o1777);
      chmodSync(strStickyFixture, 0o755);
      const objStickyAccepted = invokeFrom(strStickyFixture, ['--no-audit']);
      assert.equal(objStickyAccepted.status, 0, objStickyAccepted.stderr);

      const strWritableCheckout = join(temporary, 'TASK130_F38_PRIVATE_REPOSITORY');
      cpSync(checkout, strWritableCheckout, { recursive: true, verbatimSymlinks: true });
      const strWritableFixture = join(strWritableCheckout, '.github', 'workflows');
      chmodSync(strWritableCheckout, 0o775);
      const objWritableAncestor = invokeFrom(strWritableFixture, ['--no-audit']);
      refuse(objWritableAncestor, 15);
      assert.match(objWritableAncestor.stderr, /repository root; path\/name withheld/);
      assert.doesNotMatch(objWritableAncestor.stderr, /TASK130_F38|PRIVATE_REPOSITORY/);
      chmodSync(strWritableCheckout, 0o755);
      chmodSync(strWritableFixture, 0o1777);
      const objWritableDirect = invokeFrom(strWritableFixture, ['--no-audit']);
      refuse(objWritableDirect, 15);
      assert.match(objWritableDirect.stderr, /workflow directory; path\/name withheld/);
      assert.doesNotMatch(objWritableDirect.stderr, /TASK130_F38|PRIVATE_REPOSITORY/);

      const strNpmrcCheckout = join(temporary, 'TASK130_F33_PRIVATE_NPMRC_CHECKOUT');
      cpSync(checkout, strNpmrcCheckout, { recursive: true, verbatimSymlinks: true });
      const strNpmrcFixture = join(strNpmrcCheckout, '.github', 'workflows');
      const strPrivateNpmrc = join(strNpmrcFixture, '.npmrc');
      mkdirSync(strPrivateNpmrc);
      const objNpmrcRefusal = invokeFrom(strNpmrcFixture, ['--no-audit']);
      refuse(objNpmrcRefusal, 13);
      assert.match(objNpmrcRefusal.stderr, /project npm configuration that is not a regular file/);
      assert.doesNotMatch(objNpmrcRefusal.stderr,
        /TASK130_F33|PRIVATE_NPMRC_CHECKOUT|p1-recorder-tests/);

      const strMissingToolchain = join(temporary, 'TASK130_F33_BEARER_SECRET', 'bin');
      mkdirSync(strMissingToolchain, { recursive: true });
      const strMissingNode = join(strMissingToolchain, 'node');
      cpSync(process.execPath, strMissingNode);
      chmodSync(strMissingNode, 0o755);
      const objMissingNpm = spawnSync(strMissingNode, [
        join(fixture, 'Get-SupplyFreezeDigest.mjs'), '--json', '--any-toolchain', '--no-audit',
        `--cache-directory=${mkdtempSync(join(temporary, 'missing-npm-cache-'))}`,
      ], { encoding: 'utf8', maxBuffer: 16 * 1024 * 1024, env: process.env });
      refuse(objMissingNpm, 2);
      assert.match(objMissingNpm.stderr, /npm that is not bound to this Node installation/);
      assert.doesNotMatch(objMissingNpm.stderr, /TASK130_F33|BEARER_SECRET/);

      const strVersionToolchain = join(temporary, 'version-toolchain');
      const strVersionBin = join(strVersionToolchain, 'bin');
      const strVersionNpmRoot = join(strVersionToolchain, 'lib', 'node_modules', 'npm');
      mkdirSync(strVersionBin, { recursive: true });
      mkdirSync(dirname(strVersionNpmRoot), { recursive: true });
      cpSync(process.execPath, join(strVersionBin, 'node'));
      chmodSync(join(strVersionBin, 'node'), 0o755);
      const strActualNpmCli = realpathSync(join(dirname(process.execPath), 'npm'));
      cpSync(dirname(dirname(strActualNpmCli)), strVersionNpmRoot,
        { recursive: true, verbatimSymlinks: true });
      const strVersionNpmCli = join(strVersionNpmRoot, 'bin', 'npm-cli.js');
      const strFakeVersion =
        '11.16.0-TASK130-F28-PRIVATE-PRERELEASE.1+TASK130-F28-PRIVATE-BUILD';
      const bufVersionNpmCli = readFileSync(strVersionNpmCli);
      const intShebangEnd = bufVersionNpmCli.indexOf(0x0A) + 1;
      assert.ok(intShebangEnd > 1);
      writeFileSync(strVersionNpmCli, Buffer.concat([
        bufVersionNpmCli.subarray(0, intShebangEnd),
        Buffer.from(`if (process.argv.includes('--version') && process.env.TASK130_F26_CHILD_MARKER) { require('node:fs').writeFileSync(process.env.TASK130_F26_CHILD_MARKER, 'started'); process.exit(73); }\nif (process.argv.includes('--version')) { console.log(${JSON.stringify(strFakeVersion)}); process.exit(0); }\nif (process.argv.includes('ls') && process.env.TASK130_F34_INVALID_LS) { process.stdout.write(Buffer.from([0x80])); process.exit(0); }\n`),
        bufVersionNpmCli.subarray(intShebangEnd),
      ]));
      symlinkSync('../lib/node_modules/npm/bin/npm-cli.js', join(strVersionBin, 'npm'));
      const invokeVersionToolchain = (objEnvironment = process.env, boolNoAudit = true) => {
        const arrArguments = [join(fixture, 'Get-SupplyFreezeDigest.mjs'), '--any-toolchain',
          '--json', `--cache-directory=${mkdtempSync(join(temporary, 'version-cache-'))}`];
        if (boolNoAudit) arrArguments.push('--no-audit');
        return spawnSync(join(strVersionBin, 'node'), arrArguments, {
          encoding: 'utf8', maxBuffer: 16 * 1024 * 1024, env: objEnvironment,
        });
      };
      const strF35ChildMarker = join(temporary, 'TASK130_F35_CHILD_STARTED');
      const objVersionRefusal = invokeVersionToolchain(
        { ...process.env, TASK130_F26_CHILD_MARKER: strF35ChildMarker });
      refuse(objVersionRefusal, 2);
      assert.equal(existsSync(strF35ChildMarker), false);
      assert.match(objVersionRefusal.stderr, /npm installation that is not the reviewed one/);
      assert.doesNotMatch(`${objVersionRefusal.stdout}\n${objVersionRefusal.stderr}`,
        /TASK130-F28|PRIVATE-PRERELEASE|PRIVATE-BUILD/);
      const objObservedNpm = objVersionRefusal.stderr.match(
        /observed\s+([0-9a-f]{64}) \(([0-9]+) files, 0 symlinks\)/u);
      assert.ok(objObservedNpm, objVersionRefusal.stderr);
      const strF35AuditMarker = join(temporary, 'TASK130_F35_AUDIT_CHILD_STARTED');
      const objAuditEnabledRefusal = invokeVersionToolchain(
        { ...process.env, TASK130_F26_CHILD_MARKER: strF35AuditMarker }, false);
      refuse(objAuditEnabledRefusal, 2);
      assert.equal(existsSync(strF35AuditMarker), false);
      assert.match(objAuditEnabledRefusal.stderr, /npm installation that is not the reviewed one/);

      const strFifoCheckout = join(temporary, 'fifo-checkout');
      cpSync(checkout, strFifoCheckout, { recursive: true, verbatimSymlinks: true });
      const strFifoFixture = join(strFifoCheckout, '.github', 'workflows');
      const strFifoRecorder = join(strFifoFixture, 'Get-SupplyFreezeDigest.mjs');
      const strControlledRecorder = join(strFifoFixture,
        'Get-SupplyFreezeDigest.f26-ordering.mjs');
      const strFifoSource = readFileSync(strFifoRecorder, 'utf8')
        .replace(/const REVIEWED_NPM_TREE_SHA256 = '[0-9a-f]{64}';/u,
          `const REVIEWED_NPM_TREE_SHA256 = '${objObservedNpm[1]}';`)
        .replace(/const REVIEWED_NPM_TREE_FILES = [0-9]+;/u,
          `const REVIEWED_NPM_TREE_FILES = ${objObservedNpm[2]};`);
      writeFileSync(strControlledRecorder, strFifoSource);
      const objInvalidLs = spawnSync(join(strVersionBin, 'node'), [
        strControlledRecorder, '--json', '--any-toolchain', '--no-audit',
        `--cache-directory=${mkdtempSync(join(temporary, 'invalid-ls-cache-'))}`,
      ], { encoding: 'utf8', maxBuffer: 16 * 1024 * 1024,
        env: { ...process.env, TASK130_F34_INVALID_LS: '1' } });
      refuse(objInvalidLs, 7);
      assert.match(objInvalidLs.stderr, /npm ls stdout is not valid UTF-8/);
      assert.doesNotMatch(objInvalidLs.stderr, /�|80/u);
      const strProjectFifo = join(strFifoFixture, 'node_modules', 'yaml', 'package.json');
      rmSync(strProjectFifo);
      const objMkfifo = spawnSync('mkfifo', [strProjectFifo], { encoding: 'utf8' });
      assert.equal(objMkfifo.status, 0, objMkfifo.stderr);
      const strNpmChildMarker = join(temporary, 'TASK130_F26_CHILD_STARTED');
      const objBeforeChild = spawnSync(join(strVersionBin, 'node'), [
        strControlledRecorder, '--json', '--any-toolchain',
        '--no-audit', `--cache-directory=${mkdtempSync(join(temporary, 'fifo-cache-'))}`,
      ], { encoding: 'utf8', maxBuffer: 16 * 1024 * 1024,
        env: { ...process.env, TASK130_F26_CHILD_MARKER: strNpmChildMarker } });
      assert.equal(existsSync(strNpmChildMarker), false);
      refuse(objBeforeChild, 11);
      for (const arrFlags of [['--no-audit'], ['--no-audit', '--any-toolchain']]) {
        const objFifoRefusal = invokeFrom(strFifoFixture, arrFlags, {}, process.env, 5000);
        refuse(objFifoRefusal, 11);
        assert.match(objFifoRefusal.stderr, /tree containing special files/);
        assert.doesNotMatch(objFifoRefusal.stderr, /node_modules\/yaml\/package\.json/);
      }

      const problemCheckout = join(temporary, 'TASK130_F22_PRIVATE_PATH');
      cpSync(checkout, problemCheckout, { recursive: true, verbatimSymlinks: true });
      const problemFixture = join(problemCheckout, '.github', 'workflows');
      rmSync(join(problemFixture, 'node_modules', 'minimatch'), { recursive: true });
      const problemRefusal = invokeFrom(problemFixture, ['--no-audit']);
      refuse(problemRefusal, 7);
      assert.doesNotMatch(problemRefusal.stderr,
        /TASK130_F22_PRIVATE_PATH|minimatch@|required by glob|balanced-match@|brace-expansion@|p1-recorder-tests/u);
      assert.match(problemRefusal.stderr, /problem count\s+[1-9][0-9]*/);
      assert.match(problemRefusal.stderr, /problem categories\s+missing \d+, invalid \d+, extraneous \d+, other \d+/);
      const startupTargets = ['node-cache', 'node-coverage', 'node-warnings'].map((name) => join(checkout, name));
      const scrubbed = spawnSync('env', ['-u', 'NODE_OPTIONS', '-u', 'NODE_COMPILE_CACHE',
        '-u', 'NODE_V8_COVERAGE', '-u', 'NODE_REDIRECT_WARNINGS', '-u', 'NODE_DEBUG',
        '-u', 'NODE_DEBUG_NATIVE', 'NODE_DISABLE_COMPILE_CACHE=1',
        process.execPath, join(fixture, 'Get-SupplyFreezeDigest.mjs'), '--json',
        `--cache-directory=${mkdtempSync(join(temporary, 'startup-cache-'))}`], {
        encoding: 'utf8', maxBuffer: 16 * 1024 * 1024,
        env: { ...process.env, NODE_OPTIONS: '--trace-warnings', NODE_COMPILE_CACHE: startupTargets[0],
          NODE_V8_COVERAGE: startupTargets[1], NODE_REDIRECT_WARNINGS: startupTargets[2],
          NODE_DEBUG: 'child_process', NODE_DEBUG_NATIVE: 'HTTP',
          NODE_DISABLE_COMPILE_CACHE: '0' },
      });
      assert.equal(scrubbed.status, 0, scrubbed.stderr);
      assert.equal(JSON.parse(scrubbed.stdout).currentObservation.complete, true);
      assert.ok(startupTargets.every((path) => !existsSync(path)));
      assert.deepEqual(fingerprint(checkout), before);
      refuse(invoke(['--no-audit'], { NODE_REDIRECT_WARNINGS: join(temporary, 'unsupported-warnings') }), 2);
      for (const [strKey, strValue] of [
        ['NODE_DEBUG', 'child_process,TASK130_F19_FAKE_SECRET'],
        ['NODE_DEBUG_NATIVE', 'TASK130_F19_FAKE_SECRET'],
      ]) {
        const debugRefusal = invoke(
          ['--no-audit'], { [strKey]: strValue }, objBoundedDebugEnvironment);
        refuse(debugRefusal, 2);
        assert.doesNotMatch(debugRefusal.stderr, /TASK130_F19_FAKE_SECRET|child_process|HTTP/u);
        assert.match(debugRefusal.stderr, /unsupported Node startup-output environment/);
      }

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

      const objPackageUnicode = JSON.parse(packageBytes);
      objPackageUnicode.task130F18 = 'valid 雪';
      writeFileSync(packagePath, JSON.stringify(objPackageUnicode));
      assert.equal(invoke(['--no-audit', '--any-toolchain']).status, 0);
      const strInvalidMarker = 'TASK130_F18_PACKAGE_RAW';
      const bufPackageMarked = Buffer.from(JSON.stringify({
        ...objPackageUnicode, task130F18: strInvalidMarker,
      }));
      const intPackageMarker = bufPackageMarked.indexOf(strInvalidMarker);
      writeFileSync(packagePath, Buffer.concat([
        bufPackageMarked.subarray(0, intPackageMarker),
        Buffer.from([0x80]),
        bufPackageMarked.subarray(intPackageMarker + Buffer.byteLength(strInvalidMarker)),
      ]));
      refuse(invoke(['--no-audit', '--any-toolchain']), 4);
      writeFileSync(packagePath, packageBytes);

      chmodSync(packagePath, 0o664);
      refuse(invoke(['--no-audit', '--any-toolchain']), 15);
      chmodSync(packagePath, 0o644);

      const contractPath = join(fixture, 'workflow-policy-contract.json');
      const contractBytes = readFileSync(contractPath);
      for (const arrFlags of [['--no-audit'], ['--no-audit', '--any-toolchain']]) {
        writeFileSync(contractPath, 'null');
        const objNullContract = invoke(arrFlags);
        refuse(objNullContract, 17);
        assert.equal(objNullContract.signal, null);
        assert.match(objNullContract.stderr,
          /P1 contract root has an unexpected response schema/);
        assert.doesNotMatch(objNullContract.stderr,
          /TASK131_F31_PRIVATE_PATH|TypeError|Get-SupplyFreezeDigest|file:\/\/|\n\s+at\s/u);
      }
      writeFileSync(contractPath, contractBytes);
      const strRecursiveValue = '['.repeat(10000)
        + '"TASK131_F2_PRIVATE_CONTRACT_VALUE"' + ']'.repeat(10000);
      const strRecursiveContract = `{"supplyFreeze":{"recursive":${strRecursiveValue}}`
        + `,"TASK131_F2_PRIVATE_CONTRACT_ROOT":"withheld"}`;
      assert.equal(JSON.parse(strRecursiveContract).TASK131_F2_PRIVATE_CONTRACT_ROOT,
        'withheld');
      for (const arrFlags of [['--no-audit'], ['--no-audit', '--any-toolchain']]) {
        writeFileSync(contractPath, strRecursiveContract);
        const objRecursiveContract = invoke(arrFlags);
        refuse(objRecursiveContract, 17);
        assert.equal(objRecursiveContract.signal, null);
        assert.match(objRecursiveContract.stderr,
          /P1 historical assertions could not be compared safely/);
        assert.match(objRecursiveContract.stderr, /nothing is recorded/);
        assert.doesNotMatch(objRecursiveContract.stderr,
          /TASK131_F2|PRIVATE_CONTRACT|RangeError|Maximum call stack|Get-SupplyFreezeDigest|file:\/\/|\n\s+at\s/u);
      }
      writeFileSync(contractPath, contractBytes);
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

      const objContractUnicode = JSON.parse(contractBytes);
      objContractUnicode.task130F18 = 'valid 雪';
      writeFileSync(contractPath, JSON.stringify(objContractUnicode));
      assert.equal(invoke(['--no-audit', '--any-toolchain']).status, 0);
      const strContractMarker = 'TASK130_F18_CONTRACT_RAW';
      const bufContractMarked = Buffer.from(JSON.stringify({
        ...objContractUnicode, task130F18: strContractMarker,
      }));
      const intContractMarker = bufContractMarked.indexOf(strContractMarker);
      writeFileSync(contractPath, Buffer.concat([
        bufContractMarked.subarray(0, intContractMarker),
        Buffer.from([0x80]),
        bufContractMarked.subarray(intContractMarker + Buffer.byteLength(strContractMarker)),
      ]));
      refuse(invoke(['--no-audit', '--any-toolchain']), 17);
      writeFileSync(contractPath, contractBytes);

      chmodSync(contractPath, 0o664);
      refuse(invoke(['--no-audit', '--any-toolchain']), 17);
      chmodSync(contractPath, 0o644);

      const projectConfig = join(fixture, '.npmrc');
      writeFileSync(projectConfig, '', { mode: 0o644 });
      assert.equal(invoke(['--no-audit', '--any-toolchain']).status, 0);
      chmodSync(projectConfig, 0o664);
      refuse(invoke(['--no-audit', '--any-toolchain']), 15);
      rmSync(projectConfig);

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

      const strPrivateRegistry =
        'https://TASK130_F29_PRIVATE_HOST:8443/TASK130_F29_PRIVATE_PATH?token=PRIVATE';
      const registryFailure = invoke([], { NPM_CONFIG_REGISTRY: strPrivateRegistry });
      refuse(registryFailure, 9);
      assert.match(registryFailure.stderr,
        /observed https:\/\/\(authority and URL details withheld\)/);
      assert.doesNotMatch(registryFailure.stderr,
        /TASK130_F29|PRIVATE_HOST|PRIVATE_PATH|8443|token=/u);

      const extra = join(fixture, 'node_modules', 'yaml', 'unexpected-file');
      writeFileSync(extra, 'changed bytes');
      const changed = invoke(['--no-audit']);
      assert.equal(changed.status, 0, changed.stderr);
      assert.notEqual(JSON.parse(changed.stdout).currentObservation.installedTreeSha256,
        result.currentObservation.installedTreeSha256);
      rmSync(extra);
      symlinkSync('/etc/passwd', extra);
      refuse(invoke(['--no-audit']), 11);
      refuse(invoke(['--no-audit', '--any-toolchain']), 11);
      rmSync(extra);

      const outsideReturn = join(temporary, 'TASK130_F15_OUTSIDE_RETURN');
      symlinkSync(join(fixture, 'node_modules', 'yaml', 'package.json'), outsideReturn);
      symlinkSync(outsideReturn, extra);
      refuse(invoke(['--no-audit', '--any-toolchain']), 11);
      rmSync(extra);
      rmSync(outsideReturn);

      symlinkSync('TASK130_F15_MISSING', extra);
      refuse(invoke(['--no-audit', '--any-toolchain']), 11);
      rmSync(extra);

      const loopPeer = join(fixture, 'node_modules', 'yaml', 'TASK130_F15_LOOP_PEER');
      symlinkSync('TASK130_F15_LOOP_PEER', extra);
      symlinkSync('unexpected-file', loopPeer);
      refuse(invoke(['--no-audit', '--any-toolchain']), 11);
      rmSync(extra);
      rmSync(loopPeer);

      symlinkSync(Buffer.from([0x80]), extra);
      refuse(invoke(['--no-audit', '--any-toolchain']), 11);
      rmSync(extra);

      writeFileSync(extra, 'mode check');
      chmodSync(extra, 0o664);
      refuse(invoke(['--no-audit', '--any-toolchain']), 14);
      rmSync(extra);
      const writableDirectory = join(fixture, 'node_modules', 'yaml', 'TASK130_F17_WRITABLE');
      mkdirSync(writableDirectory, { mode: 0o775 });
      chmodSync(writableDirectory, 0o775);
      refuse(invoke(['--no-audit', '--any-toolchain']), 14);
      rmSync(writableDirectory, { recursive: true });
      const treeRoot = join(fixture, 'node_modules');
      const intRootMode = lstatSync(treeRoot).mode & 0o777;
      chmodSync(treeRoot, 0o775);
      refuse(invoke(['--no-audit', '--any-toolchain']), 14);
      chmodSync(treeRoot, intRootMode);

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
      const earlyUrlFailure = invoke(['--secret=https://user:UNIQUE_SECRET@example.test']);
      refuse(earlyUrlFailure, 2);
      assert.doesNotMatch(earlyUrlFailure.stderr, /UNIQUE_SECRET|ReferenceError/);
      const earlySchemeFailure = invoke(['--secret=git+ssh://TASK130_F29_PRIVATE_PROTOCOL/path']);
      refuse(earlySchemeFailure, 2);
      assert.doesNotMatch(earlySchemeFailure.stderr, /TASK130_F29|PRIVATE_PROTOCOL|git\+ssh/);
    } finally {
      // Every mutation is confined to this fresh, externally allocated fixture.
      rmSync(temporary, { recursive: true, force: true });
    }
  });
