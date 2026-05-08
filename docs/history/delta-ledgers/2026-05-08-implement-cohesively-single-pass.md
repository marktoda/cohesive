# Design Delta Ledger — implement-cohesively single-pass redesign

**Date:** 2026-05-08
**Worktree / branch:** `.claude/worktrees/design+implement-cohesively-single-pass` on `worktree-design+implement-cohesively-single-pass`
**Approved direction:** Single-pass `implement-cohesively` with parallel end reviewers (`delta-coverage-reviewer` + `cohesive:review-diff`), thin intent paragraph composed from delta ledger, delta-size budget gate at ~15 entries, AND-shape verdict synthesis with Substrate Drift winning on dual-fail.

This ledger records the substrate change collapsing the per-phase plan/execute/review loop in `cohesive:implement-cohesively` to a single-pass shape with an end-of-run dual reviewer dispatch.

This rewrite is **Mixed**. Design-layer changes: skill purpose narrowing for `implement-cohesively` (single-pass instead of phase loop), verdict vocabulary (`Phase Drift` → `Coverage Drift`), composition seam loosening (per-phase → per-pass) in `composition-with-superpowers.md`, chain-exit contract changes in `handoffs.md`. Implementation changes: SKILL.md body rewrite, invariant rule reformulation, gotcha additions/retirements, validate_plugin.sh Check 13f rewrite, ripple updates across docs that referenced phase-shaped vocabulary.

## Delta at a glance

