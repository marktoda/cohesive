# Rewrite Validation Review — Architecture refactor: review-diff repair pass

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** Repair-pass rewrite closing review-diff Phase 3 findings (1 Blocker + 2 High + 5 Medium + 3 Low). Ledger at `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-05-architecture-refactor-review-diff-repair.md`.

**Verdict:** Approved

## Executive judgment

The repair pass closes its enumerated review-diff findings cleanly and lands two structural improvements that pay forward: the §"Bootstrap status" table in `architecture/skills.md` makes the design-layer's retroactive-authoring lifecycle legible and lensable, and the lens-13 expansion in `agents/spec-cohesion-reviewer.md` extends content-alignment coverage to non-gating terminal verdicts (the `Aborted` shape that escaped lens 14). The two `validated`-marked SKILL.md bodies (`implement-cohesively`, `rewrite-specs`) agree with their design-layer entries on Purpose, Owns, Inputs, Outputs, and the complete verdict vocabulary — including the four-terminal reconciliation the Blocker required. The new gotcha (`invariant-claimed-before-enforced.md`) captures the symptom, the tempting wrong fix, and the Reserved-vs-Running pattern. The single non-trivial residue is bootstrap drift on the at-a-glance verdict vocabulary for the three `inherited` off-chain skills — visible *because of* the bootstrap-status table the rewrite landed, and explicitly deferred by the rewrite's own scope discipline.

## Delta at a glance

> This rewrite is **Mixed**. Design-layer changes: bootstrap-status section in `architecture/skills.md`, two-fence model table in `SKILL_DESIGN_DOC_SECTION.md`, chain-exit edges in `architecture/handoffs.md`, design-layer-canonical-for-ownership rule in `skill-shape.md`, lens 13 expansion in `spec-cohesion-reviewer.md`. Implementation changes: verdict-vocabulary reconciliation between `architecture/skills.md` and `skills/implement-cohesively/SKILL.md` (the design layer's table cell was wrong; updated to match the SKILL.md's four terminals). Substrate additions: new gotcha at `gotchas/invariant-claimed-before-enforced.md` documenting the claim-before-enforce pattern that the validate-rewrite series missed.
>
> This is the first **validated** entry in `architecture/skills.md` §"Bootstrap status" — the `implement-cohesively` per-skill section is now confirmed against its SKILL.md body via fresh-eyes review. Other sections remain `inherited` until forward rewrites reach them.
>
> - **Files:** 7 rewritten, 1 added, 0 removed
> - **Conceptual changes:** `Implemented / Drift / Incomplete` → `Implemented / Phase Drift / Substrate Drift / Aborted`; two-fence model boundary surfaces; bootstrap-status concept introduced
> - **Named invariants:** `SKILL_DESIGN_DOC_SECTION` strengthened
> - **Behavior matrices:** none touched
> - **Gotchas:** `invariant-claimed-before-enforced.md` added
> - **Semantic linters:** none added; Check 15 already landed in commit `6cdae42`
> - **Tests proposed:** captured-transcript still queued
> - **Deferred:** structure reviewer Low #3 (composition asymmetry); structure reviewer Low #4 ("Why this shape" dual role)

Preamble matches body. Per-finding repairs section accounts for 7 rewritten + 1 added. No divergence.

## Blocking issues

None. Verdict-floor mapping requires this section carry no `High` or `Blocker` findings under an `Approved` verdict.

## Important issues

### I1. At-a-glance verdict vocabulary in `skills.md` disagrees with three `inherited` SKILL.md bodies

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** `architecture/skills.md` §"Skill set at a glance" lists `Healthy / Drifting / Incoherent` for `review-codebase`, `Cohesion-Safe / Drifting / Cohesion-Breaking` for `review-diff`, `Substrate-Healthy / Gaps Found / Substrate-Missing` for `audit-substrate`. The corresponding SKILL.md bodies actually return: `Healthy / Mostly healthy / Cohesive but under-enforced / Spec drift risk / Architecture risk`, `Pass / Pass with notes / Needs substrate / Risky / Block`, `Substrate sound / Substrate gaps / Substrate sparse`. Notably, `skills/implement-cohesively/SKILL.md` and `architecture/handoffs.md` correctly cite review-diff's actual vocabulary (`Pass / Pass with notes / Needs substrate / Risky / Block`) — so the design layer's at-a-glance row is the lone surface that disagrees. Same shape of bug the Blocker just closed for `implement-cohesively`. Expected bootstrap drift on inherited section; promotion to validated status follows when a forward rewrite reaches each row.
- **Evidence:** `architecture/skills.md:16-18` vs `skills/review-codebase/SKILL.md:115`, `skills/review-diff/SKILL.md:64`, `skills/audit-substrate/SKILL.md:68`.
- **Recommended fix:** Either substrate-note in the ledger §"Remaining ambiguity" with stable IDs per row (deferring to forward rewrites per the bootstrap-status discipline), or reconcile the at-a-glance table now in this same worktree (one-line-per-row annotation pointing readers at SKILL.md as canonical until promotion). The repair pass's own framing favors deferral; the at-a-glance table is the most-scanned surface and worth a one-line annotation regardless.
- **Substrate artifact to add or update:** `architecture/skills.md` §"Skill set at a glance" — patch in place or annotate the `Output verdict` column for inherited rows; corresponding rows in §"Bootstrap status" already capture inherited status.

