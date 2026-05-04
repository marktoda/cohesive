# Agent dispatch protocol

> Every Cohesive reviewer agent runs in a fresh subprocess with no inherited conversation context. The dispatching skill passes inputs as explicit file paths in the Task-tool prompt; the agent system prompt forbids reading prior conversation. This is the load-bearing safety property of every Cohesive review.

## What

Cohesive skills dispatch reviewer agents via the Task tool. The dispatch protocol has four required elements:

1. **Inputs as explicit file paths.** The dispatching skill passes the claimed-system-shape summary, the list of normative doc paths, the scope, and the substrate discovery report — all as text or paths in the Task prompt. The agent reads from those paths; it does not infer.

2. **No conversation-context inheritance.** The agent's system prompt explicitly forbids reading prior conversation. The dispatching skill's prompt explicitly forbids pre-summarizing or pre-judging the substrate.

3. **Bounded reading.** The agent reads only the paths passed to it (plus the references its system prompt names). It does not glob the repo.

4. **Structured output.** The agent returns findings in the canonical shape (Severity / Category / Why it matters / Evidence / Recommended fix / Substrate artifact) so the dispatching skill can synthesize.

The protocol applies to every reviewer agent dispatched from any Cohesive skill: today, the four reviewers in `review-codebase` Phase 3, the two reviewers in `review-diff`, and the spec-cohesion-reviewer in `validate-rewrite`.

## Why fresh-eyes matters

The whole point of dispatching a reviewer is that it should reach an *independent* verdict. If the dispatch prompt pre-summarizes the design ("here's what we decided and why"), pre-ranks the findings ("the main issue is X"), or smuggles the calling skill's mental model into the reviewer's context, the review becomes performance — Claude reviewing its own work with cosmetic distance. The output of `review-codebase`, `review-diff`, and `validate-rewrite` only carries weight if the reviewers actually read what's there with no leading.

The fresh-eyes property is **structural**, not aspirational:

- Calling Task tool with `subagent_type` creates an isolated subprocess with no inherited conversation.
- The dispatch prompt is the *entire* context the agent has, plus whatever the agent's system prompt adds.
- The agent system prompt is fixed at dispatch time; it cannot be modified by the calling skill.

If the calling skill writes a "summary of the design" into the dispatch prompt, that summary is in the agent's context — fresh-eyes is broken not by the harness but by the prompt content. The protocol exists to prevent this.

## The dispatch contract (what the calling skill must do)

A correct dispatch prompt has this shape:

```
You are reviewing <repo path>. <One-sentence framing.>

## Claimed system shape (from Phase 1)
<Phase 1 summary as text or path reference. Verbatim from the rubric template; not editorialized.>

## Normative docs (read these in order)
1. <path>
2. <path>
...

## Implementation paths to review
<list of paths anchored to claims, not arbitrary globs>

## Discovery already established (re-use; do not re-derive)
<the substrate discovery report's findings>

## What to focus on
<the agent-specific lens: substrate-alignment, structure, library-native, or agent-readiness>

## Output format
<reference the canonical finding shape; agent's system prompt expands>

## Token discipline
<bound the output length>
```

What the dispatch prompt **must not** contain:

- A summary of the calling skill's mental model ("I think the main issues are X and Y; please verify")
- A pre-ranking of findings ("the most important thing to check is...")
- A list of conclusions the agent should reach ("the verdict should be...")
- Implicit references to prior conversation ("as we discussed...", "given what we found earlier...")
- Files to "consider" or "skim" without explicit paths

The structure-reviewer rubric explicitly checks for these prompt-content failures during a self-review.

## The agent contract (what the agent file must do)

Every reviewer agent file under `agents/` must include the canonical "What you must not do" section with this load-bearing bullet:

```
- Inherit conversation context from the calling skill. Treat your input prompt as the entire context.
```

Plus complementary bullets:

```
- Read prior conversation context. You won't have it; don't pretend.
- Glob the whole repo. Read only paths in your input.
- Pre-summarize the design's intent. Read the docs as the source of truth.
```

The exact phrasing is the canonical preamble defined in [`references/reviewer-agent-template.md`](../../../references/reviewer-agent-template.md). New reviewer agents copy it verbatim.

## Both halves are required

The protocol's safety depends on **both** the dispatching skill and the agent enforcing it:

- If only the agent forbids context inheritance, but the dispatch prompt embeds a design summary, the agent reads the summary as input and is contaminated.
- If only the dispatch prompt is clean, but the agent system prompt allows arbitrary glob, the agent may pull in implementation files that bias the review.

Both sides of the protocol exist as independent fences. The structural fence underneath both is the harness's Task-subprocess isolation: calling Task with `subagent_type` creates an isolated subprocess with no inherited conversation. The agent-file preamble and the skill-side dispatch prose are convention layers on top of that fence — defense in depth, but the harness is the load-bearer.

The fresh-eyes property was previously formalized as a named invariant (`FRESH_EYES_DISPATCH`). v0.1's substrate collapse demoted it to convention because (a) the structural fence is the harness, not the prose; (b) the verbatim-bullet rule produced enforceable-looking documentation that was, in fact, drifting across the agent files without breaking the property. The property is real; the named-invariant ceremony was performative. The conventions in [`references/reviewer-agent-template.md`](../../../references/reviewer-agent-template.md) and [`references/skill-conventions.md`](../../../references/skill-conventions.md) §"Dispatch discipline" carry the rule now.

## What this protocol forbids

