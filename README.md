# vim-flow

This project's workflow research asks whether Bend's laws and proofs improve
AI code quality and/or reduce total token cost by limiting erroneous approaches.
See [measured findings and planning rules](docs/workflows/bend-planning.md) and
the ordinary TypeScript comparison at [vim-flow-ts](https://github.com/Torwalt/vim-flow-ts).

A free browser game about reliving fluent Vim use, and an experiment in Bend 2
and fast AI iteration. Currently a playable navigation pass: the proved Bend
model draws a seeded 40x20 field on Canvas, with keyboard navigation, counts,
pending commands, proof checking and a working development toolchain.

## Start

```sh
nix develop
just setup
just dev
```

Open <http://localhost:3000>. `just` lists the available commands.

The shell includes Bend 2.0.39, Lean 4.34.0, Bun, TypeScript, Clang, just, Codex, Claude Code,
OpenCode, tmux, direnv, Ploopy and Benchpress. OpenCode uses Ploopy's pinned package.
Linux also includes Chromium for browser checks. The
flake and JS lockfiles pin dependencies. Existing agent authentication is used;
this project does not create credentials or start agent sessions.

Optional direnv users can run `direnv allow` to use `.envrc`.

Ploopy starts plans in new windows of the current tmux session. Run it from
inside tmux; it creates and prepares the plan's worktree automatically.
Worktree setup links the main checkout's ignored `.env`, runs `direnv allow`,
and installs dependencies with `direnv exec . just setup`. Ploopy checks also
run through direnv to load the flake and local API credentials.
Its repository skills live under `.agents/skills/`; refresh them with
`ploopy skills` after updating Ploopy.

## Verify

```sh
just doctor       # tool versions
just verify       # proofs, TypeScript, runtime tests, browser navigation checks, production build
just check-nix    # sandboxed proof check and static-site build
nix build         # static page in result/
```

Browser checks use the flake's Chromium on Linux. On macOS, run
`bunx playwright install chromium` once; the shell prevents browser downloads
during dependency installation.

Both the dev server and the static production bundle are checked in Chromium.
Browser checks start their own servers on OS-assigned ports, so verification
can run in multiple worktrees while local development and preview servers run.
Browser tests import `test` and `expect` from `tests/browser/test.ts` to use
the server URL assigned to their project.
Screenshots land under `test-results/`. `just preview` serves the production
bundle at <http://localhost:4173>.

`just proof` runs `bend PROOF.bend --verdict`, including the formalized BendTT
kernel. `just contract-complete` checks that the full navigation contract is
imported and proved. The proofs cover the model, axis, word, line, find and
input obligations; they make no claim about the browser renderer or
code-generation correctness.

## Layout

- `src/core/scene.bend`: pure Bend scene and exports.
- `src/core/navigation.bend`, `src/core/navigation.d.bend.ts`: the navigation
  facade used by the browser and its TypeScript boundary.
- `spec/navigation/`: the agreed navigation contract.
- `LAWS.bend`, `PROOF.bend`: agreed properties and their proofs.
- `src/web/`: Canvas presentation, key capture and pending-state display.
- `tools/bend-plugin.ts`: loads the official compiler from the pinned package,
  using `BEND_LOADER` supplied by the shell. The source matches the CLI release.
- `tests/`: runtime bridge and real-browser navigation checks.
- `nix/`: pinned Lean toolchain and a prebuilt BendTT kernel. Proof checks use
  `BENDTT` from the shell rather than compiling into a home-directory cache.
- `docs/direction.md`: the author's intent and unresolved gameplay questions.
- `docs/workbench/`: the project's Benchpress workbench.

`just build` writes a static page and its bundled assets to `dist/`. Serve that
directory with any static host. There is no application server or runtime
dependency on Nix, Bun, or a Bend installation in the player's browser.

## References

- [Bend 2](https://github.com/bendlang/bend)
- [Language and proof guide](https://github.com/bendlang/bend/blob/v2.0.39/guide/GUIDE.md)
- [Official browser integration example](https://github.com/bendlang/bend/tree/v2.0.39/demos/app_win_is_bug_2d)
