import { Quillmark, Document } from '@quillmark/wasm';
import { renderQuiverSamples } from '@quillmark/quiver/preview';

await renderQuiverSamples(import.meta.url, {
  engine: new Quillmark(),
  Document,
});
