# PLUGIN_ROOT_PATHS

> Every internal path reference in a Cohesive component uses `${CLAUDE_PLUGIN_ROOT}/<path>`. No hardcoded absolute paths, ever.

## Rule

Every reference to another file inside this plugin (skill, agent, reference, template, script) — whether in a SKILL.md body, an agent system prompt, a script, or a generated artifact — uses the `${CLAUDE_PLUGIN_ROOT}/` prefix. Hardcoded paths like `/home/<user>/...`, `~/...`, or bare relative paths to plugin-internal files are forbidden.

## Scope

### Applies to
- All `skills/<name>/SKILL.md` bodies
- All `agents/<name>.md` system prompts
- All `references/**/*.md` cross-references
- All `scripts/*.sh` and `scripts/*.py` that reference plugin-internal files
- All output formats specified by skills (when those outputs reference plugin-internal files)
- All examples and code blocks within the above

### Does not apply to
- References to files in the *user's* repo (the codebase Cohesive is being run against). User-repo paths are user-relative and should remain so.
- The plugin manifest (`.claude-plugin/plugin.json`, `.claude-plugin/marketplace.json`) — these declare metadata, not file references.
- Documentation that intentionally illustrates a hardcoded path as an anti-example (always inside an "Anti-patterns" or "Don't do this" block).

## Why this matters

The plugin is installed by absolute path that varies by user (`~/.claude/plugins/cohesive`, `/usr/local/share/claude/plugins/cohesive`, a development worktree under `/home/toda/dev/cohesive`, etc.). Hardcoded paths break for every user who isn't the original author. `${CLAUDE_PLUGIN_ROOT}` is the harness-provided portable root.

This is also load-bearing for substrate discipline: Cohesive's own self-review (`cohesive-review --scope codebase`) flagged `validate_plugin.sh` for *rewarding* non-compliant `references/...` paths in its grep at line 107. An invariant whose violation the validator silently accepts is no invariant at all.

## Where this rule must hold

Every Cohesive-internal file that references another Cohesive-internal file:

- **Skills:** when a skill body cites a reference, template, agent, or script.
- **Agents:** when an agent prompt cites a reference, another agent, or a script.
- **References:** when one reference cites another, or cites a skill body, template, or script.
- **Scripts:** when a script reads or scans a plugin-internal file.
- **Generated outputs:** when a skill's output schema includes paths to plugin-internal files (e.g., the design delta ledger pointing at `${CLAUDE_PLUGIN_ROOT}/references/templates/design-delta-ledger.md`).

## Enforcement

- **Tests:** none yet (V1 will add).
- **Types:** N/A (Markdown + Bash + Python; no type system to use).
- **Constraints:** N/A.
- **Semantic linters:** `scripts/validate_plugin.sh` runs a grep over `skills/`, `agents/`, `references/` for absolute path patterns (`/home/`, `/Users/`, `/usr/`, `~/`) outside fenced "anti-pattern" blocks. Failure is a hard fail.
- **Runtime wrappers:** N/A.
- **CI checks:** when `.github/workflows/validate.yml` lands, `validate_plugin.sh` runs on every PR.

The grep-style semantic linter is the load-bearing enforcement. Without it, the rule degrades to reviewer memory.

## Known bypass risks

- **Anti-example blocks.** An "Anti-patterns" table that shows a hardcoded path as the wrong way to do it could be flagged by a naive grep. The linter must scope the check to *non-anti-pattern* contexts (e.g., skip lines inside fenced "Don't do this" blocks).
- **User-repo paths in skill output schemas.** A skill describing where to write *its* output (e.g., `docs/history/reviews/...`) is referencing a user-repo path, not a plugin-internal one. The linter must distinguish.
- **`${CLAUDE_PLUGIN_ROOT}` interpolated into a string then concatenated.** A skill body that builds a path through string concatenation could obscure the rule. Discourage in code review; in v0.1 skills are pure Markdown so this is theoretical.

## Review checklist

When reviewing a change to any Cohesive-internal file:

- [ ] Every new path reference begins with `${CLAUDE_PLUGIN_ROOT}/`?
- [ ] Any line containing `/home/`, `/Users/`, `/usr/`, or `~/` is inside an explicitly-marked anti-example block?
- [ ] If the change moves a file, every reference to its old path has been updated?
- [ ] `bash scripts/validate_plugin.sh` passes?

## Related

- **Plan §3** locked this rule first ("All internal paths: `${CLAUDE_PLUGIN_ROOT}`. No hardcoded paths.")
- **Self-review finding 1** (`docs/history/reviews/2026-05-04-self-review.md`) named the gap: rule existed in prose, not in a check.
- **Convention reference** `${CLAUDE_PLUGIN_ROOT}/references/skill-conventions.md` enforces this for new skills.

## History

- 2026-05-04 — Created. Promoted from plan §3 prose to a named invariant. Enforcement currently aspirational; semantic linter to be added in the same Phase 1 substrate pass.