### I2. New gotcha cites a check that does not yet ship in the lens-13 wording

- **Severity:** Low
- **Category:** Enforcement
- **Why it matters:** `gotchas/invariant-claimed-before-enforced.md:39` claims `cohesive:validate-rewrite` lens 13 explicitly notes "for an invariant whose §Enforcement claims a validator ordinal, verify the script contains a matching `# <N>.` comment block and the ordinal's name matches a documented invariant." The actual lens-13 text in `agents/spec-cohesion-reviewer.md:68` is broader (Purpose / Owns / Inputs / Outputs / verdict vocabulary) and does not include the validator-ordinal-comment-grep. The gotcha is asserting an enforcement story that isn't in the lens — a miniature recurrence of the very pattern the gotcha documents.
- **Evidence:** `gotchas/invariant-claimed-before-enforced.md:39` vs `agents/spec-cohesion-reviewer.md:68`.
- **Recommended fix:** Either tighten lens 13 to actually include the validator-ordinal grep, or rewrite the gotcha's "Tests / checks that preserve this" entry to read "lens 13 catches design-implementation disagreement broadly, including present-tense vs reserved-ordinal mismatches when reviewing an invariant doc" (matching what lens 13 actually does).
- **Substrate artifact to add or update:** `gotchas/invariant-claimed-before-enforced.md` §"Tests / checks that preserve this" or `agents/spec-cohesion-reviewer.md` lens 13 — pick one surface to be canonical.

## Substrate gaps

- The §"Bootstrap status" table predicts inherited-section drift for the three off-chain rows but the at-a-glance table itself is not annotated to redirect readers to SKILL.md as canonical for those rows (see I1). A reader who lands on the at-a-glance table without scrolling down to §"Bootstrap status" treats wrong verdicts as authoritative.

## Locality concerns

The two-fence model table in `SKILL_DESIGN_DOC_SECTION.md:36-40` (presence / content / shape) is a clean seam. Each fence names what it owns and the trigger that runs it; a future contributor adding a sibling check picks the row whose concern matches. Highest-leverage move in the rewrite.

## Future-fit concerns

The bootstrap-promotion lifecycle ("seven of nine sections remain inherited") is correctly framed as non-normative future pressure (ledger §"Remaining ambiguity" entry 1). Not smuggled into normative claims.

## Enforcement concerns

The new gotcha's §"Tests / checks that preserve this" overstates lens 13's coverage (see I2). All other invariant-bearing changes pair claim with enforcement story: Check 15 is now present-tense in `SKILL_DESIGN_DOC_SECTION.md:32` with a History row witnessing commit `6cdae42`.

## Vague language to tighten

None found in normative sections. The rewrite's prose is direct throughout.

## Recommended repairs (ranked)

1. Patch the at-a-glance table verdicts for `review-codebase`, `review-diff`, `audit-substrate` to match SKILL.md bodies, or annotate the cells with a "see SKILL.md" pointer until forward rewrites validate (I1).
2. Reconcile the gotcha's lens-13 citation with the actual lens-13 wording (I2).

## What looked right

- **Bootstrap-status table is the structural fix.** Makes the retroactive-authoring lifecycle legible to lens 13 and future reviewers; the table is the load-bearing primitive that converts "predicted drift" from folklore into substrate. The cited integration with `spec-cohesion-reviewer` lens 13 (read the table during dispatch; apply extra skepticism to inherited rows) is the seam that makes the table do work, not just describe it.
- **Two-fence model table** in `SKILL_DESIGN_DOC_SECTION.md` cleanly assigns presence / content alignment / section shape to distinct surfaces. Each row names what it does *not* check. A future sibling check picks a row.
- **Lens-13 expansion** to cover non-gating terminals is the right resolution to the Blocker. The contract that closes the gap permanently rather than spot-fixing the verdict cell.
- **New gotcha** (`invariant-claimed-before-enforced.md`) captures the Reserved-vs-Running pattern with a worked witness (commits `a80e7f1` → `6cdae42` for `SKILL_DESIGN_DOC_SECTION`). The "graduate-on-day-one is valid; claim-without-structure is not" framing is the durable lesson.

## Disposition

Close in same worktree → merge.
