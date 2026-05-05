# Design Delta Ledger — Delta-at-a-glance preamble convention

**Date:** 2026-05-05
**Worktree / branch:** `.claude/worktrees/design+delta-ledger-glance` on `design/delta-ledger-glance`
**Approved direction:** Option A — Ledger preamble. Add a required `## Delta at a glance` preamble to every design delta ledger; `rewrite-specs` authors it; `validate-rewrite` and `spec-cohesion-reviewer` quote it verbatim into the validation review across all three verdicts so the reader sees what the rewrite contains at decision time. Single source of truth in the ledger; many consumers quote it.

This ledger records *what changed* in the substrate during a `rewrite-specs` pass. It exists so the fresh-eyes reviewer (and future readers) can see the rewrite as a delta, not as 'a bunch of files moved around.'

## Delta at a glance

- **Files:** 5 rewritten, 1 added, 0 removed/deprecated
- **Conceptual changes:** none (pure addition of a new convention; no existing concept renamed or replaced)
- **Named invariants:** none — the new convention ships as convention-with-grep, not invariant-promoted, per `style-guide-rot.md` promotion criteria
- **Behavior matrices:** none
- **Gotchas:** none
- **Semantic linters:** `validate_plugin.sh` check 13h (added — preamble-presence grep on delta-ledger files dated on or after the 2026-05-05 cutoff); `spec-cohesion-reviewer` "What you check" item 11 (added — per-review preamble↔body consistency check, surfaces divergence as Blocking Issue)
- **Tests proposed:** none
- **Deferred (out of scope this pass):** optional phase-derivation matrix row marking the preamble as non-phase-generating; optional `preamble-drift-in-ledgers.md` gotcha pre-recording the failure mode; promotion of the convention to a named invariant after the convention has stabilized across two release cycles and a real regression has been caught

## Files rewritten

- `references/templates/design-delta-ledger.md`
  - **Before:** Template defined frontmatter (Date / Worktree / Approved direction), a one-paragraph intro, and the body sections starting with `## Files rewritten`. The §"How to read this ledger" footer named four reading steps (Approved direction → Conceptual changes → Files rewritten → Remaining ambiguity).
  - **After:** Template now includes a required `## Delta at a glance` section between the intro paragraph and `## Files rewritten`, spec'd as a count-or-name list across 8 categories (Files / Conceptual changes / Named invariants / Behavior matrices / Gotchas / Semantic linters / Tests proposed / Deferred) with a density target of 8–15 lines and an explicit `none` rendering rule for empty categories. The §"How to read this ledger" footer expands to five reading steps, inserting "Skim Delta at a glance" between Approved direction and Conceptual changes, and notes the preamble's role as the surface `validate-rewrite` quotes verbatim.
  - **Reason:** The preamble is the load-bearing artifact of this rewrite. Authoring it once in the ledger and quoting it many places (validate-rewrite render, spec-cohesion-reviewer return, future implement-cohesively Phase 1 announcement, future review-diff against `design/<slug>` branches) is the single-source-of-truth shape that the brainstorm pressure-test selected over reviewer-return (Option B) and Approved-footer-only (Option C).

- `references/templates/cohesion-review.md`
  - **Before:** Template's body started with `## Executive judgment`, then `## Blocking issues`, `## Important issues`, etc.
  - **After:** Template now inserts `## Delta at a glance` between `## Executive judgment` and `## Blocking issues`, with prose explaining that the section quotes the ledger's preamble verbatim, what to render when the preamble is missing (`Preamble missing — see Blocking issues`), and what to render when the preamble is present but inconsistent with the ledger body (still quote it verbatim and raise a Blocking Issue naming the divergence).
  - **Reason:** The cohesion-review.md template is the canonical shape the `spec-cohesion-reviewer` agent uses to structure its return; the agent's return is what `validate-rewrite` surfaces in chat. Updating the template (rather than only the agent's inline render block) keeps the canonical shape consistent and means future reviewer agents that compose the cohesion-review template inherit the section automatically.

