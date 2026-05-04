# [Subsystem] Behavior Matrix

**Status:** Draft / Approved / Frozen
**Last reviewed:** YYYY-MM-DD
**Owner:** <team or person>

## Purpose

What branchy behavior this matrix encodes, and why writing it down (rather than leaving it implicit) matters here.

## Cells

| Cell ID | Scenario | Input / context | Expected decision / behavior | Notes | Tests |
|---|---|---|---|---|---|
| C001 | <short scenario name> | <inputs that trigger this case> | <what the system must do> | <gotchas, edge concerns> | `test_C001_<slug>` |
| C002 | ... | ... | ... | ... | ... |

## Rules

- Every cell has a **stable ID** (C001, C002, ...). Once assigned, an ID is never reused even if the cell is removed.
- Tests should be named after the matrix cells where practical (`test_C014_slack_thread_continuation`).
- New branchy behavior in this subsystem means **adding a new cell first**, then implementing.
- Cells reference invariants by name when an invariant constrains the expected behavior.
- The matrix lives alongside the subsystem it describes (e.g., `docs/intake/decision-kernel-matrix.md`).

## Removed cells

Once a cell is removed, record it here so future contributors don't reuse the ID:

| Cell ID | Removed on | Reason |
|---|---|---|
| C00N | YYYY-MM-DD | <why> |

## Out of scope

Behavior explicitly *not* covered by this matrix and where it lives instead:

- <case>: see <other matrix or spec>
- <case>: handled by <invariant name>, not by branching here

## Notes

- If a new contributor would need to read implementation files to know what the system does in case <X>, add a cell for <X>.
- If a cell description begins with "should" or "probably," the cell isn't ready — tighten the language before considering the matrix complete.
