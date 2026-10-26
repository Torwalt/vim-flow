# Navigation as a law-driven implementation experiment

Status: authority, written 2026-10-26 against `04e43bf`.

## 1. Decisions settled with the author (2026-10-26)

The author approved the movement-law approach and initial laws, and expanded the
scope to counts and additional navigation without editing. The experiment must
minimize production code authored before execution: write the laws first, then
let a simpler model choose representations, implement and prove them. Measure
where this workflow succeeds and where implementation forces specification or
model changes. The executor model will be selected later; prepare the pass but
do not start it now.

The concrete scope and policies below are engineering choices within that
authorization, not additional quotations or individually negotiated decisions.
This authority and the frozen Bend contract are the complete handoff.

## 2. Scope and exact behavior

Use the existing 40-column, 20-row field. Positions are zero-based, row-major
indices 0 through 799; row = position / 40, column = position modulo 40. Rows
are full-width text, including padding spaces. Every cell is navigable. A dot
is punctuation, not blank terrain. ASCII 32 through 126 is the supported cell
domain, with a literal space as the only blank. There are no zero-length lines,
tabs, Unicode display-width rules, wrapping, collision, time or editing.

| Input | Destination |
| --- | --- |
| `[n]h/j/k/l` | n cells on the corresponding axis, clamped at that edge |
| `[n]w/W` | Repeat n times: nearest word/WORD start strictly after cursor |
| `[n]b/B` | Repeat n times: nearest word/WORD start strictly before cursor |
| `[n]e/E` | Repeat n times: nearest word/WORD end strictly after cursor |
| `0` | Column zero of current row, when no count is pending |
| `[n]^` | First non-space of current row; count ignored |
| `[n]$` | Last column of current row + n - 1, clamped at last row |
| `gg`, `G` | First/last row, at its first non-space |
| `[n]gg`, `[n]G` | Row n - 1 clamped to the field, at its first non-space |
| `[n]f{char}`, `[n]F{char}` | nth occurrence strictly right/left on current row |
| Escape | Clear pending count/find/g prefix, preserve cursor and field |

Default count is one for relative movements. For gg/G, zero internally means
the absence of an explicit count. On a blank row first-non-space falls back to
column zero. Without a later candidate w/W/e/E go to the final cell; without an
earlier candidate b/B go to the first cell. These are intentional grid boundary
rules. `$` clamps even when its requested row exceeds the field; we do not model
Vim's configurable error behavior. Failure to find the nth f/F occurrence
preserves the original cursor completely, rather than keeping a partial find.

