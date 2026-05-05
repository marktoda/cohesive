# Design Delta Ledger — Layout Migration

**Date:** 2026-05-04
**Worktree / branch:** main (no prior commits)
**Approved direction:** Restructure `docs/` to separate current canonical substrate from dated/preserved artifacts. Promote `ARCHITECTURE.md` to top-level binding (canonical pattern: lean map with hook lines pointing at design docs). Demote `implementation_plan.md` to a historical artifact. Collapse "workflow outputs" and "preserved historical" into a single `docs/history/` umbrella. Seed `docs/substrate/designs/` with three load-bearing design docs.

This ledger records the second `rewrite-specs` pass on 2026-05-04. The previous pass (Phase 1 substrate, ledger at `docs/history/design-changes/2026-05-04-phase-1-substrate.md`) added invariants, gotchas, conventions, and a router matrix in their initial locations; this pass moved them into a clean two-tier structure (substrate / history) with `ARCHITECTURE.md` as the front door.

## Files rewritten

- `AGENTS.md`
  - **Before:** Source-of-truth section named the implementation plan as binding for v0.1 and the spec as historical-vision. Directed contributors to update plan §2 when adding skills.
  - **After:** Source-of-truth section names `/ARCHITECTURE.md` as binding. Directs contributors to update `ARCHITECTURE.md` only when broad shape changes; historical context (initial-design, mvp plan) acknowledged as preserved-but-not-authoritative. Default substrate locations updated to the new tree (`docs/substrate/<kind>/`, `docs/history/<kind>/`).
  - **Reason:** Demotion of the plan from binding to historical required the source-of-truth doc to redirect.

- `docs/substrate/designs/skill-conventions.md`
  - **Before:** "Process when adding a new skill" step 3 told the contributor to update plan §2.
  - **After:** Step 3 directs the contributor to `/ARCHITECTURE.md` only when the skill changes the broad shape; otherwise just the README.
  - **Reason:** Plan demotion.

- `README.md`
  - **Before:** Status line referenced `docs/initial_design.md` and `docs/implementation_plan.md` as the spec/plan locations.
  - **After:** Status line references `ARCHITECTURE.md` as the architectural map; the historical spec and dated plan are linked under their `docs/history/...` paths.
  - **Reason:** Layout migration; promotion of `ARCHITECTURE.md`.

- `skills/cohesive-review/SKILL.md` (Phase 1 normative-doc list)
  - **Before:** Listed `CLAUDE.md / AGENTS.md`, `architecture.md`, `README.md`, `docs/design/**`, etc.
  - **After:** Adds `ARCHITECTURE.md` (uppercase) to the priority-2 line and `docs/substrate/**` to the priority-4 line, so reviews of repos adopting Cohesive's convention find the new structure.
  - **Reason:** Detection-list extension to support repos using the new layout.

- `skills/rewrite-specs/SKILL.md` (default-artifact-dir mention)
  - **Before:** Suggested `docs/design/`, `docs/specs/`, `docs/invariants/` as existing repo conventions to detect.
  - **After:** Adds `docs/substrate/` to the detection list.
  - **Reason:** Same.

- `docs/history/initial-design.md` (banner only; body preserved)
  - **Before:** Banner pointed at `docs/implementation_plan.md` as the binding doc.
  - **After:** Banner points at `/ARCHITECTURE.md` as the binding map; the historical plan is named at its new path. Body unchanged — still describes the v0.1 vision verbatim.
  - **Reason:** Banners on historical docs are meta-content (pointers to current state) and may be updated; the historical body is preserved.

- `docs/history/plans/2026-05-04-mvp-implementation.md` (banner added; body preserved)
  - **Before:** No top-level banner; opened with the plan's normative content.
  - **After:** Top banner clarifies that the doc is a preserved historical artifact and that path references within reflect the layout at the time of writing. Body unchanged.
  - **Reason:** The plan was demoted from binding to historical; readers landing here need the redirect.

- `docs/history/design-changes/2026-05-04-phase-1-substrate.md` (banner added; body preserved)
  - **Before:** No top-level banner; opened with the ledger's normative content.
  - **After:** Top banner clarifies that paths within reflect the layout at time of writing and points at `ARCHITECTURE.md` and this layout-migration ledger. Body unchanged.
  - **Reason:** Phase 1 ledger references `docs/cohesive/...`, `docs/invariants/...` paths that have since moved; banner avoids editing the historical record while orienting future readers.

## Files added

