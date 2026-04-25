# airmark-quiver

A [Quillmark](https://github.com/nibsbin/quillmark) Source Quiver of Air Force
and DAF official-document Quills, sourced from
[tonguetoquill-collection](https://github.com/nibsbin/tonguetoquill-collection)
and aligned to the current Quillmark spec.

## Contents

| Quill        | Version | Description                                                                       |
|--------------|---------|-----------------------------------------------------------------------------------|
| `usaf_memo`  | 0.2.0   | USAF / DAF Official Memorandum (AFH 33-337)                                       |
| `af4141`     | 0.1.0   | AF Form 4141 — Individual's Record of Duties and Experience (Ground Environment)  |
| `daf1206`    | 0.1.0   | DAF Form 1206 — Nomination for Award                                              |
| `daf4392`    | 0.1.0   | DAF Form 4392 — Pre-Departure Safety Briefing (Page 2)                            |

## Install

```bash
npm install airmark-quiver @quillmark/quiver@0.1.1 @quillmark/wasm@0.59.0
```

## Usage

### Load via the convenience helper

```ts
import { Quillmark, Document } from '@quillmark/wasm';
import { QuiverRegistry } from '@quillmark/quiver/node';
import { loadAirmarkQuiver } from 'airmark-quiver';

const engine = new Quillmark();
const quiver = await loadAirmarkQuiver();
const registry = new QuiverRegistry({ engine, quivers: [quiver] });

const doc = Document.fromMarkdown(`---
QUILL: usaf_memo@0.2
memo_for: ["ORG/SYMBOL"]
memo_from: ["ORG/SYMBOL", "Organization Name", "123 Street Ave", "City ST 12345-6789"]
subject: Hello Quillmark
signature_block: ["FIRST M. LAST, Rank, USAF", "Duty Title"]
---

Body of the memo.`);

const canonicalRef = await registry.resolve(doc.quillRef);
const quill = await registry.getQuill(canonicalRef);
const { artifacts } = quill.render(doc, { format: 'pdf' });
```

### Load from the exported directory

```ts
import { Quiver } from '@quillmark/quiver/node';
import { QUIVER_DIR } from 'airmark-quiver';

const quiver = await Quiver.fromSourceDir(QUIVER_DIR);
```

## Layout

This package is a [Source Quiver](https://www.npmjs.com/package/@quillmark/quiver)
conforming to the canonical layout:

```
Quiver.yaml
quills/
  <name>/
    <x.y.z>/
      Quill.yaml
      plate.typ
      example.md
      assets/
      packages/
```

## License

Apache-2.0. Individual Quills carry their own licensing terms; see the
`packages/` directory inside each Quill for upstream font and template licenses.
