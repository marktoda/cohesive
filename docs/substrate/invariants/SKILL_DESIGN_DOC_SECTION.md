# SKILL_DESIGN_DOC_SECTION

> Every directory under `${CLAUDE_PLUGIN_ROOT}/skills/` has a `### <skill-name>` section in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md`. The substrate-first discipline only binds if the design layer exists for every skill; without this invariant, a new skill can be added without a design-layer entry, and the substrate-vs-implementation collapse persists for that skill.

## Rule

For every directory `${CLAUDE_PLUGIN_ROOT}/skills/<name>/`, the file `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md` contains a heading line matching `^### <name>$` (h3, exact directory name). The check is one-direction: every skill directory has a section; sections without corresponding directories are allowed (they may describe planned skills or carry historical entries pending cleanup).

This is one of four named invariants Cohesive ships, alongside `PLUGIN_ROOT_PATHS`, `VERDICT_BEFORE_EVIDENCE`, and `IMPLEMENTATION_PLAN_COVERS_DELTA`. It is graduated to invariant on day one of its existence because the regex is mechanical and the wording is unambiguous; promotion criteria (wording stability, caught regression, worked transcript) per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` §promotion are met by the structural simplicity of the rule rather than by accumulated dogfood evidence.

## Scope

### Applies to
- Every directory under `${CLAUDE_PLUGIN_ROOT}/skills/` (chain skills, off-chain diagnostics, the router).
- The skills.md file at `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md`.

### Does not apply to
- The *content* of the section. `spec-cohesion-reviewer` reads section content during `validate-rewrite` to ensure design-doc and SKILL.md agree on purpose, ownership, and seams (lens 2). This invariant only checks heading presence.
- The *shape* of the six slots (Purpose / Owns / Does not own / Inputs / Outputs / Why this shape). `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` governs section shape; this invariant only checks the heading line.
- Sections in skills.md without corresponding skill directories. The check is one-direction; planned-but-not-yet-implemented skills can have sections without violating this rule.

## Why this matters

The substrate-first discipline depends on the design layer existing for every skill. When a contributor adds a new skill at `skills/<name>/SKILL.md`, the SKILL.md body absorbs design pressure by default — which is exactly the substrate-implementation collapse the architecture refactor exists to prevent. Without a structural fence, the discipline stays aspirational.

This invariant fences the *presence* of the design-layer entry. The reviewer (`spec-cohesion-reviewer` lens 2) fences *content alignment* between the entry and the SKILL.md. Together they make the design layer load-bearing; either alone leaves a gap.

The graduation criterion that makes this rule a v0.1 invariant rather than a convention: the failure mode (skill added without section) is binary, mechanically observable, and produces concrete substrate breakage (every brainstorm targeting that skill must edit SKILL.md by default — the original collapse, restored). Convention status would let the failure persist silently across release cycles.

## Enforcement

**Check 15** in `scripts/validate_plugin.sh` enforces this invariant. The check sits after Check 14 (`PLUGIN_ROOT_PATHS`); CI blocks merge on a missing section.

This invariant is part of a two-fence model with `spec-cohesion-reviewer` lens 13. The fences own different concerns:

| Fence | Owns | Triggered by | Site |
|---|---|---|---|
| Presence (this invariant) | "every skill dir has a `### <name>` section in skills.md" | every CI run on every push/PR | `scripts/validate_plugin.sh` Check 15 |
| Content alignment (lens 13 in `spec-cohesion-reviewer`) | "design-doc and SKILL.md agree on Purpose / Owns / Inputs / Outputs / verdict vocabulary" | `cohesive:validate-rewrite` dispatches with classification Design or Mixed | `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md` lens 13 |
| Section shape (governed by `skill-shape.md` §"Per-skill section shape") | "the six-slot shape is honored: Purpose / Owns / Does not own / Inputs / Outputs / Why this shape" | reviewer judgment during `cohesive:review-codebase` / `cohesive:review-diff` | reviewer-judged convention; no mechanical fence |

Each fence states what it does *not* check via this table; a future contributor adding a sibling check picks the row whose concern matches and adds enforcement on that surface.

The bash check shape:

