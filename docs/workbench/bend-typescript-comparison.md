---
kind: experiment
area: tooling
state: open
---

# Compare the same game in Bend and ordinary TypeScript

*From the author, 2026-10-26.* Understand how well the implementation agent did
after relaxing law changes, extract rules for Bend plans, then implement the same
features using ordinary TypeScript/Bun and the same agent. The author prefers a
separate repo so both versions can evolve side by side. Their question is whether
Bend's laws and proofs increase quality in AI driven development, acknowledging
that it is early to judge.

**Settled (2026-10-26):** The author authorized recording the findings, creating
the separate TypeScript repo with reused tooling/environment, publishing both
under their personal GitHub account only, then landing the Bend result.

**Now:** The reviewed Bend navigation snapshot is `779bbb8`. The independent
[review](../experiments/navigation-review.md) records outcomes and planning rules.
Known defects and repair work live in [their own topic](navigation-runtime-gaps.md).
The comparison baseline is committed at `5bbede0` in
[Torwalt/vim-flow-ts](https://github.com/Torwalt/vim-flow-ts), locally
`~/repos/vim-flow-ts`. GitHub owner is the personal user Torwalt. It has an
independent Git history, the retained non-language Nix pins, ignored shared
`.env`, TypeScript-only baseline, 50 mapped finite obligation checks and the
migrated seven-unit plan. Baseline verification, both browser projects, Ploopy
lint and Nix checks passed. No implementation run has started. The Bend result
is being landed separately; the reviewed snapshot remains recorded by hash.

**Setup and comparison protocol:**

- Create a separate local `~/repos/vim-flow-ts` from the exact pre-implementation
  `main` commit, without inheriting the navigation branch's implementation.
  Keep provenance in a comparison document. Use an independent Git object store
  and a personal-account remote. Ploopy owns its plan worktree normally.
- Bootstrap ordinary TypeScript/Bun and the existing Canvas/browser test shell.
  Remove Bend/Lean sources, compiler/loader/proof/audit integration, Nix packages,
  obsolete rules and language-specific plan text from that repository. Keep Bun,
  browser, Ploopy and Benchpress versions pinned. Keep setup effort separate from
  executor effort, just as the Bend baseline and law authoring were setup.
- Retain the author's game intent, 40x20 ASCII domain, fixture, command behavior,
  pure-core/browser ownership boundary and all edge policies. Do not give the
  TypeScript executor completed navigation implementation, proofs or hindsight
  about particular implementation algorithms chosen by DeepSeek.
- Translate the planner-authored observable contract into TypeScript public API
  declarations, prose and independently derived executable examples/properties.
  Keep storage private. Helpers for classification, normalization, candidate and
  rank predicates were assistance in Bend: equivalent assistance should be
  available in TypeScript and counted, rather than stripping all specificity and
  comparing a precise Bend specification to a vague TypeScript request.
- Write an explicit mapping of the 50 original semantic obligations to runtime
  checks and/or property tests; distinguish finitely sampled evidence from a
  universal theorem. Keep 13 API/type declarations separate from those obligations.
  Avoid translating a law into a test that compares the implementation to itself.
  Do not require TypeScript to imitate affine signatures or proof assembly.
- Preserve the seven feature units: model, axis, words, lines, find, input,
  browser. Each ends with passing active checks; stage tests as functionality
  appears. Replace proof tasks with behavior/property coverage rather than
  inventing TypeScript proof work. Planner pointers can describe independent
  candidate/rank relations and tricky boundaries, as in the original handoff.
- Use OpenCode / `deepseek/deepseek-flash`, high effort, no secondary/rescue,
  fresh sessions per unit, same check policy and no human repair unless separately
  recorded. Record actual provider routes, versions, cache use and assistance.
  Preserve run/session logs; the old run lacks detailed Ploopy stats logs.
- Author and freeze a shared external acceptance corpus before TypeScript
  implementation. Run it against both versions via thin adapters: arbitrary and
  malformed fields, boundaries, word classes, nth find failures, parser sequences,
  modifiers, focus loss and high counts. Keep evaluation expected values out of
  executor changes. Do not use the completed Bend implementation as the oracle.

**How to read the comparison:**

Compare correctness on the shared corpus, defects found after completion, runtime
latency, all-in planning/implementation/review/repair effort, interventions and
ease of the next change. Report machine/provider conditions and repeat timings.
Include universal proof coverage as an additional Bend outcome; do not equate a
property-test pass with a theorem. Score the original Bend snapshot and later
repairs separately. New tests informed by this review are a hindsight advantage
for the second arm and must be labeled as such. One historical run versus one
new run compares workflows; it cannot isolate language from specification
quality, planning effort, provider changes or order effects.

For stronger evidence, give both implementations the same next gameplay feature
from a language-neutral brief, freeze shared acceptance criteria first, then
prepare comparable language-specific plans. Repeat across a few increments;
record how often existing Bend lemmas actually save work and whether proof
maintenance detects defects the TypeScript checks miss.

**Open:** The TypeScript plan is ready but not started. The first result is a
pragmatic historical workflow comparison; fresh matched runs could strengthen
it later. Freeze shared evaluation inputs and any responsiveness target before
scoring performance. The TypeScript protocol records no invented numeric timing
pass mark. Working planning rules live in
[the workflow findings](../workflows/bend-planning.md); no generic skill was added.
