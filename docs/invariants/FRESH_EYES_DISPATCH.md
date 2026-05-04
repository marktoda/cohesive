# FRESH_EYES_DISPATCH

> Every Task-tool dispatch from a Cohesive skill to a reviewer agent passes explicit input paths only, forbids inheriting prior conversation context, and includes the canonical fresh-eyes preamble.

## Rule

When a Cohesive skill dispatches a reviewer agent via the Task tool, the dispatch prompt:

1. Passes the inputs explicitly (claimed-system-shape summary, normative doc paths, scope, substrate discovery report) as text in the prompt.
2. Tells the agent to read **only** those paths plus the references the agent's own system prompt names.
3. States — verbatim, in some equivalent phrasing — that the agent does not inherit prior conversation context.
4. Does not pre-summarize or pre-judge the substrate the agent is about to review.

The agent's own system prompt (`agents/<name>.md`) reinforces (3) with the canonical bullet under "What you must not do":

```
- Inherit conversation context from the calling skill. Treat your input prompt as the entire context.
```

Both halves must hold for the invariant to hold.

## Scope

### Applies to
- Every Task-tool dispatch in `skills/cohesive-review/SKILL.md` Phase 3 (substrate-alignment, structure, library-native, agent-readiness reviewers)
- Every Task-tool dispatch in `skills/review-spec-cohesion/SKILL.md` (spec-cohesion-reviewer)
- Every future skill that dispatches a reviewer agent
- Every future reviewer agent's "What you must not do" section

### Does not apply to
- Skill-to-skill chaining (the router invoking subskills) — those run in the parent agent's context by design; "fresh eyes" is specifically a reviewer-agent property.
- The Skill tool (used to invoke subskills) — fresh-eyes is about Task-tool dispatches to agents, not skill chaining.
- Calls to non-reviewer agents (if Cohesive ever ships any). The contract is reviewer-specific.

## Why this matters

The whole point of dispatching a reviewer agent is that it should reach an independent verdict. If the dispatch prompt pre-summarizes the design, pre-ranks the findings, or smuggles the calling skill's mental model into the reviewer's context, the review becomes performance — Claude reviewing its own work with cosmetic distance. The output of `cohesive-review` and `review-spec-cohesion` only carries weight if the reviewers actually read what's there with no leading.

The self-review on 2026-05-04 (finding 1, agent-readiness review) flagged this as a Blocker: the rule existed in prose across five agent files but had no structural enforcement. A future agent adding a sixth reviewer would copy the existing dispatch shape and very plausibly omit the explicit fresh-eyes preamble — and nothing would catch it. Reviews would silently degrade.

## Where this rule must hold

Every Task-tool dispatch site in the codebase. As of v0.1:

- `skills/cohesive-review/SKILL.md` — Phase 3 dispatch of four reviewer agents in parallel
- `skills/review-spec-cohesion/SKILL.md` — single dispatch of `spec-cohesion-reviewer`

And every reviewer agent system prompt:

- `agents/spec-cohesion-reviewer.md`
- `agents/substrate-alignment-reviewer.md`
- `agents/structure-reviewer.md`
- `agents/library-native-reviewer.md`
- `agents/agent-readiness-reviewer.md`

Each must contain the canonical "do not inherit context" clause under "What you must not do."

## Enforcement

- **Tests:** none yet. V1 will add a test that loads each `agents/*.md`, parses for the canonical bullet, and fails if absent.
- **Semantic linters:** `scripts/validate_plugin.sh` greps each `agents/*.md` for the canonical bullet and fails if absent. It also greps each skill body for Task tool dispatches and asserts that nearby prose contains a "reads only paths passed to it" or "does not inherit prior conversation context" clause.
- **CI checks:** wired through `validate_plugin.sh` once `.github/workflows/validate.yml` lands.

The skill-side check is harder to make precise; v0.1 starts with the agent-side check (mandatory bullet) and adds the skill-side check in V1 once the dispatch syntax patterns are stable.

## Known bypass risks

- **A skill author copies a dispatch site without copying the surrounding "fresh eyes" prose.** The agent-side bullet still catches it — the agent's system prompt enforces the rule even if the dispatch site is silent. Belt and suspenders.
- **A skill author writes a "summary" of the design in the dispatch prompt, intending to be helpful.** Pre-summarization is exactly what the invariant forbids. The dispatching skill body must explicitly forbid pre-summarization in its own conventions; `references/skill-conventions.md` carries this rule.
- **A reviewer agent silently begins relying on conversation context that the harness happens to leak through.** Defended by the agent-side bullet + `references/reviewer-agent-template.md` requiring it.
- **A V1 non-reviewer agent that *should* inherit context is added.** Out of scope for this invariant — invariant applies only to reviewer agents. Adding a non-reviewer agent should explicitly note in `references/reviewer-agent-template.md` that it's exempt.

## Review checklist

When reviewing a change that adds or modifies a Task-tool dispatch or a reviewer agent:

- [ ] If a new reviewer agent: does it contain the canonical "do not inherit conversation context" bullet under "What you must not do"?
- [ ] If a new dispatch site: does it pass the standard inputs (claimed-system-shape / normative doc paths / scope / substrate discovery)?
- [ ] If a modified dispatch site: does it still avoid pre-summarization or pre-ranking of findings?
- [ ] Does `bash scripts/validate_plugin.sh` pass?
- [ ] Has the dispatching skill body been read end-to-end to verify no smuggled context?

## Related

- **Plan §3** locked the rule: "Pass inputs explicitly so the agent doesn't inherit conversation context."
- **`references/reviewer-agent-template.md`** carries the canonical bullet text and the agent-shape requirements.
- **`references/skill-conventions.md`** carries the dispatch-site rules.
- **Self-review finding 1** named the gap.

## History

- 2026-05-04 — Created. Promoted from plan §3 prose to a named invariant. Agent-side enforcement (canonical bullet + validator grep) is the v0.1 enforcement floor; skill-side enforcement is V1.
