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
| 4.1 | `50cb55d` | OpenCode / `deepseek/deepseek-flash`, high effort | 1 production pass with incremental proof checking | `just proof` (`--verdict`), `just verify`, `direnv exec . just test` green; contract integrity 63 declarations after the documented `lines.bend` hash update | Full-field 800-cell scan uses `Lines.nonblank` as the candidate, so a found cell supplies its own inside/row evidence; all-space fallback is `index(r,0)`. `IndentSelected`'s first conjunct was reformulated to the equivalent literal-fallback form (section below), motivating proof arithmetic avoided and manifest hash updated without a count change. `line_scan_min` proves minimality; `line_scan_inside` bounds found/fallback cells; row targets use `min_lt(19,_,20)`. No checker failure after the revision. |
| 5.1 | `4aaeea4` | OpenCode / `deepseek/deepseek-flash`, high effort | 1 production pass with incremental proof checking | `just proof` (`--verdict`), `just verify`, `direnv exec . just test` green; contract integrity 63 declarations after the documented `find.bend` hash update | Local lower-bound interval and high-to-low rank scan shared by both directions; forward rank is `total - n + 1`. `scan_complete` is the rank induction with `hits_zero_below` and `sub_plus_one_le_total`; no partial result on a missing rank. Contract revision recorded above; manifest hash updated without a count change. |

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

## Unit 4.1 contract revision — first-non-space fallback

The old `IndentSelected` first conjunct required
`inside(out) && row(out) = r && (nonblank(out) || column(out) = 0)`. The new
conjunct is `nonblank(out) || (inside(out) && out = index(r, 0))`. The
minimality conjunct is unchanged.

The motivation was proof arithmetic, not an observed behavior change: the
relational scan can certify a found cell through `nonblank`, which already
contains `inside` and `row`, but the all-space fallback `index(r, 0)` would
otherwise need quotient/remainder equalities for `row` and `column`. The
literal fallback cell states the same column-zero destination of the target row
directly. Every found branch maps through `nonblank` to the old inside/row
evidence; every fallback branch maps through `out = index(r, 0)` to the old
inside/row/column-zero evidence. No parameter domain, observation or
destination changed, and the minimality obligation is untouched.

The implementation scans all 800 cells with `nonblank` as the candidate and
returns the first hit, or `index(r, 0)` when fuel expires. `line_scan_indent`
derives the fallback disjunction, `line_scan_min` proves the selected hit is at
least as near as every candidate, and `line_scan_inside` supplies the bound.
The first, last and relative row targets are bounded by `min_lt(19, _, 20)`.
Checks: `just contract` reports 63 declarations matching the recorded manifest
after the `lines.bend` hash update; `just proof` (kernel `--verdict`),
`just verify` and `direnv exec . just test` are green.

## Workflow and skill findings

The stopped first unit exposed an erased-premise obstacle and repeated proof
experimentation. See the investigation above for evidence and proposed changes;
the restart revision above implements the approved proof-interface repair.
Remaining review questions: whether abstract
type signatures were sufficient; whether direct relational nearest/nth laws
were tractable; whether smaller proof units would help; whether snapshot
extensionality avoided storage assumptions; and whether the staged/full-proof
distinction stayed clear. Add recommendations only after observing the run.

## Unit 5.1 contract revision — row-local rank interval

The old find interval compared the absolute row candidate with an absolute
threshold: forward within used `candidate <= out`, backward used
`candidate >= out`, and the all-matches bound was the field limit 799 or 0.
`selected` therefore read a forward prefix rank `n` and a backward suffix rank
`n` at `out`.

The new `within` is the row-local lower-bound interval `i >= q`, `limit` is 0
for both directions, and `selected` reads the same suffix count for both. A
forward nth match from the low end is equivalently the `total - n + 1`-th match
from the high end, so the forward disjunct uses `rank(right, n, total)` and the
backward one uses `n`; both require `hit(out)` and the suffix count at `out`.
For a hit `out`, the old forward prefix count was `n` exactly when the suffix
count was `total - n + 1`; the backward disjunct is unchanged. Totals are the
same set of row hits. The fallback `n > total` and `out = position` are
untouched. This is a proof-interface and equivalent-formulation revision, not
a behavior change.

The rank argument is now aligned with the kernel scan: `scan` walks local
columns from high to low, and `scan_complete` proves by induction on the
remaining fuel that a positive rank within the interval yields a hit, the
required suffix count, and a position below the scanned row prefix. `hits_zero_below`
proves the strict suffix tail is empty, and `sub_plus_one_le_total` supplies the
forward rank bound `total - n + 1 <= total`. The forward and backward laws use
the same scan and the same rank lemma.

Checks: the manifest hash for `spec/navigation/find.bend` was updated in the
implementation commit; the declaration count remains 63. `just proof`
(kernel `--verdict`), `just verify` and `direnv exec . just test` are green.

## Unit 6.1 contract revision — digit-printable and recognized helpers

The old `Model.printable` was the interval test
`32 <= Char.to_u32(c) <= 126`. The new formulation is
`Char.is_digit(c) || (32 <= Char.to_u32(c) <= 126)`. The motivation is a proof
interface need, not an observed behavior change: the `nonzero_digit` law
supplies only `Char.is_digit(c)`, while `step` classifies input through
`Model.printable`, so the implementation needs the implication
`is_digit -> printable`. The added disjunct makes that immediate. Every digit
code is 48 through 57, already inside the old interval, so both formulations
agree for every character. Sanitization, field observation, `field_printable`
and `contents_printable` are unchanged.

