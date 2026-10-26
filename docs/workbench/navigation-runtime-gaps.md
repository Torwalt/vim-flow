---
kind: bug
area: vim
state: open
---

# Navigation passes proofs but misses runtime acceptance

*Observed 2026-10-26 at `779bbb8`, during the author's experiment review.*

**Now:** All original checks pass. Production Chromium leaves FindRight pending
after `f` and window blur, despite the authority requiring Escape on blur.
`99w` takes about 885 ms in one production Chromium measurement. The word
implementation repeats full-field scans even after its destination stops moving.
Committed runtime tests use only the seed despite required varied-field tests.
The executable Words.move filler lives in PROOF.bend rather than the core.

Evidence, reproduction scripts and precise source landmarks are in
[the review](../experiments/navigation-review.md#required-fixes-and-observed-limitations).
The implementation is preserved for the comparison; no fix has been applied.
Restore blur cancellation, cover arbitrary fields, repair counted-word latency
while preserving laws, and relocate the runtime filler. Record repair effort
separately from the completed implementation's cost.
