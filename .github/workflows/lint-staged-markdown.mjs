import { spawnSync } from 'node:child_process';
import { readFileSync } from 'node:fs';
import { createRequire } from 'node:module';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const workflowsDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(workflowsDir, '../..');
const rootPackagePath = resolve(repoRoot, 'package.json');
const exactSemanticVersionPattern = /^(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)$/u;
const exitStatus = Object.freeze({
  success: 0,
  lintFailure: 1,
  toolingFailure: 2
});
const normalizeMarkdownlintExitCode = (value) =>
  value === exitStatus.success || value === exitStatus.lintFailure
    ? value
    : exitStatus.toolingFailure;

let rootPackage;

try {
  rootPackage = JSON.parse(readFileSync(rootPackagePath, 'utf8'));
} catch {
  console.error('pre-commit: Failed to read the root package.json Node.js selector.');
  process.exit(exitStatus.toolingFailure);
}

const requiredNodeVersion = rootPackage?.engines?.node;
const currentNodeVersion = process.versions.node;

if (typeof requiredNodeVersion !== 'string' || !exactSemanticVersionPattern.test(requiredNodeVersion)) {
  console.error('pre-commit: Root package.json must declare engines.node as one exact semantic version.');
  process.exit(exitStatus.toolingFailure);
}

if (currentNodeVersion !== requiredNodeVersion) {
  console.error(`pre-commit: Node.js ${requiredNodeVersion} is required to lint staged Markdown.`);
  console.error(`Current version: ${process.version || 'unknown'}`);
  console.error('If you use a Node version manager with a GUI Git client, add its initialization to');
  console.error('~/.config/husky/init.sh, which Husky sources before running hooks.');
  console.error('To bypass this one commit only, use: git commit --no-verify');
  process.exit(exitStatus.toolingFailure);
}

const maxBuffer = 100 * 1024 * 1024;

const runGit = (args) => {
  const result = spawnSync('git', args, {
    cwd: repoRoot,
    encoding: 'utf8',
    maxBuffer,
    windowsHide: true
  });

  if (result.error) {
    throw result.error;
  }

  if (result.status !== 0) {
    throw new Error((result.stderr || '').trim() || `git ${args[0]} failed with exit code ${result.status}`);
  }

  return result.stdout;
};

const parseNulDelimitedPaths = (value) => value.split('\0').filter(Boolean);

const stagedMarkdownPathspecs = Object.freeze(['*.md', '*.mdc']);
let stagedMarkdownPaths;

try {
  // Git pathspec wildcards match across directory separators, unlike shell globs,
  // so these pathspecs select staged Markdown and Cursor rules in every
  // subdirectory (including hidden .cursor/rules paths), not just the root.
  // See https://git-scm.com/docs/gitglossary (def_pathspec).
  stagedMarkdownPaths = parseNulDelimitedPaths(
    runGit([
      'diff', '--cached', '--name-only', '--diff-filter=ACMR', '-z', '--',
      ...stagedMarkdownPathspecs
    ])
  );
} catch (error) {
  console.error(error);
  console.error('pre-commit: Failed to inspect staged Markdown files.');
  process.exit(exitStatus.toolingFailure);
}

if (stagedMarkdownPaths.length === 0) {
  process.exit(exitStatus.success);
}

const stagedMarkdownInputs = [];

try {
  for (const repoRelativePath of stagedMarkdownPaths) {
    const content = runGit(['show', `:${repoRelativePath}`]);
    stagedMarkdownInputs.push({ filePath: repoRelativePath, content });
  }
} catch (error) {
  console.error(error);
  console.error('pre-commit: Failed to read staged Markdown content from Git.');
  process.exit(exitStatus.toolingFailure);
}

let exitCode;
let markdownlintConfig;

try {
  const require = createRequire(import.meta.url);
  const { lintOuterMarkdownContents, loadMarkdownlintConfig } = require('./lint-nested-markdown.js');
  markdownlintConfig = loadMarkdownlintConfig(repoRoot);
  const markdownlintExitCode = await lintOuterMarkdownContents(repoRoot, stagedMarkdownInputs, markdownlintConfig);
  exitCode = normalizeMarkdownlintExitCode(markdownlintExitCode);
  if (exitCode === exitStatus.toolingFailure) {
    console.error('pre-commit: Markdown lint tooling returned an unexpected exit status.');
    console.error('Rebuild the locked tools: node .github/workflows/NpmTools.mjs install');
  }
} catch (error) {
  console.error(error);
  console.error('pre-commit: Markdown lint tooling failed to run.');
  console.error('Rebuild the locked tools: node .github/workflows/NpmTools.mjs install');
  process.exit(exitStatus.toolingFailure);
}

if (exitCode === exitStatus.lintFailure) {
  console.error('');
  console.error('pre-commit: Markdown lint failed for staged Markdown.');
  console.error('To check all Markdown files, run: npm --prefix .github/workflows run lint:md');
} else if (exitCode === exitStatus.success) {
  try {
    const require = createRequire(import.meta.url);
    const {
      displayResults,
      lintNestedMarkdownContents
    } = require('./lint-nested-markdown.js');
    const { totalBlocks, allResults } = lintNestedMarkdownContents(
      stagedMarkdownInputs,
      markdownlintConfig,
      console.log
    );
    console.log(`\nTotal nested Markdown blocks found: ${totalBlocks}\n`);
    if (displayResults(allResults)) {
      console.error('pre-commit: Nested Markdown lint failed for staged Markdown.');
      console.error('To check all Markdown files, run: npm --prefix .github/workflows run lint:md:nested');
      exitCode = exitStatus.lintFailure;
    }
  } catch (error) {
    console.error(error);
    console.error('pre-commit: Nested Markdown lint tooling failed to run.');
    console.error('Rebuild the locked tools: node .github/workflows/NpmTools.mjs install');
    exitCode = exitStatus.toolingFailure;
  }
}

process.exitCode = exitCode;
