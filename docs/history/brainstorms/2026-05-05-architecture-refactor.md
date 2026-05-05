# Brainstorm — substrate architecture refactor: adding a design layer above skills

**Date:** 2026-05-05
**Status:** Approved — proceed to `rewrite-specs`
**Approved direction:** Option A (Architecture/Conventions split + consolidated skills.md and handoffs.md + Move D binding)
**Predecessor:** Substrate discovery report (inline, conversation-only — captured in this brainstorm's "Substrate touched" appendix)

## Problem statement

Running Cohesive against Cohesive surfaces a structural failure: the brainstorm and rewrite-specs phases keep collapsing into SKILL.md edits because there is no design-layer artifact above the skill body. When the user proposes a change to a skill's purpose, ownership, or seams, the highest-altitude artifact available is the SKILL.md frontmatter description plus the "What this skill produces" / "What this skill is *not*" sections — and rewrite-specs has nowhere to land design pressure except in the SKILL.md body itself. The result is that substrate-first discipline silently inverts: design intent is captured by editing the implementation prompt rather than the design above it.

The user's claim, accepted as the premise of this brainstorm: when the substrate above implementation does not exist for a given concern, brainstorming about that concern *cannot* be substrate-first regardless of skill discipline. The fix is to author the missing substrate, not to demand more discipline from the workflow that lacks an artifact to edit.

The current `docs/substrate/designs/` directory exists but mixes two altitudes — architecture-shape decisions (three-tier separation, Cohesive↔Superpowers composition, fresh-eyes review property) and convention-shape rules (skill-shape, reviewer-agent shape, dispatch-prompt template, substrate-layout naming). Conflating them puts ~500 lines of prescriptive convention rules adjacent to ~270 lines of architectural reasoning, and neither set serves the missing per-skill design layer.

## Current scope

- Split `docs/substrate/designs/` into `docs/substrate/architecture/` (read when changing the system shape) and `docs/substrate/conventions/` (read when authoring a component).
- Author `docs/substrate/architecture/skills.md` — the skill set as a system (per-skill sections + at-a-glance table + "why these skills, not others" cuts).
- Author `docs/substrate/architecture/handoffs.md` — chain transitions and off-chain re-entry edges, with per-handoff contracts.
- Split `agent-dispatch-protocol.md` into `architecture/fresh-eyes-review.md` (the property) and `conventions/dispatch-protocol.md` (the template).
- Bind the new layer structurally (Move D): a `SKILL_DESIGN_DOC_SECTION` named invariant; `spec-cohesion-reviewer` expansion (substrate-first compliance + design-implementation agreement + handoff contract consistency); `conventions/skill-shape.md` "when-to-edit-which-layer" rule; `rewrite-specs/SKILL.md` Step 1a classification; ARCHITECTURE.md §"Where to look first" rethink-first row ordering.

## Future pressure (not current scope)

- A per-skill section that grows past ~80 lines is signaling the skill's design has earned its own file; future extraction from `architecture/skills.md` to `architecture/skills/<name>.md` may follow. Don't pre-extract; let the pressure surface.
- An `architecture/substrate.md` (parallel to skills.md) for "what substrate primitives Cohesive ships and why" may emerge when the substrate corpus grows. v0.1's 3 invariants + 5 matrices + 6 gotchas don't justify it yet.
- Promotion of further conventions to named invariants — e.g., the `## Delta at a glance` classification line ("This rewrite is [Pure implementation / Design / Mixed]") could become invariant once the wording stabilizes across several real rewrites.
- Claude Code may eventually add a manifest-level "design doc for this skill" frontmatter field linking each `skills/<name>/` directory to its design-layer section. The new layer migrates cleanly.

## Non-goals

- Not thinning SKILL.md bodies. The alternative refactor — make every skill body shorter so the body itself becomes legible as design — is a different cycle, evaluated as Option B and rejected here.
- Not changing the user-facing skill set, chain shape, or off-chain diagnostics.
- Not changing runtime references (`references/`) or templates (`references/templates/`).
- Not changing the directory names under `skills/`, `agents/`, or any frontmatter `name:` value.
- Not retiring `matrices/router.md` or `architecture/composition-with-superpowers.md`. The new layer cites both rather than absorbing them.

## Design options

### Option A: Architecture/Conventions split + consolidated skills.md and handoffs.md + Move D binding

**Summary:** Three structural moves. (1) Rename `docs/substrate/designs/` content into two destinations — `architecture/` for system-shape docs (three-tier, composition, fresh-eyes property, plus the new skills.md and handoffs.md), `conventions/` for prescriptive component rules (skill-shape, reviewer-agent-shape, dispatch-protocol template, substrate-layout). Split `agent-dispatch-protocol.md` along the property/template seam. (2) Author `skills.md` (per-skill sections in chain order: discover → brainstorm → rewrite → validate → implement → off-chain → router) and `handoffs.md` (per-handoff contracts: artifact, persistence, verdict gate, must-not-re-derive, failure mode). (3) Bind structurally — graduate `SKILL_DESIGN_DOC_SECTION` as a fourth named invariant; expand `spec-cohesion-reviewer` to a three-lens check (substrate-first compliance, design-implementation agreement, handoff contract consistency); add a "when-to-edit-which-layer" rule to `conventions/skill-shape.md`; add a Step 1a classification to `rewrite-specs/SKILL.md`; reorder ARCHITECTURE.md §"Where to look first" so rethink-comes-first.

**Substrate changes required:** Create `docs/substrate/architecture/` and `docs/substrate/conventions/` directories. Author `architecture/skills.md` (~450-550 lines) and `architecture/handoffs.md` (~250-350 lines) from scratch. Move and rename five existing design docs (three-layer-architecture → architecture/three-tier-architecture; composition-with-superpowers → architecture/ unchanged filename; agent-dispatch-protocol split into architecture/fresh-eyes-review + conventions/dispatch-protocol; skill-conventions → conventions/skill-shape; reviewer-agent-template → conventions/reviewer-agent-shape; substrate-layout → conventions/ unchanged filename). Author new `invariants/SKILL_DESIGN_DOC_SECTION.md`. Update ARCHITECTURE.md §"Where to look first" with three new rows (rethink, add-new-skill, modify-body) and shorten §"v0.1 scope" by hooking out skill-set enumeration. Update `conventions/skill-shape.md` (new §"When to edit SKILL.md alone, and when to edit the design layer first" near the top). Update `skills/rewrite-specs/SKILL.md` (new Process Step 1a classification + delta ledger preamble line). Update `agents/spec-cohesion-reviewer.md` (three new lenses + token budget). Add `scripts/validate_plugin.sh` Check N (`SKILL_DESIGN_DOC_SECTION` grep). Update README.md "What's in the box" enumeration. Update AGENTS.md if it cites old paths. Cross-reference updates across all 9 SKILL.md bodies, 6 agent files, 5 matrices, 3 existing invariants, 6 gotchas, the renamed design docs themselves — roughly 30-50 citation edits.

**Locality impact:** Strongly positive. Architecture-altitude reasoning (~5 docs) and convention-altitude rules (~4 docs) separate cleanly. Per-skill design intent consolidates into one doc with stable section anchors rather than scattering across SKILL.md frontmatter, "What this skill produces" sections, router matrix cells, and composition-table rows. Handoff contracts consolidate into one doc with stable per-edge sections rather than living implicitly across rewrite-specs Process step 7, validate-rewrite frontmatter, router matrix dispatch grid, and per-skill "Recommended next Cohesive skill" footers.

**Future fit:** Migrates cleanly to per-skill extraction (when sections grow past ~80 lines) and to manifest-level design-doc linkage (when the platform supports it). The split between architecture and conventions also creates a stable home for future architecture decisions (e.g., long-running daemon agents, web-served skill catalogs — currently flagged as "when to revisit" in three-layer-architecture.md) without further refactor.

**Initial risks:** (1) The new layer becomes aspirational if Move D is incomplete — agents still default to SKILL.md because the path-discovery hooks didn't update or the validator/reviewer don't enforce. (2) The first run of `spec-cohesion-reviewer` with expanded lenses will surface drift between the retroactively-authored design layer and the existing SKILL.md bodies; budget for at least one Issues Found verdict during the validate-rewrite pass on this very refactor. (3) Token cost of the expanded reviewer grows (lens 3's per-handoff three-site read = ~48 read points across all 16 handoffs); reviewer's token discipline section needs an explicit per-lens budget. (4) Filename `three-tier.md` (alternative to keeping `three-layer-architecture.md`) is terse; resolved by using `three-tier-architecture.md` in the rename.

### Option B: Thin SKILL.md bodies so the body itself reads as design

**Summary:** Don't add a new design layer. Instead, sharply reduce the boilerplate every SKILL.md carries (Voice section, Output format render template, full anti-pattern table, frontmatter convention prose) by promoting them into a base template the validator enforces by reference. SKILL.md bodies shrink from ~190 lines average to ~80 lines of pure design and process. Brainstorm pressure naturally lands in the slimmer body because the body is now legible as design.

**Substrate changes required:** Significant `conventions/skill-shape.md` rewrite to define a base template structure. Every SKILL.md edited to remove boilerplate. Validator gains the ability to assert "skill X uses base template version N." No new architecture-altitude docs; the architecture/conventions split may still happen but is decoupled.

**Locality impact:** Mixed. Boilerplate consolidates into one place (the base template) — improvement. But cross-skill questions ("how do these skills compose," "what crosses a chain seam") still have nowhere to live as their own artifact; the answer is implicit across the slim bodies. Workflow-level brainstorm pressure (e.g., "should we add a new chain skill") still has no canonical landing site.

**Future fit:** Doesn't solve the cross-skill design pressure problem. Chain seam questions remain implicit. A future refactor would still need to author skills.md and handoffs.md.

**Initial risks:** Larger blast radius (every SKILL.md edited). Doesn't actually fix the original problem — workflow-level changes still have nowhere to land. Risk of fighting the validator's existing pin enumeration (`PLUGIN_ROOT_PATHS.md` §"Convention pins enforced alongside this invariant"), which currently relies on boilerplate presence.

### Option C: Per-skill design files instead of a consolidated skills.md

**Summary:** Same as Option A but with `docs/substrate/architecture/skills/<name>.md` (one file per user-facing skill, ~9 files of ~80 lines each) instead of a consolidated `skills.md` with per-section anchors. Otherwise identical (architecture/conventions split, handoffs.md, Move D binding).

**Substrate changes required:** Same as A but ~9 separate files instead of one. Validator regex grep changes from `^### <skill_name>$` in skills.md to file existence at `architecture/skills/<skill_name>.md`.

**Locality impact:** Negative on the as-a-system view. Per-file design forces the reader to open 9 files to see the skill set as a whole. The chain-order teaching that consolidated skills.md provides is lost. Drift surface is higher (9 files to keep aligned vs 9 sections in one file).

**Future fit:** Migrates *back* to consolidation cleanly if the per-file shape is rejected later, but the migration is unnecessary — A already accommodates extraction when a section earns it.

**Initial risks:** Encourages each skill's design to drift independently rather than evolving with the set. Higher coordination cost when changes touch multiple skills (a typical chain refactor changes 3-4 of the 9 files vs 3-4 sections in one file).

### Option D: Status quo

**Summary:** Accept the substrate-implementation collapse when running Cohesive against itself. Continue letting brainstorm pressure land in SKILL.md bodies. Document the collapse as a known limitation.

**Substrate changes required:** None.

**Locality impact:** None.

**Future fit:** By definition. Defers the cost.

**Initial risks:** The user has already rejected this — the dogfood pass that surfaced this brainstorm is itself the rejection. Per the v0.1 release-gate self-review, Cohesive's own cohesion review is gated on passing; substrate-implementation collapse is exactly the gap a cohesion review would name. Status quo blocks the v0.1 release gate.

## Pressure test summary

| Option | Cohesion | Substrate delta | Future fit | Locality | Main risk |
|---|---|---|---|---|---|
| A | High | Large (~12 new/moved files + ~30-50 cross-ref edits) | Migrates cleanly to per-skill or manifest-linked | Strongly improves | Move D incompleteness leaves the layer aspirational |
| B | Medium | Large (every SKILL.md edited) | Doesn't solve cross-skill design pressure | Mixed | Doesn't fix original problem |
| C | Medium | Same scope as A but per-file | Encourages independent drift | Worse for as-a-system view | Coordination cost on chain refactors |
| D | Low | None | Trivial | None | Blocks v0.1 release gate |

## Breakage analysis (Option A)

- **Docs that change:** ARCHITECTURE.md (§"Where to look first" reorder + new rows; §"v0.1 scope" prose shortening; multiple cross-ref path updates); README.md ("What's in the box" enumeration); AGENTS.md (path citations if any); all 9 SKILL.md bodies (path citation updates; rewrite-specs/SKILL.md gets a new Step 1a; reviewer-dispatching skills' Voice section unaffected); all 6 agent files (path citation updates; spec-cohesion-reviewer gets new lenses); the 5 matrices (path citation updates); the 3 existing invariants (path citation updates; PLUGIN_ROOT_PATHS may need a new pin if SKILL_DESIGN_DOC_SECTION is graduated alongside); the 6 gotchas (path citation updates); the renamed design docs themselves (cross-ref each other under new paths). New files: `architecture/skills.md`, `architecture/handoffs.md`, `invariants/SKILL_DESIGN_DOC_SECTION.md`. Renamed: 6 files under designs/ (one split into two halves).
- **Existing assumptions that break:** "Design rationale lives in the SKILL.md body" — replaced by "design rationale lives in `architecture/skills.md`; SKILL.md is the implementation prompt." "Adding a skill = creating a SKILL.md and updating ARCHITECTURE.md §v0.1 scope" — replaced by a four-step substrate-first sequence (skills.md → handoffs.md → router.md → SKILL.md). "designs/ is one tier" — replaced by architecture/ + conventions/ separation.
- **Behavior matrix impact:** `matrices/router.md` is unchanged in content but cites new paths (`conventions/skill-shape.md` instead of `designs/skill-conventions.md`). `matrices/phase-derivation.md` may need an additional row for "design-layer change" phase intent (a phase that updates `architecture/skills.md` without writing code). `matrices/skill-section-presence.md` continues to reflect SKILL.md body shape; unaffected. `matrices/reviewer-output-shape.md` unchanged. `matrices/artifact-placement.md` unchanged.
- **Invariant impact:** `PLUGIN_ROOT_PATHS` unchanged in spirit; pin enumeration may add `SKILL_DESIGN_DOC_SECTION` as a sibling. `VERDICT_BEFORE_EVIDENCE` unchanged. `IMPLEMENTATION_PLAN_COVERS_DELTA` unchanged. New: `SKILL_DESIGN_DOC_SECTION` — graduated to invariant on day one because the regex is mechanical and the wording is unambiguous.
- **Test guarantee impact:** Validator gains Check N (`SKILL_DESIGN_DOC_SECTION` grep). Existing checks unaffected. spec-cohesion-reviewer gains three lenses (substrate-first compliance, design-implementation agreement, handoff contract consistency); its token discipline section needs per-lens budgets.
- **Gotchas triggered:** None directly. Indirectly relevant: `style-guide-rot.md` (rules far from generation rot) — same scar pattern; the new layer is the substrate the rule is supposed to live in. `discovery-vs-superpowers.md` unchanged (Cohesive's discovery still substrate-specific). `soft-prereqs.md` unchanged. `no-implementation-handoff.md` cited from new handoffs.md. `skipping-per-phase-plan.md` unchanged. `wordy-output.md` unchanged. New gotcha candidate: "SKILL.md edited as design instead of as implementation" — the failure mode the new layer prevents. May be subsumed by the new `conventions/skill-shape.md` "when-to-edit-which-layer" rule rather than spun out as a gotcha.
- **Locality / centralization concerns:** Option A *improves* locality. Today the per-skill design intent lives across 4-5 places per skill (frontmatter description, "What this skill produces", "What this skill is *not*", router matrix cell, composition table row). After A, it consolidates into one place per skill (a `### <name>` section in skills.md). Today the chain seam contracts live implicitly across rewrite-specs Process step 7, validate-rewrite frontmatter, the router dispatch grid, and per-skill "Recommended next" footers. After A, they consolidate into one place (a per-handoff section in handoffs.md).
- **Easy invalid change still possible:** A new skill added at `skills/foo/` without `### foo` in skills.md — caught by the new `SKILL_DESIGN_DOC_SECTION` validator check. A SKILL.md edited to change purpose without updating skills.md — caught by spec-cohesion-reviewer lens 2. A new chain edge added without a handoff contract — only caught by reviewer judgment (no mechanical check); future tightening could grep handoffs.md for `### <upstream> → <downstream>` per chain edge in skills.md, but v0.1 leaves this convention-with-reviewer.
- **New gotcha candidate:** "Authoring skill design as SKILL.md body content" — the meta-failure-mode the new layer fixes. Likely subsumed by `conventions/skill-shape.md` §"When to edit SKILL.md alone, and when to edit the design layer first" rather than spun out.

## Recommendation

**Direction:** Option A — Architecture/Conventions split + consolidated skills.md and handoffs.md + Move D binding.

**Main risk:** Move D incompleteness. The new layer becomes aspirational if any of the five binding mechanisms (validator check, reviewer expansion, skill-shape rule, rewrite-specs Step 1a, ARCHITECTURE.md row reorder) is incomplete. Without the binding, agents still default to SKILL.md because path-discovery hooks haven't updated, the reviewer doesn't catch drift, and rewrite-specs has no classification step that forces design-layer work first.

**Structural mitigation:** Four convergent fences, each catching a different failure mode. (1) `SKILL_DESIGN_DOC_SECTION` graduated as a named invariant on day one — mechanical grep, CI-enforced, blocks merge if a skill exists without a section. (2) `spec-cohesion-reviewer` three-lens expansion catches design-implementation drift during every `validate-rewrite` pass. (3) `conventions/skill-shape.md` "when-to-edit-which-layer" rule converts the discipline into reviewable convention. (4) `rewrite-specs/SKILL.md` Step 1a classification forces the rewrite to commit to a layer and surface the commitment in the delta ledger preamble. Each fence is reviewer-judged or mechanically enforced; together they make Move D's force structural rather than aspirational. Acid test: a future brainstorm-design pass on a change to `brainstorm-design` itself must edit `architecture/skills.md` (and possibly `architecture/handoffs.md`) before touching `skills/brainstorm-design/SKILL.md`. If the agent still jumps to SKILL.md first, one of the four fences is leaking.

**Required substrate before implementation:**

- **Specs (new):** `architecture/skills.md` (per-skill design layer); `architecture/handoffs.md` (chain transition contracts); `invariants/SKILL_DESIGN_DOC_SECTION.md` (named invariant).
- **Specs (rewritten in place):** `ARCHITECTURE.md` §"Where to look first" (rethink-first row reorder + new rows + path updates); §"v0.1 scope" (skill-set enumeration shortened to hook); `conventions/skill-shape.md` (formerly `designs/skill-conventions.md`; new §"When to edit SKILL.md alone, and when to edit the design layer first"); `skills/rewrite-specs/SKILL.md` (new Process Step 1a classification; delta ledger preamble line); `agents/spec-cohesion-reviewer.md` (three new lenses; token discipline per-lens budget); `README.md` ("What's in the box" enumeration).
- **Specs (renamed/moved):** `designs/skill-conventions.md` → `conventions/skill-shape.md`; `designs/reviewer-agent-template.md` → `conventions/reviewer-agent-shape.md`; `designs/substrate-layout.md` → `conventions/substrate-layout.md`; `designs/three-layer-architecture.md` → `architecture/three-tier-architecture.md`; `designs/composition-with-superpowers.md` → `architecture/composition-with-superpowers.md`; `designs/agent-dispatch-protocol.md` SPLIT → `architecture/fresh-eyes-review.md` (property half) + `conventions/dispatch-protocol.md` (template half).
- **Matrices:** `matrices/phase-derivation.md` may need a new row for design-layer-only phase intent (judgment call; verify during rewrite-specs).
- **Named invariants:** new `SKILL_DESIGN_DOC_SECTION` (graduated to invariant on day one); existing three unchanged in content but path citations update.
- **Tests / checks:** `scripts/validate_plugin.sh` adds Check N (greps `architecture/skills.md` for `^### <skill_name>$` per directory under `skills/`).
- **Gotchas:** none new spun out; the meta-failure-mode is captured by `conventions/skill-shape.md` §"When to edit SKILL.md alone…" instead.
- **Semantic linters (proposed):** Check N (the `SKILL_DESIGN_DOC_SECTION` grep) is the new lint. Future possible lint: grep handoffs.md for per-chain-edge contracts when skills.md adds a chain skill (deferred to v0.2 or later).

## Substrate touched (discovery appendix)

The discovery scan that grounded this brainstorm surfaced the following load-bearing files. `rewrite-specs` will produce per-file edits across:

- `ARCHITECTURE.md` §"Three-tier architecture", §"Composition over reinvention", §"Fresh-eyes review", §"Substrate", §"Conventions", §"Where to look first", §"v0.1 scope" — all touch designs/ paths.
- `README.md` — "What's in the box" enumeration cites designs/ paths.
- `AGENTS.md` — verify path citations if any.
- `docs/substrate/designs/skill-conventions.md` — full file rename + new section.
- `docs/substrate/designs/reviewer-agent-template.md` — rename only.
- `docs/substrate/designs/substrate-layout.md` — rename to conventions/.
- `docs/substrate/designs/three-layer-architecture.md` — rename to architecture/three-tier-architecture.md.
- `docs/substrate/designs/composition-with-superpowers.md` — rename to architecture/.
- `docs/substrate/designs/agent-dispatch-protocol.md` — split along property/template seam.
- `docs/substrate/invariants/PLUGIN_ROOT_PATHS.md` — pin enumeration may add SKILL_DESIGN_DOC_SECTION sibling; path citations update.
- `docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md` — path citations update.
- `docs/substrate/invariants/IMPLEMENTATION_PLAN_COVERS_DELTA.md` — path citations update.
- `docs/substrate/matrices/router.md` — path citations update; verify dispatch-prompt-contract grid still aligns with new handoffs.md section names.
- `docs/substrate/matrices/phase-derivation.md` — may add design-layer-only phase intent row.
- `docs/substrate/matrices/skill-section-presence.md` — path citations update.
- `docs/substrate/matrices/reviewer-output-shape.md` — path citations update.
- `docs/substrate/matrices/artifact-placement.md` — path citations update.
- `docs/substrate/gotchas/{discovery-vs-superpowers,no-implementation-handoff,skipping-per-phase-plan,soft-prereqs,style-guide-rot,wordy-output}.md` — path citations update; no rule-content changes.
- `skills/{cohesively,discover-substrate,brainstorm-design,rewrite-specs,validate-rewrite,implement-cohesively,review-codebase,review-diff,audit-substrate}/SKILL.md` — path citations update; rewrite-specs gains Step 1a; others unchanged in content.
- `agents/{substrate-alignment,structure,library-native,agent-readiness,spec-cohesion,delta-coverage}-reviewer.md` — path citations update; spec-cohesion-reviewer gains three new lenses.
- `scripts/validate_plugin.sh` — new Check N (`SKILL_DESIGN_DOC_SECTION`); path constants update.
- New: `docs/substrate/architecture/skills.md`, `docs/substrate/architecture/handoffs.md`, `docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md`.

### Recommended next Cohesive skill

`cohesive:rewrite-specs` — proceed to spec rewrite in a `design/architecture-refactor` worktree. The rewrite will be classified **Mixed** in its delta ledger preamble: design-layer changes (new architecture/ + conventions/ split, skills.md, handoffs.md, SKILL_DESIGN_DOC_SECTION invariant) and implementation changes (rewrite-specs Step 1a, spec-cohesion-reviewer expansion, validate_plugin.sh Check N, ARCHITECTURE.md and README.md hook updates, all path citations across the corpus). Bootstrap caveat: the first run of rewrite-specs against this brainstorm authors the design layer for the first time, so the substrate-first classification is necessarily Mixed regardless of how the discipline normally bins changes. Subsequent rewrites will use the design layer as the prior substrate.
