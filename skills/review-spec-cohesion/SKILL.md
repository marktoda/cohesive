---
name: review-spec-cohesion
description: Use after rewrite-specs has produced a spec rewrite and a design delta ledger, before implementation. Runs a fresh-eyes review of rewritten docs/specs in a separate agent context that did not participate in the design discussion. Judges whether the new design is internally coherent, behaviorally complete, enforceable, and aligned with the system's stated future direction. Triggers on "review the spec rewrite", "fresh-eyes review of the new design docs", "is the rewrite ready for implementation", "check the spec cohesion". Returns Approved / Issues Found / Design Incoherent.
---

# Review spec cohesion

## What this skill produces

A **spec cohesion review report** in chat, optionally written to `docs/cohesive/<topic>/cohesion-review.md`, with a verdict of **Approved**, **Issues Found**, or **Design Incoherent**, plus blocking issues, important issues, substrate gaps, locality concerns, future-fit concerns, enforcement concerns, and ranked recommended repairs.

The review's defining property is **fresh eyes**: it must run in a context that did not see the design discussion. That's what gives it the power to flag things the original designer can no longer see.

## Hard constraints

1. **Run in a fresh agent context.** This skill dispatches the `spec-cohesion-reviewer` agent via the Task tool. The agent reads only the rewritten specs and the design delta ledger — it must not inherit conversation context from the rewrite.
2. **Inputs must be paths, not summaries.** Pass the agent file paths to read; don't pre-summarize the design for it. Pre-summary defeats the fresh-eyes property.
3. **The review can block implementation.** A "Design Incoherent" or "Issues Found (blocking)" verdict means `rewrite-specs` should run again, not `plan-implementation`.

## Process

### 1. Locate the inputs

Required inputs the calling user or skill must provide (or that this skill should locate):

- **Design delta ledger path** — usually `docs/cohesive/<topic>/design-delta.md`
- **Rewritten spec paths** — extracted from the design delta ledger's "Files rewritten" / "Files added" sections
- **Substrate discovery report path** (optional) — if `discover-substrate` ran earlier, pass its output path so the reviewer can compare what existed before to what now exists
- **Approved direction summary** — one or two sentences from `brainstorm-design`

If any required input is missing, stop and ask. Do not invent inputs.

### 2. Dispatch the spec-cohesion-reviewer agent

Use the Task tool with `subagent_type: spec-cohesion-reviewer`. Pass a prompt with this shape:

```
You are reviewing a spec rewrite. Your inputs are file paths only — do not assume any prior conversation context exists.

**Approved direction:** <one or two sentences>

**Design delta ledger:** <path>

**Rewritten specs to review:**
- <path>
- <path>
- ...

**New specs added:**
- <path>
- ...

**Substrate discovery (for context):** <path or "n/a">

Read all of the above. Return a Spec Cohesion Review using the format in
${CLAUDE_PLUGIN_ROOT}/references/templates/cohesion-review.md.

Verdicts: Approved | Issues Found | Design Incoherent.

Do not read any file not listed above unless the design delta ledger explicitly references it. Do not run code, tests, or git commands. Your job is judgment of the rewritten specs.
```

Run the agent in the foreground — its result is what this skill returns.

### 3. Render the verdict

When the agent returns, surface its report in chat. If the user requested persistence (or this is part of a `cohesively`-orchestrated workflow), also write it to `docs/cohesive/<topic>/cohesion-review.md`.

### 4. Recommend the next step

Based on verdict:

- **Approved** → "Spec rewrite is ready for implementation. Next: `plan-implementation` (V1) or Superpowers' `writing-plans`."
- **Issues Found** → "Repair the blocking issues, then re-run this skill. Many repairs can be made in the same worktree without going back to `brainstorm-design`."
- **Design Incoherent** → "The design itself is incoherent — fixes won't help. Return to `brainstorm-design` with the reviewer's report as input."

## Output format

The skill's chat output (the agent's report, surfaced):

```md
# Spec Cohesion Review — <topic>

**Status:** Approved / Issues Found / Design Incoherent

## Executive judgment
<one paragraph>

## Blocking issues
### B1. <title>
- Risk: ...
- Substrate artifact: ...
- Suggested repair: ...

## Important issues
...

## Substrate gaps
...

## Locality concerns
...

## Future-fit concerns
...

## Enforcement concerns
...

## Vague language to tighten
- <file>:<line> — "<phrase>"

## Recommended repairs (ranked)
1. ...

## Next Cohesive skill
<one of the three options above>
```

## Why fresh eyes matter here

The original architect can no longer see what's underspecified, because they remember the design discussion. They know that "the kernel is pure" implies certain constraints — but a future reader (human or agent) does not have that conversation in their head. Only the docs do.

A fresh-context reviewer simulates the future reader. If the reviewer (who has read only the rewritten docs) can't tell whether some behavior is intentional or accidental, then no future contributor will be able to either. That's the gap the rewrite needs to close before implementation.

## Acceptance criteria

- The dispatched agent receives only file paths, not pre-digested summaries.
- The agent's input does not include the brainstorm or rewrite conversation history.
- The verdict is one of Approved / Issues Found / Design Incoherent — never an unstructured prose conclusion.
- Every issue in the report names the **substrate artifact** to repair (spec, matrix, invariant, gotcha, linter, test, type boundary).
- Vague language ("should," "may," "TBD") in normative sections is enumerated with file:line references.

## Red flags

- Calling the agent with a long contextual preamble that summarizes the design. That bypasses fresh-eyes.
- Reviewing in the same conversation context as the rewrite. The skill must dispatch a subagent.
- Verdict of "Approved" with no positive observations about what looked right. Calibration matters.
- Verdict of "Issues Found" with all issues marked blocking. If everything is blocking, the prioritization is failing.
- The reviewer reading implementation files. Specs only.

## Composition

- **Always preceded by:** `rewrite-specs`
- **Followed by:** `rewrite-specs` again (Issues Found) or `brainstorm-design` (Design Incoherent) or implementation planning (Approved)
