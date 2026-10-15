// Explicit native integration command. Importing this file does not run cases.
import assert from 'node:assert/strict';
import fs from 'node:fs';
import os from 'node:os';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { createServer } from 'node:http';
import { createServer as createTcpServer } from 'node:net';
import { stripVTControlCharacters } from 'node:util';
import { adaptedArguments, archiveInput, complete, declarations, digest, foundationTar, linuxCases, native, once,
  options, ordinary, ordinaryNativeTool, originalArguments, quote, readBounded, readCurlWitness,
  readNativeToolBounded, resourceFailure, verifySuite, windowsCases, windowsRetryAfter, assertRetryAfterRefusal } from './CiToolchainDownloadFixtures.mjs';

const directory = path.dirname(fileURLToPath(import.meta.url));
const repository = path.resolve(directory, '../..');
const fixtureModule = new URL('./CiToolchainDownloadFixtures.mjs', import.meta.url).href;
const windows = process.platform === 'win32';
const write = (file, content) => fs.writeFileSync(file, content, { flag: 'wx', mode: 0o600 });
const json = file => JSON.parse(readBounded(file));
const phaseRows = file => fs.existsSync(file) ? readBounded(file, 16384).toString().trim().split('\n') : [];

function childEnvironment() {
  const env = { ...process.env };
  for (const name of Object.keys(env)) {
    if (/^(?:GITHUB_TOKEN|GH_TOKEN|ACTIONS_RUNTIME_TOKEN|NODE_OPTIONS|NODE_PATH|STYLEGUIDE_RECOVERY_NODE22|npm_config_.*|GIT_.*|SSH_ASKPASS|SSH_ASKPASS_REQUIRE)$/iu.test(name)) delete env[name];
  }
  Object.assign(env, { GIT_CONFIG_NOSYSTEM: '1', GIT_CONFIG_GLOBAL: windows ? 'NUL' : '/dev/null', GIT_TERMINAL_PROMPT: '0' });
  return env;
}

async function powershell(executable, script, root, env) {
  const file = path.join(root, `prepare-${fs.readdirSync(root).length}.ps1`);
  write(file, script);
  const result = await native(executable, ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', file],
    { cwd: root, env, milliseconds: 30000 });
  assert.equal(result.status, 0, result.stderr);
  return result.stdout.trim();
}

async function admitHost(executable, root, env) {
  ordinaryNativeTool(executable);
  const result = JSON.parse(await powershell(executable, `[CmdletBinding()]
[OutputType([string])]
param()

try {
    $ErrorActionPreference = 'Stop'
    $PSNativeCommandUseErrorActionPreference = $false
    if ([Runtime.InteropServices.RuntimeInformation]::ProcessArchitecture -ne [Runtime.InteropServices.Architecture]::X64 -or
        [Runtime.InteropServices.RuntimeInformation]::OSArchitecture -ne [Runtime.InteropServices.Architecture]::X64) {
        throw 'Native x64 required.'
    }
    if ($IsWindows -and $PSVersionTable.PSVersion.ToString() -cne '7.6.5') {
        throw 'Reviewed Windows PowerShell 7.6.5 required.'
    }
    if (-not $IsWindows -and -not $IsLinux) {
        throw 'Native Linux or Windows required.'
    }
    $strCurl = if ($IsWindows) {
        Join-Path ([Environment]::SystemDirectory) 'curl.exe'
    } else {
        '/usr/bin/curl'
    }
    $strGit = if ($IsWindows) {
        Join-Path ([Environment]::GetFolderPath('ProgramFiles')) 'Git/cmd/git.exe'
    } else {
        '/usr/bin/git'
    }
    @{
        platform = $(if ($IsWindows) {
                'win32'
            } else {
                'linux'
            }); version = $PSVersionTable.PSVersion.ToString();
        curl = $strCurl; git = $strGit; executable = [Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    } | ConvertTo-Json -Compress
} catch {
    Write-Debug -Message 'A04 host admission failed.'
    throw
}
`, root, env));
  assert.equal(result.platform, process.platform);
  const fold = value => windows ? value.toLowerCase() : value;
  assert.equal(fold(fs.realpathSync.native(result.executable)), fold(fs.realpathSync.native(executable)));
  result.curlSha256 = digest(readNativeToolBounded(result.curl, 16777216));
  ordinaryNativeTool(result.git); result.gitSha256 = digest(readNativeToolBounded(result.git, 67108864));
  result.powershellSha256 = digest(readNativeToolBounded(executable, 16777216));
  if (!windows) for (const name of ['tar', 'xz']) ordinaryNativeTool('/usr/bin/' + name);
  // Full native library, effective UID, ACL and credential admission is still in the complete product caller.
  return result;
}

