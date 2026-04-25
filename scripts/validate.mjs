import { Quillmark, Document } from '@quillmark/wasm';
import { readFile, readdir, stat } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const __dirname = path.dirname(fileURLToPath(import.meta.url));
const QUIVER_DIR = path.resolve(__dirname, '..');
const QUILLS_DIR = path.join(QUIVER_DIR, 'quills');

async function walk(dir, base = dir, out = new Map()) {
  for (const entry of await readdir(dir, { withFileTypes: true })) {
    const full = path.join(dir, entry.name);
    if (entry.isDirectory()) {
      await walk(full, base, out);
    } else if (entry.isFile()) {
      const rel = path.relative(base, full).split(path.sep).join('/');
      out.set(rel, new Uint8Array(await readFile(full)));
    }
  }
  return out;
}

const engine = new Quillmark();
let failures = 0;

for (const name of (await readdir(QUILLS_DIR)).sort()) {
  const nameDir = path.join(QUILLS_DIR, name);
  if (!(await stat(nameDir)).isDirectory()) continue;
  for (const version of (await readdir(nameDir)).sort()) {
    const vDir = path.join(nameDir, version);
    if (!(await stat(vDir)).isDirectory()) continue;
    try {
      const tree = await walk(vDir);
      const quill = engine.quill(tree);
      const meta = quill.metadata;
      console.log(`ok  ${name}@${version} (backend=${quill.backendId}, files=${tree.size}, quill=${meta?.name}@${meta?.version})`);

      const examplePath = path.join(vDir, 'example.md');
      const md = await readFile(examplePath, 'utf8');
      const doc = Document.fromMarkdown(md);
      console.log(`    example parses (quillRef=${doc.quillRef}, warnings=${doc.warnings.length})`);
    } catch (err) {
      failures += 1;
      console.error(`fail ${name}@${version}:`, err.message ?? err);
    }
  }
}

if (failures > 0) process.exit(1);
console.log('\nAll quills loaded.');
