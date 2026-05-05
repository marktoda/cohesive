# PLUGIN_ROOT_PATHS

> Every internal path reference in a Cohesive component uses `${CLAUDE_PLUGIN_ROOT}/<path>`. Hardcoded absolute paths break the plugin for every user who isn't the original author.

## Rule

Every reference to a file inside this plugin (skill, agent, reference, template, script) — whether in a SKILL.md body, an agent system prompt, a script, or a generated artifact — uses the `${CLAUDE_PLUGIN_ROOT}/` prefix. Hardcoded paths like `/home/<user>/...`, `~/...`, or bare relative paths to plugin-internal files are forbidden.

This is one of four named invariants Cohesive ships at v0.1, alongside [`VERDICT_BEFORE_EVIDENCE`](VERDICT_BEFORE_EVIDENCE.md) (every verdict-led skill leads its Output format block with `**Verdict:**`), [`IMPLEMENTATION_PLAN_COVERS_DELTA`](IMPLEMENTATION_PLAN_COVERS_DELTA.md) (every delta-ledger entry maps to ≥1 phase in the implementation pass), and [`SKILL_DESIGN_DOC_SECTION`](SKILL_DESIGN_DOC_SECTION.md) (every directory under `skills/` has a `### <name>` section in `architecture/skills.md`). Other v0.1 rules (chat-render header-depth cap, density budgets, forbidden phrasings, voice-imperative pin (body prose), anti-citation lint (render templates), fresh-eyes preamble, router announcement form, clarifying-question discipline) live as conventions in [`docs/substrate/conventions/skill-shape.md`](../conventions/skill-shape.md), [`docs/substrate/conventions/reviewer-agent-shape.md`](../conventions/reviewer-agent-shape.md), and [`references/output-voice.md`](../../../references/output-voice.md). Conventions earn invariant status only when their wording has settled *and* their failure modes are concrete enough to grep for — both bars matter.

## Scope

### Applies to
- `skills/<name>/SKILL.md` bodies
- `agents/<name>.md` system prompts
- `references/**/*.md` cross-references
- `scripts/*.sh` and `scripts/*.py` referencing plugin-internal files
- Output formats specified by skills, when those outputs reference plugin-internal files
- Examples and code blocks within any of the above