- `skills/rewrite-specs/SKILL.md`
  - **Before:** Process step 5 ("Produce the design delta ledger") instructed the user to write the ledger using the template; it did not call out the §"Delta at a glance" preamble specifically. Acceptance criteria did not require the preamble. Anti-patterns table did not include preamble-related rows.
  - **After:** Process step 5 expands to name the preamble as required and load-bearing, instructs the author to fill it in last (after body sections stabilize) so it accurately summarizes them, and cross-references the spec-cohesion-reviewer's per-review consistency check and the `validate_plugin.sh` cutoff-date grep. Acceptance criteria adds a bullet requiring the preamble to be filled with a count-or-name list across the 8 categories and to render 8–15 lines of itemized content. Anti-patterns table adds two rows: (a) skipping or stubbing the preamble; (b) filling in the preamble first then drifting body sections away from it.
  - **Reason:** rewrite-specs is the authoring surface for the preamble; the substrate fence (per-review reviewer consistency check) catches divergence after the fact, but the skill body is where authors learn the discipline up-front. Without the Process / Acceptance updates, the convention rots silently — the validator catches presence but not authorship discipline.

- `skills/validate-rewrite/SKILL.md`
  - **Before:** Output format render template moved from `## Executive judgment` directly to `## Blocking issues`; no decision-time delta-content surfacing.
  - **After:** Output format render template inserts `## Delta at a glance` between `## Executive judgment` and `## Blocking issues`. The inserted section's render-template prose specifies that the section appears across all three verdicts (Approved / Issues Found / Design Incoherent), not Approved-only — closing the missing-memory item that decision-time delta context serves Issues Found and Design Incoherent readers as well (so they can decide repair-in-place vs. revisit-brainstorm).
  - **Reason:** This is the surface where the user reads the validation review and chooses among the four decision-matrix rows. The brainstorm pressure-test chose this surface as the primary consumer of the preamble; the render-template change is the user-facing realization of that choice.

- `agents/spec-cohesion-reviewer.md`
  - **Before:** "What you check" had 10 numbered items (behavior knowability, internal coherence, branchy behavior matrix coverage, named-invariant enforcement, gotchas/scars preservation, future-pressure containment, locality boundaries, shared-abstraction justification, obsolete-concept removal, vague-language hunting). The inline render block in "How to structure your output" matched the cohesion-review.md template at the time, with no preamble surface.
  - **After:** "What you check" adds item 11 — preamble↔body consistency check, with explicit instructions to compare each preamble bullet to the corresponding body section, to surface divergences as Blocking Issues, to handle missing preambles as Blocking Issues, and to quote the preamble verbatim into the rendered review regardless. The inline render block adds `## Delta at a glance` between `## Executive judgment` and `## Blocking issues`, matching the cohesion-review.md template change.
  - **Reason:** The reviewer is the structural fence on preamble correctness. The validator grep enforces presence; the reviewer enforces accuracy. Without the reviewer's per-dispatch judgment, an author could fill in a preamble that does not match the body — the preamble passes presence-grep but misleads the validation-review reader. Adding the consistency check makes the preamble's accuracy reviewable rather than aspirational.

- `scripts/validate_plugin.sh`
  - **Before:** Validator carried 14 numbered checks ending at PLUGIN_ROOT_PATHS; the post-13g checks moved straight to check 14.
  - **After:** Validator inserts check 13h between 13g (bypass-acknowledgment string) and 14 (PLUGIN_ROOT_PATHS). Check 13h iterates `docs/history/delta-ledgers/*.md`, parses each filename's `YYYY-MM-DD` date prefix, grandfathers ledgers dated before the `2026-05-05` cutoff, and greps every remaining ledger for the literal `## Delta at a glance` heading. Failures report the ledger path and the cutoff. The check's `ok` line distinguishes "no ledgers dated >= cutoff yet" from "all ledgers dated >= cutoff carry the preamble," and reports the grandfather count in both cases.
  - **Reason:** The grep is the structural enforcement complement to the reviewer-side judgment check. Together they form the substrate's two-fence model: presence (grep) and accuracy (reviewer). The cutoff-date grandfathering avoids requiring backfill of the 10 historical ledgers (which are append-only history per `substrate-layout.md`) — convention is forward-looking; old ledgers stay the way they were authored.

## Files added