async function controlledArchive(root, role, version, npmVersion, wrong, env) {
  assert.doesNotMatch(process.execPath, /[\s\r\n]/u, 'The controlled Linux shebang requires an unambiguous native Node path.');
  const release = `node-v${version}-linux-x64`;
  const log = path.join(root, 'controlled-runtime.jsonl');
  const program = `#!${process.execPath}\nconst fs=require('node:fs');const args=process.argv.slice(2);\n` +
    `fs.appendFileSync(${JSON.stringify(log)},JSON.stringify({role:${JSON.stringify(role)},args})+'\\n');\n` +
    `if(args.includes('--version'))console.log(args[0]?.endsWith('npm-cli.js')?${JSON.stringify(npmVersion)}:${JSON.stringify(wrong ? 'v0.0.0' : 'v' + version)});\n` +
    `else if(${JSON.stringify(role)}!=='preferred')process.exit(92);\n`;
  const entries = ['', '/bin', '/lib', '/lib/node_modules', '/lib/node_modules/npm', '/lib/node_modules/npm/bin']
    .map(suffix => ({ name: release + suffix + '/', type: '5' }));
  for (const [name, data, mode] of [['bin/node', program, 0o755], ['lib/node_modules/npm/bin/npm-cli.js', 'fixture', 0o644],
    ['lib/node_modules/npm/bin/npx-cli.js', 'fixture', 0o644], ['lib/node_modules/npm/package.json', JSON.stringify({ version: npmVersion }), 0o644]]) {
    entries.push({ name: `${release}/${name}`, data: Buffer.from(data), mode });
  }
  const result = await native('/usr/bin/xz', ['-c', '-T1'], { env, milliseconds: 15000, input: foundationTar(entries), binary: true });
  // Binary xz output must not pass through UTF-8 string decoding.
  assert.equal(result.status, 0, result.stderr);
  return result.stdout;
}

export function instrument(source, node, adapter, phaseFile) {
  source = source.replaceAll('\r\n', '\n');
  source = once(source, '    & $strCurlPath --disable --silent --show-error',
    `    & ${quote(node)} ${quote(adapter)} $Role $strCurlPath --disable --silent --show-error`);
  const record = text => `[IO.File]::AppendAllText(${quote(phaseFile)}, ${text} + "\n", [Text.UTF8Encoding]::new($false))`;
  for (const [anchor, marker] of [
    ['    $hashtablePreferredRuntime = Install-ReviewedRuntime', "'channels-held'"],
    ['    $null = Assert-OrdinaryPath $strArchive', '"archive-admission:$Role"'],
    ['    Expand-ReviewedArchive $strArchive $strDestinationPath $strReleaseRoot', '"expand:$Role"'],
    ['    $arrNodeVersionOutput = @(& $strNodePath --version)', '"node:$Role"'],
    ['    $arrNpmVersionOutput = @(& $strNodePath $strNpmScriptPath --version)', '"npm:$Role"'],
    ['    $hashtableCompatibilityRuntime = $null', "'preferred-complete'"],
    ['    $arrRunnerRecords = @(', "'publication'"],
  ]) source = once(source, anchor, '    ' + record(marker) + '\n' + anchor);
  return source;
}