- `ARCHITECTURE.md` (top-level) — binding architectural map. Three-tier architecture, composition with Superpowers, fresh-eyes review, substrate / conventions / "where to look first" / risks. Lean (~80 lines); each section ends with hook lines pointing at deeper docs.
- `docs/substrate/designs/three-layer-architecture.md` — extracted load-bearing design doc explaining why skills/agents/references are three deliberate tiers.
- `docs/substrate/designs/composition-with-superpowers.md` — extracted design doc explaining the seam pattern with Superpowers (worktree externalized; recommendation pattern; what Cohesive deliberately does not own).
- `docs/substrate/designs/agent-dispatch-protocol.md` — extracted design doc explaining the fresh-eyes Task-tool dispatch protocol and the both-sides-required enforcement.
- `docs/history/README.md` — short index of `docs/history/`: what lives there, contrast with `docs/substrate/`.
- `docs/history/design-changes/2026-05-04-layout-migration.md` — this ledger.

## Files removed or deprecated

None deleted. All previous content moved to new locations:

- `docs/initial_design.md` → `docs/history/initial-design.md`
- `docs/implementation_plan.md` → `docs/history/plans/2026-05-04-mvp-implementation.md`
- `docs/invariants/*.md` (5 files) → `docs/substrate/invariants/`
- `docs/cohesive/gotchas/*.md` (2 files) → `docs/substrate/gotchas/`
- `docs/cohesive/router-matrix.md` → `docs/substrate/matrices/router.md`
- `docs/cohesive/reviews/2026-05-04-cohesive-self-review.md` → `docs/history/reviews/2026-05-04-self-review.md`
- `docs/cohesive/phase-1-substrate/design-delta.md` → `docs/history/design-changes/2026-05-04-phase-1-substrate.md`
- `docs/transcripts/` (empty) → `docs/history/transcripts/`

Empty directories removed: `docs/cohesive/`, `docs/cohesive/phase-1-substrate/`, `docs/cohesive/gotchas/`, `docs/cohesive/reviews/`, `docs/invariants/`, `docs/transcripts/`.

## Conceptual changes

| Old concept | New concept | Status |
|---|---|---|
| `docs/implementation_plan.md` is binding for v0.1 | `/ARCHITECTURE.md` is binding for current architecture | Replaced |
| `docs/implementation_plan.md` is binding | `docs/history/plans/2026-05-04-mvp-implementation.md` is preserved historical | Demoted |
| Spec/plan/README/on-disk = four sources of truth | `ARCHITECTURE.md` / README / on-disk = three sources of truth | Tightened |
| `docs/cohesive/` is the namespace for Cohesive-related docs in this repo | `docs/cohesive/` is the *external* default; this repo uses `docs/substrate/` and `docs/history/` | Replaced (for internal use) |
| `docs/invariants/` (parallel sibling under `docs/`) | `docs/substrate/invariants/` (under the substrate umbrella) | Relocated |
| Workflow outputs scattered under `docs/cohesive/{reviews,phase-1-substrate,...}` | Workflow outputs under `docs/history/{reviews,design-changes,transcripts}` | Reorganized |
| "Designs" lived inside SKILL.md bodies + scattered references | Cross-cutting designs live in `docs/substrate/designs/` with hook lines from `ARCHITECTURE.md` | New tier |
| Plan §1 delta table is the authoritative spec/plan reconciliation | `ARCHITECTURE.md` describes current state; the delta table is preserved-as-historical inside the moved plan | Tightened |

## New or updated substrate

### Specs
- `/ARCHITECTURE.md` — new binding architectural map; supersedes `implementation_plan.md` for current-state authority. Lean (~80 lines); hook-style.
- `docs/history/initial-design.md` banner — updated to redirect to `ARCHITECTURE.md`.
- `docs/history/plans/2026-05-04-mvp-implementation.md` banner — added; redirects to `ARCHITECTURE.md`.

### Behavior matrices
None added. `docs/cohesive/router-matrix.md` moved unchanged to `docs/substrate/matrices/router.md`.

### Named invariants
None added. The five from Phase 1 moved unchanged from `docs/invariants/` to `docs/substrate/invariants/`.

### Gotchas
None added. The two from Phase 1 moved unchanged from `docs/cohesive/gotchas/` to `docs/substrate/gotchas/`.

### Cross-cutting design docs (new tier)
- `docs/substrate/designs/three-layer-architecture.md` — skills/agents/references separation rationale, alternatives considered, when to revisit.
- `docs/substrate/designs/composition-with-superpowers.md` — the Superpowers seam, what Cohesive deliberately does not own, risks accepted.
- `docs/substrate/designs/agent-dispatch-protocol.md` — the fresh-eyes Task-tool dispatch contract, both-sides enforcement, dispatch sites in v0.1.

