import { spawnSync } from 'node:child_process';
import { dirname, resolve, sep } from 'node:path';
import { fileURLToPath } from 'node:url';

const requiredNodeMajor = 20;
const currentNodeMajor = Number(process.versions.node.split('.')[0]);

if (!Number.isInteger(currentNodeMajor) || currentNodeMajor < requiredNodeMajor) {
  console.error('pre-commit: Node.js 20 or newer is required to lint staged Markdown.');
  console.error(`Current version: ${process.version || 'unknown'}`);
  console.error('If you use a Node version manager with a GUI Git client, add its initialization to');
  console.error('~/.config/husky/init.sh, which Husky sources before running hooks.');
  console.error('To bypass this one commit only, use: git commit --no-verify');
  process.exit(1);
}

const workflowsDir = dirname(fileURLToPath(import.meta.url));
const repoRoot = resolve(workflowsDir, '../..');
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
const toAbsolutePosixPath = (repoRelativePath) => resolve(repoRoot, repoRelativePath).split(sep).join('/');

let stagedMarkdownPaths;

try {
  // Git pathspec wildcards match across directory separators, unlike shell globs,
  // so the `*.md` pathspec selects staged Markdown in every subdirectory (e.g.
  // docs/ISSUE_EVALUATION_PROMPT.md, samples/*.md), not just the repository root.
  // See https://git-scm.com/docs/gitglossary (def_pathspec).
  stagedMarkdownPaths = parseNulDelimitedPaths(
    runGit(['diff', '--cached', '--name-only', '--diff-filter=ACMR', '-z', '--', '*.md'])
  );
} catch (error) {
  console.error(error);
  console.error('pre-commit: Failed to inspect staged Markdown files.');
  process.exit(2);
}

if (stagedMarkdownPaths.length === 0) {
  process.exit(0);
}

const stagedMarkdownByAbsolutePosixPath = {};

try {
  for (const repoRelativePath of stagedMarkdownPaths) {
    stagedMarkdownByAbsolutePosixPath[toAbsolutePosixPath(repoRelativePath)] = runGit(['show', `:${repoRelativePath}`]);
  }
} catch (error) {
  console.error(error);
  console.error('pre-commit: Failed to read staged Markdown content from Git.');
  process.exit(2);
}

let exitCode;

try {
  const { main: markdownlintCli2 } = await import('markdownlint-cli2');
  exitCode = await markdownlintCli2({
    directory: repoRoot,
    argv: ['--config', '.github/workflows/.markdownlint.jsonc'],
    nonFileContents: stagedMarkdownByAbsolutePosixPath,
    logMessage: console.log,
    logError: console.error
  });
} catch (error) {
  console.error(error);
  console.error('pre-commit: Markdown lint tooling failed to run.');
  console.error('Try reinstalling dev dependencies: npm --prefix .github/workflows ci');
  process.exit(2);
}

if (exitCode !== 0) {
  console.error('');
  console.error('pre-commit: Markdown lint failed for staged Markdown.');
  console.error('To check all Markdown files, run: npm --prefix .github/workflows run lint:md');
}

process.exitCode = exitCode;