export async function endpoint(mode, bytes, phaseFile, { httpFactory = createServer, tlsFactory = createTcpServer,
  timers = { set: (fn, ms) => setTimeout(fn, ms), clear: id => clearTimeout(id) }, platform = process.platform } = {}) {
  const requests = [], sockets = new Set(), responseTimers = new Set();
  let delayedPublication = false, connections = 0, closing = false, serverClosed = false, listenEnded = false;
  let fault = null, closePromise, checkClose = () => {}, startDone = () => {};
  const respond = (request, response) => {
    response.on('error', error => { if (!['ECONNRESET', 'EPIPE'].includes(error.code)) fault ??= String(error.message).slice(0, 512); });
    if (closing || requests.length >= 4 || request.url !== '/archive' || request.headers['x-a04-ambient']) {
      fault ??= 'Unexpected request or request bound';
      response.writeHead(400); response.end(); return;
    }
    requests.push({ url: request.url, ambient: request.headers['x-a04-ambient'] ?? null, at: performance.now() });
    const number = requests.length;
    if (mode === 'stall') return;
    if (mode === 'exhaustion' || mode === 'transient' && number === 1 || mode.startsWith('retry-after-')) {
      const respondedAt = Date.now();
      const headers = mode === 'retry-after-number' ? { 'Retry-After': '600' }
        : mode === 'retry-after-date' ? { 'Retry-After': new Date(respondedAt + 600000).toUTCString() } : {};
      response.writeHead(503, { ...headers, Connection: 'close', 'Content-Length': '0' });
      Object.assign(requests.at(-1), { responseStatus: response.statusCode, retryAfter: headers['Retry-After'] ?? null, respondedAt });
      response.end(); return;
    }
    if (mode === 'partial-stall' || mode === 'partial-recovery' && number === 1) {
      response.writeHead(200, { 'Content-Length': String(bytes.length), Connection: 'close' }); response.write(bytes.subarray(0, 127)); return;
    }
    if (mode === 'short-eof') {
      response.writeHead(200, { 'Content-Length': '1000', Connection: 'close' }); response.end('short'); return;
    }
    const payload = mode === 'wrong-digest' ? Buffer.from('wrong bytes') : bytes;
    const send = () => { response.writeHead(200, { 'Content-Length': String(payload.length), Connection: 'close' }); response.end(payload); };
    if (platform === 'linux' && mode === 'partial-recovery') {
      const phases = phaseRows(phaseFile);
      delayedPublication = phases.includes('preferred-complete') && !phases.includes('publication');
      const timer = timers.set(() => {
        responseTimers.delete(timer);
        if (closing) return;
        try { delayedPublication &&= !phaseRows(phaseFile).includes('publication'); send(); }
        catch (error) { fault ??= error.message; response.destroy(); }
      }, 150);
      responseTimers.add(timer);
    } else send();
  };
  const server = mode === 'tls-stall' ? tlsFactory(() => {}) : httpFactory((request, response) => {
    try { respond(request, response); }
    catch (error) { fault ??= String(error.message).slice(0, 512); response.destroy(); }
  });
  server.maxConnections = 4;
  server.on('drop', () => { fault ??= 'Connection bound'; });
  server.on('error', error => { fault ??= String(error.message).slice(0, 512); listenEnded = true; startDone(error); checkClose(); });
  server.on('close', () => { serverClosed = true; checkClose(); });
  server.on('connection', socket => {
    connections++; sockets.add(socket);
    socket.on('error', error => { if (!['ECONNRESET', 'EPIPE'].includes(error.code)) fault ??= String(error.message).slice(0, 512); });
    socket.on('close', () => { sockets.delete(socket); checkClose(); });
    if (closing || connections > 4) { fault ??= 'Connection bound'; try { socket.destroy(); } catch (error) { fault ??= error.message; } }
  });
  const requestClose = () => {
    try { server.close(error => {
      if (error && error.code !== 'ERR_SERVER_NOT_RUNNING') fault ??= String(error.message).slice(0, 512);
      if (!error || error.code === 'ERR_SERVER_NOT_RUNNING' && listenEnded && !server.listening) serverClosed = true;
      checkClose();
    }); } catch (error) { fault ??= String(error.message).slice(0, 512); }
  };
  const close = () => {
    if (closePromise) return closePromise;
    closing = true;
    for (const timer of responseTimers) timers.clear(timer); responseTimers.clear();
    closePromise = new Promise((resolve, reject) => {
      let done = false;
      const finish = expired => {
        if (done) return; done = true; timers.clear(limit);
        if (expired) {
          // Detach local handles only; report uncertainty and retain the case.
          try { server.unref(); } catch (error) { fault ??= error.message; }
          for (const socket of sockets) {
            try { socket.destroy(); socket.unref(); } catch (error) { fault ??= error.message; }
          }
        }
        const evidence = { kind: 'loopback', serverClosed, listenEnded, socketsPending: sockets.size,
          responseTimersPending: responseTimers.size, expired, detachedHandles: expired, fault, cleanup: expired || fault ? 'unproved' : 'closed' };
        if (expired || fault) reject(resourceFailure('Loopback teardown failed; fixture retained', evidence));
        else resolve(evidence);
      };
      const limit = timers.set(() => finish(true), 5000);
      checkClose = () => { if (serverClosed && listenEnded && sockets.size === 0 && responseTimers.size === 0) finish(false); };
      for (const socket of sockets) { try { socket.destroy(); } catch (error) { fault ??= error.message; } }
      requestClose(); checkClose();
    });
    return closePromise;
  };
  try {
    await new Promise((resolve, reject) => {
      let done = false;
      const limit = timers.set(() => {
        if (!done) { done = true; reject(resourceFailure('Loopback listen deadline', { cleanup: 'unproved' })); }
      }, 5000);
      startDone = error => {
        if (done) return; done = true; timers.clear(limit);
        if (error) reject(error); else resolve();
      };
      try {
        server.listen(0, '127.0.0.1', () => {
          listenEnded = true;
          if (closing) requestClose();
          startDone();
        });
      } catch (error) { listenEnded = true; startDone(error); }
    });
    return { address: `${mode === 'tls-stall' ? 'https' : 'http'}://127.0.0.1:${server.address().port}`,
      requests, get connections() { return connections; }, get delayedPublication() { return delayedPublication; }, close };
  } catch (error) {
    try { await close(); }
    catch (teardown) { throw resourceFailure(error.message, { teardown: teardown.resourceEvidence, cleanup: 'unproved' }); }
    throw error;
  }
}

