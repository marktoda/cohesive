# Skill conventions

The canonical shape for a Cohesive `SKILL.md`. Read this before adding a new skill or modifying an existing one. The `validate_plugin.sh` semantic linter enforces `PLUGIN_ROOT_PATHS` and structural shape; the rest of the rules below are convention, reviewed in `review-codebase` / `review-diff` rather than mechanically enforced. Treating them as conventions is deliberate — v0.1 is too early to freeze every prose rule into a structural check.

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
- **`## Token discipline`** — only when the skill's outputs can grow large (currently `review-codebase` and `review-diff`).

## Output format conventions

The "Output format" section shows the canonical chat output the skill produces. Two pieces are conventional: a TL;DR lead, and a recommended-next-skill footer.

### TL;DR convention

Every skill that persists output (writes a file under `docs/history/reviews/`, `docs/history/delta-ledgers/`, `docs/history/brainstorms/`, etc.) renders a TL;DR block as the *very first content in chat*, before any longer body. The TL;DR shape:

```md
## TL;DR

**Verdict:** <one of the skill's verdict vocabulary>
**Thesis:** <2-3 sentences. The headline finding plus the highest-leverage move.>
**Top findings:**
1. <finding title> — <one-clause why it matters>
2. ...
3. ...

### Recommended next Cohesive skill
`cohesive:<skill-name>` — <reason>
```

The TL;DR exists because persisted skill outputs (architecture reviews, substrate audits, cohesion reviews) routinely run 5K-10K tokens. A reader needs the verdict, the thesis, and the next move *first* — without scrolling. The full body follows.

Skills with chat-only output (e.g., `review-diff`) already produce verdict-led terse output and may render the TL;DR as the primary content with no longer body. Skills that don't persist (e.g., the router `cohesively`) are exempt.

### Recommended-next-skill footer

The skill's "Output format" section includes a final block named:

```md
### Recommended next Cohesive skill
`cohesive:<skill-name>` — <reason>
```

If the skill has multiple verdict-branches (e.g. `validate-rewrite` returns Approved / Issues Found / Design Incoherent), provide one recommended-next per branch. When the appropriate next step is outside Cohesive, the entry names the non-Cohesive action explicitly:

```md
`<next non-Cohesive action>` — <reason>
```

The router (`cohesively`) is exempt: its output is a one-sentence announcement, not a workflow output.

## Path discipline

Every reference to another skill, agent, reference, template, or script in the body uses `${CLAUDE_PLUGIN_ROOT}/<path>`. Examples:

- `${CLAUDE_PLUGIN_ROOT}/references/templates/invariant.md`
- `${CLAUDE_PLUGIN_ROOT}/agents/spec-cohesion-reviewer.md`
- `${CLAUDE_PLUGIN_ROOT}/skills/discover-substrate/SKILL.md`

This is the one named invariant (`PLUGIN_ROOT_PATHS`) and is enforced by `scripts/validate_plugin.sh`.

## Dispatch discipline

Skills that dispatch to reviewer agents via the Task tool include a fresh-eyes preamble in the dispatch prompt. The preamble's job is to state — in some compatible form — that the agent does not inherit conversation context, reads only the paths passed to it, and does not pre-summarize or pre-rank findings. The canonical wording is in [`reviewer-agent-template.md`](reviewer-agent-template.md); copying it verbatim is the safest default.

The dispatching skill body explicitly states, in prose, that the reviewer reads only paths passed to it, not the conversation. The structural fence is the harness's Task-subprocess isolation; the prose preamble is convention reinforcement.

## Clarifying questions

A skill turn asks **at most one** clarifying question. The question is a specific forced choice (e.g., "Should I review the codebase or the diff?"), never a vague open prompt. Forbidden phrasings include "What do you want?", "Can you tell me more?", "What are you trying to accomplish?", "Anything else I should know?".

### Canonical prereq-detection question

When a skill has `discover-substrate` or `brainstorm-design` as a prereq, it cannot reliably detect prior-skill output from session memory — the heuristic produces false positives. Per `${CLAUDE_PLUGIN_ROOT}/docs/substrate/gotchas/soft-prereqs.md`, ask the user. The canonical form:

```
"I see we're about to run [subskill]. Has [prereq] already happened for this change surface,
or should I run [prereq-skill] first?"
```

