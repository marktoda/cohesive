# Design Delta Ledger — Architecture refactor (substrate design layer)

**Date:** 2026-05-05
**Worktree / branch:** `.claude/worktrees/design+architecture-refactor` on `design/architecture-refactor`
**Approved direction:** Option A from `docs/history/brainstorms/2026-05-05-architecture-refactor.md` — architecture/conventions split + consolidated `architecture/skills.md` and `architecture/handoffs.md` + Move D binding (validator + reviewer expansion + skill-shape rule + rewrite-specs Step 1a + ARCHITECTURE.md hooks).

This ledger records what changed in the substrate during the rewrite that adds a per-skill design layer above the SKILL.md bodies, splits `docs/substrate/designs/` into `architecture/` and `conventions/`, and structurally binds the new layer via a fourth named invariant and three new spec-cohesion-reviewer lenses.

## Delta at a glance

This rewrite is **Mixed**. Design-layer changes: the architecture/conventions split (5 file moves + 1 split into two halves), the new per-skill design layer (`architecture/skills.md`), the new chain-transition contracts (`architecture/handoffs.md`), the new named invariant (`SKILL_DESIGN_DOC_SECTION`). Implementation changes: the rewrite-specs Step 1a classification, the spec-cohesion-reviewer three-lens expansion, the ARCHITECTURE.md and README.md and AGENTS.md hook updates, all path citations across the corpus.

Bootstrap caveat: the design layer being created here did not exist before this pass, so per-skill section content was authored retroactively against existing SKILL.md bodies. Lens 2 (design-implementation agreement) on the validate-rewrite pass following this ledger may surface drift; budget for one Issues Found verdict during the dogfood loop. Subsequent rewrites will use the design layer as the prior substrate.

- **Files:** 9 rewritten in place, 4 added, 6 renamed/moved (1 split into 2)
- **Conceptual changes:** `designs/` → `architecture/` + `conventions/` split; "Three-layer architecture" → "Three-tier architecture"; "skill-conventions" → "skill-shape"; "reviewer-agent-template" → "reviewer-agent-shape"; "agent-dispatch-protocol" split into property (`fresh-eyes-review`) and template (`dispatch-protocol`)
- **Named invariants:** `SKILL_DESIGN_DOC_SECTION` (added; mechanically enforced by `validate_plugin.sh` Check N once implemented; presence-check on per-skill sections in `architecture/skills.md`)
- **Behavior matrices:** `phase-derivation.md` flagged as may-need-update (a design-layer-only phase intent row may be needed during implement-cohesively); `router.md` cross-references updated; no cell additions in this pass
- **Gotchas:** none added or retired; cross-references updated across all 6 existing gotchas
- **Semantic linters:** `validate_plugin.sh` Check N (proposed, not yet implemented; to be added in implement-cohesively phase) — greps `architecture/skills.md` for `^### <skill_name>$` per directory under `skills/`
- **Tests proposed:** the captured-transcript dogfood test for the design layer is the validate-rewrite pass against this ledger itself; no separate test artifact
- **Deferred (out of scope this pass):** validate_plugin.sh Check N implementation (deferred to implement-cohesively); per-skill file extraction when sections grow past ~80 lines (deferred to v0.2 or later when pressure surfaces); `architecture/substrate.md` parallel doc for substrate primitives (deferred until corpus grows)

## Files rewritten

For each file whose normative content changed:

- `ARCHITECTURE.md`
  - **Before:** Three-tier architecture section described `docs/substrate/designs/` as the home of cross-cutting design docs; §"Where to look first" routed "Add or modify a skill" at the conventions doc and the closest skill; §"v0.1 scope" enumerated the user-facing skill set in prose; named three invariants.
  - **After:** Three-tier architecture section describes `architecture/` (cross-cutting decisions) and `conventions/` (component rules) separately; §"Where to look first" leads with rethink-first row at `architecture/skills.md` and `architecture/handoffs.md`, then add-new-skill (full sequence), then modify-body (no scope or seam change); §"v0.1 scope" hooks out the skill-set enumeration to `architecture/skills.md` and `architecture/handoffs.md`; names four invariants.
  - **Reason:** The path-discovery hooks must point at the design layer first or the layer becomes aspirational. The fourth invariant makes the layer's presence load-bearing.

