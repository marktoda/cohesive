# Fresh-eyes review

> Every Cohesive reviewer agent runs in a fresh subprocess with no inherited conversation context. This is the load-bearing safety property of every Cohesive review. Without it, reviews degrade to performance — Claude reviewing its own work with cosmetic distance.

## What

Cohesive's review skills (`review-codebase`, `review-diff`, `validate-rewrite`, `implement-cohesively`'s end-of-run dual reviewer dispatch) dispatch reviewer agents via the Task tool. Each agent runs in an isolated subprocess. The agent reads only paths the dispatching skill passes plus the references its system prompt names; it has no access to the conversation that produced those paths.

The fresh-eyes property defines four requirements for every review:

1. **Inputs as explicit file paths.** The dispatching skill passes the claimed-system-shape summary, normative doc paths, scope, and substrate discovery report — all as text or paths in the Task prompt.
2. **No conversation-context inheritance.** The agent's system prompt forbids reading prior conversation. The dispatching skill's prompt forbids pre-summarizing or pre-judging the substrate.
3. **Bounded reading.** The agent reads only the paths passed to it (plus references its system prompt names). It does not glob the repo.
4. **Structured output.** The agent returns findings in the canonical six-field shape (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact) so the dispatching skill can synthesize.

The property applies to every reviewer agent dispatched from any Cohesive skill: the four reviewers in `review-codebase` Phase 3, the two reviewers in `review-diff`, the spec-cohesion-reviewer in `validate-rewrite`, and the delta-coverage-reviewer dispatched per phase by `implement-cohesively`.

