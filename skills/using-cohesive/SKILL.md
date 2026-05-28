---
name: using-cohesive
description: Use when starting work in a codebase where substrate-first thinking applies — designing a feature, refactor, or architecture change that touches behavior or invariants; reviewing for cohesion; auditing what memory is missing; rewriting specs or behavior matrices to a chosen end state; or implementing against an approved design delta ledger. Establishes when Cohesive's substrate-first methodology is the right framing (versus Superpowers' implementation discipline) and routes substrate-shaped requests to the cohesively router. Triggers on "design substrate-first", "review for cohesion", "audit substrate", "rewrite the specs cohesively", "what invariants are missing", "is the architecture coherent for cohesion", "implement against the delta", or any request naming specs, named invariants, behavior matrices, gotchas, or cohesion explicitly as the change surface. Do NOT trigger when the request is implementation-discipline-shaped (writing tests, executing a plan, finishing a branch, debugging a specific bug) — defer to Superpowers.
---

# using-cohesive

## What this skill does

Establishes when Cohesive's substrate-first methodology is the right framing for the user's request, and routes substrate-shaped work to the canonical entry point (`cohesive:cohesively`). The skill carries no artifact, persists no file, and runs no workflow — its job is the orientation message and the routing nudge.

Substrate-first work is what Cohesive optimizes for; implementation-discipline work is what Superpowers optimizes for. This skill picks between them at session start (or whenever its frontmatter trigger matches a user request mid-session). When Cohesive applies, the skill renders a 1–2 sentence orientation naming `cohesive:cohesively` as the next step. When the request is implementation-discipline-shaped, the skill stays silent — Superpowers' bootstrap (`superpowers:using-superpowers`) handles that framing on its own.

The seam this skill closes is the trigger competition between Cohesive and Superpowers entry points. Without `using-cohesive`, first-time users who type "what's wrong with this codebase?" land in description-match-level competition between Cohesive's `discover-substrate`/`audit-substrate` and Superpowers' research/exploration skills; with it, the substrate-first framing has a session-start surface.

## When Cohesive applies

Cohesive applies when the user's request names — explicitly or by clear implication — substrate as the change surface. The five triggers:

1. **Design under substrate pressure.** Designing a feature, refactor, or architecture change that touches behavior, named invariants, semantic linters, gotchas, behavior matrices, or product seams. Phrases: "design substrate-first", "brainstorm a refactor of X", "what's the right way to add X under cohesion pressure", "how should we restructure X without breaking invariants".
2. **Cohesion review.** Reviewing a codebase, subsystem, PR, or branch for cohesion — spec/code alignment, invariant enforcement, locality, agent-readiness. Phrases: "review for cohesion", "review the architecture for cohesion", "is this codebase cohesion-healthy", "review my PR for substrate".
3. **Substrate audit.** Auditing a repo for missing memory: implicit rules without invariants, branchy behavior without matrices, scars trapped in comments, stale docs. Phrases: "audit substrate", "what memory is missing", "what specs/invariants/gotchas should we have but don't".
4. **Spec rewrite.** Rewriting specs, behavior matrices, named invariants, or gotchas to describe a chosen end state. Phrases: "rewrite the specs for X", "update the design docs to reflect Y", "make the docs match the chosen direction".
5. **Implementation against an approved rewrite.** Driving code in a single implementation pass against a design delta ledger, with end-of-run dual reviewer dispatch. Phrases: "implement the approved rewrite", "land docs with implementation", "drive implementation against the delta", "ship the rewrite cohesively".

If the user signals one of these triggers, the orientation message names `cohesive:cohesively` as the entry point. Anything ambiguous or borderline stays out of scope — when in doubt, do not orient.

## When to defer to Superpowers

Cohesive does NOT apply when the request is implementation-discipline-shaped:

- Writing or running tests for a specific feature.
- Executing a plan that already exists (no design pressure remains).
- Finishing a development branch (PR creation, merge mechanics).
- Debugging a specific bug or error.
- Adding a small, obvious feature where substrate doesn't need pressure-testing.
- General code exploration ("where does the auth flow live?", "what does this function do?").