This is a compliant forced-choice question (two specific options) and counts toward the at-most-one budget. The user answers in one or two words ("yes" / "run it"); the subskill proceeds with explicit knowledge. Subskills using this pattern as of v0.1: `brainstorm-design`, `rewrite-specs`, `review-codebase`, `review-diff`, `audit-substrate`. When the `cohesively` router invokes any of these, the router passes the prereq state explicitly in the dispatch prompt per the "Dispatch prompt contract" in `${CLAUDE_PLUGIN_ROOT}/skills/cohesively/SKILL.md`, and the subskill skips the question.

Most skills have a pre-canned clarifying question per route or per ambiguity class. Document these in the skill body so reviewers can verify.

## Router conventions

The router (`cohesively`) follows two extra rules:

1. **Announcement before dispatch.** Whenever the router selects a route and is about to invoke the first subskill, it emits one sentence in this form, before any tool call:

   ```
   I'm treating this as a Cohesive <route> workflow: <subskill-1> → <subskill-2> → <subskill-3>. Reason: <one short clause>.
   ```

   `<route>` is one of the canonical route names (`design`, `review (codebase)`, `review (diff)`, `review (substrate audit)`, `rewrite-only`, `artifact`). The reason clause is one sentence, not a paragraph. The announcement is plain text, not a comment, not buried in a tool call.

2. **One pre-canned clarifying question per route.** Per the rule above, vague phrasing forbidden. The matrix at [`docs/substrate/matrices/router.md`](../docs/substrate/matrices/router.md) names which routes ask which question.

## Tone

- Imperative for instructions to Claude ("Read X. Output Y. Do not Z.").
- Declarative for descriptions of behavior ("This skill produces W.").
- Avoid hedge words ("usually", "typically", "perhaps") in normative sections. If a rule has exceptions, name them; don't soften the rule.
- No emojis in skill bodies or in the output the skill produces.

## When sections may differ

These deviations are observed and accepted in v0.1:

- The router (`cohesively`) replaces "Process" with "Routes" and adds a "Routing decision logic" section. Routers route; they don't have a single linear process. The router may also use "Required behavior" instead of "Hard constraints" given its different shape.
- The substrate-discovery skill (`discover-substrate`) uses "When to invoke" + "Inputs" + "Process" instead of "Hard constraints" + "Process." It is a no-dispatch utility skill that has prereq-shaped guidance to give rather than process-internal constraints to enforce. The "When to invoke" section is the load-bearing one for callers.
- A skill may add a "## Token discipline" section if its outputs can grow large.

These deviations are documented; new deviations require explicit discussion and an entry in this section before adoption.

## Anti-patterns to avoid

| Anti-pattern | Why it's wrong | Fix |
|---|---|---|
| Hardcoded paths in the body (`/home/...`, `references/...` without `${CLAUDE_PLUGIN_ROOT}`) | Breaks portability; `validate_plugin.sh` fails | Always prefix with `${CLAUDE_PLUGIN_ROOT}/` |
| Missing "Recommended next Cohesive skill" footer | Workflow legibility breaks; user has to re-derive next step | Add the footer; if multiple verdicts, one per verdict |
| Vague clarifying question | Wastes a turn; reroutes design responsibility back to the user | Pre-can the question as a forced choice |
| "Hard constraints" as a bulleted list of vibes | Constraints must be enforceable | Each constraint is a one-sentence rule + rationale |
| "Anti-patterns" as a bulleted list | Conventionally a table in this repo | Use the three-column Anti-pattern / Why / Fix table |
| Frontmatter `description` written in first person ("I help you...") | Breaks the third-person plugin-dev convention | Rewrite in third person beginning with "Use when" |
| New skill not mentioned in `ARCHITECTURE.md` §"v0.1 scope" or README "What's in the box" | Source-of-truth disagreement | Update both in the same pass |
| Router omits the canonical announcement before dispatching | User can't tell which workflow is running | Use the canonical opening sentence; name the route |

## Process when adding a new skill

1. Read the closest existing skill in `skills/` — choose the one whose role most resembles yours.
2. Copy its top-level structure; do not invent new section names.
3. Update `/ARCHITECTURE.md` only if the new skill changes the broad architectural shape (rare for an additional subskill).
4. Update `README.md` §"What's in the box" to reflect the new on-disk reality.
5. Run `bash scripts/validate_plugin.sh`. The validator must pass.
6. Run `cohesive:review-diff` on your branch.
