# Gotcha: soft-prereqs degrade silently when prior context is assumed

## Symptom

A Cohesive subskill (most often `brainstorm-design`, `rewrite-specs`, or `cohesive-review`) produces mediocre output: vague design options not anchored in real substrate, a spec rewrite that doesn't know which docs are normative, an architecture review that hallucinates docs that don't exist or misses ones that do.

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

This is a compliant `ONE_PRECISE_QUESTION`: a forced choice between two specific options. The user answers in one word ("yes" / "run it"), the subskill proceeds with explicit knowledge of the state, and no false-positive heuristic runs.

For the router-driven case, the router passes an explicit "discovery already done; here is the report" flag in its dispatch instruction, so the subskill skips the question.

Implementation outline (for the V1 enforcement pass):

1. Update `skills/brainstorm-design/SKILL.md`, `skills/rewrite-specs/SKILL.md`, and `skills/cohesive-review/SKILL.md` Step 0 / "Process" sections to ask the canonical question whenever discovery output is not explicitly passed in.
2. Update `skills/cohesively/SKILL.md` route definitions to pass an explicit "discovery already complete; report at <path>" instruction when the router has run discovery itself.
3. Document the question form in `references/skill-conventions.md` under "Clarifying questions."

## Related invariant

- `ONE_PRECISE_QUESTION` — the prereq detection question must be a forced choice, not a vague open prompt.
- `SUBSKILL_RECOMMENDS_NEXT` — when the user says "no, run it first," the subskill recommends `cohesive:discover-substrate` rather than fumbling forward.

## Tests / checks that preserve this

- Manual scenario test (planned): invoke `cohesive:brainstorm-design` directly with no prior discovery; verify the subskill asks the canonical question.
- Manual scenario test (planned): invoke `cohesive:rewrite-specs` directly with a chosen direction but no discovery; verify same.
- Lint check (V1): grep each subskill body for the canonical question text near the start of "Process."

If this checks list is empty, the gotcha is enforced by reviewer memory only. The first concrete test should land in the next release pass.

## When this was discovered

- Date: 2026-05-04
- Source: self-review of the Cohesive plugin (`docs/history/reviews/2026-05-04-self-review.md` finding 8, agent-readiness #5).
- One-line summary: plan §7 named the risk, three subskill bodies left detection to Claude's heuristic, no canonical detection rule shipped in v0.1.

## Notes for future contributors

- The temptation to add a more sophisticated detection mechanism (parse session state, check for a sentinel file, hash the conversation) should be resisted. The simplest correct mechanism is "ask the user" — and asking is also substrate (it documents the question form).
- If a future runtime feature lets skills query session state deterministically, this gotcha's "Correct pattern" section should be revisited.
- This is a textbook case of the substrate-model thesis: the plan named a risk; the substrate didn't encode the prevention; the failure mode showed up in dogfooding. The fix is to *encode the prevention* (this gotcha + the canonical question), not to retrofit a heuristic.