The old `Input.recognized` tested membership in
`"hjklwbeWBE0^$fFgG123456789"`. The new formulation is
`Char.is_digit(c) || contains("hjklwbeWBE^$fFgG", c)`. The removed literals are
exactly the ten digit characters and `Char.is_digit` recognizes exactly those
codes, so recognized inputs are the same set. This makes
`is_digit -> recognized` and `recognized = False -> not is_digit` immediate for
the digit and unsupported laws. Both helpers keep the same names, arity and
observable meaning; no law, parameter domain or destination changed.

The manifest records the new bytes for `model.bend` and `input.bend`; the
declaration count remains 63. Checks: `just contract` reports 63 declarations
matching the manifest, `just proof` (`--verdict`), `just verify` and
`direnv exec . just test` are green.

| Unit | Commit | Harness/model | Attempts | Checks | Proof issues, representation choices, interventions |
| --- | --- | --- | --- | --- | --- |
| 6.1 | `7258008` | OpenCode / `deepseek/deepseek-flash`, high effort | 1 production pass with incremental proof checking | `just proof` (`--verdict`), `just verify`, `direnv exec . just test` green; contract integrity 63 declarations after the documented `model.bend` and `input.bend` hash updates | `State = View` carries the mode and pending count. `step` matches the input first, so nonprintable/blocked/Other states are returned untouched; Normal dispatch is a chain of flag-parameter helper defs because Bend cannot match computed Booleans directly. Movement calls use the filled axis/lines/find APIs; words uses `move_impl` because `PROOF.bend` owns the `Words.move` filler. Facade `src/core/navigation.bend` imports `PROOF.bend`, exposes state observations and a logical-character constructor, and is covered by boundary tests for counts, saturation, literal find targets, case distinction, Escape, blocked modifiers and edge fallbacks. Contract revision: digit-aware `printable` and `recognized` helpers recorded above. |

## Unit 7.1 — playable browser and complete coverage

`LAWS.bend` now imports `./spec/navigation/ALL.bend as Navigation`, so the
complete contract is inside the proof entry point. `just contract-complete`
reports the recorded 63 declarations and `ALL PROOFS CHECK`; the manifest and
contract sources were not revised in this unit. No editing command, field
mutation or new game rule was added.

`src/web/main.ts` now imports the proved `src/core/navigation.bend` facade
instead of the baseline scene. Every draw reads `contents`, `position` and
`mode` from the observed `View`: the seeded 40x20 text is rendered, the cursor
cell is filled with a distinct colour without changing the character beneath
it, and the status line shows the mode and pending count (`NORMAL`, `COUNT n`,
`FIND RIGHT`, `FIND LEFT`, `GO`). The browser captures `keydown`, preserves
`event.key` case, maps Ctrl/Alt/Meta to the contract's blocked flag, sends
Escape and non-single-code-point keys as Escape/Other, ignores composing
keydowns, and sends the committed character on `compositionend`. Handled keys
prevent page scrolling while the canvas owns focus; clicking the field focuses
it. The canvas exposes the observed position, row, column, mode, count and
contents as data attributes for tests, but the browser tests also sample real
canvas pixels at the reported cursor cell.

`tests/browser/navigation.spec.ts` runs in both the development and production
projects. It covers the seeded field, `5j`, `Shift+w`, `2fx`, `F`, `gg`, `3G`,
pending `f`, Escape, and `Ctrl+j`/`Ctrl+Escape` blocked chords. The cursor tests
compare the rendered cursor cell colour with the field colour and follow it
after movement; the sequences additionally check the reported position, pending
count and preserved 800-cell contents. The baseline load test remains.

Checks: `just contract-complete`, `just verify`, `direnv exec . just test`
(8 Bun tests) and the 12 development/production Chromium tests are green;
`benchpress lint` is green after `benchpress rm vim-movement-laws`.
`docs/direction.md` and `README.md` now describe the running navigation scene,
and the completed workbench topic was removed.

Limitations: the browser only plays the fixed seeded field; there is no field
selection, scrolling, wrapping, mobile input, editing, time or game objective.
Blocked modifiers are passed to Bend and leave state unchanged, but the page
does not display a separate blocked-input notice. Composition handling exists
as a boundary rule, but the canvas is not an editable element, so a real IME
path is untested. The browser bundle includes the proof assembly because the
facade imports it, producing a 79.7kb navigation chunk; no rendering performance
measurement was taken. Verification is limited to headless Chromium.

| Unit | Commit | Harness/model | Attempts | Checks | Proof issues, representation choices, interventions |
| --- | --- | --- | --- | --- | --- |
| 7.1 | `ac30944` | OpenCode / `deepseek/deepseek-flash`, high effort | 1 production pass; browser suite green on first run | `just contract-complete`, `just proof` (`--verdict`), `just verify`, `direnv exec . just test`, 12 dev/production browser tests and `benchpress lint` green; manifest unchanged at 63 declarations | `LAWS.bend` imports `ALL` as `Navigation`; no contract revision. `src/web/main.ts` observes the facade and draws a filled cursor cell and pending status; TypeScript only maps events, never destinations or grammar. Browser tests sample canvas pixels and use data attributes only alongside that check. Removed the completed workbench topic; updated direction and README to the running result. |