- `README.md`
  - **Before:** §"What's in the box" listed `designs/` as one substrate subdirectory with six design docs.
  - **After:** §"What's in the box" lists `architecture/` (five docs incl. new `skills.md` and `handoffs.md`) and `conventions/` (four docs) as separate subdirectories; lists four named invariants.
  - **Reason:** Reflect on-disk reality after the split.

- `AGENTS.md`
  - **Before:** Source-of-truth hierarchy described hooks pointing at `docs/substrate/designs/`; substrate-vs-implementation test mentioned `skill-conventions, reviewer-agent-template, substrate-layout`; "The named invariants" section claimed "two named invariants"; convention references and "When you are about to..." rows pointed at `designs/` paths.
  - **After:** Hierarchy describes hooks pointing at `architecture/` and `conventions/`; substrate-vs-implementation test mentions `skill-shape, reviewer-agent-shape, dispatch-protocol, substrate-layout, the per-skill design layer in architecture/skills.md, the chain-handoff contracts in architecture/handoffs.md`; "The named invariants" section names four invariants with full descriptions; rows cite new paths; new "Rethink what a skill is for, owns, or seams with" row directs contributors to the design layer.
  - **Reason:** Keep AGENTS.md aligned with the new path layout and the four-invariant set.

- `docs/substrate/conventions/skill-shape.md` (formerly `designs/skill-conventions.md`)
  - **Before:** Title "Skill conventions"; opening paragraph named two invariants and pointed at `designs/` for related substrate.
  - **After:** Title "Skill shape"; opening paragraph names four invariants; second paragraph cites the per-skill design layer (`architecture/skills.md`) and chain-transition contracts (`architecture/handoffs.md`) above the SKILL.md, and previews the new §"When to edit SKILL.md alone, and when to edit the design layer first" rule. New §"When to edit SKILL.md alone…" section added near the top with implementation-vs-design checklist and the default-to-Mixed rule for ambiguity.
  - **Reason:** The convention doc is the canonical place for the rule that distinguishes implementation from design edits; it must name the rule explicitly to bind the discipline.

- `docs/substrate/conventions/substrate-layout.md` (formerly `designs/substrate-layout.md`, unchanged content within rename)
  - **Before:** Directory diagram showed `docs/substrate/designs/` as a substrate subdir; Naming table had a single "Design" row with `three-layer-architecture.md` example; Phase 2 of growth pattern said "create `docs/substrate/designs/`".
  - **After:** Diagram shows `architecture/` and `conventions/` as separate subdirs; Naming table splits "Architecture" (cross-cutting decisions) and "Convention" (prescriptive component rules) rows with `three-tier-architecture.md` and `skill-shape.md` examples; Phase 2 names both subdirs and when to create each.
  - **Reason:** The layout doc must describe the actual current layout.

- `docs/substrate/conventions/reviewer-agent-shape.md` (formerly `designs/reviewer-agent-template.md`, content unchanged within rename, plus one cross-ref update)
  - **Before:** Cited `docs/substrate/designs/agent-dispatch-protocol.md` for the full property and why both halves matter.
  - **After:** Cites `docs/substrate/architecture/fresh-eyes-review.md` for the property and `docs/substrate/conventions/dispatch-protocol.md` for the prescriptive contract.
  - **Reason:** The split means the property and the template each have a separate home; the citation updates accordingly.

- `docs/substrate/architecture/three-tier-architecture.md` (formerly `designs/three-layer-architecture.md`)
  - **Before:** Title "Three-layer architecture"; "Adding a skill" said read `skill-conventions.md`; "Adding an agent" referenced `agent-dispatch-protocol.md`; Related substrate cited `agent-dispatch-protocol.md` and `composition-with-superpowers.md` (sibling).
  - **After:** Title "Three-tier architecture" (matches body vocabulary which already used "tier"); "Adding a skill" reads `skills.md` and `handoffs.md` first, then `conventions/skill-shape.md`; "Adding an agent" references `conventions/dispatch-protocol.md` and `architecture/fresh-eyes-review.md`; Related substrate cites `fresh-eyes-review.md`, `conventions/dispatch-protocol.md`, `skills.md`, `handoffs.md`, `composition-with-superpowers.md`.
  - **Reason:** Filename and title now align (the body always used "tier"); citations point at the new layer.

