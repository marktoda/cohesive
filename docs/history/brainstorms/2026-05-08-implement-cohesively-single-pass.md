# Brainstorm — implement-cohesively single-pass redesign

### Current scope

- Collapse `cohesive:implement-cohesively` from a per-phase plan/execute/review loop to a single-pass shape: `writing-plans` with thin intent paragraph derived from the delta ledger → `executing-plans` → at end, parallel dispatch of `delta-coverage-reviewer` (whole-branch input contract) + `cohesive:review-diff`.
- Delete `docs/substrate/matrices/phase-derivation.md`.
- Delete `docs/substrate/gotchas/skipping-per-phase-plan.md`.
- Add `docs/substrate/gotchas/large-delta-mega-plan.md` documenting the abandonment cliff and naming the budget gate as structural mitigation.
- Reformulate `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` predicate vocabulary from phase-shaped to single-plan-shaped.
- Update `docs/substrate/matrices/artifact-placement.md` lifecycle entry for singular plan path.
- Update `agents/delta-coverage-reviewer.md` input contract from per-phase paths to whole-branch paths.
- Update `references/templates/chat-trailer.md` `implement-cohesively` row (drop Phases table; add verdict-synthesis-driven `## Code matches locked design`).
- Update `references/verdict-vocabulary.md` `implement-cohesively` table (replace `Phase Drift` with `Coverage Drift`).
- Update `docs/substrate/architecture/handoffs.md` (chain diagram, Approved-branch contract, terminal-verdict sections).
- Update `docs/substrate/architecture/composition-with-superpowers.md` (composition table: per-pass instead of per-phase).
- Update `skills/cohesively/SKILL.md` router chain description for the design route.

### Future pressure (not current scope)

- A future delta-size threshold tuning pass once real-world delta sizes inform the budget gate's value.
- A future deferred CI grep target for verdict-synthesis combinations (currently in skill body; promote to lint check when the v0.1 grep-target list expands).
- A future deterministic "is Superpowers installed" check replacing the current LLM-judgment detection in `implement-cohesively`'s Hard constraints.
- Possible future "split into N sub-passes" mechanism if the budget gate fires more often than a small-N tail suggests. v0.1 trusts the gate alone.

### Non-goals

- Do not change the upstream contract (`validate-rewrite` Approved verdict path + delta-ledger path + branch name remain the inputs).
- Do not reintroduce per-phase structure under any name (sub-passes, micro-phases, etc.). The simplification thesis is the lock.
- Do not promote verdict synthesis to a separate matrix file unless combinations explode beyond the v0.1 3×2 table.
- Do not add LLM self-grade in the plan as a substitute for structural reviewer dispatch. The dual end-reviewer gate is the only end check.
- Do not change `cohesive:review-diff`'s general behavior; the redesign uses it as-is.

## Design options

### Option A: Single-pass with parallel end reviewers (recommended)

**Summary:** `validate-rewrite` Approved → thin intent paragraph composed from delta ledger → `superpowers:writing-plans` → `superpowers:executing-plans` → parallel dispatch of `delta-coverage-reviewer` + `cohesive:review-diff` at end of run. Verdict synthesis is AND-shape with Substrate Drift winning on dual-fail.

**Substrate changes required:**
- Rewrite `skills/implement-cohesively/SKILL.md` (major): drop Phase 1/Phase 2 loop / Phase 2c escalation rule; keep Phase 3 (now end-of-run dual reviewer) and Phase 3.5 (cleanup, gated on Implemented).
- Reformulate `IMPLEMENTATION_PLAN_COVERS_DELTA.md` predicate from "every entry maps to ≥1 phase" to "every entry is covered by the single plan and verified by end-of-run dual reviewer dispatch."
- Delete `phase-derivation.md` and `skipping-per-phase-plan.md`.
- Update `artifact-placement.md` lifecycle row: `Per-phase plan` → `Per-pass plan`; cleanup target from `<...>-phase-*.md` to `<YYYY-MM-DD>-<slug>.md`.
- Add `large-delta-mega-plan.md` gotcha citing the budget gate as structural mitigation.
- Widen `delta-coverage-reviewer.md` input contract from `(delta-ledger excerpt, plan path, phase diff)` to `(delta-ledger path, plan path, branch diff)`. Drop the "Read other phases' plans or diffs" prohibition (line 110 of current agent file). Add §"Verdict mapping" if needed.
- Update `chat-trailer.md` `implement-cohesively` row: replace `## Phases` table with `## End-of-run review` block surfacing both reviewer verdicts; `## Code matches locked design` slot now driven by AND-shape synthesis.
- Update `verdict-vocabulary.md` `implement-cohesively` table: `Phase Drift` → `Coverage Drift`; user-facing label "**Coverage gap — re-run to fill** — repair the missing entries, then re-invoke."
- Update `handoffs.md` chain diagram + `validate-rewrite → implement-cohesively (Approved branch)` contract + terminal-verdict sections to drop phase-shaped vocabulary.
- Update `composition-with-superpowers.md` composition table: per-phase → per-pass for `writing-plans` and `executing-plans` rows.
- Update `cohesively/SKILL.md` router chain description for design route.

