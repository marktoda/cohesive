# Phase Derivation Behavior Matrix

**Status:** Draft
**Last reviewed:** 2026-05-04
**Owner:** Mark Toda

## Purpose

`cohesive:implement-cohesively` derives an ordered list of phases from a design delta ledger. Each phase carries a substrate-shaped intent that gets passed to `superpowers:writing-plans` as input. This matrix names the rules: which delta-ledger sections produce phases, what intent shape each phase carries, and what predecessor relationships hold.

The matrix is normative. When a delta-ledger entry matches a row, `implement-cohesively` derives that row's phase shape. When an entry matches no row, the entry is uncovered — Phase 1 of `implement-cohesively` refuses to advance until every entry has a row match.

This matrix is the substrate-shaped seam between the design delta ledger (substrate-shape, produced by `rewrite-specs`) and the per-phase plan (TDD-shape, produced by `superpowers:writing-plans`). Naming the seam here is what prevents implementation drift across the rewrite ↔ implementation boundary.

## Cells

| Cell ID | Delta-ledger section | Entry shape | Phase intent shape | Predecessor relationships | Notes |
|---|---|---|---|---|---|
| P001 | Files rewritten | `<path>` with Before/After/Reason | "Make `<path>`'s normative claim true in code: <After-summary>. Touch <code paths likely affected>. Acceptance: <After-claim verifiable in code/test/CI>." | None inherent — but if Conceptual changes (P003) renamed a concept this file uses, P003 must precede. | One phase per file is the default; coalesce when two files describe the same behavior. |
| P002 | Files added | `<path>` with one-line purpose | "Implement the artifact described at `<path>`: <purpose-summary>. Acceptance: a future reader of `<path>` could reproduce the behavior from the doc alone." | If the new doc names a behavior matrix or invariant, P004 or P005 may already cover it; check before producing a P002 phase. | Often P002 doesn't produce a new phase if P004/P005 covers the same ground. |
| P003 | Conceptual changes | Old concept → New concept (Replaced/Merged/Removed/Tightened/Renamed) | "Apply the rename/merge/split: every reference to `<old>` becomes `<new>` in code, tests, comments, types, and CI. Acceptance: a grep for `<old>` returns 0 hits outside historical docs." | Must precede every P001 phase touching files that reference the old name. | The phase touches every file in the codebase; size proportional to the codebase's coupling to the old name. |
| P004 | Behavior matrices | New matrix path (cells added) or existing matrix (cells added/removed) | "Implement tests for the matrix cells listed in `<matrix-path>`: every cell with a Tests column entry gets a test that pins the cell's expected behavior. Acceptance: every cell ID in the matrix has a corresponding test name." | Must precede phases that branch on the matrix's cells (e.g., a P001 phase implementing the branchy behavior depends on P004 establishing the test pins). | Tests-first per the matrix discipline; implementation may follow inside the same phase if small. |
| P005 | Named invariants | `INVARIANT_NAME` — added/strengthened/weakened/removed | "Add the invariant `<NAME>` and its enforcement: implement the test/type/constraint/linter/runtime-wrapper/CI-check listed in the invariant doc's Enforcement section. Acceptance: the enforcement structurally fails when the invariant is violated." | Must precede phases that touch the invariant's runtime paths. | One phase per invariant; do not bundle multiple invariants into one phase — enforcement may drift. |
| P006 | Gotchas | New gotcha doc path | "Implement the test/lint/check listed in the gotcha's 'Tests / checks that preserve this' section. Acceptance: the structural enforcement catches a regression of the symptom." | None inherent. | If the gotcha names no structural enforcement, no phase is produced — the gotcha lives as reviewer-memory substrate, not a runtime check. Surface this in Phase 1 coverage table as "covered (no structural test)". |
| P007 | Tests / checks proposed (not yet implemented) | Free-text description of behavior to pin | "Implement the test described: `<description>`. Acceptance: the test fails when the proposed behavior regresses." | Often co-occurs with P001 (a file's behavior change ships with its test) or P004 (a matrix cell's test). Coalesce with the related phase when possible. | If Phase 1 finds a P007 entry uncovered by any other phase, produce a dedicated phase for it. |
| P008 | Semantic linter specs (proposed) | Linter description | If the rewrite marked the linter as "deferred" or "proposed, not implemented": **no phase produced**. The matrix entry is acknowledged in Phase 1's coverage table with status `Deferred`. If the rewrite explicitly said the linter ships in this implementation pass: "Implement the linter described: <description>. Acceptance: the linter fires on the named violation in a fixture; the linter is wired into CI." | None inherent. | The default is Deferred; this is the most common case. Explicit "ships in this pass" must appear in the ledger's text for a phase to be produced. |