- `skills/rewrite-specs/SKILL.md`
  - **Before:** Process steps 1, 2, 3... no classification step.
  - **After:** Process step 1a inserted between 1 and 2: classify rewrite as Pure implementation / Design / Mixed; default to Mixed when ambiguous; record the classification line in the delta ledger preamble.
  - **Reason:** The classification is the load-bearing mechanism that routes design pressure to the design layer first; without it, the discipline stays aspirational.

- `agents/spec-cohesion-reviewer.md`
  - **Before:** "What you check" had 11 items; token discipline was ≤500 words / ≤8 findings flat.
  - **After:** Items 12-14 added — substrate-first compliance (lens 1, triggered by Design or Mixed), design-implementation agreement (lens 2, per modified skill section), handoff contract consistency (lens 3, per modified handoff). Token discipline expanded with a per-classification budget: ≤500/≤8 for Pure implementation; ≤650/≤11 for Design or Mixed.
  - **Reason:** The reviewer is the content-alignment fence that complements the new SKILL_DESIGN_DOC_SECTION presence-fence; without expanded lenses, design-layer drift wouldn't be caught at validate-rewrite time.

## Files added

- `docs/substrate/architecture/skills.md` — per-skill design layer with one `### <name>` section per user-facing skill (chain-ordered: discover-substrate, brainstorm-design, rewrite-specs, validate-rewrite, implement-cohesively, then off-chain review-codebase, review-diff, audit-substrate, then router cohesively). Each section follows the canonical six-slot shape: Purpose / Owns / Does not own / Inputs / Outputs / Why this shape. Includes "Skill set at a glance" table, "What every Cohesive skill is" (3 properties), "Why these skills, not others" (6 cuts), "Adding a new skill" sequence, "Section growth policy".
- `docs/substrate/architecture/handoffs.md` — chain-transition contracts. Three transition shapes (chain, router dispatch, off-chain re-entry); chain diagram; per-handoff contracts for 5 chain edges (discover→brainstorm, brainstorm→rewrite, rewrite→validate, validate→implement-Approved, validate→rewrite-IssuesFound); 5 off-chain re-entry edges (review-codebase→brainstorm, review-codebase→rewrite, audit→rewrite, validate→brainstorm-DesignIncoherent, review-diff→out-of-chain); "Adding a new chain skill or re-entry edge" sequence.
- `docs/substrate/architecture/fresh-eyes-review.md` — the load-bearing review property half of the former `agent-dispatch-protocol.md`. Describes what the property is, why it matters, both-halves-required argument, what it forbids, what it does not forbid, failure modes, enforcement, alternatives, when to revisit.
- `docs/substrate/conventions/dispatch-protocol.md` — the prescriptive contract half of the former `agent-dispatch-protocol.md`. Names the dispatch-prompt template, the agent-file shape, concrete dispatch sites in v0.1, related substrate.
- `docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md` — new named invariant. Every directory under `skills/` has a `### <name>` section in `architecture/skills.md`. Mechanically enforced by `validate_plugin.sh` Check N (deferred to implement-cohesively). Graduated to invariant on day one because the regex is mechanical and the failure mode is binary.

## Files removed or deprecated

