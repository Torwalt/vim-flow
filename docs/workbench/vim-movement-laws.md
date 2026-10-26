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
frozen navigation specification elaborates with 63 OPEN declarations; no
navigation implementation or proof has been supplied. Baseline proof success
covers only baseline behavior. A seven-unit Ploopy plan is prepared, not run.

The [authority](../plans/NAVIGATION.md) holds the full scope, observable model,
edge behavior, immutable contracts and proof activation strategy. The
[execution plan](../plans/NAVIGATION_EXECUTION.md) assigns the work. The
[experiment record](../experiments/navigation-laws.md) distinguishes setup work
from executor work and will hold the findings about workflow and skill needs.

**Pending:** choose the executor and start the plan when the author is ready.
NEXT.md remains the author's order.
