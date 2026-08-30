#!/usr/bin/env node

// Validates the parser dependency contract without executing proposed bytes.
// Version: 1.0.20260821.5

import { spawnSync } from "node:child_process";

const PACKAGE_MAXIMUM_BYTES = 131_072;
const LOCK_MAXIMUM_BYTES = 2_097_152;
const PARSER_NAME = "markdown-it";
const PARSER_PATH = `node_modules/${PARSER_NAME}`;
const REVISION_PATTERN = /^(?:[0-9a-f]{40}|[0-9a-f]{64})$/i;
const OBJECT_ID_PATTERN = /^(?:[0-9a-f]{40}|[0-9a-f]{64})$/;
const FORBIDDEN_INSTALL_INPUTS = [".npmrc", "npm-shrinkwrap.json"];

function fail(message) {
  throw new Error(`Parser manifest contract failed: ${message}`);
}

function isRecord(value) {
  return value !== null && typeof value === "object" && !Array.isArray(value);
}

function requireRecord(value, name) {
  if (!isRecord(value)) {
    fail(`${name} must be a JSON object.`);
  }
  return value;
}

function parseArguments(argv) {
  const result = { selfTest: false };
  for (let index = 0; index < argv.length; index += 1) {
    const argument = argv[index];
    if (argument === "--self-test") {
      result.selfTest = true;
      continue;
    }
    const keyByArgument = {
      "--repository-root": "repositoryRoot",
      "--trusted-revision": "trustedRevision",
      "--input-revision": "inputRevision",
    };
    const key = keyByArgument[argument];
    if (!key || index + 1 >= argv.length || argv[index + 1].startsWith("--")) {
      fail(`Unknown or incomplete argument: ${argument}`);
    }
    result[key] = argv[index + 1];
    index += 1;
  }
  for (const key of ["repositoryRoot", "trustedRevision", "inputRevision"]) {
    if (typeof result[key] !== "string" || result[key].length === 0) {
      fail(`The ${key} argument is required.`);
    }
  }
  return result;
}

function runGit(repositoryRoot, argumentsList, maximumBytes = 65_536) {
  const result = spawnSync("git", ["-C", repositoryRoot, ...argumentsList], {
    encoding: null,
    maxBuffer: maximumBytes,
    shell: false,
    windowsHide: true,
  });
  if (result.error || result.status !== 0) {
    fail(`git ${argumentsList[0]} did not complete successfully.`);
  }
  return result.stdout;
}

function decodeUtf8(bytes, name, maximumBytes) {
  if (!Buffer.isBuffer(bytes) || bytes.length > maximumBytes) {
    fail(`${name} exceeds ${maximumBytes} bytes.`);
  }
  if (
    (bytes.length >= 3 && bytes[0] === 0xef && bytes[1] === 0xbb && bytes[2] === 0xbf) ||
    (bytes.length >= 2 &&
      ((bytes[0] === 0xff && bytes[1] === 0xfe) ||
        (bytes[0] === 0xfe && bytes[1] === 0xff)))
  ) {
    fail(`${name} must not contain a byte-order mark.`);
  }
  try {
    return new TextDecoder("utf-8", { fatal: true }).decode(bytes);
  } catch {
    fail(`${name} must contain valid UTF-8.`);
  }
}

function parseJsonBytes(bytes, name, maximumBytes) {
  const text = decodeUtf8(bytes, name, maximumBytes);
  let value;
  try {
    value = JSON.parse(text);
  } catch {
    fail(`${name} must contain valid JSON.`);
  }
  return requireRecord(value, name);
}

function resolveCommit(repositoryRoot, revision, name) {
  if (!REVISION_PATTERN.test(revision)) {
    fail(`${name} must be a complete Git object ID.`);
  }
  const resolved = decodeUtf8(
    runGit(repositoryRoot, ["rev-parse", "--verify", `${revision}^{commit}`]),
    name,
    65_536,
  ).trim();
  if (resolved.toLowerCase() !== revision.toLowerCase()) {
    fail(`${name} did not resolve to the requested commit.`);
  }
  return resolved;
}

function getTreeEntry(repositoryRoot, revision, path) {
  const output = decodeUtf8(
    runGit(repositoryRoot, ["ls-tree", "-z", revision, "--", path]),
    path,
    65_536,
  );
  if (output.length === 0) {
    return null;
  }
  const match = /^(\d{6}) (\w+) ([0-9a-f]+)\t([^\0]+)\0$/.exec(output);
  if (!match || match[4] !== path || !OBJECT_ID_PATTERN.test(match[3])) {
    fail(`${path} has an ambiguous Git tree entry.`);
  }
  return { mode: match[1], type: match[2], objectId: match[3] };
}

function requireOrdinaryBlob(entry, path) {
  if (entry.mode !== "100644" || entry.type !== "blob") {
    fail(`${path} must be an ordinary non-executable Git blob.`);
  }
}

function requireAbsentEntry(entry, path) {
  if (entry !== null) {
    fail(`${path} must remain absent from the parser installation input.`);
  }
}

function requireAbsentOwnField(record, field, name) {
  if (Object.hasOwn(record, field)) {
    fail(`${name}.${field} must remain absent from the parser installation input.`);
  }
}