- **Pre-summarizing the design.** The agent must read the docs themselves; summaries by the calling skill bias the review.
- **Pre-ranking findings.** The agent ranks; the calling skill synthesizes after the agent returns.
- **Reading conversation history.** The Task subprocess has no conversation history; the protocol just enforces that no skill body or agent prompt assumes one exists.
- **Globbing.** The agent reads paths the dispatching skill passes, plus the references the agent's system prompt names. Nothing else.
- **Cross-agent communication.** Reviewer agents do not read each other's outputs during Phase 3 dispatch — they run in parallel and the synthesizing skill merges them in Phase 4.

## What this protocol does not forbid

- **A reviewer agent referencing rubrics.** The agent's system prompt names `references/cohesion-rubric.md`, `references/substrate-model.md`, etc. The agent reads those because the agent file says to. This is not context inheritance; it is the agent's defined working set.
- **A reviewer agent producing detailed findings.** Bounded reading does not mean shallow output. An agent can produce 20 detailed findings as long as each is anchored to a path in its working set.
- **A skill body explaining the dispatch shape.** The skill's "Phase 3" or "Process" section can describe what it dispatches and why. The constraint is on the *prompt content* sent to the agent, not on the skill body explaining the protocol to a human reader.

## Failure modes this protocol prevents

- **Performance-as-review.** Without fresh-eyes, the reviewer agrees with the calling skill's mental model because the calling skill put that model in the prompt. The review then has no independent value.
- **Hallucinated agreement.** Without bounded reading, the agent can pull in implementation files that happen to support the calling skill's narrative; reviews become biased.
- **Cross-pollination across reviewer agents.** Phase 3 dispatches four reviewers in parallel. If they could read each other's in-progress outputs, the late-running ones would converge on the early-running ones' findings — losing diversity.

## Concrete dispatch sites in v0.1

- **`skills/review-codebase/SKILL.md` Phase 3** — dispatches four reviewer agents in a single message via Task tool: `substrate-alignment-reviewer`, `structure-reviewer`, `library-native-reviewer`, `agent-readiness-reviewer`.
- **`skills/review-diff/SKILL.md`** — dispatches two reviewers in a single message: `substrate-alignment-reviewer`, `structure-reviewer` (and the other two only for very large diffs).
- **`skills/validate-rewrite/SKILL.md`** — dispatches `spec-cohesion-reviewer` once, with the design delta ledger and rewritten spec paths as inputs.

Both sites honor the protocol. The post-Phase-1 architecture review (2026-05-04) found that the agent-file preamble had drifted in wording across the agents — three variants among five files — and that the prior self-review's claim of full compliance was incorrect. That drift is what motivated the v0.1 substrate collapse: the verbatim-bullet rule was producing the appearance of an enforced contract without the substance.

The substrate collapse demoted the verbatim-bullet rule to convention; it did not sweep the five agent files. The drift survives as drift-from-convention rather than drift-from-invariant. A future tightening pass may sweep the corpus to canonical wording when the wording itself stabilizes — until then, the property is held by the harness fence (structural) plus reviewer judgment of the convention (not mechanical enforcement).

## Enforcement

- **Structural (load-bearing):** the harness's Task-subprocess isolation. Reviewer agents have no access to the dispatching skill's conversation. This is the fence that actually prevents context contamination.
- **Convention (reinforcement):** the agent-file preamble bullet and the skill-side dispatch prose. Each agent file says, in some form, that the agent does not inherit conversation context; each dispatching skill states the same in its dispatch prompt. Verbatim copy from [`references/reviewer-agent-template.md`](../../../references/reviewer-agent-template.md) is the safest default. Drift is reviewed in `review-codebase` / `review-diff`, not mechanically enforced.

`scripts/validate_plugin.sh` does not grep for fresh-eyes-preamble strings in v0.1. The structural fence is the harness; the convention is reviewer-judged. If wording stabilizes across agent files in V1, a grep can be added then.

## Alternatives considered

**No protocol; let Claude figure it out.** Rejected: the failure modes (performance-as-review, hallucinated agreement) are subtle and would degrade reviews silently. The protocol makes the safety property structural.

**Single-side enforcement (agent-only OR skill-only).** Rejected: belt-and-suspenders is cheap and the failure modes attack each side differently. Both sides must hold.

**Conversation-style review (agent has access to dispatching skill's context).** Rejected: defeats the entire purpose. The reviewer's value is its independence.

## When to revisit

- If a future Cohesive skill needs a non-reviewer agent (e.g., a long-running indexer agent that must inherit context for state-keeping). At that point, the protocol must clearly distinguish reviewer agents from non-reviewer agents and only apply to the former.
- If the harness gains a structural mechanism for fresh-context dispatch (e.g., a Task-tool flag), the prose enforcement can be replaced with that mechanism.
- If a sixth reviewer agent ships that genuinely cannot work with bounded reading (e.g., a "deep architecture archaeologist" that must glob), the protocol may need to grant explicit globbing permissions per-agent. v0.1 has no such case.

## Related substrate

- [`references/reviewer-agent-template.md`](../../../references/reviewer-agent-template.md) — the canonical reviewer-agent shape, including the canonical preamble.
- [`references/skill-conventions.md`](../../../references/skill-conventions.md) §"Dispatch discipline" — the canonical skill-side rules.
- [`three-layer-architecture.md`](three-layer-architecture.md) — the three-tier separation that justifies fresh-eyes review as a load-bearing property.