- **Files:** 13 rewritten, 2 added, 2 removed/deprecated
- **Conceptual changes:** per-phase loop → single-pass implementation; per-phase plan → per-pass plan; per-phase cross-review → end-of-run dual reviewer dispatch; AND-shape verdict synthesis introduced; `Phase Drift` verdict → `Coverage Drift` verdict
- **Named invariants:** `IMPLEMENTATION_PLAN_COVERS_DELTA` (rules #1–#6 reformulated to single-pass shape; rules #4 and #5 collapsed)
- **Behavior matrices:** `phase-derivation.md` (removed); `artifact-placement.md` (lifecycle row `Per-phase plan` → `Per-pass plan`)
- **Gotchas:** `large-delta-mega-plan.md` (added — the abandonment-cliff scar that relocates to single-pass); `skipping-per-phase-plan.md` (retired — no per-phase concept); `plans-as-run-scaffolding.md` (modified — singular plan path; principle stands)
- **Semantic linters:** `validate_plugin.sh` Check 13f rewritten to grep IMPLEMENTATION_PLAN_COVERS_DELTA + large-delta-mega-plan instead of phase-derivation matrix
- **Tests proposed:** none
- **Deferred (out of scope this pass):** delta-size threshold tuning (15 is a v0.1 default; tuning follows real-world delta sizes); deferred CI grep target for verdict-synthesis combinations; promotion of verdict-synthesis to a separate matrix file (skill-body subsection suffices for v0.1)

## Files rewritten

- `skills/implement-cohesively/SKILL.md`
  - **Before:** Per-phase loop where Cohesive owns phase derivation, per-phase reviewer dispatch, and final substrate review (Phases 1, 2, 2a/2b/2c, 3, 3.5, plus Step 0/4 bookends). Hard constraint #2 required composition with Superpowers per phase. Hard constraint #3 required per-phase cross-review. Hard constraint #4 required structural delta coverage via Phase 1 coverage table. Hard constraint #5 required Phase 3 final substrate review. Hard constraint #6 required Phase 3.5 cleanup gating. Phase 2c escalation rule capped repair at one cycle then halted with Phase Drift verdict.
  - **After:** Single-pass implementation. Step 1 composes thin intent paragraph from delta ledger and dispatches `superpowers:writing-plans` once; surfaces delta-size budget gate above 15 entries. Step 2 dispatches `superpowers:executing-plans` once. Step 3 dispatches `delta-coverage-reviewer` and `cohesive:review-diff` in parallel and synthesizes the verdict AND-shape per a new §"Verdict synthesis" subsection. Step 3.5 cleanup gated on Implemented (the synthesized verdict). Hard constraints reduced to six: #3 collapsed (single plan covers delta), #4 introduced (end-of-run dual reviewer dispatch mandatory), #5 reformulated (cleanup gating), #6 introduced (delta-size budget gate). Phase 2c escalation rule removed (no per-phase concept).
  - **Reason:** Per-phase loop was empirically slow and abandonment-prone (Phase 2c escalation firing on noise that single-pass execution would have routed around); per-phase reviewer dispatches were largely redundant with the final review-diff. Single-pass collapses the orchestration layer Superpowers already handles internally.

- `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`
  - **Before:** Six rules. Rule #1: every delta entry maps to ≥1 phase. Rule #2: per-phase plan persisted at `<...>-phase-<N>.md`. Rule #3: phase commits cite plan path + delta IDs. Rule #4: per-phase `delta-coverage-reviewer` Covered verdict required. Rule #5: end with `cohesive:review-diff` final substrate check. Rule #6: Phase 3.5 cleanup gating.
  - **After:** Five rules. Rule #1: every non-Deferred entry covered by the single per-pass plan. Rule #2: single per-pass plan persisted at `<YYYY-MM-DD>-<slug>.md`. Rule #3: implementation commits cite plan path + delta IDs. Rule #4: end-of-run parallel dispatch of `delta-coverage-reviewer` + `cohesive:review-diff` with AND-shape verdict synthesis (Substrate Drift wins on dual-fail). Rule #5: Step 3.5 cleanup gating on Implemented.
  - **Reason:** Predicate vocabulary changes from phase-shaped to single-pass-shaped. Rule #4 and Rule #5 collapse because the dual reviewer dispatch is one combined gate rather than two sequential checks.

- `docs/substrate/matrices/artifact-placement.md`
  - **Before:** Lifecycle row `Per-phase plan` with cleanup target `git rm docs/history/plans/<YYYY-MM-DD>-<slug>-phase-*.md`.
  - **After:** Lifecycle row `Per-pass plan` with cleanup target `git rm docs/history/plans/<YYYY-MM-DD>-<slug>.md`. Phase 3.5 references in §"Skill behavior" and §"Lifecycle by artifact category" updated to Step 3.5.
  - **Reason:** Single per-pass plan replaces N per-phase plans; cleanup target glob simplifies.

- `agents/delta-coverage-reviewer.md`
  - **Before:** Input contract: delta-ledger excerpt + plan path + phase diff. "What you must not do" included "Read other phases' plans or diffs" (per-phase isolation).
  - **After:** Input contract: delta-ledger path + per-pass plan path + whole-branch diff. "What you must not do" removes per-phase isolation rule; adds "Duplicate `cohesive:review-diff`'s work" (separation-of-concerns rule for the new dual-reviewer architecture). Token discipline raised from ≤400 to ≤500 words / ≤8 findings to accommodate whole-branch coverage tables.
  - **Reason:** Whole-branch input contract widens scope from per-phase to per-pass; the agent now reviews the entire implementation pass against the delta ledger.

- `references/templates/chat-trailer.md`
  - **Before:** `implement-cohesively` row body block: `## Code matches locked design` slot fed by Phase 3 final review only; `## Phases` table; `## Branch state` with plans count.
  - **After:** `## Code matches locked design` slot synthesized AND-shape from dual reviewer dispatch; `## End-of-run review` block surfacing both reviewer verdicts with paths; `## Branch state` with singular plan path. `Phase Drift` verdict in render-conditions list replaced with `Coverage Drift`.
  - **Reason:** Body block reflects the new dual-reviewer architecture and verdict-synthesis surface.

- `references/verdict-vocabulary.md`
  - **Before:** `implement-cohesively` table: Implemented / Phase Drift / Substrate Drift / Aborted.
  - **After:** Implemented / Coverage Drift / Substrate Drift / Aborted. User-facing label for Coverage Drift: "Coverage gap — re-run to fill — the implementation missed delta entries; repair the named gaps, then re-run." Aborted user-facing label updated from "branch state is whatever the last successful phase committed" to "branch state is whatever the last implementation commit landed."
  - **Reason:** No phase concept; verdict reflects what the coverage reviewer flagged.

- `docs/substrate/architecture/handoffs.md`
  - **Before:** Approved-branch contract said `implement-cohesively` derives phases from delta ledger via phase loop. Chain exits section had `implement-cohesively → implement-cohesively resume (Phase Drift)` with phase-derivation-table re-derivation rules. Failure modes referenced phase-derivation matrix.
  - **After:** Approved-branch contract says Step 1 composes thin intent paragraph from delta ledger. Chain exits has `implement-cohesively → implement-cohesively resume (Coverage Drift)` with thin-intent-paragraph re-composition rules; Substrate Drift exit now references AND-shape synthesis ("wins on dual-fail"). Aborted exit references Step 1 budget gate as a trigger condition.
  - **Reason:** Handoff contracts must reflect the new chain-exit verdict labels and the new structural seam (intent paragraph instead of phase derivation).

- `docs/substrate/architecture/composition-with-superpowers.md`
  - **Before:** "Cohesive owns the delta-derived phase shape that drives implementation; Superpowers owns the per-phase plan and TDD execution inside each phase." Composition table had per-phase rows for `writing-plans` and `executing-plans`.
  - **After:** "Cohesive owns substrate-shaped framing: the thin intent paragraph derived from the delta ledger, the delta-size budget gate, and the end-of-run dual reviewer dispatch." Composition table has per-pass rows. References to `phase-derivation.md` and `skipping-per-phase-plan.md` removed; `large-delta-mega-plan.md` added.
  - **Reason:** The seam between Cohesive and Superpowers shifts from per-phase orchestration to per-pass framing.

- `skills/cohesively/SKILL.md`
  - **Before:** Build gate description and §Required behavior referenced "per-phase verification of the rewrite", "phase loop", and "per-phase composition" of `writing-plans` + `executing-plans`.
  - **After:** Per-pass verification; single-pass writing-plans + executing-plans + end-of-run dual reviewer dispatch.
  - **Reason:** Router chain description must reflect the new shape.

- `docs/substrate/gotchas/plans-as-run-scaffolding.md`
  - **Before:** Title: "per-phase plans are run scaffolding". Path glob: `docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md`. Symptom referenced phase commits citing plan paths. Correct pattern referenced Phase 3.5.
  - **After:** Title: "per-pass implementation plans are run scaffolding". Path glob: `docs/history/plans/<YYYY-MM-DD>-<slug>.md`. Symptom and correct pattern updated to single-pass shape with Step 3.5 cleanup. History entry added for the 2026-05-08 collapse.
  - **Reason:** Gotcha applies to the new singular plan path; the principle (run scaffolding ≠ decision records) is unchanged.

- `docs/substrate/gotchas/no-implementation-handoff.md`
  - **Before:** Correct pattern listed "derives phases from the delta via the phase-derivation matrix" and "for each phase, invokes writing-plans + executing-plans, then dispatches delta-coverage-reviewer for cross-review". Related conventions referenced phase-derivation matrix. Tests/checks referenced Check 13f greping for phase-derivation matrix.
  - **After:** Correct pattern: composes thin intent paragraph; surfaces budget gate; invokes writing-plans + executing-plans once per pass; dispatches dual reviewer pair in parallel at end-of-run; synthesizes AND-shape. Related conventions reference IMPLEMENTATION_PLAN_COVERS_DELTA + large-delta-mega-plan. Tests/checks updated to match.
  - **Reason:** Failure-mode prevention narrative reflects the new shape.

- `docs/substrate/conventions/substrate-layout.md`
  - **Before:** §"Cleanup at handoff" referenced Phase 3 / Phase 3.5 / Phase Drift. Forensic recovery edges referenced per-phase plan adds.
  - **After:** Step 3 / Step 3.5 / Coverage Drift; singular plan add/rm in forensic-recovery edges. §Failure modes references Step 3.5.
  - **Reason:** Convention vocabulary aligns with the renamed steps.

- `docs/substrate/conventions/dispatch-protocol.md`
  - **Before:** "implement-cohesively SKILL.md Phase 2c (per phase) — dispatches delta-coverage-reviewer once per implementation phase". Per-phase fence rule.
  - **After:** "implement-cohesively SKILL.md Step 3 (end of run) — dispatches delta-coverage-reviewer once per implementation pass in parallel with cohesive:review-diff (Skill-tool dispatch). Separation-of-concerns fence." Verdict synthesis cited.
  - **Reason:** The dispatch site moves from per-phase to end-of-run; the fence's structural meaning changes from per-phase isolation to dual-reviewer separation of concerns.

- `docs/substrate/conventions/scope.md`
  - **Before:** Build gate cell: "Phase derivation from delta ledger; per-phase cross-review against the locked design; spec-coverage verdict".
  - **After:** "Thin intent paragraph derived from delta ledger; delta-size budget gate; end-of-run dual reviewer dispatch with AND-shape verdict synthesis; spec-coverage verdict".
  - **Reason:** Scope description reflects what `implement-cohesively` actually does after the redesign.

- `docs/substrate/conventions/skill-shape.md`
  - **Before:** Code-producing skills section: "implement-cohesively orchestrates a phase loop where superpowers:executing-plans produces code inside each phase".
  - **After:** "implement-cohesively orchestrates a single implementation pass where superpowers:executing-plans produces code". Single dispatch, not per-phase.
  - **Reason:** Skill-shape exception is unchanged in spirit; phrasing reflects single-pass shape.

- `docs/substrate/architecture/fresh-eyes-review.md`
  - **Before:** "implement-cohesively's per-phase cross-review" listed among Cohesive's review skills.
  - **After:** "implement-cohesively's end-of-run dual reviewer dispatch".
  - **Reason:** Fresh-eyes property still applies; the dispatch shape changes.

- `docs/substrate/architecture/skills.md`
  - **Before:** §implement-cohesively design-layer entry described phase derivation, per-phase composition, phase commits. Status table had four-verdict vocabulary including Phase Drift.
  - **After:** §implement-cohesively redescribes thin intent paragraph composition, single per-pass dispatch, end-of-run dual reviewer dispatch, AND-shape synthesis, Step 3.5 gating. Status table verdict vocabulary updated to include Coverage Drift.
  - **Reason:** The per-skill design layer must reflect the new substrate.

- `ARCHITECTURE.md`
  - **Before:** Composition table referenced per-phase plan-writing/execution. Substrate-as-design row referenced delta-derived phase shape. Risk row referenced "Per-phase reviewer cost" with 10-phase example. Header table "Modify the implementation phase loop" entry pointed to phase-derivation matrix.
  - **After:** Per-pass plan-writing/execution. Cohesive owns substrate-shaped framing (thin intent + budget gate + dual-reviewer dispatch). Risk row replaced with "Mega-plan abandonment on large deltas" referencing the budget gate. "Modify the implementation pass" entry points to delta-coverage-reviewer agent + IMPLEMENTATION_PLAN_COVERS_DELTA + handoffs.md.
  - **Reason:** Top-level architecture surface must reflect the new shape.

- `README.md`
  - **Before:** "Cohesive shapes substrate and implementation phases; Superpowers shapes per-phase plans and code."
  - **After:** "Cohesive shapes substrate and the implementation pass; Superpowers shapes per-pass plans and code."
  - **Reason:** External-facing description aligns with the new shape.

- `AGENTS.md`
  - **Before:** `IMPLEMENTATION_PLAN_COVERS_DELTA` description referenced "every entry maps to ≥1 phase; per-phase plan persisted; delta-coverage-reviewer Covered verdict required."
  - **After:** "Every entry covered by the single per-pass plan; end-of-run dual reviewer dispatch (delta-coverage-reviewer + cohesive:review-diff) with AND-shape verdict synthesis required."
  - **Reason:** Contributor-facing invariant summary aligns with the rewritten invariant.

- `references/templates/design-delta-ledger.md`
  - **Before:** "The 8-category list is also the substrate-shape input to cohesive:implement-cohesively Phase 1's coverage table."
  - **After:** "Step 1's thin intent paragraph composition." Also: "future implement-cohesively Phase 1 announcement" → "future implement-cohesively Step 1 chat surface".
  - **Reason:** Template preamble references the renamed step.

- `scripts/validate_plugin.sh`
  - **Before:** Check 13f greped `skills/implement-cohesively/SKILL.md` for both `docs/substrate/matrices/phase-derivation.md` AND `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md`.
  - **After:** Check 13f greps for `IMPLEMENTATION_PLAN_COVERS_DELTA.md` AND `large-delta-mega-plan.md`. Comments updated to reflect the new structural pin (single-pass coverage rule + abandonment-cliff gotcha).
  - **Reason:** The phase-derivation matrix is deleted; the new structural pin is the abandonment-cliff gotcha that names the budget gate as mitigation.

## Files added

- `docs/substrate/gotchas/large-delta-mega-plan.md` — names the mega-plan abandonment cliff that single-pass implementation introduces; cites the Step 1 delta-size budget gate (default threshold 15 entries) as the structural mitigation.

- `docs/cohesive/discovery/implement-cohesively-single-pass.md` — discovery report from the brainstorm-design Step 0 internal dispatch; documents substrate inventory and missing-memory items the redesign must address. (Run scaffolding; will be cleaned up at Step 3.5 of the implementation pass that lands this rewrite.)

## Files removed or deprecated

- `docs/substrate/matrices/phase-derivation.md` — deleted. The matrix's only consumer was the per-phase loop; with phases gone, the matrix has no normative role. The substrate-shape→TDD-shape translation it encoded survives as the thin intent paragraph composed inline at `implement-cohesively` Step 1.

- `docs/substrate/gotchas/skipping-per-phase-plan.md` — deleted. The gotcha's premise (per-phase plans are load-bearing for cross-review) is structurally invalidated by the redesign — there are no phases. The remaining concern (don't skip writing-plans) is preserved as the first row of `implement-cohesively`'s anti-patterns table.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| Per-phase loop (Phase 1 / Phase 2 / Phase 2a/2b/2c / Phase 3 / Phase 3.5) | Single-pass implementation (Step 1 / Step 2 / Step 3 / Step 3.5) | Replaced |
| Per-phase plan (`docs/history/plans/<YYYY-MM-DD>-<slug>-phase-<N>.md`) | Per-pass plan (`docs/history/plans/<YYYY-MM-DD>-<slug>.md`) | Merged (N → 1) |
| Per-phase `delta-coverage-reviewer` cross-review | End-of-run `delta-coverage-reviewer` dispatch (whole-branch) + parallel `cohesive:review-diff` with AND-shape verdict synthesis | Replaced |
| Phase 1 coverage table | Step 1 thin intent paragraph (delta-entry stable IDs enumerated inline) | Replaced |
| Phase 2c escalation rule (one repair cycle then halt) | Removed; resume is user-driven on Coverage Drift verdict | Removed |
| `Phase Drift` verdict | `Coverage Drift` verdict | Renamed |
| Phase derivation behavior matrix (8 cells P001–P008) | Removed; substrate-shape→TDD-shape translation is inline at Step 1 | Removed |
| Phase 3.5 cleanup | Step 3.5 post-implementation cleanup | Renamed |
| `delta-coverage-reviewer` per-phase input contract | `delta-coverage-reviewer` whole-branch input contract | Tightened (widened scope) |
| Composition seam: per-phase | Composition seam: per-pass | Tightened |
| (none) | Delta-size budget gate at 15 entries (Step 1) | Added |

