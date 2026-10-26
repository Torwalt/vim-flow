# Review of the restarted navigation experiment

Measured 2026-10-26 at `779bbb8e649af151ff8e4beead2c50c34585a8cd`, against
pre-implementation `main` at `0e17f02c8db13dabdca3e8db49109d7d72df0121`.
The repository calls its default branch `main`, rather than `master`.
This is an independent review, not a Ploopy review run or a landing decision.
Implementation and contracts were left unchanged.

The author's explicit research goals are higher AI code quality and/or token
savings from fewer erroneous approaches. [Working planning findings](../workflows/bend-planning.md)
carry the rules forward; the separate TypeScript experiment will test those
hypotheses. No matched result or net token saving has been established yet.

## Assessment

The executor did a good job of implementing and proving the specified core
after the proof-interface repair. All seven units completed in one Ploopy
attempt each, without a recorded stronger-model rescue. The full contract is
imported and kernel-checked, not merely elaborated or partly activated. I found
no navigation destination error in source inspection and 380 independently
computed runtime checks across four fields, five positions per field and 19
commands, with small counts. This finite probe does not prove completeness.

The result is weaker as a finished browser feature: blur cancellation is
missing, counted word movement visibly stalls, and the committed runtime tests
do not meet the authority's varied-field requirement. Proofs did not catch
these gaps. There is also a small runtime/proof ownership violation.

## Required fixes and observed limitations

1. **Blur leaves a command pending.** `src/web/main.ts:111` registers no blur
   listener. Authority section 2 explicitly requires browser blur to send
   Escape. In production Chromium, press `f`, dispatch a window blur event,
   and observe `data-mode`: it remains `FindRight`. A later printable character
   can therefore complete an abandoned find. Send the unblocked Escape through
   the core when focus is lost and test cursor/field preservation and clearing
   each pending state. The dispatch reproduces the missing handler; it is not
   an operating-system focus integration test.
2. **Counted word movement blocks input.** `navigation_words.bend:39` starts
   every forward/end scan at zero and every backward scan at 799. Each step
   normalizes the field and repeatedly looks up characters in a linked String.
   `move_impl` repeats this even after reaching a fixed destination. From the
   initial scene, `99w` took 885 ms and 830 ms in two production headless Chromium
   runs, and 2,989 ms in a separate Bun probe. These are observations on this machine,
   not stable benchmark medians. A subsequent Bun `9999w` probe was terminated
   while still running; no completion time is claimed. Counts up to 9999 are
   supported, so responsiveness needs repair even though final destinations
   satisfy the laws. Consider starting scans near the cursor, avoiding repeated
   normalization and proving an early stop when another step cannot move.
   Measure high counts across all six word commands before choosing a fix.
3. **Required arbitrary-field runtime coverage is absent.** Authority section 6,
   lines 217–223, requires runtime boundary tests on varied fields.
   `tests/navigation.test.ts` constructs every state from `initial()` and only
   exercises the seed. There are useful count/case/find regressions, but no
   independent arbitrary-field construction/roundtrip boundary tests. Add a
   truthful test boundary through the real model API; do not rely on opaque
   state fabrication in permanent acceptance tests. Review probes passed but
   do not repair the committed suite's omission.
4. **One executable API filler lives in the proof file.**
   `PROOF.bend:1314` fills `NavigationWords.move`; other motion fillers live
   under `src/core/`. This conflicts with authority section 4's runtime
   ownership rule and makes input call private `WordsImpl.move_impl` directly.
   Move the delegating filler into the words implementation module and check
   the assembled entry point and proof graph. This is an ownership defect,
   not evidence of an incorrect destination or unsafe core.

The large proof file is a maintenance concern rather than a demonstrated bug:
3,378 total lines, 3,368 added by this implementation, alongside 520 lines in
the new core navigation modules and 864 lines of current contract modules.
Line counts are not effort measurements. No performance requirement or timing
budget was present in the original acceptance checks; the runtime observation
above is a newly measured quality issue, not a failed original timing gate.

## What changed after relaxation

| Unit | Agent time | Recorded difficulty and response |
| --- | --- | --- |
| Model | 8m24s | `Field = String`, `State = View` sufficed. Affine equality evidence needed forwarding to a reusable proof helper. No contract revision. |
| Axis | 8m31s | Direct filler consumed position twice. A private reusable-argument helper solved it. Built quotient/remainder, arithmetic and bound lemmas. No revision. |
| Words | 9m48s | Computed Boolean matching required explicit flag parameters. Built nearest-candidate and comparison-reflection lemmas, then count induction. No revision. Full-field scanning traded runtime efficiency for a simple proof structure. |
| Lines | 5m01s | Replaced row/column fallback conjunction with the literal destination `index(r,0)`, avoiding quotient/remainder proof work. |
| Find | 28m32s | Longest unit, about 38% of session time. Replaced forward prefix rank with equivalent suffix rank `total - n + 1`; one descending scan supports both directions. Built dependent scan witnesses and rank arithmetic. |
| Input | 11m04s | Explicit Boolean dispatch chain and reusable parameters. Rewrote digit-printable and recognized predicates so digit premises imply both directly. |
| Browser | 3m36s | Integration and existing suite passed; missing blur and slow large word counts escaped it. |

Times come from `ploopy report NAVIGATION_EXECUTION`; details come from source,
`ploopy replay` handovers and `navigation-laws.md`. One attempt is a supervisor
count: each session contained incremental proof checking and failed probes.
There is no retained Ploopy stats log in the plan checkout, so these records do
not support an exact failed-tool-call count or a full reconstruction of every
local struggle.