function readJsonBlob(repositoryRoot, revision, path, maximumBytes) {
  const entry = getTreeEntry(repositoryRoot, revision, path);
  if (!entry) {
    fail(`${path} is missing from ${revision}.`);
  }
  requireOrdinaryBlob(entry, path);
  const sizeText = decodeUtf8(
    runGit(repositoryRoot, ["cat-file", "-s", entry.objectId]),
    `${path} size`,
    65_536,
  ).trim();
  if (!/^\d+$/.test(sizeText) || Number(sizeText) > maximumBytes) {
    fail(`${path} exceeds ${maximumBytes} bytes.`);
  }
  const bytes = runGit(
    repositoryRoot,
    ["cat-file", "blob", entry.objectId],
    maximumBytes + 1,
  );
  if (bytes.length !== Number(sizeText)) {
    fail(`${path} did not produce its declared byte count.`);
  }
  return parseJsonBytes(bytes, path, maximumBytes);
}

function requirePathAbsent(repositoryRoot, revision, path) {
  requireAbsentEntry(getTreeEntry(repositoryRoot, revision, path), path);
}

function resolveDependencyPath(packages, packagePath, dependencyName) {
  let scope = packagePath;
  while (true) {
    const candidate = scope
      ? `${scope}/node_modules/${dependencyName}`
      : `node_modules/${dependencyName}`;
    if (Object.hasOwn(packages, candidate)) {
      return candidate;
    }
    if (scope.length === 0) {
      break;
    }
    const parentIndex = scope.lastIndexOf("/node_modules/");
    scope = parentIndex < 0 ? "" : scope.slice(0, parentIndex);
  }
  fail(`${packagePath} cannot resolve dependency ${dependencyName}.`);
}

function getDependencyNames(descriptor) {
  const names = new Set();
  for (const field of ["dependencies", "optionalDependencies"]) {
    if (descriptor[field] === undefined) {
      continue;
    }
    const dependencies = requireRecord(descriptor[field], `${field} descriptor`);
    for (const name of Object.keys(dependencies)) {
      if (typeof dependencies[name] !== "string" || dependencies[name].length === 0) {
        fail(`${field}.${name} must be a nonempty string.`);
      }
      names.add(name);
    }
  }
  if (descriptor.peerDependencies !== undefined) {
    const peerDependencies = requireRecord(
      descriptor.peerDependencies,
      "peerDependencies descriptor",
    );
    const peerMetadata = descriptor.peerDependenciesMeta === undefined
      ? {}
      : requireRecord(descriptor.peerDependenciesMeta, "peerDependenciesMeta descriptor");
    for (const name of Object.keys(peerDependencies)) {
      if (typeof peerDependencies[name] !== "string" || peerDependencies[name].length === 0) {
        fail(`peerDependencies.${name} must be a nonempty string.`);
      }
      if (!isRecord(peerMetadata[name]) || peerMetadata[name].optional !== true) {
        names.add(name);
      }
    }
  }
  return [...names].sort();
}

function getParserClosure(lock, name) {
  const packages = requireRecord(lock.packages, `${name}.packages`);
  if (!Object.hasOwn(packages, PARSER_PATH)) {
    fail(`${name} does not contain ${PARSER_PATH}.`);
  }
  const closure = new Map();
  const queue = [PARSER_PATH];
  while (queue.length > 0) {
    const packagePath = queue.shift();
    if (closure.has(packagePath)) {
      continue;
    }
    const descriptor = requireRecord(packages[packagePath], `${name}:${packagePath}`);
    if (descriptor.link === true) {
      fail(`${name}:${packagePath} must not be a link.`);
    }
    for (const field of ["version", "resolved", "integrity"]) {
      if (typeof descriptor[field] !== "string" || descriptor[field].length === 0) {
        fail(`${name}:${packagePath}.${field} must be a nonempty string.`);
      }
    }
    closure.set(packagePath, descriptor);
    for (const dependencyName of getDependencyNames(descriptor)) {
      queue.push(resolveDependencyPath(packages, packagePath, dependencyName));
    }
  }
  return closure;
}

function stableJson(value) {
  if (Array.isArray(value)) {
    return `[${value.map(stableJson).join(",")}]`;
  }
  if (isRecord(value)) {
    return `{${Object.keys(value)
      .sort()
      .map((key) => `${JSON.stringify(key)}:${stableJson(value[key])}`)
      .join(",")}}`;
  }
  return JSON.stringify(value);
}

function requireNonemptyString(value, name) {
  if (typeof value !== "string" || value.length === 0) {
    fail(`${name} must be a nonempty string.`);
  }
  return value;
}

function requireNonemptyStringOrArray(value, name) {
  if (typeof value === "string") {
    return requireNonemptyString(value, name);
  }
  if (!Array.isArray(value) || value.length === 0) {
    fail(`${name} must be a nonempty string or a nonempty array of nonempty strings.`);
  }
  for (let index = 0; index < value.length; index += 1) {
    requireNonemptyString(value[index], `${name}[${index}]`);
  }
  return value;
}

