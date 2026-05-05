# Rewrite Validation Review — Delta-at-a-glance preamble convention (pass 2, post repair pass 1)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes Task subprocess)
**Date:** 2026-05-05
**Subject:** Pass 2 review of spec rewrite for Option A (Ledger preamble) on branch `design/delta-ledger-glance`. Pass 1 review at `docs/history/reviews/2026-05-05-delta-ledger-glance-rewrite-validation.md` returned Approved with three Important issues (I1 Spec drift Medium, I2 Enforcement Medium, I3 Future-fit Low) and one Locality concern. Repair pass 1 (commit `cdd5c8a`) addressed I1 and Locality concern; substrate-noted I2 and I3 as deferrals.

**Verdict:** Approved

## Executive judgment

The pass-1 repairs landed cleanly. I1 is closed by promoting the ledger template's §"Delta at a glance" to canonical and citing-by-reference from the three consumer surfaces; the locality concern is closed by adding the template to the agent's Inputs list with an explicit pointer to item 11. I2 and I3 are honestly substrate-noted in §"Remaining ambiguity" with rationale for deferral rather than silent omission. The rewrite is implementable; a future contributor reading these specs alone can author a compliant ledger, run the validator, and reproduce the reviewer's preamble↔body check. Two small leftover frictions remain (below) but neither blocks implementation.

## Delta at a glance

```
- Files: 5 rewritten, 1 added, 0 removed/deprecated
- Conceptual changes: none (pure addition of a new convention; no existing concept renamed or replaced)
- Named invariants: none — the new convention ships as convention-with-grep, not invariant-promoted, per `style-guide-rot.md` promotion criteria
- Behavior matrices: none
- Gotchas: none
- Semantic linters: `validate_plugin.sh` check 13h (added — preamble-presence grep on delta-ledger files dated on or after the 2026-05-05 cutoff); `spec-cohesion-reviewer` "What you check" item 11 (added — per-review preamble↔body consistency check, surfaces divergence as Blocking Issue)
- Tests proposed: none
- Deferred (out of scope this pass): optional phase-derivation matrix row marking the preamble as non-phase-generating; optional `preamble-drift-in-ledgers.md` gotcha pre-recording the failure mode; promotion of the convention to a named invariant after the convention has stabilized across two release cycles and a real regression has been caught
```

Preamble↔body check: passes. Files count (5 rewritten, 1 added) matches §"Files rewritten" (5 entries) and §"Files added" (1 entry); each preamble category resolves to a body section that confirms or expands it.

## Blocking issues

None.

## Important issues

### I1. Cohesion-review template's "Delta at a glance" prose paraphrases the validate-rewrite render rule rather than citing the canonical ledger spec
- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** Pass-1 repair I1 made `references/templates/design-delta-ledger.md` §"Delta at a glance" the canonical home of the category list and rendering rules. `references/templates/cohesion-review.md` lines 13–17 still inline the rendering rules ("If the ledger lacks the preamble, render `Preamble missing — see Blocking issues`"; "If the preamble is present but inconsistent...still quote it verbatim"). These rules also live in the agent's item 11 (lines 63) and validate-rewrite's render template (line 107). A future author tightening the missing-preamble or divergence rule has three surfaces to update, the exact rot the I1 repair was meant to prevent.
- **Evidence:** `references/templates/cohesion-review.md:13-17`; compare to `agents/spec-cohesion-reviewer.md:63` and `skills/validate-rewrite/SKILL.md:107`.
- **Recommended fix:** Reduce cohesion-review.md §"Delta at a glance" to a one-line cite: "Quote the ledger's `## Delta at a glance` section verbatim. See `references/templates/design-delta-ledger.md` §\"Delta at a glance\" for the canonical category list and the missing-preamble / divergence rendering rules." Move the rendering rules themselves to the ledger template so all three citing surfaces resolve to one canonical statement.
- **Substrate artifact:** spec (`references/templates/cohesion-review.md` and `references/templates/design-delta-ledger.md`)

### I2. validate-rewrite Output template still embeds the all-three-verdicts rule inline rather than citing it
- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** `skills/validate-rewrite/SKILL.md:107` carries the prose "This section appears across all three verdicts (Approved / Issues Found / Design Incoherent), not just Approved — Issues Found and Design Incoherent readers also need decision-time context for whether to repair the rewrite or revisit `brainstorm-design`." This is a normative claim about *when* the section renders; it is not stated in the canonical ledger template (which describes the section's content shape, not its render-time scope across verdicts). The rule has only one surface today, so this is not yet drift, but it is the surface most likely to be edited inconsistently with the agent's render template (`agents/spec-cohesion-reviewer.md:77-78`, which carries the same shape without the across-verdicts prose).
- **Evidence:** `skills/validate-rewrite/SKILL.md:107`; `agents/spec-cohesion-reviewer.md:77-78`.
- **Recommended fix:** Either move "renders across all three verdicts" into `references/templates/cohesion-review.md` as a normative rule (and cite from validate-rewrite/the agent), or accept this as the canonical surface and add a one-line cite from `agents/spec-cohesion-reviewer.md` so the agent's render template explicitly inherits it.
- **Substrate artifact:** spec (`references/templates/cohesion-review.md`)

## Substrate gaps

None new beyond what §"Remaining ambiguity" already names. The four ambiguities listed there are all honestly scoped as deferrals with stated triggers for promotion.

## Locality concerns

None. The repair-pass-1 addition of the ledger template to the agent's Inputs list closes the seam.

## Future-fit concerns

§"Remaining ambiguity" bullets 1–4 are clearly marked non-normative and tied to specific future triggers (second cutoff-scoped check arrives; real divergence encountered; line-counting promotion considered). No future pressure smuggled into normative sections.

## Enforcement concerns

The two-fence model (presence-grep at `validate_plugin.sh:444`; accuracy-judgment at `agents/spec-cohesion-reviewer.md:63`) is named, scoped, and implemented. Convention-with-grep status is justified per `style-guide-rot.md` promotion criteria. Cutoff-date grandfathering at `validate_plugin.sh:439` is sound.

## Vague language to tighten

None in normative sections. §"Remaining ambiguity" appropriately uses speculative language because it is non-normative by section header.

## Recommended repairs (ranked)

1. Collapse `references/templates/cohesion-review.md:13-17` to a one-line cite of the ledger template (I1 above). Highest leverage — it closes the same drift surface pass-1 I1 was opened against.
2. Decide canonical home for the across-verdicts render rule (I2 above). Lower leverage; only one surface today.

## What looked right

- Repair pass 1 §"Repair pass 1" in the ledger explicitly enumerates which files moved and why, including the negative claim "No body sections of this ledger required updates" with reasoning. Future readers see the repair as a delta, not as a re-edit.
- §"Remaining ambiguity" bullet 4 (I2 deferral) is the strongest deferral: it names the failure mode, the substrate the deferred work would land on (a captured-not-authored transcript), and the trigger condition (a real divergence encountered in session).
- The agent body's item 11 defines the divergence check operationally ("compare each category bullet to the corresponding body section") rather than abstractly. A reviewer can execute it without further calibration.
- Cutoff-date grandfathering in check 13h handles the legacy-ledger problem cleanly without requiring backfill, and the `ok` line distinguishes "no post-cutoff ledgers yet" from "all post-cutoff ledgers compliant" — useful operational signal.
