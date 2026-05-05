# Rewrite Validation Review — cohesion-review-cleanup (pass 2, post repair pass 1)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes Task subprocess)
**Date:** 2026-05-05
**Subject:** Pass 2 review of spec rewrite for cohesion-review template cleanup + post-merge substrate bookkeeping on branch `design/cohesion-review-cleanup`. Pass 1 review at `docs/history/reviews/2026-05-05-cohesion-review-cleanup-rewrite-validation.md` returned Approved with two Low Important issues (I1 Spec drift, I2 Enforcement). Repair pass 1 (commit `2b6d80b`) addressed both findings.

**Verdict:** Approved

## Executive judgment

Repair pass 1 closes both pass-1 Low Important findings cleanly and introduces no new drift. The contract/slot symmetry now reads from either entry point (the bolded **canonical contract** term mirrors across cohesion-review.md and design-delta-ledger.md), and pin 8's enforcement story names the warn-level malformed-filename signal as an adjacent — not load-bearing — surface with a stated promotion path. The validator script, the canonical-list pin, and the ledger's Files-rewritten After-state describe the same check the same way. A future contributor reading any one of the four touched files can trace the rule to the other three without ambiguity. Ready for implementation.

## Delta at a glance

```
- Files: 4 rewritten, 1 added, 0 removed/deprecated
- Conceptual changes: "Delta at a glance" disambiguated into canonical contract (design-delta-ledger.md) vs render slot (cohesion-review.md) via annotation; cohesion-review.md issue-shape examples replaced from three-field to canonical six-field
- Named invariants: none added — convention pin 8 added to PLUGIN_ROOT_PATHS.md canonical list (substrate bookkeeping for an existing validator check, not a new invariant)
- Behavior matrices: none
- Gotchas: none
- Semantic linters: validate_plugin.sh check 13h tightened (added malformed-filename counter + warn-level signal)
- Tests proposed: none
- Deferred: across-verdicts render rule promotion; cutoff-date pattern promotion to skill-conventions.md §"Cutoff-date checks"; preamble convention promotion to named invariant
```

## Blocking issues

None.

## Important issues

None.

## Substrate gaps

None.

## Locality concerns

None.

## Future-fit concerns

None.

## Enforcement concerns

None. Pin 8's two-fence (presence + accuracy) plus adjacent-warn framing is internally consistent, and the validator-script implementation matches the spec.

## Vague language to tighten

None.

## Recommended repairs (ranked)

None.

## What looked right

- **Symmetric mirroring instead of rename.** The pass-1 I1 fix uses the lowest-cost move that closes the asymmetry: same bolded term on both sides, with a one-clause note about the mirroring on the slot side. The annotation-vs-rename trade-off remains substrate-noted in §"Remaining ambiguity" rather than silently retired, so a future contributor sees both why the choice was made and what would trigger revisiting it.
- **Pin 8's two-fence-plus-adjacent framing.** Naming the malformed-filename signal as *adjacent* to the two-fence model — rather than smuggling it in as a third fence — preserves the original load-bearing contract while giving the warn-level surface a clear home. The promotion path (warn → fail when a `substrate-layout.md` §Naming check ships) is concrete and falsifiable.
- **Repair-pass annotation in the ledger.** §"Repair pass 1" in the ledger is dated, scoped, and explicit about what changed and what didn't (file counts unchanged because no add/remove/rename). The ledger reads correctly as a delta even after a within-pass repair, without rewriting the §"Delta at a glance" preamble — which would have produced spurious churn.