- `docs/substrate/designs/agent-dispatch-protocol.md` — split into `architecture/fresh-eyes-review.md` (property half) and `conventions/dispatch-protocol.md` (template half). Removed during the split; no deprecated annotation left behind (per Hard constraint #4).

The five other former-`designs/` files are renames, not removals; tracked under "Files rewritten" rather than here.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| `docs/substrate/designs/` (mixed altitudes) | `docs/substrate/architecture/` (cross-cutting decisions) + `docs/substrate/conventions/` (component rules) | Replaced (split) |
| Three-layer architecture (term) | Three-tier architecture (term) | Renamed (aligns filename with body vocabulary) |
| skill-conventions.md (filename) | skill-shape.md (filename) | Renamed |
| reviewer-agent-template.md (filename) | reviewer-agent-shape.md (filename) | Renamed |
| agent-dispatch-protocol.md (single file mixing property + template) | fresh-eyes-review.md (property) + dispatch-protocol.md (template) | Split |
| "Adding a skill" reads skill-conventions and the closest existing skill | "Adding a skill" reads architecture/skills.md and architecture/handoffs.md *first*, then conventions/skill-shape.md, then SKILL.md | Tightened |
| Three named invariants (PLUGIN_ROOT_PATHS, VERDICT_BEFORE_EVIDENCE, IMPLEMENTATION_PLAN_COVERS_DELTA) | Four named invariants (adds SKILL_DESIGN_DOC_SECTION) | Added |
| Spec-cohesion-reviewer 11 lenses | Spec-cohesion-reviewer 14 lenses (3 design-layer lenses triggered by classification) | Strengthened |
| Rewrite-specs Process steps 0-7 | Rewrite-specs Process steps 0, 1, 1a (classification), 2-7 | Tightened (new classification step) |
| Per-skill design intent scattered across SKILL.md frontmatter, "What this skill produces", "What this skill is *not*", router matrix cells, composition-with-superpowers tables | Per-skill design intent consolidated in `architecture/skills.md` `### <name>` sections | Replaced (consolidated) |
| Chain seam contracts implicit across rewrite-specs Step 7, validate-rewrite frontmatter, router dispatch grid, per-skill "Recommended next" footers | Chain seam contracts consolidated in `architecture/handoffs.md` per-handoff sections | Replaced (consolidated) |

## New or updated substrate

### Specs

- `docs/substrate/architecture/skills.md` — per-skill design layer; ~470 lines; one section per user-facing skill plus the at-a-glance table and "Why these skills, not others" cuts.
- `docs/substrate/architecture/handoffs.md` — chain-transition contracts; ~250 lines; 5 chain handoffs + 5 off-chain re-entry edges with five-slot per-contract shape.
- `docs/substrate/architecture/fresh-eyes-review.md` — the property half of the former dispatch protocol; ~75 lines.
- `docs/substrate/conventions/dispatch-protocol.md` — the template half of the former dispatch protocol; ~55 lines.
- `docs/substrate/conventions/skill-shape.md` §"When to edit SKILL.md alone, and when to edit the design layer first" — new section, ~25 lines, distinguishing implementation from design edits.
- `skills/rewrite-specs/SKILL.md` Process Step 1a — new step, ~15 lines, classifies the rewrite and records the classification in the delta ledger preamble.
- `agents/spec-cohesion-reviewer.md` items 12-14 + token discipline expansion — ~30 lines added.

### Behavior matrices

- `docs/substrate/matrices/phase-derivation.md` — flagged for possible row addition during implement-cohesively (a design-layer-only phase intent row); not modified in this rewrite.
- `docs/substrate/matrices/router.md` — path citations updated; no cell content changes.
- Other matrices (`reviewer-output-shape.md`, `skill-section-presence.md`, `artifact-placement.md`) — path citations updated; no cell content changes.

### Named invariants

- `SKILL_DESIGN_DOC_SECTION` — added; current scope: every directory under `${CLAUDE_PLUGIN_ROOT}/skills/` has a heading line matching `^### <name>$` (h3, exact directory name) in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md`. One-direction check.
- `PLUGIN_ROOT_PATHS` — strengthened (related-invariants list expanded from "two named invariants" to "four"); content unchanged.
- `VERDICT_BEFORE_EVIDENCE` — unchanged.
- `IMPLEMENTATION_PLAN_COVERS_DELTA` — unchanged.

### Gotchas

- No new gotchas added. The meta-failure-mode "SKILL.md edited as design instead of as implementation" is captured by `conventions/skill-shape.md` §"When to edit SKILL.md alone…" rather than spun out as a separate gotcha.
- All 6 existing gotchas have path citations updated.

### Semantic linter specs

- `validate_plugin.sh` Check N (proposed; not yet implemented in this pass) — greps `docs/substrate/architecture/skills.md` for `^### <skill_name>$` per directory under `skills/`. Failure message: `FAIL: skills/<name>/ has no '### <name>' section in <path>`. Implementation deferred to `implement-cohesively`.

### Tests / checks proposed (not yet implemented)

- `validate_plugin.sh` Check N — see above.
- The dogfood acid test for the refactor: when the user next runs Cohesive on Cohesive itself for a brainstorm-design pass on a change to `brainstorm-design`, does the agent edit `architecture/skills.md` (and possibly `architecture/handoffs.md`) before touching `skills/brainstorm-design/SKILL.md`? If yes, the substrate worked. Captured-transcript test (deferred to a future dogfood pass).

## What this rewrite *did not* do

- Implementation code: not changed (no validator script update, no actual `validate_plugin.sh` Check N implementation; deferred to implement-cohesively).
- Tests: not changed (no test artifacts added; the captured-transcript test is queued for a future dogfood pass).
- CI: not changed (`.github/workflows/validate.yml` unchanged; the new Check N lands during implement-cohesively).
- Per-skill file extraction: not done (sections in `skills.md` stay consolidated; extraction trigger is ~80 lines per section, none currently exceeds that).
- `architecture/substrate.md` parallel doc: not authored (substrate corpus too small to justify; deferred until pressure surfaces).
- Skill body thinning (Option B from the brainstorm): not pursued; SKILL.md bodies retain their current boilerplate.
- Validator script (`scripts/validate_plugin.sh`): not edited; the new Check N implementation is for implement-cohesively.

## Remaining ambiguity

1. **`phase-derivation.md` row for design-layer-only phases**: the brainstorm flagged that a phase intent like "update `architecture/skills.md` per ledger entry X" might be a phase that doesn't write code at all — just updates docs. Whether `phase-derivation.md` needs an explicit row for this case versus implicit handling under existing rows is a judgment call deferred to implement-cohesively Phase 1's coverage table authoring.

2. **First validate-rewrite pass may surface drift**: the design-layer was authored retroactively against the existing SKILL.md bodies. Lens 2 (design-implementation agreement) on the validate-rewrite pass against this ledger may surface drift between the new `architecture/skills.md` per-skill sections and the existing skill body content. This is expected for the bootstrap pass; subsequent rewrites will use the design layer as prior substrate.

3. **`architecture/fresh-eyes-review.md` and `conventions/dispatch-protocol.md` cross-citation**: the split places half of the former `agent-dispatch-protocol.md` content in each file. Citations to the original doc were classified case-by-case; some judgment calls remain (for example, the `gotchas/skipping-per-phase-plan.md` citation went to `conventions/dispatch-protocol.md` because the gotcha is about dispatch contract specifics, not the property). Future contributors may reclassify.

4. **Section growth policy threshold**: `architecture/skills.md` §"Section growth policy" names ~80 lines as the extraction trigger but the threshold is provisional. Real pressure may shift it.

5. **PLUGIN_ROOT_PATHS pin enumeration vs SKILL_DESIGN_DOC_SECTION graduation**: the new invariant is graduated to invariant-level enforcement on day one rather than going through the convention-with-grep tier first. This is justified by the regex's mechanical simplicity and the binary failure mode but is a deviation from the typical promotion path described in `style-guide-rot.md` §promotion. Reviewer judgment may accept or contest this graduation.

## Ready for fresh-eyes review?

**Yes** — the rewrite is committed atomically on `design/architecture-refactor`. The validator passes (existing checks; Check N is deferred to implement-cohesively). All cross-references updated. Brainstorm artifact at `docs/history/brainstorms/2026-05-05-architecture-refactor.md`. Approved direction is Option A.

The fresh-eyes review will surface this rewrite's classification as **Mixed** and run all four spec-cohesion-reviewer lenses (substrate-first compliance, design-implementation agreement, handoff contract consistency, plus the existing 11 cohesion-rubric items). The bootstrap caveat in §"Delta at a glance" applies: lens 2 may surface drift between the design layer and existing SKILL.md bodies; budget for one Issues Found verdict.

## How to read this ledger

The intent is that a reviewer can:
1. Read the "Approved direction" line and know the destination.
2. Skim "Delta at a glance" and know the rewrite is Mixed and what's in scope.
3. Skim "Conceptual changes" and know what's *different* in detail (especially the architecture/conventions split and the four-invariant set).
4. Read "Files rewritten" with before/after summaries to verify each rewrite.
5. Use "Remaining ambiguity" as the focused review punch list.

The "Delta at a glance" preamble is also the surface `validate-rewrite` quotes verbatim into its rendered review. The bootstrap caveat in that preamble is what lets the reviewer interpret a possible Issues Found verdict on this pass as expected drift surfacing rather than design failure.