export async function withDownloadEndpoint(create, action) {
  let server, failure;
  try { server = await create(); return { result: await action(server), server }; }
  catch (error) { failure = error; throw error; }
  finally {
    if (server) {
      try { await server.close(); }
      catch (error) {
        if (failure) throw resourceFailure(failure.message, { operation: failure.resourceEvidence ?? null,
          teardown: error.resourceEvidence ?? error.message, cleanup: 'unproved' });
        throw error;
      }
    }
  }
}

async function runCase(mode, context) {
  const { parent, host, powershell: executable, declaration, archive, source, credential, env } = context;
  const root = fs.mkdtempSync(path.join(parent, 'case-')), identity = ordinary(root, true);
  const work = path.join(root, 'repository'), scripts = path.join(work, '.github/workflows');
  const runner = path.join(root, 'runner'), commands = path.join(runner, '_runner_file_commands');
  fs.mkdirSync(scripts, { recursive: true, mode: 0o700 }); fs.mkdirSync(commands, { recursive: true, mode: 0o700 });
  const phaseFile = path.join(root, 'phases'), pathFile = path.join(commands, 'path'), envFile = path.join(commands, 'env');
  write(pathFile, ''); write(envFile, ''); write(path.join(root, 'sentinel'), 'unchanged');
  write(path.join(scripts, 'Test-CheckoutCredentials.ps1'), credential);
  for (const folder of [work, scripts]) {
    write(path.join(folder, 'package.json'), JSON.stringify({ engines: declaration.pkg.engines }));
    write(path.join(folder, 'package-lock.json'), '{}');
  }
  const pin = structuredClone(declaration.pin);
  let preferredArchive, payload = archive.bytes;
  if (!windows) {
    const preferred = await controlledArchive(root, 'preferred', declaration.pkg.engines.node, declaration.pkg.engines.npm, false, env);
    preferredArchive = path.join(root, 'preferred.tar.xz'); write(preferredArchive, preferred);
    pin.preferred.linuxX64Sha256 = digest(preferred);
    if (mode === 'wrong-version') {
      payload = await controlledArchive(root, 'recoveryCompatibility', pin.recoveryCompatibility.node, pin.recoveryCompatibility.npm, true, env);
      pin.recoveryCompatibility.linuxX64Sha256 = digest(payload);
    }
  }
  write(path.join(scripts, 'ci-toolchain.json'), JSON.stringify(pin));
  const preparation = `[CmdletBinding()]
[OutputType([void])]
param()

try {
    $ErrorActionPreference = 'Stop'
    $PSNativeCommandUseErrorActionPreference = $false
    if ($IsWindows) {
        $objUser = [Security.Principal.WindowsIdentity]::GetCurrent().User
        foreach ($strPath in @(${[root, work, path.join(work, '.github'), scripts, runner, commands, pathFile, envFile].map(quote).join(', ')})) {
            $objItem = Get-Item -LiteralPath $strPath -Force
            $objAccessControl = if ($objItem.PSIsContainer) {
                [Security.AccessControl.DirectorySecurity]::new()
            } else {
                [Security.AccessControl.FileSecurity]::new()
            }
            $objAccessControl.SetOwner($objUser); $objAccessControl.SetAccessRuleProtection($true, $false)
            foreach ($objSecurityIdentifier in @($objUser, [Security.Principal.SecurityIdentifier]::new('S-1-5-18'), [Security.Principal.SecurityIdentifier]::new('S-1-5-32-544'))) {
                $objRule = if ($objItem.PSIsContainer) {
                    [Security.AccessControl.FileSystemAccessRule]::new($objSecurityIdentifier, 'FullControl', 'ContainerInherit, ObjectInherit', 'None', 'Allow')
                } else {
                    [Security.AccessControl.FileSystemAccessRule]::new($objSecurityIdentifier, 'FullControl', 'Allow')
                }
                [void]$objAccessControl.AddAccessRule($objRule)
            }
            Set-Acl -LiteralPath $strPath -AclObject $objAccessControl -Confirm:$false -WhatIf:$false
        }
    }
    & ${quote(host.git)} -c core.hooksPath=${quote(path.join(root, 'hooks'))} -C ${quote(work)} init --quiet --template=${quote(path.join(root, 'template'))}
    if ($LASTEXITCODE -ne 0) {
        throw 'Private fixture Git init failed.'
    }
    & ${quote(host.git)} -C ${quote(work)} remote add origin 'https://github.com/franklesniak/PSStyleGuide'
    if ($LASTEXITCODE -ne 0) {
        throw 'Private fixture origin failed.'
    }
} catch {
    Write-Debug -Message 'A04 private fixture preparation failed.'
    throw
}
`;
  fs.mkdirSync(path.join(root, 'hooks')); fs.mkdirSync(path.join(root, 'template'));
  await powershell(executable, preparation, root, env);
  let curlrc;
  const { result: caller, server } = await withDownloadEndpoint(() => endpoint(mode, payload, phaseFile), async server => {
    curlrc = `header = "X-A04-Ambient: dummy-only"\nurl = "${server.address}/ambient"\n`;
    const configPath = path.join(root, 'config.json'), adapter = path.join(root, 'dispatch.mjs');
    write(configPath, JSON.stringify({ root, runner, mode, endpoint: server.address, platform: process.platform,
      declaration, curl: host.curl, curlSha256: host.curlSha256, preferredArchive }));
    write(adapter, `import { adapterMain } from ${JSON.stringify(fixtureModule)};\n` +
      `try { process.exitCode = adapterMain(${JSON.stringify(configPath)}, ...process.argv.slice(2,4), process.argv.slice(4)); }\n` +
      `catch (error) { console.error(error.message); process.exitCode = 98; }\n`);
    const script = path.join(scripts, 'Initialize-CiToolchain.ps1'); write(script, instrument(source, process.execPath, adapter, phaseFile));
    for (const name of ['.curlrc', '_curlrc']) write(path.join(root, name), curlrc);
    const caseEnv = { ...env, RUNNER_TEMP: runner, GITHUB_PATH: pathFile, GITHUB_ENV: envFile,
      CURL_HOME: root, HOME: root, USERPROFILE: root, APPDATA: root, NO_PROXY: '127.0.0.1', no_proxy: '127.0.0.1' };
    const args = ['-NoLogo', '-NoProfile', '-NonInteractive', '-File', script];
    if (!windows) args.push('-IncludeRecoveryCompatibility', '-WorkflowDependencies', '-InstructionDependencies');
    return await native(executable, args, { cwd: work, env: caseEnv, milliseconds: 240000 });
  });
  const success = ['transient', 'partial-recovery'].includes(mode);
  assert.equal(caller.status === 0, success, caller.stdout + caller.stderr);
  const roles = windows ? ['preferred'] : ['preferred', 'recoveryCompatibility'];
  const expected = ['tls-stall', 'stall', 'partial-stall'].includes(mode) ? 28
    : ['exhaustion', 'retry-after-number', 'retry-after-date'].includes(mode) ? 22 : mode === 'short-eof' ? 18 : 0;
  assert.deepEqual(fs.readdirSync(root).filter(name => /^curl-/iu.test(name)).sort(), roles.map(role => `curl-${role}.json`).sort(), 'Extra or missing curl role record.');
  const witnesses = roles.map(role => {
    const original = originalArguments(role, declaration, process.platform, runner);
    return readCurlWitness(path.join(root, `curl-${role}.json`), { platform: process.platform, mode, role,
      command: host.curl, commandSha256: host.curlSha256, original,
      adapted: !windows && role === 'preferred' ? null : adaptedArguments(original, server.address, mode), status: expected });
  });
  for (const witness of witnesses) {
    complete(witness, mode); assert.deepEqual(witness.original, originalArguments(witness.role, declaration, process.platform, runner));
    assert.equal(witness.commandSha256, host.curlSha256);
  }
  const transferred = witnesses.at(-1);
  const retryAfter = windowsRetryAfter(process.platform, mode);
  assert.ok(transferred.status === expected || retryAfter && transferred.status === 0);
  assert.equal(transferred.controlled, false);
  const count = mode === 'tls-stall' ? server.connections : server.requests.length;
  const attempts = ['transient', 'partial-recovery'].includes(mode) ? 2
    : ['tls-stall', 'stall', 'partial-stall', 'exhaustion'].includes(mode) ? 3 : 1;
  assert.equal(count, attempts); assert.ok(server.requests.every(row => row.url === '/archive' && row.ambient === null));
  if (mode === 'tls-stall') assert.ok(transferred.elapsedMs < 10000, 'Connection cap must defeat three 3-second attempt caps plus backoff.');
  for (const name of ['.curlrc', '_curlrc']) assert.equal(readBounded(path.join(root, name)).toString(), curlrc);
  const phases = phaseRows(phaseFile), role = roles.at(-1);
  assert.ok(phases.includes('channels-held'));
  for (const witness of witnesses) {
    assert.deepEqual(witness.channels.map(row => row.name), ['path', 'env']);
    assert.ok(witness.channels.every(row => windows ? row.held === true : row.empty === true));
  }
  const errorText = stripVTControlCharacters(caller.stderr).replace(/[\r\n|]+/gu, ' ').replace(/\s+/gu, ' ');
  if (expected && transferred.status !== 0) assert.ok(errorText.includes(`Runtime download failed: ${expected} (${role}/${windows ? 'win' : 'linux'}-x64)`), errorText);
  if (retryAfter) assertRetryAfterRefusal({ platform: process.platform, mode, caller, witness: transferred,
    requests: server.requests, phases, pathBytes: readBounded(pathFile), envBytes: readBounded(envFile),
    runtimeExists: fs.existsSync(path.join(runner, 'styleguide-node')) });
  if (mode === 'wrong-digest') assert.match(errorText, /archive digest is incorrect/u);
  if (mode === 'wrong-version') assert.match(errorText, /installed Node version is incorrect/u);
  if (!success) {
    assert.equal(readBounded(pathFile).length, 0); assert.equal(readBounded(envFile).length, 0);
    assert.equal(phases.includes('publication'), false);
    assert.equal(fs.existsSync(path.join(runner, 'styleguide-node')), false, 'Owned runtime cleanup must finish.');
    assert.equal(phases.includes(`expand:${role}`), mode === 'wrong-version');
    assert.equal(phases.includes(`node:${role}`), mode === 'wrong-version');
    assert.equal(phases.includes(`npm:${role}`), false);
  } else {
    for (const current of roles) for (const phase of ['expand', 'node', 'npm']) assert.ok(phases.includes(`${phase}:${current}`));
    assert.equal(phases.at(-1), 'publication');
    const nodeRoot = path.join(runner, 'styleguide-node');
    const bin = path.join(nodeRoot, 'preferred', `node-v${declaration.pkg.engines.node}-${windows ? 'win' : 'linux'}-x64`, ...(windows ? [] : ['bin']));
    const recovery = windows ? '' : path.join(nodeRoot, 'recoveryCompatibility', `node-v${pin.recoveryCompatibility.node}-linux-x64/bin/node`);
    const records = [`npm_config_userconfig=${path.join(nodeRoot, 'npm-user.config')}`, `npm_config_globalconfig=${path.join(nodeRoot, 'npm-global.config')}`,
      'npm_config_registry=https://registry.npmjs.org/', 'npm_config_ignore_scripts=true', 'npm_config_audit=false', 'npm_config_fund=false', 'CI=true', 'NODE_PATH=', `STYLEGUIDE_RECOVERY_NODE22=${recovery}`];
    assert.equal(readBounded(envFile).toString(), records.join('\n') + '\n');
    assert.equal(readBounded(pathFile).toString(), bin + '\n');
    assert.deepEqual(json(path.join(nodeRoot, 'ready.json')), declaration.pkg.engines);
    for (const name of ['npm-user.config', 'npm-global.config']) assert.equal(readBounded(path.join(nodeRoot, name)).length, 0);
    assert.equal(digest(readBounded(path.join(nodeRoot, `${role}.${windows ? 'zip' : 'tar.xz'}`), 67108864)), archive.sha256);
    if (!windows) assert.equal(server.delayedPublication, true);
  }
  if (!windows) {
    assert.ok(phases.includes('preferred-complete'));
    const calls = readBounded(path.join(root, 'controlled-runtime.jsonl')).toString().trim().split('\n').map(JSON.parse);
    const installs = calls.filter(row => row.args.includes('ci')), preflights = calls.filter(row => row.args.includes('--preflight'));
    assert.equal(installs.length, success ? 2 : 0); assert.equal(preflights.length, success ? 2 : 0);
    assert.ok([...installs, ...preflights].every(row => row.role === 'preferred'));
  }
  assert.equal(readBounded(path.join(root, 'sentinel')).toString(), 'unchanged');
  const currentIdentity = ordinary(root, true);
  for (const key of ['ino', 'dev']) assert.equal(currentIdentity[key], identity[key]);
  assert.equal(path.dirname(root), parent);
  // Natural child settlement and exact fixture ownership precede recursive removal.
  fs.rmSync(root, { recursive: true }); assert.equal(fs.existsSync(root), false);
  return { name: mode, passed: true, cleanup: true, caller, witnesses, phases, requests: server.requests, attempts: count };
}

