# Navigation laws experiment

## Question and setup — 2026-10-26

How little production model/code can a stronger model author while still
providing a precise law contract that a simpler model can implement and prove?
Where does implementation force changes to that contract, and which workflow
or skill instructions would those failures justify?

The author approved the initial movement laws and requested counts and more
navigation, without editing. At the original handoff the executor model had
not been selected. The stopped first run and restart revision are recorded
below; the original setup account is retained as history.

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

Execution started with OpenCode / `deepseek/deepseek-flash` at high effort,
and the author stopped it during unit 1.1 on 2026-10-26. No navigation
implementation landed. An implementation session reported a conflict between
erased equality assumptions and the frozen model laws; its handover is in the
[archived first-run handover](navigation-law-feasibility/first-run-handover.md).

The independent [feasibility investigation](navigation-law-feasibility.md)
reproduces that restriction and kernel-checks two alternative formulations on
a small cell model. This is a specification-interface finding, not a completed
navigation proof or a controlled result about executor strength. The
investigation and its probes are stronger-model interventions and count as
such. Ploopy history/report remain the source for completed session timing
and cost; no aggregate measurement is asserted here.

| Unit | Commit | Harness/model | Attempts | Checks | Proof issues, representation choices, interventions |
| --- | --- | --- | --- | --- | --- |
| 1.1 | `3f56459` | OpenCode / `deepseek/deepseek-flash`, high effort | 1 in the restarted run | `just proof`, `just verify`, `direnv exec . just test` green; contract integrity still 63 declarations, manifest unchanged | Chose `Field = String` and `State = View`. `field` is identity, `at` is an inside-clamped `text_at`, `contents` is an 800-cell sanitized padding built from `text_at`, `view`/`pack` are identity, and `initial` is the prescribed seed. Abstract `Data` laws fill as argument-less defs (`def Model.Field(): String`); typed API laws fill as untyped-name defs. The affine `ok` premise in `contents_at` had to be forwarded once to a proof helper with a reusable `+ok` premise so the same evidence could both rewrite the clamped lookup and supply the padding bound. Added proof-only helper laws for padding length, printability and prefix agreement; no contract revision or manifest change. |
| 2.1 | `9224d59` | OpenCode / `deepseek/deepseek-flash`, high effort | 1 production pass after isolated probe proofs of the arithmetic helpers | `just proof`, `just verify`, `direnv exec . just test` green; contract integrity still 63 declarations, manifest unchanged | `move` is a private `move_impl` with a reusable position because each direction reads the position twice; the untyped law filler passes it once. Destinations are `Model.index` over `Nat.sub`/`Nat.min`, so zero counts are identity and every edge saturates. Bounds use a `Nat.divmod.go` invariant (`a = n + 40d + r`), quotient/remainder lemmas and induction over `Nat.add`, `sub` and `min`. The first direct filler was rejected for consuming the law's affine `position` twice; no contract or manifest revision. |
| 3.1 | `915d9a6` | OpenCode / `deepseek/deepseek-flash`, high effort | 1 production pass after an isolated probe of the scan and Nat-reflection helpers | `just proof`, `just verify`, `direnv exec . just test` green; contract integrity still 63 declarations, manifest unchanged | Words scan from position 0 upward (`w`/`e`) or from 799 downward (`b`) with 800-cell fuel, carried candidate flags and edge fallbacks 799/0. Bend rejects matching a computed `candidate(...)`, so the scanner takes the flag as a parameter and recurses with the next computed flag. Candidate/minimality is proved by scan-window lemmas (`scan_up_min`, `scan_down_min`) using Nat comparison reflection; count decomposition is definitional (`counted`) and bounded is proved by induction over the count in `move_inside`. No specification, authority or manifest revision. |

## Restart revision — 2026-10-26

The author approved relaxing proof interfaces and helper restrictions while
preserving observable behavior and kernel verification, committing the
investigation, and deleting the stopped worktree to restart from scratch.

All 60 `for -name: {equality}` binders in the six specification modules now
use ordinary affine proof evidence. No parameter domain, equality body,
predicate, fixture, runtime API declaration or semantic obligation was removed
or changed in this repair. The before/after source comparison permits exactly
those annotation changes. The manifest records the revised bytes; the starting
contract still has 13 abstract declarations and 50 semantic obligations.

The motivating checker error and successful ordinary-evidence/conditional
alternatives are preserved in the feasibility probes. The repair changes the
proof interface, not the intended inside/outside or input behavior. It does
not constitute an implementation witness for the full model or later units.

Authority section 4 now permits documented signature repairs, equivalent law
reformulations and shared helpers. Every affected behavioral obligation must
remain covered; independent examples and kernel verification remain required.
The audit command is named `--integrity` (`--frozen` remains a compatibility
alias). A manifest match detects unrecorded edits; it does not establish
semantic equivalence. The executor may update the manifest with a documented
contract revision, but may not change the authority or audit tool.

This repair and the investigation/probes are stronger-model authoring work.
The next run uses a revised handoff and must not be reported as an unchanged
retry or a zero-intervention comparison. The original handover is archived
above; the author requested removal of the old worktree and its ignored logs.

For unit 3.1, the candidate/minimality work is the forward/backward scan proof:
the selected position is shown to be a real candidate and at least as near as
every other candidate, with independent edge fallbacks. Count handling is kept
separate: `counted` is the one-step decomposition of the recursive move, and
`bounded` is a structural induction over that same count. The proof uses the
candidate predicate only through its flag and public classification helpers; it
does not evaluate a concrete fixture or replace the universal law with examples.

## Workflow and skill findings

The stopped first unit exposed an erased-premise obstacle and repeated proof
experimentation. See the investigation above for evidence and proposed changes;
the restart revision above implements the approved proof-interface repair.
Remaining review questions: whether abstract
type signatures were sufficient; whether direct relational nearest/nth laws
were tractable; whether smaller proof units would help; whether snapshot
extensionality avoided storage assumptions; and whether the staged/full-proof
distinction stayed clear. Add recommendations only after observing the run.
