# Rewrite Validation Review — Disposition rule for validation-review findings (pass 4)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** Pass 4 fresh-eyes review of spec rewrite on branch `design/disposition-rule`. Pass 1 (Issues Found, 3 Blockers + 2 Important) closed by repair pass 1; pass 2 (Issues Found, 1 Blocker + 1 Medium) closed by repair pass 2; pass 3 (Issues Found, 1 High at fifth citing surface) closed by repair pass 3. Reviewing post-repair-pass-3 state. Design delta ledger at `docs/history/delta-ledgers/2026-05-05-disposition-rule.md`.

**Verdict:** Approved

## Executive judgment

Repair pass 3 closes pass-3 B1 cleanly. The skill-conventions deviation entry now reads "rendered iff verdict is `Approved`" with an inline citation to the verdict-floor mapping rationale, matching the four other citing surfaces (rubric, SKILL.md §"Output format", agent §"How to structure your output", cohesion-review template). All five citing surfaces of the disposition rule's render shape agree byte-for-byte on the Approved-only conditional render. The five canonical Disposition phrases are stated identically in SKILL.md line 153 and cohesion-review template line 91; the agent and rubric cite without restating. Preamble matches body in the ledger. No new Blocker- or High-severity findings; the rewrite is implementable.

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

None.

## Important issues

### I1. Canonical Disposition-phrase strings live on two surfaces, not one

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** The five canonical Disposition phrases are stated as literal strings in two surfaces — `skills/validate-rewrite/SKILL.md:153` and `references/templates/cohesion-review.md:91` — but the rubric table at `references/cohesion-rubric.md:118-124` (the canonical home per its own "Citations" paragraph) carries different prose in the **Recommendation** column. The phrase forms are paraphrases of the rubric rows, not citations of them. Two surfaces hold the literal phrases and the rubric does not — the same multi-surface drift surface the disposition rule was designed to close.
- **Evidence:** `references/cohesion-rubric.md:118-124` (table column wording); `skills/validate-rewrite/SKILL.md:153` ("the five legitimate phrases are..."); `references/templates/cohesion-review.md:91` (same five phrases, identical strings); rubric §"Citations" line 134 claims SKILL.md, agent, and cohesion-review template "cite this section rather than restate the table" — but the literal phrases are not in the rubric to cite.
- **Recommended fix:** Add a sixth column to the rubric table (`Canonical Disposition phrase`) carrying the literal phrase string for each row, then have SKILL.md and the cohesion-review template cite that column rather than restate the five strings.
- **Substrate artifact to add or update:** spec (rubric table column addition).

### I2. Stale "across repair pass 1" qualifier in preamble file-count bullet

- **Severity:** Low
- **Category:** Vague language
- **Why it matters:** Preamble line 11 reads "Files: 6 rewritten, 0 added, 0 removed/deprecated (file counts unchanged across repair pass 1; only intra-file content tightened)". After repair passes 2 and 3, the qualifier is stale.
- **Evidence:** `docs/history/delta-ledgers/2026-05-05-disposition-rule.md:11`.
- **Recommended fix:** Update the parenthetical to "file counts unchanged across all repair passes; only intra-file content tightened".
- **Substrate artifact to add or update:** spec (ledger preamble copy-edit).

## Substrate gaps

- A semantic linter that greps the canonical Disposition phrases across SKILL.md and cohesion-review template would catch I1-class drift mechanically. Substrate-noted in the ledger §"Remaining ambiguity" as a "disposition rule citation surfaces" grep candidate.

## Locality concerns

None. The disposition rule is correctly localized to the rubric; the five citing surfaces each cite rather than re-derive the rule's logic. The only locality residue is the phrase-string duplication in I1.

## Future-fit concerns

None. The override-residue re-evaluation trigger and the verdict-floor pin remain defensible.

## Enforcement concerns

The disposition rule is convention-only; promotion to named invariant is correctly deferred per `style-guide-rot.md` promotion criteria. No further action this pass.

## Vague language to tighten

- `docs/history/delta-ledgers/2026-05-05-disposition-rule.md:11` — "across repair pass 1" (see I2)

## Recommended repairs (ranked)

1. Close I1 by adding a `Canonical Disposition phrase` column to the rubric table.
2. Close I2 by updating the preamble parenthetical to cover all three repair passes.

## Recommended next Cohesive skill

**Disposition:** Close in same worktree → merge

**Implementation route** — pick one:

| Option | Skill | When to pick |
|---|---|---|
| Implement now with delta-coverage discipline (default) | `cohesive:implement-cohesively` | Substantial rewrites; the rewrite added named invariants, behavior matrices, or cross-cutting conceptual changes. |
| Land specs first; implement separately later | merge the `design/<slug>` branch first; later run `cohesive:implement-cohesively` against the merged delta ledger | Spec rewrite is independently valuable; the implementation has dependencies that aren't yet ready. |
| Hand off to Superpowers without delta-coverage discipline | `superpowers:writing-plans` | Small rewrites where the delta is mostly cosmetic; user accepts implementation may drift. |
| Schedule for later | (no immediate action) | The rewrite is approved; implementation is not currently in scope. |

This rewrite is doc-only (no executable code). The land-specs-first row is the natural fit: merge the branch.

## What looked right

- Pass-3 B1 closure is precise and auditable. The skill-conventions deviation entry now states the simplified conditional and inlines the verdict-floor rationale, matching the four sibling citing surfaces.
- The rubric §"Substrate-note as user override" cleanly separates default (close-inline) from override (substrate-note), and pins the override's substrate landing surface (ledger §"Remaining ambiguity") with a stable-ID + rationale + back-citation contract. This is a high-quality "rule, not menu" design move.
- The verdict-floor mapping (rubric §"Verdict → severity-floor mapping") makes the disposition table total and forbids the previously-ambiguous `Approved + High` cell with a clear contract-violation framing rather than a silent gap.
