# Rewrite Validation Review — Disposition rule for validation-review findings (pass 3)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** Pass 3 fresh-eyes review of spec rewrite on branch `design/disposition-rule`. Pass 1 (Issues Found, 3 Blockers + 2 Important) closed by repair pass 1; pass 2 (Issues Found, 1 Blocker + 1 Medium, both new from incomplete propagation) closed by repair pass 2. Reviewing post-repair-pass-2 state. Design delta ledger at `docs/history/delta-ledgers/2026-05-05-disposition-rule.md`.

**Verdict:** Issues Found

## Executive judgment

Repair pass 2 closes both pass-2 findings cleanly: the cohesion-review template's Disposition phrase list now matches SKILL.md (substrate-note correctly demoted to user override, not an agent-rendered phrase), and the ledger body's "6-row"/"5-row" typo is fixed. The substrate is internally coherent across the four primary surfaces (rubric, SKILL.md, agent, cohesion-review template). One new finding surfaced this pass: a fifth citing surface — `docs/substrate/designs/skill-conventions.md` §"When sections may differ" — still describes the implementation-route conditional in its pre-repair-pass-2 form. The substrate is otherwise mergeable; this is the same incomplete-propagation defect class as pass-2, caught one citing surface deeper.

## Delta at a glance

- **Files:** 6 rewritten, 0 added, 0 removed/deprecated (file counts unchanged across repair pass 1; only intra-file content tightened)
- **Conceptual changes:** disposition rule promoted to canonical home of validation-review-finding recommendation; "Three options" menu pattern explicitly forbidden; verdict-floor mapping pinned (`Approved` ⇔ highest-severity ≤ Medium; `Issues Found` ⇔ highest-severity ≥ High); `Approved + Low` row made deterministic with substrate-note as user override; severity vocabulary aligned (`Blocking` → `Blocker` in rubric, matching reviewer-agent template); cohesion-review template section headers (`Blocking issues` / `Important issues`) glossed against severity vocabulary
- **Named invariants:** none added (disposition rule lives as convention in cohesion-rubric.md; promotion criteria deferred — see Remaining ambiguity)
- **Behavior matrices:** disposition table embedded in `references/cohesion-rubric.md` §"Disposition rule for validation-review findings" (5-row mapping of `(verdict, highest-severity)` → `(recommendation, re-validate?)`, total over the verdict-floor mapping); not a standalone matrix file
- **Gotchas:** none added (a future "Three options improvisation" gotcha is substrate-noted for follow-up if the pattern recurs)
- **Semantic linters:** none (a future grep that flags option-menu shapes in validation-review chat output is substrate-noted)
- **Tests proposed:** none
- **Deferred (out of scope this pass):** promotion of disposition rule to named invariant; validator check pinning the literal `Disposition:` line in `validate-rewrite` rendered output; gotcha note for the "Three options" failure mode; first-class override-residue ledger section (re-evaluation trigger: >3 silent overrides per release cycle)

## Blocking issues

