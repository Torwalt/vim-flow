# vim-flow

A free browser game for experienced Vim users who miss fluent manual code
navigation and editing. Bend 2 is the game language; TypeScript and Canvas are
the browser shell. This repository currently contains only the verified baseline.

Read `docs/direction.md` for the author's intent. Gameplay is still to discuss.

- Enter `nix develop`; run `just setup` once, then `just dev`.
- Before writing Bend, run `bend version` and read all of `bend guide`.
  Read `bend guide shaders` before parallel or graphical Bend work.
- Keep game rules, Vim interpretation and world updates in `src/core/` as pure
  Bend functions. `src/web/` captures input and draws state; it does not decide
  game outcomes. Do not introduce foreign or unsafe code into the proved core.
- `LAWS.bend` holds the agreed requirements. Do not weaken them to make a proof
  pass. Proof signatures, equivalent law formulations and shared helpers may
  evolve under the active plan's contract-revision rules; record the evidence
  and preserve behavior and obligation coverage. `PROOF.bend` proves them.
  Run `just proof` after changing the core.
- `src/core/scene.d.bend.ts` describes the JS boundary. Update the declarations
  alongside exports and verify their runtime representation with `just test`.
- Run `just verify` before finishing changes. Run `just check-nix` after flake
  changes. `flake.lock` and `bun.lock` are committed; generated output is not.
- Keep design questions and work through the benchpress skill in
  `docs/workbench/`; `NEXT.md` is the author's order. Run `benchpress lint`.
- Preserve Git identity. Do not put AI attribution in commit messages.
