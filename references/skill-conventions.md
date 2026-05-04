# Skill conventions

The canonical shape for a Cohesive `SKILL.md`. Read this before adding a new skill or modifying an existing one. The `validate_plugin.sh` semantic linter enforces the structural rules below; the stylistic ones are reviewed in `cohesive-review --scope codebase`.

## Frontmatter

Every `skills/<name>/SKILL.md` opens with YAML frontmatter:

```yaml
---
name: <skill-name>
description: Use when <one-sentence trigger>. <One-sentence what-it-does>. Triggers on "<phrase>", "<phrase>", "<phrase>".
---
```

Rules:

- `name` matches the directory name exactly.
- `description` is one paragraph (typically 2–4 sentences). Third-person. Begins with "Use when". Ends with explicit trigger phrases in quotes.
- No additional frontmatter fields (no `allowed-tools` unless the skill genuinely needs to scope its tool surface).

## Required body sections (in order)

```md
# <Skill name in human form>

## What this skill produces

## Hard constraints
(Numbered list. Each constraint is a one-sentence rule + one-sentence rationale.)

## Process
(Numbered steps. Steps may be subdivided.)

## Output format
(A markdown code block showing the canonical chat output the skill produces.)

## Acceptance criteria
(Bulleted list. Each criterion is testable in principle.)

## What this skill is *not*
(Bulleted list. Names adjacent skills/concepts the skill does not cover.)
```

## Optional sections

Use these when relevant; omit the heading when not:

- **`## Worktree handling`** — only for skills that should run in an isolated worktree (currently `rewrite-specs`).
- **`## Anti-patterns (Red Flags)`** — a markdown table with three columns (Anti-pattern / Why it's wrong / Fix). Use the table form, not a bulleted list.
- **`## Composition`** — names skills that typically run before or after this one, plus Superpowers compositions.
- **`## Routes`** — only for the router (`cohesively`).

## Output format conventions

The "Output format" section shows the canonical chat output the skill produces. It must include a final block named:

```md
### Recommended next Cohesive skill
`cohesive:<skill-name>` — <reason>
```

This footer is enforced by named invariant `SUBSKILL_RECOMMENDS_NEXT`. If the skill has multiple verdict-branches (e.g. `review-spec-cohesion` returns Approved / Issues Found / Design Incoherent), provide one recommended-next per branch.

## Path discipline

Every reference to another skill, agent, reference, template, or script in the body uses `${CLAUDE_PLUGIN_ROOT}/<path>`. Examples:

- `${CLAUDE_PLUGIN_ROOT}/references/templates/invariant.md`
- `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/discover-substrate/SKILL.md`

This is enforced by named invariant `PLUGIN_ROOT_PATHS` and checked by `validate_plugin.sh`.

## Dispatch discipline

Skills that dispatch to reviewer agents via the Task tool must include the canonical fresh-eyes preamble in the dispatch prompt. The preamble is defined in named invariant `FRESH_EYES_DISPATCH` and templated in `${CLAUDE_PLUGIN_ROOT}/references/reviewer-agent-template.md`.

The dispatching skill body must explicitly state, in prose: "The reviewer reads only paths passed to it, not the conversation."

## Clarifying questions

A skill turn asks **at most one** clarifying question. The question is a specific forced choice (e.g., "Should I review the codebase or the diff?"), never a vague open prompt ("What do you want?", "Can you tell me more?"). This is enforced by named invariant `ONE_PRECISE_QUESTION`.

Most skills have a pre-canned clarifying question per route or per ambiguity class. Document these in the skill body so reviewers can verify.

## Tone

- Imperative for instructions to Claude ("Read X. Output Y. Do not Z.").
- Declarative for descriptions of behavior ("This skill produces W.").
- Avoid hedge words ("usually", "typically", "perhaps") in normative sections. If a rule has exceptions, name them; don't soften the rule.
- No emojis in skill bodies or in the output the skill produces.

## When sections may differ

These deviations are observed and accepted in v0.1:

- The router (`cohesively`) replaces "Process" with "Routes" and adds a "Routing decision logic" section. Routers route; they don't have a single linear process.
- `cohesive-review` carries three sub-bodies (one per scope). Each sub-body honors the section conventions internally.
- A skill may add a "## Token discipline" section if its outputs can grow large (e.g., `cohesive-review`).

These deviations are documented; new deviations should be discussed before adoption.

## Anti-patterns to avoid

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Hardcoded paths in the body (`/home/...`, `references/...` without `${CLAUDE_PLUGIN_ROOT}`) | Breaks portability; `validate_plugin.sh` fails | Always prefix with `${CLAUDE_PLUGIN_ROOT}/` |
| Missing "Recommended next Cohesive skill" footer | Breaks `SUBSKILL_RECOMMENDS_NEXT` | Add the footer; if multiple verdicts, one per verdict |
| Vague clarifying question | Breaks `ONE_PRECISE_QUESTION` | Pre-can the question as a forced choice |
| "Hard constraints" as a bulleted list of vibes | Constraints must be enforceable | Each constraint is a one-sentence rule + rationale |
| "Anti-patterns" as a bulleted list | Conventionally a table in this repo | Use the three-column Anti-pattern / Why / Fix table |
| Frontmatter `description` written in first person ("I help you...") | Breaks the third-person plugin-dev convention | Rewrite in third person beginning with "Use when" |
| New skill not mentioned in plan §2 or README "What's in the box" | Source-of-truth disagreement | Update plan §2 and README in the same pass |

## Process when adding a new skill

1. Read the closest existing skill in `skills/` — choose the one whose role most resembles yours.
2. Copy its top-level structure; do not invent new section names.
3. Update `docs/implementation_plan.md` §2 to add the skill row to the canonical structure.
4. Update `README.md` §"What's in the box" to mirror plan §2.
5. Run `bash scripts/validate_plugin.sh`. The validator must pass.
6. Run `cohesive:cohesive-review --scope diff` on your branch.
