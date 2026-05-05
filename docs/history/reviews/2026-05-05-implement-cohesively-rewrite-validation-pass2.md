# Rewrite Validation Review — implement-cohesively (pass 2)

> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md

**Verdict:** Approved

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** Pass-2 review of the rewrite at `.claude/worktrees/design+implement-cohesively/`, against ledger + repair pass 1 at `docs/history/delta-ledgers/2026-05-04-implement-cohesively.md`.

## Executive judgment

The rewrite is implementable. Repair pass 1 closed all eight findings from the first validation cleanly: the Step/Phase numbering schism (B1) is resolved with the SKILL preamble paragraph that pins Step-0/Phase-1/2/3/Step-4 as the canonical labels and the invariant rewritten to match; the route-count drift (B2) is gone from both router.md and skill-conventions; the ARCHITECTURE.md skill-count phrasings (B3) reconcile; the invariant scope now covers `implement/<slug>` (I1); the Phase 2c escalation rule is concrete with a `Phase Drift` halt after one repair cycle (I2); the bypass acknowledgment line is named verbatim in both validate-rewrite's Output format and the invariant's §Known bypass risks (I3); the Phase 1 coverage table is pinned to the same column shape as the final Phases table at two points in time (I4); the validate-rewrite footer-placement deviation is now an accepted entry in skill-conventions §"When sections may differ" (I5). One minor internal contradiction remains inside the invariant doc and three smaller cohesion gaps are worth tightening in the implementation pass, but none block.

## Blocking issues

(none)

## Important issues

### I1. Invariant doc contradicts itself on bypass-acknowledgment surface

- **Severity:** Medium
- **Category:** Spec drift / Enforcement
- **Why it matters:** `IMPLEMENTATION_PLAN_COVERS_DELTA.md` §Known bypass risks says the bypass acknowledgment "lands in the conversation transcript, not in commit history; this is enough for v0.1." The same doc's §Review checklist asks "If the rule was bypassed (user chose direct `superpowers:writing-plans`), was the bypass documented in the **branch's commit history**?" A reviewer following the §Review checklist will look for commit-history evidence the acknowledgment was never required to land in commit history. A future contributor will not know which surface is canonical and will either over-enforce (block reviews) or under-enforce (skip the check entirely).
- **Evidence:** `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` §Known bypass risks (transcript-only) vs §Review checklist (commit-history requirement).
- **Recommended fix:** Rewrite the §Review checklist line to match the §Known bypass risks decision: "If the rule was bypassed, was the literal acknowledgment line rendered in the conversation transcript before `superpowers:writing-plans` was invoked?" — and note that commit-history enforcement is a future tightening, not a v0.1 expectation.
- **Substrate artifact to add or update:** named invariant (`IMPLEMENTATION_PLAN_COVERS_DELTA.md`).

### I2. Phase ordering for mutually-independent phases is intentionally underspecified — but the consequence isn't named

- **Severity:** Medium
- **Category:** Vague language / Test
- **Why it matters:** `phase-derivation.md` §Rules says "When two phases have no inter-dependency, the implementer may interleave or order by code-locality concerns; the matrix does not enforce a single global order." The ledger marks this as intentional flexibility. But the consequence of non-determinism is not surfaced to the implementer: two runs of `implement-cohesively` against the same delta could produce different phase orderings, which means the per-phase cross-review verdicts are not reproducible across runs, and a Phase Drift verdict on phase 3 in run A may not correspond to the same delta entries as phase 3 in run B. A future contributor debugging an `implement-cohesively` failure will not know whether the order they're seeing is normative or accidental.
- **Evidence:** `docs/substrate/matrices/phase-derivation.md` §Rules; `skills/implement-cohesively/SKILL.md` §Phase 1 (Phase ordering rules 1–5).
- **Recommended fix:** Add one rule to phase-derivation.md §Rules: "Within each predecessor-respecting tier, phase order is stable per run but is not guaranteed identical across runs of `implement-cohesively` against the same delta. Reviewers comparing two runs should compare by delta-entry stable IDs, not phase numbers." Cite this from `delta-coverage-reviewer.md` §"What you must not do" (a phase number is not a stable identifier; the delta-entry ID is).
- **Substrate artifact to add or update:** behavior matrix (`phase-derivation.md`) + reviewer agent (`delta-coverage-reviewer.md`).

### I3. Token cost at scale: no pre-flight phase-count guidance

- **Severity:** Medium
- **Category:** Future-fit / Test
- **Why it matters:** `ARCHITECTURE.md` §"Risks the design accepts" names per-phase reviewer cost — a 10-phase pass dispatches 10 reviewer agents on top of 10 `writing-plans` and 10 `executing-plans` invocations. The ledger §Remaining ambiguity flags this. `implement-cohesively`'s Phase 1 has the chance to surface a phase count to the user before Phase 2 begins, but the SKILL body does not require it. A user invoking the skill on a large delta will discover the cost only after multiple phases have run, with no ability to budget or split into multiple sessions.
- **Evidence:** `skills/implement-cohesively/SKILL.md` §Phase 1 (no phase-count surfacing); `ARCHITECTURE.md` §"Risks the design accepts" (cost acknowledged, no concrete budget).
- **Recommended fix:** Add to Phase 1's coverage table description: "After rendering the coverage table, surface the phase count and an estimated reviewer dispatch count (= phase count) to the user. If the count exceeds a threshold (default: 8), pause and confirm before proceeding to Phase 2." Add an acceptance criterion. The threshold itself is a v0.1 decision that the implementation pass can tune.
- **Substrate artifact to add or update:** spec (`implement-cohesively/SKILL.md`) + acceptance criterion.