function getOptionalNestedValue(record, path, name) {
  let current = record;
  for (let index = 0; index < path.length - 1; index += 1) {
    const field = path[index];
    if (current[field] === undefined) {
      return { present: false };
    }
    current = requireRecord(
      current[field],
      `${name}.${path.slice(0, index + 1).join(".")}`,
    );
  }
  const value = current[path.at(-1)];
  return value === undefined ? { present: false } : { present: true, value };
}

function validateOptionalSelector(snapshot, name, kind) {
  if (!snapshot.present) {
    return;
  }
  if (kind === "string") {
    requireNonemptyString(snapshot.value, name);
    return;
  }
  if (kind === "record") {
    requireRecord(snapshot.value, name);
    return;
  }
  if (kind === "string-or-array") {
    requireNonemptyStringOrArray(snapshot.value, name);
    return;
  }
  fail(`Internal error: unsupported optional selector kind ${kind}.`);
}

function validateRuntimeSelectorContract(trustedPackage, trustedRoot, inputPackage, inputRoot) {
  const trustedEngines = requireRecord(trustedPackage.engines, "trusted package.json.engines");
  const trustedRootEngines = requireRecord(
    trustedRoot.engines,
    "trusted package-lock.json root engines",
  );
  const inputEngines = requireRecord(inputPackage.engines, "package.json.engines");
  const inputRootEngines = requireRecord(
    inputRoot.engines,
    "package-lock.json root engines",
  );
  const trustedNode = requireNonemptyString(
    trustedEngines.node,
    "trusted package.json.engines.node",
  );
  const trustedRootNode = requireNonemptyString(
    trustedRootEngines.node,
    "trusted package-lock.json root engines.node",
  );
  const inputNode = requireNonemptyString(inputEngines.node, "package.json.engines.node");
  const inputRootNode = requireNonemptyString(
    inputRootEngines.node,
    "package-lock.json root engines.node",
  );
  const trustedNpm = requireNonemptyString(
    trustedEngines.npm,
    "trusted package.json.engines.npm",
  );
  const trustedRootNpm = requireNonemptyString(
    trustedRootEngines.npm,
    "trusted package-lock.json root engines.npm",
  );
  const inputNpm = requireNonemptyString(inputEngines.npm, "package.json.engines.npm");
  const inputRootNpm = requireNonemptyString(
    inputRootEngines.npm,
    "package-lock.json root engines.npm",
  );
  if (trustedNode !== trustedRootNode) {
    fail("The trusted package and lock root must agree on engines.node.");
  }
  if (inputNode !== inputRootNode) {
    fail("package.json and the package-lock.json root must agree on engines.node.");
  }
  if (inputNode !== trustedNode) {
    fail(`The proposed engines.node selector must equal the trusted selector ${trustedNode}.`);
  }
  if (trustedNpm !== trustedRootNpm) {
    fail("The trusted package and lock root must agree on engines.npm.");
  }
  if (inputNpm !== inputRootNpm) {
    fail("package.json and the package-lock.json root must agree on engines.npm.");
  }
  if (inputNpm !== trustedNpm) {
    fail(`The proposed engines.npm selector must equal the trusted selector ${trustedNpm}.`);
  }

  const optionalSelectors = [
    { name: "volta.node", path: ["volta", "node"], kind: "string" },
    { name: "devEngines", path: ["devEngines"], kind: "record" },
    { name: "volta.extends", path: ["volta", "extends"], kind: "string" },
  ];
  for (const selector of optionalSelectors) {
    const trusted = getOptionalNestedValue(
      trustedPackage,
      selector.path,
      "trusted package.json",
    );
    const input = getOptionalNestedValue(inputPackage, selector.path, "package.json");
    validateOptionalSelector(trusted, `trusted package.json.${selector.name}`, selector.kind);
    validateOptionalSelector(input, `package.json.${selector.name}`, selector.kind);
    if (stableJson(input) !== stableJson(trusted)) {
      fail(`The proposed ${selector.name} selector must equal the trusted selector.`);
    }
  }

  for (const name of ["os", "cpu", "libc"]) {
    const trustedPackageSelector = getOptionalNestedValue(
      trustedPackage,
      [name],
      "trusted package.json",
    );
    const trustedRootSelector = getOptionalNestedValue(
      trustedRoot,
      [name],
      "trusted package-lock.json root",
    );
    const inputPackageSelector = getOptionalNestedValue(
      inputPackage,
      [name],
      "package.json",
    );
    const inputRootSelector = getOptionalNestedValue(
      inputRoot,
      [name],
      "package-lock.json root",
    );
    for (const [snapshot, displayName] of [
      [trustedPackageSelector, `trusted package.json.${name}`],
      [trustedRootSelector, `trusted package-lock.json root ${name}`],
      [inputPackageSelector, `package.json.${name}`],
      [inputRootSelector, `package-lock.json root ${name}`],
    ]) {
      validateOptionalSelector(snapshot, displayName, "string-or-array");
    }
    if (name !== "libc") {
      if (stableJson(trustedPackageSelector) !== stableJson(trustedRootSelector)) {
        fail(`The trusted package and lock root must agree on ${name}.`);
      }
      if (stableJson(inputPackageSelector) !== stableJson(inputRootSelector)) {
        fail(`package.json and the package-lock.json root must agree on ${name}.`);
      }
    }
    if (stableJson(inputPackageSelector) !== stableJson(trustedPackageSelector)) {
      fail(`The proposed package.json.${name} selector must equal the trusted selector.`);
    }
    if (stableJson(inputRootSelector) !== stableJson(trustedRootSelector)) {
      fail(`The proposed package-lock.json root ${name} selector must equal the trusted selector.`);
    }
  }
}

