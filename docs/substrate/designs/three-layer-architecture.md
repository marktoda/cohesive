# Three-layer architecture

> Cohesive separates workflow orchestration (`skills/`), fresh-context review (`agents/`), and runtime-consumed content (`references/`) into three deliberate tiers. The separation is the load-bearing structural decision in the codebase.

## What

Three top-level directories under `${CLAUDE_PLUGIN_ROOT}`, each with a single role:

| Tier | Path | Role | Lifecycle |
|---|---|---|---|
| Skills | `skills/<name>/SKILL.md` | Workflow orchestration | Edited when the workflow changes |
| Agents | `agents/<name>.md` | Fresh-context review | Edited when the review lens changes |
| References | `references/<name>.md`, `references/templates/<name>.md` | Pure content (rubrics, models, templates, conventions) | Edited when the content changes |

Skills are user-invocable. Agents are dispatched by skills, never by the user directly. References are read by both at runtime.

## Why this separation

Each tier has a different reader, a different lifecycle, and a different failure mode if conflated.

- **Skills are processes.** A skill body answers "what does the user / harness do, step by step?" If a skill body absorbs reference content (substrate model, rubric definitions), the skill becomes hard to update without re-reading every paragraph that *should* live in references.
- **Agents are reviewers.** An agent file answers "what does this fresh-context subprocess check, and what does it not?" If an agent body absorbs orchestration logic, it's no longer a reviewer — it's a workflow inside a Task subprocess, and the fresh-eyes property breaks.
- **References are content.** A reference answers "what does Cohesive teach about X?" If a reference is conflated with a skill body, the content gets fragmented across components and reviewers can't find the canonical statement.

The three readers are different too:
- Claude reads skill bodies during workflow execution.
- Claude (in a Task subprocess) reads agent bodies + the explicitly-passed paths.
- Claude reads references when a skill or agent cites them.
- Humans / future contributors read all three — but for different reasons (changing a workflow vs adding a review lens vs updating a rubric).

Conflating any two of the three pushes content into the wrong tier and degrades all three.

## Concrete examples in v0.1

- **Skills citing references** — `skills/cohesive-review/SKILL.md` cites `${CLAUDE_PLUGIN_ROOT}/references/architecture-review-rubric.md` for the four-phase rubric. The skill body says *what to do*; the rubric defines *what counts as good*. Splitting them lets the rubric be updated without touching the skill body.
- **Skills dispatching agents** — `skills/cohesive-review/SKILL.md` Phase 3 dispatches four reviewer agents in a single message via Task tool. The skill body knows the dispatch shape; each agent file knows its own review lens. The skill doesn't embed reviewer prompts; the agents don't embed orchestration.
- **References as templates** — `references/templates/invariant.md` is filled in by `rewrite-specs` when a new invariant is named. The skill body knows when to fill the template; the template itself knows what the artifact must contain.

## What this separation forbids

- **A skill embedding a long rubric inline.** If the rubric is more than ~10 lines, it lives in `references/`. The skill cites the path.
- **An agent embedding a process flowchart.** If the agent finds itself describing "first do A, then B, then C, then return," it has been mis-tiered as a workflow. Workflows are skills.
- **A reference embedding a skill's output schema.** Output schemas live in skill bodies because the skill produces the output. References describe vocabulary, not action.

## What the separation does not require

- **References cannot cite skills.** They can — and do, for canonical output formats (e.g., `references/design-pressure-testing.md` cites `${CLAUDE_PLUGIN_ROOT}/skills/brainstorm-design/SKILL.md` as the canonical home of a particular output format). The dependency direction is "reference describes vocabulary; skill is the authoritative producer," and citing the skill from the reference acknowledges that. The self-review flagged one case of inverted citation direction, which should be flipped in a future cleanup.
- **One-line content cannot live in a skill.** Tiny inline definitions are fine. The rule is about substantial content; small clarifications stay where they are most legible.