### I4. `no-implementation-handoff` gotcha's "Tests / checks" doesn't cite the bypass-acknowledgment pin

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** Repair pass 1 added the bypass acknowledgment as a new structural pin (named verbatim in validate-rewrite/SKILL.md and IMPLEMENTATION_PLAN_COVERS_DELTA.md). The `no-implementation-handoff.md` gotcha is the canonical scar narrative; a reviewer reading only this gotcha to find what's enforced sees three pins (router has `implement` route; decision matrix renders; skill exists in expected_skills) but does not see the bypass acknowledgment pin. Cohesion gap, not an enforcement gap — the rule is enforced elsewhere — but the gotcha is the natural one-stop-read for this scar.
- **Evidence:** `docs/substrate/gotchas/no-implementation-handoff.md` §"Tests / checks that preserve this" (3 bullet pins, no acknowledgment-line reference).
- **Recommended fix:** Add a fourth bullet: "**`validate-rewrite` Approved footer renders the bypass acknowledgment line when row 3 is picked** — covered by `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` Output format §'Bypass acknowledgment' and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` §Known bypass risks. Lint check (deferred V1): grep for the literal acknowledgment string."
- **Substrate artifact to add or update:** gotcha (`no-implementation-handoff.md`).

## Substrate gaps

(All surfaced under Important issues — no additional gaps.)

## Locality concerns

The seam between Cohesive's substrate-shape and Superpowers' TDD-shape is unusually clear in this rewrite: `composition-with-superpowers.md` §"The seam" enumerates four tightness tiers (loose/tight/recommendation/phase-boundary doc) and `implement-cohesively`'s Hard constraint #2 names the no-fallback boundary explicitly. The seam between Cohesive's design ledger and Superpowers' plan is mediated by `phase-derivation.md`, which is the substrate-shape pin between the two — exactly the right place for it.

## Future-fit concerns

`composition-with-superpowers.md` §"When to revisit" names the next forecasted shifts (Superpowers rename or restructure; deterministic plugin-installed check; substrate-shaped code generation as a future Cohesive skill). Future pressure is acknowledged without smuggling into normative scope.

## Enforcement concerns

- The bypass acknowledgment is a pure transcript convention in v0.1 (no commit-history landing, no validator check). The decision to leave it as transcript-only is documented in §Known bypass risks but produces I1's contradiction with §Review checklist.
- The deferred CI grep for commit-message citations now correctly names both `design/<slug>` and `implement/<slug>` branches; the enforcement story is internally consistent post-repair.
- `validate_plugin.sh` updates are deferred to the implementation pass per the ledger §"What this rewrite did not do" — no validator coverage of `implement-cohesively`'s frontmatter, voice citation, prereq-question shape, or verdict-leads compliance until then.

## Vague language to tighten

- `phase-derivation.md` §Rules — "the implementer may interleave or order by code-locality concerns" (see I2; intentional flexibility per ledger but consequence not surfaced).

## Recommended repairs (ranked)

1. Resolve the §Known bypass risks vs §Review checklist contradiction in `IMPLEMENTATION_PLAN_COVERS_DELTA.md` (I1).
2. Surface phase-count and reviewer-dispatch budget at Phase 1 in `implement-cohesively/SKILL.md` (I3).
3. Pin the cross-run reproducibility expectation in `phase-derivation.md` §Rules and `delta-coverage-reviewer.md` (I2).
4. Add the bypass-acknowledgment pin to `no-implementation-handoff.md` §"Tests / checks that preserve this" (I4).

## What looked right

- Repair pass 1 hit every blocker and important issue without expanding scope. The conceptual-changes table in the ledger reads like a tidy diff against the first validation review — a future reviewer auditing the repair quality can match each row to a closed finding.
- The Step/Phase preamble paragraph at the top of `implement-cohesively/SKILL.md` §Process is the right shape: one short paragraph that pins the labels for citation by the invariant. Other Cohesive skills with mixed-vocabulary phase/step layouts could borrow this shape if the same drift recurs.
- The Phase 2c escalation rule is tight: "one repair cycle, then `Phase Drift`" with explicit user-as-repair-actor handoff. The rule rejects auto-loop-past-first as an anti-pattern row in the same SKILL — the rule and its enforcement story land together, not in separate documents.
- The `validate-rewrite` Output format's "Bypass acknowledgment" paragraph names the literal line verbatim. A future Claude rendering this Output format has the exact string to emit; no improvisation surface.
- The invariant's §Known bypass risks treats "documented bypass" as a substrate move rather than a leak ("Naming bypasses is not weakness — it's substrate"). This is the right framing for v0.1, where the bypass is rare and the substrate-side fence (this invariant scoped to `implement-cohesively`) holds independently.

### Recommended next Cohesive skill

`cohesive:implement-cohesively` — the rewrite is approved; the design is sound; the four remaining tightenings (I1–I4) are non-blocking and can be folded into the implementation pass's first phase or addressed in a follow-up substrate-only rewrite. No second `cohesive:rewrite-specs` round is required before implementation.
