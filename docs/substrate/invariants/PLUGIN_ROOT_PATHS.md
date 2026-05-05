# PLUGIN_ROOT_PATHS

> Every internal path reference in a Cohesive component uses `${CLAUDE_PLUGIN_ROOT}/<path>`. Hardcoded absolute paths break the plugin for every user who isn't the original author.

## Rule

Every reference to a file inside this plugin (skill, agent, reference, template, script) — whether in a SKILL.md body, an agent system prompt, a script, or a generated artifact — uses the `${CLAUDE_PLUGIN_ROOT}/` prefix. Hardcoded paths like `/home/<user>/...`, `~/...`, or bare relative paths to plugin-internal files are forbidden.

This is one of two named invariants Cohesive ships at v0.1, alongside [`VERDICT_BEFORE_EVIDENCE`](VERDICT_BEFORE_EVIDENCE.md) (every verdict-led skill leads its Output format block with `**Verdict:**`). Other v0.1 rules (chat-render header-depth cap, density budgets, forbidden phrasings, voice-citation pin, fresh-eyes preamble, router announcement form, clarifying-question discipline) live as conventions in [`docs/substrate/designs/skill-conventions.md`](../designs/skill-conventions.md), [`docs/substrate/designs/reviewer-agent-template.md`](../designs/reviewer-agent-template.md), and [`references/output-voice.md`](../../../references/output-voice.md). Conventions earn invariant status only when their wording has settled *and* their failure modes are concrete enough to grep for — both bars matter.

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

`scripts/validate_plugin.sh` greps `skills/`, `agents/`, and `references/` for hardcoded path patterns (`/home/`, `/Users/`, `/usr/local/`, `~/`) outside fenced code blocks and explicit anti-pattern lines. A violation is a hard fail; the failure message names this invariant by name. The grep is check 13 in the validator.

### Convention pins enforced alongside this invariant (canonical list)

`validate_plugin.sh` runs convention-layer greps that pin related rules. This is the canonical enumeration — AGENTS.md and `docs/substrate/designs/skill-conventions.md` link here rather than restating, so the three docs cannot drift.

**Currently enforced (v0.1):**

1. **Canonical prereq-detection question** in subskill bodies (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`). The forced-choice question prevents soft-prereqs degradation. Validator check 10.
2. **Fresh-eyes preamble bullet** in every `agents/*.md` file (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/designs/reviewer-agent-template.md` §"The fresh-eyes preamble"). Validator check 11.
3. **"Recommended next Cohesive skill" footer** in every persisting skill body. Validator check 12.
4. **Negative-trigger check** on skill descriptions (`description` frontmatter must not contain forbidden trigger phrases). Validator check 9b.
5. **Verdict-leads check** for verdict-led skills (per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/invariants/VERDICT_BEFORE_EVIDENCE.md`). Validator check 13a. This is the surface-level enforcement of the second named invariant.
6. **Voice-citation check** in every `skills/*/SKILL.md` Output format block (validator check 13b) and every `agents/*.md` first code block (validator check 13c), per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/style-guide-rot.md`. Convention-with-grep status, not invariant. **Exemption:** `skills/cohesively/SKILL.md` is exempt — its render budget is 1–2 sentences with no `#` title (per `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Density budgets" and the SKILL.md §"Output"); the grep skips it.

None of the convention pins above (1–4, 6) are named invariants — they remain conventions. They share the same enforcement surface (`validate_plugin.sh`) as the two named invariants (this one, and `VERDICT_BEFORE_EVIDENCE`).

**Shared ownership:** pins 5 and 6 are the surface-level enforcement of `VERDICT_BEFORE_EVIDENCE` (verdict-leads grep) and the voice-citation convention (the literal-citation grep) respectively. If `VERDICT_BEFORE_EVIDENCE`'s scope changes (e.g. a new verdict-led skill is added or removed), update its own §"Enforcement" *and* this canonical list together — both docs describe the same grep but from different angles, and drift between them is a substrate failure.

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

- [`docs/substrate/designs/skill-conventions.md`](../designs/skill-conventions.md) — where the demoted v0.1 conventions live (skill output shape, clarifying questions, router announcement form).
- [`docs/substrate/designs/reviewer-agent-template.md`](../designs/reviewer-agent-template.md) — where the fresh-eyes-preamble convention lives.

## History

- 2026-05-04 — Created from plan §3 prose during the Phase 1 substrate pass.
- 2026-05-04 — Substrate collapse: the four other v0.1 invariants demoted to conventions; this rule kept because it is the one with a real runtime failure mode. Doc simplified: dropped the elaborate Tests/Types/Constraints/Semantic-linters/Runtime-wrappers/CI-checks enforcement schema in favor of a single-paragraph statement of what's actually enforced.
- 2026-05-04 — `cut-anchor-pin` rewrite (repair pass 1): updated to reflect that v0.1 now ships two named invariants (this one plus `VERDICT_BEFORE_EVIDENCE`). The substrate-collapse-era prose claiming "the one named invariant" was contradicting the new substrate.
