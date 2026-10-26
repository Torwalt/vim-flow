default:
    @just --list

# Install the locked JS development dependencies.
setup:
    bun install --frozen-lockfile

# Run the local page with hot reload.
dev:
    bun run dev

# Check every law with Bend's formalized kernel.
proof:
    bend PROOF.bend --verdict

# Check the TypeScript side of the Bend boundary and browser shell.
typecheck:
    bun run typecheck

# Exercise the actual Bend-to-JavaScript exports.
test:
    bun run test

# Check both the development server and static bundle in headless Chromium.
test-browser: build
    bun run test:browser

# Produce a static directory ready to serve.
build:
    bend index.html -o dist

# Serve the production bundle on localhost:4173.
preview: build
    bun run preview

# Run the baseline checks and make a production bundle.
verify: proof typecheck test test-browser
    benchpress lint

# Check the Nix proof and static-site derivations.
check-nix:
    nix flake check

# Format the flake.
fmt:
    nixfmt flake.nix nix/*.nix

# Show the pinned tool versions without starting an agent session.
doctor:
    bend version
    lean --version
    bun --version
    tsc --version
    just --version
    codex --version
    claude --version
    ploopy --version
    benchpress --version
