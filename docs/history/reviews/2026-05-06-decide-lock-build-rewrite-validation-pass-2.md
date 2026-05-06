# Rewrite Validation Review — Decide → Lock → Build user-facing gate framing (pass 2)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-06
**Subject:** Decide → Lock → Build user-facing gate framing rewrite (pass 2 of internal repair loop) on branch `design/decide-lock-build`; design delta ledger at `docs/history/delta-ledgers/2026-05-06-decide-lock-build.md`

**Status:** Issues Found

## Executive judgment

The rewrite executes a coherent hard cut-over: gate vocabulary is consistently pinned across `cohesively/SKILL.md`, `architecture/skills.md`, `audience-separation.md`, and the README; the validate-rewrite Approved trailer's architectural reflection is well-specified end to end (cohesion-review template format + SKILL.md Process Step 5 + chat-trailer Variants row all agree); pass-2 repairs visibly closed the prior pass's matrix-residue and prose/format-mismatch findings. The single Blocker is that **pass-2's I3 fix was applied only to `validate-rewrite/SKILL.md`** — `implement-cohesively/SKILL.md` carries the same render-conditional-parenthetical-inside-fenced-code-block pattern that I3 named as the failure mode. The pass-2 ledger asserts `Closes: B1, B2, I1, I2, I3` but I3 covers a class of error, not a single occurrence; the class survives in the sister skill the rewrite restructured in this same pass.

## Delta at a glance

This rewrite is **Mixed** — primarily Design (user-facing surface restructure: gate vocabulary, chain-rendering retired, lock→build handoff reflection, build-end spec-coverage verdict) with implementation seams in the chat-trailer template, the cohesion-review template, two SKILL.md `## Output format` blocks, and one validator check.

(Full preamble matches `docs/history/delta-ledgers/2026-05-06-decide-lock-build.md` lines 9-37.)

## Blocking issues

### B1. I3 fix incomplete — render-conditional parentheticals still leak in implement-cohesively render template

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** The pass-1 finding I3 named the failure mode (instructions/parentheticals inside ```md fences leak verbatim into user-facing output, per `docs/substrate/gotchas/style-guide-rot.md`). The pass-2 ledger marks I3 closed by extracting render-conditional rules to a prose §"Render-conditional rules for the body block" in `validate-rewrite/SKILL.md`. The same pattern survives in `implement-cohesively/SKILL.md` lines 145-146 and 151: `**Code matches locked design:** ✓ *(rendered when Phase 3 final cohesive:review-diff returns Pass / Pass with notes — …)*` and `**Drift detected:** ✗ <count> places *(rendered when Phase 3 returns Needs substrate / Risky / Block — …)*` and `Phase 3 review: <path> *(persisted; chat omits the full body)*`. All three sit inside the ```md fenced render template the model reproduces. A model dispatching this skill will render both verdict lines simultaneously plus the parentheticals, exactly the user-visible leak the gotcha names. The decide-lock-build rewrite's *core* design move was promoting this slot to the lead — getting it wrong here defeats the rewrite's headline.
- **Evidence:** `skills/implement-cohesively/SKILL.md:145-146`, `:151`. The ```md fence runs from line 136 to line 175.
- **Recommended fix:** Extract render-conditional parentheticals to a new prose subsection §"Render-conditional rules for the body block" preceding the render template (mirror the pattern applied to `validate-rewrite/SKILL.md` in pass 2). The fenced template should carry only the literal output the model is meant to reproduce — pick one line (`**Code matches locked design:** ✓` *or* `**Drift detected:** ✗ <count> places`), and let the prose subsection say which renders when. Resolve the `Aborted` case explicitly (Phase 3 didn't run; neither line applies).
- **Substrate artifact to add or update:** spec (`skills/implement-cohesively/SKILL.md` §"Output format"); cite `docs/substrate/gotchas/style-guide-rot.md` §"Correct pattern" for parity with validate-rewrite.

## Important issues

### I1. implement-cohesively `### Next` renders four verdict-branches simultaneously, contradicting default-recommend rule's spirit

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** `chat-trailer.md` §"How `### Next` carries payload" allows per-verdict-branch recommendations, but the §"Default-recommend rule" was added in this pass specifically to stop multi-row "user picks among rows" ceremony. `implement-cohesively/SKILL.md:171-174` lists all four `Internal <verdict>:` bullets at once inside the fenced render template, which a model will reproduce verbatim — the user sees four equally-weighted options on a render that should surface only the one matching their actual verdict. The chat-trailer Variants row for `validate-rewrite` got the new treatment; `implement-cohesively`'s did not.
- **Evidence:** `skills/implement-cohesively/SKILL.md:167-175`. Compare to `skills/validate-rewrite/SKILL.md:215-228` which now collapses to one default + disclosure.
- **Recommended fix:** Render only the bullet whose internal verdict matches the actual run. Either lift the per-verdict branching to a prose subsection ("Render the bullet matching the internal verdict; omit the other three") or apply the default-recommend disclosure shape if multiple plausible moves exist for one verdict.
- **Substrate artifact to add or update:** spec (`skills/implement-cohesively/SKILL.md` §"Output format").

### I2. Repair-pass 2 classification ("Pure implementation") narrows ledger preamble's "Mixed" without explanation

- **Severity:** Low
- **Category:** Vague language
- **Why it matters:** The ledger's `## Delta at a glance` preamble (line 11) classifies the rewrite as **Mixed**; the `## Repair pass 2` section (line 152) re-classifies as **Pure implementation**. Both labels are load-bearing — the spec-cohesion-reviewer applies lenses 12-14 only on Design/Mixed. A future reader can't tell which classification governs a given lens decision. The ledger should clarify: pass-2 *repairs* are pure implementation (textual fixes); the rewrite they repair remains Mixed.
- **Evidence:** `docs/history/delta-ledgers/2026-05-06-decide-lock-build.md:11`, `:152`.
- **Recommended fix:** In §"Repair pass 2", reword to "Classification of pass-2 repairs: Pure implementation; the underlying rewrite remains Mixed per §'Delta at a glance'."
- **Substrate artifact to add or update:** ledger entry; consider adding a per-pass classification field to `references/templates/design-delta-ledger.md` if this surfaces again.

## Recommended repairs (ranked)

1. Extract render-conditional parentheticals from `implement-cohesively/SKILL.md` Output format render template; mirror the pass-2 prose-subsection pattern from validate-rewrite (closes B1).
2. Resolve the four-bullet `### Next` in `implement-cohesively` to render only the matching verdict (closes I1).
3. Annotate the pass-2 classification line to disambiguate from the rewrite's Mixed classification (closes I2).

## What looked right

- **Architectural reflection slot is end-to-end coherent.** `cohesion-review.md` §"Architectural reflection" carries both render context and persisted-file format aligned (paragraph + three bullets); `validate-rewrite/SKILL.md` Process Step 5 cites it cleanly; chat-trailer Variants row reflects the same shape. Three surfaces, one contract.
- **Pass-2 repairs to validate-rewrite are exemplary.** The §"Render-conditional rules for the body block" prose subsection is the right structural fix and it cleanly separates the literal render from its conditions. The model deserved to be applied uniformly to implement-cohesively in the same pass.
- **Audience-separation §"Gate vocabulary is the user-facing chat-surface vocabulary"** is dense, scannable, and pins the seam structurally rather than as a reminder. The naming-of-retired-pattern (chain rendering) inside the convention is what makes future drift legible.

### Next

**Disposition:** Repair → re-validate
