import type { BunPlugin } from "bun";

const loader = process.env.BEND_LOADER;
if (!loader) {
  throw new Error("BEND_LOADER is missing. Enter the development shell with nix develop.");
}

// Load the official source matching the pinned CLI release.
const { default: plugin } = await import(loader);
export default plugin as BunPlugin;