### Does not apply to
- Paths in the *user's* repo (the codebase Cohesive runs against). User-repo paths are user-relative.
- Plugin manifests (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`).
- Documentation that intentionally illustrates a hardcoded path as an anti-example, inside an explicit "Anti-patterns" / "Don't do this" block.

## Why this matters

The plugin installs at a path that varies by user (`~/.claude/plugins/cohesive`, `/usr/local/share/claude/plugins/cohesive`, a development worktree, etc.). Hardcoded paths break for every user who isn't the original author. `${CLAUDE_PLUGIN_ROOT}` is the harness-provided portable root.

This is a real correctness contract. Unlike v0.1's other rules (output-shape, prose conventions), a violation produces a runtime failure for end users, not just substrate drift. That's why this one survives the substrate collapse as a named invariant.

## Enforcement

`scripts/validate_plugin.sh` greps `skills/`, `agents/`, and `references/` for hardcoded path patterns (`/home/`, `/Users/`, `/usr/local/`, `~/`) outside fenced code blocks and explicit anti-pattern lines. A violation is a hard fail; the failure message names this invariant by name. The grep is Check 14 in the validator.

### Convention pins enforced alongside this invariant (canonical list)

`validate_plugin.sh` runs convention-layer greps that pin related rules. This is the canonical enumeration — AGENTS.md and `docs/substrate/conventions/skill-shape.md` link here rather than restating, so the three docs cannot drift.

**Currently enforced (v0.1):**

1. **Canonical prereq-detection question** in subskill bodies (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`). The forced-choice question prevents soft-prereqs degradation. Validator check 10.
2. **Fresh-eyes preamble bullet** in every `agents/*.md` file (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` §"The fresh-eyes preamble"). Validator check 11.
3. **"Recommended next Cohesive skill" footer** in every persisting skill body. Validator check 12.
4. **Negative-trigger check** on skill descriptions (`description` frontmatter must not contain forbidden trigger phrases). Validator check 9b.
5. **Verdict-leads check** for verdict-led skills (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`). Validator check 13a. This is the surface-level enforcement of the second named invariant.
6. **Voice-imperative check** in every non-router `skills/*/SKILL.md` body (validator check 13b) and every `agents/*-reviewer.md` body (validator check 13c), per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md`. The check greps body prose (outside fenced code blocks) for the literal `Read ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md before rendering chat output.`. Convention-with-grep status, not invariant. **Exemption:** `skills/cohesively/SKILL.md` is exempt — its render budget is 1–2 sentences and its dispatched subskills carry the voice load; the grep skips it.
7. **Anti-citation check on render templates** in every non-router `skills/*/SKILL.md` Output format code block and every `agents/*-reviewer.md` "How to structure your output" code block (validator check 13d). The check greps inside the code block for *absence* of the literal `> Voice and density: ${CLAUDE_PLUGIN_ROOT}/references/output-voice.md`. Citation literals in render templates leak verbatim into user-facing output — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` §"Correct pattern". Convention-with-grep status; pairs with check 13b/13c to catch half-migrations (imperative-added-but-citation-not-removed or vice versa).
8. **Delta-at-a-glance preamble check** in every `docs/history/delta-ledgers/*.md` file dated on or after the cutoff (validator check 13h). The check greps each ledger filename for a `YYYY-MM-DD` prefix, grandfathers ledgers dated before the cutoff (`2026-05-05`, encoded as a constant in `validate_plugin.sh`), and asserts that every remaining ledger contains the literal `## Delta at a glance` heading. The canonical contract for the preamble's category list, authoring rules, and consumer rendering rules lives at `${CLAUDE_PLUGIN_ROOT}/references/templates/design-delta-ledger.md` §"Delta at a glance"; the grep is the presence half of a two-fence model whose accuracy half is the per-dispatch reviewer judgment in `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md` "What you check" item 11. The check also emits a **warn-level malformed-filename signal** as an adjacent (not load-bearing) surface — when a ledger filename lacks the `YYYY-MM-DD` prefix per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/substrate-layout.md` §Naming, the check warns and increments a malformed counter without failing. Promotion path: warn → fail when a dedicated filename-validation check ships under `substrate-layout.md` §Naming enforcement. Convention-with-grep status; promotion of the preamble check itself to named invariant follows the criteria in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md` §promotion (two release cycles + caught regression + captured-not-authored worked transcript). The cutoff-date pattern is itself new in v0.1; a second cutoff-scoped check would warrant a `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Cutoff-date checks" entry covering when to advance.

None of the convention pins above (1–4, 6, 7, 8) are named invariants — they remain conventions. They share the same enforcement surface (`validate_plugin.sh`) as the four named invariants: this one (Check 14), `VERDICT_BEFORE_EVIDENCE` (Check 13a), `SKILL_DESIGN_DOC_SECTION` (Check 15), and `IMPLEMENTATION_PLAN_COVERS_DELTA` (no validator check; enforced by `implement-cohesively` acceptance criteria + `delta-coverage-reviewer` verdict).

**Shared ownership:** pin 5 is the surface-level enforcement of `VERDICT_BEFORE_EVIDENCE` (verdict-leads grep). Pins 6 and 7 enforce the voice-imperative convention (imperative-in-body grep + anti-citation-in-template grep). If `VERDICT_BEFORE_EVIDENCE`'s scope changes (e.g. a new verdict-led skill is added or removed), update its own §"Enforcement" *and* this canonical list together — both docs describe the same grep but from different angles, and drift between them is a substrate failure. The same coupling holds for the voice-imperative convention: the imperative literal (pin 6) and the citation literal it replaces in render templates (pin 7) are two halves of one rule.

The validator runs locally and in CI on push/PR via `.github/workflows/validate.yml`. A red check blocks merge.

## Known bypass risks

- **Anti-example blocks.** A line showing a hardcoded path as the wrong way to do it could trip a naive grep. The validator scopes the check to non-anti-pattern contexts (skips lines inside fenced "Don't do this" blocks).
- **User-repo paths in skill output schemas.** A skill describing where to write *its* output (e.g., `docs/history/reviews/...`) is referencing a user-repo path, not a plugin-internal one. The validator distinguishes.
- **`${CLAUDE_PLUGIN_ROOT}` interpolated then concatenated.** Theoretically obscures the rule; in practice v0.1 components are pure Markdown, so this isn't a live risk.

## Review checklist

When reviewing a change to any Cohesive-internal file:

- [ ] Every new path reference begins with `${CLAUDE_PLUGIN_ROOT}/`?
- [ ] Any line containing `/home/`, `/Users/`, `/usr/`, or `~/` is inside an explicitly-marked anti-example block?
- [ ] If the change moves a file, every reference to its old path has been updated?
- [ ] `bash scripts/validate_plugin.sh` passes?

## Related

- [`docs/substrate/conventions/skill-shape.md`](../conventions/skill-shape.md) — where the demoted v0.1 conventions live (skill output shape, clarifying questions, router announcement form).
- [`docs/substrate/conventions/reviewer-agent-shape.md`](../conventions/reviewer-agent-shape.md) — where the fresh-eyes-preamble convention lives.

## History

- 2026-05-04 — Created from plan §3 prose during the Phase 1 substrate pass.
- 2026-05-04 — Substrate collapse: the four other v0.1 invariants demoted to conventions; this rule kept because it is the one with a real runtime failure mode. Doc simplified: dropped the elaborate Tests/Types/Constraints/Semantic-linters/Runtime-wrappers/CI-checks enforcement schema in favor of a single-paragraph statement of what's actually enforced.
- 2026-05-04 — `cut-anchor-pin` rewrite (repair pass 1): updated to reflect that v0.1 now ships two named invariants (this one plus `VERDICT_BEFORE_EVIDENCE`). The substrate-collapse-era prose claiming "the one named invariant" was contradicting the new substrate.
- 2026-05-04 — Voice-imperative pivot: pin #6 retargeted from "voice-citation in render template" to "voice-imperative in body prose"; new pin #7 added for "anti-citation in render template" (the inverse check that catches half-migrations). Shared-ownership paragraph extended to cover the imperative/anti-citation pair as two halves of one rule. See `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-04-voice-citation-imperative.md`.
- 2026-05-05 — Architecture refactor (repair pass 1): updated to reflect that v0.1 now ships four named invariants (this one plus `VERDICT_BEFORE_EVIDENCE`, `IMPLEMENTATION_PLAN_COVERS_DELTA`, `SKILL_DESIGN_DOC_SECTION`). Concrete validator ordinals reserved alongside (this one Check 14; `VERDICT_BEFORE_EVIDENCE` Check 13a; `SKILL_DESIGN_DOC_SECTION` Check 15). See `${CLAUDE_PLUGIN_ROOT}/docs/history/delta-ledgers/2026-05-05-architecture-refactor.md`.