In these cases, defer to Superpowers' skills (`superpowers:writing-plans`, `superpowers:executing-plans`, `superpowers:test-driven-development`, `superpowers:finishing-a-development-branch`, `superpowers:requesting-code-review`, `superpowers:systematic-debugging`, etc.) or to direct user invocation. Do not render an orientation message; the absence of orientation is the right signal.

This skill is the structural mitigation that closes the trigger-competition seam between Cohesive and Superpowers; the narrowing rule (substrate-vocabulary tokens; no bare generic-review triggers) applies to this skill's own frontmatter description and is enforced by `scripts/validate_plugin.sh` Check 9a / 9b.

## How to enter Cohesive

When Cohesive applies, render the orientation in this canonical form:

```
I'll route this through `cohesive:cohesively` to pick the right approach.
```

Then invoke `cohesive:cohesively` (or recommend the user do so, depending on harness conventions). The router announces the route and dispatches the first subskill of that route. Phase transitions inside Cohesive are user-driven; the user can stop the chain at any subskill boundary.

`cohesive:cohesively` is the universal entry point. This skill never invokes a chain skill or diagnostic directly — only the router knows the routing logic, and routing through it is what closes the trigger competition this skill exists to mitigate.

## Required behavior

1. **Orient at most once per session per request shape.** Render the orientation message when the trigger fires for a request whose shape has not been oriented yet in this session. Track the request shape to detect repeats; the deferral for "already inside a Cohesive workflow" lives in Hard Constraint #4 below, not here.
2. **Defer cleanly when Superpowers fits better.** When the request is implementation-discipline-shaped, do not orient toward Cohesive. Do not render an apologetic "Cohesive doesn't apply here" message — the absence of orientation is the right signal. Superpowers' bootstrap handles the implementation-discipline framing.
3. **Never invoke a chain skill or diagnostic directly.** The only Cohesive skill this skill ever names as a next step is `cohesive:cohesively`. Naming a chain skill (e.g., `cohesive:discover-substrate`) bypasses route selection and reproduces the failure mode this skill exists to close.
4. **Never re-orient over an already-running route.** If `cohesively` has already announced a route in this session, or a Cohesive subskill is currently executing, do not render an orientation message — the user is already inside Cohesive and re-orientation would be ceremony.
5. **The frontmatter description is load-bearing.** This skill carries the substrate-narrowed trigger phrases that distinguish Cohesive's framing from Superpowers'. The narrowing mechanism is enforced by `scripts/validate_plugin.sh` Check 9a (substrate-vocabulary tokens) and Check 9b (no bare generic-review triggers); see those checks for the concrete token list and forbidden phrase list. Drift in the description re-opens the seam this skill exists to close.

## Output

A 1–2 sentence orientation message naming `cohesive:cohesively` as the entry point, rendered when the trigger fires and the user's request is substrate-shaped per §"When Cohesive applies". No persisted artifact, no verdict, no per-route dispatch.

```
I'll route this through `cohesive:cohesively` to pick the right approach.
```

When the request is implementation-discipline-shaped or otherwise outside Cohesive's framing, the skill produces no output.

## Acceptance criteria

- Orients toward Cohesive only when the request is substrate-shaped per §"When Cohesive applies".
- Defers cleanly to Superpowers (no orientation rendered) when the request is implementation-discipline-shaped per §"When to defer to Superpowers".
- The orientation message names `cohesive:cohesively` as the next step — never a chain skill or diagnostic directly.
- Renders at most one orientation per session per request shape.
- Does not re-orient over an already-running Cohesive route.
- Frontmatter description carries substrate-vocabulary tokens and avoids bare generic-review triggers per `scripts/validate_plugin.sh` Check 9a/9b.

## What this skill is *not*

- Not the router. `cohesive:cohesively` selects the route; this skill only advises whether to enter Cohesive at all.
- Not a workflow. It produces no artifact and persists no file.
- Not a discovery skill. `cohesive:discover-substrate` is the substrate-inventory skill; this skill never invokes it directly.
- Not a replacement for `superpowers:using-superpowers`. The two are session-start orientation skills for different framings; both can fire in the same session for different request types.
- Not a code-producing skill. It writes no code, no tests, no specs, no plans. Its only output is the orientation message.
- Not a substitute for the user's own judgment. The orientation is advisory; if the user explicitly invokes a Superpowers skill on substrate-shaped work, this skill does not override that choice.
