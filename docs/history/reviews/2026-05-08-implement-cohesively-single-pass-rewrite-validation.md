# Rewrite Validation Review — implement-cohesively single-pass

**Verdict:** Issues found — repair pass needed

## Executive judgment

The single-pass redesign is internally coherent at the load-bearing surfaces — `IMPLEMENTATION_PLAN_COVERS_DELTA` reformulates cleanly to five rules, the new `large-delta-mega-plan.md` gotcha names the abandonment cliff with structural mitigation, and the AND-shape verdict synthesis has a clean truth table. But the rewrite is **incomplete**: stale phase-shaped vocabulary survives in load-bearing surfaces — top-level docs, validator-pinned literals, a normative dispatch convention, and three files the ledger claims were rewritten. A future contributor reading README, ARCHITECTURE, `fresh-eyes-review`, or `skill-tool-dispatch` would conclude `implement-cohesively` still runs a phase loop. The most expensive failure is a literal-string contradiction across SKILL.md / invariant / validator that lens 14 should have caught.

## Delta at a glance

- **Files:** 13 rewritten, 2 added, 2 removed/deprecated
- **Conceptual changes:** per-phase loop → single-pass implementation; per-phase plan → per-pass plan; per-phase cross-review → end-of-run dual reviewer dispatch; AND-shape verdict synthesis introduced; `Phase Drift` verdict → `Coverage Drift` verdict
- **Named invariants:** `IMPLEMENTATION_PLAN_COVERS_DELTA` (rules #1–#6 reformulated to single-pass shape; rules #4 and #5 collapsed)
- **Behavior matrices:** `phase-derivation.md` (removed); `artifact-placement.md` (lifecycle row `Per-phase plan` → `Per-pass plan`)
- **Gotchas:** `large-delta-mega-plan.md` (added); `skipping-per-phase-plan.md` (retired); `plans-as-run-scaffolding.md` (modified)
- **Semantic linters:** `validate_plugin.sh` Check 13f rewritten
- **Tests proposed:** none

## Blocking issues

### B1. Bypass-acknowledgment string contradicts across SKILL.md / invariant / validator

- **Severity:** Blocker
- **Category:** Spec drift / Invariant
- **Why it matters:** `validate_plugin.sh:497` greps for `"Cohesive's per-phase verification of the rewrite doesn't apply"` and `validate-rewrite/SKILL.md:246` carries that exact string. But `IMPLEMENTATION_PLAN_COVERS_DELTA.md:64` (in the rewrite list) declares the canonical handshake string as `"Cohesive's verification of the rewrite doesn't apply"` (no "per-phase"). Three normative surfaces disagree on the literal string the validator pins. Lens 14 (handoff contract consistency) should have flagged this. After rewrite, `validate-rewrite` SKILL still renders "per-phase verification" to the user and the validator passes only because `validate-rewrite/SKILL.md` was excluded from the rewrite scope.
- **Evidence:** `validate-rewrite/SKILL.md:241` (`"Cohesive's phased loop with per-phase reviews would be ceremony"`); `validate-rewrite/SKILL.md:246` (per-phase string); `IMPLEMENTATION_PLAN_COVERS_DELTA.md:64` (no "per-phase"); `scripts/validate_plugin.sh:497`.
- **Recommended fix:** Add `validate-rewrite/SKILL.md` to the rewrite list. Decide one canonical string (drop "per-phase" — there is no per-phase concept), then update `validate_plugin.sh:497`'s `bypass_string` and `IMPLEMENTATION_PLAN_COVERS_DELTA.md:64` in the same pass.
- **Substrate artifact:** Spec (validate-rewrite SKILL) + named invariant + semantic linter.

### B2. Top-level surfaces (README, ARCHITECTURE) still describe per-phase shape

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** README and ARCHITECTURE are the ledger's claimed-rewritten surfaces (entries explicitly listed). They retain stale phase-shaped descriptions in user-facing prose. A new contributor reading either one concludes `implement-cohesively` runs a phase loop.
- **Evidence:** `README.md:19` (`"phase-by-phase against a design delta ledger"`); `README.md:58` (`"Phases derived from the design delta ledger; each phase is plan-then-TDD ... per phase"`); `ARCHITECTURE.md:11` (`"composing superpowers:executing-plans per phase"`); `ARCHITECTURE.md:76` (`"phase-by-phase against the design delta ledger"`).
- **Recommended fix:** Sweep both files; replace with single-pass / per-pass language matching the SKILL body.
- **Substrate artifact:** Spec.

### B3. `skill-tool-dispatch.md` describes a deleted phase loop as canonical

- **Severity:** Blocker
- **Category:** Spec drift / Locality
- **Why it matters:** `docs/substrate/conventions/skill-tool-dispatch.md` is the prescriptive convention for every Cohesive Skill-tool dispatch. It is heavily phase-centric (lines 3, 23, 59, 108, 110, 117, 118, 134) and is **not in the rewrite list**. Future contributors authoring a Skill-tool composition will read this convention and reproduce the deleted shape. The named invariant cited at line 117 (`<slug>-phase-<N>.md` plan path) directly contradicts `IMPLEMENTATION_PLAN_COVERS_DELTA.md` Rule #2.
- **Evidence:** `skill-tool-dispatch.md:3,23,59,108,110,117,118,134`.
- **Recommended fix:** Add to rewrite list. Replace per-phase composition examples with per-pass; line 117/118 become Step 1 / Step 2 single-dispatch examples.
- **Substrate artifact:** Spec / convention.

### B4. Files claimed rewritten in the ledger still carry stale phase vocabulary

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** Three files the ledger lists under "Files rewritten" still contain the old vocabulary in normative prose. The ledger preamble claims the rewrite "did not leave stale phase-shaped references outside History sections" (§"Ready for fresh-eyes review?"); this is materially false.
- **Evidence:** `fresh-eyes-review.md:16` (`"the delta-coverage-reviewer dispatched per phase by implement-cohesively"`); `dispatch-protocol.md:5` (`"implement-cohesively's phase loop"`) and `:82` (`"phase loop"`); `substrate-layout.md:31` (`"per-phase plans, discovery reports"`); `architecture/skills.md:27` (`"composes superpowers:executing-plans per phase"`).
- **Recommended fix:** Sweep each file. The ledger's "ready for fresh-eyes" line should be reasserted only after the sweep.
- **Substrate artifact:** Spec.

## Important issues

### I1. `no-implementation-handoff.md` retains "per-phase fence" in symptom narrative

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** Line 9 reads `"the rewrite's value (delta ledger as inspectable work-shape; per-phase fence; final substrate review) was bypassed"`. The phrase is in the present-tense symptom description, not a History block. With phases gone, "per-phase fence" no longer names a real surface.
- **Evidence:** `docs/substrate/gotchas/no-implementation-handoff.md:9`.
- **Recommended fix:** Replace `"per-phase fence"` with `"end-of-run dual reviewer fence"` or drop the parenthetical.
- **Substrate artifact:** Gotcha.

### I2. Coverage Drift resume contract names plan reuse but doesn't pin it

- **Severity:** Medium
- **Category:** Future-fit
- **Why it matters:** `handoffs.md:219-220` says resume "must not re-derive the thin intent paragraph" but `implement-cohesively/SKILL.md` Step 1 unconditionally enumerates non-Deferred entries — there is no resume branch. The two surfaces don't disagree, but the SKILL body has no logic backing the handoff's must-not clause; the discipline is reviewer-judged. Acknowledged in §"Remaining ambiguity" but not pinned.
- **Evidence:** `handoffs.md:219-220` vs `implement-cohesively/SKILL.md:61-84`.
- **Recommended fix:** Add a Step 1 sub-clause: "On Coverage Drift resume, reuse the prior pass's intent paragraph verbatim; do not re-enumerate entries." Or accept the substrate-note in §"Remaining ambiguity".
- **Substrate artifact:** Spec.

## What looked right

- **AND-shape verdict synthesis is cleanly tabulated.** `implement-cohesively/SKILL.md:106-111` enumerates the 2×2 reviewer-output matrix; the dual-fail rule (Substrate Drift wins) is named and motivated.
- **`large-delta-mega-plan.md` names the relocated cliff explicitly.** The "Why it happened" section (lines 11-13) traces the relocation from many-phase escalation to single-pass overflow; the budget gate is a real structural mitigation, not optimism.
- **Invariant rules collapse (4+5 → 4) is justified in the ledger and reflected in the doc.** The rule reformulation is internally coherent.

## Recommended repairs (ranked)

1. **B1** — Bypass-acknowledgment string contradiction. Decide canonical string (drop "per-phase"); update `validate-rewrite/SKILL.md`, `IMPLEMENTATION_PLAN_COVERS_DELTA.md:64`, and `validate_plugin.sh:497` `bypass_string` in the same pass.
2. **B3** — `skill-tool-dispatch.md` sweep. Replace phase-centric examples with per-pass; reformulate line 117/118 to Step 1/Step 2 single-dispatch shape.
3. **B4** — Sweep `fresh-eyes-review.md:16`, `dispatch-protocol.md:5,82`, `substrate-layout.md:31`, `architecture/skills.md:27` for stale phase vocabulary.
4. **B2** — README/ARCHITECTURE sweep for stale phase descriptions.
5. **I1** — `no-implementation-handoff.md:9` parenthetical fix.
6. **I2** — Either pin the Coverage Drift resume rule in `implement-cohesively/SKILL.md` Step 1, or accept the substrate-note in §"Remaining ambiguity" of the ledger.

### Next

Disposition: Repair → re-validate.
