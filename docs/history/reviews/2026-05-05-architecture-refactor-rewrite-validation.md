# Rewrite Validation Review — architecture refactor (substrate design layer)

**Reviewer:** spec-cohesion-reviewer (fresh-eyes context)
**Date:** 2026-05-05
**Subject:** rewrite landed on `design/architecture-refactor`; design delta ledger at `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-05-architecture-refactor.md`. Classification: **Mixed**. Lenses 12–14 applied.

**Verdict:** Issues Found

## Executive judgment

The architecture/conventions split, the new per-skill design layer at `architecture/skills.md`, the new chain-handoff doc, and the `SKILL_DESIGN_DOC_SECTION` invariant are coherent, well-justified, and structurally bind the discipline. A future contributor reading this corpus could correctly route a design-shape edit to the design layer before SKILL.md. However, three internal contradictions in the rewrite would mislead that contributor: two surfaces still claim "two named invariants" inside docs that elsewhere claim four, and the `spec-cohesion-reviewer` agent description still names a long-retired skill (`review-spec-cohesion`, `cohesive-review`). One enforcement gap is non-blocking but high-leverage: the new invariant names "Check N" as a placeholder rather than a real validator-check ordinal, leaving the structural fence asserted but unimplemented. None invalidate the design; all are repair-in-place.

## Delta at a glance

> This rewrite is **Mixed**. Design-layer changes: the architecture/conventions split (5 file moves + 1 split into two halves), the new per-skill design layer (`architecture/skills.md`), the new chain-transition contracts (`architecture/handoffs.md`), the new named invariant (`SKILL_DESIGN_DOC_SECTION`). Implementation changes: the rewrite-specs Step 1a classification, the spec-cohesion-reviewer three-lens expansion, the ARCHITECTURE.md and README.md and AGENTS.md hook updates, all path citations across the corpus.
>
> Bootstrap caveat: the design layer being created here did not exist before this pass, so per-skill section content was authored retroactively against existing SKILL.md bodies. Lens 2 (design-implementation agreement) on the validate-rewrite pass following this ledger may surface drift; budget for one Issues Found verdict during the dogfood loop.
>
> - **Files:** 9 rewritten in place, 4 added, 6 renamed/moved (1 split into 2)
> - **Conceptual changes:** `designs/` → `architecture/` + `conventions/`; "Three-layer" → "Three-tier"; `skill-conventions` → `skill-shape`; `reviewer-agent-template` → `reviewer-agent-shape`; `agent-dispatch-protocol` split into `fresh-eyes-review` (property) + `dispatch-protocol` (template)
> - **Named invariants:** `SKILL_DESIGN_DOC_SECTION` added; total now 4
> - **Behavior matrices:** path citations only; no cell additions
> - **Gotchas:** none added/retired; cross-references updated
> - **Semantic linters:** `validate_plugin.sh` Check N proposed, deferred to implement-cohesively
> - **Deferred:** Check N implementation; per-skill file extraction; `architecture/substrate.md`

## Blocking issues

### B1. `skill-shape.md` and `PLUGIN_ROOT_PATHS.md` claim "two named invariants" while ARCHITECTURE.md, AGENTS.md, README.md, and `SKILL_DESIGN_DOC_SECTION.md` claim four

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** The four-invariant claim is the headline structural binding for the entire refactor — every contributor-facing doc names it. A contributor reading `skill-shape.md` line 166 ("This is one of two named invariants (`PLUGIN_ROOT_PATHS` and `VERDICT_BEFORE_EVIDENCE`)") will conclude the four-invariant claim elsewhere is aspirational or stale, and may skip enforcement of `IMPLEMENTATION_PLAN_COVERS_DELTA` and `SKILL_DESIGN_DOC_SECTION` on the assumption they aren't real. The same drift in `PLUGIN_ROOT_PATHS.md:51` ("the two named invariants (this one, and `VERDICT_BEFORE_EVIDENCE`)") is in the canonical-list doc that other docs cite *as* canonical.
- **Evidence:** `docs/substrate/conventions/skill-shape.md:166`; `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md:51`. Compare with `ARCHITECTURE.md:39`, `AGENTS.md:42`, `README.md:160-163`, `SKILL_DESIGN_DOC_SECTION.md:9` — all claim four.
- **Recommended fix:** Replace "two named invariants" with "four named invariants" in both files; enumerate `PLUGIN_ROOT_PATHS`, `VERDICT_BEFORE_EVIDENCE`, `IMPLEMENTATION_PLAN_COVERS_DELTA`, `SKILL_DESIGN_DOC_SECTION` consistently. The `PLUGIN_ROOT_PATHS.md` History row added during this pass should also note the count change to 4.
- **Substrate artifact to add or update:** specs (both files); ledger §"Files rewritten" entry for `PLUGIN_ROOT_PATHS.md` is currently absent and should be added (the file was in fact modified per the four-invariant claim at line 9, but the ledger lists `PLUGIN_ROOT_PATHS` under §"Named invariants" only as "strengthened (related-invariants list expanded from two to four); content unchanged" — the line 51 and line 81 stale strings show content *was not* fully updated).