Ploopy reports 1h14m session time, 53s supervisor checks and $0.69. It reports
75.4M tokens read, 99% cached, and 649k written. These are harness figures;
they are not 75.4M unique context tokens or an all-in experiment price. Planning,
the stopped run, stronger-model investigation/repair, and this review are
additional work. The executor was OpenCode / `deepseek/deepseek-flash`, high
effort. Reported model identity does not pin a provider's internal model build.

## Were the contract revisions legitimate?

The original behavioral authority and audit tool are unchanged. Only model,
lines, find and input contract bytes changed; hashes were updated and the
declaration count stayed 63. Equal counts alone are not semantic evidence.

- **Lines:** found results still carry row and bounds through `nonblank`.
  The fallback `inside(out) && out = index(r,0)` selects exactly the old
  row/column-zero result for the bounded target rows used by the laws. The
  universal minimality conjunct remains. This preserves the motion obligation.
- **Find:** for a positive requested count within the total number of strict,
  row-local hits, prefix rank n is suffix rank `total - n + 1`. Requiring a
  hit makes that position unique. Backward suffix rank and insufficient-match
  identity remain. The zero law remains separate. The interval implementation
  still compares absolute positions despite its row-local wording; its loop
  enumerates the current row. I found no domain restriction or missing hit.
- **Digits:** adding the ASCII digit disjunct to printability adds no supported
  character, and replacing ten literal digits in `recognized` with
  `Char.is_digit` preserves that set under the pinned Base definition. These
  make existing semantic facts easier to use in proofs.

These preservation arguments are supported by source inspection and independent
runtime examples. The executor did not supply kernel-checked old/new equivalence
theorems. The authority allowed a preservation argument plus independent
examples, so their absence is not itself a violation. Preserve this distinction
when describing the result: the final laws are checked; their equivalence to
the previous version was reviewed rather than kernel-proved.

The first run's erased-evidence obstacle was a planner interface defect. The
restart repaired all 60 erased equality-premise annotations before execution.
Success after that repair supports the revised workflow; it does not isolate
whether relaxation alone caused success or show an unchanged retry succeeded.

## Rules worth carrying into Bend plans

1. Freeze the supported domain and observable behavior. Let the executor change
   quantities, private types, equivalent predicates and helper organization
   against concrete checker evidence. Require an old-to-new obligation map,
   a preservation argument, independent examples and a full kernel verdict.
   A manifest establishes recorded bytes, not correctness of a revision.
2. The planner should specify public observations, valid-state conditions,
   construction of arbitrary supported inputs, exact edge behavior and examples.
   It need not implement private storage or motion algorithms: the abstract
   Field/State boundary worked here without a complete model witness.
3. Before handoff, validate the proof interface with a small real witness using
   the pinned compiler, particularly premises, abstract type filling and runtime
   proof assembly. Merely elaborating open laws was insufficient. Count witness
   work as planner assistance; a full feature implementation is not necessary.
4. Provide checked shared infrastructure for repeated arithmetic and scan facts,
   with an index of signatures and import paths. Share classification and
   normalization freely; keep destination examples independent. Authoring these
   helpers is real work and belongs in experiment accounting.
5. Keep the successful cumulative model → motions → parser → browser ordering.
   Find deserves an explicit rank/scan strategy note or a separate green lemma
   preparation unit if future units repeatedly exceed the others. One slow unit
   alone is insufficient reason to split every proof into tiny sessions.
6. Make runtime acceptance first-class: arbitrary fields, focus loss, real input
   sequences, and high-count timing. Mathematical termination and bounds do not
   imply usable latency. Add a shared timing criterion before the next measured
   experiment, rather than silently treating it as an old requirement.
7. Keep executable fillers in the core and organize reusable proof modules by
   subject. Avoid forcing every later session to navigate one growing proof file.
   Establish enough assembly examples that agents can keep this separation.
8. Require evidence of forward progress from probes. Escalate when experiments
   repeat the same restriction; distinguish proof-interface, missing-lemma,
   normalization-resource and actual behavior problems in the handover.

Future work should be easier when it reuses the current bounded grid, arithmetic,
observations and input grammar. That is a reasoned expectation, not yet measured.
Editing, changing geometry, Unicode, time and mutable world rules can invalidate
those assumptions and introduce new proof costs. Measure the next shared feature
in both arms before claiming that Bend pays for itself.

## Verification and reproduction

`nix develop --command just verify` passed: contract integrity, kernel verdict,
TypeScript, eight Bun tests, twelve development/production Chromium tests and
benchpress lint. `nix develop --command just contract-complete` independently
passed with all 63 declarations and the full import checked. No flake or core
changes were made for this review.

The standalone review probes in `navigation-review/` can be run from the repo:

```sh
nix develop --command bun docs/experiments/navigation-review/motions.ts
nix develop --command bun docs/experiments/navigation-review/browser.ts
```

The motion probe deliberately fabricates the inspected private View shape to
exercise arbitrary fields through the real compiled step. This is a review
technique tied to this revision, not a supported TypeScript API. It compares
against separate TypeScript calculations and is not wired into `just verify`.
The browser probe starts and stops its own production preview on port 43187;
use a free port. Results vary by machine and warmup. Neither probe changes the
implementation or constitutes the shared acceptance suite proposed for the
comparison.
