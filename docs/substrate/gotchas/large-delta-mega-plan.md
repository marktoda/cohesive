# Gotcha: large deltas produce mega-plans that abandon mid-execution

> A design delta ledger with many entries (30+ of varying shapes) produces a single implementation plan whose per-task expansion overflows the context budget for `superpowers:executing-plans`. The execution abandons mid-run with no automatic recovery, leaving the branch in a partial state. The structural mitigation is the delta-size budget gate at `cohesive:implement-cohesively` Step 1: when the delta-entry count exceeds 15, the skill surfaces the count and pauses for user confirmation before invoking `superpowers:writing-plans`.

## Symptom

The user invokes `cohesive:implement-cohesively` against a `validate-rewrite` Approved branch whose delta ledger has, say, 28 non-Deferred entries spanning rewritten files, conceptual changes, named invariants, behavior matrices, and gotchas. The skill composes the thin intent paragraph and dispatches `superpowers:writing-plans`, which produces a plan with ~50 tasks. `superpowers:executing-plans` begins execution; tasks 1–18 land cleanly; somewhere around task 19–25 the execution context overflows and the run abandons. The branch carries partial implementation; the end-of-run reviewers never dispatch; the user is left to either pick up by hand from a half-implemented state or revert and split the rewrite.

## Why it happened

The previous (per-phase) shape of `implement-cohesively` mitigated this implicitly: the phase-derivation matrix split a large delta into phases of 3–8 entries each, and `writing-plans`/`executing-plans` were invoked per phase. Each per-phase plan was small enough to finish; drift detection happened per phase; abandonment risk was bounded.

The single-pass redesign deletes the phase-derivation matrix because phase orchestration was redundant with what `writing-plans` and `executing-plans` already do internally. But the abandonment-cliff property phase derivation had been mitigating did not disappear — it relocated. The per-phase escalation rule (one repair cycle then halt with `Phase Drift`) had been the user-visible surface of "this phase didn't fit"; with no phases, the new failure mode is the larger context overflow inside a single `executing-plans` run.

## Tempting wrong fix

**Auto-split the delta into N sub-passes when it exceeds the threshold.** Re-introduces phase-like structure through the back door — the user just chose to delete this orchestration layer and the redesign committed to single-pass simplification. Auto-splitting puts phases back under a different name (`sub-pass`) and reintroduces the ordering, plan-numbering, and verdict-aggregation complexity the redesign deleted.

**Scale the threshold to whatever the latest model handles.** Threshold tuning is reasonable but isn't a substrate fix — it's parameter selection. The structural fix is the gate itself: surface the cost to the user before the expensive call. Threshold tuning is a follow-up substrate change.

**Trust `writing-plans`/`executing-plans` to handle whatever input.** "We'll trust it" violates the skill's own structural-mitigation rule. The whole point of substrate-first work is that mitigation is structure, not optimism.

## Correct pattern

`cohesive:implement-cohesively` Step 1 surfaces the delta-entry count before invoking `superpowers:writing-plans`. When the count exceeds **15** (default; tunable in a follow-up substrate change as real-world delta sizes inform the budget):

```
This delta has <N> entries. Single-pass implementation produces one large plan;
executing-plans runs may abandon on context overflow. Confirm to proceed, or run
cohesive:rewrite-specs to split the delta into smaller rewrites first.
```

The user confirms (accepts the abandonment risk for this run), aborts (returns to scope reduction), or interactively decides to split the rewrite via `cohesive:rewrite-specs`. The gate fires only above the threshold; for most rewrites it's invisible.

The threshold value is a v0.1 default; tighten or relax in a follow-up substrate change as real-world delta sizes inform the budget. The gate's *existence* is the structural mitigation; the threshold is parameter tuning.

## Related conventions

- **Substrate mitigation rule** — mitigation is structure (a test, a linter, a boundary, a gate), not optimism. See `${CLAUDE_PLUGIN_ROOT}/skills/brainstorm-design/SKILL.md` Hard constraint #4.
- **Audience seam for budget surfaces** — the gate's chat surface is decision-shape ("This delta has N entries; confirm to proceed") not substrate-shape (no mention of "writing-plans context budget" in chat). Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/audience-separation.md`.

## Tests / checks that preserve this

- **`implement-cohesively/SKILL.md` Step 1 gate** — refuses to invoke `writing-plans` without surfacing the delta-entry count and pausing for confirmation when above threshold. Reviewed in `cohesive:review-codebase` against the skill body.
- **Manual scenario test (planned, deferred):** invoke `implement-cohesively` with a delta ledger containing 20 entries; verify the gate surfaces the count and the skill awaits confirmation before invoking `writing-plans`.

If the test list is empty, the gate is enforced by reviewer memory only. The first concrete test should land in a future implementation pass that produces a structural fixture.

## When this was discovered

- Date: 2026-05-08
- Source: brainstorm at `docs/history/brainstorms/2026-05-08-implement-cohesively-single-pass.md` Phase 4 (cross-branch graft check + remaining battery). The redesign collapsed the per-phase loop into single-pass; the discovery report at `docs/cohesive/discovery/implement-cohesively-single-pass.md` §"Missing memory" surfaced the abandonment-cliff relocation as a substrate gap before code was written.
- One-line summary: deleting per-phase orchestration relocated the abandonment cliff from many-phase escalation to single-pass context overflow; the size-budget gate is the structural translation.

## Notes for future contributors

- The threshold value (15) is a v0.1 default. Real-world delta sizes will inform a tightening or relaxation; track via reviewer attention on actual implementation-pass outcomes.
- If a future `executing-plans` ergonomic change makes mid-run resumption automatic, this gotcha needs revisiting — the cliff softens. Until then, the gate is the only structural prevention.
- The gate is *not* a hard stop. Above-threshold deltas are still implementable; the user just confirms the cost. A future tightening might convert the gate to a hard-stop with a forced split, but v0.1 prefers user agency.
