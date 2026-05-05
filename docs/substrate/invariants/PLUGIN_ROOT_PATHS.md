# PLUGIN_ROOT_PATHS

> Every internal path reference in a Cohesive component uses `${CLAUDE_PLUGIN_ROOT}/<path>`. Hardcoded absolute paths break the plugin for every user who isn't the original author.

## Rule

Every reference to a file inside this plugin (skill, agent, reference, template, script) — whether in a SKILL.md body, an agent system prompt, a script, or a generated artifact — uses the `${CLAUDE_PLUGIN_ROOT}/` prefix. Hardcoded paths like `/home/<user>/...`, `~/...`, or bare relative paths to plugin-internal files are forbidden.

This is the one named invariant Cohesive ships at v0.1. Other v0.1 rules (skill-output shape, fresh-eyes preamble, router announcement form, clarifying-question discipline) live as conventions in [`references/skill-conventions.md`](../../../references/skill-conventions.md) and [`references/reviewer-agent-template.md`](../../../references/reviewer-agent-template.md). They earn invariant status only when their wording has settled and their failure modes are concrete enough to grep for.

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

The validator also runs the convention-layer greps that pin related rules: canonical prereq-detection question in subskill bodies, fresh-eyes preamble bullet in reviewer agent files, "Recommended next Cohesive skill" footer in every persisting skill body, and a negative-trigger check on skill descriptions. None of those rules are named invariants — they remain conventions. They are mentioned here only because they share the same enforcement surface.

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

- [`references/skill-conventions.md`](../../../references/skill-conventions.md) — where the demoted v0.1 conventions live (skill output shape, clarifying questions, router announcement form).
- [`references/reviewer-agent-template.md`](../../../references/reviewer-agent-template.md) — where the fresh-eyes-preamble convention lives.

## History

- 2026-05-04 — Created from plan §3 prose during the Phase 1 substrate pass.
- 2026-05-04 — Substrate collapse: the four other v0.1 invariants demoted to conventions; this rule kept because it is the one with a real runtime failure mode. Doc simplified: dropped the elaborate Tests/Types/Constraints/Semantic-linters/Runtime-wrappers/CI-checks enforcement schema in favor of a single-paragraph statement of what's actually enforced.