**Locality impact:**
- Decreases. The phase-derivation matrix as a centralized translation layer removes; thin intent paragraph composition is inline 3-line logic.
- Cohesive↔Superpowers seam loosens (one writing-plans + one executing-plans per pass, not per phase). Composition table simplifies.

**Future fit:**
- *Easy:* delta size scaling (writing-plans/executing-plans absorb internal granularity); verdict synthesis evolution (adding a third reviewer is a row in the subsection); resumption (executing-plans owns its own resumption per Superpowers).
- *Hard:* per-phase attribution of drift (lost — drift detected in aggregate at end). Acceptable per original conversation tradeoff.
- *Hard:* per-phase resumption checkpoint (lost — but this was Cohesive owning Superpowers' concern; releasing it is correct).

**Initial risks:**
- Mega-plan abandonment on large deltas (mitigated by budget gate at ~15 entries).
- Drift detected late rather than per-phase (mitigated by accepting more potential rework as the v0.1 cost; aggregate detection is sufficient given dual reviewer fresh-eyes).
- Verdict-synthesis subsection becomes a maintenance surface (mitigated by skill-body subsection rather than separate matrix).

### Option B: Single-pass with single end reviewer (review-diff only)

**Summary:** Same as A but skip `delta-coverage-reviewer` entirely; rely on `cohesive:review-diff` to verify both substrate alignment and delta coverage by reading the delta ledger as part of the review scope.

**Substrate changes required:** Same as A *plus* delete `agents/delta-coverage-reviewer.md` entirely. Update `cohesive:review-diff` skill body to add delta-ledger-path scope input and instruct the dispatched reviewer agents to verify coverage in addition to substrate alignment.

**Locality impact:** Decreases further than A. One reviewer dispatch instead of two. Cleaner separation of concerns is lost (review-diff carries two concerns).

**Future fit:** Easy: fewest reviewer dispatches. Hard: review-diff's prompt grows (must check both delta coverage AND substrate alignment); future tightening of either concern entangles them.

**Initial risks:** Reviewer-prompt entanglement. Coverage and substrate alignment are conceptually distinct lenses; folding into one prompt risks one lens crowding out the other under token budget pressure.

### Option C: Single-pass with composite verdict (no synthesis)

**Summary:** Same as A but render both reviewer verdicts side-by-side in the chat trailer without synthesis. User reads "Coverage: ✓ / Substrate: ✗" rather than a single label like "Substrate Drift."

**Substrate changes required:** Same as A but `verdict-vocabulary.md` grows two columns instead of one row update; chat trailer's `implement-cohesively` row carries two `**Verdict:**`-equivalent slots.

**Locality impact:** Equal to A on the file count but the chat trailer's verdict slot becomes non-canonical (every other skill has one verdict; `implement-cohesively` has two).

**Future fit:** *Hard:* chain edge from `implement-cohesively` to downstream skills (`finishing-a-development-branch`, `rewrite-specs`) currently keys on a single verdict; composite verdict requires every consumer to handle the new two-axis vocabulary.

**Initial risks:** User cognitive load (two verdicts to read instead of one). Downstream consumer drift if some consumers default to "Coverage" while others default to "Substrate."

## Pressure test summary

| Option | Cohesion | Substrate delta | Future fit | Locality | Main risk |
|---|---|---|---|---|---|
| A | High | Medium (~12 files) | Good | Decreases (good) | Mega-plan abandonment on large deltas |
| B | High | Medium-Large (~13 files; deletes an agent) | Good but reviewer-prompt entanglement | Decreases (good but concern-fold) | Coverage and substrate alignment crowd each other in one prompt |
| C | Medium | Medium (~12 files) | Poor (composite verdict propagates downstream) | Equal | Downstream consumer divergence on which verdict drives action |

## Breakage analysis

### Option A

- **Docs that would change:** `skills/implement-cohesively/SKILL.md`, `IMPLEMENTATION_PLAN_COVERS_DELTA.md`, `artifact-placement.md`, `delta-coverage-reviewer.md`, `chat-trailer.md`, `verdict-vocabulary.md`, `handoffs.md`, `composition-with-superpowers.md`, `cohesively/SKILL.md`. Plus deletes (`phase-derivation.md`, `skipping-per-phase-plan.md`) and add (`large-delta-mega-plan.md`).
- **Existing assumptions that break:**
  - `IMPLEMENTATION_PLAN_COVERS_DELTA` Rule #1 currently asserts "every entry maps to ≥1 phase" — predicate becomes "every entry maps to the single plan."
  - `delta-coverage-reviewer.md` "What you must not do" §"Read other phases' plans or diffs" obsoletes; agent now reads one plan and one whole-branch diff.
  - `composition-with-superpowers.md:9-17` table assumes per-phase invocations; rows update.
  - `chat-trailer.md:93` `implement-cohesively` row assumes a Phases table; replaces with end-of-run review block.
- **Behavior matrix impact:** `phase-derivation.md` deletes (only consumer is the deprecated phase loop); `artifact-placement.md` lifecycle row updates from `Per-phase plan` to `Per-pass plan` with singular cleanup target.
- **Invariant impact:** `IMPLEMENTATION_PLAN_COVERS_DELTA` reformulates extensively. Rule #1 (predicate vocabulary). Rule #2 (single plan path). Rule #3 (commit cites singular plan + stable IDs). Rule #4 (end-of-run dual reviewer Implemented; not per-phase Covered). Rule #5 (folds into Rule #4). Rule #6 (cleanup gating preserved with singular plan path).
- **Test guarantee impact:** No code tests; reviewer agent verdicts are the enforcement. `delta-coverage-reviewer` agent contract widens; verdict-synthesis becomes the new enforcement surface.
- **Gotchas triggered:**
  - Retired: `skipping-per-phase-plan.md` (no per-phase concept).
  - Modified: `plans-as-run-scaffolding.md` (singular plan, but principle stands).
  - New: `large-delta-mega-plan.md` (the abandonment-cliff scar this redesign accepts).
- **Locality / centralization concerns:** Decreases — phase-derivation matrix as centralized translation layer removes; thin intent paragraph composition is inline.
- **Easy invalid change still possible:**
  - Re-adding per-phase logic by convention (no structural prevention; reviewer-judged).
  - Skipping the dual end-reviewer dispatch (skill body Hard constraint enforces; same posture as current per-phase enforcement).
  - Setting the budget threshold too high so the gate never fires (reviewer-judged; tunable).

## Decision dialog

### Axes walked

- **Matrix fate:** agent picked Delete entirely; user ratified. Substrate evidence: `phase-derivation.md`'s only consumer is the per-phase loop being deleted; no other skill cites it normatively.
- **Intent translation:** agent picked Thin intent paragraph; user ratified. Substrate evidence: `composition-with-superpowers.md:28` calls out substrate-shape vs TDD-shape as load-bearing distinction; `skipping-per-phase-plan.md:34` flags raw-substrate-as-TDD-input as a substrate violation.
- **Mega-plan mitigation:** agent picked Delta-size budget gate; user ratified. Substrate evidence: existing 8-phase gate at `skills/implement-cohesively/SKILL.md:80` is the structural parallel; the abandonment cliff doesn't disappear with phases, it relocates.

### Sub-decisions

| # | Sub-decision | Tag | Outcome | Notes |
|---|---|---|---|---|
| 1 | Verdict synthesis | Confirm | AND-shape, Substrate Drift wins on dual-fail | Both Pass → Implemented. delta-coverage flags missing → Coverage Drift. review-diff flags substrate violation → Substrate Drift. Both fail → Substrate Drift wins (the rewrite was misformulated; coverage gaps are downstream). |
| 2 | Verdict vocabulary update | Default | `Phase Drift` → `Coverage Drift` | Mechanical follow-on of #1. |
| 3 | Plan path | Default | Singular `docs/history/plans/<YYYY-MM-DD>-<slug>.md` | No `-phase-N` suffix. |
| 4 | Cleanup name | Default | "Post-implementation cleanup" (was "Phase 3.5") | Preserves the gating-on-Implemented logic; renames the step. |
| 5 | Verdict-synthesis location | Default | Skill-body subsection, not separate matrix | Promote to matrix only if combinations explode. |
| 6 | Threshold value | Default | 15 entries | Tunable in follow-up substrate change. |

### Cross-branch graft check (Phase 4 opening, conv-mode)

- **Hybrid candidate surfaced?** No. Q15 (premature centralization): leaf de-centralizes (phase-derivation matrix deletes); no graft needed. Q19 (future idea this makes hard): per-phase resumption is lost, but executing-plans owns its own resumption per Superpowers — releasing this concern is correct, not a substrate gap. Q20 (appears-easy-but-isn't): verdict synthesis collapses 15 combinations to 3 outputs; mitigation is enumerating combinations explicitly in skill-body subsection. No graft from non-chosen axes (Repurpose matrix, Opt-in split) reduces the leaf's main risk.
- **Cleared?** Yes (proceeded to remaining battery).

## Recommendation

**Direction:** Option A — Single-pass `implement-cohesively` with parallel end reviewers (`delta-coverage-reviewer` + `cohesive:review-diff`), thin intent paragraph composed from the delta ledger, delta-size budget gate at ~15 entries, AND-shape verdict synthesis with Substrate Drift winning on dual-fail.

**Main risk:** Mega-plan abandonment on large deltas — collapsing per-phase scope into one writing-plans/executing-plans pass relocates the abandonment cliff from "per-phase escalation rule" to "single-pass context overflow."

**Structural mitigation:** Delta-size budget gate at ~15 entries surfaces the size and pauses for user confirmation before invoking writing-plans, paired with a new gotcha `docs/substrate/gotchas/large-delta-mega-plan.md` documenting the cliff and naming the gate as the structural enforcement. The threshold value is tunable in a follow-up substrate change as real-world delta sizes inform it.

**Required substrate before implementation:**

- **Specs:**
  - Rewrite `skills/implement-cohesively/SKILL.md` removing Phase 1/Phase 2 loop / Phase 2c escalation; keep end-of-run dual reviewer dispatch (rename to fit single-pass framing); preserve cleanup step gated on Implemented.
  - Update `docs/substrate/architecture/handoffs.md` chain diagram, `validate-rewrite → implement-cohesively (Approved branch)` contract, and terminal-verdict sections.
  - Update `docs/substrate/architecture/composition-with-superpowers.md` composition table (per-phase → per-pass).
  - Update `skills/cohesively/SKILL.md` router chain description for design route.
- **Matrices:**
  - Update `docs/substrate/matrices/artifact-placement.md` lifecycle row: `Per-phase plan` → `Per-pass plan`; cleanup target singular.
  - Delete `docs/substrate/matrices/phase-derivation.md`.
- **Named invariants:**
  - Reformulate `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` predicate vocabulary from phase-shaped to single-plan-shaped. Rules #1–#6 all touched.
- **Tests / checks:**
  - Update `agents/delta-coverage-reviewer.md` input contract from per-phase to whole-branch; remove "Read other phases' plans or diffs" prohibition; add §"Verdict mapping" subsection if needed.
  - Update `references/templates/chat-trailer.md` `implement-cohesively` row body-block specification.
  - Update `references/verdict-vocabulary.md` `implement-cohesively` table (`Phase Drift` → `Coverage Drift`).
- **Gotchas:**
  - Delete `docs/substrate/gotchas/skipping-per-phase-plan.md`.
  - Modify `docs/substrate/gotchas/plans-as-run-scaffolding.md` (singular plan path; principle stands).
  - Add `docs/substrate/gotchas/large-delta-mega-plan.md` documenting the abandonment cliff.
- **Semantic linters (proposed):** None this pass. A future deferred CI grep target could verify verdict-synthesis combinations are enumerated; deferred.

### Next

Rewrite the docs to make this direction true. *(`cohesive:rewrite-specs`.)* **Files to edit:** `skills/implement-cohesively/SKILL.md` (major rewrite), `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` (reformulate Rules #1–#6), `docs/substrate/matrices/artifact-placement.md` (lifecycle row), `agents/delta-coverage-reviewer.md` (input contract), `references/templates/chat-trailer.md` (`implement-cohesively` row), `references/verdict-vocabulary.md` (`implement-cohesively` table), `docs/substrate/architecture/handoffs.md` (chain diagram + contracts + terminal verdicts), `docs/substrate/architecture/composition-with-superpowers.md` (composition table), `skills/cohesively/SKILL.md` (router chain description), `docs/substrate/gotchas/plans-as-run-scaffolding.md` (modify for singular plan); add `docs/substrate/gotchas/large-delta-mega-plan.md`; delete `docs/substrate/matrices/phase-derivation.md` and `docs/substrate/gotchas/skipping-per-phase-plan.md`. Slug: `implement-cohesively-single-pass`. Classification: Mixed (substrate change to a flagship Cohesive skill).
