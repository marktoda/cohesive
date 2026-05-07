# Rewrite Validation Review — discovery-as-internal-step (pass 1)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** 8 rewritten specs for the discover-substrate-as-internal-sub-step direction; design delta ledger at `docs/history/delta-ledgers/2026-05-06-discovery-as-internal-step.md`.

**Status:** Issues Found

## Executive judgment

The chain-edge changes (Hard constraint #1, the 4 Process steps, router.md grid, cohesively grid, skills.md `### discover-substrate` body, validator array) are coherent end-to-end. But the rewrite stopped at the four primary surfaces and explicitly deferred two sweeps; one of those deferrals (Composition sections) and one local skills.md inconsistency (the at-a-glance table row + opening-prose chain notation) create live contradictions inside *already-rewritten files*. A fresh contributor reading audit-substrate's `## Composition` will be told the router passes `"discovery already complete; report at <path>"` prereq state, while reading the same rewrite's router.md three minutes later they'll be told it doesn't.

## Delta at a glance

(Full preamble matches `docs/history/delta-ledgers/2026-05-06-discovery-as-internal-step.md` lines 9-30.)

## Blocking issues

### B1. audit-substrate `## Composition` directly contradicts the rewritten router contract on the very prereq this rewrite retires

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** `skills/audit-substrate/SKILL.md:213` says "The router passes 'discovery already complete; report at <path>' so this skill skips its own discovery prompt." That's the retired contract. Hard constraint #1 of the same file (line 20) and the rewritten `router.md:59` both say the router passes nothing.
- **Recommended fix:** Rewrite the Composition "Most often invoked by" bullet to reflect internal dispatch; drop the "Always preceded by: cohesive:discover-substrate" bullet — internal-dispatch is not "preceded by," it *is* Step 1.

### B2. Three other consumer skills carry the same `Always preceded by: discover-substrate` Composition contradiction

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** brainstorm-design, review-codebase, review-diff each carry `Always preceded by: discover-substrate (or its output reused...)`. The ledger called these "technically still true" but with the new model "preceded by" is the wrong relation; the relation is "internally dispatches."
- **Recommended fix:** In each, replace the "Always preceded by" bullet with: `Internally dispatches: cohesive:discover-substrate as <Step 0 / Phase 1.0 / Step 2> per Hard constraint #<N>; optional override skips re-running discovery if a report path is supplied in the dispatch prompt.`

## Important issues

### B3. Ledger preamble file count diverges from body

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** Preamble says "6 rewritten" but §"Files rewritten" enumerates 8 entries.
- **Recommended fix:** Update preamble to "8 rewritten."

### B4. skills.md at-a-glance table + opening prose still describe discover-substrate as a chain step within Decide

- **Severity:** High
- **Category:** Lens 13 (within design layer itself)
- **Why it matters:** Same file's `### discover-substrate` body explicitly retires the chain-step framing, but the table row says "Decide (silent)" and line 3 says "discover-substrate → brainstorm-design (Decide)".
- **Recommended fix:** Change table Gate column for discover-substrate to "_internal sub-step_". Rewrite line 3's chain notation to: "The agent-internal subskill chain is `brainstorm-design` (Decide; dispatches `discover-substrate` internally as Step 0)…". Promote the discover-substrate Bootstrap status row from `inherited` to `validated` once this repair lands.

### B5. handoffs.md deferral is load-bearing, not cosmetic

- **Severity:** High
- **Category:** Lens 14
- **Why it matters:** Lens-14 requires every chain-edge gate to appear identically in three sites: upstream verdict vocabulary, downstream prereq, router.md dispatch. For the four affected edges, two of three sites have moved (consumer skills + router.md) and one (handoffs.md) hasn't.
- **Recommended fix:** Update handoffs.md's four discover-substrate handoff entries (or retire them as no-longer-handoffs since discovery is now internal-dispatch, not a chain edge) in the same worktree before merge.

### I1. brainstorm-design Inputs in skills.md not updated

- **Severity:** Medium
- **Category:** Lens 13
- **Why it matters:** `skills.md:118` Inputs still says "passed by router or freshly invoked"; should reference Step 0 internal dispatch.
- **Recommended fix:** Change Inputs to name the internal-dispatch source.

### I2. validate_plugin.sh header comment accuracy

- **Severity:** Low
- **Category:** Vague language
- **Why it matters:** File header still lists "Canonical prereq-detection question in subskills with a discover-substrate prereq" as enforced; the check is now structural-only (no consumers).
- **Recommended fix:** Update header to "currently no skill carries a discovery-state prereq; check structure preserved against future regressions."

## What looked right

- Hard constraint #1's "Optional override" semantics are written identically across all four consumer skills.
- router.md preserves cell IDs R001-R017; only per-route columns changed.
- skills.md `### discover-substrate` body itself is a clean forward rewrite.
- Validator Check 10's intentional-empty-array-with-comment pattern is the right shape.

### Next

**Disposition:** Repair → re-validate