### B1. `skill-conventions.md` deviation entry describes the pre-pass-2 implementation-route conditional

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** `docs/substrate/designs/skill-conventions.md:204` (the `validate-rewrite` deviation entry under §"When sections may differ") describes the conditional as "an **Implementation route** matrix (rendered iff verdict is `Approved` and disposition does not require re-validation)". Repair pass 2 (per ledger §"Repair pass 2" line 121) explicitly simplified this conditional to "iff verdict is `Approved`" — the verdict-floor mapping makes the re-validation gate redundant for Approved. Both `skills/validate-rewrite/SKILL.md:155` ("Render the implementation decision matrix iff the verdict is `Approved`") and `references/templates/cohesion-review.md:93` ("render iff verdict is `Approved`; otherwise omit") use the simplified form. `skill-conventions.md` is the citing surface that did not get the pass-2 update. This is a fifth citing surface for the disposition rule's render shape — the same shape class as pass-2 B1 (template drift), caught one substrate layer deeper. A future skill author revising `validate-rewrite` and reading `skill-conventions.md` to understand the exemption would reproduce the obsolete conditional, re-introducing the pass-1 disjunction class. The Files-rewritten section of the ledger (line 49) lists `skill-conventions.md` as updated, so the file is in scope; the update simply missed the pass-2 simplification.
- **Evidence:** `docs/substrate/designs/skill-conventions.md:204` ("rendered iff verdict is `Approved` and disposition does not require re-validation"); `skills/validate-rewrite/SKILL.md:155` ("iff the verdict is `Approved`"); `references/templates/cohesion-review.md:93` ("render iff verdict is `Approved`; otherwise omit"); ledger line 121 (pass-2 B1 closure narrative pinning the simplified form).
- **Recommended fix:** In `skill-conventions.md:204`, change "rendered iff verdict is `Approved` and disposition does not require re-validation" to "rendered iff verdict is `Approved`". Optionally cite the verdict-floor mapping inline so the simplification rationale is visible at the deviation entry. One-line edit.
- **Substrate artifact to add or update:** spec (`docs/substrate/designs/skill-conventions.md` §"When sections may differ", `validate-rewrite` deviation entry).

## Important issues

None.

## Substrate gaps

- The "incomplete propagation" failure mode has now appeared in two consecutive passes (pass-2 B1 = template drift; pass-3 B1 = skill-conventions drift). The `style-guide-rot` promotion criteria (wording stability + caught regression + worked transcript) are getting close to satisfied for a propagation-completeness check: every repair pass for a multi-surface canonical rule should grep all citing surfaces. Substrate-noting this as a candidate for a future semantic linter target ("disposition rule citation surfaces"), parallel to the substrate-noted Three-options grep already deferred. Not a finding this pass.

## Locality concerns

- Single canonical home + four citing surfaces (skill body, agent body, cohesion-review template, skill-conventions deviation entry) shape preserved; B1 is a citing-surface drift, not a locality regression. Once B1 closes, the surfaces will agree.

## Future-fit concerns

- None new. The override-residue trigger (>3 silent overrides per release cycle) and the verdict-floor pin remain defensible.

## Enforcement concerns

- None new. Body-level Red flag in skill + agent + the "What you must not do" entry continue to be the load-bearing defense; promotion to named invariant correctly deferred.

## Vague language to tighten

- `references/cohesion-rubric.md:122` — "Yes if the repair adds a new file or named invariant; otherwise no" (Approved + Medium row's Re-validate column carries a narrative conditional that's not derivable from `(verdict, highest-severity)` alone). Carried over from pass-2 substrate gaps; not a finding this pass — the prose is a known soft edge accepted as v0.1 substrate.

## Recommended repairs (ranked)

1. **B1: Update `skill-conventions.md:204` deviation entry to use the simplified conditional.** Change "iff verdict is `Approved` and disposition does not require re-validation" to "iff verdict is `Approved`". One-line edit; closes the fifth citing surface and finishes the propagation pass-2 started.

## Recommended next Cohesive skill

**Disposition:** Repair → re-validate

## What looked right

- Pass-2 B1 and I1 close with substrate-shaped fixes: the template phrase list now mirrors SKILL.md exactly (5 canonical phrases), and the demotion of substrate-noting to a user override per rubric §"Substrate-note as user override" is stated in the same shape across the rubric, SKILL.md, agent, and cohesion-review template — a clean "single canonical home, four citing surfaces" propagation modulo the B1 fifth surface.
- The repair pass 2 ledger entries at `docs/history/delta-ledgers/2026-05-05-disposition-rule.md:121-122` document each closure with `pass-2 B<n> closed —` + structural fix + cited file:line, matching the repair-pass-1 record shape. The ledger is now a worked transcript of two repair passes against the same substrate change, which is itself substrate worth preserving.
- The simplification of the implementation-route conditional from "iff Approved and disposition does not require re-validation" to "iff Approved" (rationalized by the verdict-floor mapping) is the right kind of substrate move: removing a redundant axis once the surrounding pin makes it derivable. The two surfaces that got the update (SKILL.md, cohesion-review template) read more cleanly for it.