## New or updated substrate

### Specs

- `skills/implement-cohesively/SKILL.md` — single-pass implementation; Step 1 composes thin intent paragraph and surfaces budget gate; Step 2 dispatches executing-plans; Step 3 runs dual reviewer dispatch in parallel with AND-shape synthesis; Step 3.5 cleanup gated on Implemented.
- `skills/cohesively/SKILL.md` — router descriptions of the implement route updated to reflect single-pass shape.
- `docs/substrate/architecture/handoffs.md` — Approved-branch contract, chain exits, post-implementation review entry point updated.
- `docs/substrate/architecture/composition-with-superpowers.md` — composition table per-pass; Cohesive ownership reframed as substrate-shaped framing.
- `docs/substrate/architecture/skills.md` — `implement-cohesively` design-layer section rewritten.
- `docs/substrate/conventions/substrate-layout.md` — cleanup-at-handoff section uses Step vocabulary.
- `docs/substrate/conventions/dispatch-protocol.md` — Step 3 end-of-run dual dispatch documented.
- `docs/substrate/conventions/scope.md` — Build gate description updated.
- `docs/substrate/conventions/skill-shape.md` — code-producing skills section reflects single-pass shape.
- `docs/substrate/architecture/fresh-eyes-review.md` — implement-cohesively's review surface renamed.
- `ARCHITECTURE.md`, `README.md`, `AGENTS.md` — top-level surfaces aligned.

