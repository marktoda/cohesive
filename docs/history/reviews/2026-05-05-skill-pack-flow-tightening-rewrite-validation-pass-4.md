# Rewrite Validation Review — skill-pack-flow-tightening (pass 4)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** 12 rewritten + 3 added specs per `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-05-skill-pack-flow-tightening.md` (post repair pass 4)

**Verdict:** Approved

## Executive judgment

A future contributor can read these specs and implement against them without the original architect. The ledger preamble, body, and the four repair-pass summaries are mutually consistent; the prior-pass closures (B1 preamble count, B2 skill-shape stub, I1 bootstrap-status three-label scheme, B1 lens 13/14 citations, I1 Hard Constraint #5 reference shape, I2 Output persisted/chat-trailer split) all hold cleanly across the substrate. The new `using-cohesive` skill body, design-layer section, handoff contract, exemption entry, and validator skill-set entry agree on purpose, ownership, inputs, outputs, and the absence of verdict; lens 13 and lens 14 have no drift to surface. The two findings below are taste-level — neither blocks merge.

## Delta at a glance

> [unchanged from prior passes — preamble describes the rewrite scope]

## Blocking issues

_None._

## Important issues

### I1. Validator-array exemption for `using-cohesive` is not documented at the array site

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** Step 5 of the rewritten "Adding a new skill" sequence in `architecture/skills.md` instructs contributors to "consult those comments rather than guessing" about which validator arrays apply. The `# 13b.` comment block above `voice_imperative_skills` says "every non-router skills/*/SKILL.md body" without naming the second exemption (`using-cohesive`). The exemption is properly recorded in `conventions/skill-shape.md` §"When sections may differ" and in `matrices/skill-section-presence.md`, but the consult-the-comments instruction makes the inline-comment surface load-bearing.
- **Evidence:** `scripts/validate_plugin.sh` `voice_imperative_skills` array comment block; cross-reference `docs/substrate/architecture/skills.md` Step 5.
- **Recommended fix:** Extend the `# 13b.` comment block to name both exemptions explicitly. Disposition: close inline (≤2 lines).

### I2. Hard Constraint #1 body and §"Acceptance criteria" use slightly different reset granularity

- **Severity:** Low
- **Category:** Domain model
- **Why it matters:** SKILL.md Hard Constraint #1 title says "Orient at most once per session per request shape"; body says "Subsequent substrate-shaped requests in the same session do not need re-orientation if the user is already inside a Cohesive workflow." The "per request shape" granularity in the title and the "if already inside a workflow" granularity in the body are not the same rule.
- **Evidence:** `skills/using-cohesive/SKILL.md` Hard Constraint #1 vs Hard Constraint #4 vs Acceptance criterion 4.
- **Recommended fix:** Tighten Constraint #1 body to match the title; move the "already inside" rule into Constraint #4 (where it already lives). Disposition: close inline (≤2 lines).

## Substrate gaps

_None surfaced this pass._

## Locality concerns

_None._

## Future-fit concerns

_None._

## Enforcement concerns

_None._

## Behavior knowable outside implementation?

Yes. The five-transition-shape model in `handoffs.md`, the per-skill section in `skills.md`, the §"Routes" + §"Dispatch prompt contract" in `cohesively/SKILL.md`, the §"What the dispatch prompt must contain" in `skill-tool-dispatch.md`, and the §"When Cohesive applies" / §"When to defer to Superpowers" / §"How to enter Cohesive" in `using-cohesive/SKILL.md` together let a future contributor reproduce the routing decision function without reading code.

## Vague language to tighten

_None at the normative-section level._

## Recommended repairs (ranked)

1. Per the Approved + Low disposition rule, close I1 and I2 inline (≤2 lines each) without re-running `validate-rewrite`.

## What looked right

- The Check 13i annotation tightening on both mirror surfaces plus the explicit Check 13j candidate naming closes pass-2 B1 cleanly without overpromising the grep.
- The bootstrap-status three-label scheme (`inherited` / `newly-authored` / `validated`) plus the post-table prose extending skepticism to both non-validated statuses gives future reviewers a deterministic signal at dispatch.
- The §"Output (persisted)" / §"Output (chat trailer)" split in `skill-tool-dispatch.md` with worked examples per dispatch site reduces ambiguity rather than introducing it.
- The §"Adding a new skill" 5-step sequence in `skills.md`, with `skill-shape.md` §"Process when adding a new skill" reduced to a one-paragraph stub deferring to the canonical sequence, is one canonical entry point, not two competing ones.

### Recommended next Cohesive skill

**Disposition:** Close inline (≤2 lines per finding) → merge

**Implementation route** — pick one:

| Option | Skill | When to pick |
|---|---|---|
| Implement now with delta-coverage discipline (default) | `cohesive:implement-cohesively` | Substantial rewrites; the rewrite added named invariants, behavior matrices, or cross-cutting conceptual changes. Phase loop with per-phase cross-review against the delta. |
| Land specs first; implement separately later | merge the `design/<slug>` branch first; later run `cohesive:implement-cohesively` against the merged delta ledger | Spec rewrite is independently valuable (e.g., for review by humans before code lands); the implementation has dependencies that aren't yet ready. |
| Hand off to Superpowers without delta-coverage discipline | `superpowers:writing-plans` | Small rewrites where the delta is mostly cosmetic; user accepts that the implementation may drift from the rewrite. The bypass is documented per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` §"Known bypass risks." |
| Schedule for later | (no immediate action) | The rewrite is approved; implementation is not currently in scope. Re-invoke `cohesive:implement-cohesively` or `superpowers:writing-plans` when ready. |
