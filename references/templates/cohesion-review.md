# Spec Cohesion Review — [topic]

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** YYYY-MM-DD
**Subject:** <which rewritten specs were reviewed; reference the design delta ledger>

**Status:** Approved / Issues Found / Design Incoherent

## Executive judgment

One paragraph. Could a future contributor — human or agent — read these rewritten specs and implement the system without needing the original architect's memory? If not, what's the single biggest gap?

## Blocking issues

Issues that should prevent moving from spec rewrite to implementation. Each must be repairable.

### B1. <short title>
- **Risk:** <what goes wrong if this ships as-is>
- **Substrate artifact to repair:** Spec / matrix / invariant / gotcha / linter / test
- **Suggested repair:** <concrete next step>

(repeat for B2, B3...)

## Important issues

Not blocking, but should be repaired in the same pass.

### I1. <short title>
- **Risk:** ...
- **Substrate artifact to repair:** ...
- **Suggested repair:** ...

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

## What looked right

Brief — the few highest-quality moves in this rewrite. Not flattery; calibration for the next reviewer.

- ...
