# Rewrite Validation Review — architecture refactor (repair pass 1)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** repair-pass-1 commit `88d1cb7` against `design/architecture-refactor`; design delta ledger at `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-05-architecture-refactor.md`. Classification of the repair: **Pure implementation**. Re-applying lenses 1–14.

**Verdict:** Issues Found

## Executive judgment

Repairs B1, B2, I1, I2 from the prior validation review all landed cleanly: the four-invariant claim is now consistent across `ARCHITECTURE.md`, `AGENTS.md`, `README.md`, `skill-shape.md:166`, `PLUGIN_ROOT_PATHS.md:9/51/83`, and `SKILL_DESIGN_DOC_SECTION.md:9`; `spec-cohesion-reviewer.md` no longer cites the retired `review-spec-cohesion` / `cohesive-review` skills (the legacy names were replaced with `validate-rewrite` and `cohesive:review-codebase` at lines 14 and 112); `SKILL_DESIGN_DOC_SECTION.md:32` reserves **Check 15** with a complete bash snippet; the brainstorm artifact is now persisted on the design branch. However, repair-pass-1 introduced one new internal contradiction inside the file it most edited: `PLUGIN_ROOT_PATHS.md:34` still claims "The grep is **check 13** in the validator" while the same file's §"Convention pins" line 51 and History row at line 83 reserve **Check 14** for this invariant (with 13a/13b/13c/13d/13h taken by convention pins). The contradiction is internal to the canonical-list doc that other docs cite *as* canonical — same drift class as the original B1, repair-pass-1 missed one of its own surfaces.

## Delta at a glance

The repair-pass-1 commit message classifies as **Pure implementation** (per dispatch). The 2026-05-05 ledger's `## Delta at a glance` block describes the original Mixed pass; no preamble exists for the repair-pass-1 surface specifically. Per `references/templates/design-delta-ledger.md` consumer-rendering rules, repair-passes inherit the parent ledger's preamble; the inheritance is acceptable here because no new files, no new invariants, no new conceptual changes landed in the repair pass — only textual repair against four findings.

## Blocking issues

### B1. `PLUGIN_ROOT_PATHS.md` §"Enforcement" line 34 still says "check 13"; same file lines 51 + 83 + the History row reserve Check 14 for this invariant

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** This is the canonical home of the validator-ordinal allocation; every other doc cites this file rather than restating. A future contributor implementing the validator during `implement-cohesively` will read §"Enforcement" first (it's the load-bearing section for implementation work) and code the wrong ordinal, or burn a turn reconciling against §"Convention pins" line 51 and the History row at line 83 which both say Check 14. The repair-pass-1 ledger entry on this file (line 83) explicitly states "this one Check 14"; line 34 is an oversight that recreates exactly the original-B1 drift class — canonical-list doc disagreeing with itself — inside the file the repair pass most edited.
- **Evidence:** `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md:34` — "The grep is **check 13** in the validator." Compare to same file:51 ("this one (Check 14)"), :83 ("this one Check 14"), and `docs/substrate/conventions/skill-shape.md:166` ("`PLUGIN_ROOT_PATHS` Check 14").
- **Recommended fix:** Replace "check 13" → "Check 14" on line 34. Verify no other location in the file still names check 13 for this invariant. (The 13a/13b/13c/13d/13h ordinals legitimately remain — those are convention-pin grep slots, not this invariant.)
- **Substrate artifact to add or update:** invariant (`PLUGIN_ROOT_PATHS.md:34`); no ledger update needed if treated as a continuation of the same repair pass.

## Important issues

None.

## Substrate gaps

None new beyond the lens-14 bootstrap caveat the prior review surfaced (per-skill SKILL.md bodies were not re-read in this dispatch's input set). Lens 14 verification on chain edges remains deferred until a future validate-rewrite pass that includes SKILL.md paths in its input set.

## Locality concerns

None new. Repair pass touched only normative claims inside already-correct locality boundaries.

## Future-fit concerns

None.

## Enforcement concerns

`SKILL_DESIGN_DOC_SECTION` now ships with a concrete reserved ordinal (Check 15), a complete bash snippet, and a clear "implementation lands during `implement-cohesively`" deferral. This closes I1 cleanly and preserves the day-one graduation argument. The B1 residual above is an enforcement-narrative drift, not an enforcement gap.

## Vague language to tighten

None significant in repaired sections.

## Recommended repairs (ranked)

1. Fix B1: `PLUGIN_ROOT_PATHS.md:34` "check 13" → "Check 14".

## Disposition

Repair → re-validate.

## What looked right

- Repair B1 (four-invariant consistency) landed across all six surfaces named in the prior review. The History row at `PLUGIN_ROOT_PATHS.md:83` documents the count change explicitly with reserved-ordinal allocation, which makes the repair traceable.
- Repair B2 cleaned both citation sites in `spec-cohesion-reviewer.md` (frontmatter description at line 14 and synthesizing-skill citation at line 112) and used the canonical replacements (`validate-rewrite`, `cohesive:review-codebase`).
- Repair I1 chose option (a) from the prior review's recommendation — concrete ordinal reservation (Check 15) with full bash snippet and explicit deferral note — over option (b) convention-with-grep-pending. This preserves the day-one graduation argument and stabilizes the doc across the implementation phase.
- Repair I2 (brainstorm persistence) lands the artifact at the cited path on the design branch, so the dispatch citation now resolves on the same branch as the ledger.

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — repair the single remaining Blocking finding in the same worktree, then re-run `cohesive:validate-rewrite`. The repair is a one-token edit; the next pass should converge to Approved.
