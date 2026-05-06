# Rewrite Validation Review — cohesive:init + substrate-vocabulary (pass 4)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Phase 1 pass A on branch `design/init-and-substrate-vocabulary` (pass 4 of internal repair loop); design delta ledger at `docs/history/delta-ledgers/2026-05-06-init-and-substrate-vocabulary.md`

**Status:** Approved

## Architectural reflection

A future contributor can read `skills/init/SKILL.md`, `references/substrate-vocabulary.md`, the cohesively router body, and the `### init` design-layer section in `skills.md` and reproduce init's behavior without consulting the original architect. The Rosetta Stone seam is now explicit (chat shows index; draft files carry the translation paragraph), the chat-vs-file surface seam is named, the bounded-proposal contract is unambiguous, the refusal/warn split between substrate-shaped paths and agent-handoff paths is structurally clean, and the design-layer agreement across SKILL.md / skills.md / handoffs.md / router.md is verifiable on lens 13 and lens 14.

- **Easier downstream:** First-time adoption stops being a chicken-and-egg problem. `cohesive:init` produces a draft substrate the user reviews; the Rosetta Stone teaches the vocabulary by translating the user's own code.
- **Harder downstream:** Substrate-vocabulary table is now load-bearing for a single consumer (init); when chat-trailer translation lands in sub-pass B, the table's column shape becomes harder to evolve without coordinated edits across both consumers. The deferred Check 13o is the eventual structural fence.
- **Load-bearing on memory:** The 4-bucket vs 6-vocabulary distinction (I1) and the 1-line summary derivation (I2) are pinned in this pass's repairs, but their consistency depends on reviewer attention until the chat-trailer translation surface lands.

## Executive judgment

The ledger's pass-4 repairs land where claimed (preamble file count to 8, `### cohesively` cell range to R001-R017, handoffs.md "five formalized shapes plus one provisional sixth," `--brief` parse point in Step 0). Remaining issues are taste-level or next-pass tightenings, all Medium/Low.

## Delta at a glance

(Full preamble matches `docs/history/delta-ledgers/2026-05-06-init-and-substrate-vocabulary.md` lines 9-30.)

## Important issues

### I1. Init scans 4 type-buckets but Hard constraint #4 says "≤5 per substrate type" against a 6-type vocabulary

- **Severity:** Medium
- **Category:** Domain model
- **Why it matters:** Vocabulary table defines 6 types; init's Process Step 2 enumerates 4 proto-signal categories. Hard constraint #4 says "≤5 per substrate type" without naming which.
- **Recommended fix:** Explicitly state v0.1 init scans 4 of 6 types (invariants/matrices/gotchas/conventions+linters); specs and standalone semantic linters fold under proto-conventions.

### I2. Chat-trailer cites a "1-line user-facing summary" field that doesn't exist

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** Init's chat trailer renders `<1-line user-facing summary from substrate-vocabulary.md>` but the table has multi-sentence translations only.
- **Recommended fix:** Change init's template to "the first sentence of the user-facing translation" so the derivation rule is explicit.

### I3. "Per substrate type" cap interacts ambiguously with the 4-vs-6 type bucket question

- **Severity:** Low
- **Category:** Vague language
- **Recommended fix:** After I1, restate Hard constraint #4 as "≤5 drafts per of the {N} v0.1 type buckets enumerated in Step 2; ≤20 drafts total."

### I4. substrate-vocabulary's "distinction-per-finding" claim doesn't match init's draft template

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** `references/substrate-vocabulary.md:81` claims init surfaces the convention/invariant distinction with quoted prose per finding; init's draft template has no such field.
- **Recommended fix:** Weaken the substrate-vocabulary.md claim to "the proposed-artifact body draws the distinction implicitly via the choice of category."

## What looked right

- **Chat-vs-file surface seam is structurally clean.** Rosetta Stone lives in draft files (where the user reads); chat carries the index.
- **Refusal/warn split is the right cut.** Substrate-shaped paths refuse; agent-handoff paths warn-and-continue.
- **Triple-site lens-14 parity holds.** Init's "no verdict" claim agrees across SKILL.md, skills.md design layer, handoffs.md, and the dispatch-contract grid.
- **Substrate-vocabulary table earns its existence.** §"Why this distinction matters" pins the highest-leverage claim (the convention/invariant boundary).
- **Pass-4 ledger preamble update is a clean self-fix.** Closing the 5-vs-8 file count divergence means downstream consumers see the full delta.

### Next

**Disposition:** Close in same worktree → merge

**Implementation route — default:** Build the locked design and verify the code matches it. *(`cohesive:implement-cohesively`.)* Note: this rewrite is docs-only — closing I1-I4 inline before merge; init itself is the implementation surface (SKILL.md body + reference table + router + matrices), all already landed.