A small word is a run of ASCII letters/digits/underscore or a run of other
non-space punctuation. A WORD is any non-space run. Row boundaries always split
runs. The fixed padded grid differs from an editor buffer with variable-length
lines and empty lines. [Vim reference](https://vimhelp.org/motion.txt.html).

Counts start with 1-9; subsequent digits include zero. Count entry does not
move. Counts saturate at 9999, keeping JS values exact and bounded instead of
wrapping on a long digit sequence. Every completed motion clears the count.
This cap is an explicit policy choice, recorded for the experiment.

Normal input has four observable grammar states: Normal (with optional count),
FindRight, FindLeft, Go. These are command parsing states, not Insert or Visual
mode. f/F consumes the next printable character literally, including a digit,
space, motion key or shifted character. A printable character other than g
after g cancels and is consumed, without reprocessing. Unsupported printable
characters in Normal clear the count and otherwise do nothing. Nonprintable
characters, modifier-only events and other non-character keys leave state
unchanged. Ctrl/Alt/Meta chords leave state unchanged even during a prefix.
Escape without those modifiers cancels. Uppercase is preserved; H/J/K/L do not
execute h/j/k/l. Key repeat is ordinary repeated key input. Browser blur sends
Escape to avoid a stranded prefix; composition events are ignored until the
browser supplies a committed logical character.

## 3. Smallest model authored before execution

`spec/navigation/model.bend` declares Field and State as abstract Data-kinded
laws. The executor fills these with its chosen types through paired definitions
in `src/core/`; they are not empty datatypes or assumed axioms. It also fills
the field factory/observations, pack/view, initial state and motion/step API
declarations. No storage container, rope, grid array, cursor implementation,
movement algorithm or input implementation is provided ahead of the run.

The unavoidable commitments are observable: Mode, View (field, position, mode),
and Input (case-preserving character plus blocked-modifier flag, Escape plus
flag, or Other). View is an observation/transfer object, not a mandated State
representation. The String returned by contents is an observation, not a
mandated Field representation. pack/view roundtrip makes every valid observable state
constructible; field(text) plus its cell laws covers arbitrary printable scenes
and prevents a singleton hard-coded field from satisfying the contract.

The factory truncates at 800 characters, pads missing cells with spaces, and
replaces unsupported characters with spaces. Observed contents is exactly 800
printable characters. Cell reads outside the field return space. The seed is
four specified 40-character rows followed by blank rows, beginning with
`alpha beta  foo_bar ++ 42 "quote"`; initial cursor is zero, Normal with no count.
Calling initial again resets deterministically; no separate reset command is
required.

There are 13 abstract declarations (two types and eleven callable operations)
and 50 semantic obligations. Spec definitions are character classification,
observations, arithmetic, candidate/rank predicates and relational selection
conditions; they do not return a word/find/line movement destination. They are
real specification-authoring work and must be counted as such. Typechecking
them is not evidence that the contracts are satisfiable or complete.

## 4. Contract ownership and proof activation

`spec/navigation/ALL.bend` is the entire frozen contract. `manifest.json` fixes
the bytes of all seven Bend specification modules. Never edit those files,
their manifest, this authority, or the contract audit tool during execution.
An implementation/model conflict is evidence for the experiment: stop with a
specific counterexample or checker limitation. Do not silently narrow the
domain, change a law, add unsafe code/foreign code, or change a hash.

At handoff the full contract elaborates and reports exactly 63 open declarations.
`just contract-pending` verifies that diagnostic, explicitly as an OPEN result.
The baseline `just proof` remains green and covers only activated obligations.
This distinction must remain visible in reports.

Each core unit activates its unchanged module by adding an import to root
`LAWS.bend`, and supplies both its executable declarations and proofs through
the root `PROOF.bend` import graph. Previously activated modules remain active.
The cumulative order is model, axis, words, lines, find, input. Modules may
import dependencies: already filled declarations resolve canonically across
imports. Use `def Contract.name(...)` to fill an imported law, as the baseline
does with Laws.one_character_per_cell. Runtime definitions belong in src/core;
proof bodies belong in PROOF.bend or imported proof-only modules.

The final unit imports `./spec/navigation/ALL.bend as Navigation` in LAWS.bend.
`just contract-complete` checks frozen bytes, that full import, and the complete
kernel verdict. Passing only selected per-module proofs is not completion.
Never count an unfinished future law as proved or move it out of the manifest.

Private helper types, storage, algorithms and auxiliary lemmas are executor
choices. Core executable bodies may use Base and the filled contract APIs, not
the specification's candidate/rank/selection helpers as a runtime oracle. The
seed text constant is allowed. Proofs may use all specification predicates.
This keeps specification work visible without shipping it as the implementation.

## 5. Architecture and runtime boundary

Keep every rule, parser decision and transition pure in src/core. TypeScript
captures input, converts event.key to a logical character without lowercasing,
reports Ctrl/Alt/Meta as blocked, and draws the observed Bend state. It never
computes destinations, accumulates counts, handles find state or decides which
printable commands are supported. Shift alone and other non-character keys
become Other. A non-single-character string is not a glyph; account for JS
code points when constructing Char and let Bend reject unsupported characters.

Expose a stable browser facade (suggested src/core/navigation.bend) with
initial, step, observations and dimensions as needed. State and Field can be
opaque in TypeScript; do not claim their private runtime shapes. Add matching
`.d.bend.ts` declarations beside every JS-imported Bend entry point and test
the actual representation through the pinned loader. Keep scene's existing
boundary truthful; update its declarations and proof if its Cell changes.

Because the contract modules contain open semantic laws as well as API
declarations, a runtime entry point must assemble the filled proofs too. Use
separate implementation modules under src/core which PROOF.bend imports; the
browser facade imports PROOF.bend and the contract APIs and delegates to the
filled executable definitions. PROOF.bend must not import that facade, avoiding
an import cycle. Proofs stay compile-time evidence, with no runtime transition
logic in the facade. This assembly pattern was checked with an isolated toy
contract before the handoff. An implementation module imported alone before
proof assembly is expected to contain open claims; the full entry point is the
gate. Do not bypass those claims to make a browser bundle compile.

Draw a distinct cursor overlay without modifying the field character. Provide
a visible cursor row/column and pending command indicator driven by Bend's
View. Initial scene must be the contracted seed. Keep browser focus usable and
prevent normal page scrolling for handled game keystrokes while the game owns
focus. Verify cursor pixels as well as displayed state; a data attribute alone
does not show that Canvas drew the cursor. No new game mechanics or editing.

## 6. Verification and experiment evidence

Each unit runs just proof and just verify under nix develop. No flake changes
are expected; if made, run just check-nix. Contract integrity is part of verify.
Keep unit boundaries green. Fresh Ploopy worktrees run locked dependency setup
through .ploopy.toml; no executor model is configured and automatic stronger
rescue is disabled. The author chooses a model when starting the run.

Preflight encountered kernel normalization fuel exhaustion when directly
evaluating a concrete saturated count of 9999. The compiled count examples
pass, and the contract elaborates; its universal proofs are still open. Prefer
symbolic arithmetic lemmas to large concrete reflexivity reductions, and report
a kernel limitation if it prevents the required verdict. The find rank predicate
already limits its counting domain to one row to avoid needless normalization.

Add focused boundary tests that invoke the real exported functions on varied
fields, including all-space text, punctuation adjacent to words, row boundaries,
repeated/missing find targets and singleton WORDs. Test count grammar (10j,
99999l, 0, 2W, count clearing), lowercase/uppercase distinction, literal pending
targets, Escape and modifier handling. Use worked examples derived independently
from the contract, not expected values computed by the implementation or its
specification predicate. Formal proofs remain the universal checks.

Before browser integration, the unchanged baseline browser suite is sufficient.
After integration, exercise real keystrokes in development and production,
including 5j, Shift+w, 2fx, F, gg, 3G, Escape and blocked chords. Check visible
cursor changes, text preservation and browser errors. Do not stop unrelated
servers if test ports are occupied; report the conflict or choose isolated
test ports without weakening assertions.

Record outcomes in `docs/experiments/navigation-laws.md`, and append a compact
row for each unit: commit, actual harness/model, attempts, checks, proof issues,
representation choices and specification interventions. Use Ploopy's history
for timing/cost where available; mark unavailable metrics as unavailable. Never
fabricate zero interventions or zero cost. Distinguish checker rejection of a
proof from a real inconsistency or under-specification in the laws. Record
whether datatype/observation boundaries needed revision and which extra skill
instructions the evidence suggests. Do not write a new generic skill merely
because one might be useful.

Last unit updates durable experiment findings and the direction document to
describe what actually runs, removes the completed workbench topic, and leaves
the plan/authority in place for Ploopy's lifecycle. No push or landing is part
of this pass. Retain the experiment record and frozen spec after plan closure.
