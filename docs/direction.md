# Direction

*From the author, 2026-10-26.* Relive the feeling of fluent Vim use: look at the
screen, see where you are and where you want to go, know the exact motions, then
execute them from muscle memory. Their example: move five lines, find a quote,
change the string inside it. This is for Vim users, initially those who use Vim
as the author does. The researched games did not capture that experience.

The game is free. The author's goals are to relive Vim, try Bend 2, gain
attention, and test the fastest possible AI iteration strategies. Bend is
chosen here; adopting it for later projects depends on what this teaches us.

## Candidate gameplay

The preferred direction is an old-school 2D RTS/wargame, with Dune, Command &
Conquer and Warcraft II as references. The author loves RTS and is already
building one; they do not particularly like platformers.

A textual/glyph world navigated in rows and columns with Vim motions, marks,
and as many familiar Vim interactions as possible. The cursor is a god hand:
editing might destroy parts of the world and kill enemies there; terrain
might regenerate. Summon troops. Actions might use bindings or a
Telescope-like picker. These are possibilities, not implemented rules.

An alternative is a codebase platformer, traversed through Vim motions. Its
objectives, failure condition and editing mechanics are unknown.

## Baseline architecture

- Pure Bend modules own the model and expose functions to JavaScript.
- Laws and proofs stay in Bend and are checked with `--verdict`.
- TypeScript renders the model on Canvas. The initial field is a plumbing
  check, not a chosen game mechanic or visual direction.
- Bun serves the page and loads Bend through the pinned official compiler.
- Nix pins the tools; just provides the common commands.

## Next discussion

Choose the first playable loop and map the author's actual Vim interactions
onto it. Decide what textual structures mean in the world, how commands target
them, and whether time continues during multi-key commands. No gameplay
implementation is included in this baseline.
