# Gotcha: soft-prereqs degrade silently when prior context is assumed

## Symptom

A Cohesive subskill (most often `brainstorm-design`, `rewrite-specs`, `review-codebase`, `review-diff`, or `audit-substrate`) produces mediocre output: vague design options not anchored in real substrate, a spec rewrite that doesn't know which docs are normative, an architecture review that hallucinates docs that don't exist or misses ones that do.

The user invoked the subskill directly, without running `discover-substrate` first. The subskill's body says "if discover-substrate hasn't run yet for this change surface, invoke it first" — but it doesn't say *how* to detect that discovery has run, so the subskill silently assumes prior session context and proceeds.

The output looks competent on the surface. The issues are in what's *missing*: real file paths, real invariant names, real test coverage. They're absent because the subskill never read the codebase.

## Why it happened

Plan §3 line 89 commits to "skill-level prereqs are soft: subskills check for prior skill output and run a quick inline version if missing, instead of hard-gating." The intent is good — hard gates make skills brittle when invoked across sessions. But "check for prior skill output" was never specified:

- There is no canonical session-state mechanism Claude Code skills can query.
- The subskill body language ("if `discover-substrate` hasn't run yet, invoke it first") is read by Claude as guidance, not as a deterministic check.
- Claude's "soft check" in practice degrades to "do I remember discovery output from earlier in this conversation?" — which produces a false positive whenever the conversation has any prior context, including unrelated context.

So the failure mode is: the subskill runs without a fresh `discover-substrate` because Claude's heuristic check returns "yes, we discussed substrate earlier" — even when "earlier" was an unrelated turn or a previous topic.

The plan §7 risks list flagged this exact failure mode: "Soft prereqs may produce mediocre output if subskills are routinely invoked without context." The risk was named; the detection rule was not.

## Tempting wrong fix

Hard-gate the prereq: refuse to run the subskill until `discover-substrate` has been invoked in the current session.

Why it's wrong: hard gates break the legitimate cross-session case (a user pauses overnight and resumes), the direct-invocation case (`/cohesive:rewrite-specs` with a chosen direction from a prior session), and the router-driven case (the router has already discovered substrate at the route level). Hard gates also produce a worse user experience: the subskill refuses to run rather than producing a useful but flagged result.

The plan deliberately chose soft over hard. Reverting to hard is a regression.

## Correct pattern

Don't ask Claude to detect prior state. Ask the user.

Each subskill that has `discover-substrate` as a prereq opens its turn with a short, pre-canned check:

> "I see we're about to run [subskill]. Has substrate discovery already happened for this change surface, or should I run `discover-substrate` first?"

This complies with the clarifying-question convention in `docs/substrate/conventions/skill-shape.md`: a forced choice between two specific options. The user answers in one word ("yes" / "run it"), the subskill proceeds with explicit knowledge of the state, and no false-positive heuristic runs.

For the router-driven case, the router passes an explicit "discovery already done; here is the report" flag in its dispatch instruction, so the subskill skips the question.

Implementation outline (for the V1 enforcement pass):

1. Update `skills/brainstorm-design/SKILL.md`, `skills/rewrite-specs/SKILL.md`, `skills/review-codebase/SKILL.md`, `skills/review-diff/SKILL.md`, and `skills/audit-substrate/SKILL.md` "Hard constraints" / "Process" sections to ask the canonical question whenever discovery output is not explicitly passed in. (Done in v0.1.)
2. Update `skills/cohesively/SKILL.md` route definitions to pass an explicit "discovery already complete; report at <path>" instruction when the router has run discovery itself, codified in the "Dispatch prompt contract" section. (Done in v0.1.)
3. Document the question form in `docs/substrate/conventions/skill-shape.md` under "Clarifying questions." (Done in v0.1.)

## What this gotcha does not cover

This gotcha covers only the case where the prereq is *substrate discovery in the current conversation*. For prereqs that are file paths — an Approved validation review for `implement-cohesively`, a delta ledger for `validate-rewrite`, a chosen-direction summary passed by a dispatching skill — the correct pattern is **inputs declared explicitly in the skill body and directive errors when missing**, not a forced-choice question. See `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` for per-handoff input contracts.

The session-memory failure mode this gotcha names applies specifically to "did discovery happen in this conversation?" because that prereq has no canonical artifact to point at. A path prereq has a canonical artifact (`docs/history/<kind>/<date>-<slug>*.md`); the correct response to a missing path prereq is `"Missing <input>. Run cohesive:<upstream-skill> first; expected output at <path>."` — not the canonical clarifying question.

The previous draft of this gotcha enumerated "structured-artifact handoff" as a third recognized-input shape that downstream skill bodies should detect alongside the canonical question. That enumeration retired in the 2026-05-05 validate-rewrite-internal-loop refactor: `validate-rewrite`'s Issues Found repair pass became an internal loop (no longer a user-driven handoff to detect — see `${CLAUDE_PLUGIN_ROOT}/docs/substrate/architecture/handoffs.md` §"validate-rewrite ↔ rewrite-specs (Issues Found internal repair loop)"), and `implement-cohesively`'s Approved-verdict input became a directive-error path prereq (no clarifying question at all). The structural-handoff middle ground turned out to be solving a problem the simpler "explicit inputs + directive errors" shape doesn't have.

## Related conventions

- **Clarifying-question convention** ([`docs/substrate/conventions/skill-shape.md`](../conventions/skill-shape.md) §"Clarifying questions") — the prereq detection question must be a forced choice, not a vague open prompt.
- **Recommended-next-skill convention** ([`docs/substrate/conventions/skill-shape.md`](../conventions/skill-shape.md) §"Output format conventions") — when the user says "no, run it first," the subskill recommends `cohesive:discover-substrate` rather than fumbling forward.

## Tests / checks that preserve this

- Manual scenario test (planned): invoke `cohesive:brainstorm-design` directly with no prior discovery; verify the subskill asks the canonical question.
- Manual scenario test (planned): invoke `cohesive:rewrite-specs` directly with no chosen direction and no discovery; verify the subskill asks the canonical question.
- Manual scenario test (planned): invoke `cohesive:implement-cohesively` directly with no validation review path; verify the subskill **stops with a directive error** naming `cohesive:validate-rewrite` as the upstream — it does *not* ask the canonical question because its prereq is a file path, not session state.
- Lint check (V1): grep each substrate-discovery-prereq subskill body (`brainstorm-design`, `rewrite-specs`, `review-codebase`, `review-diff`, `audit-substrate`) for the canonical question text near the start of "Process."

If this checks list is empty, the gotcha is enforced by reviewer memory only. The first concrete test should land in the next release pass.

## When this was discovered

- Date: 2026-05-04
- Source: self-review of the Cohesive plugin (`docs/history/reviews/2026-05-04-self-review.md` finding 8, agent-readiness #5).
- One-line summary: plan §7 named the risk, three subskill bodies left detection to Claude's heuristic, no canonical detection rule shipped in v0.1.

## Notes for future contributors

- The temptation to add a more sophisticated detection mechanism (parse session state, check for a sentinel file, hash the conversation) should be resisted. The simplest correct mechanism is "ask the user" — and asking is also substrate (it documents the question form).
- If a future runtime feature lets skills query session state deterministically, this gotcha's "Correct pattern" section should be revisited.
- This is a textbook case of the substrate-model thesis: the plan named a risk; the substrate didn't encode the prevention; the failure mode showed up in dogfooding. The fix is to *encode the prevention* (this gotcha + the canonical question), not to retrofit a heuristic.