export async function main(args = process.argv.slice(2)) {
  const selected = options(args);
  assert.ok(['linux', 'win32'].includes(process.platform) && process.arch === 'x64', 'Native Linux/Windows x64 required.');
  const declaration = declarations(repository);
  assert.equal(process.versions.node, declaration.pkg.engines.node, 'Use the declared preferred Node host.');
  const archive = archiveInput(selected.archiveDirectory, declaration, process.platform);
  ordinaryNativeTool(selected.powershell);
  const sourcePath = path.join(directory, 'Initialize-CiToolchain.ps1'), credentialPath = path.join(directory, 'Test-CheckoutCredentials.ps1');
  const source = readBounded(sourcePath).toString(), credential = readBounded(credentialPath).toString();
  const parent = fs.mkdtempSync(path.join(os.tmpdir(), 'a04-native-')); const parentIdentity = ordinary(parent, true);
  const env = childEnvironment();
  const host = await admitHost(selected.powershell, parent, env);
  const result = { schema: 'StyleGuide.NativeDownloadResult.v1', platform: process.platform, host,
    source: { initializer: digest(source), credential: digest(credential), ...declaration.identities },
    archive: { filename: archive.filename, sha256: archive.sha256, bytes: archive.bytes.length }, cases: [], passed: 0, failed: 0, skipped: 0 };
  for (const mode of windows ? windowsCases : linuxCases) result.cases.push(await runCase(mode,
    { ...selected, declaration, archive, source, credential, parent, host, env }));
  result.passed = result.cases.length;
  assert.equal(digest(readBounded(sourcePath)), result.source.initializer);
  assert.equal(digest(readBounded(credentialPath)), result.source.credential);
  assert.deepEqual(declarations(repository).identities, declaration.identities);
  assert.equal(digest(readBounded(archive.file, 67108864)), archive.sha256);
  assert.equal(digest(readNativeToolBounded(host.curl, 16777216)), host.curlSha256);
  assert.equal(digest(readNativeToolBounded(host.git, 67108864)), host.gitSha256);
  assert.equal(digest(readNativeToolBounded(selected.powershell, 16777216)), host.powershellSha256);
  const currentParentIdentity = ordinary(parent, true);
  for (const key of ['ino', 'dev']) assert.equal(currentParentIdentity[key], parentIdentity[key]);
  assert.equal(path.dirname(parent), os.tmpdir());
  fs.rmSync(parent, { recursive: true });
  return verifySuite(result, process.platform);
}

// Prefer loader identity; retain direct-call detection on runtimes without this property.
const isMain = typeof import.meta.main === 'boolean' ? import.meta.main : (() => {
  if (!process.argv[1]) return false;
  try {
    return fs.realpathSync(process.argv[1]) === fs.realpathSync(fileURLToPath(import.meta.url));
  } catch {
    return false;
  }
})();

if (isMain) {
  main().then(result => {
    const output = JSON.stringify(result);
    assert.ok(Buffer.byteLength(output) <= 1048576, 'Completed suite output exceeds its one-MiB bound.');
    console.log(output);
  }).catch(error => {
    console.error(JSON.stringify({ failure: `Native download suite failed: ${error.message}`,
      ...(error.resourceEvidence ? { resources: error.resourceEvidence } : {}) })); process.exitCode = 1;
  });
}
