# ONE_PRECISE_QUESTION

> Any Cohesive skill turn asks at most one clarifying question, and when it asks, the question is a specific forced choice — never a vague open prompt.

## Rule

Within a single Cohesive skill turn (one user → assistant exchange), the skill may ask zero or one clarifying questions. When it asks one, the question:

1. Names a specific forced choice between concrete options ("A or B?", "Should this be scope X or scope Y?", "Approved direction A, B, or C?").
2. Is grounded in the skill's documented routes, modes, or input shape — not improvised.
3. Does not include vague open prompts: forbidden forms include "What do you want?", "Can you tell me more?", "What are you trying to accomplish?", "Anything else I should know?"

If two questions are genuinely needed, ask one this turn and the second only if the first answer requires it.

## Scope

### Applies to
- The router (`cohesively`) — one clarifying question per route, pre-canned in the route definition.
- Every subskill that has documented clarifying questions: `cohesive-review`, `rewrite-specs`, etc.
- Every future Cohesive skill.

### Does not apply to
- Confirmations of consent before destructive actions (e.g., "About to commit; OK to proceed?"). Those are not clarifying questions.
- Questions inside a worked example or template — those illustrate; they aren't asked.
- The Approved/Issues Found/Design Incoherent verdict prompts in `review-spec-cohesion`. Those are verdicts, not questions.

## Why this matters

Vague open questions waste turns and are often a substitute for thinking. A skill that asks "what do you want?" has effectively rerouted the design responsibility back to the user — which defeats the purpose of having a skill. Cohesive skills are opinionated; their value is the routes and rubrics they apply, not the questions they ask.

A second motivation: precise clarifying questions are themselves substrate. They become the documented disambiguation rules a future agent reads when extending the skill. "What do you want?" leaves no documentation behind.

The self-review on 2026-05-04 flagged this as locked-in-prose at `cohesively/SKILL.md:127` (in the Red flags table) but with no structural enforcement.

## Where this rule must hold

- `skills/cohesively/SKILL.md` — each route specifies whether it asks a clarifying question and, if so, gives the canonical form.
- `skills/cohesive-review/SKILL.md` — the mode-disambiguation question is pre-canned ("Is this a full architecture review (`--scope codebase`), a PR/diff review (`--scope diff`), or a substrate audit (`--scope substrate`)?").
- `skills/rewrite-specs/SKILL.md` — the precondition question is implicit in "An approved direction is required."
- Every future skill body, in a "Clarifying questions" block under "Process" or "Routes."

## Enforcement

- **Tests:** none yet. V1 will add a transcript-shape check: any transcript with a `?` from the assistant turn must show a question form matching one documented in the relevant skill's body.
- **Semantic linters:** `scripts/validate_plugin.sh` greps each SKILL.md for the strings "what do you want", "tell me more", "anything else" and fails if found outside an anti-pattern block. (This is a coarse first cut; the full invariant is harder to lint.)
- **CI checks:** through `validate_plugin.sh`.

The full invariant (one question max, must be a forced choice) is partially aspirational in v0.1 — the validator catches the worst-case anti-patterns, not every violation. Reviewer judgment fills the gap.

## Known bypass risks

- **A skill body that pre-cans a question with vague phrasing.** E.g., "Which scope are you thinking about?" The validator catches it only if it matches the forbidden phrase list. Reviewer judgment is the floor.
- **The router asks zero questions and the subskill asks one** — that's permitted. The "one max" budget applies per skill turn, not per workflow.
- **A skill genuinely needs two pieces of information.** If decomposition into two turns is unworkable, the skill should bundle the request as a single forced choice over the joint space (e.g., "Codebase review of subsystem X, or codebase review of the whole repo?") rather than asking two separate questions.

## Review checklist

When reviewing a change to a SKILL.md that adds or modifies a clarifying question:

- [ ] Is the question pre-canned in the skill body, with documented options?
- [ ] Does the question name specific forced choices, not open prompts?
- [ ] Does the skill ask at most one question per turn?
- [ ] Does the question pattern avoid the forbidden phrases ("what do you want", "tell me more", "anything else")?

When reviewing a transcript:

- [ ] Does each Cohesive assistant turn contain at most one `?`?
- [ ] If a question is asked, is it traceable to a pre-canned form in the relevant skill?

## Related

- **`references/skill-conventions.md`** — names this rule for new skills.
- **`cohesively/SKILL.md`** — Red flags section explicitly forbids vague questions.

## History

- 2026-05-04 — Created. Promoted from `cohesively/SKILL.md:88,127` prose. v0.1 enforcement is partial (forbidden-phrase grep + reviewer judgment); fuller transcript-shape check follows in V1.
