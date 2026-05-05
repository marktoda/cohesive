# Rewrite Validation Review — Delta-at-a-glance preamble convention (pass 3, post repair pass 2)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes Task subprocess)
**Date:** 2026-05-05
**Subject:** Pass 3 review of spec rewrite for Option A (Ledger preamble) on branch `design/delta-ledger-glance`. Pass 1 review at `docs/history/reviews/2026-05-05-delta-ledger-glance-rewrite-validation.md` (Approved with 3 Important + 1 Locality). Pass 2 review at `docs/history/reviews/2026-05-05-delta-ledger-glance-rewrite-validation-pass-2.md` (Approved with 2 Important). Repair pass 1 (commit `cdd5c8a`) addressed pass-1 I1 + Locality. Repair pass 2 (commit `cf3890c`) addressed pass-2 New-I1 by promoting `references/templates/design-delta-ledger.md` §"Delta at a glance" to canonical home of category list + authoring rules + consumer rendering rules.

**Verdict:** Approved

## Executive judgment

Repair pass 2 closed pass-2 New-I1 cleanly. `references/templates/design-delta-ledger.md` §"Delta at a glance" is now unambiguously the canonical home of the category list, authoring rules, and consumer rendering rules; the three consumer surfaces (`cohesion-review.md`, the reviewer agent body, the `validate-rewrite` render-template prose) cite it rather than restate. The three deferrals (pass-1 I2, pass-1 I3, pass-2 New-I2) are honestly substrate-noted in §"Remaining ambiguity" with rationale. The rewrite is implementable as written. One internal contradiction predates this rewrite but is now visible against the new agent block — see I1.

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

## Blocking issues

None.

## Important issues

### I1. Issue-shape contradiction between agent body and review template

- **Severity:** Medium
- **Category:** Spec drift
- **Why it matters:** The reviewer agent's "Issue format (canonical six-field shape)" section (`agents/spec-cohesion-reviewer.md:93-104`) requires every issue to carry six fields (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact). The render block at line 82 of the same file restates the six-field shape. But the cohesion-review template at `references/templates/cohesion-review.md:21-25, 32-35` specifies a three-field shape (Risk / Substrate artifact / Suggested repair), and the agent body line 87 directs reviewers to "Use the template at `references/templates/cohesion-review.md`." A future reviewer following the template literally will produce the three-field shape and violate the agent's six-field requirement; a future reviewer following the agent block will produce the six-field shape and diverge from the template. The synthesizing skill referenced at agent line 104 expects uniform shape across reviewer agents. Predates this rewrite but the new line-82 render block makes the contradiction newly load-bearing.
- **Evidence:** `agents/spec-cohesion-reviewer.md:82` ("Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact"); `agents/spec-cohesion-reviewer.md:87` ("Use the template at `references/templates/cohesion-review.md`"); `references/templates/cohesion-review.md:21-25` (three-field "Risk / Substrate artifact / Suggested repair").
- **Recommended fix:** Align the cohesion-review.md template's B1/I1 example shapes to the canonical six-field shape, citing `docs/substrate/designs/reviewer-agent-template.md` §"Output format conventions" once. This is the same single-source-of-truth move repair pass 2 made for the preamble.
- **Substrate artifact to add or update:** spec — `references/templates/cohesion-review.md` issue-shape examples.

### I2. Across-verdicts rule still single-surface

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** The "this section appears across all three verdicts" rule (`validate-rewrite/SKILL.md:107`) is the operational constraint that distinguishes Option A from Option C (Approved-footer-only). It lives only in `validate-rewrite`. The ledger acknowledges this as pass-2 New-I2 and defers promotion until a second consumer of across-verdicts scoping appears. The deferral rationale is sound, but a reader of `references/templates/design-delta-ledger.md` §"Consumer rendering rules" will not learn that across-verdicts scoping is part of the rendering contract — they will infer it is a per-consumer choice. Not yet drift; flagged so the next pass remembers.
- **Evidence:** `skills/validate-rewrite/SKILL.md:107`; ledger §"Remaining ambiguity" pass-2 New-I2 entry.
- **Recommended fix:** When a second across-verdicts consumer arrives, promote the rule to `references/templates/design-delta-ledger.md` §"Consumer rendering rules" as a fourth bullet. No action this pass.
- **Substrate artifact to add or update:** spec — `references/templates/design-delta-ledger.md` §"Consumer rendering rules" (deferred).

## Substrate gaps

None this pass beyond what the ledger already substrate-notes.

## Locality concerns

None. Agent's "Inputs you will receive" (line 45) declares the new dependency on `design-delta-ledger.md`. Pass-1 locality concern stays closed.

## Future-fit concerns

None. Future pressure (named-invariant promotion, cutoff-date convention, captured worked-example transcript) is contained in §"Remaining ambiguity" with explicit promotion criteria.

## Enforcement concerns

The two-fence model (validator grep for presence; reviewer judgment for accuracy) is intact. Validator check 13h grandfathers pre-cutoff ledgers correctly, and this ledger (2026-05-05, cutoff itself) carries the preamble.

## Vague language to tighten

None found in normative sections of the rewritten files.

## Recommended repairs (ranked)

1. I1 — align `cohesion-review.md` issue-shape examples to the six-field canonical shape (predates this rewrite but newly-load-bearing).
2. I2 — defer until a second across-verdicts consumer arrives; current substrate note is sufficient.

## What looked right

- Repair pass 2's promotion of `design-delta-ledger.md` §"Delta at a glance" to canonical home of category list + authoring rules + consumer rendering rules is the same single-source-of-truth shape the pass-2 reviewer asked for, executed cleanly. The three citing surfaces are tight one-liners that will not drift.
- The §"Repair pass 1" and §"Repair pass 2" sections in the ledger preserve the audit trail without polluting the "Files rewritten" body counts — file counts in §"Delta at a glance" remained 5/1/0 across both repair passes because no files were added or removed; only citations within already-enumerated files were tightened. This is the right discipline for a multi-pass repair history.
- The agent's "Inputs you will receive" addition (line 45) declares the new dependency on the ledger template explicitly rather than letting the dependency live implicitly in item 11.