- `docs/history/delta-ledgers/2026-05-05-delta-ledger-glance.md` — this ledger. The first delta ledger that itself satisfies the new convention; serves as the worked example for future authors and as the first instance the validator's check 13h evaluates.

## Files removed or deprecated

None.

## Conceptual changes

None. The rewrite is a pure addition of a new convention (Delta-at-a-glance preamble). No existing concept is renamed, merged, removed, or tightened — the existing delta-ledger sections, the existing review template sections, and the existing reviewer-agent rubric all remain in place; the preamble is a new section composed alongside them.

## New or updated substrate

### Specs
- `references/templates/design-delta-ledger.md` — adds required `## Delta at a glance` section spec'd as a count-or-name list across 8 categories with a 8–15-line density target; updates §"How to read this ledger" to name the preamble as the second skim step.
- `references/templates/cohesion-review.md` — adds `## Delta at a glance` section between Executive judgment and Blocking issues; specifies missing-preamble and divergence-from-body rendering rules.
- `skills/rewrite-specs/SKILL.md` — Process step 5 expanded with preamble-authorship instructions; Acceptance criteria adds preamble bullet; Anti-patterns adds two rows.
- `skills/validate-rewrite/SKILL.md` — Output format render template inserts `## Delta at a glance` across all three verdicts.
- `agents/spec-cohesion-reviewer.md` — "What you check" adds item 11 (preamble↔body consistency); inline render template adds the section.

### Behavior matrices
None added.

### Named invariants
None added. The brainstorm explicitly chose convention-with-grep status for v0.1 — a named-invariant promotion requires the wording to stabilize across two release cycles, a real regression to be caught by the validator grep, and a captured-not-authored worked transcript per `style-guide-rot.md` §promotion criteria. Until those conditions are met, the rule lives as convention enforced by `validate_plugin.sh` check 13h and `spec-cohesion-reviewer` "What you check" item 11.

### Gotchas
None added. The brainstorm marked a `preamble-drift-in-ledgers.md` gotcha as deferrable until a real divergence is observed in practice.

