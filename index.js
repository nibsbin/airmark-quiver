import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

/**
 * Absolute path to the root of this Source Quiver (contains `Quiver.yaml`).
 */
export const QUIVER_DIR = __dirname;

/**
 * Absolute path to the `quills/` directory inside this Quiver.
 */
export const QUILLS_DIR = path.join(__dirname, 'quills');

/**
 * Convenience loader that resolves this Source Quiver through `@quillmark/quiver/node`.
 *
 * ```ts
 * import { loadAirmarkQuiver } from '@airmark/quiver';
 * const quiver = await loadAirmarkQuiver();
 * ```
 */
export async function loadAirmarkQuiver() {
  const { Quiver } = await import('@quillmark/quiver/node');
  return Quiver.fromSourceDir(QUIVER_DIR);
}