### Semantic linter specs (proposed, not implemented)
None added in this pass. Phase 1's five invariants still describe their own enforcement specs; this pass did not add new invariants.

### Tests / checks proposed (not yet implemented)
- A `validate_plugin.sh` extension to grep `ARCHITECTURE.md` for currency markers (skill list matches `skills/`, agent list matches `agents/`, reference list matches `references/`). Flags obvious staleness.
- A `validate_plugin.sh` check that the on-disk `skills/` / `agents/` / `references/` / `scripts/` directories match what `ARCHITECTURE.md` claims (parity check).
- Detection-list expansion in `validate_plugin.sh` to recognize `docs/substrate/` and `docs/history/` as Cohesive's own conventions when running against this repo.

## What this rewrite *did not* do

- Implementation code: not changed.
- Tests: not changed.
- CI: not changed.
- `validate_plugin.sh`: not extended (Phase 3 work).
- The five named invariants and two gotchas: bodies unchanged; only their paths moved.
- The router behavior matrix: body unchanged; only its path moved.
- The historical plan body: unchanged; only the top-of-file banner added.
- The historical spec body: unchanged; only the top-of-file banner updated.
- The Phase 1 design-delta ledger: body preserved as the historical record; banner added at top to clarify path drift.
- `references/templates/implementation-plan.md` decision (delete or commit): still deferred from Phase 1.
- `cohesive-review --scope substrate` mode split: deferred (Phase 2 of self-review roadmap).
- `scripts/scan_substrate.py:82` precedence bug: deferred (Phase 2).
- Second dogfood transcript against an external repo: not produced.
- README §"What's in the box" tree: not updated to mention `docs/substrate/`, `docs/history/`, `ARCHITECTURE.md`. The status line cites them; the "What's in the box" code block still describes only the plugin tiers (`skills/`, `agents/`, `references/`, `scripts/`) — which are still accurate. Adding a `docs/` overview to that block is a small follow-up.
- `agents/*.md` reviewer agents and `skills/*/SKILL.md` other skills: did not check for residual path references beyond the two SKILLs explicitly updated. The path sweep verified no remaining old-layout refs in any of the swept files.

## Remaining ambiguity

- **`README.md` §"What's in the box" tree expansion.** Currently lists plugin tiers only. Should be expanded to describe the new `docs/` structure. Small follow-up; not blocking.
- **Detection-list parity in `cohesive-review` and `rewrite-specs` SKILLs.** The two skills now mention `docs/substrate/` in their detection lists (this pass), but the prose explanation of "default artifact dir" and "what counts as existing convention" could be tightened in a future pass.
- **`/ARCHITECTURE.md` currency.** The doc claims a specific set of skills/agents/references/templates/scripts. As components evolve, this list will drift unless `validate_plugin.sh` grows a parity check (proposed above; Phase 3).
- **Initial commit not made.** The repo still has zero commits. Suggested message for the combined Phase 1 + layout-migration: `design: phase-1 substrate + layout migration` — or two separate commits if the user wants atomic history (`design: phase-1 substrate` and `design: layout migration`). User decides.
- **Spec-cohesion review.** This pass is also eligible for fresh-eyes review via `cohesive:review-spec-cohesion`. The reviewer should read `ARCHITECTURE.md`, the three new design docs, the AGENTS.md updates, and this ledger.

## Ready for fresh-eyes review?

**Yes.** This is structural work — the substrate content was unchanged; only its locations moved and `ARCHITECTURE.md` plus three design docs landed as net-new content. The reviewer's job: verify that `ARCHITECTURE.md` is genuinely lean (no creeping detail), that the three new design docs in `substrate/designs/` are scoped well (cross-cutting, not duplicating component-internal design that lives in SKILL bodies), that historical artifacts are correctly framed by their banners, and that no stale path references remain in non-historical files.

## How to read this ledger

1. Read the "Approved direction" line: layout migration to substrate/history split with `ARCHITECTURE.md` promotion.
2. Skim "Conceptual changes" for the binding-doc shift (plan → ARCHITECTURE.md) and the substrate/history umbrella structure.
3. Read `/ARCHITECTURE.md` first — that's the new front door.
4. Read the three design docs in `docs/substrate/designs/` — they carry the architectural detail that `ARCHITECTURE.md` hooks at.
5. Use "Remaining ambiguity" as the focused review punch list.