function validateContract(trustedPackage, trustedLock, inputPackage, inputLock) {
  requireAbsentOwnField(trustedPackage, "overrides", "trusted package.json");
  requireAbsentOwnField(inputPackage, "overrides", "package.json");
  const trustedRoot = requireRecord(trustedLock.packages?.[""], "trusted lock root");
  const inputRoot = requireRecord(inputLock.packages?.[""], "input lock root");
  validateRuntimeSelectorContract(trustedPackage, trustedRoot, inputPackage, inputRoot);
  const trustedClosure = getParserClosure(trustedLock, "trusted lock");
  const inputClosure = getParserClosure(inputLock, "input lock");
  const trustedParser = trustedClosure.get(PARSER_PATH);
  const expectedVersion = trustedParser.version;
  const inputDevDependencies = requireRecord(
    inputPackage.devDependencies,
    "package.json.devDependencies",
  );
  const inputRootDevDependencies = requireRecord(
    inputRoot.devDependencies,
    "package-lock.json root devDependencies",
  );
  if (inputDevDependencies[PARSER_NAME] !== expectedVersion) {
    fail(`package.json must declare ${PARSER_NAME} at exact version ${expectedVersion}.`);
  }
  if (inputRootDevDependencies[PARSER_NAME] !== expectedVersion) {
    fail(`package-lock.json must declare ${PARSER_NAME} at exact version ${expectedVersion}.`);
  }
  for (const field of ["name", "version"]) {
    if (trustedPackage[field] !== trustedRoot[field] || trustedPackage[field] !== trustedLock[field]) {
      fail(`The trusted package and lock must agree on ${field}.`);
    }
    if (inputPackage[field] !== inputRoot[field] || inputPackage[field] !== inputLock[field]) {
      fail(`package.json and package-lock.json must agree on ${field}.`);
    }
  }
  if (inputLock.lockfileVersion !== trustedLock.lockfileVersion) {
    fail("The proposed lockfile version must equal the trusted lockfile version.");
  }
  const trustedPaths = [...trustedClosure.keys()].sort();
  const inputPaths = [...inputClosure.keys()].sort();
  if (stableJson(inputPaths) !== stableJson(trustedPaths)) {
    fail("The proposed parser dependency paths must equal the trusted closure.");
  }
  for (const packagePath of trustedPaths) {
    if (stableJson(inputClosure.get(packagePath)) !== stableJson(trustedClosure.get(packagePath))) {
      fail(`The proposed parser dependency descriptor changed: ${packagePath}.`);
    }
  }
}

function clone(value) {
  return JSON.parse(JSON.stringify(value));
}

function expectFailure(name, operation, expectedText) {
  let message = "";
  try {
    operation();
  } catch (error) {
    message = error instanceof Error ? error.message : String(error);
  }
  if (!message.includes(expectedText)) {
    fail(`Self-test ${name} did not produce ${expectedText}.`);
  }
}

