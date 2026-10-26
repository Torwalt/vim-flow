Historical executor report from the stopped first run, 2026-10-26.
Its global impossibility claim was not independently established; see the
[feasibility investigation](../navigation-law-feasibility.md). Archived before
the author-requested worktree removal.

# Handover 1.1

## What landed

Nothing. No repository files were changed and the tree is clean. No commit.

## Landmark drift

None: implementation was not reached. The plan's start points (`src/core/scene.bend`,
`scene.d.bend.ts`, `LAWS.bend`, `PROOF.bend`) are still as described.

## Deviations from the work order

I stopped before writing the model because the frozen model obligations are not
provable with Bend 2.0.39's erasure rules. This is a checker/contract conflict,
not a missing lemma.

## What the next session must know

The viable representation was worked out: fill `Model.Field` with `String`
(`def Model.Field(): String`), `Model.State` with `Model.View`; `field(text)=text`;
`contents(f)=take_pad(800,f)`; `at(f,p)` is a left-to-right scan with fuel 800 that
returns `text_at(text,p)` for `p<800` and space for `p>=800`. The abstract type laws
do fill by a type alias (`law T: Data` filled by `def T(): SomeType`). Law fillers
are untyped bare-name defs: `parse_def` rejects typed binders in a filler.

The blocker is `field_contents` and `field_outside`. Both must use their premise,
and Bend 2.0.39 cannot eliminate an **erased** equality premise:

- Any term-level use of a `for -ok` equality is measured affine, so the filler fails
  with `expected : -ok, observed : ok`.
- The only escape is to pass the erased proof to another **erased** parameter, or
  use it in a type. I tried both; neither gives a live proof of the obligation.
- They cannot be proved without the premise: for `text` = 801 `a`s and
  `p=800`, `field_outside` forces `at(field(text),800)=' '` while `field_contents`
  requires `at(field(text),800)=text_at(text,800)='a'`. So `field_contents` cannot
  be strengthened to all `p`, and any proof must use `p<800`. Likewise
  `field_outside` needs `p>=800`.

Minimal reproduce (save as `/tmp/erased.bend`):

```python
import Base

law f:
  for p: Nat
  for -ok: {False{} == True{} : Bool}
  {p == p : Nat}

def f(p, ok):
  %ok : {p == p : Nat}
  {==}
```

`direnv exec . bend /tmp/erased.bend --check-only` gives
`expected : -ok, observed : ok`. Replacing the rewrite with a call to
`Empty.absurd` or a helper law also fails; marking the helper's parameter `-`
makes the helper's own use of it fail.

## Open problems

To land this unit the authority must change the two premises from erased
(`for -ok`, `for -outside`) to affine (`for ok`, `for outside`) in the frozen
`spec/navigation/model.bend`, or Bend must add a way to eliminate erased equality
evidence in dead propositions. Both are outside this unit's allowed edits. The
remaining model declarations/proofs are otherwise routine with the representation
above; no contract difficulty was found with `pack`/`view` or the seed.
