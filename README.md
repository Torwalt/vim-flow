# vim-flow

A free browser game about reliving fluent Vim use, and an experiment in Bend 2
and fast AI iteration. Currently a baseline: a Bend-generated glyph field on
Canvas, with proof checking and a working development toolchain.

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
just verify       # proofs, TypeScript, bridge test, browser smoke, production build
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
kernel. The initial law proves that every baseline cell has exactly one glyph
character. This establishes the proof pipeline; it makes no claim about future
gameplay, the browser renderer, or code-generation correctness.

## Layout

- `src/core/scene.bend`: pure Bend scene and exports.
- `LAWS.bend`, `PROOF.bend`: agreed properties and their proofs.
- `src/core/scene.d.bend.ts`: explicit TypeScript declaration of those exports.
- `src/web/`: Canvas presentation.
- `tools/bend-plugin.ts`: loads the official compiler from the pinned package,
  using `BEND_LOADER` supplied by the shell. The source matches the CLI release.
- `tests/`: runtime bridge and real-browser smoke checks.
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
