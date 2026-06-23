import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

if (
  process.env.CI === 'true' ||
  process.env.HUSKY === '0' ||
  process.env.NODE_ENV === 'production'
) {
  process.exit(0);
}

const { default: husky } = await import('husky');
const workflowsDir = dirname(fileURLToPath(import.meta.url));

process.chdir(resolve(workflowsDir, '../..'));

const message = husky();

if (message) {
  console.error(message);
  process.exit(1);
}