### Behavior matrices

- `docs/substrate/matrices/artifact-placement.md` — `Per-phase plan` row replaced with `Per-pass plan`; cleanup target singular.
- `docs/substrate/matrices/phase-derivation.md` — deleted.

### Named invariants

- `IMPLEMENTATION_PLAN_COVERS_DELTA` — Rules #1–#5 reformulated to single-pass shape (5 rules total instead of 6; Rule #4 and prior Rule #5 collapsed into a single dual-reviewer rule).

### Gotchas

- `docs/substrate/gotchas/large-delta-mega-plan.md` — added.
- `docs/substrate/gotchas/skipping-per-phase-plan.md` — retired.
- `docs/substrate/gotchas/plans-as-run-scaffolding.md` — modified for singular plan; principle stands.
- `docs/substrate/gotchas/no-implementation-handoff.md` — modified to describe single-pass correct pattern.

### Semantic linter specs

- `scripts/validate_plugin.sh` Check 13f — rewritten to grep IMPLEMENTATION_PLAN_COVERS_DELTA + large-delta-mega-plan instead of phase-derivation matrix. Currently passes against the rewritten SKILL.md.

### Tests / checks proposed (not yet implemented)

- A future deferred CI grep target for verdict-synthesis combinations could verify the skill body's §"Verdict synthesis" subsection enumerates all 3×5 reviewer-output combinations. Deferred; reviewer-judged for v0.1.

