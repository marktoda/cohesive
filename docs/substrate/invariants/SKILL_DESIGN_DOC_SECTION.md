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

Reserved ordinal: **Check 15** in `scripts/validate_plugin.sh` (slot reserved during the architecture refactor; sits after Check 14 `PLUGIN_ROOT_PATHS`). Implementation lands during `implement-cohesively`; this invariant is graduated on day one because the regex is mechanical and the failure mode binary, but the bash check itself is not yet in `validate_plugin.sh` as of the architecture refactor commit. Until the check is implemented, the invariant is asserted by structural-fence claim plus reviewer judgment in `cohesive:review-codebase` and `cohesive:review-diff`; once implemented, the check enforces presence mechanically and CI blocks merge.

The check shape:

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

## Review checklist

When adding or renaming a skill:

- [ ] Does the new/renamed skill directory have a matching `### <name>` section in skills.md?
- [ ] Does the section follow the canonical six-slot shape (Purpose / Owns / Does not own / Inputs / Outputs / Why this shape)?
- [ ] Is the at-a-glance table at the top of skills.md updated with a row for the new/renamed skill?
- [ ] Are inbound and outbound handoffs added to `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` (if chain or re-entry)?
- [ ] If router-dispatchable, is a cell added to `${CLAUDE_PLUGIN_ROOT}/docs/substrate/matrices/router.md`?
- [ ] Does `bash scripts/validate_plugin.sh` pass?

## Related

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/skills.md` — the per-skill design layer this invariant pins.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` — the chain-transition contracts that the per-skill sections describe at endpoints.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"When to edit SKILL.md alone, and when to edit the design layer first" — the convention this invariant enforces structurally.
- `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md` lens 2 — the content-alignment fence that complements this presence-fence.

## History

- 2026-05-05 — Created during the architecture refactor (see `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-05-architecture-refactor.md`). Graduated to invariant on day one because the regex is mechanical and the failure mode is binary; promotion criteria met by structural simplicity rather than accumulated dogfood evidence.
