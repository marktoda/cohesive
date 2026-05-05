# Rewrite Validation Review — architecture refactor (repair pass 2)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** repair-pass-2 commit `dbe441e` against `design/architecture-refactor`; design delta ledger at `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-05-architecture-refactor.md`. Repair classification per dispatch: **Pure implementation**. Re-applying lenses 1–14.

**Verdict:** Approved

## Executive judgment

The single Blocking finding from pass 2 (`PLUGIN_ROOT_PATHS.md:34` saying "check 13" while the rest of the same file and four downstream cites said Check 14) is repaired. Line 34 now reads "Check 14"; lines 51, 83, the History row, and `skill-shape.md:166` all agree. The four-invariant claim is consistent across `ARCHITECTURE.md:39`, `AGENTS.md:42`, `README.md`, `skill-shape.md:3` and :166, `PLUGIN_ROOT_PATHS.md:9` and :51, and `SKILL_DESIGN_DOC_SECTION.md:9`. Validator-ordinal allocation (13a `VERDICT_BEFORE_EVIDENCE`, 13b/c/d voice/anti-citation, 13h delta-preamble, 14 `PLUGIN_ROOT_PATHS`, 15 `SKILL_DESIGN_DOC_SECTION`) is consistent on every surface that names ordinals. No new internal contradictions introduced; no new files; no new claims. A future contributor reading `PLUGIN_ROOT_PATHS.md` from any entry point lands at the same ordinal.

## Delta at a glance

The repair-pass-2 commit classifies as **Pure implementation** per dispatch — a single textual edit to repair the residual finding from pass 2. No preamble exists for this surface specifically; per `references/templates/design-delta-ledger.md` consumer-rendering rules, repair passes inherit the parent ledger's preamble. Inheritance is appropriate here: no new files, no new invariants, no new conceptual changes, no scope shift.

## Blocking issues

None.

## Important issues

None.

## Substrate gaps

None new beyond the lens-14 bootstrap caveat the ledger §"Remaining ambiguity" item 2 already records (chain-edge verification deferred until SKILL.md paths are in dispatch input). That gap is intentional and ledger-tracked, not a finding.

## Locality concerns

None. Repair touched a single normative claim inside the canonical-list doc already correctly localized.

## Future-fit concerns

None.

## Enforcement concerns

`PLUGIN_ROOT_PATHS` §"Enforcement" line 34 now matches §"Convention pins" line 51 and the History row line 83. The validator-ordinal narrative is internally coherent: a contributor implementing the validator during `implement-cohesively` reads "Check 14" wherever they enter the file.

## Behavior knowable outside implementation?

Yes. The four-invariant set, the validator-ordinal allocation, the per-skill design layer presence rule, and the chain-handoff contracts are all knowable from the specs alone. No regression from prior passes' Approved findings on lens 1.

## Vague language to tighten

None significant in the repaired surface.

## Recommended repairs (ranked)

None.

## Disposition

Merge as-is — no findings.

## What looked right

- Repair landed exactly where pass 2 named it; no collateral edits introduced new drift surfaces.
- Internal consistency across the canonical-list doc (`PLUGIN_ROOT_PATHS.md` lines 34 / 51 / 83 / History row) now holds — same drift class that bit pass 1 (B1) and pass 2 (B1) is closed on the third pass.
- The ordinal-allocation story (13a / 13b / 13c / 13d / 13h / 14 / 15) is coherent across every surface that names an ordinal: the canonical-list doc, the per-invariant doc, `skill-shape.md`, `ARCHITECTURE.md`, `AGENTS.md`. A grep for any single ordinal returns the same allocation everywhere.

### Recommended next Cohesive skill

Per the implementation decision matrix in `${CLAUDE_PLUGIN_ROOT}/skills/validate-rewrite/SKILL.md` §"Output format":

| Option | Skill | When to pick |
|---|---|---|
| Implement now with delta-coverage discipline (default) | `cohesive:implement-cohesively` | Substantial rewrites; the rewrite added named invariants, behavior matrices, or cross-cutting conceptual changes. Phase loop with per-phase cross-review against the delta. |
| Land specs first; implement separately later | merge the `design/architecture-refactor` branch first; later run `cohesive:implement-cohesively` against the merged delta ledger | Spec rewrite is independently valuable (e.g., for review by humans before code lands); the implementation has dependencies that aren't yet ready. |
| Hand off to Superpowers without delta-coverage discipline | `superpowers:writing-plans` | Small rewrites where the delta is mostly cosmetic; user accepts that the implementation may drift from the rewrite. The bypass is documented per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` §"Known bypass risks." |
| Schedule for later | (no immediate action) | The rewrite is approved; implementation is not currently in scope. Re-invoke `cohesive:implement-cohesively` or `superpowers:writing-plans` when ready. |

Recommended default: **`cohesive:implement-cohesively`** — substantial rewrite added one named invariant (`SKILL_DESIGN_DOC_SECTION`), one design-layer doc with one section per skill (`architecture/skills.md`), one chain-handoff contract doc (`architecture/handoffs.md`), three new reviewer lenses, a rewrite-specs classification step, and the `validate_plugin.sh` Check 15 implementation is the natural Phase 1 candidate.