function runSelfTests() {
  const trustedPackage = {
    name: "fixture",
    version: "1.0.0",
    engines: { node: "24.18.0", npm: "11.16.0" },
    devDependencies: {},
  };
  const trustedLock = {
    name: "fixture",
    version: "1.0.0",
    lockfileVersion: 3,
    packages: {
      "": {
        name: "fixture",
        version: "1.0.0",
        engines: { node: "24.18.0", npm: "11.16.0" },
        devDependencies: {},
      },
      [PARSER_PATH]: {
        version: "14.2.0",
        resolved: "https://registry.npmjs.org/markdown-it/-/markdown-it-14.2.0.tgz",
        integrity: "sha512-parser",
        dev: true,
        dependencies: { argparse: "^2.0.1" },
      },
      "node_modules/argparse": {
        version: "2.0.1",
        resolved: "https://registry.npmjs.org/argparse/-/argparse-2.0.1.tgz",
        integrity: "sha512-argparse",
        dev: true,
      },
    },
  };
  const inputPackage = {
    name: "fixture",
    version: "1.0.0",
    engines: { node: "24.18.0", npm: "11.16.0" },
    devDependencies: { [PARSER_NAME]: "14.2.0" },
  };
  const inputLock = clone(trustedLock);
  inputLock.packages[""].devDependencies[PARSER_NAME] = "14.2.0";
  validateContract(trustedPackage, trustedLock, inputPackage, inputLock);

  const mutations = [
    ["direct deletion", (pkg) => delete pkg.devDependencies[PARSER_NAME], "must declare"],
    ["direct drift", (pkg) => (pkg.devDependencies[PARSER_NAME] = "14.2.1"), "must declare"],
    [
      "root lock drift",
      (_pkg, lock) => (lock.packages[""].devDependencies[PARSER_NAME] = "14.2.1"),
      "must declare",
    ],
    [
      "parser integrity drift",
      (_pkg, lock) => (lock.packages[PARSER_PATH].integrity = "sha512-changed"),
      "descriptor changed",
    ],
    [
      "transitive drift",
      (_pkg, lock) => (lock.packages["node_modules/argparse"].version = "2.0.2"),
      "descriptor changed",
    ],
    [
      "closure deletion",
      (_pkg, lock) => delete lock.packages["node_modules/argparse"],
      "cannot resolve dependency",
    ],
    [
      "closure shadowing",
      (_pkg, lock) => {
        lock.packages[`${PARSER_PATH}/node_modules/argparse`] = {
          ...lock.packages["node_modules/argparse"],
          version: "2.0.2",
        };
      },
      "dependency paths",
    ],
    [
      "node selector drift",
      (pkg, lock) => {
        pkg.engines.node = "24.17.0";
        lock.packages[""].engines.node = "24.17.0";
      },
      "must equal the trusted selector",
    ],
    [
      "node lock-root drift",
      (_pkg, lock) => (lock.packages[""].engines.node = "24.17.0"),
      "must agree on engines.node",
    ],
    [
      "node selector deletion",
      (pkg) => delete pkg.engines.node,
      "package.json.engines.node must be a nonempty string",
    ],
    [
      "npm selector drift",
      (pkg, lock) => {
        pkg.engines.npm = "99.0.0";
        lock.packages[""].engines.npm = "99.0.0";
      },
      "proposed engines.npm selector must equal the trusted selector 11.16.0",
    ],
    [
      "npm package-only drift",
      (pkg) => (pkg.engines.npm = "99.0.0"),
      "package.json and the package-lock.json root must agree on engines.npm",
    ],
    [
      "npm lock-root drift",
      (_pkg, lock) => (lock.packages[""].engines.npm = "99.0.0"),
      "package.json and the package-lock.json root must agree on engines.npm",
    ],
    [
      "npm selector deletion",
      (pkg) => delete pkg.engines.npm,
      "package.json.engines.npm must be a nonempty string",
    ],
    [
      "npm lock-root selector deletion",
      (_pkg, lock) => delete lock.packages[""].engines.npm,
      "package-lock.json root engines.npm must be a nonempty string",
    ],
    [
      "higher-precedence Volta selector addition",
      (pkg) => (pkg.volta = { node: "24.18.0" }),
      "volta.node selector must equal the trusted selector",
    ],
    [
      "higher-precedence development runtime addition",
      (pkg) => {
        pkg.devEngines = { runtime: { name: "node", version: "24.18.0" } };
      },
      "devEngines selector must equal the trusted selector",
    ],
    [
      "indirect Volta selector addition",
      (pkg) => (pkg.volta = { extends: "./runtime-package.json" }),
      "volta.extends selector must equal the trusted selector",
    ],
    [
      "malformed Volta selector container",
      (pkg) => (pkg.volta = "24.18.0"),
      "package.json.volta must be a JSON object",
    ],
    [
      "malformed development-engine selector",
      (pkg) => (pkg.devEngines = []),
      "package.json.devEngines must be a JSON object",
    ],
    [
      "direct transitive override",
      (pkg) => (pkg.overrides = { argparse: "1.0.10" }),
      "package.json.overrides must remain absent",
    ],
    [
      "nested parser override",
      (pkg) => (pkg.overrides = { [PARSER_NAME]: { argparse: "1.0.10" } }),
      "package.json.overrides must remain absent",
    ],
    [
      "empty overrides object",
      (pkg) => (pkg.overrides = {}),
      "package.json.overrides must remain absent",
    ],
    [
      "malformed overrides value",
      (pkg) => (pkg.overrides = "argparse@1.0.10"),
      "package.json.overrides must remain absent",
    ],
  ];
  for (const [name, mutate, expectedText] of mutations) {
    const packageMutation = clone(inputPackage);
    const lockMutation = clone(inputLock);
    mutate(packageMutation, lockMutation);
    expectFailure(
      name,
      () => validateContract(trustedPackage, trustedLock, packageMutation, lockMutation),
      expectedText,
    );
  }

  const trustedNpmMismatch = clone(trustedLock);
  trustedNpmMismatch.packages[""].engines.npm = "99.0.0";
  expectFailure(
    "trusted npm package-lock disagreement",
    () => validateContract(trustedPackage, trustedNpmMismatch, inputPackage, inputLock),
    "trusted package and lock root must agree on engines.npm",
  );

  for (const selectorName of ["os", "cpu", "libc"]) {
    const packageAddition = clone(inputPackage);
    packageAddition[selectorName] = ["restricted"];
    expectFailure(
      `root ${selectorName} package-only addition`,
      () => validateContract(trustedPackage, trustedLock, packageAddition, inputLock),
      selectorName === "libc"
        ? `proposed package.json.${selectorName} selector must equal the trusted selector`
        : `package.json and the package-lock.json root must agree on ${selectorName}`,
    );

    const lockAddition = clone(inputLock);
    lockAddition.packages[""][selectorName] = ["restricted"];
    expectFailure(
      `root ${selectorName} lock-only addition`,
      () => validateContract(trustedPackage, trustedLock, inputPackage, lockAddition),
      selectorName === "libc"
        ? `proposed package-lock.json root ${selectorName} selector must equal the trusted selector`
        : `package.json and the package-lock.json root must agree on ${selectorName}`,
    );

    const matchedPackageAddition = clone(inputPackage);
    const matchedLockAddition = clone(inputLock);
    matchedPackageAddition[selectorName] = ["restricted"];
    matchedLockAddition.packages[""][selectorName] = ["restricted"];
    expectFailure(
      `root ${selectorName} matched addition`,
      () => validateContract(
        trustedPackage,
        trustedLock,
        matchedPackageAddition,
        matchedLockAddition,
      ),
      `proposed package.json.${selectorName} selector must equal the trusted selector`,
    );
  }

  for (const selectorName of ["os", "cpu", "libc"]) {
    for (const [description, malformedValue, expectedText] of [
      ["empty string", "", "must be a nonempty string"],
      ["empty array", [], "must be a nonempty string or a nonempty array"],
      ["non-string array member", [1], "[0] must be a nonempty string"],
      ["object", { name: "linux" }, "must be a nonempty string or a nonempty array"],
    ]) {
      const packageMutation = clone(inputPackage);
      packageMutation[selectorName] = malformedValue;
      expectFailure(
        `malformed package root ${selectorName} ${description}`,
        () => validateContract(trustedPackage, trustedLock, packageMutation, inputLock),
        `package.json.${selectorName}${expectedText.startsWith("[") ? "" : " "}${expectedText}`,
      );

      const lockMutation = clone(inputLock);
      lockMutation.packages[""][selectorName] = malformedValue;
      expectFailure(
        `malformed lock root ${selectorName} ${description}`,
        () => validateContract(trustedPackage, trustedLock, inputPackage, lockMutation),
        `package-lock.json root ${selectorName}${expectedText.startsWith("[") ? "" : " "}${expectedText}`,
      );
    }
  }

  const trustedPlatformPackage = clone(trustedPackage);
  const trustedPlatformLock = clone(trustedLock);
  const inputPlatformPackage = clone(inputPackage);
  const inputPlatformLock = clone(inputLock);
  for (const [targetPackage, targetRoot] of [
    [trustedPlatformPackage, trustedPlatformLock.packages[""]],
    [inputPlatformPackage, inputPlatformLock.packages[""]],
  ]) {
    targetPackage.os = ["linux", "win32"];
    targetRoot.os = ["linux", "win32"];
    targetPackage.cpu = ["x64", "arm64"];
    targetRoot.cpu = ["x64", "arm64"];
    targetPackage.libc = ["glibc", "musl"];
  }
  validateContract(
    trustedPlatformPackage,
    trustedPlatformLock,
    inputPlatformPackage,
    inputPlatformLock,
  );

  const stringPlatformPackage = clone(trustedPackage);
  const stringPlatformLock = clone(trustedLock);
  const inputStringPlatformPackage = clone(inputPackage);
  const inputStringPlatformLock = clone(inputLock);
  for (const [targetPackage, targetRoot] of [
    [stringPlatformPackage, stringPlatformLock.packages[""]],
    [inputStringPlatformPackage, inputStringPlatformLock.packages[""]],
  ]) {
    targetPackage.os = "linux";
    targetRoot.os = "linux";
    targetPackage.cpu = "x64";
    targetRoot.cpu = "x64";
    targetPackage.libc = "glibc";
  }
  validateContract(
    stringPlatformPackage,
    stringPlatformLock,
    inputStringPlatformPackage,
    inputStringPlatformLock,
  );

  for (const selectorName of ["os", "cpu"]) {
    const packageMismatch = clone(inputPlatformPackage);
    packageMismatch[selectorName] = ["changed"];
    expectFailure(
      `root ${selectorName} package-lock disagreement`,
      () => validateContract(
        trustedPlatformPackage,
        trustedPlatformLock,
        packageMismatch,
        inputPlatformLock,
      ),
      `package.json and the package-lock.json root must agree on ${selectorName}`,
    );

    const matchedDriftPackage = clone(inputPlatformPackage);
    const matchedDriftLock = clone(inputPlatformLock);
    matchedDriftPackage[selectorName] = ["changed"];
    matchedDriftLock.packages[""][selectorName] = ["changed"];
    expectFailure(
      `root ${selectorName} matched drift`,
      () => validateContract(
        trustedPlatformPackage,
        trustedPlatformLock,
        matchedDriftPackage,
        matchedDriftLock,
      ),
      `proposed package.json.${selectorName} selector must equal the trusted selector`,
    );

    const matchedDeletionPackage = clone(inputPlatformPackage);
    const matchedDeletionLock = clone(inputPlatformLock);
    delete matchedDeletionPackage[selectorName];
    delete matchedDeletionLock.packages[""][selectorName];
    expectFailure(
      `root ${selectorName} matched deletion`,
      () => validateContract(
        trustedPlatformPackage,
        trustedPlatformLock,
        matchedDeletionPackage,
        matchedDeletionLock,
      ),
      `proposed package.json.${selectorName} selector must equal the trusted selector`,
    );

    const reorderedPackage = clone(inputPlatformPackage);
    const reorderedLock = clone(inputPlatformLock);
    reorderedPackage[selectorName].reverse();
    reorderedLock.packages[""][selectorName].reverse();
    expectFailure(
      `root ${selectorName} array-order drift`,
      () => validateContract(
        trustedPlatformPackage,
        trustedPlatformLock,
        reorderedPackage,
        reorderedLock,
      ),
      `proposed package.json.${selectorName} selector must equal the trusted selector`,
    );
  }

  const libcDrift = clone(inputPlatformPackage);
  libcDrift.libc = ["musl", "glibc"];
  expectFailure(
    "root libc array-order drift",
    () => validateContract(
      trustedPlatformPackage,
      trustedPlatformLock,
      libcDrift,
      inputPlatformLock,
    ),
    "proposed package.json.libc selector must equal the trusted selector",
  );
  const libcDeletion = clone(inputPlatformPackage);
  delete libcDeletion.libc;
  expectFailure(
    "root libc deletion",
    () => validateContract(
      trustedPlatformPackage,
      trustedPlatformLock,
      libcDeletion,
      inputPlatformLock,
    ),
    "proposed package.json.libc selector must equal the trusted selector",
  );
  const libcLockAddition = clone(inputPlatformLock);
  libcLockAddition.packages[""].libc = "glibc";
  expectFailure(
    "root libc independent lock drift",
    () => validateContract(
      trustedPlatformPackage,
      trustedPlatformLock,
      inputPlatformPackage,
      libcLockAddition,
    ),
    "proposed package-lock.json root libc selector must equal the trusted selector",
  );

  const trustedPlatformMismatch = clone(trustedPlatformLock);
  trustedPlatformMismatch.packages[""].os = ["linux"];
  expectFailure(
    "trusted root os package-lock disagreement",
    () => validateContract(
      trustedPlatformPackage,
      trustedPlatformMismatch,
      inputPlatformPackage,
      inputPlatformLock,
    ),
    "trusted package and lock root must agree on os",
  );

  const developmentEngineKeys = ["cpu", "os", "libc", "runtime", "packageManager"];
  for (const key of developmentEngineKeys) {
    for (const [form, descriptor] of [
      ["object", { name: "mismatch", version: "1", onFail: "error" }],
      ["array", [{ name: "mismatch", version: "1", onFail: "error" }]],
    ]) {
      const packageMutation = clone(inputPackage);
      packageMutation.devEngines = { [key]: descriptor };
      expectFailure(
        `development-engine ${key} ${form} addition`,
        () => validateContract(trustedPackage, trustedLock, packageMutation, inputLock),
        "devEngines selector must equal the trusted selector",
      );
    }
  }
  for (const malformedValue of [null, "node", []]) {
    const packageMutation = clone(inputPackage);
    packageMutation.devEngines = malformedValue;
    expectFailure(
      `malformed development-engine top-level ${stableJson(malformedValue)}`,
      () => validateContract(trustedPackage, trustedLock, packageMutation, inputLock),
      "package.json.devEngines must be a JSON object",
    );
    const trustedPackageMutation = clone(trustedPackage);
    trustedPackageMutation.devEngines = malformedValue;
    expectFailure(
      `malformed trusted development-engine top-level ${stableJson(malformedValue)}`,
      () => validateContract(trustedPackageMutation, trustedLock, inputPackage, inputLock),
      "trusted package.json.devEngines must be a JSON object",
    );
  }
  const trustedDevelopmentEnginePackage = clone(trustedPackage);
  trustedDevelopmentEnginePackage.devEngines = {
    cpu: [
      { name: "x64", onFail: "error" },
      { name: "arm64", onFail: "warn" },
    ],
    os: { name: "win32", onFail: "warn" },
    libc: [{ name: "glibc", version: "2", onFail: "ignore" }],
    runtime: { name: "node", version: "24.18.0", onFail: "error" },
    packageManager: [{ name: "npm", version: "11.16.0", onFail: "error" }],
  };
  const inputDevelopmentEnginePackage = clone(inputPackage);
  inputDevelopmentEnginePackage.devEngines = clone(trustedDevelopmentEnginePackage.devEngines);
  validateContract(
    trustedDevelopmentEnginePackage,
    trustedLock,
    inputDevelopmentEnginePackage,
    inputLock,
  );
  for (const key of developmentEngineKeys) {
    const packageMutation = clone(inputDevelopmentEnginePackage);
    const descriptor = Array.isArray(packageMutation.devEngines[key])
      ? packageMutation.devEngines[key][0]
      : packageMutation.devEngines[key];
    descriptor.name = `${descriptor.name}-changed`;
    expectFailure(
      `development-engine ${key} name drift`,
      () => validateContract(
        trustedDevelopmentEnginePackage,
        trustedLock,
        packageMutation,
        inputLock,
      ),
      "devEngines selector must equal the trusted selector",
    );
    const deletionMutation = clone(inputDevelopmentEnginePackage);
    delete deletionMutation.devEngines[key];
    expectFailure(
      `development-engine ${key} deletion`,
      () => validateContract(
        trustedDevelopmentEnginePackage,
        trustedLock,
        deletionMutation,
        inputLock,
      ),
      "devEngines selector must equal the trusted selector",
    );
  }
  for (const [field, changedValue] of [
    ["version", "11.15.0"],
    ["onFail", "warn"],
  ]) {
    const packageMutation = clone(inputDevelopmentEnginePackage);
    packageMutation.devEngines.packageManager[0][field] = changedValue;
    expectFailure(
      `development-engine packageManager ${field} drift`,
      () => validateContract(
        trustedDevelopmentEnginePackage,
        trustedLock,
        packageMutation,
        inputLock,
      ),
      "devEngines selector must equal the trusted selector",
    );
  }
  const arrayOrderMutation = clone(inputDevelopmentEnginePackage);
  arrayOrderMutation.devEngines.cpu.reverse();
  expectFailure(
    "development-engine descriptor order drift",
    () => validateContract(
      trustedDevelopmentEnginePackage,
      trustedLock,
      arrayOrderMutation,
      inputLock,
    ),
    "devEngines selector must equal the trusted selector",
  );
  const developmentEngineDeletion = clone(inputDevelopmentEnginePackage);
  delete developmentEngineDeletion.devEngines;
  expectFailure(
    "development-engine selector deletion",
    () => validateContract(
      trustedDevelopmentEnginePackage,
      trustedLock,
      developmentEngineDeletion,
      inputLock,
    ),
    "devEngines selector must equal the trusted selector",
  );
  const trustedExtendedPackage = clone(trustedPackage);
  trustedExtendedPackage.volta = { extends: "./trusted-runtime-package.json" };
  const inputExtendedPackage = clone(inputPackage);
  inputExtendedPackage.volta = { extends: "./proposed-runtime-package.json" };
  expectFailure(
    "indirect Volta selector path drift",
    () => validateContract(
      trustedExtendedPackage,
      trustedLock,
      inputExtendedPackage,
      inputLock,
    ),
    "volta.extends selector must equal the trusted selector",
  );
  const trustedOverridePackage = clone(trustedPackage);
  trustedOverridePackage.overrides = { argparse: "1.0.10" };
  expectFailure(
    "trusted root override",
    () => validateContract(trustedOverridePackage, trustedLock, inputPackage, inputLock),
    "trusted package.json.overrides must remain absent",
  );
  expectFailure(
    "malformed JSON",
    () => parseJsonBytes(Buffer.from("{"), "fixture", 10),
    "valid JSON",
  );
  expectFailure(
    "byte-order mark",
    () => parseJsonBytes(Buffer.from([0xef, 0xbb, 0xbf, 0x7b, 0x7d]), "fixture", 10),
    "byte-order mark",
  );
  expectFailure(
    "invalid UTF-8",
    () => parseJsonBytes(Buffer.from([0xc3, 0x28]), "fixture", 10),
    "valid UTF-8",
  );
  expectFailure(
    "oversized input",
    () => parseJsonBytes(Buffer.from("{}"), "fixture", 1),
    "exceeds",
  );
  expectFailure(
    "non-blob entry",
    () => requireOrdinaryBlob(
      { mode: "120000", type: "blob", objectId: "a".repeat(40) },
      "package.json",
    ),
    "ordinary non-executable Git blob",
  );
  for (const path of FORBIDDEN_INSTALL_INPUTS) {
    expectFailure(
      `${path} addition`,
      () => requireAbsentEntry(
        { mode: "100644", type: "blob", objectId: "a".repeat(40) },
        path,
      ),
      "must remain absent",
    );
  }
  console.log("Parser manifest mutation self-tests passed.");
}