### Semantic linter specs
- `validate_plugin.sh` check 13h — added; greps every delta-ledger file dated on or after 2026-05-05 for the literal `## Delta at a glance` heading. Already implemented in this rewrite (not just spec'd).
- `spec-cohesion-reviewer` per-review preamble↔body consistency check — added; per-dispatch reviewer judgment that flags divergence as a Blocking Issue. Already implemented in this rewrite.

### Tests / checks proposed (not yet implemented)
None.

## What this rewrite *did not* do

- Did not promote the convention to a named invariant. Convention-with-grep is the v0.1 status per the brainstorm and `style-guide-rot.md` promotion criteria.
- Did not backfill the 10 historical ledgers under `docs/history/delta-ledgers/2026-05-04-*.md`. Grandfathered by the cutoff date in check 13h; historical ledgers are append-only and stay as authored.
- Did not modify `implement-cohesively`. Phase 1 already produces a coverage table that surfaces delta content at execution time (option B from the router's pressure-test choice, deliberately not chosen). The two surfaces (decision-time preamble in validate-rewrite render; execution-time coverage table in implement-cohesively Phase 1) compose without overlap.
- Did not introduce a row in `phase-derivation.md` for the preamble. The preamble is descriptive, not phase-generating; the matrix's silence on non-phase-generating ledger sections is a separate substrate gap and was deferred.
- Did not change the agent-dispatch contract. Hard Constraint #2 in `validate-rewrite` ("inputs must be paths, not summaries") is preserved — the agent reads the ledger's preamble from the file path it receives, not from a dispatching-skill-authored summary.
- Did not write code, tests, or CI workflow changes beyond the validator script.

## Remaining ambiguity

- The cutoff date in `validate_plugin.sh` (`2026-05-05`) is encoded as a shell variable. If the convention's wording or shape changes in a future rewrite that historical post-cutoff ledgers cannot satisfy, the cutoff would need to advance, leaving a window of ledgers grandfathered by the new cutoff. This pattern (cutoff-date constants in validators) has not been used elsewhere in `validate_plugin.sh` and may need a broader convention if more cutoff-scoped checks are added. Pass-1 review I3 surfaced this same gap and the convention was deliberately deferred — `docs/substrate/designs/skill-conventions.md` §"Cutoff-date checks" is the natural future home if a second cutoff-scoped check arrives.
- The 8–15-line density target in the design-delta-ledger.md template is a guideline, not a validator-enforced count. A future tightening could promote it to a structural check (line-counting AWK in check 13h), but the brainstorm did not propose this and it would interact with the multi-line bullet possibility in the Conceptual changes / Behavior matrices categories.
- The "What this rewrite did not do" section of the ledger is currently the only place "deferred" items are typically recorded; the new preamble's `Deferred` bullet introduces a second surface for the same information. Future ledgers may need explicit guidance on whether `Deferred` in the preamble should match `What this rewrite did not do` exactly, or whether they serve different scopes.
- Pass-1 review I2: reviewer-side per-review consistency check (item 11 in `agents/spec-cohesion-reviewer.md`) lacks a captured worked-example transcript showing what counts as "divergence" between preamble and body. Two reviewer instances may calibrate "divergence" differently. Deferred to a future captured-not-authored transcript under `docs/history/transcripts/` once a real divergence is encountered in a session — authoring a hypothetical worked example up-front would risk modeling a divergence that doesn't reflect real failure modes.

## Repair pass 1

Triggered by the pass-1 validate-rewrite review (Approved verdict with three Important issues; persisted at `docs/history/reviews/2026-05-05-delta-ledger-glance-rewrite-validation.md`). Repair scope:

- **I1 (Spec drift, Medium) — addressed.** The 8-category list previously appeared in four surfaces (template, rewrite-specs SKILL Acceptance, agent's "What you check" item 11, validate-rewrite Output format prose). The template at `references/templates/design-delta-ledger.md` §"Delta at a glance" is now the canonical home; the other three surfaces cite it by reference rather than re-enumerate. A future rewrite that adds or renames a category updates the template; the three citing surfaces stay correct without modification.
- **Locality concern — addressed.** The agent's "Inputs you will receive" section now lists `references/templates/design-delta-ledger.md` alongside the four existing references, with a note pointing to "What you check" item 11. The dependency from "agent reads the rubric" to "agent reads the rubric AND the ledger template" is now declared in the inputs list.
- **I2 (Enforcement, Medium) — deferred.** Substrate-noted in §"Remaining ambiguity" above. Authoring a hypothetical worked-example transcript up-front would risk modeling a divergence that doesn't reflect real failure modes; promotion happens when a real divergence is encountered.
- **I3 (Future-fit, Low) — deferred.** Substrate-noted in §"Remaining ambiguity" above. The §"Cutoff-date checks" convention can be authored if and when a second cutoff-scoped check arrives in `validate_plugin.sh`; a one-off pattern doesn't yet warrant a substrate page.

Files modified in repair pass 1: `skills/rewrite-specs/SKILL.md` (Acceptance bullet now cites the canonical category list); `agents/spec-cohesion-reviewer.md` (item 11 now cites the canonical category list; "Inputs you will receive" now lists the ledger template); `skills/validate-rewrite/SKILL.md` (Output format render-template prose now cites the canonical category list rather than enumerate). No body sections of this ledger required updates — file counts in §"Delta at a glance" are unchanged because repair pass 1 did not add, remove, or rename files; it tightened citations within the same files already enumerated under §"Files rewritten".

## Ready for fresh-eyes review?

**Yes** — repair pass 1 closed both pass-1 actionable findings (I1 + locality concern); I2 and I3 are deferred with substrate notes in §"Remaining ambiguity". The rewrite is internally consistent and the preamble in this very ledger remains the worked example future authors can copy.

## How to read this ledger

The intent is that a reviewer can:
1. Read the "Approved direction" line and know the destination.
2. Skim "Delta at a glance" and know the shape of the change in 8–15 lines.
3. Skim "Conceptual changes" and know what's *different* in detail.
4. Read "Files rewritten" with before/after snippets to verify each rewrite.
5. Use "Remaining ambiguity" as the focused review punch list.

The "Delta at a glance" preamble is also the surface `validate-rewrite` quotes verbatim into its rendered review, so the validation-review reader sees the same scannable summary at decision time. Keep it consistent with the body sections — the `spec-cohesion-reviewer` agent flags divergence as a Blocking Issue.
