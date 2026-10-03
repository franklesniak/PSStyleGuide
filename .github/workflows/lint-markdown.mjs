import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import { runBounded } from './NpmTools.mjs';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../..');

export function normalizeLintStatus(status) { return status === 0 || status === 1 ? status : 2; }

export async function lintMarkdownFiles(root = repoRoot, run = runBounded) {
  const required = JSON.parse(fs.readFileSync(path.join(root, 'package.json'), 'utf8')).engines?.node;
  if (!/^(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)\.(?:0|[1-9]\d*)$/u.test(required ?? '') || required !== process.versions.node) {
    throw new Error(`Markdown lint requires declared Node ${required ?? 'version'}; observed ${process.versions.node}.`);
  }
  const child = path.join(root, '.github/workflows/lint-nested-markdown.js');
  if (!fs.statSync(child).isFile()) throw new Error('Markdown lint requires the regular outer child script.');
  const result = run(process.execPath, [child, '--outer'], { cwd: root });
  if (result.stdout?.length) process.stdout.write(result.stdout);
  if (result.stderr?.length) process.stderr.write(result.stderr);
  const status = normalizeLintStatus(result.status);
  if (status === 2) console.error(`Markdown lint tooling failed (native exit ${result.status}).`);
  return status;
}

if (process.argv[1] && path.resolve(process.argv[1]) === fileURLToPath(import.meta.url)) {
  try {
    if (process.argv.length !== 2) throw new Error('Usage: node .github/workflows/lint-markdown.mjs');
    process.exitCode = await lintMarkdownFiles();
  } catch (error) {
    console.error(`Markdown lint tooling: ${error.message}`);
    process.exitCode = 2;
  }
}
