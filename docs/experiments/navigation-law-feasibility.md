# Navigation law feasibility investigation

*Measured 2026-10-26, Bend 2.0.39, after the author stopped execution.*

The first DeepSeek implementation session did not reach production code. It
reported a conflict between erased proof assumptions and the frozen model
laws. This investigation separates that obstacle from model capability.

## Reproductions

The [probe sources](navigation-law-feasibility/) are standalone, hand-written
experiments, outside the production proof graph. Run each with:

```sh
nix develop --command bend docs/experiments/navigation-law-feasibility/affine.bend --verdict
```

Replace `affine.bend` with each filename below. Negative probes are expected
to fail; they are not unfinished production obligations.

| Probe | Result | What it checks |
| --- | --- | --- |
| `erased.bend` | Rejected: expected `-ok`, observed `ok` | Returning an erased equality assumption as evidence of that same equality |
| `affine.bend` | ALL PROOFS CHECK | Identical statement/body with an ordinary proof assumption |
| `model-erased.bend` | Rejected: expected `-ok`, observed `ok` | A Boolean cell model with inside fidelity and outside clamping, using erased assumptions |
| `model-affine.bend` | ALL PROOFS CHECK | Identical cell model and proof bodies with ordinary assumptions |
| `model-guarded.bend` | ALL PROOFS CHECK | Same cell behavior, using conditional proposition types instead of explicit equality assumptions |

The identity probe is deliberately stronger evidence than the executor's
reflexive-goal example: its conclusion needs the assumption for arbitrary `p`.
It confirms an erasure restriction, not just a poorly chosen rewrite.

The installed `bend base Equal` also uses ordinary, non-erased equality
evidence in `Equal.cong`, `Equal.sym` and `Equal.trans`. Erased types and
endpoints in those signatures do not make their equality evidence erased.

The model probes reduce positions/characters to Booleans, retaining the
essential conditional obligations. They do not establish feasibility of the
whole 800-cell model, its runtime bridge, arithmetic, word/find selection, or
the later input proofs. No complete navigation proof or global impossibility
proof was produced here.

## Findings

The handoff imposed an inappropriate proof-signature restriction. Ordinary
proof evidence works in the pinned checker; erased evidence cannot simply
be used the same way. Changing that annotation preserves the intended
inside/outside behavioral requirement, while changing its proof interface.
It needs an explicit contract revision, not a compiler bypass.

This is broader than the two laws the executor named. The six contract
modules contain 60 erased equality-premise binders: model 4, axis 5, words 3,
lines 6, find 2, input 40. Some premises may be unnecessary for particular
implementations; this count does not assert that every binder causes a
failure. Audit the signatures before resuming.

DeepSeek correctly identified the assignment, investigated the obstacle, and
respected the prohibition on editing frozen contracts. Its first session
also repeated similar failed experiments and overstated a global
unprovability claim. This run does not isolate model strength: the supplied
proof interfaces were not validated by an implementation witness beforehand.

## Recommended next experiment

Keep intended behavior, independently derived examples and the kernel check
as the acceptance boundary. Permit reviewed changes to proof interfaces,
equivalent law formulations, helper functions and lemma organization. Do not
permit narrowing the supported domain, dropping an obligation, changing
expected examples to match code, or adding unsafe/foreign proof escapes.

Use ordinary proof assumptions as the smallest repair. Conditional laws such
as `When(inside(p), equality)` are another demonstrated option, but should be
chosen for proof ergonomics, not imposed across the whole contract without
trying one real model implementation first.

Treat laws as an executable design aid: allow shared classification,
sanitization, bounds and coordinate helpers. Keep independent examples of
user-visible results so sharing helpers does not make specification mistakes
invisible. Representation choices and helper organization need not be frozen
to protect navigation behavior.

Before another full run, have the specification author establish a checked
witness for the model unit, or a small real vertical slice. Count that work as
stronger-model assistance. Then give DeepSeek the corrected, identical unit
and compare its result with a stronger executor if necessary. Record repeated
failures and escalate after experiments stop producing new evidence; do not
treat arbitrary retry counts as evidence that the model is incapable.

At the end of the investigation the authority, manifest, audit tool and
execution plan were unchanged. The author subsequently approved the repair
and restart recorded in [the experiment record](navigation-laws.md#restart-revision--2026-10-26):
ordinary proof assumptions, documented contract revisions and shared helpers
are now allowed. The negative probes retain the original erased assumptions
as reproductions; they are not part of the repaired production contract.