```bash
# 15. SKILL_DESIGN_DOC_SECTION: every directory under skills/ has a `### <name>`
# section in docs/substrate/architecture/skills.md. Per
# docs/substrate/invariants/SKILL_DESIGN_DOC_SECTION.md.
SKILLS_DOC="docs/substrate/architecture/skills.md"
[ -f "$SKILLS_DOC" ] || { fail "$SKILLS_DOC missing (per SKILL_DESIGN_DOC_SECTION)"; }
for skill_dir in skills/*/; do
  skill_name=$(basename "$skill_dir")
  grep -q "^### ${skill_name}$" "$SKILLS_DOC" \
    || fail "skills/${skill_name}/ has no '### ${skill_name}' section in $SKILLS_DOC (per SKILL_DESIGN_DOC_SECTION)"
done
```

The validator runs locally and in CI on push/PR via `.github/workflows/validate.yml`. A red check blocks merge.

## Known bypass risks

- **Section nesting changes.** If a future revision of skills.md groups skills under h3 banners (e.g., `### Chain skills` / `#### discover-substrate`), the regex breaks. Mitigation: skills.md §"Section growth policy" documents the per-section anchor as the regex target; any restructuring updates the validator regex in the same pass.
- **Section-with-no-skill-dir.** A section for a planned skill exists in skills.md but the directory hasn't been created. The check is one-direction; this is allowed. Spec-cohesion-reviewer flags during validate-rewrite if a planned section drifts beyond what's reasonable.
- **Skill renamed without section rename.** Renaming `skills/foo/` to `skills/bar/` requires also renaming the section heading. The validator catches this on the next CI run; the rename pass must update both surfaces.
- **First per-skill extraction silently breaks Check 15.** When a per-skill section grows past ~80 lines and earns its own file at `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills/<name>.md` (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md` §"Section growth policy"), the regex target shifts from `^### <name>$` in `skills.md` to file existence at the extracted path. The current Check 15 hardcodes `skills.md`; the first extraction breaks the validator until the regex is updated. Mitigation: the first-extraction checklist row below pairs the migration with a validator update in the same commit.
- **Bootstrap-inherited section drift.** Sections marked `inherited` in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md` §"Bootstrap status" were authored retroactively against existing SKILL.md bodies; lens 13 (design-implementation agreement) and lens 14 (handoff contract consistency) may surface drift on the first forward rewrite that touches them. This is predicted bootstrap drift, not a defect of the inherited section. Mitigation: `spec-cohesion-reviewer` reads the bootstrap-status table during dispatch and applies extra skepticism to inherited-status sections; sections earn validated status when a forward `cohesive:rewrite-specs` pass uses the design layer as prior substrate.

## Review checklist

When adding or renaming a skill:

- [ ] Does the new/renamed skill directory have a matching `### <name>` section in skills.md?
- [ ] Does the section follow the canonical six-slot shape (Purpose / Owns / Does not own / Inputs / Outputs / Why this shape)?
- [ ] Is the at-a-glance table at the top of skills.md updated with a row for the new/renamed skill?
- [ ] Are inbound and outbound handoffs added to `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` (if chain or re-entry)?
- [ ] If router-dispatchable, is a cell added to `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md`?
- [ ] Is the §"Bootstrap status" table in `skills.md` updated with the new section (status: `inherited` until the first forward rewrite validates it)?
- [ ] Does `bash scripts/validate_plugin.sh` pass?

When extracting a section to its own file (per `skills.md` §"Section growth policy"):

- [ ] Does `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills/<name>.md` exist with the extracted content?
- [ ] Is the parent section in `skills.md` replaced with a one-paragraph stub linking out?
- [ ] Is `scripts/validate_plugin.sh` Check 15 updated so the regex accepts either `^### <name>$` in `skills.md` *or* file existence at `architecture/skills/<name>.md`?
- [ ] Does `bash scripts/validate_plugin.sh` pass after the extraction?

## Related

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md` — the per-skill design layer this invariant pins.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` — the chain-transition contracts that the per-skill sections describe at endpoints.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"When to edit SKILL.md alone, and when to edit the design layer first" — the convention this invariant enforces structurally.
- `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md` lens 2 — the content-alignment fence that complements this presence-fence.

## History

- 2026-05-05 — Created during the architecture refactor (see `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-05-architecture-refactor.md`). Graduated to invariant on day one because the regex is mechanical and the failure mode is binary; promotion criteria met by structural simplicity rather than accumulated dogfood evidence.
- 2026-05-05 — `implement-cohesively` Phase 1 landed Check 15 in `scripts/validate_plugin.sh` (commit `6cdae42`). The §"Enforcement" section's "claim-before-implementation" caveat is retired; the check is now structurally enforced via CI. This pattern (invariant doc claims enforcement before the check ships) is documented as a scar in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/invariant-claimed-before-enforced.md`.
- 2026-05-05 — Architecture refactor review-diff repair pass: added the two-fence model table to §"Enforcement" naming the boundary between this invariant (presence) and `spec-cohesion-reviewer` lens 13 (content alignment); added the first-per-skill-extraction bypass risk and matching review-checklist rows; added the bootstrap-inherited section drift bypass risk; cited the §"Bootstrap status" table in skills.md.