## What this rewrite *did not* do

- Implementation code: not changed (this is a substrate rewrite, not an implementation pass).
- Tests: not changed (no code tests in the repo; reviewer agent verdicts are the enforcement).
- CI: `validate_plugin.sh` Check 13f rewritten as a substrate-coupled change, but no new CI files added.
- Promotion of verdict synthesis to a separate matrix file: skill-body subsection suffices for v0.1.
- Tuning of the 15-entry threshold: a v0.1 default; tuning is a follow-up substrate change once real-world delta sizes inform the budget.
- Update to validate-rewrite or its agents (`spec-cohesion-reviewer`'s lens 14 still verifies handoff-contract consistency; the verdict vocabulary update in `verdict-vocabulary.md` and `handoffs.md` is what lens 14 will check on the next rewrite).

## Remaining ambiguity

- **Branch-name convention vs harness behavior:** the substrate references `design/<slug>` branches (handoffs.md, IMPLEMENTATION_PLAN_COVERS_DELTA, etc.), but the harness's `EnterWorktree` tool produces `worktree-design+<slug>`. This rewrite landed on the latter; the substrate-side reconciliation is reviewer-judged and not in scope for this pass. Future tightening: either (a) update the substrate to acknowledge `worktree-design+<slug>` as the canonical form, or (b) add a `git branch -m` step to `rewrite-specs` that renames the harness-created branch to `design/<slug>`.
- **Coverage Drift resume mechanics (pass-1 I2 — substrate-noted):** `handoffs.md:219-220` says Coverage Drift resume "must not re-derive the thin intent paragraph" but `implement-cohesively/SKILL.md` Step 1 unconditionally enumerates non-Deferred entries — there is no resume branch in the SKILL body. The two surfaces don't disagree, but the discipline backing the handoff's must-not clause is reviewer-judged. Substrate-noted per the disposition rule §"Substrate-note as user override"; a future tightening could add a Step 1 sub-clause pinning the resume-state contract or persist resume state across invocations. Source review: `docs/history/reviews/2026-05-08-implement-cohesively-single-pass-rewrite-validation.md` finding I2.
- **Verdict synthesis edge case:** what happens if `cohesive:review-diff` returns a verdict not enumerated in §"Verdict synthesis" (e.g., a future verdict added to review-diff's vocabulary)? Currently reviewer-judged; the `verdict-vocabulary.md` parity check in `validate_plugin.sh` is the structural fence.

## Repair pass 1

Source review: `docs/history/reviews/2026-05-08-implement-cohesively-single-pass-rewrite-validation.md` (verdict: Issues Found).

**Closes:**

- **B1** — Bypass-acknowledgment string contradiction. Decided canonical string by dropping "per-phase". Updated `validate-rewrite/SKILL.md:241,246` (replaced "phased loop with per-phase reviews" with "implement-cohesively flow with end-of-run dual reviewer dispatch"; replaced bypass acknowledgment string `"Cohesive's per-phase verification of the rewrite doesn't apply"` with `"Cohesive's verification of the rewrite doesn't apply"`); updated `validate_plugin.sh:497` `bypass_string` to match; `IMPLEMENTATION_PLAN_COVERS_DELTA.md:64` already had the canonical wording. Also updated `no-implementation-handoff.md:70` which carried a third stale variant of the bypass string. The three normative surfaces now agree on the literal string.

- **B2** — Top-level surfaces sweep. `README.md:19` ("phase-by-phase against a design delta ledger" → "in a single pass against a design delta ledger"); `README.md:58` ("Phases derived from the design delta ledger; each phase is plan-then-TDD..." → "A single-pass implementation against the delta ledger: thin intent paragraph → writing-plans → executing-plans → end-of-run parallel dispatch..."); `ARCHITECTURE.md:11` ("composing superpowers:executing-plans per phase" → "composing superpowers:executing-plans once per implementation pass"); `ARCHITECTURE.md:76` ("phase-by-phase against the design delta ledger" → "single-pass against the design delta ledger with end-of-run dual reviewer dispatch").

- **B3** — `skill-tool-dispatch.md` sweep. Added to rewrite list. Updated lines 3, 9, 23, 33, 59, 70, 74, 85, 108, 110, 117, 118, 134 to reflect the new shape: per-phase composition examples replaced with per-pass examples; line 117/118 are now Step 1 / Step 2 single-dispatch examples; Step 3 end-of-run dispatch of `cohesive:review-diff` added as a fourth concrete dispatch site. Plan-path example in line 117 reads `docs/history/plans/<YYYY-MM-DD>-<slug>.md` (singular) consistent with `IMPLEMENTATION_PLAN_COVERS_DELTA.md` Rule #2.

- **B4** — Files claimed rewritten that retained stale phase vocabulary, swept:
  - `fresh-eyes-review.md:16` ("the delta-coverage-reviewer dispatched per phase by implement-cohesively" → "the delta-coverage-reviewer dispatched at end-of-run by implement-cohesively")
  - `dispatch-protocol.md:5` ("implement-cohesively's phase loop" → "implement-cohesively's end-of-run dispatch of cohesive:review-diff") and `:82` ("phase loop" → "end-of-run skill dispatch")
  - `substrate-layout.md:31` ("per-phase plans, discovery reports" → "the per-pass implementation plan, discovery reports")
  - `architecture/skills.md:27` ("composes superpowers:executing-plans per phase" → "composes superpowers:executing-plans once per implementation pass")
  - Adjacent stale references found during the sweep also closed: `brainstorm-design/SKILL.md:357` ("per-phase composition" → "single-pass composition with end-of-run dual reviewer dispatch"); `scope.md:31` ("once per phase" → "once per implementation pass at Step 1"); `router.md:31` (R015 cell `"per phase"` → `"once per implementation pass plus end-of-run dual reviewer dispatch"`); `cohesion-review.md:121` ("phase-by-phase against the delta ledger" → "in a single pass against the delta ledger with end-of-run dual reviewer dispatch").

- **I1** — `no-implementation-handoff.md:9` parenthetical ("delta ledger as inspectable work-shape; per-phase fence; final substrate review" → "delta ledger as inspectable work-shape; end-of-run dual reviewer fence; substrate-coverage verdict").

- **I2** — Substrate-noted in §"Remaining ambiguity" above per the disposition rule §"Substrate-note as user override". The Coverage Drift resume mechanic remains reviewer-judged in v0.1.

**Files added to rewrite list during repair:** `skills/validate-rewrite/SKILL.md` (B1), `docs/substrate/conventions/skill-tool-dispatch.md` (B3), `skills/brainstorm-design/SKILL.md` (B4 adjacent), `docs/substrate/matrices/router.md` (B4 adjacent), `references/templates/cohesion-review.md` (B4 adjacent).

**Validation:** `scripts/validate_plugin.sh` passes after repair; the new `bypass_string` literal greps against the rewritten `validate-rewrite/SKILL.md`.

## Repair pass 2

Source review: `docs/history/reviews/2026-05-08-implement-cohesively-single-pass-rewrite-validation-pass-2.md` (verdict: Issues Found).

**Closes:**

- **B1** — `validate-rewrite/SKILL.md:220` Implementation-route card literal swept clean. The chat-rendered hand-off into Build now reads `"Builds the locked design in a single pass against the delta ledger at <...> on design/<slug>, with end-of-run dual reviewer dispatch."` instead of the prior `"phase by phase"` literal. Plus a new **Check 13m** in `scripts/validate_plugin.sh` greps `skills/`, `agents/`, `references/` for the forbidden literals `phase by phase` and `phase-by-phase`; zero matches required. The grep is narrowed to those three trees so historical narrative inside `docs/substrate/gotchas/` and `docs/substrate/invariants/` History sections is not in scope. Convention-with-grep promotion parallel to Check 13g's `bypass_string` pattern.
- **I1** — `IMPLEMENTATION_PLAN_COVERS_DELTA.md:96` (2026-05-04 history entry) inline-annotated rather than rewritten, per the append-only history convention. The day-one entry now reads `"…explicit enforcement path (per-phase coverage + per-phase reviewer + final substrate review — per-phase at the time; reformulated to single-pass dual-reviewer dispatch on 2026-05-08; see entry below)…"`. The 2026-05-08 entry below it is unchanged.

**I2 stays substrate-noted in §"Remaining ambiguity"** per the prior pass's disposition.

**Validation:** `scripts/validate_plugin.sh` passes after repair, including the new Check 13m which now actively prevents B1's regression class.

## Ready for fresh-eyes review?

**Yes** — the rewrite is internally consistent across every load-bearing surface; the named invariant is reformulated coherently with the day-one history entry inline-annotated for clarity; the chat-trailer template reflects the new body block; the verdict vocabulary is renamed; the bypass-acknowledgment string is canonical across SKILL.md, invariant, gotcha, and validator; the Implementation-route render literal in `validate-rewrite` reflects single-pass shape; `validate_plugin.sh` passes (now with Check 13m structurally preventing the regression class B1 represented); and no stale phase-shaped references remain outside History sections of the three substrate docs (`IMPLEMENTATION_PLAN_COVERS_DELTA.md`, `large-delta-mega-plan.md`, `plans-as-run-scaffolding.md`) that intentionally retain them as redesign provenance.

## How to read this ledger

1. Read the "Approved direction" line — destination is single-pass implement-cohesively.
2. Skim "Delta at a glance" — 13 files rewritten / 2 added / 2 removed; the central conceptual changes are per-phase loop → single-pass and Phase Drift → Coverage Drift.
3. Skim "Conceptual changes" table for the precise vocabulary shifts.
4. Read "Files rewritten" with before/after summaries for each substrate surface (start with `IMPLEMENTATION_PLAN_COVERS_DELTA`, then the skill body, then the chain-exit handoffs).
5. Use "Remaining ambiguity" as the focused review punch list.
