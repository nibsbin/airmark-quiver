import type { Quiver } from '@quillmark/quiver/node';

/**
 * Absolute path to the root of this Source Quiver (contains `Quiver.yaml`).
 */
export declare const QUIVER_DIR: string;

/**
 * Absolute path to the `quills/` directory inside this Quiver.
 */
export declare const QUILLS_DIR: string;

/**
 * Convenience loader that resolves this Source Quiver through `@quillmark/quiver/node`.
 */
export declare function loadAirmarkQuiver(): Promise<Quiver>;