function main() {
  const options = parseArguments(process.argv.slice(2));
  const trustedRevision = resolveCommit(
    options.repositoryRoot,
    options.trustedRevision,
    "trusted revision",
  );
  const inputRevision = resolveCommit(
    options.repositoryRoot,
    options.inputRevision,
    "input revision",
  );
  for (const path of FORBIDDEN_INSTALL_INPUTS) {
    requirePathAbsent(options.repositoryRoot, trustedRevision, path);
    requirePathAbsent(options.repositoryRoot, inputRevision, path);
  }
  const trustedPackage = readJsonBlob(
    options.repositoryRoot,
    trustedRevision,
    "package.json",
    PACKAGE_MAXIMUM_BYTES,
  );
  const trustedLock = readJsonBlob(
    options.repositoryRoot,
    trustedRevision,
    "package-lock.json",
    LOCK_MAXIMUM_BYTES,
  );
  const inputPackage = readJsonBlob(
    options.repositoryRoot,
    inputRevision,
    "package.json",
    PACKAGE_MAXIMUM_BYTES,
  );
  const inputLock = readJsonBlob(
    options.repositoryRoot,
    inputRevision,
    "package-lock.json",
    LOCK_MAXIMUM_BYTES,
  );
  validateContract(trustedPackage, trustedLock, inputPackage, inputLock);
  console.log("Parser manifest contract passed.");
  if (options.selfTest) {
    runSelfTests();
  }
}

try {
  main();
} catch (error) {
  console.error(error instanceof Error ? error.message : String(error));
  process.exitCode = 1;
}