### B2. `spec-cohesion-reviewer.md` description and synthesis citation name a retired skill

- **Severity:** High
- **Category:** Spec drift
- **Why it matters:** The frontmatter description (`review-spec-cohesion`) and the body's synthesizing-skill citation (`review-spec-cohesion`, `cohesive-review` Phase 4) reference skills that do not exist in v0.1. The actual dispatching skill is `validate-rewrite`; the actual whole-codebase skill is `review-codebase`. A contributor adding a sixth lens to `spec-cohesion-reviewer` would search for a non-existent dispatcher and find no match. The agent file is the spec for what the reviewer does and who calls it; the citation is canonical.
- **Evidence:** `agents/spec-cohesion-reviewer.md:14` ("the Cohesive `review-spec-cohesion` skill is invoking this agent automatically"); `agents/spec-cohesion-reviewer.md:112` ("the synthesizing skill (`review-spec-cohesion`, `cohesive-review` Phase 4)"). Compare to `validate-rewrite/SKILL.md` and `review-codebase/SKILL.md` (both in `architecture/skills.md` per-skill sections).
- **Recommended fix:** Replace `review-spec-cohesion` with `validate-rewrite` and `cohesive-review` with `review-codebase`. Audit the rest of the agent file for similar legacy names — the dispatch-prompt-shape citation in the cohesion-review template (line 19, "synthesizing skill (`validate-rewrite`, `cohesive:review-codebase`, `cohesive:review-diff`)") shows the canonical surface already uses correct names.
- **Substrate artifact to add or update:** spec (`agents/spec-cohesion-reviewer.md`).

## Important issues

### I1. `SKILL_DESIGN_DOC_SECTION.md` enforces via "Check N" — placeholder ordinal, not a real validator check

- **Severity:** Medium
- **Category:** Enforcement
- **Why it matters:** The named invariant's enforcement story is "`scripts/validate_plugin.sh` runs Check N" with a bash snippet. The other invariants name concrete check ordinals (`PLUGIN_ROOT_PATHS` is "check 13"; voice imperative is "Check 13b/13c"; anti-citation is "Check 13d"; delta-ledger preamble is "check 13h"). "Check N" is a placeholder. The ledger says implementation is deferred to implement-cohesively — fine — but a graduated-on-day-one invariant whose enforcement is referenced as a placeholder weakens the structural-fence claim. A future contributor reading this in isolation cannot tell whether the check exists or not.
- **Evidence:** `docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md:32` ("`scripts/validate_plugin.sh` runs Check N"); same file:9 (graduated-on-day-one claim); ledger §"Semantic linter specs" ("`validate_plugin.sh` Check N (proposed, not yet implemented in this pass)").
- **Recommended fix:** Either (a) reserve a concrete ordinal now (e.g., "Check 14") and mark "implementation deferred" against that ordinal, so docs are stable across the implementation phase; or (b) explicitly re-frame the rule as convention-with-grep-pending until the validator ships, and graduate to invariant once the check lands. Option (a) preserves the day-one graduation argument; option (b) is more honest about current state.
- **Substrate artifact to add or update:** invariant (`SKILL_DESIGN_DOC_SECTION.md`); `PLUGIN_ROOT_PATHS.md` §"Convention pins" canonical-list entry once the ordinal is reserved.

### I2. The brainstorm path the dispatch cites does not exist on `design/architecture-refactor`

- **Severity:** Low
- **Category:** Spec drift
- **Why it matters:** The validate-rewrite dispatch references the brainstorm at `docs/history/brainstorms/2026-05-05-architecture-refactor.md`. That file was authored on `main` before the worktree branched, but the dispatch reviewer (running fresh-context against the worktree) cannot see it on the design branch — only the 2026-05-04 brainstorm is present there. The ledger preamble cites the path as canonical provenance. A future reviewer trying to verify the design provenance hits a 404 in the worktree state. Per the ledger's own `discovery was conducted inline during brainstorm` framing in dispatch, this may be intentional (brainstorm conducted in-conversation), but the ledger should not cite a path that doesn't exist on the branch the rewrite lives on.
- **Evidence:** Ledger line 5 ("Approved direction: Option A from `docs/history/brainstorms/2026-05-05-architecture-refactor.md`"); `ls docs/history/brainstorms/` on the worktree shows only the 2026-05-04 file.
- **Recommended fix:** Persist the brainstorm to the design branch (cherry-pick or copy from main into the worktree, then commit), so the cited path resolves on the same branch as the ledger and the validation review. This is the canonical fix — provenance lives with the rewrite.
- **Substrate artifact to add or update:** ledger preamble (no change needed if the brainstorm is persisted); design branch (add the brainstorm artifact).