## Default cells (used when no specific row matches)

| Cell ID | Scenario | Behavior | Why |
|---|---|---|---|
| P900 | Delta-ledger entry matches none of P001–P008 | Phase 1 of `implement-cohesively` flags as Uncovered and refuses to advance. | Coverage is structural per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`. |
| P901 | Delta-ledger has zero entries (empty rewrite) | `implement-cohesively` recommends abort: a rewrite with no delta has nothing to implement. | Implementation requires delta. |
| P902 | All delta-ledger entries are Deferred-class (P008-only ledger) | `implement-cohesively` recommends abort: nothing to implement in this pass. | Same reason. |

## Rules

- Every cell has a stable ID (P001..P0NN). Once assigned, an ID is never reused even if the cell is removed.
- Phase order obeys the predecessor relationships in the table. When two phases have no inter-dependency, the implementer may interleave or order by code-locality concerns; the matrix does not enforce a single global order.
- A delta-ledger entry may produce more than one phase (rare; e.g., a Files-rewritten entry that also adds a new invariant — but typically the invariant gets its own P005 phase and the file change becomes P001 dependent on P005).
- Coalescing phases is allowed when their delta entries are tightly coupled (same subsystem, same file set, same TDD plan would result). The Phase 1 coverage table must still list every individual delta entry with its phase number.
- When a delta-ledger entry could match more than one cell (e.g., a Files-added that is itself a behavior matrix), the more-specific cell wins (P004 over P002).

## Removed cells

| Cell ID | Removed on | Reason |
|---|---|---|
| _none yet_ | | |

## Out of scope

- **Plan-shape inside a phase.** This matrix produces *phase intent* (substrate-shape). The TDD-shape inside the plan is `superpowers:writing-plans`' job. The matrix names what `writing-plans` is asked to produce a plan for, not how the plan structures its tasks.
- **Cross-review verdict thresholds.** Whether a phase is Covered/Drift/Incomplete is `delta-coverage-reviewer`'s job. The matrix produces phases; the reviewer judges them.
- **Branch-strategy decisions.** Whether implementation lands on the rewrite's branch, a child branch, or a fresh branch off main is `implement-cohesively`'s "Branch shape" section. The matrix derives phases regardless of branch shape.

## Notes

- If an `implement-cohesively` invocation finds a delta-ledger entry it cannot map to a cell, that's substrate work: either the cell list is incomplete (add a row here) or the ledger entry is malformed (the rewrite needs repair). Do not silently skip uncovered entries.
- If a future contributor would need to read `implement-cohesively`'s implementation to know what intent shape gets passed to `writing-plans` for some delta-ledger section, add a row to this matrix.
- If a cell description begins with "should" or "probably," the cell isn't ready — tighten the language before considering the matrix complete.

## Related substrate

- **`${CLAUDE_PLUGIN_ROOT}/skills/implement-cohesively/SKILL.md`** §"Process" — the skill body that consumes this matrix.
- **`${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`** — the named invariant that requires every delta entry to map to ≥1 phase.
- **`${CLAUDE_PLUGIN_ROOT}/references/templates/design-delta-ledger.md`** — the source-side artifact this matrix consumes.
- **`${CLAUDE_PLUGIN_ROOT}/agents/delta-coverage-reviewer.md`** — the per-phase reviewer that uses this matrix's predecessor rules to judge plan-implementation agreement.

## History

- 2026-05-04 — Created. Substrate-shaped seam between design delta ledger and `superpowers:writing-plans`. Cell IDs P001–P008 cover the eight ledger-section-to-phase mappings. P900–P902 are the default rules expanded into matrix cells so default behavior is testable.
