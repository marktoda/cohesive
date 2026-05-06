# Dispatch protocol

The prescriptive shape of every Cohesive **Task-tool reviewer-agent dispatch**. Read this when authoring a new reviewer-dispatching skill or a new reviewer agent. The load-bearing property — fresh-eyes review — and its rationale live in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md`; this doc specifies the contract every Task-tool dispatch must follow.

Cohesive has a second dispatch shape — **Skill-tool (skill→skill) dispatch** — used by `validate-rewrite`'s repair loop and `implement-cohesively`'s phase loop. Skill-tool dispatches are subroutine calls: same conversation context, prompt-as-handoff, no fresh-eyes property. This doc covers Task-tool dispatches only; the Skill-tool contract lives at `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-tool-dispatch.md`. A new contributor authoring a composition seam should consult the right one — conflating the two is exactly the failure mode the separate documents exist to prevent.

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

Every reviewer agent file under `agents/` includes the canonical "What you must not do" section with this load-bearing bullet:

```
- Inherit conversation context from the calling skill. Treat your input prompt as the entire context.
```

Plus complementary bullets:

```
- Read prior conversation context. You won't have it; don't pretend.
- Glob the whole repo. Read only paths in your input.
- Pre-summarize the design's intent. Read the docs as the source of truth.
```

The exact phrasing is the canonical preamble defined in `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md`. New reviewer agents copy it verbatim.

## Concrete dispatch sites in v0.1

- **`skills/review-codebase/SKILL.md` Phase 3** — dispatches four reviewer agents in a single message via Task tool: `substrate-alignment-reviewer`, `structure-reviewer`, `library-native-reviewer`, `agent-readiness-reviewer`.
- **`skills/review-diff/SKILL.md`** — dispatches two reviewers in a single message: `substrate-alignment-reviewer`, `structure-reviewer` (and the other two only for very large diffs).
- **`skills/validate-rewrite/SKILL.md`** — dispatches `spec-cohesion-reviewer` once, with the design delta ledger and rewritten spec paths as inputs.
- **`skills/implement-cohesively/SKILL.md` Phase 2c (per phase)** — dispatches `delta-coverage-reviewer` once per implementation phase, with the delta-ledger excerpt, plan path, and phase diff as inputs. Each dispatch is independent (per-phase fence); no cross-phase reviewer state.

All sites honor the contract. The post-Phase-1 architecture review (2026-05-04) found that the agent-file preamble had drifted in wording across the agents — three variants among five files — and that the prior self-review's claim of full compliance was incorrect. That drift is what motivated the v0.1 substrate collapse: the verbatim-bullet rule was producing the appearance of an enforced contract without the substance.

The substrate collapse demoted the verbatim-bullet rule to convention; it did not sweep the agent files. The drift survives as drift-from-convention rather than drift-from-invariant. A future tightening pass may sweep the corpus to canonical wording when the wording itself stabilizes — until then, the property is held by the harness fence (structural) plus reviewer judgment of the convention (not mechanical enforcement). `delta-coverage-reviewer` ships with the canonical preamble verbatim from day one; whether the corpus stays aligned is reviewer-judged.

## Related substrate

- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/fresh-eyes-review.md` — the load-bearing property this contract enforces; rationale, alternatives, when to revisit.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/reviewer-agent-shape.md` — the canonical reviewer-agent shape, including the canonical preamble.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-shape.md` §"Dispatch discipline" — the canonical skill-side rules.
- `${CLAUDE_PLUGIN_ROOT}/docs/substrate/conventions/skill-tool-dispatch.md` — the Skill-tool (skill→skill) dispatch contract; complementary to this doc and consulted instead when authoring an internal repair loop or phase loop.