## Consequences for adding new components

**Adding a skill:**
- Read [`references/skill-conventions.md`](../../../references/skill-conventions.md). The conventions doc is the canonical shape.
- Update [`ARCHITECTURE.md`](../../../ARCHITECTURE.md) only if the new skill changes the broad architectural shape (rare for an additional subskill).
- Update [`README.md`](../../../README.md) §"What's in the box" and the on-disk parity check.
- The skill body cites references and templates; it does not duplicate them.

**Adding an agent:**
- Read [`references/reviewer-agent-template.md`](../../../references/reviewer-agent-template.md). The template is the canonical shape.
- The agent's "Inputs you will receive" section names every path the agent will read. The agent does not glob.
- The agent's "What you must not do" section includes the canonical fresh-eyes preamble (see [`agent-dispatch-protocol.md`](agent-dispatch-protocol.md)).
- The dispatching skill body must be updated to invoke the new agent with the standard input shape.

**Adding a reference:**
- Determine whether it's content (lives at top level of `references/`) or a fillable artifact template (lives in `references/templates/`).
- Cite from `${CLAUDE_PLUGIN_ROOT}/references/...` paths from skill or agent bodies that need it.
- Don't pre-create empty references; create them when there's content.

## Failure modes this separation prevents

- **The "everything in one giant SKILL.md" failure.** When a skill body absorbs reference content + agent prompts + template definitions, no one can find the canonical statement of anything, and updates touch one giant file.
- **The "agent doing orchestration" failure.** When an agent embeds workflow logic, fresh-eyes is broken (reviews depend on orchestration choices the user can't see) and the agent can't be reused across skills.
- **The "reference duplicated in three skills" failure.** When the same paragraph appears in three skill bodies, updates drift; reviewers find three versions and can't tell which is authoritative.

The structure-reviewer agent ([`structure-reviewer.md`](../../../agents/structure-reviewer.md)) actively looks for these failure modes during `cohesive-review --scope codebase`.

## Alternatives considered

**Two tiers only (skills + everything else).** Rejected: collapses agents into skills, breaking the fresh-eyes property of reviews. The cost of fresh-eyes review is precisely that the agent doesn't know what the calling skill knows — collapsing them puts the calling skill's mental model into the agent.

**Four or more tiers (e.g., separate `templates/` at top level).** Rejected in v0.1 by the implementation plan: templates are a kind of reference, not a sibling tier. Putting them under `references/templates/` keeps the top-level structure simple and matches their use (they are *content* the runtime reads, like other references).

**No tiers, flat namespace.** Rejected as obviously hostile to discoverability. The three-tier separation costs nothing in path length and gains a lot in legibility.

## When to revisit

This decision should be re-examined when:
- A new component category appears that doesn't fit any of the three tiers (e.g., long-running daemon scripts, web-served skill catalogs).
- The number of files in any tier exceeds ~30 and one tier needs further subdivision (likely `agents/` or `skills/` would gain subdirectories before `references/` does).
- A pattern of inter-tier coupling emerges that the current separation doesn't accommodate (e.g., agents needing to invoke other agents — currently forbidden by design).

None of these apply in v0.1.

## Related substrate

- [`docs/substrate/invariants/PLUGIN_ROOT_PATHS.md`](../invariants/PLUGIN_ROOT_PATHS.md) — every cross-tier reference uses `${CLAUDE_PLUGIN_ROOT}/`.
- [`agent-dispatch-protocol.md`](agent-dispatch-protocol.md) — the cross-tier interface between skills and agents; describes fresh-eyes as a load-bearing property held by harness subprocess isolation plus convention reinforcement.
- [`references/locality-over-centralization.md`](../../../references/locality-over-centralization.md) — the principle this separation operationalizes.
- [`composition-with-superpowers.md`](composition-with-superpowers.md) — extends the same separation principle outward (Cohesive owns substrate; Superpowers owns implementation).
