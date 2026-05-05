# Rewrite Validation Review — Disposition rule for validation-review findings (pass 2)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** Pass 2 review of spec rewrite on branch `design/disposition-rule`. Pass 1 review at `docs/history/reviews/2026-05-05-disposition-rule-rewrite-validation.md` (Issues Found, 3 Blockers + 2 Important). Repair pass 1 (commit `3e6b133`) closed all 5 findings. Design delta ledger at `docs/history/delta-ledgers/2026-05-05-disposition-rule.md`.

**Verdict:** Issues Found

## Executive judgment

Repair pass 1 closes B1/B2/B3/I1/I2 cleanly: the disposition table is now deterministic over a pinned verdict-floor mapping, the `Approved + Low` disjunction is gone, the Issues Found row covers `High or Blocker`, the cohesion-review template glosses its "Blocking issues" heading against the Blocker severity term, and the override clause carries an explicit re-evaluation trigger. The single canonical home + three citing surfaces shape is intact. Two new findings surfaced in this pass: a phrase-set drift between `cohesion-review.md` (template the agent reproduces) and `validate-rewrite/SKILL.md` §"Disposition derivation" (the skill that dispatches the agent), and a count typo (5 vs 6 rows) inside the ledger body that disagrees with the ledger's own (correct) preamble. Both are repairable in one small pass.

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

### B1. Cohesion-review template lists a Disposition phrase that the skill explicitly forbids

- **Severity:** Blocker
- **Category:** Spec drift
- **Why it matters:** The cohesion-review template at `references/templates/cohesion-review.md:91` enumerates `Substrate-note in ledger §"Remaining ambiguity" → merge` as one of the legitimate Disposition phrases. The SKILL.md Disposition derivation at `skills/validate-rewrite/SKILL.md:153` explicitly states the five legitimate phrases (`Merge as-is — no findings`, `Close inline (≤2 lines per finding) → merge`, `Close in same worktree → merge`, `Repair → re-validate`, `Return to brainstorm-design`) and says "Substrate-noting is a user override of the Approved + Low default per the rubric §'Substrate-note as user override', **not a separate Disposition phrase the agent renders**." The reviewer agent is instructed to use the cohesion-review template as its output template; it will render the forbidden phrase, reproducing the same "two phrases pickable for one input" defect that pass-1 B1 closed in the rubric body. The rule's canonical home is correct; one citing surface contradicts.
- **Evidence:** `references/templates/cohesion-review.md:91` (template phrase list includes Substrate-note); `skills/validate-rewrite/SKILL.md:153` (skill phrase list excludes Substrate-note + explicit "not a separate Disposition phrase the agent renders").
- **Recommended fix:** Remove `Substrate-note in ledger §"Remaining ambiguity" → merge` from the template's example phrase list at `cohesion-review.md:91`. Replace with the 5-phrase set from `SKILL.md:153`. Add a one-line note that substrate-noting is a user override per rubric §"Substrate-note as user override", not a phrase the agent renders.
- **Substrate artifact to add or update:** spec (`references/templates/cohesion-review.md` §"Recommended next Cohesive skill")

## Important issues

### I1. Ledger §"Behavior matrices" says "6-row table"; preamble (and actual table) say 5

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** The ledger's §"Delta at a glance" preamble at `docs/history/delta-ledgers/2026-05-05-disposition-rule.md:14` correctly says "5-row mapping". The body §"New or updated substrate" → §"Behavior matrices" at line 76 says "6-row disposition table". The actual table at `references/cohesion-rubric.md:118-124` has 5 data rows under one header row. Per the consumer rendering rules at `references/templates/design-delta-ledger.md:32-38` (item 11 of `agents/spec-cohesion-reviewer.md`), preamble-body divergence within a ledger is a Blocking Issue surface. The preamble is correct (which is what `validate-rewrite` quotes verbatim into the validation review), so reader-facing impact is limited; the typo lives in the body. Catch-and-fix this pass before the wrong number is copied into a future ledger as a template.
- **Evidence:** `docs/history/delta-ledgers/2026-05-05-disposition-rule.md:14` ("5-row mapping"); same file line 76 ("6-row disposition table"); `references/cohesion-rubric.md:118-124` (5 data rows).
- **Recommended fix:** Change "6-row" to "5-row" at the ledger line cited. The preamble already shows the correct count.
- **Substrate artifact to add or update:** spec (the ledger itself; one-character fix)

## Substrate gaps

- No worked transcript yet of an `Approved + Medium` rendered Disposition phrase (`Close in same worktree → merge` + the Re-validate scope-conditional `Yes if the repair adds a new file or named invariant; otherwise no`). The rule's last narrative axis (the conditional re-validate column for Medium) is novel; without a worked example the next agent improvises whether to render the conditional or the boolean. Substrate-noted; not a finding this pass.

## Locality concerns

- Single canonical home + three citing surfaces shape preserved. ✓ B1 above is a citing-surface drift, not a locality regression.

## Future-fit concerns

- Override-residue trigger pinned at "more than 3 silent overrides per release cycle" — observability through the existing §"Remaining ambiguity" residue contract. Defensible for a first iteration.

## Enforcement concerns

- Body-level Red flag in skill + agent + a "What you must not do" entry. Promotion to named invariant correctly deferred per `style-guide-rot.md` promotion criteria. No further action this pass.

## Vague language to tighten

- `references/cohesion-rubric.md:122` — "Yes if the repair adds a new file or named invariant; otherwise no" (Approved + Medium row's Re-validate column carries a narrative conditional that's not derivable from `(verdict, highest-severity)` alone; consider promoting "scope-of-repair" to a third axis or accepting the prose as a known soft edge — see Substrate gaps)

## Recommended repairs (ranked)

1. **B1: Reconcile the cohesion-review template's Disposition phrase list with the SKILL.md derivation list.** Remove Substrate-note phrase from `cohesion-review.md:91`; add the override note. The rule of record (rubric) and the dispatching skill (SKILL.md) already agree; only the template citing surface drifts.
2. **I1: Fix "6-row" → "5-row" in the ledger body §"Behavior matrices".** One-character correction; preamble is already correct.

## Recommended next Cohesive skill

**Disposition:** Repair → re-validate

## What looked right

- Pass-1 B1/B2/B3/I1/I2 all close with substrate-shaped fixes, not papered-over wording. The new rubric §"Verdict → severity-floor mapping" is the load-bearing pin that retires the pass-1 defect class structurally; it is cited from the agent's verdict definitions and the SKILL.md hard constraint, so the pin propagates.
- §"Substrate-note as user override" at `references/cohesion-rubric.md:130` correctly resolves the "two-phrase row" defect by promoting substrate-note out of the table into a named override path with a contractual ledger residue. The override does not change the agent's render — exactly the right shape.
- The `>3 silent overrides per release cycle` re-evaluation trigger at `references/cohesion-rubric.md:132` is the right substrate move: it accepts the unobservability of overrides in v0.1 while making the trigger to fix it concrete and counter-shaped (count, not vibes).
- Repair pass 1 ledger entries at `docs/history/delta-ledgers/2026-05-05-disposition-rule.md:107-115` document each closure with `B<n> closed —` + the structural fix + the cited file:line. This is the right shape for a repair-pass record; the next reviewer can verify each closure quickly.
