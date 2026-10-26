---
authority: docs/plans/NAVIGATION.md
context: docs/experiments/navigation-laws.md
test: yes
---

# Implement and prove navigation against an observable contract

Status: active task document, revised 2026-10-26 after the stopped first run;
ready for a fresh run with no navigation implementation landed.

## Decisions settled with the author (2026-10-26)

Implement navigation and counts without editing. Minimize production code before
execution. The stronger model authored the contract and repaired its erased
equality assumptions after the first run. The executor chooses private
representations and writes implementation and proofs. The author chooses the
executor when restarting. The authority holds all shared behavior and
ownership rules; read it in every unit.

Run under nix develop. Every unit activates only its assigned contract
module in LAWS.bend, leaves earlier ones active, implements its API in src/core,
proves its obligations through PROOF.bend, and runs just verify. Contract proof
interfaces, equivalent law formulations and shared helpers may evolve under
authority section 4. Preserve behavior and obligation coverage; document each
revision and update manifest hashes/count in the same commit. Do not edit the
authority or audit tool. Record the unit's evidence in
docs/experiments/navigation-laws.md. No implementation has been supplied in
src/core for this pass. No change to NEXT.md is authorized.

Declaration counts below describe the starting contract. A documented
reformulation must retain coverage of every starting obligation and prove all
replacements and added helper laws; changing a count is not completion.

## Stage 1 — Runtime observations and arbitrary scenes

### 1.1 Choose representations and prove the observable model

**Goal:** Fill all declarations and prove all obligations in
spec/navigation/model.bend, then activate that module in LAWS.bend.

**Start from:** src/core/scene.bend, src/core/scene.d.bend.ts, LAWS.bend and
PROOF.bend. The two abstract types are declarations to implement, not axioms.
Choose private Data types for Field/State; provide field/at/contents,
pack/view and initial with the prescribed seed. No movement implementation is
needed here. Keep the existing browser unchanged. Use ordinary proof evidence
as in the repaired contract and Bend's Base equality lemmas. The checked small
probes in docs/experiments/navigation-law-feasibility/ are starting examples,
not a proof that the full model is already feasible. Do not repeat the stopped
run's erased-assumption experiments. Shared helpers and signature adjustments
are permitted under authority section 4.

**Done when:** The model module is imported by root LAWS.bend, its 17
declarations are filled/proved through the root proof graph, just proof and
just verify pass, and the experiment record names the chosen representations
and any difficulty implementing the abstract-type signatures. Add focused
runtime roundtrip/field tests if you expose this boundary to JavaScript now.

## Stage 2 — Axis movement

### 2.1 Implement counted h/j/k/l destinations and prove edge behavior

**Goal:** Implement and prove spec/navigation/axis.bend, including zero counts,
exact arithmetic destinations and bounds for all natural counts.

**Start from:** The model contract and its src/core implementations; activate
axis.bend in LAWS.bend. Preserve the behavioral obligations; adjust proof
interfaces only under authority section 4.
Keyboard parsing and browser movement belong to later units.

**Done when:** All six axis declarations are filled/proved, just verify passes,
and evidence records proof attempts and the chosen arithmetic strategy.

## Stage 3 — Word and WORD navigation

### 3.1 Implement counted w/b/e and W/B/E with relational proofs

**Goal:** Implement and prove spec/navigation/words.bend. Specification helpers
may guide and support the implementation under authority section 4.

**Start from:** Model observations and the private core representation. Activate
words.bend in LAWS.bend. The one-step law quantifies over competing candidates;
the counted law is grounded by it. Choose scans, indexing or another terminating
algorithm and add private lemmas as needed. Do not weaken the universal law to
checks on only the fixture.

**Done when:** All five word declarations are filled/proved, just verify passes,
and evidence distinguishes candidate/minimality proof work from count induction.

## Stage 4 — Line and field navigation

### 4.1 Implement 0, ^, $, gg and G destinations

**Goal:** Implement and prove spec/navigation/lines.bend, including blank rows,
explicit/default row counts and clamped relative row-end behavior.

**Start from:** Model contract and implementations. Activate lines.bend in
LAWS.bend. These functions compute destinations; input's g-prefix protocol is
outside this unit. First-non-space is constrained relationally, including its
all-space fallback.

**Done when:** All seven line declarations are filled/proved, just verify
passes, and evidence records the first-non-space and fallback proof strategy.

## Stage 5 — Counted character find

### 5.1 Implement nth forward/backward row-local find

**Goal:** Implement and prove spec/navigation/find.bend: exact nth target,
strict direction, current-cell exclusion and complete no-op on insufficient
matches. Zero internal count is identity.

**Start from:** Model and its core representation. Activate find.bend in
LAWS.bend. The contract counts matches within an interval; it does not prescribe
the implementation's scan or data structure. Input's pending target state is
outside this unit.

**Done when:** All four find declarations are filled/proved and just verify
passes. Evidence names any rank/counting lemmas needed and covers why a partially
successful find cannot be returned when the requested count is absent.

## Stage 6 — Pure input interpretation

### 6.1 Implement counts, case and pending commands in Bend

**Goal:** Implement and prove spec/navigation/input.bend, connecting actual
character events to the already proved movement APIs.

**Start from:** The model, all motion contracts and their core implementations.
Activate input.bend in LAWS.bend. Implement step with count saturation,
0-versus-count disambiguation, all four grammar states, literal find targets,
Escape, unsupported/nonprintable input and blocked modifier behavior.
Representation extensionality and field/validity preservation are obligations,
not optional properties. Supply a JS facade with accurate declarations and
focused boundary tests for sequences independently worked out from the contract.

**Done when:** All 24 input declarations are filled/proved, every earlier module
remains checked, actual exported step passes count/prefix/case regression tests,
and just verify passes. The browser may still draw the baseline in this unit.

## Stage 7 — Playable browser and complete experiment evidence

### 7.1 Render and exercise the full proved navigation scene

**Goal:** Connect the proved engine to src/web/main.ts, render the seeded field
and distinct cursor, and establish complete contract coverage.

**Start from:** The filled navigation API, its .d.bend.ts boundary,
src/web/main.ts, src/web/style.css and tests/browser/baseline.spec.ts.
TypeScript captures and draws; all command decisions stay in Bend. Preserve
case and expose blocked modifiers. Render cursor/pending state from View;
verify real cursor pixels alongside the reported position.

**Done when:** LAWS.bend imports ./spec/navigation/ALL.bend as Navigation,
just contract-complete and just verify pass, development and production browser
tests cover the authority's sequences, no editing is introduced, and
docs/experiments/navigation-laws.md records the actual outcomes and limitations.
Update docs/direction.md's baseline/next discussion to match the running result,
remove docs/workbench/vim-movement-laws.md with benchpress rm, fix any dangling
links and run benchpress lint. Keep this plan and its authority for Ploopy to
close; do not land or push.
