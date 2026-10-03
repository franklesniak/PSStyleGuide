import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { lstatSync } from 'node:fs';

if (process.env.HUSKY === '0') {
  process.exit(0);
}

const workflowsDir = dirname(fileURLToPath(import.meta.url));
process.chdir(resolve(workflowsDir, '../..'));
try {
  lstatSync('.git');
} catch (error) {
  if (error.code !== 'ENOENT') throw error;
  console.log('No .git entry in this source directory; no Git hook was installed.');
  process.exit(0);
}

const { default: husky } = await import('husky');

const message = husky();

if (message) {
  console.error(message);
  process.exit(1);
}
