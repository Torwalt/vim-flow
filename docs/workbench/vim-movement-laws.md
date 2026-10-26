---
kind: experiment
area: vim
state: planned
plan: docs/plans/NAVIGATION_EXECUTION.md
---

# Implement navigation against reviewed laws with a simpler model

*Settled with the author, 2026-10-26.* The initial laws were approved. Expand
navigation to counts and additional motions, without editing. Minimize
production code before execution; leave storage and implementation choices to
the executor. The author will choose the executor model later.

**Now:** The browser still contains only the verified baseline. The complete
navigation specification elaborates with 63 OPEN declarations; no
navigation implementation or proof has been supplied. Baseline proof success
covers only baseline behavior. The author stopped the DeepSeek run during unit
1.1 on 2026-10-26; no navigation implementation landed. An independent
[feasibility investigation](../experiments/navigation-law-feasibility.md)
reproduces an erased-assumption obstacle and checks alternatives on a small
model. The repaired contract now uses ordinary equality assumptions, and the
authority permits documented proof-interface revisions and shared helpers.

The [authority](../plans/NAVIGATION.md) holds the full scope, observable model,
edge behavior, contract revision rules and proof activation strategy. The
[execution plan](../plans/NAVIGATION_EXECUTION.md) assigns the work. The
[experiment record](../experiments/navigation-laws.md) distinguishes setup work
from executor work and will hold the findings about workflow and skill needs.

**Settled (2026-10-26):** The author approved relaxing proof-interface and
helper restrictions while preserving behavior and verification. Commit the
findings and repair, remove the old worktree, and let the author restart the
plan from scratch. No complete model witness has been supplied; do not claim
this restart already isolates executor strength. The experiment record holds
the repair evidence and will capture the next outcome.
NEXT.md remains the author's order.
