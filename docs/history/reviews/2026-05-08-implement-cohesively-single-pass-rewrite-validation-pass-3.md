# Rewrite Validation Review — implement-cohesively single-pass redesign (pass 3)

**Verdict:** Approved — ready to implement

## Architectural reflection

How it feels now: the rewrite collapses an orchestration layer Cohesive never structurally needed and replaces it with two thin substrate-shape moves — composing the intent paragraph and dispatching two reviewers in parallel. The resulting shape is small enough to hold in head: Step 1 (intent + budget gate) → Step 2 (executing-plans) → Step 3 (dual reviewer) → Step 3.5 (cleanup). The AND-shape verdict table is the load-bearing seam, and it pins itself: only `Covered + Pass/Pass-with-notes` reaches Implemented; everything else routes to a named repair edge. Substrate Drift winning on dual-fail is the right call — when both fail, the rewrite was the wrong size, not the implementation.

- **Easier downstream:** adding a new chain skill or new reviewer no longer needs to participate in phase-derivation; it joins the dispatch pair or sits on a different chain edge. The verdict vocabulary is now finite and listed in one place per surface (skill body, handoffs, verdict-vocabulary, delta-coverage agent).
- **Harder downstream:** the abandonment cliff is now reviewer-judged at the user's confirmation. A 16-entry delta produces no warning; a 14-entry plan that happens to be heavyweight produces no warning either. The 15-threshold is a guess until real-world data informs it (and the ledger names this deferral).
- **Load-bearing on memory:** the intent-paragraph "Make / Constraints / Acceptance" three-line format is convention without grep enforcement; an implementer who paraphrases will not be caught until reviewer attention.

## Executive judgment

A future contributor reading these specs can implement the system without the original architect. The named invariant `IMPLEMENTATION_PLAN_COVERS_DELTA` reads end-to-end against the SKILL body, the chain edges in handoffs.md, the AND-shape table, and the lifecycle row in artifact-placement. Pass-3 surfaced one Medium (`scope.md:29` stale phase-shape sentence) and one Low (`Aborted` row missing from synthesis table); both closed inline post-pass.

## Delta at a glance

- **Files:** 13 rewritten, 2 added, 2 removed/deprecated
- **Conceptual changes:** per-phase loop → single-pass implementation; per-phase plan → per-pass plan; per-phase cross-review → end-of-run dual reviewer dispatch; AND-shape verdict synthesis introduced; `Phase Drift` verdict → `Coverage Drift` verdict
- **Named invariants:** `IMPLEMENTATION_PLAN_COVERS_DELTA` (rules #1–#6 reformulated to single-pass shape; rules #4 and #5 collapsed)
- **Behavior matrices:** `phase-derivation.md` (removed); `artifact-placement.md` (lifecycle row `Per-phase plan` → `Per-pass plan`)
- **Gotchas:** `large-delta-mega-plan.md` (added); `skipping-per-phase-plan.md` (retired); `plans-as-run-scaffolding.md` (modified)
- **Semantic linters:** `validate_plugin.sh` Check 13f rewritten; Check 13m added in pass-2 to prevent `phase by phase` literal regression
- **Tests proposed:** none

## Important issues

### I1. Stale phase-shape sentence in scope.md (closed inline)

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** `docs/substrate/conventions/scope.md:29` claimed "Cohesive owns substrate and phase shape, Superpowers owns plan writing and TDD execution inside each phase" — contradicting every other normative surface. Repair pass 1 §B4 closed `scope.md:31` but missed line 29 in the same paragraph. Check 13m's grep scope (`skills/`, `agents/`, `references/`) does not cover `docs/substrate/conventions/`, so the regression class B1 prevented does not catch this.
- **Evidence:** `docs/substrate/conventions/scope.md:29`.
- **Closed inline:** Replaced with `the principle is that Cohesive owns substrate-shaped framing (intent paragraph + delta-size budget gate + end-of-run dual reviewer dispatch), Superpowers owns plan writing and TDD execution.`
- **Substrate artifact:** spec.

### I2. Aborted verdict missing from synthesis table (closed inline)

- **Severity:** Low
- **Category:** Domain model
- **Why it matters:** §"Verdict synthesis" table in `skills/implement-cohesively/SKILL.md:106-111` was the load-bearing pin for verdict combinations. `Aborted` was documented in prose immediately after but absent from the table — a future contributor reading only the table would miss it as a verdict.
- **Evidence:** `skills/implement-cohesively/SKILL.md:115` (prose) vs `:106-111` (table without Aborted row).
- **Closed inline:** Added a fifth row to the synthesis table: `| (not dispatched) | (not dispatched) | **Aborted** (Step 3 did not run — the user paused before reviewers dispatched, e.g., declined the budget gate or stopped during Step 2) |`. The prose paragraph below is collapsed into the table row's parenthetical.
- **Substrate artifact:** spec.

## Vague language to tighten

- `skills/implement-cohesively/SKILL.md:74` — "tighten or relax in a follow-up substrate change as real-world delta sizes inform the budget" reads aspirational. Acceptable as a deferral note. Low; not closed.
- `agents/delta-coverage-reviewer.md:99` — "Medium / Low" merged into one severity row; cohesion-rubric §"Severity vocabulary" treats them separately. Low; not closed.

## What looked right

- The AND-shape verdict synthesis table is the cleanest substrate move in this rewrite. Four (now five, with Aborted) rows = an entire phase-derivation matrix retired without losing structural enforcement. "Substrate Drift wins on dual-fail" is the right call and is justified inline.
- The `large-delta-mega-plan.md` gotcha closes the abandonment cliff at the right altitude — names the relocation honestly, names two tempting wrong fixes by name, and pins the structural mitigation (Step 1 budget gate) to a runtime path. This is the move that justifies single-pass against future readers' "but what about large deltas?" objection.
- Repair pass 2's Check 13m promotion to convention-with-grep is exactly the right enforcement shape — it catches the regression class without freezing the rewording, mirroring the convention-with-grep pattern from `style-guide-rot.md`.

### Next

Close in same worktree → merge.
