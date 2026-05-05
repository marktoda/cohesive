# Spec Cohesion Review — [topic]

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** YYYY-MM-DD
**Subject:** <which rewritten specs were reviewed; reference the design delta ledger>

**Status:** Approved / Issues Found / Design Incoherent

## Executive judgment

One paragraph. Could a future contributor — human or agent — read these rewritten specs and implement the system without needing the original architect's memory? If not, what's the single biggest gap?

## Delta at a glance

This section is a **render slot** in the validation review document, not the canonical contract for the preamble. Quote the ledger's `## Delta at a glance` section verbatim here. The **canonical contract** — category list, authoring rules, and consumer rendering rules (missing-preamble handling and divergence-from-body handling) — lives at `references/templates/design-delta-ledger.md` §"Delta at a glance"; that section names itself as canonical-contract using the same bolded term, so the contract/slot relationship is symmetric whichever document a reader opens first.

## Blocking issues

Issues that should prevent moving from spec rewrite to implementation. Each finding uses the canonical six-field shape from `docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions" — the same shape every Cohesive reviewer agent produces — so the synthesizing skill (`validate-rewrite`, `cohesive:review-codebase`, `cohesive:review-diff`) can merge findings uniformly.

### B1. <short title>
- **Severity:** Blocker / High / Medium / Low
- **Category:** Spec drift / Locality / Invariant / Test / Domain model / Vague language / Future-fit / Enforcement
- **Why it matters:** <concrete consequence; not "may cause confusion">
- **Evidence:** <file:line references; quoted snippets when illustrative>
- **Recommended fix:** <concrete next step the rewriter can act on>
- **Substrate artifact to add or update:** spec / behavior matrix / named invariant / gotcha / semantic linter / test / type boundary

(repeat for B2, B3...)

## Important issues

Not blocking, but should be repaired in the same pass. Use the same six-field shape as Blocking issues.

### I1. <short title>
- **Severity:** ...
- **Category:** ...
- **Why it matters:** ...
- **Evidence:** ...
- **Recommended fix:** ...
- **Substrate artifact to add or update:** ...

## Substrate gaps

Substrate the rewrite *didn't* add but should have. Distinct from issues with what was added.

- <gap>: <why it matters>
- ...

## Locality concerns

Does the rewrite increase the context required to make a future change in this area? Are seams clear?

- ...

## Future-fit concerns

Does the rewrite acknowledge future pressure without smuggling it into current scope?

- ...

## Enforcement concerns

Are named invariants accompanied by an enforcement story (test/type/constraint/linter/runtime wrapper/CI)?

- ...

## Behavior knowable outside implementation?

- Are matrix cells complete enough that an agent could reproduce the decision function?
- Are test names traceable to spec sections or matrix cells?
- Is any normatively-important behavior knowable *only* by reading code?

## Vague language to tighten

Look for "should," "probably," "we will," "TODO," "TBD" in normative sections of the rewrite. List them here:

- <file>:<line> — "<offending phrase>"
- ...

## Recommended repairs (ranked)

1. <highest leverage>
2. <next>
3. ...

## Recommended next Cohesive skill

The recommendation is determined by the disposition rule in `references/cohesion-rubric.md` §"Disposition rule for validation-review findings", which maps `(verdict, highest-severity-present)` to a single recommendation. The reviewer commits to one phrase; alternative options are not rendered.

**Disposition:** <one phrase from the rubric table — e.g., `Merge as-is — no findings`, `Close inline (≤2 lines per finding) → merge`, `Substrate-note in ledger §"Remaining ambiguity" → merge`, `Repair → re-validate`, `Return to brainstorm-design`>

**Implementation route:** [render iff verdict is `Approved` and disposition does not require re-validation; otherwise omit] — the dispatching `validate-rewrite` skill renders the implementation decision matrix from `skills/validate-rewrite/SKILL.md` §"Output format". When the disposition requires re-validation or is `Return to brainstorm-design`, omit the matrix entirely.

## What looked right

Brief — the few highest-quality moves in this rewrite. Not flattery; calibration for the next reviewer.

- ...
