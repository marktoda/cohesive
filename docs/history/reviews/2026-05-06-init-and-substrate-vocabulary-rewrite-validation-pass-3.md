# Rewrite Validation Review — cohesive:init + substrate-vocabulary (pass 3)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Phase 1 pass A on branch `design/init-and-substrate-vocabulary` (pass 3 of internal repair loop); design delta ledger at `docs/history/delta-ledgers/2026-05-06-init-and-substrate-vocabulary.md`

**Status:** Issues Found

## Executive judgment

Pass-3 closed the 6 sweep failures from pass 2. The single biggest gap remaining is sweep drift introduced by pass-3's own scope: pass-3 closed several "named-but-not-edited" findings, but two updates that should have ridden along with R017's introduction did not. The §"Delta at a glance" preamble's file count disagrees with the body, and skills.md §cohesively's Owns clause still cites cell range `R001-R016`. Both are surface-level fixes; both are exactly the divergence lens-11 and lens-13 exist to catch.

## Delta at a glance

(Full preamble matches `docs/history/delta-ledgers/2026-05-06-init-and-substrate-vocabulary.md` lines 9-30.)

## Blocking issues

### B1. Preamble file count diverges from body

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** The preamble claims "5 rewritten, 3 added"; pass-2 added `handoffs.md` and `skill-section-presence.md` to the rewrite scope. The body now has more files than the preamble claims. A downstream Phase 1 coverage table built from the preamble will miss the handoffs.md §"init → user-driven keep/reject" contract and the skill-section-presence.md row update.
- **Evidence:** ledger:23 ("Files: 5 rewritten, 3 added, 0 removed") vs §"Repair pass 2" §"Repair-pass file changes" lines 151-154 (adds 2 files).
- **Recommended fix:** Update preamble's `**Files:**` to reflect the actual count after pass-2 + pass-3 additions; add the missing files to §"Files rewritten" with before/after blocks.

### B2. skills.md §cohesively Owns clause cites stale cell range

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** Lens-13 mismatch. Design layer says "cells R001-R016" but R017 was added in this rewrite. A reader following the design-layer claim to the matrix gets a count mismatch.
- **Evidence:** `skills.md:252` ("cells R001-R016") vs `router.md:33` (R017 added).
- **Recommended fix:** Edit to "cells R001-R017".

## Important issues

### I1. handoffs.md "five transition shapes" lead claims exhaustiveness while init section names a sixth

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** Lead says "Every Cohesive transition is one of five shapes"; init section names "Adoption" as a sixth. Reader of the lead alone is told five; reader of init section is told six.
- **Evidence:** `handoffs.md:1` vs `:50`.
- **Recommended fix:** Either qualify the lead or add a "Provisional sixth shape: Adoption — see §init for status" entry under §"The five transition shapes".

### I2. `--brief` flag has no documented parse point

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** Hard constraint #5 names the flag and Step 3 references it, but no Process step describes parsing.
- **Evidence:** `init/SKILL.md:38`, `:72`.
- **Recommended fix:** Add to Step 0: "If the dispatch prompt or user invocation includes `--brief`, set `verbose=false`; default `verbose=true`."

## What looked right

- The chat-vs-file surface seam in §"What this skill produces" is crisp — chat carries an index in show-shape, the draft file carries the full translation paragraph.
- The truncation signal closes the user-expectation gap surfaced in pass 1.
- The detect-and-warn split for CLAUDE.md / AGENTS.md / docs/specs/ vs refuse-on-substrate-shaped-paths is the right concrete narrowing.
- The substrate-vocabulary.md "What this earns" column with the Convention row's explicit inversion is legible without forcing readers to read five conventions to discover it.

## Recommended repairs (ranked)

1. B1 — update ledger preamble + add pass-2 files to §"Files rewritten".
2. B2 — `skills.md:252` cell range fix (one-line edit).
3. I1 — qualify handoffs.md lead.
4. I2 — document `--brief` parse point.

### Next

**Disposition:** Repair → re-validate
