# Navigation laws experiment

## Question and setup — 2026-10-26

How little production model/code can a stronger model author while still
providing a precise law contract that a simpler model can implement and prove?
Where does implementation force changes to that contract, and which workflow
or skill instructions would those failures justify?

The author approved the initial movement laws and requested counts and more
navigation, without editing. The executor model is deliberately not selected
yet. There is no implementation run or outcome to report.

The handoff is docs/plans/NAVIGATION.md, its execution plan, and the frozen
spec/navigation modules. Their 63 declarations comprise 13 abstract API/type
declarations and 50 semantic obligations. The full contract elaborates but is
OPEN; baseline proof success is not a navigation proof pass.

## Work authored before execution

- Zero production changes under src/core or src/web; no movement algorithms.
- Two abstract Data type declarations (Field, State) instead of concrete
  storage. Three observable datatypes (Mode, View, Input) specify the public
  semantic boundary. Their choice is real model authoring, even though it is
  kept outside production source until implementations fill the contract.
- Specification helpers describe classification, coordinates, candidate/rank
  relations and input/count expectations. Their line count and authoring effort
  are part of the setup cost, not work attributed to the simpler executor.
- Complete laws, fixed seed data, staged proof activation, contract integrity
  and completion checks, and a seven-unit Ploopy plan.
- A temporary isolated Bend probe confirmed an abstract Data law can be filled
  by a downstream definition and a law over its observation checked with
  --verdict. The probe used Nat as a toy state; it did not implement navigation.
  A second probe checked a runtime facade importing that completed proof graph.
- Bend 2.0.39 refuses live definitions that call unfilled laws. Relational spec
  helpers therefore operate on observed String values; laws connect them to
  the abstract field in erased/type positions. This was a specification design
  constraint discovered before handoff, not an executor failure.

Preflight also extracted the pure specification helpers into temporary modules
without their open runtime declarations. Seventeen concrete checks passed
--verdict: fixture width, keyword/punctuation/WORD distinctions, candidate
boundaries, find ranks/failure, and row targets. These check selected predicates,
not satisfiability of the whole navigation contract. An initial field-wide find
rank scan exhausted the kernel's normalization fuel on a concrete example;
the final rank predicate counts only the current row's 40 cells, preserving the
row-local requirement. A concrete reflexivity check for saturation at 9999
still exhausted kernel fuel; compiled JS evaluations of 9999+digit saturation
and decimal zero append passed. The universal count proofs remain open and may
need symbolic arithmetic lemmas instead of evaluating large numerals directly.
These are setup findings, not smaller-model results.

Handoff checks passed: full contract elaboration with exactly 63 open claims,
baseline --verdict, TypeScript, runtime boundary test, static build, both
development/production Chromium checks, Ploopy lint/show and benchpress lint.

The commitments include fixed 40x20 ASCII geometry, fully navigable cells,
bounded count entry (saturating at 9999), and four input grammar states. They
are frozen behavior choices for this experiment. Storage, private helper types,
scans and proof strategies are left to the executor.

## How to interpret results

This is one chosen boundary, not evidence that it is the universal minimum.
Even a completely successful run establishes only the written properties over
the chosen domain. Browser integration, responsiveness and whether these rules
feel right still need empirical checks. The abstract types preserve storage
freedom, but their observation/API signatures can themselves prove too rigid.

Record specification bugs separately from implementation bugs, failed proofs,
resource limits and tooling failures. Every stronger-model intervention counts,
including a rescue that supplies a missing lemma or chooses a representation.
Automatic stronger rescue is disabled so such help cannot be hidden in the
initial measurement. Metrics unavailable from the harness stay unavailable.

## Execution evidence

Not started. Ploopy history/report will supply timing, actual model and cost
where available. Each unit adds one row and links any detailed findings below.

| Unit | Commit | Harness/model | Attempts | Checks | Proof issues, representation choices, interventions |
| --- | --- | --- | --- | --- | --- |

## Workflow and skill findings

No executor evidence yet. Candidate questions for the review: whether abstract
type signatures were sufficient; whether direct relational nearest/nth laws
were tractable; whether smaller proof units would help; whether snapshot
extensionality avoided storage assumptions; and whether the staged/full-proof
distinction stayed clear. Add recommendations only after observing the run.