## Substrate gaps

- **Lens 14 (handoff contract consistency) cannot fully run** because the per-skill SKILL.md bodies (e.g., `validate-rewrite`, `implement-cohesively`, `cohesively`) were not in this dispatch's input set. The new skills.md sections claim verdict vocabularies and prereq checks; verifying upstream-vs-downstream agreement requires reading those SKILL.md bodies, which was out of scope. This is a bootstrap-pass artifact (the ledger acknowledges it), not a rewrite defect — but the next validate-rewrite pass that touches a chain edge needs SKILL.md paths in the dispatch input.

## Locality concerns

The architecture/conventions split is a clean locality move: `architecture/` is read when shape changes, `conventions/` is read when authoring. The new design layer (`skills.md`) sits at the right altitude — above SKILL.md, below ARCHITECTURE.md. The split of `agent-dispatch-protocol.md` into property (`fresh-eyes-review.md`) + template (`dispatch-protocol.md`) follows the same architecture/convention cut and is well-justified. No new shared abstractions without contracts.

## Future-fit concerns

§"Section growth policy" in `skills.md` names ~80 lines as the extraction trigger and explicitly defers the per-skill file extraction "until pressure surfaces." This is the right shape — future pressure acknowledged, not smuggled into normative scope.

## Enforcement concerns

`SKILL_DESIGN_DOC_SECTION` graduates to invariant on day one with a deferred validator check (see I1). The other three invariants have stable enforcement stories. The four-invariant claim is the load-bearing surface; the B1 drift undermines the enforcement narrative for two of the four.

## Vague language to tighten

None significant. Normative sections are end-state. The ledger §"Remaining ambiguity" correctly captures non-normative open questions. One minor: `architecture/skills.md:248` ("A per-skill section that grows past ~80 lines is signaling...") — the "~80" is approximate but the section growth policy is normative; consider tightening to a hard threshold or explicitly marking the threshold provisional (the ledger §"Remaining ambiguity" item 4 already does the latter; the doc could cite back).

## Recommended repairs (ranked)

1. Fix B1: replace "two named invariants" → "four named invariants" in `skill-shape.md:166` and `PLUGIN_ROOT_PATHS.md:51`; update `PLUGIN_ROOT_PATHS.md` History row.
2. Fix B2: replace `review-spec-cohesion` → `validate-rewrite` and `cohesive-review` → `review-codebase` in `spec-cohesion-reviewer.md` (lines 14, 112).
3. Address I1: reserve a concrete validator ordinal for `SKILL_DESIGN_DOC_SECTION` (e.g., "Check 14") rather than "Check N", or re-frame as convention-with-grep-pending.
4. Address I2: persist the brainstorm artifact to the design branch.

## Disposition

Repair → re-validate.

## What looked right

- The architecture/conventions split is clean and the rationale ("read when changing shape" vs "read when authoring") generalizes — `substrate-layout.md` Naming table now distinguishes them and the growth pattern documents both Phase-2 triggers.
- `architecture/skills.md` per-skill six-slot shape (Purpose / Owns / Does not own / Inputs / Outputs / Why this shape) is exactly the substrate that was missing from SKILL.md frontmatter and "What this skill is *not*" sections; the consolidation is high-leverage.
- `architecture/handoffs.md` per-handoff five-slot shape (artifact / persistence / verdict gate / must-not-re-derive / failure mode) makes chain-edge drift a concrete, reviewable surface — lens 14 has a real anchor for the first time.
- `skill-shape.md` §"When to edit SKILL.md alone, and when to edit the design layer first" with the "default to Mixed when ambiguous" rule pairs cleanly with `rewrite-specs` Step 1a — the discipline is bound at both the convention surface and the producing-skill surface.
- The `agent-dispatch-protocol.md` split into property (architecture) + template (convention) is a textbook altitude cut and the citation-reclassification rationale is documented in §"Remaining ambiguity" item 3.

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — repair the 2 Blocking + 2 Important findings in the same worktree, then re-run `cohesive:validate-rewrite`. The repairs are textual/surface-level (no design rethink); a single repair pass should converge to Approved.
