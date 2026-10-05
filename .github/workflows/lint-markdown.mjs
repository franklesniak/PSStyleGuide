import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { runBounded } from './NpmTools.mjs';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');

export function normalizeLintStatus(status) { return status === 0 || status === 1 ? status : 2; }

export async function lintMarkdownFiles(root = repoRoot, run = runBounded) {
  const canonicalRoot = fs.realpathSync(root);
  const manifest = path.join(root, 'package.json');
  const manifestLeaf = fs.lstatSync(manifest);
  if (manifestLeaf.isSymbolicLink() || !manifestLeaf.isFile() || manifestLeaf.size > 1024 * 1024) {
    throw new Error('Markdown lint requires a non-symlink regular package manifest of at most 1 MiB.');
  }
  const canonicalManifest = fs.realpathSync(manifest);
  const manifestRelative = path.relative(canonicalRoot, canonicalManifest);
  if (manifestRelative === '..' || manifestRelative.startsWith(`..${path.sep}`) || path.isAbsolute(manifestRelative)) {
    throw new Error('Markdown lint package manifest resolves outside the repository.');
  }
  const required = JSON.parse(fs.readFileSync(canonicalManifest, 'utf8')).engines?.node;
  if (!/^(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)$/u.test(required ?? '') || required !== process.versions.node) {
    throw new Error(`Markdown lint requires declared Node ${required ?? 'version'}; observed ${process.versions.node}.`);
  }
  const child = path.join(root, '.github/workflows/lint-nested-markdown.js');
  const leaf = fs.lstatSync(child);
  if (leaf.isSymbolicLink() || !leaf.isFile()) throw new Error('Markdown lint requires a non-symlink regular outer child script.');
  const canonicalChild = fs.realpathSync(child);
  const relative = path.relative(canonicalRoot, canonicalChild);
  if (relative === '..' || relative.startsWith(`..${path.sep}`) || path.isAbsolute(relative)) {
    throw new Error('Markdown lint outer child resolves outside the repository.');
  }
  const result = run(process.execPath, [canonicalChild, '--outer'], { cwd: root, timeout: 120000, maxBuffer: 2 * 1024 * 1024 });
  if (result.stdout?.length) process.stdout.write(result.stdout);
  if (result.stderr?.length) process.stderr.write(result.stderr);
  const status = normalizeLintStatus(result.status);
  if (status === 2) console.error(`Markdown lint tooling failed (native exit ${result.status}).`);
  return status;
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
  try {
    if (process.argv.length !== 2) throw new Error('Usage: node .github/workflows/lint-markdown.mjs');
    process.exitCode = await lintMarkdownFiles();
  } catch (error) {
    console.error(`Markdown lint tooling: ${error.message}`);
    process.exitCode = 2;
  }
}