The prescriptive shape of the dispatch prompt and agent file lives in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/dispatch-protocol.md`. This doc explains why the property matters and what enforces it.

## Why fresh-eyes matters

The whole point of dispatching a reviewer is that it should reach an *independent* verdict. If the dispatch prompt pre-summarizes the design ("here's what we decided and why"), pre-ranks the findings ("the main issue is X"), or smuggles the calling skill's mental model into the reviewer's context, the review becomes performance. The output of `review-codebase`, `review-diff`, and `validate-rewrite` only carries weight if the reviewers actually read what's there with no leading.

The fresh-eyes property is **structural**, not aspirational:

- Calling Task tool with `subagent_type` creates an isolated subprocess with no inherited conversation.
- The dispatch prompt is the *entire* context the agent has, plus whatever the agent's system prompt adds.
- The agent system prompt is fixed at dispatch time; it cannot be modified by the calling skill.

If the calling skill writes a "summary of the design" into the dispatch prompt, that summary is in the agent's context — fresh-eyes is broken not by the harness but by the prompt content. The convention layer at `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/dispatch-protocol.md` exists to prevent this.

## Both halves are required

The property's safety depends on **both** the dispatching skill and the agent enforcing it:

- If only the agent forbids context inheritance, but the dispatch prompt embeds a design summary, the agent reads the summary as input and is contaminated.
- If only the dispatch prompt is clean, but the agent system prompt allows arbitrary glob, the agent may pull in implementation files that bias the review.

Both sides exist as independent fences. The structural fence underneath both is the harness's Task-subprocess isolation: calling Task with `subagent_type` creates an isolated subprocess with no inherited conversation. The agent-file preamble and the skill-side dispatch prose are convention layers on top of that fence — defense in depth, but the harness is the load-bearer.

The fresh-eyes property was previously formalized as a named invariant (`FRESH_EYES_DISPATCH`). v0.1's substrate collapse demoted it to convention because (a) the structural fence is the harness, not the prose; (b) the verbatim-bullet rule produced enforceable-looking documentation that was, in fact, drifting across the agent files without breaking the property. The property is real; the named-invariant ceremony was performative. The conventions in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` and `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Dispatch discipline" carry the rule now.

## What this property forbids

- **Pre-summarizing the design.** The agent must read the docs themselves; summaries by the calling skill bias the review.
- **Pre-ranking findings.** The agent ranks; the calling skill synthesizes after the agent returns.
- **Reading conversation history.** The Task subprocess has no conversation history; the property just enforces that no skill body or agent prompt assumes one exists.
- **Globbing.** The agent reads paths the dispatching skill passes, plus the references the agent's system prompt names. Nothing else.
- **Cross-agent communication.** Reviewer agents do not read each other's outputs during Phase 3 dispatch — they run in parallel and the synthesizing skill merges them in Phase 4.

## What this property does not forbid

- **A reviewer agent referencing rubrics.** The agent's system prompt names `references/cohesion-rubric.md`, `references/substrate-model.md`, etc. The agent reads those because the agent file says to. This is not context inheritance; it is the agent's defined working set.
- **A reviewer agent producing detailed findings.** Bounded reading does not mean shallow output. An agent can produce 20 detailed findings as long as each is anchored to a path in its working set.
- **A skill body explaining the dispatch shape.** The skill's "Phase 3" or "Process" section can describe what it dispatches and why. The constraint is on the *prompt content* sent to the agent, not on the skill body explaining the property to a human reader.

## Failure modes this property prevents

- **Performance-as-review.** Without fresh-eyes, the reviewer agrees with the calling skill's mental model because the calling skill put that model in the prompt. The review then has no independent value.
- **Hallucinated agreement.** Without bounded reading, the agent can pull in implementation files that happen to support the calling skill's narrative; reviews become biased.
- **Cross-pollination across reviewer agents.** Phase 3 dispatches four reviewers in parallel. If they could read each other's in-progress outputs, the late-running ones would converge on the early-running ones' findings — losing diversity.

## Enforcement

- **Structural (load-bearing):** the harness's Task-subprocess isolation. Reviewer agents have no access to the dispatching skill's conversation. This is the fence that actually prevents context contamination.
- **Convention (reinforcement):** the agent-file preamble bullet and the skill-side dispatch prose. Each agent file says, in some form, that the agent does not inherit conversation context; each dispatching skill states the same in its dispatch prompt. Verbatim copy from `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` is the safest default. Drift is reviewed in `review-codebase` / `review-diff`, not mechanically enforced.

`scripts/validate_plugin.sh` does not grep for fresh-eyes-preamble strings in v0.1. The structural fence is the harness; the convention is reviewer-judged. If wording stabilizes across agent files in V1, a grep can be added then.

## Alternatives considered

**No property; let Claude figure it out.** Rejected: the failure modes (performance-as-review, hallucinated agreement) are subtle and would degrade reviews silently. The property makes the safety guarantee structural.

**Single-side enforcement (agent-only OR skill-only).** Rejected: belt-and-suspenders is cheap and the failure modes attack each side differently. Both sides must hold.

**Conversation-style review (agent has access to dispatching skill's context).** Rejected: defeats the entire purpose. The reviewer's value is its independence.

## Subprocess isolation also serves capacity isolation

The Task-subprocess fence is the same mechanism whether a skill wants **fresh eyes** (independent verdict, no calling-skill bias) or **fresh capacity** (a clean context window with room for a long phase). Both reduce to: dispatch a subagent and pass the paths it needs.

This means **wrap-up recommendations must never tell the user to restart their session for context-budget reasons.** "Open a fresh session and resume from Phase N" / "the fresh-session context budget gives Phase X room" / "start a new session, run X, then resume Y" — these all push friction onto the user that the harness already solves. If a flow's next step needs more context room than the current turn has, the right move is to (a) dispatch the next step as a subagent in the same turn, or (b) end the turn naming the next skill and let the user invoke it — that invocation itself runs in a fresh subprocess.

The chat-output rule is in `${CLAUDE_PLUGIN_ROOT}/references/output-voice.md` §"Forbidden phrasings"; this section is the architectural reason behind it. Any Cohesive skill producing a wrap-up trailer is bound by both surfaces.

## When to revisit

- If a future Cohesive skill needs a non-reviewer agent (e.g., a long-running indexer agent that must inherit context for state-keeping). At that point, the property must clearly distinguish reviewer agents from non-reviewer agents and only apply to the former.
- If the harness gains a structural mechanism for fresh-context dispatch (e.g., a Task-tool flag), the prose enforcement can be replaced with that mechanism.
- If a sixth reviewer agent ships that genuinely cannot work with bounded reading (e.g., a "deep architecture archaeologist" that must glob), the property may need to grant explicit globbing permissions per-agent. v0.1 has no such case.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/dispatch-protocol.md` — the prescriptive dispatch contract (calling skill prompt shape; agent file shape).
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` — the canonical reviewer-agent shape, including the canonical preamble.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Dispatch discipline" — the canonical skill-side rules.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/three-tier-architecture.md` — the three-tier separation that justifies fresh-eyes review as a load-bearing property.
